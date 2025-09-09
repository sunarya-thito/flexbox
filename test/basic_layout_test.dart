import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('Basic Layout Tests', () {
    testWidgets('FlexBox renders children correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.vertical,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(100),
                  height: BoxSize.fixed(50),
                  child: Container(color: Colors.red),
                ),
                FlexBoxChild(
                  width: BoxSize.fixed(150),
                  height: BoxSize.fixed(75),
                  child: Container(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify children are rendered
      expect(find.byType(Container), findsNWidgets(2));
      expect(find.byType(FlexBoxChild), findsNWidgets(2));
    });

    testWidgets('FlexBox horizontal direction layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.horizontal,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(100),
                  height: BoxSize.fixed(50),
                  child: Container(key: Key('child1'), color: Colors.red),
                ),
                FlexBoxChild(
                  width: BoxSize.fixed(150),
                  height: BoxSize.fixed(75),
                  child: Container(key: Key('child2'), color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child1 = tester.getTopLeft(find.byKey(Key('child1')));
      final child2 = tester.getTopLeft(find.byKey(Key('child2')));

      // In horizontal layout, second child should be to the right of first
      expect(child2.dx > child1.dx, isTrue);
      // Note: children might have different Y positions due to cross-axis alignment
    });

    testWidgets('FlexBox vertical direction layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.vertical,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(100),
                  height: BoxSize.fixed(50),
                  child: Container(key: Key('child1'), color: Colors.red),
                ),
                FlexBoxChild(
                  width: BoxSize.fixed(150),
                  height: BoxSize.fixed(75),
                  child: Container(key: Key('child2'), color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child1 = tester.getTopLeft(find.byKey(Key('child1')));
      final child2 = tester.getTopLeft(find.byKey(Key('child2')));

      // In vertical layout, second child should be below first
      expect(child2.dy > child1.dy, isTrue);
      // Note: children might have different X positions due to cross-axis alignment
    });

    testWidgets('Fixed sizing works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.vertical,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(200),
                  height: BoxSize.fixed(100),
                  child: Container(key: Key('fixedChild'), color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getSize(find.byKey(Key('fixedChild')));
      expect(child.width, equals(200.0));
      expect(child.height, equals(100.0));
    });

    testWidgets('Unconstrained sizing uses available space', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    width: BoxSize.unconstrained(),
                    height: BoxSize.fixed(100),
                    child: Container(
                      key: Key('unconstrainedChild'),
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getSize(find.byKey(Key('unconstrainedChild')));
      expect(child.width, equals(400.0)); // Should use full available width
      expect(child.height, equals(100.0));
    });

    testWidgets('Flex sizing distributes space proportionally', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.flex(1),
                    height: BoxSize.fixed(100),
                    child: Container(key: Key('flex1'), color: Colors.red),
                  ),
                  FlexBoxChild(
                    width: BoxSize.flex(2),
                    height: BoxSize.fixed(100),
                    child: Container(key: Key('flex2'), color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child1 = tester.getSize(find.byKey(Key('flex1')));
      final child2 = tester.getSize(find.byKey(Key('flex2')));

      // Flex 2 should be twice as wide as flex 1
      expect(child2.width / child1.width, closeTo(2.0, 0.1));
    });

    testWidgets('Mixed sizing types work together', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(100),
                    child: Container(key: Key('fixed'), color: Colors.red),
                  ),
                  FlexBoxChild(
                    width: BoxSize.flex(1),
                    height: BoxSize.fixed(100),
                    child: Container(key: Key('flex'), color: Colors.blue),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(50),
                    height: BoxSize.fixed(100),
                    child: Container(key: Key('fixed2'), color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final fixedChild = tester.getSize(find.byKey(Key('fixed')));
      final flexChild = tester.getSize(find.byKey(Key('flex')));
      final fixed2Child = tester.getSize(find.byKey(Key('fixed2')));

      expect(fixedChild.width, equals(100.0));
      expect(fixed2Child.width, equals(50.0));
      // Flex child should get remaining space: 400 - 100 - 50 = 250
      expect(flexChild.width, equals(250.0));
    });

    testWidgets('Empty FlexBox renders without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(direction: Axis.vertical, children: []),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FlexBox), findsOneWidget);
    });

    testWidgets('Single child FlexBox works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.vertical,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(200),
                  height: BoxSize.fixed(100),
                  child: Container(
                    key: Key('singleChild'),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getSize(find.byKey(Key('singleChild')));
      expect(child.width, equals(200.0));
      expect(child.height, equals(100.0));
    });

    testWidgets('Large number of children renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.vertical,
              children: List.generate(
                10,
                (index) => FlexBoxChild(
                  width: BoxSize.fixed(100),
                  height: BoxSize.fixed(50),
                  child: Container(key: Key('child$index'), color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all children are rendered
      for (int i = 0; i < 10; i++) {
        expect(find.byKey(Key('child$i')), findsOneWidget);
      }

      // Verify vertical stacking
      final firstChild = tester.getTopLeft(find.byKey(Key('child0')));
      final lastChild = tester.getTopLeft(find.byKey(Key('child9')));
      expect(lastChild.dy > firstChild.dy, isTrue);
    });

    testWidgets('Nested FlexBox layouts work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlexBox(
              direction: Axis.vertical,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(300),
                  height: BoxSize.fixed(200),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    children: [
                      FlexBoxChild(
                        width: BoxSize.fixed(100),
                        height: BoxSize.fixed(100),
                        child: Container(
                          key: Key('nested1'),
                          color: Colors.red,
                        ),
                      ),
                      FlexBoxChild(
                        width: BoxSize.fixed(150),
                        height: BoxSize.fixed(100),
                        child: Container(
                          key: Key('nested2'),
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('nested1')), findsOneWidget);
      expect(find.byKey(Key('nested2')), findsOneWidget);

      final nested1 = tester.getTopLeft(find.byKey(Key('nested1')));
      final nested2 = tester.getTopLeft(find.byKey(Key('nested2')));

      // Nested children should be horizontally arranged
      expect(nested2.dx > nested1.dx, isTrue);
      expect(nested2.dy, equals(nested1.dy));
    });
  });
}
