import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('Sizing Behaviors Tests', () {
    group('Fixed Sizing', () {
      testWidgets('Fixed width and height work correctly', (
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
                      width: BoxSize.fixed(200),
                      height: BoxSize.fixed(150),
                      child: Container(
                        key: Key('fixedChild'),
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

        final childSize = tester.getSize(find.byKey(Key('fixedChild')));
        expect(childSize.width, equals(200.0));
        expect(childSize.height, equals(150.0));
      });

      testWidgets('Fixed sizing overrides container constraints', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 100, // Smaller than child
                height: 80,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(250),
                      height: BoxSize.fixed(200),
                      child: Container(
                        key: Key('oversizedChild'),
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

        final childSize = tester.getSize(find.byKey(Key('oversizedChild')));
        expect(childSize.width, equals(250.0));
        expect(childSize.height, equals(200.0));
      });
    });

    group('Unconstrained Sizing', () {
      testWidgets('Unconstrained sizing fits content', (
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
                      width: BoxSize.expanding(),
                      height: BoxSize.expanding(),
                      child: Container(
                        key: Key('unconstrainedChild'),
                        width: 180,
                        height: 120,
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

        final childSize = tester.getSize(find.byKey(Key('unconstrainedChild')));
        expect(childSize.width, equals(180.0));
        expect(childSize.height, equals(120.0));
      });

      testWidgets('Unconstrained with min/max constraints', (
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
                      width: BoxSize.expanding(min: 100, max: 250),
                      height: BoxSize.expanding(min: 80, max: 200),
                      child: Container(
                        key: Key('constrainedUnconstrainedChild'),
                        width: 50, // Below min
                        height: 300, // Above max
                        color: Colors.orange,
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
          find.byKey(Key('constrainedUnconstrainedChild')),
        );
        expect(childSize.width, greaterThanOrEqualTo(100.0));
        expect(childSize.width, lessThanOrEqualTo(250.0));
        expect(childSize.height, greaterThanOrEqualTo(80.0));
        expect(childSize.height, lessThanOrEqualTo(200.0));
      });

      testWidgets('Unconstrained with flex children acts as biggest flex', (
        WidgetTester tester,
      ) async {
        // SPECIFICATION TEST: This documents the DESIRED behavior
        // Test case: flex(1), flex(2), unconstrained
        // Unconstrained should act as if it has flex(2) - the biggest flex value
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 500, // Total width
                height: 300,
                child: FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('flex1Child'),
                        color: Colors.red,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(2.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('flex2Child'),
                        color: Colors.blue,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.expanding(),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('unconstrainedChild'),
                        width:
                            80, // Content width - should be ignored in flex calculation
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

        final flex1Size = tester.getSize(find.byKey(Key('flex1Child')));
        final flex2Size = tester.getSize(find.byKey(Key('flex2Child')));
        final unconstrainedSize = tester.getSize(
          find.byKey(Key('unconstrainedChild')),
        );

        // Total flex units: 1 + 2 + 2 (unconstrained acts as biggest flex) = 5
        // Available width: 500px
        // Expected: flex(1) = 100px, flex(2) = 200px, unconstrained = 200px
        expect(flex1Size.width, equals(100.0));
        expect(flex2Size.width, equals(200.0));
        expect(unconstrainedSize.width, equals(200.0)); // Acts as flex(2)
      });

      testWidgets('Unconstrained fills remaining space when no flex children', (
        WidgetTester tester,
      ) async {
        // SPECIFICATION TEST: This documents the DESIRED behavior
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
                      child: Container(
                        key: Key('fixedChild'),
                        color: Colors.red,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.expanding(),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('unconstrainedChild'),
                        width: 50, // Content width - should be ignored
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

        final fixedSize = tester.getSize(find.byKey(Key('fixedChild')));
        final unconstrainedSize = tester.getSize(
          find.byKey(Key('unconstrainedChild')),
        );

        expect(fixedSize.width, equals(100.0));
        expect(
          unconstrainedSize.width,
          equals(300.0),
        ); // 400 - 100 = 300 (fills remaining)
      });
    });

    group('Flex Sizing', () {
      testWidgets('Single flex child takes available space', (
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
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('singleFlexChild'),
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

        final childSize = tester.getSize(find.byKey(Key('singleFlexChild')));
        expect(childSize.width, equals(400.0)); // Takes full width
        expect(childSize.height, equals(100.0));
      });

      testWidgets('Multiple flex children share space proportionally', (
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
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('flex1Child'),
                        color: Colors.red,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(2.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('flex2Child'),
                        color: Colors.blue,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('flex3Child'),
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

        final flex1Size = tester.getSize(find.byKey(Key('flex1Child')));
        final flex2Size = tester.getSize(find.byKey(Key('flex2Child')));
        final flex3Size = tester.getSize(find.byKey(Key('flex3Child')));

        // Total flex: 1 + 2 + 1 = 4
        // Expected widths: 100, 200, 100
        expect(flex1Size.width, equals(100.0));
        expect(flex2Size.width, equals(200.0));
        expect(flex3Size.width, equals(100.0));
      });

      testWidgets('Flex sizing with min/max constraints', (
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
                      width: BoxSize.flex(1.0, min: 150, max: 180),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('constrainedFlexChild'),
                        color: Colors.cyan,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('normalFlexChild'),
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final constrainedSize = tester.getSize(
          find.byKey(Key('constrainedFlexChild')),
        );
        final normalSize = tester.getSize(find.byKey(Key('normalFlexChild')));

        expect(constrainedSize.width, greaterThanOrEqualTo(150.0));
        expect(constrainedSize.width, lessThanOrEqualTo(180.0));
        expect(normalSize.width, greaterThan(0));
      });

      testWidgets('Vertical flex sizing works correctly', (
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
                      width: BoxSize.fixed(200),
                      height: BoxSize.flex(1.0),
                      child: Container(
                        key: Key('verticalFlex1'),
                        color: Colors.pink,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(200),
                      height: BoxSize.flex(2.0),
                      child: Container(
                        key: Key('verticalFlex2'),
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

        final flex1Size = tester.getSize(find.byKey(Key('verticalFlex1')));
        final flex2Size = tester.getSize(find.byKey(Key('verticalFlex2')));

        // Total flex: 1 + 2 = 3
        // Expected heights: 100, 200
        expect(flex1Size.height, equals(100.0));
        expect(flex2Size.height, equals(200.0));
      });
    });

    group('Ratio Sizing', () {
      testWidgets('Ratio sizing respects aspect ratio', (
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
                      width: BoxSize.fixed(200),
                      height: BoxSize.ratio(0.5), // Height = width * 0.5
                      child: Container(
                        key: Key('ratioChild'),
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

        final childSize = tester.getSize(find.byKey(Key('ratioChild')));
        expect(childSize.width, equals(200.0));
        expect(childSize.height, equals(100.0)); // 200 * 0.5
      });

      testWidgets('Ratio sizing with different reference dimensions', (
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
                      width: BoxSize.ratio(1.5), // Width = height * 1.5
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('widthRatioChild'),
                        color: Colors.brown,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(120),
                      height: BoxSize.ratio(2.0), // Height = width * 2.0
                      child: Container(
                        key: Key('heightRatioChild'),
                        color: Colors.lime,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final widthRatioSize = tester.getSize(
          find.byKey(Key('widthRatioChild')),
        );
        final heightRatioSize = tester.getSize(
          find.byKey(Key('heightRatioChild')),
        );

        expect(widthRatioSize.width, equals(150.0)); // 100 * 1.5
        expect(widthRatioSize.height, equals(100.0));
        expect(heightRatioSize.width, equals(120.0));
        expect(heightRatioSize.height, equals(240.0)); // 120 * 2.0
      });

      testWidgets('Ratio sizing with constraints', (WidgetTester tester) async {
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
                      width: BoxSize.fixed(400),
                      height: BoxSize.ratio(
                        0.1,
                        min: 60,
                        max: 120,
                      ), // Would be 40 without constraints
                      child: Container(
                        key: Key('constrainedRatioChild'),
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

        final childSize = tester.getSize(
          find.byKey(Key('constrainedRatioChild')),
        );
        expect(childSize.width, equals(400.0));
        expect(childSize.height, equals(60.0)); // Constrained to min value
      });
    });

    group('Intrinsic Sizing', () {
      testWidgets('Intrinsic sizing fits text content', (
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
                      width: BoxSize.intrinsic(),
                      height: BoxSize.intrinsic(),
                      child: Text(
                        'Short Text',
                        key: Key('shortTextChild'),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.intrinsic(),
                      height: BoxSize.intrinsic(),
                      child: Text(
                        'This is a much longer text that should result in different intrinsic dimensions',
                        key: Key('longTextChild'),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final shortSize = tester.getSize(find.byKey(Key('shortTextChild')));
        final longSize = tester.getSize(find.byKey(Key('longTextChild')));

        expect(shortSize.width, greaterThan(0));
        expect(shortSize.height, greaterThan(0));
        expect(longSize.width, greaterThan(shortSize.width));
      });

      testWidgets('Intrinsic sizing with constraints', (
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
                      width: BoxSize.intrinsic(min: 100, max: 200),
                      height: BoxSize.intrinsic(min: 50, max: 100),
                      child: Text(
                        'Constrained Text',
                        key: Key('constrainedIntrinsicChild'),
                        style: TextStyle(fontSize: 24),
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
          find.byKey(Key('constrainedIntrinsicChild')),
        );
        expect(childSize.width, greaterThanOrEqualTo(100.0));
        expect(childSize.width, lessThanOrEqualTo(200.0));
        expect(childSize.height, greaterThanOrEqualTo(50.0));
        expect(childSize.height, lessThanOrEqualTo(100.0));
      });
    });

    group('Mixed Sizing Scenarios', () {
      testWidgets('Fixed, flex, and unconstrained sizing together', (
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
                      child: Container(
                        key: Key('fixedChild'),
                        color: Colors.red,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('flexChild'),
                        color: Colors.blue,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.expanding(),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('unconstrainedChild'),
                        width: 80,
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

        final fixedSize = tester.getSize(find.byKey(Key('fixedChild')));
        final flexSize = tester.getSize(find.byKey(Key('flexChild')));
        final unconstrainedSize = tester.getSize(
          find.byKey(Key('unconstrainedChild')),
        );

        expect(fixedSize.width, equals(100.0));
        expect(flexSize.width, equals(220.0)); // 400 - 100 - 80
        expect(unconstrainedSize.width, equals(80.0));
      });

      testWidgets('All sizing types in vertical layout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(300),
                      height: BoxSize.fixed(80),
                      child: Container(
                        key: Key('fixedHeightChild'),
                        color: Colors.orange,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(300),
                      height: BoxSize.flex(1.0),
                      child: Container(
                        key: Key('flexHeightChild'),
                        color: Colors.purple,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(300),
                      height: BoxSize.ratio(0.5), // 300 * 0.5 = 150
                      child: Container(
                        key: Key('ratioHeightChild'),
                        color: Colors.cyan,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(300),
                      height: BoxSize.expanding(),
                      child: Container(
                        key: Key('unconstrainedHeightChild'),
                        height: 60,
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

        final fixedSize = tester.getSize(find.byKey(Key('fixedHeightChild')));
        final flexSize = tester.getSize(find.byKey(Key('flexHeightChild')));
        final ratioSize = tester.getSize(find.byKey(Key('ratioHeightChild')));
        final unconstrainedSize = tester.getSize(
          find.byKey(Key('unconstrainedHeightChild')),
        );

        expect(fixedSize.height, equals(80.0));
        expect(flexSize.height, equals(110.0)); // 400 - 80 - 150 - 60
        expect(ratioSize.height, equals(150.0));
        expect(unconstrainedSize.height, equals(60.0));
      });

      testWidgets('Complex nested sizing behaviors', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600,
                height: 400,
                child: FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(400),
                      child: FlexBox(
                        direction: Axis.vertical,
                        children: [
                          FlexBoxChild(
                            width: BoxSize.flex(1.0),
                            height: BoxSize.flex(1.0),
                            child: Container(
                              key: Key('nestedFlexChild'),
                              color: Colors.red,
                            ),
                          ),
                          FlexBoxChild(
                            width: BoxSize.flex(1.0),
                            height: BoxSize.fixed(100),
                            child: Container(
                              key: Key('nestedFixedChild'),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(200),
                      height: BoxSize.fixed(400),
                      child: Container(
                        key: Key('sidebarChild'),
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

        final nestedFlexSize = tester.getSize(
          find.byKey(Key('nestedFlexChild')),
        );
        final nestedFixedSize = tester.getSize(
          find.byKey(Key('nestedFixedChild')),
        );
        final sidebarSize = tester.getSize(find.byKey(Key('sidebarChild')));

        expect(nestedFlexSize.width, equals(400.0)); // 600 - 200
        expect(nestedFlexSize.height, equals(300.0)); // 400 - 100
        expect(nestedFixedSize.width, equals(400.0));
        expect(nestedFixedSize.height, equals(100.0));
        expect(sidebarSize.width, equals(200.0));
        expect(sidebarSize.height, equals(400.0));
      });

      testWidgets('Flex distribution with min/max constraints and redistribution', (
        WidgetTester tester,
      ) async {
        // Test scenario: Multiple flex children where one is constrained by min/max,
        // and remaining space should be redistributed to other flex children
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
                      width: BoxSize.flex(
                        2.0,
                        min: 200,
                        max: 200,
                      ), // Constrained to exactly 200
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('constrainedFlex'),
                        color: Colors.red,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(1.0), // Should get remaining space
                      height: BoxSize.fixed(100),
                      child: Container(key: Key('flex1'), color: Colors.blue),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(1.0), // Should get remaining space
                      height: BoxSize.fixed(100),
                      child: Container(key: Key('flex2'), color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final constrainedSize = tester.getSize(
          find.byKey(Key('constrainedFlex')),
        );
        final flex1Size = tester.getSize(find.byKey(Key('flex1')));
        final flex2Size = tester.getSize(find.byKey(Key('flex2')));

        // Total width: 400
        // Constrained child: exactly 200 (clamped by min=max=200)
        // Remaining space: 400 - 200 = 200
        // This should be distributed among the other 2 flex children with flex(1.0) each
        // So each should get: 200 / 2 = 100

        expect(
          constrainedSize.width,
          equals(200.0),
          reason: 'Constrained flex child should be clamped to min/max',
        );
        expect(
          flex1Size.width,
          equals(100.0),
          reason: 'Remaining space should be redistributed: (400-200)/2 = 100',
        );
        expect(
          flex2Size.width,
          equals(100.0),
          reason: 'Remaining space should be redistributed: (400-200)/2 = 100',
        );

        // Verify total adds up correctly
        final totalWidth =
            constrainedSize.width + flex1Size.width + flex2Size.width;
        expect(
          totalWidth,
          equals(400.0),
          reason: 'Total width should equal container width',
        );
      });

      testWidgets('Flex distribution with max constraint affecting redistribution', (
        WidgetTester tester,
      ) async {
        // Test scenario: Flex child would normally be larger but is constrained by max,
        // extra space should be redistributed
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600,
                height: 300,
                child: FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.flex(
                        4.0,
                        max: 150,
                      ), // Would be 400 without max, but clamped to 150
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('maxConstrainedFlex'),
                        color: Colors.purple,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(
                        1.0,
                      ), // Should get more than normal due to redistribution
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('redistributedFlex'),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final maxConstrainedSize = tester.getSize(
          find.byKey(Key('maxConstrainedFlex')),
        );
        final redistributedSize = tester.getSize(
          find.byKey(Key('redistributedFlex')),
        );

        print(
          'Max constrained test: maxConstrainedSize.width=${maxConstrainedSize.width}, redistributedSize.width=${redistributedSize.width}',
        );

        // Proper behavior with redistribution:
        // Total width: 600, Total flex: 4+1=5
        // Without constraints: flex(4) would get 600*4/5=480, flex(1) would get 600*1/5=120
        // With max=150 constraint: flex(4) gets 150 (clamped), remaining space is 600-150=450
        // Remaining flex is 1, so flex(1) gets all 450

        expect(
          maxConstrainedSize.width,
          equals(150.0),
          reason: 'Flex child should be clamped by max constraint',
        );
        expect(
          redistributedSize.width,
          equals(450.0),
          reason:
              'Proper redistribution: constrained space should be redistributed to other flex children',
        );

        // The total should equal container width with proper redistribution
        final totalWidth = maxConstrainedSize.width + redistributedSize.width;
        expect(
          totalWidth,
          equals(600.0),
          reason:
              'With proper redistribution, total should equal container width',
        );
      });

      testWidgets('Flex distribution with min constraint affecting redistribution', (
        WidgetTester tester,
      ) async {
        // Test scenario: Flex child would normally be smaller but is constrained by min,
        // space should be taken from other flex children
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 200,
                child: FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.flex(
                        1.0,
                        min: 200,
                      ), // Would be 100 without min, but forced to 200
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('minConstrainedFlex'),
                        color: Colors.teal,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(
                        2.0,
                      ), // Should get less space due to min constraint
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('reducedFlex'),
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final minConstrainedSize = tester.getSize(
          find.byKey(Key('minConstrainedFlex')),
        );
        final reducedSize = tester.getSize(find.byKey(Key('reducedFlex')));

        print(
          'Min constrained test: minConstrainedSize.width=${minConstrainedSize.width}, reducedSize.width=${reducedSize.width}',
        );

        // Proper behavior with redistribution:
        // Total width: 300, Total flex: 1+2=3
        // Without constraints: flex(1) would get 300*1/3=100, flex(2) would get 300*2/3=200
        // With min=200 constraint: flex(1) gets 200 (forced by min), remaining space is 300-200=100
        // Remaining flex is 2, so flex(2) gets 100

        expect(
          minConstrainedSize.width,
          equals(200.0),
          reason: 'Flex child should be forced to min constraint',
        );
        expect(
          reducedSize.width,
          equals(100.0),
          reason:
              'Proper redistribution: remaining space after min constraint should be distributed to other flex children',
        );

        // The total should equal container width with proper redistribution
        final totalWidth = minConstrainedSize.width + reducedSize.width;
        expect(
          totalWidth,
          equals(300.0),
          reason:
              'With proper redistribution, total should equal container width',
        );
      });
    });
  });
}
