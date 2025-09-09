import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class FlexSizingDemo extends BaseDemoPage {
  FlexSizingDemo()
    : super(
        title: 'Flex Sizing',
        description: 'Flexible and ratio-based sizing options',
        color: Colors.teal,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Flex sizing example
          _buildExample(
            'Flex Sizing',
            'Boxes with different flex values share available space',
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.flex(1),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.red[300],
                      child: Center(
                        child: Text(
                          'Flex 1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.flex(2),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.green[300],
                      child: Center(
                        child: Text(
                          'Flex 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.flex(1),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.blue[300],
                      child: Center(
                        child: Text(
                          'Flex 1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

          // Relative sizing example
          _buildExample(
            'Relative Sizing',
            'Boxes sized as percentages of container',
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.relative(0.3), // 30%
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.purple[300],
                      child: Center(
                        child: Text(
                          '30%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.relative(0.5), // 50%
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.orange[300],
                      child: Center(
                        child: Text(
                          '50%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.relative(0.2), // 20%
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.teal[300],
                      child: Center(
                        child: Text(
                          '20%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

          // Mixed sizing example
          _buildExample(
            'Mixed Sizing',
            'Combination of fixed, flex, and relative sizing',
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(80),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.indigo[300],
                      child: Center(
                        child: Text(
                          'Fixed\n80px',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.relative(0.3),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.pink[300],
                      child: Center(
                        child: Text(
                          '30%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.flex(1),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.amber[300],
                      child: Center(
                        child: Text(
                          'Flex\n(remaining)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
