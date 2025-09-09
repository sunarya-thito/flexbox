import 'package:flutter/material.dart';

// Import all demo pages
import 'demos/basic_layout_demo.dart';
import 'demos/positioning_demo.dart';
import 'demos/relative_viewport_demo.dart';
import 'demos/unconstrained_sizing_demo.dart';
import 'demos/scrolling_demo.dart';
import 'demos/flex_sizing_demo.dart';
import 'demos/absolute_positioning_demo.dart';
import 'demos/sticky_positioning_demo.dart';
import 'widgets/demo_home_page.dart';

void main() {
  runApp(FlexBoxDemoApp());
}

class FlexBoxDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexBox Demo Collection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DemoHomePage(),
      routes: {
        '/basic-layout': (context) => BasicLayoutDemo(),
        '/positioning': (context) => PositioningDemo(),
        '/relative-viewport': (context) => RelativeViewportDemo(),
        '/unconstrained-sizing': (context) => UnconstrainedSizingDemo(),
        '/scrolling': (context) => ScrollingDemo(),
        '/flex-sizing': (context) => FlexSizingDemo(),
        '/absolute-positioning': (context) => AbsolutePositioningDemo(),
        '/sticky-positioning': (context) => StickyPositioningDemo(),
      },
    );
  }
}
