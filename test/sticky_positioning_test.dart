import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('Sticky Positioning Tests', () {
    testWidgets('Sticky positioning keeps element in view during scroll', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 1000,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Large content to create scroll
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(200),
                      child: Container(color: Colors.grey.shade300),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(50),
                      left: BoxPosition.fixed(30),
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(80),
                      horizontalPosition: BoxPositionType.sticky,
                      verticalPosition: BoxPositionType.sticky,
                      child: Container(
                        key: Key('stickyChild'),
                        color: Colors.orange,
                      ),
                    ),
                    // More content below
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(600),
                      child: Container(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('stickyChild')), findsOneWidget);

      // Scroll down and verify sticky element adjusts position
      await tester.drag(find.byType(SingleChildScrollView), Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('stickyChild')), findsOneWidget);
    });

    testWidgets('StickyStart positioning works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 800,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Content before sticky element
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(150),
                      child: Container(color: Colors.blue.shade100),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(20),
                      left: BoxPosition.fixed(50),
                      width: BoxSize.fixed(120),
                      height: BoxSize.fixed(60),
                      horizontalPosition: BoxPositionType.stickyStart,
                      verticalPosition: BoxPositionType.stickyStart,
                      child: Container(
                        key: Key('stickyStartChild'),
                        color: Colors.green,
                      ),
                    ),
                    // Content after sticky element
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(500),
                      child: Container(color: Colors.blue.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('stickyStartChild')), findsOneWidget);

      // Verify the element maintains position at start of parent
      final child = tester.getTopLeft(find.byKey(Key('stickyStartChild')));
      expect(child.dx, equals(50.0));
      expect(child.dy, greaterThanOrEqualTo(20.0));
    });

    testWidgets('StickyEnd positioning works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 800,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Content before sticky element
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(200),
                      child: Container(color: Colors.red.shade100),
                    ),
                    FlexBoxChild(
                      bottom: BoxPosition.fixed(20),
                      right: BoxPosition.fixed(30),
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(80),
                      horizontalPosition: BoxPositionType.stickyEnd,
                      verticalPosition: BoxPositionType.stickyEnd,
                      child: Container(
                        key: Key('stickyEndChild'),
                        color: Colors.purple,
                      ),
                    ),
                    // Content after sticky element
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(400),
                      child: Container(color: Colors.red.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('stickyEndChild')), findsOneWidget);

      // Verify the element positions relative to end of parent
      final child = tester.getTopLeft(find.byKey(Key('stickyEndChild')));
      // Right positioning: containerWidth - childWidth - rightOffset = 400 - 100 - 30 = 270
      expect(child.dx, equals(270.0));
    });

    testWidgets('sticky positioning anchors to viewport', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 1200,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Large content to offset FlexBox
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(300),
                      child: Container(color: Colors.cyan.shade100),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(40),
                      left: BoxPosition.fixed(60),
                      width: BoxSize.fixed(120),
                      height: BoxSize.fixed(80),
                      horizontalPosition: BoxPositionType.sticky,
                      verticalPosition: BoxPositionType.sticky,
                      child: Container(
                        key: Key('stickyChild'),
                        color: Colors.amber,
                      ),
                    ),
                    // More content
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(800),
                      child: Container(color: Colors.cyan.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('stickyChild')), findsOneWidget);

      // sticky should position relative to viewport, not FlexBox content
      final child = tester.getTopLeft(find.byKey(Key('stickyChild')));
      expect(child.dx, equals(60.0));
      expect(child.dy, equals(40.0));
    });

    testWidgets('stickyStart positioning works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 1000,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Content to push FlexBox down
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(250),
                      child: Container(color: Colors.teal.shade100),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(10),
                      left: BoxPosition.fixed(20),
                      width: BoxSize.fixed(140),
                      height: BoxSize.fixed(70),
                      horizontalPosition: BoxPositionType.stickyStart,
                      verticalPosition: BoxPositionType.stickyStart,
                      child: Container(
                        key: Key('stickyStartChild'),
                        color: Colors.lime,
                      ),
                    ),
                    // Additional content
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(600),
                      child: Container(color: Colors.teal.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('stickyStartChild')), findsOneWidget);

      // Should stick to viewport start, not FlexBox start
      final child = tester.getTopLeft(find.byKey(Key('stickyStartChild')));
      expect(child.dx, equals(20.0));
      expect(child.dy, equals(10.0));
    });

    testWidgets('stickyEnd positioning works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 1000,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Content before
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(200),
                      child: Container(color: Colors.pink.shade100),
                    ),
                    FlexBoxChild(
                      bottom: BoxPosition.fixed(30),
                      right: BoxPosition.fixed(40),
                      width: BoxSize.fixed(110),
                      height: BoxSize.fixed(90),
                      horizontalPosition: BoxPositionType.stickyEnd,
                      verticalPosition: BoxPositionType.stickyEnd,
                      child: Container(
                        key: Key('stickyEndChild'),
                        color: Colors.indigo,
                      ),
                    ),
                    // Content after
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(650),
                      child: Container(color: Colors.pink.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('stickyEndChild')), findsOneWidget);

      // Should position relative to viewport end
      final child = tester.getTopLeft(find.byKey(Key('stickyEndChild')));
      // Right positioning relative to viewport: containerWidth - childWidth - rightOffset
      expect(child.dx, equals(400 - 110 - 40)); // 250
    });

    testWidgets('Mixed sticky positioning types work together', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 1200,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Content spacer
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(100),
                      child: Container(color: Colors.grey.shade200),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(20),
                      left: BoxPosition.fixed(20),
                      width: BoxSize.fixed(80),
                      height: BoxSize.fixed(60),
                      horizontalPosition: BoxPositionType.sticky,
                      verticalPosition: BoxPositionType.sticky,
                      child: Container(key: Key('sticky1'), color: Colors.red),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(30),
                      left: BoxPosition.fixed(120),
                      width: BoxSize.fixed(80),
                      height: BoxSize.fixed(60),
                      horizontalPosition: BoxPositionType.sticky,
                      verticalPosition: BoxPositionType.sticky,
                      child: Container(key: Key('sticky2'), color: Colors.blue),
                    ),
                    FlexBoxChild(
                      bottom: BoxPosition.fixed(40),
                      right: BoxPosition.fixed(20),
                      width: BoxSize.fixed(80),
                      height: BoxSize.fixed(60),
                      horizontalPosition: BoxPositionType.stickyEnd,
                      verticalPosition: BoxPositionType.stickyEnd,
                      child: Container(
                        key: Key('sticky3'),
                        color: Colors.green,
                      ),
                    ),
                    // Large content to enable scrolling
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(800),
                      child: Container(color: Colors.grey.shade300),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('sticky1')), findsOneWidget);
      expect(find.byKey(Key('sticky2')), findsOneWidget);
      expect(find.byKey(Key('sticky3')), findsOneWidget);

      // Test that all sticky elements are rendered
      final sticky1 = tester.getTopLeft(find.byKey(Key('sticky1')));
      final sticky2 = tester.getTopLeft(find.byKey(Key('sticky2')));
      final sticky3 = tester.getTopLeft(find.byKey(Key('sticky3')));

      expect(sticky1.dx, equals(20.0));
      expect(sticky2.dx, equals(120.0));
      expect(sticky3.dx, equals(400 - 80 - 20)); // 300
    });

    testWidgets('Sticky positioning with scrolling behavior', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 1500,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Top spacer
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(300),
                      child: Container(color: Colors.orange.shade100),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(50),
                      left: BoxPosition.fixed(50),
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(80),
                      horizontalPosition: BoxPositionType.sticky,
                      verticalPosition: BoxPositionType.sticky,
                      child: Container(
                        key: Key('scrollStickyChild'),
                        color: Colors.deepPurple,
                      ),
                    ),
                    // Bottom spacer
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(1000),
                      child: Container(color: Colors.orange.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('scrollStickyChild')), findsOneWidget);

      // Initial position
      final initialPosition = tester.getTopLeft(
        find.byKey(Key('scrollStickyChild')),
      );
      expect(initialPosition.dx, equals(50.0));

      // Scroll down and verify sticky behavior
      await tester.drag(find.byType(SingleChildScrollView), Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('scrollStickyChild')), findsOneWidget);

      // After scrolling, sticky element should adjust its position
      final scrolledPosition = tester.getTopLeft(
        find.byKey(Key('scrollStickyChild')),
      );
      expect(
        scrolledPosition.dx,
        equals(50.0),
      ); // Horizontal position should remain the same
    });

    testWidgets('Horizontal and vertical sticky positioning independence', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 800,
                  height: 800,
                  child: FlexBox(
                    direction: Axis.vertical,
                    children: [
                      FlexBoxChild(
                        width: BoxSize.fixed(800),
                        height: BoxSize.fixed(200),
                        child: Container(color: Colors.amber.shade100),
                      ),
                      FlexBoxChild(
                        top: BoxPosition.fixed(100),
                        left: BoxPosition.fixed(150),
                        width: BoxSize.fixed(120),
                        height: BoxSize.fixed(80),
                        horizontalPosition: BoxPositionType.sticky,
                        verticalPosition: BoxPositionType.sticky,
                        child: Container(
                          key: Key('mixedStickyChild'),
                          color: Colors.deepOrange,
                        ),
                      ),
                      FlexBoxChild(
                        width: BoxSize.fixed(800),
                        height: BoxSize.fixed(500),
                        child: Container(color: Colors.amber.shade200),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('mixedStickyChild')), findsOneWidget);

      final position = tester.getTopLeft(find.byKey(Key('mixedStickyChild')));
      expect(position.dx, equals(150.0));
      expect(position.dy, equals(100.0));
    });
  });
}
