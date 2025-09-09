import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class PositioningDemo extends BaseDemoPage {
  PositioningDemo()
    : super(
        title: 'Positioning Types',
        description:
            'Compare relative, fixed, and sticky positioning behaviors',
        color: Colors.green,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return Container(
      height: 400,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FlexBox(
        direction: Axis.vertical,
        children: [
          // Large content to enable scrolling
          for (int i = 0; i < 10; i++)
            FlexBoxChild(
              width: BoxSize.unconstrained(),
              height: BoxSize.fixed(60),
              child: Container(
                margin: EdgeInsets.all(4),
                color: Colors.grey[200],
                child: Center(child: Text('Content Block ${i + 1}')),
              ),
            ),

          // Relative positioned element
          FlexBoxChild(
            top: BoxPosition.fixed(20),
            right: BoxPosition.fixed(20),
            width: BoxSize.fixed(80),
            height: BoxSize.fixed(40),
            horizontalPosition: BoxPositionType.relative,
            verticalPosition: BoxPositionType.relative,
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Relative',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),

          // Fixed positioned element
          FlexBoxChild(
            top: BoxPosition.fixed(20),
            left: BoxPosition.fixed(20),
            width: BoxSize.fixed(80),
            height: BoxSize.fixed(40),
            horizontalPosition: BoxPositionType.fixed,
            verticalPosition: BoxPositionType.fixed,
            child: Container(
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Fixed',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),

          // Sticky positioned element
          FlexBoxChild(
            bottom: BoxPosition.fixed(20),
            right: BoxPosition.fixed(20),
            width: BoxSize.fixed(80),
            height: BoxSize.fixed(40),
            horizontalPosition: BoxPositionType.stickyEnd,
            verticalPosition: BoxPositionType.stickyEnd,
            child: Container(
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Sticky',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
