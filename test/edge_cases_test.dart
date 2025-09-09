import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('Edge Cases and Constraints Tests', () {
    testWidgets('FlexBox with no children renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FlexBox(
                direction: Axis.vertical,
                children: [],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FlexBox), findsOneWidget);
    });

    testWidgets('FlexBox with single child renders correctly', (WidgetTester tester) async {
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
                    child: Container(key: Key('singleChild'), color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(Key('singleChild')), findsOneWidget);
      
      final childSize = tester.getSize(find.byKey(Key('singleChild')));
      expect(childSize.width, equals(200.0));
      expect(childSize.height, equals(150.0));
    });

    testWidgets('Large number of children render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: SingleChildScrollView(
                child: FlexBox(
                  direction: Axis.vertical,
                  children: List.generate(50, (index) => 
                    FlexBoxChild(
                      width: BoxSize.fixed(300),
                      height: BoxSize.fixed(40),
                      child: Container(
                        key: Key('child_$index'),
                        color: index.isEven ? Colors.red.shade100 : Colors.blue.shade100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Check that multiple children are rendered
      expect(find.byKey(Key('child_0')), findsOneWidget);
      expect(find.byKey(Key('child_10')), findsOneWidget);
      expect(find.byKey(Key('child_20')), findsOneWidget);
    });

    testWidgets('Extremely small dimensions work correctly', (WidgetTester tester) async {
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
                    width: BoxSize.fixed(1),
                    height: BoxSize.fixed(1),
                    child: Container(key: Key('tinyChild'), color: Colors.red),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(0.5),
                    height: BoxSize.fixed(0.5),
                    child: Container(key: Key('subPixelChild'), color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('tinyChild')), findsOneWidget);
      expect(find.byKey(Key('subPixelChild')), findsOneWidget);
      
      final tinySize = tester.getSize(find.byKey(Key('tinyChild')));
      final subPixelSize = tester.getSize(find.byKey(Key('subPixelChild')));
      
      expect(tinySize.width, equals(1.0));
      expect(tinySize.height, equals(1.0));
      expect(subPixelSize.width, equals(0.5));
      expect(subPixelSize.height, equals(0.5));
    });

    testWidgets('Extremely large dimensions work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(5000),
                      height: BoxSize.fixed(3000),
                      child: Container(key: Key('largeChild'), color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('largeChild')), findsOneWidget);
      
      final largeSize = tester.getSize(find.byKey(Key('largeChild')));
      expect(largeSize.width, equals(5000.0));
      expect(largeSize.height, equals(3000.0));
    });

    testWidgets('Negative positioning values work correctly', (WidgetTester tester) async {
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
                    top: BoxPosition.fixed(-50),
                    left: BoxPosition.fixed(-30),
                    width: BoxSize.fixed(200),
                    height: BoxSize.fixed(150),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(key: Key('negativeChild'), color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('negativeChild')), findsOneWidget);
      
      final childPosition = tester.getTopLeft(find.byKey(Key('negativeChild')));
      expect(childPosition.dx, equals(-30.0));
      expect(childPosition.dy, equals(-50.0));
    });

    testWidgets('Positioning beyond container bounds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: FlexBox(
                    direction: Axis.vertical,
                    children: [
                      FlexBoxChild(
                        top: BoxPosition.fixed(500), // Beyond container height
                        left: BoxPosition.fixed(600), // Beyond container width
                        width: BoxSize.fixed(100),
                        height: BoxSize.fixed(80),
                        horizontalPosition: BoxPositionType.relative,
                        verticalPosition: BoxPositionType.relative,
                        child: Container(key: Key('beyondBoundsChild'), color: Colors.purple),
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
      
      expect(find.byKey(Key('beyondBoundsChild')), findsOneWidget);
      
      final childPosition = tester.getTopLeft(find.byKey(Key('beyondBoundsChild')));
      expect(childPosition.dx, equals(600.0));
      expect(childPosition.dy, equals(500.0));
    });

    testWidgets('FlexBox with complex nested structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(400),
                    height: BoxSize.fixed(200),
                    child: FlexBox(
                      direction: Axis.horizontal,
                      children: [
                        FlexBoxChild(
                          width: BoxSize.fixed(200),
                          height: BoxSize.fixed(100),
                          child: Container(key: Key('nestedChild1'), color: Colors.red),
                        ),
                        FlexBoxChild(
                          width: BoxSize.fixed(200),
                          height: BoxSize.fixed(100),
                          child: Container(key: Key('nestedChild2'), color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(400),
                    height: BoxSize.fixed(200),
                    child: FlexBox(
                      direction: Axis.vertical,
                      children: [
                        FlexBoxChild(
                          width: BoxSize.fixed(100),
                          height: BoxSize.fixed(100),
                          child: Container(key: Key('nestedChild3'), color: Colors.green),
                        ),
                        FlexBoxChild(
                          width: BoxSize.fixed(100),
                          height: BoxSize.fixed(100),
                          child: Container(key: Key('nestedChild4'), color: Colors.yellow),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('nestedChild1')), findsOneWidget);
      expect(find.byKey(Key('nestedChild2')), findsOneWidget);
      expect(find.byKey(Key('nestedChild3')), findsOneWidget);
      expect(find.byKey(Key('nestedChild4')), findsOneWidget);
    });

    testWidgets('zOrder property affects rendering order', (WidgetTester tester) async {
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
                    left: BoxPosition.fixed(50),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(100),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    zOrder: 1,
                    child: Container(key: Key('bottomLayer'), color: Colors.red),
                  ),
                  FlexBoxChild(
                    top: BoxPosition.fixed(75),
                    left: BoxPosition.fixed(75),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(100),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    zOrder: 2,
                    child: Container(key: Key('topLayer'), color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('bottomLayer')), findsOneWidget);
      expect(find.byKey(Key('topLayer')), findsOneWidget);
      
      // Both widgets should be visible but overlapping
      final bottomPosition = tester.getTopLeft(find.byKey(Key('bottomLayer')));
      final topPosition = tester.getTopLeft(find.byKey(Key('topLayer')));
      
      expect(bottomPosition.dx, equals(50.0));
      expect(bottomPosition.dy, equals(50.0));
      expect(topPosition.dx, equals(75.0));
      expect(topPosition.dy, equals(75.0));
    });

    testWidgets('Flex positioning with zero flex value', (WidgetTester tester) async {
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
                    left: BoxPosition.flex(0),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    child: Container(key: Key('zeroFlexChild'), color: Colors.cyan),
                  ),
                  FlexBoxChild(
                    left: BoxPosition.flex(1),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    child: Container(key: Key('oneFlexChild'), color: Colors.pinkAccent),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('zeroFlexChild')), findsOneWidget);
      expect(find.byKey(Key('oneFlexChild')), findsOneWidget);
    });

    testWidgets('Ratio sizing with extreme ratios', (WidgetTester tester) async {
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
                    width: BoxSize.ratio(0.01), // Very small ratio
                    height: BoxSize.fixed(50),
                    child: Container(key: Key('smallRatioChild'), color: Colors.pink),
                  ),
                  FlexBoxChild(
                    width: BoxSize.ratio(10.0), // Large ratio
                    height: BoxSize.fixed(50),
                    child: Container(key: Key('largeRatioChild'), color: Colors.brown),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('smallRatioChild')), findsOneWidget);
      expect(find.byKey(Key('largeRatioChild')), findsOneWidget);
      
      final smallSize = tester.getSize(find.byKey(Key('smallRatioChild')));
      final largeSize = tester.getSize(find.byKey(Key('largeRatioChild')));
      
      // Small ratio should result in very small width
      expect(smallSize.width, lessThan(10.0));
      // Large ratio should result in large width
      expect(largeSize.width, greaterThan(100.0));
    });

    testWidgets('Unconstrained sizing in tight constraints', (WidgetTester tester) async {
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
                    height: BoxSize.unconstrained(),
                    child: Container(
                      key: Key('unconstrainedChild'),
                      width: 250,
                      height: 180,
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
      
      expect(find.byKey(Key('unconstrainedChild')), findsOneWidget);
      
      final childSize = tester.getSize(find.byKey(Key('unconstrainedChild')));
      expect(childSize.width, equals(250.0));
      expect(childSize.height, equals(180.0));
    });

    testWidgets('Mixed positioning and sizing edge cases', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  // Zero-sized with positioning
                  FlexBoxChild(
                    top: BoxPosition.fixed(10),
                    left: BoxPosition.fixed(20),
                    width: BoxSize.fixed(0),
                    height: BoxSize.fixed(0),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(key: Key('zeroSizedPositioned'), color: Colors.red),
                  ),
                  // Very large with negative positioning
                  FlexBoxChild(
                    top: BoxPosition.fixed(-100),
                    left: BoxPosition.fixed(-50),
                    width: BoxSize.fixed(1000),
                    height: BoxSize.fixed(800),
                    horizontalPosition: BoxPositionType.relative,
                    verticalPosition: BoxPositionType.relative,
                    child: Container(key: Key('largeNegativePositioned'), color: Colors.blue.withOpacity(0.3)),
                  ),
                  // Flex with extreme values
                  FlexBoxChild(
                    width: BoxSize.flex(100),
                    height: BoxSize.flex(0.001),
                    child: Container(key: Key('extremeFlexChild'), color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('zeroSizedPositioned')), findsOneWidget);
      expect(find.byKey(Key('largeNegativePositioned')), findsOneWidget);
      expect(find.byKey(Key('extremeFlexChild')), findsOneWidget);
    });

    testWidgets('Intrinsic sizing behavior', (WidgetTester tester) async {
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
                      'Intrinsic Text Content',
                      key: Key('intrinsicChild'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.intrinsic(min: 100, max: 200),
                    height: BoxSize.intrinsic(min: 50, max: 150),
                    child: Text(
                      'Constrained Intrinsic Content',
                      key: Key('constrainedIntrinsicChild'),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byKey(Key('intrinsicChild')), findsOneWidget);
      expect(find.byKey(Key('constrainedIntrinsicChild')), findsOneWidget);
      
      final intrinsicSize = tester.getSize(find.byKey(Key('intrinsicChild')));
      final constrainedSize = tester.getSize(find.byKey(Key('constrainedIntrinsicChild')));
      
      // Intrinsic sizing should fit content
      expect(intrinsicSize.width, greaterThan(0));
      expect(intrinsicSize.height, greaterThan(0));
      
      // Constrained intrinsic should respect min/max bounds
      expect(constrainedSize.width, greaterThanOrEqualTo(100));
      expect(constrainedSize.width, lessThanOrEqualTo(200));
      expect(constrainedSize.height, greaterThanOrEqualTo(50));
      expect(constrainedSize.height, lessThanOrEqualTo(150));
    });
  });
}
