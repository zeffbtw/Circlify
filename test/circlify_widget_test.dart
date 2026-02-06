import 'package:circlify/circlify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Circlify Widget', () {
    testWidgets('renders with empty items list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: Circlify(items: []),
          ),
        ),
      );

      expect(find.byType(Circlify), findsOneWidget);
      // CustomPaint is used for rendering the chart
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with single item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: Circlify(
              items: [
                CirclifyItem(id: 'a', color: Colors.red, value: 100),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Circlify), findsOneWidget);
    });

    testWidgets('renders with multiple items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: Circlify(
              items: [
                CirclifyItem(id: 'a', color: Colors.red, value: 30),
                CirclifyItem(id: 'b', color: Colors.green, value: 40),
                CirclifyItem(id: 'c', color: Colors.blue, value: 30),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Circlify), findsOneWidget);
    });

    testWidgets('applies custom segment width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: Circlify(
              segmentWidth: 50,
              items: [
                CirclifyItem(id: 'a', color: Colors.red, value: 100),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Circlify), findsOneWidget);
    });

    testWidgets('applies custom segment spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: Circlify(
              segmentSpacing: 10,
              items: [
                CirclifyItem(id: 'a', color: Colors.red, value: 50),
                CirclifyItem(id: 'b', color: Colors.blue, value: 50),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Circlify), findsOneWidget);
    });

    testWidgets('updates when items change', (tester) async {
      final items = <CirclifyItem>[
        CirclifyItem(id: 'a', color: Colors.red, value: 100),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 200,
                height: 200,
                child: Column(
                  children: [
                    Expanded(child: Circlify(items: items)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          items.add(CirclifyItem(
                            id: 'b',
                            color: Colors.blue,
                            value: 100,
                          ));
                        });
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(Circlify), findsOneWidget);

      // Tap add button
      await tester.tap(find.text('Add'));
      await tester.pump();

      // Animation should start
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Circlify), findsOneWidget);
    });

    testWidgets('disposes properly when removed from tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: Circlify(
              items: [
                CirclifyItem(id: 'a', color: Colors.red, value: 100),
              ],
            ),
          ),
        ),
      );

      // Replace with different widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: Text('Replaced'),
          ),
        ),
      );

      expect(find.byType(Circlify), findsNothing);
      expect(find.text('Replaced'), findsOneWidget);
    });

    testWidgets('handles rapid item changes without crash', (tester) async {
      List<CirclifyItem> items = [
        CirclifyItem(id: 'a', color: Colors.red, value: 100),
      ];

      late StateSetter updateState;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return SizedBox(
                width: 200,
                height: 200,
                child: Circlify(items: items),
              );
            },
          ),
        ),
      );

      // Rapid changes
      updateState(() {
        items = [
          CirclifyItem(id: 'a', color: Colors.red, value: 50),
          CirclifyItem(id: 'b', color: Colors.blue, value: 50),
        ];
      });
      await tester.pump();

      updateState(() {
        items = [
          CirclifyItem(id: 'b', color: Colors.blue, value: 100),
        ];
      });
      await tester.pump();

      updateState(() {
        items = [
          CirclifyItem(id: 'c', color: Colors.green, value: 100),
        ];
      });
      await tester.pump();

      // Let animations complete
      await tester.pumpAndSettle();

      expect(find.byType(Circlify), findsOneWidget);
    });
  });
}
