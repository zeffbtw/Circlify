import 'package:circlify/circlify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CirclifyItem', () {
    test('creates item with required fields', () {
      final item = CirclifyItem(
        color: Colors.red,
        value: 100,
      );

      expect(item.color, Colors.red);
      expect(item.value, 100);
      expect(item.label, isNull);
      expect(item.id, isNotEmpty);
    });

    test('creates item with custom id', () {
      final item = CirclifyItem(
        id: 'custom-id',
        color: Colors.blue,
        value: 50,
      );

      expect(item.id, 'custom-id');
    });

    test('creates item with label', () {
      final item = CirclifyItem(
        color: Colors.green,
        value: 75,
        label: 'Test Label',
      );

      expect(item.label, 'Test Label');
    });

    test('generates unique ids for different items', () {
      final item1 = CirclifyItem(color: Colors.red, value: 10);
      final item2 = CirclifyItem(color: Colors.blue, value: 20);

      expect(item1.id, isNot(equals(item2.id)));
    });

    test('throws assertion error for value <= 0', () {
      expect(
        () => CirclifyItem(color: Colors.red, value: 0),
        throwsAssertionError,
      );

      expect(
        () => CirclifyItem(color: Colors.red, value: -10),
        throwsAssertionError,
      );
    });

    group('copyWith', () {
      test('copies with new color', () {
        final original = CirclifyItem(
          id: 'test',
          color: Colors.red,
          value: 100,
        );
        final copied = original.copyWith(color: Colors.blue);

        expect(copied.id, 'test');
        expect(copied.color, Colors.blue);
        expect(copied.value, 100);
      });

      test('copies with new value', () {
        final original = CirclifyItem(
          id: 'test',
          color: Colors.red,
          value: 100,
        );
        final copied = original.copyWith(value: 200);

        expect(copied.id, 'test');
        expect(copied.color, Colors.red);
        expect(copied.value, 200);
      });

      test('copies with new label', () {
        final original = CirclifyItem(
          id: 'test',
          color: Colors.red,
          value: 100,
          label: 'Original',
        );
        final copied = original.copyWith(label: 'New Label');

        expect(copied.label, 'New Label');
      });

      test('preserves id when copying', () {
        final original = CirclifyItem(
          id: 'original-id',
          color: Colors.red,
          value: 100,
        );
        final copied = original.copyWith(value: 200);

        expect(copied.id, 'original-id');
      });
    });

    group('copyWithLabel', () {
      test('can set label to null', () {
        final original = CirclifyItem(
          id: 'test',
          color: Colors.red,
          value: 100,
          label: 'Has Label',
        );
        final copied = original.copyWithLabel(null);

        expect(copied.label, isNull);
        expect(copied.id, 'test');
        expect(copied.color, Colors.red);
        expect(copied.value, 100);
      });

      test('can set new label', () {
        final original = CirclifyItem(
          id: 'test',
          color: Colors.red,
          value: 100,
        );
        final copied = original.copyWithLabel('New Label');

        expect(copied.label, 'New Label');
      });
    });
  });
}
