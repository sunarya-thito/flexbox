import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseFlexShrinkConstrainedWidth extends TestCase {
  @override
  String get name => 'Flex Shrink with Width Constraints';
  @override
  String get path => 'case_flex_shrink_constrained_width.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 400,
      height: 200,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(200),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              flexShrink: 2.0,
              width: SizeUnit.fixed(200),
              minWidth: SizeUnit.fixed(100),
              maxWidth: SizeUnit.fixed(180),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexShrink: 1.0,
              width: SizeUnit.fixed(200),
              minWidth: SizeUnit.fixed(120),
              maxWidth: SizeUnit.fixed(160),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
