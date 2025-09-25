import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseAlignSelfRow extends TestCase {
  @override
  String get name => 'Align Self in Row';
  @override
  String get path => 'case_align_self_row.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 600,
      height: 300,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.row,
          alignItems: BoxAlignmentGeometry.start,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              alignSelf: BoxAlignmentGeometry.start,
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(150),
              alignSelf: BoxAlignmentGeometry.center,
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(80),
              alignSelf: BoxAlignmentGeometry.end,
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
