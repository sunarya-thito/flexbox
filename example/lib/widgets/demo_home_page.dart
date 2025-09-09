import 'package:flutter/material.dart';
import '../models/demo_item.dart';

class DemoHomePage extends StatelessWidget {
  final List<DemoItem> demos = [
    DemoItem(
      title: 'Basic Layout',
      subtitle: 'Fundamental FlexBox layout concepts',
      icon: Icons.view_stream,
      route: '/basic-layout',
      color: Colors.blue,
    ),
    DemoItem(
      title: 'Positioning Types',
      subtitle: 'Relative, fixed, sticky positioning',
      icon: Icons.place,
      route: '/positioning',
      color: Colors.green,
    ),
    DemoItem(
      title: 'Relative vs Viewport',
      subtitle: 'BoxPositionType.relative vs relativeViewport',
      icon: Icons.fullscreen,
      route: '/relative-viewport',
      color: Colors.purple,
    ),
    DemoItem(
      title: 'Unconstrained Sizing',
      subtitle: 'Dynamic sizing with remaining space',
      icon: Icons.unfold_more,
      route: '/unconstrained-sizing',
      color: Colors.orange,
    ),
    DemoItem(
      title: 'Scrolling Behavior',
      subtitle: 'How positioning works with scrolling',
      icon: Icons.view_list,
      route: '/scrolling',
      color: Colors.red,
    ),
    DemoItem(
      title: 'Flex Sizing',
      subtitle: 'Flexible and ratio-based sizing',
      icon: Icons.tune,
      route: '/flex-sizing',
      color: Colors.teal,
    ),
    DemoItem(
      title: 'Absolute Positioning',
      subtitle: 'Complex absolute positioning layouts',
      icon: Icons.aspect_ratio,
      route: '/absolute-positioning',
      color: Colors.indigo,
    ),
    DemoItem(
      title: 'Sticky Positioning',
      subtitle: 'Sticky elements during scroll',
      icon: Icons.push_pin,
      route: '/sticky-positioning',
      color: Colors.pink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FlexBox Demo Collection'), elevation: 0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'FlexBox Package',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Explore different features and capabilities',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: demos.length,
                  itemBuilder: (context, index) {
                    final demo = demos[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pushNamed(context, demo.route),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                demo.color.withOpacity(0.1),
                                demo.color.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(demo.icon, size: 40, color: demo.color),
                                SizedBox(height: 12),
                                Text(
                                  demo.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  demo.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
