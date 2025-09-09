import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  group('FlexBox Intrinsic Computation Tests', () {
    testWidgets('Intrinsic widget wrapping FlexBox with RatioSize children', (
      WidgetTester tester,
    ) async {
      // Test the specific scenario: Intrinsic(FlexBox(FlexBoxChild(size: RatioSize)))
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // IntrinsicWidth wrapping FlexBox with RatioSize children
                  IntrinsicWidth(
                    child: FlexBox(
                      direction: Axis.horizontal,
                      children: [
                        FlexBoxChild(
                          width: BoxSize.fixed(100),
                          height: BoxSize.fixed(50),
                          child: Container(
                            key: Key('fixed1'),
                            color: Colors.red,
                          ),
                        ),
                        FlexBoxChild(
                          width: BoxSize.ratio(
                            2.0,
                          ), // width = height * 2.0 = 50 * 2.0 = 100
                          height: BoxSize.fixed(50),
                          child: Container(
                            key: Key('ratioWidth'),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // IntrinsicHeight wrapping FlexBox with RatioSize children
                  IntrinsicHeight(
                    child: FlexBox(
                      direction: Axis.vertical,
                      children: [
                        FlexBoxChild(
                          width: BoxSize.fixed(80),
                          height: BoxSize.fixed(40),
                          child: Container(
                            key: Key('fixed2'),
                            color: Colors.green,
                          ),
                        ),
                        FlexBoxChild(
                          width: BoxSize.fixed(80),
                          height: BoxSize.ratio(
                            1.5,
                          ), // height = width * 1.5 = 80 * 1.5 = 120
                          child: Container(
                            key: Key('ratioHeight'),
                            color: Colors.orange,
                          ),
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

      // Test that intrinsic sizing works correctly with RatioSize children

      // For IntrinsicWidth scenario:
      // The FlexBox should size itself to accommodate its content
      // Expected width: 100 (fixed) + 100 (ratio: 50 * 2.0) = 200
      final ratioWidthChild = tester.getSize(find.byKey(Key('ratioWidth')));
      expect(
        ratioWidthChild.width,
        equals(100.0),
        reason: 'Ratio width child should be 50 * 2.0 = 100',
      );
      expect(
        ratioWidthChild.height,
        equals(50.0),
        reason: 'Height should be fixed at 50',
      );

      // For IntrinsicHeight scenario:
      // The FlexBox should size itself to accommodate its content
      // Expected height: max(40 (fixed), 120 (ratio: 80 * 1.5)) = 120
      final ratioHeightChild = tester.getSize(find.byKey(Key('ratioHeight')));
      expect(
        ratioHeightChild.width,
        equals(80.0),
        reason: 'Width should be fixed at 80',
      );
      expect(
        ratioHeightChild.height,
        equals(120.0),
        reason: 'Ratio height child should be 80 * 1.5 = 120',
      );
    });

    testWidgets('FlexBox intrinsic computation with FixedSize children', (
      WidgetTester tester,
    ) async {
      late FlexBox flexBox;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                flexBox = FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.red),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(150),
                      height: BoxSize.fixed(80),
                      child: Container(color: Colors.blue),
                    ),
                  ],
                );
                return flexBox;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the RenderBox for the FlexBox
      final RenderBox renderBox = tester.renderObject(find.byWidget(flexBox));

      // Test intrinsic width computation (cross-axis for horizontal FlexBox)
      // For horizontal FlexBox, intrinsic width should be max of children widths
      final minIntrinsicWidth = renderBox.getMinIntrinsicWidth(double.infinity);
      final maxIntrinsicWidth = renderBox.getMaxIntrinsicWidth(double.infinity);

      print('Min intrinsic width: $minIntrinsicWidth');
      print('Max intrinsic width: $maxIntrinsicWidth');

      // Test intrinsic height computation (main-axis for horizontal FlexBox)
      // For horizontal FlexBox, intrinsic height should be sum of children heights
      final minIntrinsicHeight = renderBox.getMinIntrinsicHeight(
        double.infinity,
      );
      final maxIntrinsicHeight = renderBox.getMaxIntrinsicHeight(
        double.infinity,
      );

      print('Min intrinsic height: $minIntrinsicHeight');
      print('Max intrinsic height: $maxIntrinsicHeight');

      // For horizontal FlexBox with fixed-size children:
      // Width (main-axis) should be sum of children widths: 100 + 150 = 250
      // Height (cross-axis) should be max of children heights: max(50, 80) = 80

      expect(
        minIntrinsicWidth,
        equals(250.0),
        reason: 'Min intrinsic width should be sum of children',
      );
      expect(
        maxIntrinsicWidth,
        equals(250.0),
        reason: 'Max intrinsic width should be sum of children',
      );
      expect(
        minIntrinsicHeight,
        equals(80.0),
        reason: 'Min intrinsic height should be max of children',
      );
      expect(
        maxIntrinsicHeight,
        equals(80.0),
        reason: 'Max intrinsic height should be max of children',
      );
    });

    testWidgets('FlexBox intrinsic computation with vertical direction', (
      WidgetTester tester,
    ) async {
      late FlexBox flexBox;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                flexBox = FlexBox(
                  direction: Axis.vertical,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.red),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(150),
                      height: BoxSize.fixed(80),
                      child: Container(color: Colors.blue),
                    ),
                  ],
                );
                return flexBox;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderBox renderBox = tester.renderObject(find.byWidget(flexBox));

      final minIntrinsicWidth = renderBox.getMinIntrinsicWidth(double.infinity);
      final maxIntrinsicWidth = renderBox.getMaxIntrinsicWidth(double.infinity);
      final minIntrinsicHeight = renderBox.getMinIntrinsicHeight(
        double.infinity,
      );
      final maxIntrinsicHeight = renderBox.getMaxIntrinsicHeight(
        double.infinity,
      );

      print('Vertical - Min intrinsic width: $minIntrinsicWidth');
      print('Vertical - Max intrinsic width: $maxIntrinsicWidth');
      print('Vertical - Min intrinsic height: $minIntrinsicHeight');
      print('Vertical - Max intrinsic height: $maxIntrinsicHeight');

      // For vertical FlexBox with fixed-size children:
      // Width (cross-axis) should be max of children widths: max(100, 150) = 150
      // Height (main-axis) should be sum of children heights: 50 + 80 = 130

      expect(
        minIntrinsicWidth,
        equals(150.0),
        reason: 'Min intrinsic width should be max of children',
      );
      expect(
        maxIntrinsicWidth,
        equals(150.0),
        reason: 'Max intrinsic width should be max of children',
      );
      expect(
        minIntrinsicHeight,
        equals(130.0),
        reason: 'Min intrinsic height should be sum of children',
      );
      expect(
        maxIntrinsicHeight,
        equals(130.0),
        reason: 'Max intrinsic height should be sum of children',
      );
    });

    testWidgets('FlexBox intrinsic computation with UnconstrainedSize children', (
      WidgetTester tester,
    ) async {
      late FlexBox flexBox;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                flexBox = FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.unconstrained(),
                      height: BoxSize.unconstrained(),
                      child: Container(
                        width: 120,
                        height: 60,
                        color: Colors.green,
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.red),
                    ),
                  ],
                );
                return flexBox;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderBox renderBox = tester.renderObject(find.byWidget(flexBox));

      final minIntrinsicWidth = renderBox.getMinIntrinsicWidth(double.infinity);
      final maxIntrinsicWidth = renderBox.getMaxIntrinsicWidth(double.infinity);
      final minIntrinsicHeight = renderBox.getMinIntrinsicHeight(
        double.infinity,
      );
      final maxIntrinsicHeight = renderBox.getMaxIntrinsicHeight(
        double.infinity,
      );

      print('Unconstrained - Min intrinsic width: $minIntrinsicWidth');
      print('Unconstrained - Max intrinsic width: $maxIntrinsicWidth');
      print('Unconstrained - Min intrinsic height: $minIntrinsicHeight');
      print('Unconstrained - Max intrinsic height: $maxIntrinsicHeight');

      // This test will reveal if the implementation correctly handles UnconstrainedSize
      // Currently the implementation returns 0.0 for UnconstrainedSize, which might be wrong
    });

    testWidgets('FlexBox intrinsic computation with IntrinsicSize children', (
      WidgetTester tester,
    ) async {
      late FlexBox flexBox;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                flexBox = FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.intrinsic(),
                      height: BoxSize.intrinsic(),
                      child: Text('Short', style: TextStyle(fontSize: 16)),
                    ),
                    FlexBoxChild(
                      width: BoxSize.intrinsic(),
                      height: BoxSize.intrinsic(),
                      child: Text(
                        'Much longer text',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                );
                return flexBox;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderBox renderBox = tester.renderObject(find.byWidget(flexBox));

      final minIntrinsicWidth = renderBox.getMinIntrinsicWidth(double.infinity);
      final maxIntrinsicWidth = renderBox.getMaxIntrinsicWidth(double.infinity);
      final minIntrinsicHeight = renderBox.getMinIntrinsicHeight(
        double.infinity,
      );
      final maxIntrinsicHeight = renderBox.getMaxIntrinsicHeight(
        double.infinity,
      );

      print('Intrinsic - Min intrinsic width: $minIntrinsicWidth');
      print('Intrinsic - Max intrinsic width: $maxIntrinsicWidth');
      print('Intrinsic - Min intrinsic height: $minIntrinsicHeight');
      print('Intrinsic - Max intrinsic height: $maxIntrinsicHeight');

      // These should be computed based on the actual text sizes
      expect(
        minIntrinsicWidth,
        greaterThan(0),
        reason: 'Should compute actual intrinsic width',
      );
      expect(
        maxIntrinsicWidth,
        greaterThan(0),
        reason: 'Should compute actual intrinsic width',
      );
      expect(
        minIntrinsicHeight,
        greaterThan(0),
        reason: 'Should compute actual intrinsic height',
      );
      expect(
        maxIntrinsicHeight,
        greaterThan(0),
        reason: 'Should compute actual intrinsic height',
      );
    });

    testWidgets('FlexBox intrinsic computation with FlexSize children', (
      WidgetTester tester,
    ) async {
      late FlexBox flexBox;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                flexBox = FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.flex(1.0),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.purple),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(60),
                      child: Container(color: Colors.orange),
                    ),
                  ],
                );
                return flexBox;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderBox renderBox = tester.renderObject(find.byWidget(flexBox));

      final minIntrinsicWidth = renderBox.getMinIntrinsicWidth(double.infinity);
      final maxIntrinsicWidth = renderBox.getMaxIntrinsicWidth(double.infinity);
      final minIntrinsicHeight = renderBox.getMinIntrinsicHeight(
        double.infinity,
      );
      final maxIntrinsicHeight = renderBox.getMaxIntrinsicHeight(
        double.infinity,
      );

      print('Flex - Min intrinsic width: $minIntrinsicWidth');
      print('Flex - Max intrinsic width: $maxIntrinsicWidth');
      print('Flex - Min intrinsic height: $minIntrinsicHeight');
      print('Flex - Max intrinsic height: $maxIntrinsicHeight');

      // FlexSize children are skipped in intrinsic computation (continue statement)
      // So only the fixed child should contribute: width=100, height=60
      expect(
        minIntrinsicWidth,
        equals(100.0),
        reason: 'Should only count non-flex children',
      );
      expect(
        maxIntrinsicWidth,
        equals(100.0),
        reason: 'Should only count non-flex children',
      );
      expect(
        minIntrinsicHeight,
        equals(60.0),
        reason: 'Should only count non-flex children',
      );
      expect(
        maxIntrinsicHeight,
        equals(60.0),
        reason: 'Should only count non-flex children',
      );
    });

    testWidgets('FlexBox intrinsic computation with spacing', (
      WidgetTester tester,
    ) async {
      late FlexBox flexBox;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                flexBox = FlexBox(
                  direction: Axis.horizontal,
                  spacing: 10.0,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.red),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.blue),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.green),
                    ),
                  ],
                );
                return flexBox;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final RenderBox renderBox = tester.renderObject(find.byWidget(flexBox));

      final minIntrinsicWidth = renderBox.getMinIntrinsicWidth(double.infinity);
      final maxIntrinsicWidth = renderBox.getMaxIntrinsicWidth(double.infinity);
      final minIntrinsicHeight = renderBox.getMinIntrinsicHeight(
        double.infinity,
      );
      final maxIntrinsicHeight = renderBox.getMaxIntrinsicHeight(
        double.infinity,
      );

      print('Spacing - Min intrinsic width: $minIntrinsicWidth');
      print('Spacing - Max intrinsic width: $maxIntrinsicWidth');
      print('Spacing - Min intrinsic height: $minIntrinsicHeight');
      print('Spacing - Max intrinsic height: $maxIntrinsicHeight');

      // For horizontal FlexBox, height is cross-axis (should be max of children)
      // Width is main-axis (should be sum + spacing)
      // Width: 100 + 100 + 100 + 10 + 10 = 320 (3 children, 2 spacings)
      // Height: max(50, 50, 50) = 50
      expect(
        minIntrinsicWidth,
        equals(320.0),
        reason: 'Main-axis should include spacing: 100+100+100+10+10',
      );
      expect(
        maxIntrinsicWidth,
        equals(320.0),
        reason: 'Main-axis should include spacing: 100+100+100+10+10',
      );
      expect(
        minIntrinsicHeight,
        equals(50.0),
        reason: 'Cross-axis should be max of children heights',
      );
      expect(
        maxIntrinsicHeight,
        equals(50.0),
        reason: 'Cross-axis should be max of children heights',
      );
    });

    testWidgets('FlexBox intrinsic computation with RatioSize children', (
      WidgetTester tester,
    ) async {
      late FlexBox flexBox;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                flexBox = FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    FlexBoxChild(
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      child: Container(color: Colors.red),
                    ),
                    FlexBoxChild(
                      width: BoxSize.ratio(
                        2.0,
                      ), // width = height * 2.0 = 60 * 2.0 = 120
                      height: BoxSize.fixed(60),
                      child: Container(color: Colors.blue),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(80),
                      height: BoxSize.ratio(
                        1.5,
                      ), // height = width * 1.5 = 80 * 1.5 = 120
                      child: Container(color: Colors.green),
                    ),
                  ],
                );
                return flexBox;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the RenderBox for the FlexBox
      final RenderBox renderBox = tester.renderObject(find.byWidget(flexBox));

      // Test intrinsic width computation (main-axis for horizontal FlexBox)
      // For horizontal FlexBox, width should be sum of children widths
      // Test with constrained cross-axis (height = 60) so ratio can be computed
      final minIntrinsicWidthConstrained = renderBox.getMinIntrinsicWidth(60.0);
      final maxIntrinsicWidthConstrained = renderBox.getMaxIntrinsicWidth(60.0);

      // Test with unconstrained cross-axis (height = infinity) - ratio children will be skipped
      final minIntrinsicWidthUnconstrained = renderBox.getMinIntrinsicWidth(
        double.infinity,
      );
      final maxIntrinsicWidthUnconstrained = renderBox.getMaxIntrinsicWidth(
        double.infinity,
      );

      // Test intrinsic height computation (cross-axis for horizontal FlexBox)
      // Test with constrained main-axis (width = 100) so ratio can be computed
      final minIntrinsicHeightConstrained = renderBox.getMinIntrinsicHeight(
        100.0,
      );
      final maxIntrinsicHeightConstrained = renderBox.getMaxIntrinsicHeight(
        100.0,
      );

      print(
        'RatioSize - Min intrinsic width (constrained): $minIntrinsicWidthConstrained',
      );
      print(
        'RatioSize - Max intrinsic width (constrained): $maxIntrinsicWidthConstrained',
      );
      print(
        'RatioSize - Min intrinsic width (unconstrained): $minIntrinsicWidthUnconstrained',
      );
      print(
        'RatioSize - Max intrinsic width (unconstrained): $maxIntrinsicWidthUnconstrained',
      );
      print(
        'RatioSize - Min intrinsic height (constrained): $minIntrinsicHeightConstrained',
      );
      print(
        'RatioSize - Max intrinsic height (constrained): $maxIntrinsicHeightConstrained',
      );

      // For horizontal FlexBox with RatioSize children and constrained cross-axis (height=60):
      // Width (main-axis): sum of all children widths
      // - Child 1: fixed width 100
      // - Child 2: ratio width = height * 2.0 = 60 * 2.0 = 120
      // - Child 3: fixed width 80
      // Total width: 100 + 120 + 80 = 300

      expect(
        minIntrinsicWidthConstrained,
        equals(300.0),
        reason:
            'Constrained: Main-axis should be sum including ratio children: 100+120+80',
      );
      expect(
        maxIntrinsicWidthConstrained,
        equals(300.0),
        reason:
            'Constrained: Main-axis should be sum including ratio children: 100+120+80',
      );

      // For unconstrained cross-axis (height=infinity), ratio children depending on cross-axis are skipped:
      // - Child 1: fixed width 100
      // - Child 2: ratio width = skipped (0) because cross-axis is infinite
      // - Child 3: fixed width 80
      // Total width: 100 + 0 + 80 = 180

      expect(
        minIntrinsicWidthUnconstrained,
        equals(180.0),
        reason:
            'Unconstrained: Ratio children depending on infinite cross-axis should be skipped: 100+0+80',
      );
      expect(
        maxIntrinsicWidthUnconstrained,
        equals(180.0),
        reason:
            'Unconstrained: Ratio children depending on infinite cross-axis should be skipped: 100+0+80',
      );

      // For horizontal FlexBox with RatioSize children and constrained main-axis (width=100):
      // Height (cross-axis): max of all children heights
      // - Child 1: fixed height 50
      // - Child 2: fixed height 60
      // - Child 3: ratio height = width * 1.5 = 100 * 1.5 = 150
      // Max height: max(50, 60, 150) = 150

      expect(
        minIntrinsicHeightConstrained,
        equals(150.0),
        reason:
            'Constrained: Cross-axis should be max including ratio children: max(50,60,150)',
      );
      expect(
        maxIntrinsicHeightConstrained,
        equals(150.0),
        reason:
            'Constrained: Cross-axis should be max including ratio children: max(50,60,150)',
      );
    });
  });
}
