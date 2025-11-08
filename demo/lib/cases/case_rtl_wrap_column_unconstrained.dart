import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseRTLWrapColumnUnconstrained extends TestCase {
  @override
  String get name => 'Right-to-Left Flex Wrap Column (Unconstrained)';
  @override
  String get path => 'case_rtl_wrap_column_unconstrained.dart';
  @override
  Widget build() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 300,
        child: Box.parent(
          child: FlexBox(
            key: key0,
            wrap: FlexWrap.wrap,
            direction: FlexDirection.column,
            children: [
              FlexItem(
                key: key1,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(1),
              ),
              FlexItem(
                key: key2,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(2),
              ),
              FlexItem(
                key: key3,
                width: SizeUnit.fixed(250),
                height: SizeUnit.fixed(100),
                child: Box(3),
              ),
              FlexItem(
                key: key4,
                width: SizeUnit.fixed(100),
                height: SizeUnit.fixed(100),
                child: Box(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
