import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class RelativePositioningDemo extends BaseDemoPage {
  RelativePositioningDemo()
    : super(
        title: 'Relative Positioning',
        description:
            'BoxPosition.fixed() positioning method for percentage-based positioning',
        color: Colors.indigo,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExample(
            'Relative Positioning',
            'Position elements as percentages of container size',
            Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  // Background content
                  FlexBoxChild(
                    width: BoxSize.expanding(),
                    height: BoxSize.expanding(),
                    child: Container(
                      color: Colors.blue[50],
                      child: Center(
                        child: Text(
                          'Container Area\n300x200',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Relative positioned at 25% from left
                  FlexBoxChild(
                    left: BoxPosition.fixed(0.25), // 25% from left
                    top: BoxPosition.fixed(0.2), // 20% from top
                    width: BoxSize.fixed(60),
                    height: BoxSize.fixed(40),
                    horizontalPosition: BoxPositionType.fixed,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 2),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '25%\n20%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Relative positioned at 70% from left
                  FlexBoxChild(
                    left: BoxPosition.fixed(0.7), // 70% from left
                    bottom: BoxPosition.fixed(0.15), // 15% from bottom
                    width: BoxSize.fixed(60),
                    height: BoxSize.fixed(40),
                    horizontalPosition: BoxPositionType.fixed,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 2),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '70%\n85%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center positioned
                  FlexBoxChild(
                    left: BoxPosition.fixed(0.5), // 50% from left
                    top: BoxPosition.fixed(0.5), // 50% from top
                    width: BoxSize.fixed(50),
                    height: BoxSize.fixed(30),
                    horizontalPosition: BoxPositionType.fixed,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[400],
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 2),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Center',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Mixed Positioning Methods',
            'Combining relative and fixed positioning',
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  // Background
                  FlexBoxChild(
                    width: BoxSize.expanding(),
                    height: BoxSize.expanding(),
                    child: Container(
                      color: Colors.pink[50],
                      child: Center(
                        child: Text(
                          'Mixed Positioning Demo',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Fixed position from top-left
                  FlexBoxChild(
                    left: BoxPosition.fixed(20),
                    top: BoxPosition.fixed(20),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(30),
                    horizontalPosition: BoxPositionType.fixed,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[500],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          'Fixed: 20,20',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Relative position at 60% width
                  FlexBoxChild(
                    left: BoxPosition.fixed(0.6),
                    top: BoxPosition.fixed(60),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(30),
                    horizontalPosition: BoxPositionType.fixed,
                    verticalPosition: BoxPositionType.fixed,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[500],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          'Relative: 60%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Position Methods Explained:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '• BoxPosition.fixed(value) - Absolute position in pixels',
                ),
                Text(
                  '• BoxPosition.fixed(0.0-1.0) - Percentage of container size',
                ),
              ],
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
