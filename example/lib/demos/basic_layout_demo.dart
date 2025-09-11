import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class BasicLayoutDemo extends BaseDemoPage {
  BasicLayoutDemo()
    : super(
        title: 'Basic Layout',
        description:
            'Fundamental FlexBox layout with different directions and alignments',
        color: Colors.blue,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Horizontal Layout
          _buildSection('Horizontal Layout', [
            Container(
              height: 120,
              width: 400,
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
                      color: Colors.red[300],
                      child: Center(
                        child: Text(
                          'Box 1',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(60),
                    child: Container(
                      color: Colors.green[300],
                      child: Center(
                        child: Text(
                          'Box 2',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(90),
                    height: BoxSize.fixed(70),
                    child: Container(
                      color: Colors.blue[300],
                      child: Center(
                        child: Text(
                          'Box 3',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),

          SizedBox(height: 24),

          // Vertical Layout
          _buildSection('Vertical Layout', [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(120),
                    height: BoxSize.fixed(40),
                    child: Container(
                      color: Colors.purple[300],
                      child: Center(
                        child: Text(
                          'Vertical 1',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(50),
                    child: Container(
                      color: Colors.orange[300],
                      child: Center(
                        child: Text(
                          'Vertical 2',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(140),
                    height: BoxSize.fixed(35),
                    child: Container(
                      color: Colors.teal[300],
                      child: Center(
                        child: Text(
                          'Vertical 3',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
