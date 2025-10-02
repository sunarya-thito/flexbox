import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseBuilder extends TestCase {
  @override
  Widget build() {
    return SizedBox(
      width: 450,
      height: 300,
      child: Box.parent(
        child: FlexBox(
          key: key0,
          padding: const EdgeInsets.all(10).asEdgeSpacing,
          wrap: FlexWrap.wrap,
          rowGap: SpacingUnit.fixed(20),
          columnGap: SpacingUnit.fixed(15),
          justifyContent: BoxAlignmentBase.spaceBetween,
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
            FlexItem.builder(
              key: key3,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              top: PositionUnit.fixed(10),
              paintOrder: 9,
              builder: (context, box) {
                return Box(
                  3,
                  child: box.overflowBounds.hasTopOverflow
                      ? const Text('Overflow Top')
                      : null,
                );
              },
            ),
            FlexItem(
              key: key4,
              width: SizeUnit.fixed(350),
              height: SizeUnit.fixed(100),
              child: Box(4),
            ),
            FlexItem(
              key: key5,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(5),
            ),
            FlexItem(
              key: key6,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(6),
            ),
            FlexItem(
              key: key7,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(7),
            ),
          ],
        ),
      ),
    );
  }

  @override
  String get name => 'Layout Box Builder';

  @override
  String get path => 'layout_box.dart';
}
