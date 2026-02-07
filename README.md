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
  circlify: ^<latest-version>
```

## 🚀 Usage

Here’s a quick example to get started:

```dart
class App extends StatelessWidget {
  const App({super.key});

  final List<CirclifyItem> items = [
    CirclifyItem(id: '1', color: Colors.red, value: 100),
    CirclifyItem(id: '2', color: Colors.green, value: 100),
    CirclifyItem(id: '3', color: Colors.blue, value: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Circlify(
            items: items,
          ),
        ),
      ),
    );
  }
}
```

## ⚠️ Important Note: Proper Initialization of `CirclifyItem`

To ensure smooth performance, all `CirclifyItem` objects must be initialized only once **if `id` is not provided**. Avoid re-creating `CirclifyItem` instances on every rebuild. Below is an example of what **not to do**:

### 🚫 Incorrect Usage
```dart
Circlify(
  items: [
    CirclifyItem(color: Colors.red, value: 100),
    CirclifyItem(color: Colors.green, value: 100),
    CirclifyItem(color: Colors.blue, value: 100),
  ],
)
```

The issue with the above example is that new `CirclifyItem` objects are being created on each rebuild, causing unnecessary re-rendering and performance issues.

### ✅ Correct Usage
Instead, ensure that `CirclifyItem` objects are created once and reused, as shown in the following examples:

#### Example 1: Assign `id` to each item
```dart
Circlify(
  items: [
    CirclifyItem(id: '1', color: Colors.red, value: 100),
    CirclifyItem(id: '2', color: Colors.green, value: 100),
    CirclifyItem(id: '3', color: Colors.blue, value: 100),
  ],
)
```

#### Example 2: Define `CirclifyItem` list separately
```dart
List<CirclifyItem> items = [
  CirclifyItem(color: Colors.red, value: 100),
  CirclifyItem(color: Colors.green, value: 100),
  CirclifyItem(color: Colors.blue, value: 100),
];

Circlify(
  items: items,
)
```

By following these patterns, you ensure that your charts remain performant and efficient.

## 📏 Labels on Items

Add custom labels to each item using the `label` property. This feature allows for enhanced visual representation of each section in the circular chart.

### 🎨 Example with Labels
<img src="https://raw.githubusercontent.com/zeffbtw/Circlify/refs/heads/main/raw/labels_demo.jpg" alt="Circlify Labels" width="300">

```dart
Circlify(
  segmentWidth: 100,
  labelStyle: const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  ),
  items: [
    CirclifyItem(
      id: '1',
      color: Colors.red,
      value: 100,
      label: 'Red',
    ),
    CirclifyItem(
      id: '2',
      color: Colors.green,
      value: 100,
      label: 'Green',
    ),
    CirclifyItem(
      id: '3',
      color: Colors.blue,
      value: 100,
      label: 'Blue',
    ),
  ],
)
```

### ✨ Key Takeaways for Labels
- Use the `label` property to add descriptive text to each item.
- Customize the appearance of labels using the `labelStyle` property, which accepts a `TextStyle` object.
- Ensure each `CirclifyItem` has a unique `id` to optimize re-renders and maintain a consistent visual layout.

## 👆 Segment Tap Handling

Make your charts interactive by handling tap events on segments using the `onSegmentTap` callback.

### Example
```dart
Circlify(
  items: items,
  onSegmentTap: (details) {
    print('Tapped: ${details.item.label}');
    print('Index: ${details.index}');
    print('Position: ${details.localPosition}');
  },
)
```

The callback receives a `SegmentTapDetails` object containing:
- `item` — The tapped `CirclifyItem`
- `index` — The index in the items list
- `localPosition` — Tap position relative to the widget

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
| `labelStyle`         | `TextStyle`    | TextStyle of label on CirclifyItem                                  | Optional           |
| `onSegmentTap`       | `SegmentTapCallback` | Callback when a segment is tapped                               | Optional           |


## 📝 CirclifyItem Parameters

| Parameter | Type    | Description                                   | Default         |
| --------- | ------- | --------------------------------------------- | --------------- |
| `id`      | `String`| Unique ID for the item (auto-generated if not provided) | Auto-generated  |
| `color`   | `Color` | Color of the item                             | Required        |
| `value`   | `double`| Value of the item (must be > 0)               | Required        |
| `label`   | `String`| The label of the item, drawn on center of the segment| Optional        |

## 📝 SegmentTapDetails Properties

| Property        | Type           | Description                              |
| --------------- | -------------- | ---------------------------------------- |
| `item`          | `CirclifyItem` | The tapped chart item                    |
| `index`         | `int`          | Index of the tapped item in the list     |
| `localPosition` | `Offset`       | Tap position relative to the widget      |

## 💬 Feedback and Contributions

If you encounter any issues or have suggestions, feel free to open an [issue](https://github.com/zeffbtw/circlify/issues) on GitHub. Contributions are welcome!

## 📝 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](https://github.com/zeffbtw/circlify/blob/main/LICENSE) file for details.

---

Made with ❤️ by [zeffbtw](https://github.com/zeffbtw).
