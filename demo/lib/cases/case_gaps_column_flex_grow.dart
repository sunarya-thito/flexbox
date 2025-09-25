import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseGapsColumnFlexGrow extends TestCase {
  @override
  String get name => 'Gaps in Column with Flex Grow Children';
  @override
  String get path => 'case_gaps_column_flex_grow.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 200,
      height: 600,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.column,
          rowGap: SpacingUnit.fixed(20),
          columnGap: SpacingUnit.fixed(15),
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
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexGrow: 1.0,
              width: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
