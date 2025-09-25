import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseAlignItemsCenterRTLRow extends TestCase {
  @override
  String get name => 'Align Items Center in RTL Row';
  @override
  String get path => 'case_align_items_center_rtl_row.dart';
  @override
  Widget build() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: 600,
        height: 300,
        child: Box.parent(
          child: FlexBox(
            key: key0,
            direction: FlexDirection.row,
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
                height: SizeUnit.fixed(150),
                child: Box(2),
              ),
              FlexItem(
                key: key3,
                width: SizeUnit.fixed(100),
                height: SizeUnit.fixed(80),
                child: Box(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
