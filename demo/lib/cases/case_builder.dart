import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/material.dart';

final GlobalKey key3 = GlobalKey();

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
            FlexItem(
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem(
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(1),
            ),
            FlexItem(
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(2),
            ),
            FlexItem.builder(
              key: key3,
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              top: PositionUnit.fixed(0),
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
            FlexItem(
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(5),
            ),
            FlexItem(
              width: SizeUnit.fixed(150),
              height: SizeUnit.fixed(100),
              child: Box(6),
            ),

            // Floating button to show key7
            AbsoluteItem(
              bottom: PositionUnit.fixed(10),
              right: PositionUnit.fixed(10),
              child: RowBox(
                rowGap: SpacingUnit.fixed(10),
                children: [
                  FlexItem(
                    width: SizeUnit.fixed(50),
                    height: SizeUnit.fixed(50),
                    child: FloatingActionButton(
                      onPressed: () {
                        Scrollable.ensureVisible(
                          key3.currentContext!,
                          alignment: 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ),
                  FlexItem(
                    width: SizeUnit.fixed(50),
                    height: SizeUnit.fixed(50),
                    child: FloatingActionButton(
                      onPressed: () {
                        Scrollable.ensureVisible(
                          key3.currentContext!,
                          alignment: 0.5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  ),
                  FlexItem(
                    width: SizeUnit.fixed(50),
                    height: SizeUnit.fixed(50),
                    child: FloatingActionButton(
                      onPressed: () {
                        Scrollable.ensureVisible(
                          key3.currentContext!,
                          alignment: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ),
                ],
              ),
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
