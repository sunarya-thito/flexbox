import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseJustifyEnd extends TestCase {
  @override
  String get name => 'Justify Content End';
  @override
  String get path => 'case_justify_end.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 800,
      height: 600,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          justifyContent: BoxAlignmentBase.end,
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
