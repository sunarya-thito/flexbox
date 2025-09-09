import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class RatioSizingDemo extends BaseDemoPage {
  RatioSizingDemo()
      : super(
          title: 'Ratio Sizing',
          description:
              'Elements sized based on aspect ratios relative to their container',
          color: Colors.deepPurple,
        );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExample(
            'Square Ratios',
            'Different square aspect ratios (1:1) with varying sizes',
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
                    width: BoxSize.ratio(1.0), // 1:1 aspect ratio
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.red[400],
                      child: Center(
                        child: Text(
                          'Square\n1:1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  FlexBoxChild(
                    width: BoxSize.ratio(1.0), // 1:1 aspect ratio
                    height: BoxSize.fixed(100),
                    child: Container(
                      color: Colors.green[400],
                      child: Center(
                        child: Text(
                          'Larger\nSquare\n1:1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  FlexBoxChild(
                    width: BoxSize.ratio(1.0), // 1:1 aspect ratio
                    height: BoxSize.fixed(60),
                    child: Container(
                      color: Colors.blue[400],
                      child: Center(
                        child: Text(
                          'Small\n1:1',
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
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Landscape Ratios',
            'Wide aspect ratios (width > height)',
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.vertical,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(200),
                    height: BoxSize.ratio(0.5), // 2:1 aspect ratio (width:height)
                    child: Container(
                      color: Colors.purple[400],
                      child: Center(
                        child: Text(
                          '2:1 Ratio',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  FlexBoxChild(
                    width: BoxSize.fixed(240),
                    height: BoxSize.ratio(0.375), // 16:6 aspect ratio
                    child: Container(
                      color: Colors.orange[400],
                      child: Center(
                        child: Text(
                          '16:6 Ratio (Ultrawide)',
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
            'Portrait Ratios',
            'Tall aspect ratios (height > width)',
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.fixed(60),
                    height: BoxSize.ratio(2.0), // 1:2 aspect ratio (width:height)
                    child: Container(
                      color: Colors.teal[400],
                      child: Center(
                        child: Text(
                          '1:2\nRatio',
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
                  SizedBox(width: 8),
                  FlexBoxChild(
                    width: BoxSize.fixed(80),
                    height: BoxSize.ratio(1.6), // 1:1.6 (golden ratio)
                    child: Container(
                      color: Colors.amber[700],
                      child: Center(
                        child: Text(
                          'Golden\nRatio\n1:1.6',
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
                  SizedBox(width: 8),
                  FlexBoxChild(
                    width: BoxSize.fixed(50),
                    height: BoxSize.ratio(3.0), // 1:3 aspect ratio
                    child: Container(
                      color: Colors.indigo[400],
                      child: Center(
                        child: Text(
                          '1:3',
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
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Ratio with Constraints',
            'Ratio sizing combined with min/max constraints',
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  FlexBoxChild(
                    width: BoxSize.ratio(1.0, min: 100, max: 120),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.pink[400],
                      child: Center(
                        child: Text(
                          'Square\nMin: 100\nMax: 120',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  FlexBoxChild(
                    width: BoxSize.fixed(150),
                    height: BoxSize.ratio(0.6, min: 60, max: 100),
                    child: Container(
                      color: Colors.cyan[600],
                      child: Center(
                        child: Text(
                          'Ratio: 0.6\nMin Height: 60\nMax Height: 100',
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

          SizedBox(height: 24),

          _buildExample(
            'Dynamic Ratio Sizing',
            'Ratios that adapt to different container sizes',
            Column(
              children: [
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    children: [
                      FlexBoxChild(
                        width: BoxSize.ratio(1.5), // 3:2 aspect ratio
                        height: BoxSize.unconstrained(),
                        child: Container(
                          color: Colors.deepOrange[400],
                          child: Center(
                            child: Text(
                              '3:2',
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
                SizedBox(height: 8),
                Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    children: [
                      FlexBoxChild(
                        width: BoxSize.ratio(1.5), // Same 3:2 aspect ratio
                        height: BoxSize.unconstrained(),
                        child: Container(
                          color: Colors.deepOrange[400],
                          child: Center(
                            child: Text(
                              '3:2\n(larger container)',
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
