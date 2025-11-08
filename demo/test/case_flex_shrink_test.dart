import 'package:demo/cases/case_flex_shrink.dart';
import 'helper.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

void main() {
  TestCase testCase = CaseFlexShrink();
  testWidgets(testCase.name, (WidgetTester tester) async {
    await tester.pumpWidget(testCase.buildTest());
    await tester.pumpAndSettle();
    // perform the test
    tester.expectSize(key0, Size(300.0, 200.0));
    tester.expectRect(key1, Offset(0.0, 0.0) & Size(100.0, 100.0));
    tester.expectRect(key2, Offset(100.0, 0.0) & Size(80.0, 100.0));
    tester.expectRect(key3, Offset(180.0, 0.0) & Size(120.0, 100.0));
  });
}
