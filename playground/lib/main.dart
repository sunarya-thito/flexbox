import 'package:playground/app.dart';
import 'package:playground/controller.dart';
import 'package:playground/value.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(
    ShadcnApp(
      home: const Playground(),
      theme: ThemeData.dark(),
    ),
  );
}
