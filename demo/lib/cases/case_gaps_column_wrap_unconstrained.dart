import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseGapsColumnWrapUnconstrained extends TestCase {
  @override
  String get name => 'Gaps in Column Wrap (Unconstrained)';
  @override
  String get path => 'case_gaps_column_wrap_unconstrained.dart';
  @override
  Widget build() {
    return SizedBox(
      height: 250,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.column,
          wrap: FlexWrap.wrap,
          rowGap: SpacingUnit.fixed(20),
          columnGap: SpacingUnit.fixed(15),
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
            FlexItem(
              key: key4,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(4),
            ),
          ],
        ),
      ),
    );
  }
}
