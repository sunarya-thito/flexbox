import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseFlexWrapReverseRowReverse extends TestCase {
  @override
  String get name => 'Flex Wrap Reverse Row Reverse';
  @override
  String get path => 'case_flex_wrap_reverse_row_reverse.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 300,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          wrap: FlexWrap.wrapReverse,
          direction: FlexDirection.rowReverse,
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
              width: SizeUnit.fixed(250),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
            FlexItem(
              key: key4,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(4),
            ),
          ],
        ),
      ),
    );
  }
}
