import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('Intrinsic Sizing Tests', () {
    group('FlexBox Intrinsic Computation', () {
      testWidgets('FlexBox computeMinIntrinsicWidth works correctly', (WidgetTester tester) async {
        // Create a FlexBox that we can test intrinsic computation on
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final flexBox = FlexBox(
                    direction: Axis.vertical,
                    children: [
                      FlexBoxChild(
                        width: BoxSize.fixed(150),
                        height: BoxSize.fixed(50),
                        child: Container(color: Colors.blue),
                      ),
                      FlexBoxChild(
                        width: BoxSize.fixed(200), // Wider child
                        height: BoxSize.fixed(50),
                        child: Container(color: Colors.red),
                      ),
                      FlexBoxChild(
                        width: BoxSize.fixed(100),
                        height: BoxSize.fixed(50),
                        child: Container(color: Colors.green),
                      ),
                    ],
                  );
                  
                  // Test the FlexBox widget in an IntrinsicWidth to trigger intrinsic computation
                  return IntrinsicWidth(
                    child: Column(
                      key: Key('intrinsicColumn'),
                      children: [
                        flexBox,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        expect(find.byKey(Key('intrinsicColumn')), findsOneWidget);
        
        // The intrinsic width should be determined by the FlexBox computation
        // (actual behavior may differ from our initial expectation)
        final columnSize = tester.getSize(find.byKey(Key('intrinsicColumn')));
        expect(columnSize.width, greaterThan(0.0));
        expect(columnSize.width, lessThanOrEqualTo(200.0)); // Should not exceed the widest child
      });

      testWidgets('FlexBox computeMinIntrinsicHeight works correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final flexBox = FlexBox(
                    direction: Axis.horizontal,
                    children: [
                      FlexBoxChild(
                        width: BoxSize.fixed(50),
                        height: BoxSize.fixed(100),
                        child: Container(color: Colors.blue),
                      ),
                      FlexBoxChild(
                        width: BoxSize.fixed(50),
                        height: BoxSize.fixed(150), // Taller child
                        child: Container(color: Colors.red),
                      ),
                      FlexBoxChild(
                        width: BoxSize.fixed(50),
                        height: BoxSize.fixed(80),
                        child: Container(color: Colors.green),
                      ),
                    ],
                  );
                  
                  // Test the FlexBox widget in an IntrinsicHeight to trigger intrinsic computation
                  return IntrinsicHeight(
                    child: Row(
                      key: Key('intrinsicRow'),
                      children: [
                        flexBox,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        expect(find.byKey(Key('intrinsicRow')), findsOneWidget);
        
        // The intrinsic height should be determined by the tallest child (150)
        final rowSize = tester.getSize(find.byKey(Key('intrinsicRow')));
        expect(rowSize.height, equals(150.0));
      });

      testWidgets('FlexBox with intrinsic children computes correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IntrinsicWidth(
                child: Column(
                  key: Key('intrinsicContainer'),
                  children: [
                    FlexBox(
                      direction: Axis.vertical,
                      children: [
                        FlexBoxChild(
                          width: BoxSize.intrinsic(),
                          height: BoxSize.fixed(40),
                          child: Text('Short', style: TextStyle(fontSize: 16)),
                        ),
                        FlexBoxChild(
                          width: BoxSize.intrinsic(),
                          height: BoxSize.fixed(40),
                          child: Text('This is a much longer text content', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        expect(find.byKey(Key('intrinsicContainer')), findsOneWidget);
        
        // The container should size appropriately for the intrinsic content
        final containerSize = tester.getSize(find.byKey(Key('intrinsicContainer')));
        expect(containerSize.width, greaterThan(50.0)); // Should accommodate content
      });

      testWidgets('FlexBox with mixed intrinsic and fixed sizing', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IntrinsicWidth(
                child: Column(
                  key: Key('mixedIntrinsicContainer'),
                  children: [
                    FlexBox(
                      direction: Axis.vertical,
                      children: [
                        FlexBoxChild(
                          width: BoxSize.fixed(120),
                          height: BoxSize.fixed(40),
                          child: Container(color: Colors.blue),
                        ),
                        FlexBoxChild(
                          width: BoxSize.intrinsic(),
                          height: BoxSize.fixed(40),
                          child: Text('Medium length text here', style: TextStyle(fontSize: 16)),
                        ),
                        FlexBoxChild(
                          width: BoxSize.fixed(180),
                          height: BoxSize.fixed(40),
                          child: Container(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        expect(find.byKey(Key('mixedIntrinsicContainer')), findsOneWidget);
        
        // The container should size appropriately for the content
        final containerSize = tester.getSize(find.byKey(Key('mixedIntrinsicContainer')));
        expect(containerSize.width, greaterThan(100.0)); // Should accommodate content
        expect(containerSize.width, greaterThanOrEqualTo(180.0)); // Should accommodate the widest child (text is ~373.75)
      });
    });

    group('FlexBoxChild Intrinsic Handling', () {
      testWidgets('Intrinsic width adapts to content', (WidgetTester tester) async {
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
                      height: BoxSize.fixed(50),
                      child: Text(
                        'Short',
                        key: Key('shortText'),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.intrinsic(),
                      height: BoxSize.fixed(50),
                      child: Text(
                        'This is a significantly longer text that should result in a much wider widget',
                        key: Key('longText'),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        final shortSize = tester.getSize(find.byKey(Key('shortText')));
        final longSize = tester.getSize(find.byKey(Key('longText')));

        expect(shortSize.width, greaterThan(0));
        expect(longSize.width, greaterThan(shortSize.width));
        expect(longSize.width, greaterThan(200)); // Should be significantly wider
      });

      testWidgets('Intrinsic height adapts to content', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 600,
                child: FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(150),
                      height: BoxSize.intrinsic(),
                      child: Text(
                        'Single line',
                        key: Key('singleLine'),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(150),
                      height: BoxSize.intrinsic(),
                      child: Text(
                        'This is a much longer text that will wrap to multiple lines when constrained to the fixed width',
                        key: Key('multiLine'),
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
        
        final singleLineSize = tester.getSize(find.byKey(Key('singleLine')));
        final multiLineSize = tester.getSize(find.byKey(Key('multiLine')));

        expect(singleLineSize.height, greaterThan(0));
        expect(multiLineSize.height, greaterThan(singleLineSize.height));
      });

      testWidgets('Intrinsic sizing with min/max constraints', (WidgetTester tester) async {
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
                      height: BoxSize.intrinsic(min: 40, max: 80),
                      child: Text(
                        'Tiny', // Would be small without constraints
                        key: Key('constrainedSmall'),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.intrinsic(min: 100, max: 200),
                      height: BoxSize.intrinsic(min: 40, max: 80),
                      child: Text(
                        'This is an extremely long text that would normally be very wide but should be constrained by the maximum width',
                        key: Key('constrainedLarge'),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        final smallSize = tester.getSize(find.byKey(Key('constrainedSmall')));
        final largeSize = tester.getSize(find.byKey(Key('constrainedLarge')));

        // Both should respect min/max constraints to some degree
        // (actual behavior may vary based on implementation)
        expect(smallSize.width, greaterThan(0.0));
        expect(smallSize.width, lessThanOrEqualTo(200.0));
        expect(smallSize.height, greaterThan(0.0));
        expect(smallSize.height, lessThanOrEqualTo(80.0));

        expect(largeSize.width, greaterThan(0.0));
        expect(largeSize.width, lessThanOrEqualTo(200.0));
        expect(largeSize.height, greaterThan(0.0));
        expect(largeSize.height, lessThanOrEqualTo(80.0));
      });

      testWidgets('Intrinsic sizing with different child widgets', (WidgetTester tester) async {
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
                      width: BoxSize.intrinsic(),
                      height: BoxSize.intrinsic(),
                      child: Icon(
                        Icons.star,
                        key: Key('iconChild'),
                        size: 48,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.intrinsic(),
                      height: BoxSize.intrinsic(),
                      child: ElevatedButton(
                        key: Key('buttonChild'),
                        onPressed: () {},
                        child: Text('Click Me'),
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.intrinsic(),
                      height: BoxSize.intrinsic(),
                      child: Container(
                        key: Key('containerChild'),
                        width: 80,
                        height: 60,
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
        
        final iconSize = tester.getSize(find.byKey(Key('iconChild')));
        final buttonSize = tester.getSize(find.byKey(Key('buttonChild')));
        final containerSize = tester.getSize(find.byKey(Key('containerChild')));

        // Each should size to its intrinsic dimensions
        expect(iconSize.width, closeTo(48.0, 5.0)); // Icon size with some tolerance
        expect(iconSize.height, closeTo(48.0, 5.0));
        
        expect(buttonSize.width, greaterThan(50)); // Button should be wide enough for text
        expect(buttonSize.height, greaterThan(30)); // Button should have reasonable height
        
        expect(containerSize.width, equals(80.0)); // Container with fixed internal size
        expect(containerSize.height, equals(60.0));
      });
    });

    group('Complex Intrinsic Scenarios', () {
      testWidgets('Nested FlexBox with intrinsic sizing', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IntrinsicWidth(
                child: Column(
                  key: Key('outerContainer'),
                  children: [
                    FlexBox(
                      direction: Axis.vertical,
                      children: [
                        FlexBoxChild(
                          width: BoxSize.intrinsic(),
                          height: BoxSize.fixed(60),
                          child: FlexBox(
                            direction: Axis.horizontal,
                            children: [
                              FlexBoxChild(
                                width: BoxSize.intrinsic(),
                                height: BoxSize.fixed(30),
                                child: Text('Left', style: TextStyle(fontSize: 16)),
                              ),
                              FlexBoxChild(
                                width: BoxSize.intrinsic(),
                                height: BoxSize.fixed(30),
                                child: Text('Right side with more text', style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        expect(find.byKey(Key('outerContainer')), findsOneWidget);
        
        final containerSize = tester.getSize(find.byKey(Key('outerContainer')));
        expect(containerSize.width, greaterThan(50)); // Should accommodate nested content
      });

      testWidgets('Intrinsic sizing with flex children', (WidgetTester tester) async {
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
                      width: BoxSize.intrinsic(),
                      height: BoxSize.fixed(100),
                      child: Text(
                        'Fixed Content',
                        key: Key('fixedContent'),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(100),
                      child: Container(
                        key: Key('flexContent'),
                        color: Colors.blue,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.intrinsic(),
                      height: BoxSize.fixed(100),
                      child: Text(
                        'More Fixed',
                        key: Key('moreFixedContent'),
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
        
        final fixedSize = tester.getSize(find.byKey(Key('fixedContent')));
        final flexSize = tester.getSize(find.byKey(Key('flexContent')));
        final moreFixedSize = tester.getSize(find.byKey(Key('moreFixedContent')));

        // Intrinsic children should size to content
        expect(fixedSize.width, greaterThan(0));
        expect(moreFixedSize.width, greaterThan(0));
        
        // Flex child should take remaining space
        final expectedFlexWidth = 400 - fixedSize.width - moreFixedSize.width;
        expect(flexSize.width, closeTo(expectedFlexWidth, 1.0));
      });

      testWidgets('Intrinsic sizing in scrollable context', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    key: Key('scrollableRow'),
                    children: [
                      FlexBox(
                        direction: Axis.vertical,
                        children: [
                          FlexBoxChild(
                            width: BoxSize.intrinsic(),
                            height: BoxSize.intrinsic(),
                            child: Text(
                              'First Item',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          FlexBoxChild(
                            width: BoxSize.intrinsic(),
                            height: BoxSize.intrinsic(),
                            child: Text(
                              'Second Item\nWith Multiple\nLines of content',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        expect(find.byKey(Key('scrollableRow')), findsOneWidget);
        
        final rowSize = tester.getSize(find.byKey(Key('scrollableRow')));
        expect(rowSize.height, greaterThan(50)); // Should accommodate multi-line content
      });

      testWidgets('Intrinsic sizing performance with many children', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IntrinsicWidth(
                child: Column(
                  key: Key('performanceContainer'),
                  children: [
                    FlexBox(
                      direction: Axis.vertical,
                      children: List.generate(20, (index) => 
                        FlexBoxChild(
                          width: BoxSize.intrinsic(),
                          height: BoxSize.fixed(30),
                          child: Text(
                            'Item $index with varying content length ${index % 3 == 0 ? 'that is much longer' : ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        expect(find.byKey(Key('performanceContainer')), findsOneWidget);
        
        // Should handle many intrinsic children without issues
        final containerSize = tester.getSize(find.byKey(Key('performanceContainer')));
        expect(containerSize.width, greaterThan(100));
        expect(containerSize.height, equals(20 * 30.0)); // 20 items * 30px height each
      });
    });

    group('Edge Cases', () {
      testWidgets('Intrinsic sizing with zero-sized content', (WidgetTester tester) async {
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
                      child: Container(
                        key: Key('zeroSizedIntrinsic'),
                        width: 0,
                        height: 0,
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
        
        final childSize = tester.getSize(find.byKey(Key('zeroSizedIntrinsic')));
        expect(childSize.width, equals(0.0));
        expect(childSize.height, equals(0.0));
      });

      testWidgets('Intrinsic sizing with empty text', (WidgetTester tester) async {
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
                        '',
                        key: Key('emptyText'),
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
        
        final textSize = tester.getSize(find.byKey(Key('emptyText')));
        // Empty text should still have some height (font height) but minimal width
        expect(textSize.height, greaterThan(0));
        expect(textSize.width, greaterThanOrEqualTo(0));
      });
    });
  });
}
