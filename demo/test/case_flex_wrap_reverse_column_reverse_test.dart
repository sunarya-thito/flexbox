import 'package:demo/cases/case_flex_wrap_reverse_column_reverse.dart';
import 'helper.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

void main() {
  TestCase testCase = CaseFlexWrapReverseColumnReverse();
  testWidgets(testCase.name, (WidgetTester tester) async {
    await tester.pumpWidget(testCase.buildTest());
    await tester.pumpAndSettle();
    // perform the test
    tester.expectSize(key0, Size(350.0, 300.0));
    tester.expectRect(key1, Offset(100.0, 200.0) & Size(150.0, 100.0));
    tester.expectRect(key2, Offset(100.0, 100.0) & Size(150.0, 100.0));
    tester.expectRect(key3, Offset(100.0, 0.0) & Size(250.0, 100.0));
    tester.expectRect(key4, Offset(0.0, 200.0) & Size(100.0, 100.0));
  });
}
