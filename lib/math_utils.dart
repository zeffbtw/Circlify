import 'dart:math';
import 'dart:ui';

class MathUtils {
  MathUtils._();

  static double scalarToAngle(double radius, double scalar) {
    if (radius == 0) {
      throw ArgumentError('Radius cannot be zero');
    }

    double angleRadians = scalar / radius;
    double angleDegrees = angleRadians * (180 / pi);

    return angleDegrees;
  }

  static double angleToScalar(double radius, double angle) {
    return (pi * radius * angle) / 180;
  }

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

  static Offset findIntersectionWithTangent({
    required Offset center,
    required double radius,
    required double angleDegrees,
    required Offset point1,
    required Offset point2,
  }) {
    // Переводим угол в радианы
    double angleRadians = angleDegrees * pi / 180;

    // Вычисляем координаты точки на окружности (точка касания)
    double x0 = center.dx + radius * cos(angleRadians);
    double y0 = center.dy + radius * sin(angleRadians);

    // Вычисляем наклон касательной
    // Направление касательной перпендикулярно радиусу
    double dx = -radius * sin(angleRadians);
    double dy = radius * cos(angleRadians);

    double tangentSlope;
    if (dx != 0) {
      tangentSlope = dy / dx;
    } else {
      tangentSlope = double.infinity; // Касательная вертикальна
    }

    // Вычисляем смещение касательной по оси Y (b1)
    double b1 = y0 - tangentSlope * x0;

    // Вычисляем наклон и смещение для прямой через две точки
    double deltaX = point2.dx - point1.dx;
    double deltaY = point2.dy - point1.dy;

    double lineSlope;
    double b2;

    if (deltaX != 0) {
      lineSlope = deltaY / deltaX;
      b2 = point1.dy - lineSlope * point1.dx;
    } else {
      lineSlope = double.infinity; // Прямая вертикальна
      b2 = point1.dx; // x = b2
    }

    // Находим точку пересечения
    double x, y;

    if (tangentSlope == lineSlope) {
      // Прямые параллельны или совпадают
      throw Exception('Прямые параллельны или совпадают');
    } else if (tangentSlope.isInfinite) {
      // Касательная вертикальна: x = x0
      if (lineSlope.isInfinite) {
        // Обе прямые вертикальны
        throw Exception('Прямые параллельны или совпадают');
      } else {
        x = x0;
        y = lineSlope * x + b2;
      }
    } else if (lineSlope.isInfinite) {
      // Прямая вертикальна: x = b2
      x = b2;
      y = tangentSlope * x + b1;
    } else {
      // Обычный случай
      x = (b2 - b1) / (tangentSlope - lineSlope);
      y = tangentSlope * x + b1;
    }

    return Offset(x, y);
  }
}
