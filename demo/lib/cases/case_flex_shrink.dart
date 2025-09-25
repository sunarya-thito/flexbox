import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseFlexShrink extends TestCase {
  @override
  String get name => 'Flex Shrink';
  @override
  String get path => 'case_flex_shrink.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 300,
      height: 200,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              flexShrink: 1.5,
              width: SizeUnit.fixed(200),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexShrink: 1.0,
              width: SizeUnit.fixed(200),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
