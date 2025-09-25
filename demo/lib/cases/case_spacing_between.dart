import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseSpacingBetween extends TestCase {
  @override
  String get name => 'Flex Spacing Between';
  @override
  String get path => 'case_spacing_between.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 500,
      height: 200,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          justifyContent: BoxAlignmentBase.spaceBetween,
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
