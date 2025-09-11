import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('Positioning Types Tests', () {
    testWidgets('Relative positioning works correctly', (
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
                    top: BoxPosition.fixed(50),
                    left: BoxPosition.fixed(30),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('relativeChild'),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getTopLeft(find.byKey(Key('relativeChild')));
      // Relative positioning should offset from the FlexBox origin
      expect(child.dx, equals(30.0));
      expect(child.dy, equals(50.0));
    });

    testWidgets('Fixed positioning works correctly', (
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
                  // Regular content to offset FlexBox
                  FlexBoxChild(
                    width: BoxSize.fixed(200),
                    height: BoxSize.fixed(100),
                    child: Container(color: Colors.blue),
                  ),
                  FlexBoxChild(
                    top: BoxPosition.fixed(20),
                    left: BoxPosition.fixed(40),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.fixed,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(key: Key('fixedChild'), color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getTopLeft(find.byKey(Key('fixedChild')));
      // Fixed positioning should be relative to viewport, not FlexBox
      expect(child.dx, equals(40.0));
      expect(child.dy, equals(20.0));
    });

    testWidgets('relative positioning works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 600,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Large content to create scroll offset
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(300),
                      child: Container(color: Colors.grey),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(50),
                      left: BoxPosition.fixed(30),
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(80),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('viewportChild'),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('viewportChild')), findsOneWidget);
      // relative positioning should anchor to viewport, not content
    });

    testWidgets('Multiple positioning types can coexist', (
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
                    top: BoxPosition.fixed(10),
                    left: BoxPosition.fixed(10),
                    width: BoxSize.fixed(80),
                    height: BoxSize.fixed(60),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(key: Key('relative'), color: Colors.red),
                  ),
                  FlexBoxChild(
                    top: BoxPosition.fixed(20),
                    right: BoxPosition.fixed(20),
                    width: BoxSize.fixed(80),
                    height: BoxSize.fixed(60),
                    horizontalPosition: BoxPositionType.fixed,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(key: Key('fixed'), color: Colors.blue),
                  ),
                  FlexBoxChild(
                    bottom: BoxPosition.fixed(30),
                    left: BoxPosition.fixed(30),
                    width: BoxSize.fixed(80),
                    height: BoxSize.fixed(60),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(key: Key('viewport'), color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('relative')), findsOneWidget);
      expect(find.byKey(Key('fixed')), findsOneWidget);
      expect(find.byKey(Key('viewport')), findsOneWidget);
    });

    testWidgets('Left and right positioning work correctly', (
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
                    left: BoxPosition.fixed(50),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('leftChild'),
                      color: Colors.orange,
                    ),
                  ),
                  FlexBoxChild(
                    right: BoxPosition.fixed(50),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('rightChild'),
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final leftChild = tester.getTopLeft(find.byKey(Key('leftChild')));
      final rightChild = tester.getTopLeft(find.byKey(Key('rightChild')));

      expect(leftChild.dx, equals(50.0));
      // Right positioned child should be at: containerWidth - childWidth - rightOffset = 400 - 100 - 50 = 250
      expect(rightChild.dx, equals(250.0));
    });

    testWidgets('Top and bottom positioning work correctly', (
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
                    top: BoxPosition.fixed(40),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    verticalPosition: BoxPositionType.relative,
                    child: Container(key: Key('topChild'), color: Colors.lime),
                  ),
                  FlexBoxChild(
                    bottom: BoxPosition.fixed(40),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('bottomChild'),
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final topChild = tester.getTopLeft(find.byKey(Key('topChild')));
      final bottomChild = tester.getTopLeft(find.byKey(Key('bottomChild')));

      expect(topChild.dy, equals(40.0));
      // Bottom positioned child should be at: containerHeight - childHeight - bottomOffset = 300 - 80 - 40 = 180
      expect(bottomChild.dy, equals(180.0));
    });

    testWidgets('Center positioning works with BoxPosition.relative(0.5)', (
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
                    left: BoxPosition.relative(
                      0.25,
                    ), // Center - half width percentage
                    top: BoxPosition.relative(
                      0.37,
                    ), // Approximate center - half height percentage
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('centeredChild'),
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getTopLeft(find.byKey(Key('centeredChild')));

      // Child positioned at percentage of container
      expect(child.dx, equals(400 * 0.25)); // 100
      expect(child.dy, equals(300 * 0.37)); // 111
    });

    testWidgets('Relative percentage positioning works correctly', (
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
                    left: BoxPosition.relative(0.25), // 25% of width
                    top: BoxPosition.relative(0.5), // 50% of height
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('percentChild'),
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getTopLeft(find.byKey(Key('percentChild')));

      expect(child.dx, equals(400 * 0.25)); // 100
      expect(child.dy, equals(300 * 0.5)); // 150
    });

    testWidgets('Mixed horizontal and vertical positioning types work', (
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
                    left: BoxPosition.fixed(50),
                    top: BoxPosition.fixed(30),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(
                      key: Key('mixedChild'),
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final child = tester.getTopLeft(find.byKey(Key('mixedChild')));

      // Horizontal relative, vertical fixed
      expect(child.dx, equals(50.0)); // Relative to FlexBox
      expect(child.dy, equals(30.0)); // Fixed to viewport
    });

    testWidgets('Positioning without constraints works correctly', (
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
                    left: BoxPosition.fixed(50),
                    top: BoxPosition.fixed(30),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('constrainedChild'),
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final childSize = tester.getSize(find.byKey(Key('constrainedChild')));
      final childPosition = tester.getTopLeft(
        find.byKey(Key('constrainedChild')),
      );

      // Size should match the specified fixed dimensions
      expect(childSize.width, equals(100.0));
      expect(childSize.height, equals(80.0));
      expect(childPosition.dx, equals(50.0));
      expect(childPosition.dy, equals(30.0));
    });
  });

  group('Absolute Positioning with Unconstrained Sizing', () {
    testWidgets('Unconstrained with relative anchored positioning', (
      WidgetTester tester,
    ) async {
      // SPECIFICATION TEST: This documents the DESIRED behavior
      // Test: FlexBox 100px height, child anchored top=20, height=unconstrained
      // Expected: height = 80px (100 - 20)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100, // FlexBox viewport height
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    top: BoxPosition.fixed(20), // Anchored 20px from top
                    width: BoxSize.fixed(150),
                    height: BoxSize.expanding(), // Should fill remaining space
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('unconstrainedViewportChild'),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final childSize = tester.getSize(
        find.byKey(Key('unconstrainedViewportChild')),
      );
      final childPosition = tester.getTopLeft(
        find.byKey(Key('unconstrainedViewportChild')),
      );

      // Height should be viewport height - top anchor = 100 - 20 = 80
      expect(childSize.height, equals(80.0));
      expect(childSize.width, equals(150.0));
      expect(childPosition.dy, equals(20.0)); // Top position should be 20
    });

    testWidgets('Unconstrained with relative anchored positioning', (
      WidgetTester tester,
    ) async {
      // SPECIFICATION TEST: This documents the DESIRED behavior
      // Test: FlexBox 100px height, but content 300px height (scrollable)
      // Child anchored top=20, height=unconstrained
      // Expected: height = 280px (300 - 20) when using relative
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100, // Viewport height
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  // Large content to make total content height = 300px
                  FlexBoxChild(
                    width: BoxSize.fixed(200),
                    height: BoxSize.fixed(300),
                    child: Container(color: Colors.grey[200]),
                  ),
                  // Absolutely positioned child with unconstrained height
                  FlexBoxChild(
                    top: BoxPosition.fixed(
                      20,
                    ), // Anchored 20px from content top
                    width: BoxSize.fixed(150),
                    height:
                        BoxSize.expanding(), // Should fill remaining content space
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('unconstrainedContentChild'),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final childSize = tester.getSize(
        find.byKey(Key('unconstrainedContentChild')),
      );
      final childPosition = tester.getTopLeft(
        find.byKey(Key('unconstrainedContentChild')),
      );

      // Height should be content height - top anchor = 300 - 20 = 280
      expect(childSize.height, equals(280.0));
      expect(childSize.width, equals(150.0));
      expect(childPosition.dy, equals(20.0)); // Top position should be 20
    });

    testWidgets('Unconstrained with bottom anchor relative', (
      WidgetTester tester,
    ) async {
      // SPECIFICATION TEST: This documents the DESIRED behavior
      // Test: FlexBox 100px height, child anchored bottom=30, height=unconstrained
      // Expected: height = 70px (100 - 30), positioned at top=0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100,
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    bottom: BoxPosition.fixed(30), // Anchored 30px from bottom
                    width: BoxSize.fixed(150),
                    height: BoxSize.expanding(),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('unconstrainedBottomChild'),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final childSize = tester.getSize(
        find.byKey(Key('unconstrainedBottomChild')),
      );
      final childPosition = tester.getTopLeft(
        find.byKey(Key('unconstrainedBottomChild')),
      );

      // Height should be viewport height - bottom anchor = 100 - 30 = 70
      expect(childSize.height, equals(70.0));
      expect(childSize.width, equals(150.0));
      expect(childPosition.dy, equals(0.0)); // Should start at top
    });

    testWidgets('Unconstrained with left and right anchors', (
      WidgetTester tester,
    ) async {
      // SPECIFICATION TEST: This documents the DESIRED behavior
      // Test: FlexBox 200px width, child anchored left=20, right=30, width=unconstrained
      // Expected: width = 150px (200 - 20 - 30)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100,
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    left: BoxPosition.fixed(20),
                    right: BoxPosition.fixed(30),
                    width: BoxSize.expanding(),
                    height: BoxSize.fixed(80),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(
                      key: Key('unconstrainedWidthChild'),
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

      final childSize = tester.getSize(
        find.byKey(Key('unconstrainedWidthChild')),
      );
      final childPosition = tester.getTopLeft(
        find.byKey(Key('unconstrainedWidthChild')),
      );

      // Width should be viewport width - left - right = 200 - 20 - 30 = 150
      expect(childSize.width, equals(150.0));
      expect(childSize.height, equals(80.0));
      expect(childPosition.dx, equals(20.0)); // Left position should be 20
    });
  });
}
