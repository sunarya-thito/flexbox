import 'package:flutter/material.dart';
import 'package:flexiblebox/flexiblebox.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexBox RelativeViewport Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RelativeViewport Test')),
      body: Container(
        height: 300, // Viewport height
        width: double.infinity,
        color: Colors.grey[200],
        child: FlexBox(
          direction: Axis.vertical,
          children: [
            // Create a tall flexbox that requires scrolling
            Container(
              height: 600, // Flexbox content height > viewport height
              color: Colors.blue[100],
              child: Stack(
                children: [
                  // Regular relative positioning (anchored to flexbox size)
                  FlexBoxChild(
                    bottom: BoxPosition.fixed(10),
                    right: BoxPosition.fixed(10),
                    verticalPosition: BoxPositionType.relative,
                    horizontalPosition: BoxPositionType.relative,
                    child: Container(
                      width: 100,
                      height: 30,
                      color: Colors.red,
                      child: Center(
                        child: Text(
                          'Relative',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // RelativeViewport positioning (anchored to viewport size)
                  FlexBoxChild(
                    bottom: BoxPosition.fixed(10),
                    left: BoxPosition.fixed(10),
                    verticalPosition: BoxPositionType.relativeViewport,
                    horizontalPosition: BoxPositionType.relativeViewport,
                    child: Container(
                      width: 120,
                      height: 30,
                      color: Colors.green,
                      child: Center(
                        child: Text(
                          'RelViewport',
                          style: TextStyle(color: Colors.white),
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
    );
  }
}
