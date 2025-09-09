import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  testWidgets('IntrinsicWidth test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IntrinsicWidth(
            child: FlexBox(
              direction: Axis.vertical,
              children: [
                FlexBoxChild(
                  width: BoxSize.fixed(150),
                  height: BoxSize.fixed(50),
                  child: Container(color: Colors.blue),
                ),
                FlexBoxChild(
                  width: BoxSize.fixed(200),
                  height: BoxSize.fixed(50),
                  child: Container(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Just check that it renders without infinite loop
    expect(find.byType(FlexBox), findsOneWidget);
  });
}
