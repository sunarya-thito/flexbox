import 'package:flexiblebox/flexiblebox_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexibleBox Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlexibleBox Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Example 1: Flex Direction Row
              _buildSectionTitle('1. Flex Direction: Row'),
              _buildDescription('Horizontal layout with fixed-size items'),
              FlexBox(
                direction: FlexDirection.row,
                children: [
                  FlexItem(
                    width: 100.size,
                    height: 80.size,
                    child: _buildBox(Colors.red, '1'),
                  ),
                  FlexItem(
                    width: 100.size,
                    height: 80.size,
                    child: _buildBox(Colors.blue, '2'),
                  ),
                  FlexItem(
                    width: 100.size,
                    height: 80.size,
                    child: _buildBox(Colors.green, '3'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Example 2: Flex Direction Column
              _buildSectionTitle('2. Flex Direction: Column'),
              _buildDescription('Vertical layout with fixed-size items'),
              FlexBox(
                direction: FlexDirection.column,
                children: [
                  FlexItem(
                    width: 150.size,
                    height: 60.size,
                    child: _buildBox(Colors.purple, '1'),
                  ),
                  FlexItem(
                    width: 150.size,
                    height: 60.size,
                    child: _buildBox(Colors.orange, '2'),
                  ),
                  FlexItem(
                    width: 150.size,
                    height: 60.size,
                    child: _buildBox(Colors.teal, '3'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Example 3: Flex Grow
              _buildSectionTitle('3. Flex Grow'),
              _buildDescription(
                'Item 1: Fixed width, Item 2: Grows 2x, Item 3: Grows 1x',
              ),
              SizedBox(
                width: 400,
                child: FlexBox(
                  direction: FlexDirection.row,
                  children: [
                    FlexItem(
                      width: 80.size,
                      height: 80.size,
                      child: _buildBox(Colors.red, 'Fixed'),
                    ),
                    FlexItem(
                      flexGrow: 2.0,
                      height: 80.size,
                      child: _buildBox(Colors.blue, 'Grow 2x'),
                    ),
                    FlexItem(
                      flexGrow: 1.0,
                      height: 80.size,
                      child: _buildBox(Colors.green, 'Grow 1x'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Example 4: Flex Shrink
              _buildSectionTitle('4. Flex Shrink'),
              _buildDescription(
                'Items shrink when container is 300px but items want 400px total',
              ),
              SizedBox(
                width: 300,
                child: FlexBox(
                  direction: FlexDirection.row,
                  children: [
                    FlexItem(
                      width: 200.size,
                      flexShrink: 2.0,
                      height: 80.size,
                      child: _buildBox(Colors.purple, 'Shrink 2x'),
                    ),
                    FlexItem(
                      width: 200.size,
                      flexShrink: 1.0,
                      height: 80.size,
                      child: _buildBox(Colors.orange, 'Shrink 1x'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Example 5: Row Gap
              _buildSectionTitle('5. Row Gap'),
              _buildDescription('16px horizontal spacing between items'),
              FlexBox(
                direction: FlexDirection.row,
                rowGap: 16.0.spacing,
                children: [
                  FlexItem(
                    width: 80.size,
                    height: 80.size,
                    child: _buildBox(Colors.red, '1'),
                  ),
                  FlexItem(
                    width: 80.size,
                    height: 80.size,
                    child: _buildBox(Colors.blue, '2'),
                  ),
                  FlexItem(
                    width: 80.size,
                    height: 80.size,
                    child: _buildBox(Colors.green, '3'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Example 6: Column Gap
              _buildSectionTitle('6. Column Gap'),
              _buildDescription('16px vertical spacing between items'),
              FlexBox(
                direction: FlexDirection.column,
                columnGap: 16.0.spacing,
                children: [
                  FlexItem(
                    width: 150.size,
                    height: 60.size,
                    child: _buildBox(Colors.purple, '1'),
                  ),
                  FlexItem(
                    width: 150.size,
                    height: 60.size,
                    child: _buildBox(Colors.orange, '2'),
                  ),
                  FlexItem(
                    width: 150.size,
                    height: 60.size,
                    child: _buildBox(Colors.teal, '3'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Example 7: Sticky Items
              _buildSectionTitle('7. Sticky Items'),
              _buildDescription(
                'Yellow header sticks to the top when scrolling (scroll down to see)',
              ),
              Container(
                height: 300,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: FlexBox(
                  direction: FlexDirection.column,
                  alignItems: BoxAlignmentGeometry.stretch,
                  children: [
                    FlexItem(
                      key: Key('stickyHeader'),
                      top: 0.position,
                      height: 50.size,
                      paintOrder: 1, // to ensure it paints above other items
                      child: Container(
                        color: Colors.amber,
                        alignment: Alignment.center,
                        child: const Text(
                          'Sticky Header',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    FlexItem(
                      height: 120.size,
                      child: _buildBox(Colors.red, 'Item 1'),
                    ),
                    FlexItem(
                      height: 120.size,
                      child: _buildBox(Colors.blue, 'Item 2'),
                    ),
                    FlexItem(
                      // Sticks below the header when scrolling
                      top: 100.percent.relativeChildPosition(
                        Key('stickyHeader'),
                      ),
                      paintOrder: 1,
                      height: 120.size,
                      child: _buildBox(Colors.green, 'Item 3'),
                    ),
                    FlexItem(
                      height: 120.size,
                      child: _buildBox(Colors.purple, 'Item 4'),
                    ),
                    FlexItem(
                      height: 120.size,
                      child: _buildBox(Colors.orange, 'Item 5'),
                    ),
                    FlexItem(
                      height: 120.size,
                      child: _buildBox(Colors.teal, 'Item 6'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32), // Example 8: Absolute Positioning
              _buildSectionTitle('8. Absolute Positioning'),
              _buildDescription(
                'Yellow box is absolutely positioned at top-right corner',
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: FlexBox(
                  direction: FlexDirection.row,
                  children: [
                    FlexItem(
                      width: 100.size,
                      height: 80.size,
                      child: _buildBox(Colors.red, '1'),
                    ),
                    FlexItem(
                      width: 100.size,
                      height: 80.size,
                      child: _buildBox(Colors.green, '2'),
                    ),
                    // Absolute positioned item - doesn't affect layout of other items
                    AbsoluteItem(
                      width: 120.size,
                      height: 100.size,
                      top: 10.position,
                      right: 10.position,
                      child: _buildBox(Colors.amber, 'Absolute'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        description,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildBox(Color color, String text) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
