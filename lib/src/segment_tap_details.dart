import 'circlify_item.dart';
import 'package:flutter/material.dart';

/// Contains information about a tapped segment.
class SegmentTapDetails {
  /// The tapped chart item.
  final CirclifyItem item;

  /// The index of the tapped item in the items list.
  final int index;

  /// The tap position relative to the widget.
  final Offset localPosition;

  const SegmentTapDetails({
    required this.item,
    required this.index,
    required this.localPosition,
  });
}
