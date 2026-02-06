import 'package:circlify/circlify.dart';
import 'package:example/animation_demo.dart';
import 'package:example/custom_value_demo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: App()));
}

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Circlify(
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
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomValuesDemo(),
                  ),
                );
              },
              child: const Text('To custom value demo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnimationDemo(),
                  ),
                );
              },
              child: const Text('To animation demo'),
            ),
          ],
        ),
      ),
    );
  }
}
