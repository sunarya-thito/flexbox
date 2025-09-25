import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseItemsStretch extends TestCase {
  @override
  String get name => 'Align Items Stretch';
  @override
  String get path => 'case_items_stretch.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 800,
      height: 600,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          alignItems: BoxAlignmentGeometry.stretch,
          alignContent: BoxAlignmentContent.stretch,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              width: SizeUnit.fixed(100),
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
