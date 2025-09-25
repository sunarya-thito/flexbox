import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseScrollableSticky extends TestCase {
  @override
  String get name => 'Sticky Scrollable FlexBox';
  @override
  String get path => 'case_scrollable_sticky.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 300,
      height: 250,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          alignItems: BoxAlignmentGeometry.center,
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
              height: SizeUnit.fixed(500),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(300),
              child: Box(3),
            ),
            FlexItem(
              key: key4,
              top: PositionUnit.fixed(25),
              bottom: PositionUnit.fixed(25),
              left: PositionUnit.fixed(0),
              right: PositionUnit.fixed(0),
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(4),
            ),
            FlexItem(
              key: key5,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(200),
              child: Box(5),
            ),
            FlexItem(
              key: key6,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(450),
              child: Box(6),
            ),
            FlexItem(
              key: key7,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(350),
              child: Box(7),
            ),
          ],
        ),
      ),
    );
  }
}
