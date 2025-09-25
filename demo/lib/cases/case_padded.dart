import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CasePadded extends TestCase {
  @override
  String get name => 'Padded Simple FlexBox';
  @override
  String get path => 'case_padded.dart';
  @override
  Widget build() {
    return Box.parent(
      child: FlexBox(
        key: key0,
        padding: DirectionalEdgeSpacing.only(
          top: SpacingUnit.fixed(20),
          start: SpacingUnit.fixed(60),
          end: SpacingUnit.fixed(40),
          bottom: SpacingUnit.fixed(60),
        ),
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
