import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseOverflowLargeContent extends TestCase {
  @override
  String get name => 'Overflow with Large Content';
  @override
  String get path => 'case_overflow_large_content.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          wrap: FlexWrap.none,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(300),
              height: SizeUnit.fixed(300),
              child: Box(1),
            ),
          ],
        ),
      ),
    );
  }
}
