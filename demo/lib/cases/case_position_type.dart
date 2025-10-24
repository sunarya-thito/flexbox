import 'package:demo/case.dart';
import 'package:flexiblebox/flexiblebox_extensions.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/material.dart';

class CasePositionType extends TestCase {
  @override
  Widget build() {
    return FlexBox(
      children: [
        // PositionType.none
        FlexItem(
          width: SizeUnit.fixed(400),
          height: SizeUnit.fixed(400),
          child: ColoredBox(
            color: Colors.blue,
            child: Scrollbars(
              child: FlexBox(
                padding: EdgeSpacing.all(16.spacing),
                alignItems: BoxAlignmentGeometry.stretch,
                children: [
                  FlexItem(
                    flexGrow: 1,
                    // width: 500.size,
                    height: 500.size,
                    position: PositionType.none,
                    child: ColoredBox(
                      color: Colors.yellow,
                      child: Scrollbars(
                        child: FlexBox(
                          padding: EdgeSpacing.all(24.spacing),
                          children: [
                            AbsoluteItem(
                              width: SizeUnit.viewportSize,
                              height: 100.size,
                              paintOrder: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                            FlexItem(
                              flexGrow: 1,
                              height: 500.size,
                              position: PositionType.none,
                              child: ColoredBox(
                                color: Colors.green,
                                child: Scrollbars(
                                  child: FlexBox(
                                    padding: EdgeSpacing.all(32.spacing),
                                    children: [
                                      AbsoluteItem(
                                        key: Key('purple_box'),
                                        width: 100.size,
                                        height: 100.size,
                                        // right: 0.position,
                                        // bottom: 0.position,
                                        child: ColoredBox(color: Colors.purple),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  String get name => 'Position Type';

  @override
  String get path => 'case_position_type.dart';
}
