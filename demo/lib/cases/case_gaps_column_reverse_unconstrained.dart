import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseGapsColumnReverseUnconstrained extends TestCase {
  @override
  String get name => 'Gaps in Column Reverse Direction (Unconstrained)';
  @override
  String get path => 'case_gaps_column_reverse_unconstrained.dart';
  @override
  Widget build() {
    return SizedBox(
      height: 600,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.columnReverse,
          rowGap: SpacingUnit.fixed(15),
          columnGap: SpacingUnit.fixed(25),
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
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
