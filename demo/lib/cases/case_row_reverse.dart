import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseRowReverse extends TestCase {
  @override
  String get name => 'Row Reverse FlexBox';
  @override
  String get path => 'case_row_reverse.dart';
  @override
  Widget build() {
    return Box.parent(
      child: FlexBox(
        key: key0,
        direction: FlexDirection.rowReverse,
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
    );
  }
}
