import 'package:demo/cases/case_scrollable_absolute.dart';
import 'helper.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';

void main() {
  TestCase testCase = CaseScrollableAbsolute();
  testWidgets(testCase.name, (WidgetTester tester) async {
    await tester.pumpWidget(testCase.buildTest());
    await tester.pumpAndSettle();
    // perform the test
    tester.expectSize(key0, Size(500.0, 500.0));
    tester.expectRect(key1, Offset(0.0, 200.0) & Size(100.0, 100.0));
    tester.expectRect(key2, Offset(100.0, 100.0) & Size(100.0, 300.0));
    tester.expectRect(key3, Offset(200.0, 150.0) & Size(100.0, 200.0));
    tester.expectRect(key4, Offset(300.0, 200.0) & Size(100.0, 100.0));
    tester.expectRect(key5, Offset(400.0, 150.0) & Size(100.0, 200.0));
    tester.expectRect(key6, Offset(500.0, 125.0) & Size(100.0, 250.0));
    tester.expectRect(key7, Offset(600.0, 175.0) & Size(100.0, 150.0));
    tester.expectRect(key8, Offset(150.0, 50.0) & Size(200.0, 400.0));
    tester.expectRect(key9, Offset(50.0, 50.0) & Size(100.0, 100.0));
    tester.expectRect(key10, Offset(350.0, 350.0) & Size(100.0, 100.0));
    // scroll to the end and verify
    await tester.drag(find.byKey(key0), Offset(-400.0, -400.0));
    // note that although we drag by -400, -400,
    // the actual scroll offset is smaller due to the content size
    await tester.pumpAndSettle();
    tester.expectRect(key1, Offset(-200.0, 200.0) & Size(100.0, 100.0));
    tester.expectRect(key2, Offset(-100.0, 100.0) & Size(100.0, 300.0));
    tester.expectRect(key3, Offset(0.0, 150.0) & Size(100.0, 200.0));
    tester.expectRect(key4, Offset(100.0, 200.0) & Size(100.0, 100.0));
    tester.expectRect(key5, Offset(200.0, 150.0) & Size(100.0, 200.0));
    tester.expectRect(key6, Offset(300.0, 125.0) & Size(100.0, 250.0));
    tester.expectRect(key7, Offset(400.0, 175.0) & Size(100.0, 150.0));
    tester.expectRect(key8, Offset(-50.0, 50.0) & Size(200.0, 400.0));
    tester.expectRect(key9, Offset(-150.0, 50.0) & Size(100.0, 100.0));
    // key10 is not affected by scroll, it stays at the same position
    tester.expectRect(key10, Offset(350.0, 350.0) & Size(100.0, 100.0));
  });
}
