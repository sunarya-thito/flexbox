import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseFlexGrowConstrainedHeight extends TestCase {
  @override
  String get name => 'Flex Grow with Height Constraints';
  @override
  String get path => 'case_flex_grow_constrained_height.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 200,
      height: 600,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.column,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(50),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              flexGrow: 2.0,
              width: SizeUnit.fixed(100),
              minHeight: SizeUnit.fixed(100),
              maxHeight: SizeUnit.fixed(200),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexGrow: 1.0,
              width: SizeUnit.fixed(100),
              minHeight: SizeUnit.fixed(80),
              maxHeight: SizeUnit.fixed(150),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
