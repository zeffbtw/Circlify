import 'package:circlify/circlify.dart';
import 'package:circlify/circlify_item.dart';
import 'package:flutter/material.dart';

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  List<CirclifyItem> items = [
    CirclifyItem(color: Colors.red, value: 100),
    CirclifyItem(color: Colors.green, value: 200),
    CirclifyItem(color: Colors.blue, value: 500),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Circlify(
                items: items,
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              child: const Text('Add item'),
              onPressed: () {
                setState(() {
                  items.insert(
                    (items.length / 2).round(),
                    CirclifyItem(color: Colors.amberAccent, value: 100),
                  );
                });
              },
            ),
            TextButton(
              child: const Text('Remove item'),
              onPressed: () {
                setState(() {
                  if (items.isNotEmpty) items.removeAt((items.length / 2).round());
                });
              },
            ),
            TextButton(
              child: const Text('Multiple 2 value'),
              onPressed: () {
                setState(() {
                  if (items.isNotEmpty) items.last.value *= 2;
                });
              },
            ),
            TextButton(
              child: const Text('Div 2 value'),
              onPressed: () {
                setState(() {
                  if (items.isNotEmpty) items.last.value /= 2;
                });
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
