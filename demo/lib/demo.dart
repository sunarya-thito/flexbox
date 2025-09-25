import 'dart:ui';

import 'package:demo/case.dart';
import 'package:flutter/material.dart';

class DemoApp extends StatefulWidget {
  final List<TestCase> testCases;
  const DemoApp({super.key, required this.testCases});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 200,
          child: ListView.builder(
            itemCount: widget.testCases.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.testCases[index].name),
                selected: index == selectedIndex,
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              );
            },
          ),
        ),
        VerticalDivider(),
        Expanded(
          child: ScrollConfiguration(
            behavior: MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: Center(
              child: widget.testCases[selectedIndex].build(),
            ),
          ),
        ),
      ],
    );
  }
}
