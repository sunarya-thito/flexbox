import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseGapsRowFlexShrinkUnconstrained extends TestCase {
  @override
  String get name => 'Gaps in Row with Flex Shrink Children (Unconstrained)';
  @override
  String get path => 'case_gaps_row_flex_shrink_unconstrained.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 400,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          rowGap: SpacingUnit.fixed(20),
          columnGap: SpacingUnit.fixed(15),
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
