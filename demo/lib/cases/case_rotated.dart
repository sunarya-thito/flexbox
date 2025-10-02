import 'dart:math';

import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/material.dart';

class CaseRotated extends TestCase {
  final ValueNotifier<double> rotation = ValueNotifier(0.0);
  @override
  Widget build() {
    return ListenableBuilder(
      listenable: rotation,
      builder: (context, child) {
        return ColumnBox(
          columnGap: SpacingUnit.fixed(40),
          children: [
            FlexItem(
              width: SizeUnit.fixed(400),
              height: SizeUnit.fixed(200),
              child: Container(
                // border
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: RotatedWidget(
                  angle: rotation.value * pi / 180,
                  child: Box(1),
                ),
              ),
            ),
            FlexItem(
              height: SizeUnit.fixed(40),
              alignSelf: BoxAlignmentGeometry.stretch,
              child: Slider(
                value: rotation.value,
                min: 0,
                max: 360,
                onChanged: (value) {
                  rotation.value = value;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  String get name => 'RotatedWidget';

  @override
  String get path => 'case_rotated.dart';
}
