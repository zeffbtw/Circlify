/// A Flutter package for creating customizable circular charts with smooth animations.
///
/// The main widget is [Circlify], which renders a circular chart from a list
/// of [CirclifyItem]s. The chart automatically animates when items are added,
/// removed, or their values change.
///
/// Example:
/// ```dart
/// Circlify(
///   items: [
///     CirclifyItem(id: 'a', color: Colors.red, value: 30),
///     CirclifyItem(id: 'b', color: Colors.blue, value: 70),
///   ],
///   segmentWidth: 40,
///   segmentSpacing: 5,
/// )
/// ```
library circlify;

import 'dart:math';

import 'package:flutter/material.dart';

import 'src/circlify_item.dart';
import 'src/segment_tap_details.dart';
import 'src/chart_painter.dart';
import 'src/math_utils.dart';
import 'src/segment_calculator.dart';

export 'src/circlify_item.dart';
export 'src/segment_tap_details.dart';

/// Callback signature for segment tap events.
typedef SegmentTapCallback = void Function(SegmentTapDetails details);

/// A circular chart widget with smooth animations.
///
/// Displays data as segments in a circular (donut) chart. Each segment's size
/// is proportional to its [CirclifyItem.value] relative to the total.
///
/// The chart automatically animates when:
/// - Items are added (fade in)
/// - Items are removed (fade out)
/// - Item values change (smooth size transition)
///
/// Animation diffing is based on [CirclifyItem.id], so ensure each item has
/// a unique, stable identifier for correct animations.
///
/// {@tool snippet}
/// Basic usage:
/// ```dart
/// Circlify(
///   items: [
///     CirclifyItem(id: 'sales', color: Colors.blue, value: 42, label: '42%'),
///     CirclifyItem(id: 'costs', color: Colors.red, value: 28),
///     CirclifyItem(id: 'profit', color: Colors.green, value: 30),
///   ],
/// )
/// ```
/// {@end-tool}
class Circlify extends StatefulWidget {
  const Circlify({
    super.key,
    required this.items,
    this.segmentWidth = 40,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.segmentSpacing = 5,
    this.segmentDefaultColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeIn,
    this.labelStyle,
    this.onSegmentTap,
  });

  /// Chart items
  final List<CirclifyItem> items;

  /// Segments border radius
  final BorderRadius borderRadius;

  /// Segments spacing, must be more than or equal 0 and less than circle free space amount
  final double segmentSpacing;

  /// Segments width, must be more than 0 and less than [borderRadius]
  final double segmentWidth;

  /// Segment color for empty chart
  final Color segmentDefaultColor;

  /// Animation duration
  final Duration animationDuration;

  /// Animation curve
  final Curve animationCurve;

  /// Label text style
  final TextStyle? labelStyle;

  /// Called when a segment is tapped.
  ///
  /// Provides [SegmentTapDetails] containing the tapped item, its index,
  /// and the tap position.
  final SegmentTapCallback? onSegmentTap;

  @override
  State<Circlify> createState() => _CirclifyState();
}

class _CirclifyState extends State<Circlify> with TickerProviderStateMixin {
  late List<CirclifyItem> _currentItems;
  late List<CirclifyItem> _oldItems;

  final Map<String, Animation<double>> _animations = {};
  final Map<String, AnimationController> _controllers = {};
  final Map<String, AnimationType> _animationTypes = {};
  final Map<int, CirclifyItem> _removingItems = {};
  final List<int> _removingItemsIndexes = [];

  @override
  void initState() {
    super.initState();
    _currentItems = List.from(widget.items);
    _oldItems = List.generate(widget.items.length, (index) {
      final item = widget.items[index].copyWith();
      return item;
    });
  }

  @override
  void didUpdateWidget(covariant Circlify oldWidget) {
    super.didUpdateWidget(oldWidget);
    _listIsChanged(_oldItems, widget.items);
    _oldItems = List.generate(widget.items.length, (index) {
      final item = widget.items[index].copyWith();
      return item;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
    _animationTypes.clear();
    super.dispose();
  }

  void _listIsChanged(List<CirclifyItem> oldItems, List<CirclifyItem> newItems) {
    bool isAnimated = false;

    // Remove item check
    for (int i = 0; i < oldItems.length; i++) {
      final fIndex = newItems.indexWhere((item) => item.id == oldItems[i].id);
      if (fIndex == -1) {
        _removeAnimation(oldItems, newItems, i);
        isAnimated = true;
      }
    }

    // Add item check
    for (int i = 0; i < newItems.length; i++) {
      final fIndex = oldItems.indexWhere((item) => item.id == newItems[i].id);
      if (fIndex == -1) {
        _addAnimation(oldItems, newItems, i);
        isAnimated = true;
      }
    }

    // Change value check
    for (int i = 0; i < newItems.length; i++) {
      final fIndex = oldItems.indexWhere((item) => item.id == newItems[i].id);

      if (fIndex != -1 && newItems[i].value != oldItems[fIndex].value) {
        _updateValueAnimation(oldItems, newItems, fIndex, i);
        isAnimated = true;
      }
    }

    // Need for update _currentItems without animation
    if (isAnimated == false) {
      _currentItems = List.from(newItems);
      setState(() {});
    }
  }

  void _removeAnimation(List<CirclifyItem> oldItems, List<CirclifyItem> newItems, int index) {
    final itemId = oldItems[index].id;

    _controllers[itemId]?.dispose();

    final controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _controllers[itemId] = controller;

    controller.addListener(() {
      if (mounted) setState(() {});
    });

    _removingItemsIndexes.add(index);
    _removingItems[index] = oldItems[index];
    _animationTypes[itemId] = AnimationType.remove;
    _animations[itemId] = Tween<double>(
      begin: 1,
      end: 0.01,
    ).chain(CurveTween(curve: widget.animationCurve)).animate(controller)
      ..addStatusListener((status) {
        if (status.isCompleted) {
          _animations.remove(itemId);
          _animationTypes.remove(itemId);
          _removingItems.remove(index);
          _removingItemsIndexes.remove(index);
          _controllers.remove(itemId)?.dispose();
        }
      });
    controller.forward();
    setState(() {
      _currentItems = List.from(newItems);
    });
  }

  void _addAnimation(List<CirclifyItem> oldItems, List<CirclifyItem> newItems, int index) {
    final itemId = newItems[index].id;

    _controllers[itemId]?.dispose();

    final controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _controllers[itemId] = controller;

    controller.addListener(() {
      if (mounted) setState(() {});
    });

    _animationTypes[itemId] = AnimationType.add;
    _animations[itemId] = Tween<double>(
      begin: 0.01,
      end: 1,
    ).chain(CurveTween(curve: widget.animationCurve)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animations.remove(itemId);
          _animationTypes.remove(itemId);
          _controllers.remove(itemId)?.dispose();
        }
      });
    controller.forward();
    setState(() {
      _currentItems = List.from(newItems);
    });
  }

  void _updateValueAnimation(
      List<CirclifyItem> oldItems, List<CirclifyItem> newItems, int oldItemIndex, int newItemIndex) {
    final itemId = newItems[newItemIndex].id;

    _controllers[itemId]?.dispose();

    final controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _controllers[itemId] = controller;

    controller.addListener(() {
      if (mounted) setState(() {});
    });

    _animationTypes[itemId] = AnimationType.updateValue;
    _animations[itemId] = Tween<double>(
      begin: oldItems[oldItemIndex].value / newItems[newItemIndex].value,
      end: 1,
    ).chain(CurveTween(curve: widget.animationCurve)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animations.remove(itemId);
          _animationTypes.remove(itemId);
          _controllers.remove(itemId)?.dispose();
        }
      });
    controller.forward();
    setState(() {
      _currentItems = List.from(newItems);
    });
  }

  List<CirclifyItem> get _formattedItems {
    final List<CirclifyItem> formattedItems = List.from(_currentItems);

    for (int i = 0; i < _removingItemsIndexes.length; i++) {
      if (_removingItems[_removingItemsIndexes[i]] != null) {
        formattedItems.insert(_removingItemsIndexes[i], _removingItems[_removingItemsIndexes[i]]!);
      }
    }
    return formattedItems;
  }

  /// Hit tests the given position to find the tapped segment.
  SegmentTapDetails? _hitTest(Offset position, Size size) {
    final items = _formattedItems;
    if (items.isEmpty) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - widget.segmentWidth;

    // Calculate distance from center
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    // Check if tap is within the ring
    if (distance < innerRadius || distance > outerRadius) {
      return null;
    }

    // Single item covers the full circle
    if (items.length == 1) {
      return SegmentTapDetails(
        item: items[0],
        index: 0,
        localPosition: position,
      );
    }

    // Calculate angle in degrees (0-360)
    double angle = atan2(dy, dx) * (180 / pi);
    if (angle < 0) angle += 360;

    // Calculate segment boundaries
    final segmentPadding = ChartMathUtils.scalarToAngle(
      outerRadius - widget.segmentWidth / 2,
      widget.segmentSpacing,
    );

    // Get adjusted percentages using shared calculator
    List<double> adjustedPercentages = SegmentCalculator.calculateAdjustedPercentages(
      items: items,
      segmentPadding: segmentPadding,
      animations: _animations,
      animationTypes: _animationTypes,
    );

    // Find which segment the angle falls into
    double startAngle = 0;
    for (int i = 0; i < items.length; i++) {
      double segmentDegrees = adjustedPercentages[i] * 360;
      double endAngle = startAngle + segmentDegrees;

      // Normalize angle for comparison (chart uses 180° offset)
      double normalizedTapAngle = angle - 180;
      if (normalizedTapAngle < 0) normalizedTapAngle += 360;

      if (normalizedTapAngle >= startAngle && normalizedTapAngle < endAngle) {
        return SegmentTapDetails(
          item: items[i],
          index: i,
          localPosition: position,
        );
      }

      startAngle = endAngle + segmentPadding;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final radius = size.width / 2;

        double maxSegmentSpacing = SegmentCalculator.calculateMaxSegmentSpacing(
          widget.items,
          radius - widget.segmentWidth / 2,
        );

        assert(
          widget.segmentSpacing >= 0 && widget.segmentSpacing <= maxSegmentSpacing,
          'Segment spacing is too large for the number of segments and the size of the chart',
        );

        assert(
          widget.segmentWidth >= 1 && widget.segmentWidth < radius,
          'Segment width is too large or too small for the size of the chart',
        );

        final customPaint = CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: CircleChartPainter(
            currentItems: _formattedItems,
            segmentWidth: widget.segmentWidth,
            borderRadius: widget.borderRadius,
            segmentSpacing: widget.segmentSpacing,
            segmentDefaultColor: widget.segmentDefaultColor,
            animations: _animations,
            animationTypes: _animationTypes,
            labelStyle: widget.labelStyle,
          ),
        );

        if (widget.onSegmentTap == null) {
          return customPaint;
        }

        return GestureDetector(
          onTapUp: (details) {
            final hitResult = _hitTest(details.localPosition, size);
            if (hitResult != null) {
              widget.onSegmentTap!(hitResult);
            }
          },
          child: customPaint,
        );
      },
    );
  }
}
