# Circlify

[![pub package](https://img.shields.io/pub/v/circlify.svg)](https://pub.dev/packages/circlify)
[![GitHub license](https://img.shields.io/github/license/zeffbtw/circlify)](https://github.com/zeffbtw/circlify/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/zeffbtw/circlify)](https://github.com/zeffbtw/circlify/stargazers)

**Circlify** is a lightweight and powerful Flutter package for creating customizable circular charts with smooth animations. Perfect for visualizing data in dashboards or adding dynamic radial elements to your app.

## 📊 Demo

<p align="center">
  <img src="https://raw.githubusercontent.com/zeffbtw/Circlify/refs/heads/main/raw/custom_value_demo.gif" alt="Circlify Demo 1" width="300">
  <img src="https://raw.githubusercontent.com/zeffbtw/Circlify/refs/heads/main/raw/animation_demo.gif" alt="Circlify Demo 2" width="300">
</p>

## 🌟 Features

- Highly customizable circular charts
- Smooth animations
- Supports interactive and dynamic updates
- Customizable `CirclifyItem` subclasses
- Easy to integrate into any Flutter project

## 📦 Installation

Add `circlify` to your `pubspec.yaml`:

```yaml
dependencies:
  circlify: ^1.1.0
```

## 🚀 Usage

Here’s a quick example to get started:

```dart
import 'package:circlify/circlify.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Circlify(
            items: [
              CirclifyItem(color: Colors.red, value: 100),
              CirclifyItem(color: Colors.green, value: 100),
              CirclifyItem(color: Colors.blue, value: 100),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🛠 Custom CirclifyItem

You can also create your own `CirclifyItem` subclass and use it in the `Circlify` widget:

```dart
class CustomCircleChartItem extends CirclifyItem {
  final String name;

  CustomCircleChartItem({
    required super.color,
    required super.value,
    required super.id,
    required this.name,
  });
}

class CustomChartApp extends StatelessWidget {
  const CustomChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Circlify(
            items: [
              CustomCircleChartItem(
                color: Colors.purple,
                value: 150,
                id: 'item1',
                name: 'Custom Item 1',
              ),
              CustomCircleChartItem(
                color: Colors.orange,
                value: 100,
                id: 'item2',
                name: 'Custom Item 2',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## ⚙️ Circlify Parameters

| Parameter            | Type           | Description                                                        | Default               |
| -------------------- | -------------- | ------------------------------------------------------------------ | --------------------- |
| `items`              | `List<CirclifyItem>` | List of data points for the chart                                   | Required              |
| `borderRadius`       | `BorderRadius` | Border radius for chart segments                                    | `BorderRadius.all(Radius.circular(10))`   |
| `segmentSpacing`     | `double`       | Spacing between segments (must be ≥ 0 and < circle free space)      | `5.0`                 |
| `segmentWidth`       | `double`       | Width of chart segments (must be > 0 and < `borderRadius`)          | `10.0`                |
| `segmentDefaultColor`| `Color`        | Default color for empty chart segments                              | `Colors.grey`         |
| `animationDuration`  | `Duration`     | Duration of the animation                                           | `Duration(milliseconds: 150)` |
| `animationCurve`     | `Curve`        | Animation curve                                                     | `Curves.easeIn`    |

## 📝 CirclifyItem Parameters

| Parameter | Type    | Description                                   | Default         |
| --------- | ------- | --------------------------------------------- | --------------- |
| `id`      | `String`| Unique ID for the item (auto-generated if not provided) | Auto-generated  |
| `color`   | `Color` | Color of the item                             | Required        |
| `value`   | `double`| Value of the item (must be > 0)               | Required        |


## 💬 Feedback and Contributions

If you encounter any issues or have suggestions, feel free to open an [issue](https://github.com/zeffbtw/circlify/issues) on GitHub. Contributions are welcome!

## 📝 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](https://github.com/zeffbtw/circlify/blob/main/LICENSE) file for details.

---

Made with ❤️ by [zeffbtw](https://github.com/zeffbtw).
