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

  CirclifyItem({
    String? id,
    required this.color,
    required this.value,
  })  : id = id ?? _generateSimpleUuid,
        assert(value > 0, 'Value must be greater than 0');
}

String get _generateSimpleUuid {
  var random = Random();
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  var randomValue = random.nextInt(1 << 32);
  return '${timestamp.toRadixString(16)}-${randomValue.toRadixString(16)}';
}
