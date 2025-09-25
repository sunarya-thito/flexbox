import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseFlexShrinkConstrainedHeight extends TestCase {
  @override
  String get name => 'Flex Shrink with Height Constraints';
  @override
  String get path => 'case_flex_shrink_constrained_height.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 200,
      height: 400,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.column,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(200),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              flexShrink: 2.0,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(200),
              minHeight: SizeUnit.fixed(100),
              maxHeight: SizeUnit.fixed(180),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexShrink: 1.0,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(200),
              minHeight: SizeUnit.fixed(80),
              maxHeight: SizeUnit.fixed(160),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
