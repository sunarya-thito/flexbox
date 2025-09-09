import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Demo Page Base Class
abstract class BaseDemoPage extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  BaseDemoPage({
    required this.title,
    required this.description,
    required this.color,
  });

  Widget buildDemo(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: color.withOpacity(0.1),
              child: Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(child: buildDemo(context)),
          ],
        ),
      ),
    );
  }
}
