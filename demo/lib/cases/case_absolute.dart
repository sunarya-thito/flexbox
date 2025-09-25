import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseAbsolute extends TestCase {
  @override
  String get name => 'Absolute Positioning';
  @override
  String get path => 'case_absolute.dart';
  @override
  Widget build() {
    return Box.parent(
      child: FlexBox(
        key: key0,
        children: [
          FlexItem(
            key: key1,
            width: SizeUnit.fixed(100),
            height: SizeUnit.fixed(300),
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
            height: SizeUnit.fixed(300),
            child: Box(3),
          ),
          FlexItem(
            key: key4,
            width: SizeUnit.fixed(100),
            height: SizeUnit.fixed(300),
            child: Box(4),
          ),
          // absolute children
          AbsoluteItem(
            key: key5,
            top: PositionUnit.fixed(50),
            left: PositionUnit.fixed(150),
            bottom: PositionUnit.fixed(50),
            right: PositionUnit.fixed(150),
            child: Box(5),
          ),
          AbsoluteItem(
            key: key6,
            top: PositionUnit.fixed(50),
            left: PositionUnit.fixed(50),
            width: SizeUnit.fixed(100),
            height: SizeUnit.fixed(100),
            child: Box(6),
          ),
          AbsoluteItem(
            key: key7,
            bottom: PositionUnit.fixed(50),
            right: PositionUnit.fixed(50),
            width: SizeUnit.fixed(100),
            height: SizeUnit.fixed(100),
            child: Box(7),
          ),
        ],
      ),
    );
  }
}
