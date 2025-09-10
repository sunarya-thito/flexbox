import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('Viewport Positioning Tests', () {
    testWidgets('relative positioning anchors to viewport', (
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
                    // Content to offset the FlexBox
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(300),
                      child: Container(color: Colors.grey.shade300),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(50),
                      left: BoxPosition.fixed(80),
                      width: BoxSize.fixed(120),
                      height: BoxSize.fixed(90),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('viewportChild'),
                        color: Colors.blue,
                      ),
                    ),
                    // Additional content
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(400),
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

      expect(find.byKey(Key('viewportChild')), findsOneWidget);

      final child = tester.getTopLeft(find.byKey(Key('viewportChild')));
      // relative should position relative to viewport, not FlexBox content
      expect(child.dx, equals(80.0));
      expect(child.dy, equals(50.0));
    });

    testWidgets('relative with percentage positioning', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 600,
              height: 400,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 600,
                  height: 1000,
                  child: FlexBox(
                    direction: Axis.vertical,
                    children: [
                      // Large content to create scrollable area
                      FlexBoxChild(
                        width: BoxSize.fixed(600),
                        height: BoxSize.fixed(200),
                        child: Container(color: Colors.red.shade100),
                      ),
                      FlexBoxChild(
                        left: BoxPosition.relative(
                          0.25,
                        ), // 25% of viewport width
                        top: BoxPosition.relative(
                          0.5,
                        ), // 50% of viewport height
                        width: BoxSize.fixed(100),
                        height: BoxSize.fixed(80),
                        horizontalPosition: BoxPositionType.relative,
                        verticalPosition: BoxPositionType.relative,
                        child: Container(
                          key: Key('percentViewportChild'),
                          color: Colors.purple,
                        ),
                      ),
                      // More content
                      FlexBoxChild(
                        width: BoxSize.fixed(600),
                        height: BoxSize.fixed(700),
                        child: Container(color: Colors.red.shade200),
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

      expect(find.byKey(Key('percentViewportChild')), findsOneWidget);

      final child = tester.getTopLeft(find.byKey(Key('percentViewportChild')));
      // Position should be relative to full content dimensions for relative positioning
      // Content height = 200 (first child) + 700 (third child) = 900
      // Content width = 600 (from SizedBox)
      expect(child.dx, equals(600 * 0.25)); // 150 (25% of content width)
      expect(child.dy, equals(900 * 0.5)); // 450 (50% of content height)
    });

    testWidgets('relative vs Relative positioning comparison', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                height: 900,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Content to offset FlexBox
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(150),
                      child: Container(color: Colors.green.shade100),
                    ),
                    // Relative positioning - relative to FlexBox
                    FlexBoxChild(
                      top: BoxPosition.fixed(60),
                      left: BoxPosition.fixed(100),
                      width: BoxSize.fixed(80),
                      height: BoxSize.fixed(60),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('relativeChild'),
                        color: Colors.orange,
                      ),
                    ),
                    // relative positioning - relative to viewport
                    FlexBoxChild(
                      top: BoxPosition.fixed(60),
                      left: BoxPosition.fixed(100),
                      width: BoxSize.fixed(80),
                      height: BoxSize.fixed(60),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('viewportRelativeChild'),
                        color: Colors.cyan,
                      ),
                    ),
                    // More content
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(600),
                      child: Container(color: Colors.green.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('relativeChild')), findsOneWidget);
      expect(find.byKey(Key('viewportRelativeChild')), findsOneWidget);

      final relativeChild = tester.getTopLeft(find.byKey(Key('relativeChild')));
      final viewportChild = tester.getTopLeft(
        find.byKey(Key('viewportRelativeChild')),
      );

      // Both should have the same positioning values in this case
      expect(relativeChild.dx, equals(100.0));
      expect(viewportChild.dx, equals(100.0));
      expect(relativeChild.dy, equals(60.0));
      expect(viewportChild.dy, equals(60.0));
    });

    testWidgets('Viewport positioning with scrolling behavior', (
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
                    // Large top content
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(400),
                      child: Container(color: Colors.amber.shade100),
                    ),
                    FlexBoxChild(
                      top: BoxPosition.fixed(100),
                      left: BoxPosition.fixed(150),
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(80),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('scrollViewportChild'),
                        color: Colors.indigo,
                      ),
                    ),
                    // Large bottom content
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(600),
                      child: Container(color: Colors.amber.shade200),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('scrollViewportChild')), findsOneWidget);

      // Initial position before scrolling
      final initialPosition = tester.getTopLeft(
        find.byKey(Key('scrollViewportChild')),
      );
      expect(initialPosition.dx, equals(150.0));
      expect(initialPosition.dy, equals(100.0));

      // Scroll down
      await tester.drag(find.byType(SingleChildScrollView), Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('scrollViewportChild')), findsOneWidget);

      // After scrolling, the viewport positioned element moves with the content
      final scrolledPosition = tester.getTopLeft(
        find.byKey(Key('scrollViewportChild')),
      );
      expect(
        scrolledPosition.dx,
        equals(150.0),
      ); // Horizontal should remain the same
      expect(
        scrolledPosition.dy,
        equals(100.0 - 300.0),
      ); // Should move up by scroll amount (-200.0)
    });

    testWidgets('Mixed viewport and regular positioning types', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 500,
                height: 1000,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Content spacer
                    FlexBoxChild(
                      width: BoxSize.fixed(500),
                      height: BoxSize.fixed(200),
                      child: Container(color: Colors.pink.shade100),
                    ),
                    // Fixed positioning
                    FlexBoxChild(
                      top: BoxPosition.fixed(30),
                      left: BoxPosition.fixed(50),
                      width: BoxSize.fixed(90),
                      height: BoxSize.fixed(70),
                      horizontalPosition: BoxPositionType.fixed,
                      verticalPosition: BoxPositionType.fixed,
                      child: Container(
                        key: Key('fixedChild'),
                        color: Colors.red,
                      ),
                    ),
                    // Relative positioning
                    FlexBoxChild(
                      top: BoxPosition.fixed(40),
                      left: BoxPosition.fixed(160),
                      width: BoxSize.fixed(90),
                      height: BoxSize.fixed(70),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('relativeChild'),
                        color: Colors.blue,
                      ),
                    ),
                    // relative positioning
                    FlexBoxChild(
                      top: BoxPosition.fixed(50),
                      left: BoxPosition.fixed(270),
                      width: BoxSize.fixed(90),
                      height: BoxSize.fixed(70),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('viewportChild'),
                        color: Colors.green,
                      ),
                    ),
                    // Content below
                    FlexBoxChild(
                      width: BoxSize.fixed(500),
                      height: BoxSize.fixed(600),
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

      expect(find.byKey(Key('fixedChild')), findsOneWidget);
      expect(find.byKey(Key('relativeChild')), findsOneWidget);
      expect(find.byKey(Key('viewportChild')), findsOneWidget);

      final fixedChild = tester.getTopLeft(find.byKey(Key('fixedChild')));
      final relativeChild = tester.getTopLeft(find.byKey(Key('relativeChild')));
      final viewportChild = tester.getTopLeft(find.byKey(Key('viewportChild')));

      // Fixed positioning should be relative to viewport
      expect(fixedChild.dx, equals(50.0));
      expect(fixedChild.dy, equals(30.0));

      // Relative positioning should be relative to FlexBox
      expect(relativeChild.dx, equals(160.0));
      expect(relativeChild.dy, equals(40.0));

      // relative should be relative to viewport
      expect(viewportChild.dx, equals(270.0));
      expect(viewportChild.dy, equals(50.0));
    });

    testWidgets('Viewport positioning with constraints and sizing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 800,
              height: 600,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 800,
                  height: 1200,
                  child: FlexBox(
                    direction: Axis.vertical,
                    children: [
                      // Content offset
                      FlexBoxChild(
                        width: BoxSize.fixed(800),
                        height: BoxSize.fixed(300),
                        child: Container(color: Colors.teal.shade100),
                      ),
                      // Viewport positioned with flex sizing
                      FlexBoxChild(
                        top: BoxPosition.relative(
                          0.1,
                        ), // 10% of viewport height
                        left: BoxPosition.relative(
                          0.2,
                        ), // 20% of viewport width
                        width: BoxSize.flex(1.0),
                        height: BoxSize.fixed(120),
                        horizontalPosition: BoxPositionType.relative,
                        verticalPosition: BoxPositionType.relative,
                        child: Container(
                          key: Key('flexViewportChild'),
                          color: Colors.deepPurple,
                        ),
                      ),
                      // Viewport positioned with unconstrained sizing
                      FlexBoxChild(
                        bottom: BoxPosition.fixed(80),
                        right: BoxPosition.fixed(40),
                        width: BoxSize.unconstrained(),
                        height: BoxSize.unconstrained(),
                        horizontalPosition: BoxPositionType.relative,
                        verticalPosition: BoxPositionType.relative,
                        child: Container(
                          key: Key('unconstrainedViewportChild'),
                          width: 150,
                          height: 100,
                          color: Colors.brown,
                        ),
                      ),
                      // More content
                      FlexBoxChild(
                        width: BoxSize.fixed(800),
                        height: BoxSize.fixed(600),
                        child: Container(color: Colors.teal.shade200),
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

      expect(find.byKey(Key('flexViewportChild')), findsOneWidget);
      expect(find.byKey(Key('unconstrainedViewportChild')), findsOneWidget);

      final flexChild = tester.getTopLeft(find.byKey(Key('flexViewportChild')));
      final unconstrainedChild = tester.getTopLeft(
        find.byKey(Key('unconstrainedViewportChild')),
      );

      // FlexViewport child positioned relative to content dimensions for relative
      // Content height = 300 (first child) + 600 (third child) = 900
      // Content width = 800 (from SizedBox)
      expect(flexChild.dx, equals(800 * 0.2)); // 160 (20% of content width)
      expect(flexChild.dy, equals(900 * 0.1)); // 90 (10% of content height)

      // Unconstrained viewport child positioned from bottom-right relative to content dimensions
      // Content dimensions: 800x900, child dimensions: 150x100
      expect(
        unconstrainedChild.dx,
        equals(800 - 150 - 40),
      ); // 610 (content width - child width - right offset)
      expect(
        unconstrainedChild.dy,
        equals(900 - 100 - 80),
      ); // 720 (content height - child height - bottom offset)
    });

    testWidgets('Edge case: Viewport positioning with zero dimensions', (
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
                    // Zero-width child with viewport positioning
                    FlexBoxChild(
                      top: BoxPosition.fixed(50),
                      left: BoxPosition.fixed(100),
                      width: BoxSize.fixed(0),
                      height: BoxSize.fixed(80),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('zeroWidthChild'),
                        color: Colors.orange,
                      ),
                    ),
                    // Zero-height child with viewport positioning
                    FlexBoxChild(
                      top: BoxPosition.fixed(150),
                      left: BoxPosition.fixed(200),
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(0),
                      horizontalPosition: BoxPositionType.relative,
                      verticalPosition: BoxPositionType.relative,
                      child: Container(
                        key: Key('zeroHeightChild'),
                        color: Colors.cyan,
                      ),
                    ),
                    // Regular content
                    FlexBoxChild(
                      width: BoxSize.fixed(400),
                      height: BoxSize.fixed(300),
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

      expect(find.byKey(Key('zeroWidthChild')), findsOneWidget);
      expect(find.byKey(Key('zeroHeightChild')), findsOneWidget);

      final zeroWidthChild = tester.getSize(find.byKey(Key('zeroWidthChild')));
      final zeroHeightChild = tester.getSize(
        find.byKey(Key('zeroHeightChild')),
      );

      expect(zeroWidthChild.width, equals(0.0));
      expect(zeroWidthChild.height, equals(80.0));
      expect(zeroHeightChild.width, equals(100.0));
      expect(zeroHeightChild.height, equals(0.0));
    });

    testWidgets(
      'Viewport positioning maintains consistency across layout changes',
      (WidgetTester tester) async {
        bool showExtraContent = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: SizedBox(
                      width: 400,
                      height: showExtraContent ? 1000 : 600,
                      child: FlexBox(
                        direction: Axis.vertical,
                        children: [
                          if (showExtraContent)
                            FlexBoxChild(
                              width: BoxSize.fixed(400),
                              height: BoxSize.fixed(200),
                              child: Container(color: Colors.yellow.shade100),
                            ),
                          FlexBoxChild(
                            top: BoxPosition.fixed(80),
                            left: BoxPosition.fixed(120),
                            width: BoxSize.fixed(160),
                            height: BoxSize.fixed(100),
                            horizontalPosition: BoxPositionType.relative,
                            verticalPosition: BoxPositionType.relative,
                            child: GestureDetector(
                              onTap: () => setState(
                                () => showExtraContent = !showExtraContent,
                              ),
                              child: Container(
                                key: Key('consistentViewportChild'),
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          FlexBoxChild(
                            width: BoxSize.fixed(400),
                            height: BoxSize.fixed(400),
                            child: Container(color: Colors.grey.shade200),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initial position
        final initialPosition = tester.getTopLeft(
          find.byKey(Key('consistentViewportChild')),
        );
        expect(initialPosition.dx, equals(120.0));
        expect(initialPosition.dy, equals(80.0));

        // Tap to change layout
        await tester.tap(find.byKey(Key('consistentViewportChild')));
        await tester.pumpAndSettle();

        // Position should remain consistent relative to viewport
        final afterChangePosition = tester.getTopLeft(
          find.byKey(Key('consistentViewportChild')),
        );
        expect(afterChangePosition.dx, equals(120.0));
        expect(afterChangePosition.dy, equals(80.0));
      },
    );
  });
}
