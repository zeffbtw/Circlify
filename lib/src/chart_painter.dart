import 'dart:math';

import 'circlify_item.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'math_utils.dart';
import 'segment_calculator.dart';

/// CustomPainter for rendering circular chart segments.
@internal
class CircleChartPainter extends CustomPainter {
  CircleChartPainter({
    required List<CirclifyItem> currentItems,
    required this.segmentWidth,
    required this.borderRadius,
    required this.segmentSpacing,
    required this.segmentDefaultColor,
    required this.animations,
    required this.animationTypes,
    this.labelStyle,
  }) : items = List.generate(currentItems.length, (index) {
          final item = currentItems[index];
          return item.copyWith(
            value: item.value * (animations[item.id]?.value ?? 1).abs(),
          );
        });

  final List<CirclifyItem> items;
  final double segmentWidth;
  final double segmentSpacing;
  final BorderRadius borderRadius;
  final Color segmentDefaultColor;
  final Map<String, Animation<double>> animations;
  final Map<String, AnimationType> animationTypes;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    double segmentPadding =
        ChartMathUtils.scalarToAngle(size.width / 2 - segmentWidth / 2, segmentSpacing);

    List<double> adjustedPercentages = SegmentCalculator.calculateAdjustedPercentages(
      items: items,
      segmentPadding: segmentPadding,
      animations: animations,
      animationTypes: animationTypes,
    );

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
        label: items[0].label,
      );
      return;
    }

    for (int i = 0; i < items.length; i++) {
      double segmentDegrees = adjustedPercentages[i] * 360;
      _drawSegment(
        canvas: canvas,
        size: size,
        item: items[i],
        segmentStartAngle: startAngle,
        segmentSizeAngle: segmentDegrees,
        segmentWidth: segmentWidth,
      );
      startAngle += segmentDegrees + segmentPadding;
    }
  }

  void _drawSingleSegment({
    required Canvas canvas,
    required Size size,
    required double segmentWidth,
    required Color color,
    String? label,
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
    if (label != null) {
      _drawText(
        canvas: canvas,
        size: size,
        text: label,
        offset: Offset(size.width / 2, segmentWidth / 2),
      );
    }
  }

  void _drawSegment({
    required Canvas canvas,
    required Size size,
    required double segmentStartAngle,
    required double segmentSizeAngle,
    required double segmentWidth,
    required CirclifyItem item,
  }) {
    final paint = Paint()
      ..color = item.color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    final path = Path();

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - segmentWidth;

    final normalizedBorderRadius = _normalizeBorderRadius(
      borderRadius,
      ChartMathUtils.angleToScalar(outerRadius, segmentSizeAngle),
      ChartMathUtils.angleToScalar(innerRadius, segmentSizeAngle),
      segmentWidth,
    );

    // Start of segment
    final start = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(normalizedBorderRadius.topLeft.y, size.height / 2),
      angle: segmentStartAngle,
    );

    path.moveTo(start.dx, start.dy);

    final snapOfAngle4 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(0, size.height / 2),
      angle: segmentStartAngle,
    );

    final startOfAngle4 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(0, size.height / 2),
      angle: segmentStartAngle +
          ChartMathUtils.scalarToAngle(outerRadius, normalizedBorderRadius.topLeft.x),
    );

    // Draw angle 4
    path.quadraticBezierTo(
      snapOfAngle4.dx,
      snapOfAngle4.dy,
      startOfAngle4.dx,
      startOfAngle4.dy,
    );

    final arcRect = Rect.fromCircle(center: center, radius: outerRadius);

    // Draw arc 1
    path.arcTo(
      arcRect,
      pi +
          (segmentStartAngle +
                  ChartMathUtils.scalarToAngle(outerRadius, normalizedBorderRadius.topLeft.x)) *
              (pi / 180),
      pi /
          (180 /
              (segmentSizeAngle -
                  ChartMathUtils.scalarToAngle(outerRadius,
                      normalizedBorderRadius.topLeft.x + normalizedBorderRadius.topRight.x))),
      false,
    );

    // End of arc 1, snap of angle 1
    final snapOfAngle1 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(0, size.height / 2),
      angle: segmentSizeAngle + segmentStartAngle,
    );

    // End of help arc 1, end of angle 1
    final endOfAngle1 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(normalizedBorderRadius.topRight.y, size.height / 2),
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
    final startOfAngle2 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(segmentWidth - normalizedBorderRadius.bottomRight.y, size.height / 2),
      angle: segmentSizeAngle + segmentStartAngle,
    );

    // End of angle 2
    final endOfAngle2 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(segmentWidth, size.height / 2),
      angle: segmentSizeAngle -
          ChartMathUtils.scalarToAngle(innerRadius, normalizedBorderRadius.bottomRight.x) +
          segmentStartAngle,
    );

    final point2Angle2 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(segmentWidth, size.height / 2),
      angle: segmentSizeAngle + segmentStartAngle,
    );

    // End of arc 2, snap of angle 2
    late final Offset snapOfAngle2;
    if (normalizedBorderRadius.bottomRight.x > 0) {
      snapOfAngle2 = ChartMathUtils.findIntersectionWithTangent(
        center: center,
        radius: innerRadius,
        angleDegrees: 180 +
            (segmentStartAngle +
                segmentSizeAngle -
                ChartMathUtils.scalarToAngle(innerRadius, normalizedBorderRadius.bottomRight.x)),
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
    final arcRect2 = Rect.fromCircle(center: center, radius: innerRadius);
    path.arcTo(
      arcRect2,
      pi +
          pi /
              (180 /
                  (segmentStartAngle +
                      segmentSizeAngle -
                      ChartMathUtils.scalarToAngle(
                          innerRadius, normalizedBorderRadius.bottomRight.x))),
      -pi /
          (180 /
              (segmentSizeAngle -
                  ChartMathUtils.scalarToAngle(innerRadius,
                      normalizedBorderRadius.bottomLeft.x + normalizedBorderRadius.bottomRight.x))),
      false,
    );

    final point1Angle3 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(segmentWidth, size.height / 2),
      angle: segmentStartAngle,
    );

    // End of help arc 2, end of angle 3
    final endOfAngle3 = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(segmentWidth - normalizedBorderRadius.bottomLeft.y, size.height / 2),
      angle: segmentStartAngle,
    );

    // Snap of angle 3
    late final Offset snapOfAngle3;
    if (normalizedBorderRadius.bottomLeft.x == 0) {
      snapOfAngle3 = endOfAngle3;
    } else {
      snapOfAngle3 = ChartMathUtils.findIntersectionWithTangent(
        center: center,
        radius: innerRadius,
        angleDegrees: 180 +
            (segmentStartAngle +
                ChartMathUtils.scalarToAngle(innerRadius, normalizedBorderRadius.bottomLeft.x)),
        point1: point1Angle3,
        point2: endOfAngle3,
      );
    }

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

    final textPoint = ChartMathUtils.calcEndOfArc(
      center: center,
      start: Offset(segmentWidth / 2, size.height / 2),
      angle: segmentSizeAngle / 2 + segmentStartAngle,
    );

    if (item.label != null) {
      _drawText(
        canvas: canvas,
        size: size,
        text: item.label!,
        offset: textPoint,
      );
    }
  }

  void _drawText({
    required Canvas canvas,
    required Size size,
    required String text,
    required Offset offset,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: labelStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width / 2,
    );
    final textSize = textPainter.size;

    final centeredOffset = offset - Offset(textSize.width / 2, textSize.height / 2);
    textPainter.paint(canvas, centeredOffset);
  }

  /// Normalizes border radius to fit within segment constraints.
  static BorderRadius _normalizeBorderRadius(
    BorderRadius borderRadius,
    double segmentWidthTop,
    double segmentWidthBottom,
    double segmentHeight,
  ) {
    double halfSegmentWidthTop = segmentWidthTop / 2.0;
    // Bottom uses /5 instead of /2 to account for the narrower inner arc
    double halfSegmentWidthBottom = segmentWidthBottom / 5.0;
    double halfSegmentHeight = segmentHeight / 2.0;

    return BorderRadius.only(
      topLeft: _normalizeCorner(
        borderRadius.topLeft,
        halfSegmentWidthTop,
        halfSegmentHeight,
      ),
      topRight: _normalizeCorner(
        borderRadius.topRight,
        halfSegmentWidthTop,
        halfSegmentHeight,
      ),
      bottomLeft: _normalizeCorner(
        borderRadius.bottomLeft,
        halfSegmentWidthBottom,
        halfSegmentHeight,
      ),
      bottomRight: _normalizeCorner(
        borderRadius.bottomRight,
        halfSegmentWidthBottom,
        halfSegmentHeight,
      ),
    );
  }

  /// Normalizes a single corner radius to fit within max constraints.
  static Radius _normalizeCorner(
    Radius radius,
    double maxHorizontal,
    double maxVertical,
  ) {
    double horizontalRatio =
        radius.x > maxHorizontal ? maxHorizontal / radius.x : 1.0;
    double verticalRatio =
        radius.y > maxVertical ? maxVertical / radius.y : 1.0;
    double ratio = min(horizontalRatio, verticalRatio);

    return Radius.elliptical(radius.x * ratio, radius.y * ratio);
  }

  @override
  bool shouldRepaint(covariant CircleChartPainter oldDelegate) {
    if (animations.isNotEmpty) return true;

    if (items.length != oldDelegate.items.length) return true;

    for (int i = 0; i < items.length; i++) {
      if (items[i].id != oldDelegate.items[i].id ||
          items[i].value != oldDelegate.items[i].value ||
          items[i].color != oldDelegate.items[i].color ||
          items[i].label != oldDelegate.items[i].label) {
        return true;
      }
    }

    return segmentWidth != oldDelegate.segmentWidth ||
        segmentSpacing != oldDelegate.segmentSpacing ||
        borderRadius != oldDelegate.borderRadius ||
        segmentDefaultColor != oldDelegate.segmentDefaultColor ||
        labelStyle != oldDelegate.labelStyle;
  }
}
