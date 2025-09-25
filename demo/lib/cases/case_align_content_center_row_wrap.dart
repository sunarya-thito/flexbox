import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseAlignContentCenterRowWrap extends TestCase {
  @override
  String get name => 'Align Content Center in Row Wrap';
  @override
  String get path => 'case_align_content_center_row_wrap.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 350,
      height: 400,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          wrap: FlexWrap.wrap,
          alignContent: BoxAlignmentContent.center,
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
            FlexItem(
              key: key4,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(4),
            ),
            FlexItem(
              key: key5,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(5),
            ),
          ],
        ),
      ),
    );
  }
}
