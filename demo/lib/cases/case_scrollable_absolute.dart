import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseScrollableAbsolute extends TestCase {
  @override
  String get name => 'Scrollable Absolute FlexBox';
  @override
  String get path => 'case_scrollable_absolute.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 500,
      height: 500,
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
              height: SizeUnit.fixed(300),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(200),
              child: Box(3),
            ),
            FlexItem(
              key: key4,
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
              height: SizeUnit.fixed(250),
              child: Box(6),
            ),
            FlexItem(
              key: key7,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(150),
              child: Box(7),
            ),

            // absolute children
            AbsoluteItem(
              key: key8,
              top: PositionUnit.fixed(50) - PositionUnit.scrollOffset,
              left: PositionUnit.fixed(150) - PositionUnit.scrollOffset,
              bottom: PositionUnit.fixed(50) + PositionUnit.scrollOffset,
              right: PositionUnit.fixed(150) + PositionUnit.scrollOffset,
              child: Box(5),
            ),
            AbsoluteItem(
              key: key9,
              top: PositionUnit.fixed(50) - PositionUnit.scrollOffset,
              left: PositionUnit.fixed(50) - PositionUnit.scrollOffset,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(6),
            ),
            AbsoluteItem(
              key: key10,
              bottom: PositionUnit.fixed(50),
              right: PositionUnit.fixed(50),
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(7),
            ),
          ],
        ),
      ),
    );
  }
}
