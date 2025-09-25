import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseAlignItemsCenterRowFlexGrow extends TestCase {
  @override
  String get name => 'Align Items Center in Row with Flex Grow';
  @override
  String get path => 'case_align_items_center_row_flex_grow.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 600,
      height: 300,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          alignItems: BoxAlignmentGeometry.center,
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
              height: SizeUnit.fixed(150),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexGrow: 1.0,
              height: SizeUnit.fixed(80),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
