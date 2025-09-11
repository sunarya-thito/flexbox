import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class UnconstrainedSizingDemo extends BaseDemoPage {
  UnconstrainedSizingDemo()
    : super(
        title: 'Unconstrained Sizing',
        description:
            'Elements that expand to fill remaining space in the container',
        color: Colors.orange,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (false)
            _buildExample(
              'Horizontal Unconstrained',
              'Unconstrained elements fill remaining horizontal space',
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
                        color: Colors.red[300],
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
                      width: BoxSize.expanding(),
                      height: BoxSize.fixed(80),
                      child: Container(
                        color: Colors.green[300],
                        child: Center(
                          child: Text(
                            'UNCONSTRAINED\n(fills remaining space)',
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
                      width: BoxSize.fixed(60),
                      height: BoxSize.fixed(80),
                      child: Container(
                        color: Colors.blue[300],
                        child: Center(
                          child: Text(
                            'Fixed\n60px',
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

          SizedBox(height: 24),
          if (false)
            _buildExample(
              'Vertical Unconstrained',
              'Unconstrained elements fill remaining vertical space',
              Container(
                height: 250,
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
                      height: BoxSize.fixed(50),
                      child: Container(
                        color: Colors.purple[300],
                        child: Center(
                          child: Text(
                            'Fixed Height: 50px',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    FlexBoxChild(
                      width: BoxSize.fixed(200),
                      height: BoxSize.expanding(),
                      child: Container(
                        color: Colors.orange[300],
                        child: Center(
                          child: Text(
                            'UNCONSTRAINED HEIGHT\n(fills remaining space)',
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
                      width: BoxSize.fixed(200),
                      height: BoxSize.fixed(40),
                      child: Container(
                        color: Colors.teal[300],
                        child: Center(
                          child: Text(
                            'Fixed Height: 40px',
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
          if (false)
            _buildExample(
              'Multiple Unconstrained Elements',
              'Multiple unconstrained elements share remaining space equally',
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
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(80),
                      child: Container(
                        color: Colors.indigo[300],
                        child: Center(
                          child: Text(
                            'Fixed\n100px',
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
                      width: BoxSize.expanding(),
                      height: BoxSize.fixed(80),
                      child: Container(
                        color: Colors.pink[300],
                        child: Center(
                          child: Text(
                            'Unconstrained 1',
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
                      width: BoxSize.expanding(),
                      height: BoxSize.fixed(80),
                      child: Container(
                        color: Colors.amber[600],
                        child: Center(
                          child: Text(
                            'Unconstrained 2',
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
                      width: BoxSize.expanding(),
                      height: BoxSize.fixed(80),
                      child: Container(
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'Unconstrained 3',
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

          SizedBox(height: 24),

          _buildExample(
            'Unconstrained with Constraints',
            'Unconstrained sizing with min/max constraints',
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
                      color: Colors.brown[400],
                      child: Center(
                        child: Text(
                          'Fixed\n80px',
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
                    // width: BoxSize.expanding(min: 150, max: 200),
                    width: BoxSize.expanding().clamp(
                      min: BoxSize.fixed(150),
                      max: BoxSize.fixed(200),
                    ),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.deepOrange[400],
                      child: Center(
                        child: Text(
                          'Unconstrained\nMin: 150px\nMax: 200px',
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
                  FlexBoxChild(
                    width: BoxSize.expanding().clamp(min: BoxSize.fixed(100)),
                    height: BoxSize.fixed(80),
                    child: Container(
                      color: Colors.deepPurple[400],
                      child: Center(
                        child: Text(
                          'Unconstrained\nMin: 100px',
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

          if (false)
            _buildExample(
              'Unconstrained Absolute Positioning - relative',
              'Absolutely positioned elements with unconstrained sizing relative to viewport',
              Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: FlexBox(
                  direction: Axis.horizontal,
                  children: [
                    // Background content
                    FlexBoxChild(
                      width: BoxSize.fixed(150),
                      height: BoxSize.fixed(80),
                      child: Container(
                        margin: EdgeInsets.all(8),
                        color: Colors.blue[100],
                        child: Center(
                          child: Text(
                            'Regular Content\n150x80',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    // Absolutely positioned unconstrained element
                    FlexBoxChild(
                      left: BoxPosition.fixed(40),
                      top: BoxPosition.fixed(20),
                      width: BoxSize.expanding(),
                      height: BoxSize.expanding(),
                      horizontalPosition: BoxPositionType.fixed,
                      verticalPosition: BoxPositionType.fixed,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[400]!.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[700]!, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            'Unconstrained\nAbsolute\n(relative)\nFills remaining\nviewport space',
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
                  ],
                ),
              ),
            ),

          SizedBox(height: 24),

          if (false)
            _buildExample(
              'Unconstrained Absolute Positioning - relative',
              'Absolutely positioned elements with unconstrained sizing relative to scrollable content',
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: FlexBox(
                  direction: Axis.vertical,
                  children: [
                    // Large scrollable content
                    for (int i = 0; i < 12; i++)
                      FlexBoxChild(
                        width: BoxSize.expanding(),
                        height: BoxSize.fixed(60),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue[100 + (i % 4) * 100]!,
                                Colors.blue[200 + (i % 4) * 100]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              'Scrollable Content Row ${i + 1}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                    // Absolutely positioned unconstrained element - relative
                    FlexBoxChild(
                      right: BoxPosition.fixed(20),
                      top: BoxPosition.fixed(30),
                      width: BoxSize.expanding(),
                      height: BoxSize.expanding(),
                      horizontalPosition: BoxPositionType.fixed,
                      verticalPosition: BoxPositionType.fixed,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[400]!.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green[700]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Unconstrained Absolute\n(relative)\n\nFills remaining space\nof ENTIRE scrollable\ncontent area\n\nScrolls with content',
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

                    // Fixed positioned for comparison
                    FlexBoxChild(
                      left: BoxPosition.fixed(20),
                      top: BoxPosition.fixed(100),
                      width: BoxSize.fixed(100),
                      height: BoxSize.fixed(50),
                      horizontalPosition: BoxPositionType.fixed,
                      verticalPosition: BoxPositionType.fixed,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple[400],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            'Fixed\nPosition\n(stays put)',
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

          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unconstrained Absolute Positioning:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '• relative: Fills remaining space within the visible viewport',
                ),
                Text(
                  '• relative: Fills remaining space within the entire scrollable content area',
                ),
                Text(
                  '• Fixed: Stays in fixed position, unaffected by scrolling',
                ),
                SizedBox(height: 8),
                Text(
                  'The key difference: relative sizing extends to the full content size, while relative only considers the visible area.',
                  style: TextStyle(fontStyle: FontStyle.italic),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
