import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Import all demo pages
import 'demos/basic_layout_demo.dart';
import 'demos/flex_sizing_demo.dart';
import 'demos/scrolling_demo.dart';
import 'demos/intrinsic_sizing_demo.dart';
import 'demos/unconstrained_sizing_demo.dart';
import 'demos/ratio_sizing_demo.dart';
import 'demos/relative_positioning_demo.dart';
import 'demos/advanced_layout_demo.dart';
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
        '/scrolling': (context) => ScrollingDemo(),
        '/flex-sizing': (context) => FlexSizingDemo(),
        '/intrinsic-sizing': (context) => IntrinsicSizingDemo(),
        '/unconstrained-sizing': (context) => UnconstrainedSizingDemo(),
        '/ratio-sizing': (context) => RatioSizingDemo(),
        '/relative-positioning': (context) => RelativePositioningDemo(),
        '/advanced-layout': (context) => AdvancedLayoutDemo(),
      },
    );
  }
}
