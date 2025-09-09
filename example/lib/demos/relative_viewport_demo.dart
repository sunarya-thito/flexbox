import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class RelativeViewportDemo extends BaseDemoPage {
  RelativeViewportDemo()
    : super(
        title: 'Relative vs Viewport',
        description:
            'Compare BoxPositionType.relative vs relativeViewport positioning',
        color: Colors.purple,
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
        direction: Axis.horizontal,
        children: [
          // Large content that exceeds viewport
          FlexBoxChild(
            width: BoxSize.fixed(600),
            height: BoxSize.fixed(300),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.blue[300]!],
                ),
              ),
              child: Center(
                child: Text(
                  'Large Content Area\n600x300\nScroll horizontally →',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Relative positioned (anchored to FlexBox)
          FlexBoxChild(
            left: BoxPosition.fixed(50),
            top: BoxPosition.fixed(50),
            width: BoxSize.fixed(100),
            height: BoxSize.fixed(60),
            horizontalPosition: BoxPositionType.relative,
            verticalPosition: BoxPositionType.relative,
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Relative\n(to FlexBox)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),

          // RelativeViewport positioned (anchored to viewport)
          FlexBoxChild(
            left: BoxPosition.fixed(50),
            top: BoxPosition.fixed(120),
            width: BoxSize.fixed(100),
            height: BoxSize.fixed(60),
            horizontalPosition: BoxPositionType.relativeViewport,
            verticalPosition: BoxPositionType.relativeViewport,
            child: Container(
              color: Colors.green,
              child: Center(
                child: Text(
                  'RelativeViewport\n(to Viewport)',
                  textAlign: TextAlign.center,
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
