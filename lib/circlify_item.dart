import 'dart:math';

import 'package:flutter/material.dart';

/// Represents a single segment in a [Circlify] chart.
///
/// Each item has a [value] that determines its proportional size in the chart,
/// a [color] for rendering, and an optional [label] displayed on the segment.
///
/// The [id] is used for animation diffing - items with the same id will animate
/// smoothly when their values change.
///
/// Example:
/// ```dart
/// CirclifyItem(
///   id: 'sales',
///   color: Colors.blue,
///   value: 42.0,
///   label: '42%',
/// )
/// ```
class CirclifyItem {
  /// The id of the item, required for correctly updating the item.
  ///
  /// IMPORTANT: id must be unique across all items in the chart.
  /// If not provided, a UUID will be generated automatically.
  final String id;

  /// The color of the segment.
  final Color color;

  /// The value of the item, must be greater than 0.
  ///
  /// Values are relative - a chart with items of values [10, 20, 30]
  /// will look the same as one with [1, 2, 3].
  final double value;

  /// The label displayed on the center of the segment.
  ///
  /// If null, no label will be displayed.
  final String? label;

  /// Creates a chart item with the given properties.
  ///
  /// The [value] must be greater than 0.
  /// If [id] is not provided, a unique identifier will be generated.
  CirclifyItem({
    String? id,
    required this.color,
    required this.value,
    this.label,
  })  : id = id ?? _generateSimpleUuid,
        assert(value > 0, 'Value must be greater than 0');

  /// Creates a copy of this item with the given fields replaced.
  ///
  /// To explicitly set [label] to null, use [copyWithLabel] instead.
  CirclifyItem copyWith({
    Color? color,
    double? value,
    String? label,
  }) {
    return CirclifyItem(
      id: id,
      color: color ?? this.color,
      value: value ?? this.value,
      label: label ?? this.label,
    );
  }

  /// Creates a copy with explicitly setting the label (can be null).
  CirclifyItem copyWithLabel(String? label) {
    return CirclifyItem(
      id: id,
      color: color,
      value: value,
      label: label,
    );
  }
}

String get _generateSimpleUuid {
  final random = Random();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomValue = random.nextInt(1 << 32);
  return '${timestamp.toRadixString(16)}-${randomValue.toRadixString(16)}';
}
