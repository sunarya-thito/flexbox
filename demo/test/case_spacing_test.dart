import 'package:demo/cases/case_spacing.dart';
import 'helper.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

void main() {
  TestCase testCase = CaseSpacing();
  testWidgets(testCase.name, (WidgetTester tester) async {
    await tester.pumpWidget(testCase.buildTest());
    await tester.pumpAndSettle();
    // perform the test
    tester.expectSize(key0, Size(500.0, 180.0));
    tester.expectRect(key1, Offset(60.0, 20.0) & Size(100.0, 100.0));
    tester.expectRect(key2, Offset(210.0, 20.0) & Size(100.0, 100.0));
    tester.expectRect(key3, Offset(360.0, 20.0) & Size(100.0, 100.0));
  });
}
