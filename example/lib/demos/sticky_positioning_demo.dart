import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class StickyPositioningDemo extends BaseDemoPage {
  StickyPositioningDemo()
    : super(
        title: 'Sticky Positioning',
        description: 'Elements that stick to viewport edges while scrolling',
        color: Colors.pink,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FlexBox(
        direction: Axis.vertical,
        children: [
          // Content blocks for scrolling
          for (int i = 0; i < 15; i++)
            FlexBoxChild(
              width: BoxSize.unconstrained(),
              height: BoxSize.fixed(100),
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.primaries[i % Colors.primaries.length].withOpacity(
                        0.3,
                      ),
                      Colors.primaries[i % Colors.primaries.length].withOpacity(
                        0.6,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Content Block ${i + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Y Position: ${i * 100 + 50}px',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Sticky header (sticks to top)
          FlexBoxChild(
            top: BoxPosition.fixed(0),
            width: BoxSize.unconstrained(),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.relative,
            verticalPosition: BoxPositionType.stickyStart,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'Sticky Header (Top)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Sticky footer (sticks to bottom)
          FlexBoxChild(
            bottom: BoxPosition.fixed(0),
            width: BoxSize.unconstrained(),
            height: BoxSize.fixed(50),
            horizontalPosition: BoxPositionType.relative,
            verticalPosition: BoxPositionType.stickyEnd,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Sticky Footer (Bottom)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Sticky sidebar (sticks to left)
          FlexBoxChild(
            left: BoxPosition.fixed(0),
            top: BoxPosition.fixed(60),
            width: BoxSize.fixed(80),
            height: BoxSize.fixed(200),
            horizontalPosition: BoxPositionType.stickyStart,
            verticalPosition: BoxPositionType.relative,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Sticky Left',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating action button (sticky to bottom-right)
          FlexBoxChild(
            bottom: BoxPosition.fixed(20),
            right: BoxPosition.fixed(20),
            width: BoxSize.fixed(60),
            height: BoxSize.fixed(60),
            horizontalPosition: BoxPositionType.stickyEnd,
            verticalPosition: BoxPositionType.stickyEnd,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),

          // Viewport-based sticky examples

          // Sticky viewport header (sticks to top of viewport)
          FlexBoxChild(
            top: BoxPosition.fixed(0),
            left: BoxPosition.fixed(100),
            width: BoxSize.fixed(200),
            height: BoxSize.fixed(40),
            horizontalPosition: BoxPositionType.relativeViewport,
            verticalPosition: BoxPositionType.stickyStartViewport,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.cyan,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'Viewport Sticky Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Sticky viewport footer (sticks to bottom of viewport)
          FlexBoxChild(
            bottom: BoxPosition.fixed(0),
            left: BoxPosition.fixed(100),
            width: BoxSize.fixed(200),
            height: BoxSize.fixed(40),
            horizontalPosition: BoxPositionType.relativeViewport,
            verticalPosition: BoxPositionType.stickyEndViewport,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'Viewport Sticky Footer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Sticky viewport sidebar (viewport-based sticky)
          FlexBoxChild(
            left: BoxPosition.fixed(0),
            top: BoxPosition.fixed(50),
            width: BoxSize.fixed(60),
            height: BoxSize.fixed(150),
            horizontalPosition: BoxPositionType.stickyStartViewport,
            verticalPosition: BoxPositionType.relativeViewport,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Viewport Left',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
