/// Internal constants for Circlify chart calculations.
library;

import 'package:meta/meta.dart';

/// Minimum percentage a segment can occupy (2.5% of the circle).
/// Prevents segments from becoming too small to see.
@internal
const double minSegmentPercentage = 0.025;
