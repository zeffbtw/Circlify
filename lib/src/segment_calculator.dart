import 'dart:math';

import 'circlify_item.dart';
import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import 'constants.dart';

/// Animation type for segment transitions.
@internal
enum AnimationType {
  remove,
  add,
  updateValue,
}

/// Calculates segment percentages for circular charts.
@internal
class SegmentCalculator {
  SegmentCalculator._();

  /// Calculates the maximum allowed segment spacing for a given number of items.
  static double calculateMaxSegmentSpacing(List<CirclifyItem> items, double radius) {
    int itemCount = items.length;

    if (itemCount == 0) return double.infinity;

    double circumference = 2 * pi * radius;
    double totalMinSegmentLength = minSegmentPercentage * circumference * itemCount;
    double maxTotalGapLength = circumference - totalMinSegmentLength;

    if (maxTotalGapLength <= 0) return 0;
    return maxTotalGapLength / itemCount;
  }

  /// Calculates adjusted percentages for segments, applying minimum size constraints.
  ///
  /// [items] - List of chart items
  /// [segmentPadding] - Padding between segments in degrees
  /// [animations] - Optional animation values for each item (by id)
  /// [animationTypes] - Optional animation types for each item (by id)
  static List<double> calculateAdjustedPercentages({
    required List<CirclifyItem> items,
    required double segmentPadding,
    Map<String, Animation<double>>? animations,
    Map<String, AnimationType>? animationTypes,
  }) {
    if (items.isEmpty) return [];

    double totalSize = items.fold(0.0, (sum, item) => sum + item.value);

    List<double> rawPercentages = items.map((item) {
      if (totalSize == 0) return 0.0;
      return item.value / totalSize;
    }).toList();

    double gapPercentage = segmentPadding / 360;
    double totalGapPercentage = items.length * gapPercentage;
    double availablePercentage = 1 - totalGapPercentage;

    List<double> adjustedPercentages = List.from(rawPercentages);
    double totalAdjustedPercentage = 0;

    for (int i = 0; i < adjustedPercentages.length; i++) {
      if (adjustedPercentages[i] < minSegmentPercentage) {
        final itemId = items[i].id;
        final animationValue = animations?[itemId]?.value;
        final animationType = animationTypes?[itemId];

        if (animationValue == null || animationType == AnimationType.updateValue) {
          adjustedPercentages[i] = minSegmentPercentage;
        } else {
          // Keep original percentage during add/remove animations
          availablePercentage -= gapPercentage * animationValue;
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
}
