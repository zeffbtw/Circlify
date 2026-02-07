# Changelog


## [2.1.0] - 2026-02-07

### ✨ New Features

- **Segment Tap Handling**: Added `onSegmentTap` callback to handle tap events on chart segments. The callback receives `SegmentTapDetails` containing the tapped item, its index, and tap position.

### 📝 Documentation

- Updated README with segment tap handling documentation
- Fixed syntax error in usage example
- Removed outdated TODO section (tap handling now implemented)

---

## [2.0.0] - 2026-02-06

### ⚠️ Breaking Changes

- **Immutable CirclifyItem**: All fields (`color`, `value`, `label`) are now `final`. Direct mutation no longer works — use `copyWith()` instead.

### 🚀 Migration from 1.x

**Before (1.x):**
```dart
item.value = 200;
item.color = Colors.blue;
```

**After (2.0):**
```dart
item = item.copyWith(value: 200);
item = item.copyWith(color: Colors.blue);

// To explicitly set label to null:
item = item.copyWithLabel(null);
```

**Why:** Immutability ensures correct animation diffing and prevents subtle state bugs with Flutter's widget lifecycle.

### ✨ New Features

- **copyWithLabel()**: New method to explicitly set `label` to `null` (since `copyWith(label: null)` preserves the current value).

### 🛠 Improvements

- **Memory leak fix**: AnimationControllers are now properly disposed when items are removed.
- **Performance**: Optimized `shouldRepaint` logic with proper field checks.
- **Performance**: Cached center offset calculations in CustomPainter.
- **Lifecycle**: Fixed `didUpdateWidget` to call `super` first (Flutter convention).
- **Code cleanup**: Removed dead `.drive()` calls.

### 🐛 Fixes

- Fixed typos in example code (`segmentWidght` → `segmentWidth`, `Multiple` → `Multiply`).
- Fixed CHANGELOG date inconsistency.

---

## [1.2.3] - 2025-06-23

### 🐛 Fixes
- **Changelog**: Corrected errors in the Changelog.


## [1.2.2] - 2025-06-23

### 🐛 Fixes
- **Label rendering**: Fixed issue where label for a single item was not visible.  
  Related to [GitHub issue #1](https://github.com/zeffbtw/Circlify/issues/1).


## [1.2.1] - 2024-12-14

### 🐛 Fixes
- **Readme and pubspec**: Corrected errors in the README and pubspec.yaml links.

---

## [1.2.0] - 2024-12-14

### ✨ New Features
- **Labels on Segments**: Added support for displaying text labels directly on chart segments. This allows for more informative and visually appealing charts.

### 🐛 Fixes
- **Readme and Examples**: Corrected errors in the README and usage examples. All examples are now accurate and free from misleading code snippets.

---


## [1.1.0] - 2024-11-12

### 🚀 Enhancements
- **License Updated**: Changed the license to **BSD 3-Clause** for better compliance and transparency.
- **Refactoring**: `MathUtils` class is now made private (`_MathUtils`) to avoid exposure of internal utility functions.

### 🛠 Improvements
- Minor code styling adjustments for better readability and consistency.

### 🐛 Fixes
- No specific bug fixes in this release, but internal improvements were made to enhance code maintainability.

---

## [1.0.0] - 2024-11-11

**🚀 Circlify v1.0.0 — Initial Release**

We are excited to announce the first release of Circlify, a lightweight Flutter package for creating customizable circular charts and radial visualizations. This initial version includes all the core features to help you create smooth and interactive circular charts in your Flutter applications.

### 🎉 Core Features
- Customizable circular charts with smooth animations.
- Easy integration with your existing Flutter projects.
- Support for interactive updates and dynamic data changes.
- Initial API for `Circlify` and `CirclifyItem`.

---

Check out the [GitHub repository](https://github.com/zeffbtw/circlify) for more details and to contribute to the project!
