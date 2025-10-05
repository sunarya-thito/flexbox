import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

extension TestExtension on WidgetTester {
  void expectSize(Key key, Size size) {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget, reason: 'Cannot find widget for $key');
    final renderBox = renderObject<RenderBox>(finder);
    final actualSize = renderBox.size;
    expect(actualSize, size, reason: 'Size for $key');
  }

  void expectRect(Key key, Rect rect) {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget, reason: 'Cannot find widget for $key');
    final renderBox = renderObject<RenderBox>(finder);
    final parentData = renderBox.parentData as LayoutBoxParentData;
    final offset = parentData.offset;
    expect(
      offset & renderBox.size,
      rect,
      reason: 'Rect for $key',
    );
  }

  void expectOffset(Key key, Offset offset) {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget, reason: 'Cannot find widget for $key');
    final renderBox = renderObject<RenderBox>(finder);
    final actualOffset = (renderBox.parentData as BoxParentData).offset;
    expect(actualOffset, offset, reason: 'Offset for $key');
  }
}
