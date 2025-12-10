import 'package:demo/case.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/material.dart';

class _DynamicChild extends StatefulWidget {
  const _DynamicChild();

  @override
  State<_DynamicChild> createState() => _DynamicChildState();
}

class _DynamicChildState extends State<_DynamicChild> {
  bool _a = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => setState(() => _a = !_a),
        child: Text(
          _a
              ? 'Hello World'
              : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        ),
      ),
    );
  }
}

class CaseDynamicChild extends TestCase {
  @override
  Widget build() {
    return const FlexBox(
      alignItems: BoxAlignment.center,
      justifyContent: BoxAlignment.center,
      children: [
        FlexItem(
          width: SizeUnit.fitContent,
          height: SizeUnit.fitContent,
          child: _DynamicChild(),
        ),
      ],
    );
  }

  @override
  String get name => 'Dynamic Child';

  @override
  String get path => 'dynamic_child.dart';
}
