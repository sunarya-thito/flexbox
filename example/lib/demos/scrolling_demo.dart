import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class ScrollingDemo extends BaseDemoPage {
  ScrollingDemo()
    : super(
        title: 'Scrolling Behavior',
        description: 'How different positioning types behave during scrolling',
        color: Colors.red,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      width: 1300,
      child: FlexBox(
        direction: Axis.vertical,
        children: [
          // Content blocks to create scrollable area
          for (int i = 0; i < 30; i++)
            FlexBoxChild(
              width: BoxSize.unconstrained(),
              height: BoxSize.fixed(80),
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[100 + (i % 4) * 100]!,
                      Colors.blue[200 + (i % 4) * 100]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Scrollable Content ${i + 1}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // Column 1: fixed
          FlexBoxChild(
            top: BoxPosition.fixed(20),
            left: BoxPosition.fixed(20),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.fixed,
            verticalPosition: BoxPositionType.fixed,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'fixed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 2: relative
          FlexBoxChild(
            bottom: BoxPosition.fixed(100),
            left: BoxPosition.fixed(160),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.relative,
            verticalPosition: BoxPositionType.relative,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'relative',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 3: relativeViewport
          FlexBoxChild(
            bottom: BoxPosition.fixed(20),
            left: BoxPosition.fixed(300),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.relativeViewport,
            verticalPosition: BoxPositionType.relativeViewport,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'relativeViewport',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 4: sticky
          FlexBoxChild(
            top: BoxPosition.fixed(800),
            left: BoxPosition.fixed(440),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.sticky,
            verticalPosition: BoxPositionType.sticky,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'sticky',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 5: stickyStart
          FlexBoxChild(
            top: BoxPosition.fixed(1000),
            left: BoxPosition.fixed(580),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.stickyStart,
            verticalPosition: BoxPositionType.stickyStart,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'stickyStart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 6: stickyEnd
          FlexBoxChild(
            bottom: BoxPosition.fixed(-200),
            left: BoxPosition.fixed(720),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.stickyStart,
            verticalPosition: BoxPositionType.stickyEnd,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'stickyEnd',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 7: stickyViewport
          FlexBoxChild(
            top: BoxPosition.fixed(800),
            left: BoxPosition.fixed(860),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.stickyViewport,
            verticalPosition: BoxPositionType.stickyViewport,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'stickyViewport',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 8: stickyStartViewport
          FlexBoxChild(
            top: BoxPosition.fixed(1000),
            left: BoxPosition.fixed(1000),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.stickyStartViewport,
            verticalPosition: BoxPositionType.stickyStartViewport,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'stickyStartViewport',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Column 9: stickyEndViewport
          FlexBoxChild(
            bottom: BoxPosition.fixed(600),
            left: BoxPosition.fixed(1140),
            width: BoxSize.fixed(120),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.stickyEndViewport,
            verticalPosition: BoxPositionType.stickyEndViewport,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'stickyEndViewport',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
