import 'dart:math';

import 'package:flutter/material.dart';

class CirclifyItem {
  /// The id of the item, required for correctly updating the item
  ///
  /// IMPORTANT: id must be unique
  final String id;

  /// The color of the item
  Color color;

  /// The value of the item, must be greater than 0
  double value;

  /// The label of the item, drawn on center of the segment
  String? label;

  CirclifyItem({
    String? id,
    required this.color,
    required this.value,
    this.label,
  })  : id = id ?? _generateSimpleUuid,
        assert(value > 0, 'Value must be greater than 0');

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
}

String get _generateSimpleUuid {
  var random = Random();
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  var randomValue = random.nextInt(1 << 32);
  return '${timestamp.toRadixString(16)}-${randomValue.toRadixString(16)}';
}
