// ignore_for_file: avoid_print

import 'dart:io';

import 'package:demo/helper.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

abstract class TestCase {
  String get name;
  String get path;
  String get fullPath => 'package:demo/cases/$path';
  //https://github.com/sunarya-thito/flexbox/blob/master/demo/lib/cases/case_absolute.dart
  String get gitPath =>
      'https://github.com/sunarya-thito/flexbox/blob/master/demo/lib/cases/$path';
  String get rawGitPath =>
      'https://raw.githubusercontent.com/sunarya-thito/flexbox/refs/heads/master/demo/lib/cases/$path';
  Widget build();
  Widget buildTest() => Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: build()),
  );

  void generateTest() {
    testWidgets(name, (WidgetTester tester) async {
      print('--- GENERATED TEST FOR $fullPath ---');
      StringBuffer buffer = StringBuffer();
      await tester.pumpWidget(buildTest());
      await tester.pumpAndSettle();
      final finder = find.byKey(key0);
      expect(finder, findsOneWidget, reason: 'Cannot find widget for $key0');
      final renderBox = tester.renderObject<RenderBox>(finder);
      final size = renderBox.size;
      buffer.writeln(
        'tester.expectSize(key0, Size(${size.width}, ${size.height}));',
      );
      for (var i = 1; i <= 20; i++) {
        final key = Key('key$i');
        final finder = find.byKey(key);
        if (finder.evaluate().isEmpty) {
          break;
        }
        final renderBox = tester.renderObject<RenderBox>(finder);
        final offset = (renderBox.parentData as BoxParentData).offset;
        final size = renderBox.size;
        buffer.writeln(
          'tester.expectRect(key$i, Offset(${offset.dx}, ${offset.dy}) & Size(${size.width}, ${size.height}));',
        );
      }
      // get the name without .dart
      String name = path.substring(0, path.length - 5);
      File file = File('test/${name}_test.dart');
      if (file.existsSync()) {
        print('File test/${name}_test.dart already exists, skipping write.');
      } else {
        /* Should generate the following content:
        import 'package:demo/cases/case_simple.dart';

        void main() {
          TestCase case = CaseSimple();
          testWidgets(case.name, (WidgetTester tester) async {
            await tester.pumpWidget(case.buildTest());
            await tester.pumpAndSettle();
            // perform the test
            expectSize(key0, Size(300.0, 100.0));
            expectRect(key1, Offset(0.0, 0.0) & Size(100.0, 100.0));
            expectRect(key2, Offset(100.0, 0.0) & Size(100.0, 100.0));
            expectRect(key3, Offset(200.0, 0.0) & Size(100.0, 100.0));
          });
        }
        */
        StringBuffer fileContent = StringBuffer();
        fileContent.writeln("import '$fullPath';");
        fileContent.writeln("import 'helper.dart';");
        fileContent.writeln("import 'package:demo/case.dart';");
        fileContent.writeln("import 'package:demo/helper.dart';");
        fileContent.writeln(
          'import \'package:flutter_test/flutter_test.dart\';',
        );
        fileContent.writeln('import \'package:flutter/rendering.dart\';');
        fileContent.writeln('');
        fileContent.writeln('void main() {');
        fileContent.writeln('  TestCase testCase = $runtimeType();');
        fileContent.writeln(
          '  testWidgets(testCase.name, (WidgetTester tester) async {',
        );
        fileContent.writeln(
          '    await tester.pumpWidget(testCase.buildTest());',
        );
        fileContent.writeln('    await tester.pumpAndSettle();');
        fileContent.writeln('    // perform the test');
        // buffer.toString() does not have indentation
        fileContent.writeln(
          buffer.toString().split('\n').map((line) => '    $line').join('\n'),
        );
        fileContent.writeln('  });');
        fileContent.writeln('}');
        file.writeAsStringSync(fileContent.toString());
        print('File test/${name}_test.dart has been created.');
      }
    });
  }

  // void expectRect(Key key, Rect rect) {
  //   final finder = find.byKey(key);
  //   expect(finder, findsOneWidget, reason: 'Cannot find widget for $key');
  //   final renderBox = tester!.renderObject<RenderBox>(finder);
  //   final offset = (renderBox.parentData as BoxParentData).offset;
  //   expect(offset & renderBox.size, rect, reason: 'Rect for $key');
  // }

  // void expectOffset(Key key, Offset offset) {
  //   final finder = find.byKey(key);
  //   expect(finder, findsOneWidget, reason: 'Cannot find widget for $key');
  //   final renderBox = tester!.renderObject<RenderBox>(finder);
  //   final actualOffset = (renderBox.parentData as BoxParentData).offset;
  //   expect(actualOffset, offset, reason: 'Offset for $key');
  // }

  // void expectSize(Key key, Size size) {
  //   final finder = find.byKey(key);
  //   expect(finder, findsOneWidget, reason: 'Cannot find widget for $key');
  //   final renderBox = tester!.renderObject<RenderBox>(finder);
  //   final actualSize = renderBox.size;
  //   expect(actualSize, size, reason: 'Size for $key');
  // }
}
