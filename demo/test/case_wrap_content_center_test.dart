import 'package:demo/cases/case_wrap_content_center.dart';
import 'helper.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

void main() {
  TestCase testCase = CaseWrapContentCenter();
  testWidgets(testCase.name, (WidgetTester tester) async {
    await tester.pumpWidget(testCase.buildTest());
    await tester.pumpAndSettle();
    // perform the test
    tester.expectSize(key0, Size(300.0, 500.0));
    tester.expectRect(key1, Offset(0.0, 50.0) & Size(100.0, 100.0));
    tester.expectRect(key2, Offset(100.0, 50.0) & Size(100.0, 200.0));
    tester.expectRect(key3, Offset(200.0, 50.0) & Size(100.0, 150.0));
    tester.expectRect(key4, Offset(0.0, 250.0) & Size(150.0, 100.0));
    tester.expectRect(key5, Offset(150.0, 250.0) & Size(150.0, 200.0));
    
  });
}
