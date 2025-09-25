import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseFlexGrow extends TestCase {
  @override
  String get name => 'Flex Grow';
  @override
  String get path => 'case_flex_grow.dart';
  @override
  Widget build() {
    return SizedBox(
      width: 800,
      height: 200,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          children: [
            FlexItem(
              key: key1,
              width: SizeUnit.fixed(100),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              key: key2,
              flexGrow: 2.0,
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              key: key3,
              flexGrow: 1.0,
              height: SizeUnit.fixed(100),
              child: Box(3),
            ),
          ],
        ),
      ),
    );
  }
}
