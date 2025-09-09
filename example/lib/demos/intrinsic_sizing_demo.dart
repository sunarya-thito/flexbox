import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class IntrinsicSizingDemo extends BaseDemoPage {
  IntrinsicSizingDemo()
      : super(
          title: 'Intrinsic Sizing',
          description:
              'Elements that size themselves based on their content',
          color: Colors.purple,
        );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExample(
            'Intrinsic Width',
            'Boxes size themselves based on text content width',
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.intrinsic(),
                    height: BoxSize.fixed(80),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.red[300],
                      child: Center(
                        child: Text(
                          'Short',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.intrinsic(),
                    height: BoxSize.fixed(80),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.green[300],
                      child: Center(
                        child: Text(
                          'Medium Length Text',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.intrinsic(),
                    height: BoxSize.fixed(80),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.blue[300],
                      child: Center(
                        child: Text(
                          'Very Long Text Content Here',
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

          _buildExample(
            'Intrinsic Height',
            'Boxes size themselves based on text content height',
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(200),
                    height: BoxSize.intrinsic(),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.purple[300],
                      child: Text(
                        'Single line',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(200),
                    height: BoxSize.intrinsic(),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.orange[300],
                      child: Text(
                        'This is a longer text that will wrap to multiple lines when the width is constrained',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    width: BoxSize.fixed(200),
                    height: BoxSize.intrinsic(),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.teal[300],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Multi-element content:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Item 1',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '• Item 2',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '• Item 3',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Intrinsic with Constraints',
            'Intrinsic sizing with min/max constraints',
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.intrinsic(min: 100, max: 150),
                    height: BoxSize.fixed(80),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.indigo[300],
                      child: Center(
                        child: Text(
                          'Min: 100px\nMax: 150px',
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
                  FlexBoxChild(
                    width: BoxSize.intrinsic(min: 200),
                    height: BoxSize.fixed(80),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.pink[300],
                      child: Center(
                        child: Text(
                          'Short\n(Min: 200px)',
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
                  FlexBoxChild(
                    width: BoxSize.intrinsic(max: 100),
                    height: BoxSize.fixed(80),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.amber[700],
                      child: Center(
                        child: Text(
                          'Very Long Text (Max: 100px)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
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
