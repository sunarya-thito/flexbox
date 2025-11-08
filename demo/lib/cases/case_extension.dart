import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:flexiblebox/flexiblebox_extensions.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseExtension extends TestCase {
  @override
  Widget build() {
    return SizedBox(
      height: 400,
      width: 500,
      child: ColumnBox(
        alignItems: BoxAlignmentGeometry.stretch,
        children: [
          Box(1)
              .top(0.position)
              .paintOrder(1)
              .height(SizeUnit.fitContent + 50.size)
              .id(#box1),
          Box(2).height(250.size),
          Box(3).height(200.size),
          Box(4).height(150.size),
          Box(5)
              .top(PositionUnit.childSize(#box1))
              .paintOrder(1)
              .height(SizeUnit.fitContent + 25.size)
              .id(#box5),
          Box(6).height(250.size),
          Box(7).height(200.size),
          Box(8).height(150.size),
          Box(9)
              .height(150.size)
              .paintOrder(2)
              .top(
                PositionUnit.childSize(#box1) + PositionUnit.childSize(#box5),
              ),
          Box(10).height(200.size),
          Box(11).height(150.size),
        ],
      ),
    );
  }

  @override
  String get name => 'Case Extension';

  @override
  String get path => 'case_extension.dart';
}
