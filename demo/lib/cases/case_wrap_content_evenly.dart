import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseWrapContentEvenly extends TestCase {
  @override
  String get name => 'Flex Wrap with Align Content Space Evenly';
  @override
  String get path => 'case_wrap_content_evenly.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 300,
      height: 500,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          wrap: FlexWrap.wrap,
          alignContent: BoxAlignmentContent.spaceEvenly,
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
              height: SizeUnit.fixed(200),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(150),
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
              height: SizeUnit.fixed(200),
              child: Box(5),
            ),
          ],
        ),
      ),
    );
  }
}
