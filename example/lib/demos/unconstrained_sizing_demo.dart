import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class UnconstrainedSizingDemo extends BaseDemoPage {
  UnconstrainedSizingDemo()
    : super(
        title: 'Unconstrained Sizing',
        description: 'Dynamic sizing that uses remaining space after anchoring',
        color: Colors.orange,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Example 1: Horizontal unconstrained with relative positioning
          _buildExample(
            'Unconstrained Width - Relative Positioning',
            'FlexBox is 300px wide, left anchor is 30px, remaining space = 270px',
            Container(
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          'Fixed\n100px',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    left: BoxPosition.fixed(30),
                    width: BoxSize.unconstrained(),
                    height: BoxSize.fixed(50),
                    horizontalPosition: BoxPositionType.relative,
                    child: Container(
                      color: Colors.red[400],
                      child: Center(
                        child: Text(
                          'Unconstrained\n(uses remaining)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Example 2: Horizontal unconstrained with viewport positioning
          _buildExample(
            'Unconstrained Width - Viewport Positioning',
            'Viewport is 300px wide, left anchor is 30px, remaining space = 270px',
            Container(
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(50),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Text('50px', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    left: BoxPosition.fixed(30),
                    width: BoxSize.unconstrained(),
                    height: BoxSize.fixed(50),
                    horizontalPosition: BoxPositionType.relativeViewport,
                    child: Container(
                      color: Colors.green[400],
                      child: Center(
                        child: Text(
                          'Viewport Unconstrained\n(uses viewport space)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Example 3: Vertical unconstrained
          _buildExample(
            'Unconstrained Height',
            'Uses remaining vertical space after top anchor',
            Container(
              width: 200,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(150),
                    height: BoxSize.fixed(60),
                    child: Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          'Fixed Height\n60px',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    top: BoxPosition.fixed(30),
                    left: BoxPosition.fixed(10),
                    width: BoxSize.fixed(80),
                    height: BoxSize.unconstrained(),
                    verticalPosition: BoxPositionType.relativeViewport,
                    child: Container(
                      color: Colors.blue[400],
                      child: Center(
                        child: Text(
                          'Unconstrained\nHeight',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(String title, String description, Widget demo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        SizedBox(height: 12),
        demo,
      ],
    );
  }
}
