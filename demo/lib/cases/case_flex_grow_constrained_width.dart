import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseFlexGrowConstrainedWidth extends TestCase {
  @override
  String get name => 'Flex Grow with Width Constraints';
  @override
  String get path => 'case_flex_grow_constrained_width.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 600,
      height: 200,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(50),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              flexGrow: 2.0,
              minWidth: SizeUnit.fixed(100),
              maxWidth: SizeUnit.fixed(200),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexGrow: 1.0,
              minWidth: SizeUnit.fixed(80),
              maxWidth: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
