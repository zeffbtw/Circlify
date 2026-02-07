import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Internal math utilities for circular chart calculations.
@internal
class ChartMathUtils {
  ChartMathUtils._();

  /// Converts a scalar distance along an arc to an angle in degrees.
  static double scalarToAngle(double radius, double scalar) {
    if (radius == 0) {
      throw ArgumentError('Radius cannot be zero');
    }

    double angleRadians = scalar / radius;
    double angleDegrees = angleRadians * (180 / pi);

    return angleDegrees;
  }

  /// Converts an angle in degrees to a scalar distance along an arc.
  static double angleToScalar(double radius, double angle) {
    return (pi * radius * angle) / 180;
  }

  /// Calculates the end point of an arc given a center, start point, and angle.
  static Offset calcEndOfArc({
    required Offset center,
    required Offset start,
    required double angle,
  }) {
    final radian = angle * (pi / 180);

    double x1 = start.dx - center.dx;
    double y1 = start.dy - center.dy;

    double x2 = x1 * cos(radian) - y1 * sin(radian);
    double y2 = x1 * sin(radian) + y1 * cos(radian);

    return Offset(x2 + center.dx, y2 + center.dy);
  }

  /// Finds the intersection point between a tangent line and a line segment.
  static Offset findIntersectionWithTangent({
    required Offset center,
    required double radius,
    required double angleDegrees,
    required Offset point1,
    required Offset point2,
  }) {
    double angleRadians = angleDegrees * pi / 180;

    double x0 = center.dx + radius * cos(angleRadians);
    double y0 = center.dy + radius * sin(angleRadians);

    double dx = -radius * sin(angleRadians);
    double dy = radius * cos(angleRadians);

    double tangentSlope;
    if (dx != 0) {
      tangentSlope = dy / dx;
    } else {
      tangentSlope = double.infinity;
    }

    double b1 = y0 - tangentSlope * x0;

    double deltaX = point2.dx - point1.dx;
    double deltaY = point2.dy - point1.dy;

    double lineSlope;
    double b2;

    if (deltaX != 0) {
      lineSlope = deltaY / deltaX;
      b2 = point1.dy - lineSlope * point1.dx;
    } else {
      lineSlope = double.infinity;
      b2 = point1.dx;
    }

    double x, y;

    if (tangentSlope == lineSlope) {
      throw StateError('Lines are parallel or equal');
    } else if (tangentSlope.isInfinite) {
      if (lineSlope.isInfinite) {
        throw StateError('Lines are parallel or equal');
      } else {
        x = x0;
        y = lineSlope * x + b2;
      }
    } else if (lineSlope.isInfinite) {
      x = b2;
      y = tangentSlope * x + b1;
    } else {
      x = (b2 - b1) / (tangentSlope - lineSlope);
      y = tangentSlope * x + b1;
    }

    return Offset(x, y);
  }
}
