import 'package:demo/cases/case_scrollable.dart';
import 'helper.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

void main() {
  TestCase testCase = CaseScrollable();
  testWidgets(testCase.name, (WidgetTester tester) async {
    await tester.pumpWidget(testCase.buildTest());
    await tester.pumpAndSettle();
    // perform the test
    tester.expectSize(key0, Size(300.0, 150.0));
    tester.expectRect(key1, Offset(0.0, 100.0) & Size(100.0, 100.0));
    tester.expectRect(key2, Offset(100.0, 0.0) & Size(100.0, 300.0));
    tester.expectRect(key3, Offset(200.0, 50.0) & Size(100.0, 200.0));
    tester.expectRect(key4, Offset(300.0, 100.0) & Size(100.0, 100.0));
    tester.expectRect(key5, Offset(400.0, 50.0) & Size(100.0, 200.0));
    tester.expectRect(key6, Offset(500.0, 25.0) & Size(100.0, 250.0));
    tester.expectRect(key7, Offset(600.0, 75.0) & Size(100.0, 150.0));
    
  });
}
