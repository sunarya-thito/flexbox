import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseRTLColumnReverse extends TestCase {
  @override
  String get name => 'Right-to-Left Column Reverse FlexBox';
  @override
  String get path => 'case_rtl_column_reverse.dart';
  @override
  Widget build() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.columnReverse,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
