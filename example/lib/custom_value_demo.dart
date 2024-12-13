import 'package:circlify/Circlify.dart';
import 'package:circlify/circlify_item.dart';
import 'package:flutter/material.dart';

class CustomValuesDemo extends StatefulWidget {
  const CustomValuesDemo({super.key});

  @override
  State<CustomValuesDemo> createState() => _CustomValuesDemoState();
}

class _CustomValuesDemoState extends State<CustomValuesDemo> {
  double value = 100;
  double spacing = 5;
  double radius = 10;
  double segmentWidght = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom value demo')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: Circlify(
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
              items: [
                CustomCircleChartItem(
                  id: '0',
                  color: Colors.red,
                  value: value,
                  name: 'Name',
                ),
                CirclifyItem(
                  id: '1',
                  color: Colors.green,
                  value: 100,
                  label: 'Hello',
                ),
                CirclifyItem(
                  id: '2',
                  color: Colors.green,
                  value: 100,
                  label: 'Circlify',
                ),
              ],
              segmentSpacing: spacing,
              segmentWidth: segmentWidght,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          const SizedBox(height: 20),
          Text('Red segment value: $value'),
          Slider(
            min: 1,
            max: 500,
            value: value,
            onChanged: (value) => setState(() => this.value = value),
          ),
          const SizedBox(height: 20),
          Text('Border radius: $radius'),
          Slider(
            min: 0,
            max: 50,
            value: radius,
            onChanged: (value) => setState(() => radius = value),
          ),
          const SizedBox(height: 20),
          Text('Segment spacing $spacing'),
          Slider(
            min: 0,
            max: 100,
            value: spacing,
            onChanged: (value) => setState(() => spacing = value),
          ),
          const SizedBox(height: 20),
          Text('Segment width $segmentWidght'),
          Slider(
            min: 1,
            max: 140,
            value: segmentWidght,
            onChanged: (value) => setState(() => segmentWidght = value),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// You can also create your own [CirclifyItem] subclass and use it in the [Circlify] widget.
class CustomCircleChartItem extends CirclifyItem {
  final String name;

  CustomCircleChartItem({
    required super.color,
    required super.value,
    required super.id,
    required this.name,
  });
}
