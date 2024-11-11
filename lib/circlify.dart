library circlify;

import 'dart:math';
import 'package:circlify/circlify_item.dart';
import 'package:circlify/math_utils.dart';
import 'package:flutter/material.dart';

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

  @override
  State<Circlify> createState() => _CirclifyState();
}

class _CirclifyState extends State<Circlify> with TickerProviderStateMixin {
  late List<CirclifyItem> _currentItems;
  late List<CirclifyItem> _oldItems;

  final Map<String, Animation<double>> _animations = {};
  final Map<String, _AnimationType> _animationTypes = {};
  final Map<int, CirclifyItem> _removingItems = {};
  final List<int> _removingItemsIndexes = [];
  @override
  void initState() {
    super.initState();
    _currentItems = List.from(widget.items);
    _oldItems = List.generate(widget.items.length, (index) {
      final item = widget.items[index];

      return CirclifyItem(
        id: item.id,
        color: item.color,
        value: item.value,
      );
    });
  }

  @override
  void didUpdateWidget(covariant Circlify oldWidget) {
    _listIsChanged(_oldItems, widget.items);
    _oldItems = List.generate(widget.items.length, (index) {
      final item = widget.items[index];
      return CirclifyItem(
        id: item.id,
        color: item.color,
        value: item.value,
      );
    });
    super.didUpdateWidget(oldWidget);
  }

  void _listIsChanged(List<CirclifyItem> oldItems, List<CirclifyItem> newItems) {
    // Remove item check
    for (int i = 0; i < oldItems.length; i++) {
      final fIndex = newItems.indexWhere((item) => item.id == oldItems[i].id);
      if (fIndex == -1) {
        _removeAnimation(oldItems, newItems, i);
      }
    }

    // Add item check
    for (int i = 0; i < newItems.length; i++) {
      final fIndex = oldItems.indexWhere((item) => item.id == newItems[i].id);
      if (fIndex == -1) {
        _addAnimation(oldItems, newItems, i);
      }
    }

    // Change value check
    for (int i = 0; i < newItems.length; i++) {
      final fIndex = oldItems.indexWhere((item) => item.id == newItems[i].id);

      if (fIndex != -1 && newItems[i].value != oldItems[fIndex].value) {
        _updateValueAnimation(oldItems, newItems, fIndex, i);
      }
    }
  }

  void _removeAnimation(List<CirclifyItem> oldItems, List<CirclifyItem> newItems, int index) {
    final itemId = oldItems[index].id;

    final controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..drive(CurveTween(curve: widget.animationCurve));
    controller.addListener(() {
      setState(() {});
    });
    _removingItemsIndexes.add(index);
    _removingItems[index] = oldItems[index];
    _animationTypes[itemId] = _AnimationType.remove;
    _animations[itemId] = Tween<double>(
      begin: 1,
      end: 0.01,
    ).chain(CurveTween(curve: widget.animationCurve)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animations.remove(itemId);
          _animationTypes.remove(itemId);
          _removingItems.remove(index);
          _removingItemsIndexes.remove(index);
          controller.removeListener(() {});
          controller.dispose();
        }
      });
    controller.forward();
    setState(() {
      _currentItems = List.from(newItems);
    });
  }

  void _addAnimation(List<CirclifyItem> oldItems, List<CirclifyItem> newItems, int index) {
    final itemId = newItems[index].id;
    final controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    controller.addListener(() {
      setState(() {});
    });
    _animationTypes[itemId] = _AnimationType.add;
    _animations[itemId] = Tween<double>(
      begin: 0.01,
      end: 1,
    ).chain(CurveTween(curve: widget.animationCurve)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animations.remove(itemId);
          _animationTypes.remove(itemId);
          controller.removeListener(() {});
          controller.dispose();
        }
      });
    controller.forward();
    setState(() {
      _currentItems = List.from(newItems);
    });
  }

  void _updateValueAnimation(List<CirclifyItem> oldItems, List<CirclifyItem> newItems, int oldItemIndex, int newItemIndex) {
    final itemId = newItems[newItemIndex].id;

    final controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..drive(CurveTween(curve: widget.animationCurve));
    controller.addListener(() {
      setState(() {});
    });
    _animationTypes[itemId] = _AnimationType.updateValue;
    _animations[itemId] = Tween<double>(
      begin: oldItems[oldItemIndex].value / newItems[newItemIndex].value,
      end: 1,
    ).chain(CurveTween(curve: widget.animationCurve)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animations.remove(itemId);
          _animationTypes.remove(itemId);
          controller.removeListener(() {});
          controller.dispose();
        }
      });
    controller.forward();
    setState(() {
      _currentItems = List.from(newItems);
    });
  }

  static double _calculateMaxSegmentSpacing(List<CirclifyItem> items, double radius) {
    double minPercentage = 0.025;
    int itemCount = items.length;

    if (itemCount == 0) return double.infinity;

    double circumference = 2 * pi * radius;
    double totalMinSegmentLength = minPercentage * circumference * itemCount;
    double maxTotalGapLength = circumference - totalMinSegmentLength;

    if (maxTotalGapLength <= 0) return 0;
    return maxTotalGapLength / itemCount;
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final radius = size.width / 2;

        double maxSegmentSpacing = _calculateMaxSegmentSpacing(widget.items, radius - widget.segmentWidth / 2);
        assert(
          widget.segmentSpacing >= 0 && widget.segmentSpacing <= maxSegmentSpacing,
          'Segment spacing is too large for the number of segments and the size of the chart or the number of segments is too large',
        );

        assert(
          widget.segmentWidth >= 1 && widget.segmentWidth < radius,
          'Segment width is too large or too small for the size of the chart',
        );

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _CircleChartPainter(
            currentItems: _formattedItems,
            segmentWidth: widget.segmentWidth,
            borderRadius: widget.borderRadius,
            segmentSpacing: widget.segmentSpacing,
            segmentDefaultColor: widget.segmentDefaultColor,
            animations: _animations,
            animationTypes: _animationTypes,
          ),
        );
      },
    );
  }
}

class _CircleChartPainter extends CustomPainter {
  _CircleChartPainter({
    required List<CirclifyItem> currentItems,
    required this.segmentWidth,
    required this.borderRadius,
    required this.segmentSpacing,
    required this.segmentDefaultColor,
    required this.animations,
    required this.animationTypes,
  }) : items = List.generate(currentItems.length, (index) {
          final item = currentItems[index];
          return CirclifyItem(
            id: item.id,
            value: item.value * (animations[item.id]?.value ?? 1).abs(),
            color: item.color,
          );
        });

  final List<CirclifyItem> items;
  final double segmentWidth;
  final double segmentSpacing;
  final BorderRadius borderRadius;
  final Color segmentDefaultColor;
  final Map<String, Animation<double>> animations;
  final Map<String, _AnimationType> animationTypes;

  @override
  void paint(Canvas canvas, Size size) {
    double segmentPadding = MathUtils.scalarToAngle(size.width / 2 - segmentWidth / 2, segmentSpacing);
    List<double> adjustedPercentages = _calculateAdjustedPercentages(segmentPadding);
    double startAngle = 0;

    if (items.isEmpty) {
      _drawSingleSegment(
        canvas: canvas,
        size: size,
        color: segmentDefaultColor,
        segmentWidth: segmentWidth,
      );
      return;
    }
    if (items.length == 1) {
      _drawSingleSegment(
        canvas: canvas,
        size: size,
        color: items[0].color,
        segmentWidth: segmentWidth,
      );
      return;
    }

    for (int i = 0; i < items.length; i++) {
      double segmentDegrees = adjustedPercentages[i] * 360;
      _drawSegment(
        canvas: canvas,
        size: size,
        color: items[i].color,
        segmentStartAngle: startAngle,
        segmentSizeAngle: segmentDegrees,
        segmentWidth: segmentWidth,
      );
      startAngle += segmentDegrees + segmentPadding;
    }
  }

  List<double> _calculateAdjustedPercentages(double segmentPadding) {
    double totalSize = items.fold(0, (sum, item) => sum + item.value);
    List<double> rawPercentages = items.map((item) {
      if (totalSize == 0) return 0.0;
      return item.value / totalSize;
    }).toList();

    double minPercentage = 0.025;
    double gapPercentage = segmentPadding / 360;
    double totalGapPercentage = items.length * gapPercentage;
    double availablePercentage = 1 - totalGapPercentage;

    List<double> adjustedPercentages = List.from(rawPercentages);
    double totalAdjustedPercentage = 0;

    for (int i = 0; i < adjustedPercentages.length; i++) {
      if (adjustedPercentages[i] < minPercentage) {
        final itemId = items[i].id;
        if (animations[itemId]?.value == null || animationTypes[itemId] == _AnimationType.updateValue) {
          adjustedPercentages[i] = minPercentage;
        } else {
          adjustedPercentages[i] = adjustedPercentages[i];
          availablePercentage -= gapPercentage * animations[itemId]!.value;
        }
      }
      totalAdjustedPercentage += adjustedPercentages[i];
    }

    double scale = availablePercentage / totalAdjustedPercentage;
    for (int i = 0; i < adjustedPercentages.length; i++) {
      adjustedPercentages[i] *= scale;
    }

    return adjustedPercentages;
  }

  /// Draws a single segment of the circle chart.
  ///
  /// The segment is drawn at the given [color] with a stroke width of
  /// [segmentWidth]. The segment is anti-aliased and covers the entire
  /// circle, leaving no gaps.
  ///
  /// The [canvas] is the canvas to draw upon and [size] is the size of the
  /// canvas.
  ///
  /// Returns nothing.
  void _drawSingleSegment({
    required Canvas canvas,
    required Size size,
    required double segmentWidth,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = segmentWidth
      ..isAntiAlias = true;

    final double radius = (size.width / 2) - (segmentWidth / 2);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
      0,
      2 * pi,
      false,
      paint,
    );
  }

  /// Draws a single segment of a circle chart.
  ///
  /// This method draws a single segment of a circle chart on the given
  /// [canvas] with the specified [size], [segmentStartAngle], [segmentSizeAngle],
  /// [segmentWidth], and [color].
  ///
  /// The segment is drawn with a "tail" at the start and end of the segment,
  /// similar to a pie chart.
  ///
  /// The [segmentStartAngle] and [segmentSizeAngle] are in degrees, with
  /// 0 degrees at the 3 o'clock position. The [segmentWidth] is the width of
  /// the segment, in pixels.
  ///
  /// The method returns nothing.
  ///
  /// The caller is responsible for configuring the [canvas] and [paint]
  /// correctly before calling this method.
  void _drawSegment({
    required Canvas canvas,
    required Size size,
    required double segmentStartAngle,
    required double segmentSizeAngle,
    required double segmentWidth,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    final path = Path();
    final borderRadius = _normalizeBorderRadius(
      this.borderRadius,
      MathUtils.angleToScalar(size.width / 2, segmentSizeAngle),
      MathUtils.angleToScalar(size.width / 2 - segmentWidth, segmentSizeAngle),
      segmentWidth,
    );

    // Start of segment
    final start = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(borderRadius.topLeft.y, size.height / 2),
      angle: segmentStartAngle,
    );

    path.moveTo(start.dx, start.dy);

    final snapOfAngle4 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(0, size.height / 2),
      angle: segmentStartAngle,
    );

    final startOfAngle4 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(0, size.height / 2),
      angle: segmentStartAngle + MathUtils.scalarToAngle(size.width / 2, borderRadius.topLeft.x),
    );

    // Draw angle 4
    path.quadraticBezierTo(
      snapOfAngle4.dx,
      snapOfAngle4.dy,
      startOfAngle4.dx,
      startOfAngle4.dy,
    );

    final arcRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    // Draw arc 1
    path.arcTo(
      arcRect,
      pi + (segmentStartAngle + MathUtils.scalarToAngle(size.width / 2, borderRadius.topLeft.x)) * (pi / 180),
      pi / (180 / (segmentSizeAngle - MathUtils.scalarToAngle(size.width / 2, borderRadius.topLeft.x + borderRadius.topRight.x))),
      false,
    );

    // End of arc 1, snap of angle 1
    final snapOfAngle1 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(0, size.height / 2),
      angle: segmentSizeAngle + segmentStartAngle,
    );

    // End of help arc 1, end of angle 1
    final endOfAngle1 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(borderRadius.topRight.y, size.height / 2),
      angle: segmentSizeAngle + segmentStartAngle,
    );

    // Draw angle 1
    path.quadraticBezierTo(
      snapOfAngle1.dx,
      snapOfAngle1.dy,
      endOfAngle1.dx,
      endOfAngle1.dy,
    );

    // End of help arc 2, start of angle 2
    final startOfAngle2 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(segmentWidth - borderRadius.bottomRight.y, size.height / 2),
      angle: segmentSizeAngle + segmentStartAngle,
    );

    // End of angle 2
    final endOfAngle2 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(segmentWidth, size.height / 2),
      angle: segmentSizeAngle - MathUtils.scalarToAngle(size.width / 2 - segmentWidth, borderRadius.bottomRight.x) + segmentStartAngle,
    );

    final point2Angle2 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(segmentWidth, size.height / 2),
      angle: segmentSizeAngle + segmentStartAngle,
    );

    // End of arc 2, snap of angle 2
    late final Offset snapOfAngle2;
    if (borderRadius.bottomRight.x > 0) {
      snapOfAngle2 = MathUtils.findIntersectionWithTangent(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - segmentWidth,
        angleDegrees: 180 + (segmentStartAngle + segmentSizeAngle - MathUtils.scalarToAngle(size.width / 2 - segmentWidth, borderRadius.bottomRight.x)),
        point1: startOfAngle2,
        point2: point2Angle2,
      );
    } else {
      snapOfAngle2 = endOfAngle2;
    }

    // Draw line to angle 2
    path.lineTo(startOfAngle2.dx, startOfAngle2.dy);

    // Draw angle 2
    path.quadraticBezierTo(
      snapOfAngle2.dx,
      snapOfAngle2.dy,
      endOfAngle2.dx,
      endOfAngle2.dy,
    );

    // Arc 2
    final arcRect2 = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - segmentWidth,
    );
    path.arcTo(
      arcRect2,
      pi + pi / (180 / (segmentStartAngle + segmentSizeAngle - MathUtils.scalarToAngle(size.width / 2 - segmentWidth, borderRadius.bottomRight.x))),
      -pi / (180 / (segmentSizeAngle - MathUtils.scalarToAngle(size.width / 2 - segmentWidth, borderRadius.bottomLeft.x + borderRadius.bottomRight.x))),
      false,
    );

    final point1Angle3 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(segmentWidth, size.height / 2),
      angle: segmentStartAngle,
    );

    // End of help arc 2, end of angle 3
    final endOfAngle3 = MathUtils.calcEndOfArc(
      center: Offset(size.width / 2, size.height / 2),
      start: Offset(segmentWidth - borderRadius.bottomLeft.y, size.height / 2),
      angle: segmentStartAngle,
    );

    // Snap of angle 3
    late final Offset snapOfAngle3;
    if (borderRadius.bottomLeft.x == 0) {
      snapOfAngle3 = endOfAngle3;
    } else {
      snapOfAngle3 = MathUtils.findIntersectionWithTangent(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - segmentWidth,
        angleDegrees: 180 + (segmentStartAngle + MathUtils.scalarToAngle(size.width / 2 - segmentWidth, borderRadius.bottomLeft.x)),
        point1: point1Angle3,
        point2: endOfAngle3,
      );
    }

    // final path2 = Path();
    // path2.moveTo(point1Angle3.dx, point1Angle3.dy);
    // // path2.lineTo(endOfAngle3.dx, endOfAngle3.dy);
    // path2.lineTo(snapOfAngle3.dx, snapOfAngle3.dy);
    // path2.lineTo(0, 0);
    // canvas.drawPath(path2, paint);

    // path.lineTo(snapOfAngle3.dx, snapOfAngle3.dy);
    // path.lineTo(endOfAngle3.dx, endOfAngle3.dy);

    // Draw angle 3
    path.quadraticBezierTo(
      snapOfAngle3.dx,
      snapOfAngle3.dy,
      endOfAngle3.dx,
      endOfAngle3.dy,
    );

    // Close the line with start
    path.close();
    canvas.drawPath(path, paint);
  }

  static BorderRadius _normalizeBorderRadius(
    BorderRadius borderRadius,
    double segmentWidthTop,
    double segmentWidthBottom,
    double segmentHeight,
  ) {
    // Половинные ширины верхней и нижней частей сегмента
    double halfSegmentWidthTop = segmentWidthTop / 2.0;
    double halfSegmentWidthBottom = segmentWidthBottom / 5;
    double halfSegmentHeight = segmentHeight / 2.0;

    // Нормализация для верхнего левого угла
    double topLeftMaxHorizontalRadius = halfSegmentWidthTop;
    double topLeftMaxVerticalRadius = halfSegmentHeight;
    double topLeftHorizontalRadius = borderRadius.topLeft.x;
    double topLeftVerticalRadius = borderRadius.topLeft.y;
    double topLeftHorizontalRatio = topLeftHorizontalRadius > topLeftMaxHorizontalRadius ? topLeftMaxHorizontalRadius / topLeftHorizontalRadius : 1.0;
    double topLeftVerticalRatio = topLeftVerticalRadius > topLeftMaxVerticalRadius ? topLeftMaxVerticalRadius / topLeftVerticalRadius : 1.0;
    double topLeftRatio = min(topLeftHorizontalRatio, topLeftVerticalRatio);

    // Нормализация для нижнего левого угла
    double bottomLeftMaxHorizontalRadius = halfSegmentWidthBottom;
    double bottomLeftMaxVerticalRadius = halfSegmentHeight;
    double bottomLeftHorizontalRadius = borderRadius.bottomLeft.x;
    double bottomLeftVerticalRadius = borderRadius.bottomLeft.y;
    double bottomLeftHorizontalRatio = bottomLeftHorizontalRadius > bottomLeftMaxHorizontalRadius ? bottomLeftMaxHorizontalRadius / bottomLeftHorizontalRadius : 1.0;
    double bottomLeftVerticalRatio = bottomLeftVerticalRadius > bottomLeftMaxVerticalRadius ? bottomLeftMaxVerticalRadius / bottomLeftVerticalRadius : 1.0;
    double bottomLeftRatio = min(bottomLeftHorizontalRatio, bottomLeftVerticalRatio);

    // Нормализация для верхнего правого угла
    double topRightMaxHorizontalRadius = halfSegmentWidthTop;
    double topRightMaxVerticalRadius = halfSegmentHeight;
    double topRightHorizontalRadius = borderRadius.topRight.x;
    double topRightVerticalRadius = borderRadius.topRight.y;
    double topRightHorizontalRatio = topRightHorizontalRadius > topRightMaxHorizontalRadius ? topRightMaxHorizontalRadius / topRightHorizontalRadius : 1.0;
    double topRightVerticalRatio = topRightVerticalRadius > topRightMaxVerticalRadius ? topRightMaxVerticalRadius / topRightVerticalRadius : 1.0;
    double topRightRatio = min(topRightHorizontalRatio, topRightVerticalRatio);

    // Нормализация для нижнего правого угла
    double bottomRightMaxHorizontalRadius = halfSegmentWidthBottom;
    double bottomRightMaxVerticalRadius = halfSegmentHeight;
    double bottomRightHorizontalRadius = borderRadius.bottomRight.x;
    double bottomRightVerticalRadius = borderRadius.bottomRight.y;
    double bottomRightHorizontalRatio = bottomRightHorizontalRadius > bottomRightMaxHorizontalRadius ? bottomRightMaxHorizontalRadius / bottomRightHorizontalRadius : 1.0;
    double bottomRightVerticalRatio = bottomRightVerticalRadius > bottomRightMaxVerticalRadius ? bottomRightMaxVerticalRadius / bottomRightVerticalRadius : 1.0;
    double bottomRightRatio = min(bottomRightHorizontalRatio, bottomRightVerticalRatio);

    return BorderRadius.only(
      topLeft: Radius.elliptical(
        borderRadius.topLeft.x * topLeftRatio,
        borderRadius.topLeft.y * topLeftRatio,
      ),
      bottomLeft: Radius.elliptical(
        borderRadius.bottomLeft.x * bottomLeftRatio,
        borderRadius.bottomLeft.y * bottomLeftRatio,
      ),
      topRight: Radius.elliptical(
        borderRadius.topRight.x * topRightRatio,
        borderRadius.topRight.y * topRightRatio,
      ),
      bottomRight: Radius.elliptical(
        borderRadius.bottomRight.x * bottomRightRatio,
        borderRadius.bottomRight.y * bottomRightRatio,
      ),
    );
  }

  double get allItemsSize => items.map((e) => e.value).fold(0, (a, b) => a + b);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum _AnimationType {
  remove,
  add,
  updateValue,
}
