import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseOverflowRow extends TestCase {
  @override
  String get name => 'Overflow in Row (No Wrap)';
  @override
  String get path => 'case_overflow_row.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 300,
      height: 200,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          wrap: FlexWrap.none,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
