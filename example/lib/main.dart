import 'package:circlify/Circlify.dart';
import 'package:circlify/circlify_item.dart';
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
