import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class AbsolutePositioningDemo extends BaseDemoPage {
  AbsolutePositioningDemo()
    : super(
        title: 'Absolute Positioning',
        description:
            'Complex absolute positioning layouts with different anchor points',
        color: Colors.indigo,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: FlexBox(
        direction: Axis.horizontal,
        children: [
          // Regular content
          FlexBoxChild(
            width: BoxSize.fixed(200),
            height: BoxSize.fixed(150),
            child: Container(
              color: Colors.blue[100],
              child: Center(
                child: Text(
                  'Regular Content\n200x150',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Top-left positioned
          FlexBoxChild(
            top: BoxPosition.fixed(10),
            left: BoxPosition.fixed(10),
            width: BoxSize.fixed(60),
            height: BoxSize.fixed(40),
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Top-Left',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Top-right positioned
          FlexBoxChild(
            top: BoxPosition.fixed(10),
            right: BoxPosition.fixed(10),
            width: BoxSize.fixed(60),
            height: BoxSize.fixed(40),
            child: Container(
              color: Colors.green,
              child: Center(
                child: Text(
                  'Top-Right',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bottom-left positioned
          FlexBoxChild(
            bottom: BoxPosition.fixed(10),
            left: BoxPosition.fixed(10),
            width: BoxSize.fixed(60),
            height: BoxSize.fixed(40),
            child: Container(
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Bottom-Left',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bottom-right positioned
          FlexBoxChild(
            bottom: BoxPosition.fixed(10),
            right: BoxPosition.fixed(10),
            width: BoxSize.fixed(60),
            height: BoxSize.fixed(40),
            child: Container(
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Bottom-Right',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Center positioned
          FlexBoxChild(
            top: BoxPosition.relative(0.4),
            left: BoxPosition.relative(0.4),
            width: BoxSize.fixed(80),
            height: BoxSize.fixed(50),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  'Center\n(40%, 40%)',
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

          // Stretched horizontally
          FlexBoxChild(
            top: BoxPosition.fixed(60),
            left: BoxPosition.fixed(80),
            right: BoxPosition.fixed(80),
            height: BoxSize.fixed(30),
            child: Container(
              color: Colors.teal,
              child: Center(
                child: Text(
                  'Stretched Horizontally',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Stretched vertically
          FlexBoxChild(
            left: BoxPosition.fixed(250),
            top: BoxPosition.fixed(60),
            bottom: BoxPosition.fixed(60),
            width: BoxSize.fixed(40),
            child: Container(
              color: Colors.pink,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Vertical',
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
