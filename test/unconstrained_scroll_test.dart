import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  testWidgets('Unconstrained child with fixed siblings does not overflow container', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 100,
            child: FlexBox(
              direction: Axis.horizontal,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(80),
                  height: BoxSize.fixed(100),
                  child: Container(key: Key('fixed1'), color: Colors.red),
                ),
                FlexBoxChild(
                  width: BoxSize.unconstrained(),
                  height: BoxSize.fixed(100),
                  child: Container(
                    key: Key('unconstrained'),
                    width: 200,
                    color: Colors.green,
                  ),
                ),
                FlexBoxChild(
                  width: BoxSize.fixed(40),
                  height: BoxSize.fixed(100),
                  child: Container(key: Key('fixed2'), color: Colors.blue),
                ),
                // Anchor child to right: 0, relative to content
                FlexBoxChild(
                  right: BoxPosition.fixed(0),
                  width: BoxSize.fixed(20),
                  height: BoxSize.fixed(100),
                  horizontalPosition: BoxPositionType.relativeContent,
                  child: Container(
                    key: Key('anchoredRight'),
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

    final flexboxFinder = find.byType(FlexBox);
    final flexboxRect = tester.getRect(flexboxFinder);
    final fixed1Rect = tester.getRect(find.byKey(Key('fixed1')));
    final unconstrainedRect = tester.getRect(find.byKey(Key('unconstrained')));
    final fixed2Rect = tester.getRect(find.byKey(Key('fixed2')));
    final anchoredRightRect = tester.getRect(find.byKey(Key('anchoredRight')));

    // The right edge of the last child should not exceed the right edge of the FlexBox
    final rightmost = [
      fixed1Rect,
      unconstrainedRect,
      fixed2Rect,
    ].map((r) => r.right).reduce((a, b) => a > b ? a : b);
    expect(rightmost, lessThanOrEqualTo(flexboxRect.right));
    // The left edge of the first child should not be less than the left edge of the FlexBox
    final leftmost = [
      fixed1Rect,
      unconstrainedRect,
      fixed2Rect,
    ].map((r) => r.left).reduce((a, b) => a < b ? a : b);
    expect(leftmost, greaterThanOrEqualTo(flexboxRect.left));

    // The anchored right child should be inside the visible area (right edge <= flexbox right)
    expect(anchoredRightRect.right, lessThanOrEqualTo(flexboxRect.right));
    expect(anchoredRightRect.left, greaterThanOrEqualTo(flexboxRect.left));
  });
}
