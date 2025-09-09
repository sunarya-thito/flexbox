import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';
import '../widgets/base_demo_page.dart';

class AdvancedLayoutDemo extends BaseDemoPage {
  AdvancedLayoutDemo()
    : super(
        title: 'Advanced Layout',
        description:
            'Spacing, alignment, reverse direction, and scrolling behaviors',
        color: Colors.brown,
      );

  @override
  Widget buildDemo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExample(
            'Spacing Between Elements',
            'Control spacing between FlexBox children',
            Column(
              children: [
                Text('Spacing: 0'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    spacing: 0,
                    children: [
                      _buildBox('A', Colors.red[300]!),
                      _buildBox('B', Colors.green[300]!),
                      _buildBox('C', Colors.blue[300]!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Spacing: 16'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    spacing: 16,
                    children: [
                      _buildBox('A', Colors.red[300]!),
                      _buildBox('B', Colors.green[300]!),
                      _buildBox('C', Colors.blue[300]!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Spacing: double.infinity (max spacing)'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    spacing: double.infinity,
                    children: [
                      _buildBox('A', Colors.red[300]!),
                      _buildBox('B', Colors.green[300]!),
                      _buildBox('C', Colors.blue[300]!),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Infinite Spacing Behavior',
            'How double.infinity spacing distributes elements with maximum spacing',
            Column(
              children: [
                Text('Vertical Layout with Infinite Spacing'),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.vertical,
                    spacing: double.infinity,
                    children: [
                      _buildBox('Top', Colors.deepOrange[400]!),
                      _buildBox('Mid', Colors.deepPurple[400]!),
                      _buildBox('Bot', Colors.teal[400]!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Text(
                    'double.infinity spacing pushes elements to the extremes,\n'
                    'distributing maximum available space between them.\n'
                    'First element goes to start, last to end, others evenly spaced.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Alignment Options',
            'Different alignment options for FlexBox content',
            Column(
              children: [
                Text('Alignment.topLeft'),
                SizedBox(height: 8),
                Container(
                  height: 150,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    alignment: Alignment.topLeft,
                    children: [
                      _buildBox('1', Colors.purple[300]!),
                      _buildBox('2', Colors.orange[300]!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Alignment.center'),
                SizedBox(height: 8),
                Container(
                  height: 150,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    alignment: Alignment.center,
                    children: [
                      _buildBox('1', Colors.purple[300]!),
                      _buildBox('2', Colors.orange[300]!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Alignment.bottomRight'),
                SizedBox(height: 8),
                Container(
                  height: 150,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildBox('1', Colors.purple[300]!),
                      _buildBox('2', Colors.orange[300]!),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Reverse Direction',
            'Normal vs reversed layout direction',
            Column(
              children: [
                Text('Normal Direction'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    reverse: false,
                    children: [
                      _buildBox('First', Colors.teal[300]!),
                      _buildBox('Second', Colors.amber[300]!),
                      _buildBox('Third', Colors.indigo[300]!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Reversed Direction'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    reverse: true,
                    children: [
                      _buildBox('First', Colors.teal[300]!),
                      _buildBox('Second', Colors.amber[300]!),
                      _buildBox('Third', Colors.indigo[300]!),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Scroll Overflow Control',
            'Control scrolling behavior when content overflows',
            Column(
              children: [
                Text('Horizontal Scrolling Enabled'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    scrollHorizontalOverflow: true,
                    children: [
                      for (int i = 0; i < 8; i++)
                        _buildBox(
                          '${i + 1}',
                          Colors.primaries[i % Colors.primaries.length],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Horizontal Scrolling Disabled'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    scrollHorizontalOverflow: false,
                    children: [
                      for (int i = 0; i < 8; i++)
                        _buildBox(
                          '${i + 1}',
                          Colors.primaries[i % Colors.primaries.length],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Padding and Clipping',
            'FlexBox with padding and different clip behaviors',
            Column(
              children: [
                Text('With Padding'),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    padding: EdgeInsets.all(16),
                    children: [
                      _buildBox('Padded', Colors.pink[300]!),
                      _buildBox('Content', Colors.cyan[300]!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Clip.hardEdge - Content clipped at container edge'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    clipBehavior: Clip.hardEdge,
                    scrollHorizontalOverflow:
                        false, // Disable scrolling to see clipping
                    children: [
                      for (int i = 0; i < 6; i++)
                        _buildBox(
                          '${i + 1}',
                          Colors.primaries[i % Colors.primaries.length],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Clip.none - Content can overflow container'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    clipBehavior: Clip.none,
                    scrollHorizontalOverflow:
                        false, // Disable scrolling to see overflow
                    children: [
                      for (int i = 0; i < 6; i++)
                        _buildBox(
                          '${i + 1}',
                          Colors.primaries[i % Colors.primaries.length],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Clip.antiAlias - Smooth clipped edges'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    clipBehavior: Clip.antiAlias,
                    scrollHorizontalOverflow: false,
                    children: [
                      for (int i = 0; i < 6; i++)
                        _buildBox(
                          '${i + 1}',
                          Colors.primaries[i % Colors.primaries.length],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text('Clip.none + Scrollable - Overflow AND scrollable'),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: FlexBox(
                    direction: Axis.horizontal,
                    clipBehavior: Clip.none,
                    scrollHorizontalOverflow: true, // Enable scrolling
                    children: [
                      for (int i = 0; i < 8; i++)
                        _buildBox(
                          '${i + 1}',
                          Colors.primaries[i % Colors.primaries.length],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    'Content overflows container bounds AND is scrollable.\n'
                    'Scroll to see more content, plus overflow is visible.',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildExample(
            'Z-Order Layering',
            'Control rendering order of overlapping elements',
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: FlexBox(
                direction: Axis.horizontal,
                children: [
                  // Background element
                  FlexBoxChild(
                    width: BoxSize.unconstrained(),
                    height: BoxSize.unconstrained(),
                    zOrder: 0,
                    child: Container(
                      color: Colors.blue[100],
                      child: Center(
                        child: Text(
                          'Background (Z: 0)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Overlapping elements with different z-orders
                  FlexBoxChild(
                    left: BoxPosition.fixed(50),
                    top: BoxPosition.fixed(20),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(60),
                    zOrder: 2,
                    horizontalPosition: BoxPositionType.relativeViewport,
                    verticalPosition: BoxPositionType.relativeViewport,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'Z: 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    left: BoxPosition.fixed(100),
                    top: BoxPosition.fixed(40),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(60),
                    zOrder: 1,
                    horizontalPosition: BoxPositionType.relativeViewport,
                    verticalPosition: BoxPositionType.relativeViewport,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'Z: 1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexBoxChild(
                    left: BoxPosition.fixed(150),
                    top: BoxPosition.fixed(10),
                    width: BoxSize.fixed(100),
                    height: BoxSize.fixed(60),
                    zOrder: 3,
                    horizontalPosition: BoxPositionType.relativeViewport,
                    verticalPosition: BoxPositionType.relativeViewport,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[400],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'Z: 3',
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

  Widget _buildBox(String text, Color color) {
    return FlexBoxChild(
      width: BoxSize.fixed(60),
      height: BoxSize.fixed(60),
      child: Container(
        color: color,
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
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
