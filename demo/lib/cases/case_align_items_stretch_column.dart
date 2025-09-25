import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseAlignItemsStretchColumn extends TestCase {
  @override
  String get name => 'Align Items Stretch in Column';
  @override
  String get path => 'case_align_items_stretch_column.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 400,
      height: 300,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          direction: FlexDirection.column,
          alignItems: BoxAlignmentGeometry.stretch,
          children: [
            FlexItem(
              key: key1,
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
