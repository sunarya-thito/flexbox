// import 'package:demo/case.dart';
// import 'package:flutter/material.dart';
// import 'package:flexbox/lib/src/painter/border.dart' as b;

// class CaseBorderPainter extends TestCase {
//   @override
//   String get name => 'Border Painter';

//   @override
//   String get path => 'case_border_painter.dart';

//   @override
//   Widget build() {
//     return const BorderPainterDemo();
//   }
// }

// class BorderPainterDemo extends StatefulWidget {
//   const BorderPainterDemo({super.key});

//   @override
//   State<BorderPainterDemo> createState() => _BorderPainterDemoState();
// }

// class _BorderPainterDemoState extends State<BorderPainterDemo> {
//   final _topLeft = ValueNotifier<double>(20.0);
//   final _topRight = ValueNotifier<double>(20.0);
//   final _bottomLeft = ValueNotifier<double>(20.0);
//   final _bottomRight = ValueNotifier<double>(20.0);

//   final _topWidth = ValueNotifier<double>(10.0);
//   final _rightWidth = ValueNotifier<double>(10.0);
//   final _bottomWidth = ValueNotifier<double>(10.0);
//   final _leftWidth = ValueNotifier<double>(10.0);

//   final _topAlignment = ValueNotifier<double>(0.5);
//   final _rightAlignment = ValueNotifier<double>(0.5);
//   final _bottomAlignment = ValueNotifier<double>(0.5);
//   final _leftAlignment = ValueNotifier<double>(0.5);

//   final _topColor = ValueNotifier<Color>(Colors.red);
//   final _rightColor = ValueNotifier<Color>(Colors.green);
//   final _bottomColor = ValueNotifier<Color>(Colors.blue);
//   final _leftColor = ValueNotifier<Color>(Colors.orange);

//   final _borderStyle = ValueNotifier<b.BorderStyle>(const b.BorderStyle.solid());
//   final _dashArray = ValueNotifier<List<double>>([10, 5]);

//   final _strokeJoin = ValueNotifier<StrokeJoin>(StrokeJoin.miter);
//   final _strokeCap = ValueNotifier<StrokeCap>(StrokeCap.butt);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ValueListenableBuilder(
//               valueListenable: _topLeft,
//               builder: (context, _, __) => ValueListenableBuilder(
//                 valueListenable: _topRight,
//                 builder: (context, _, __) => ValueListenableBuilder(
//                   valueListenable: _bottomLeft,
//                   builder: (context, _, __) => ValueListenableBuilder(
//                     valueListenable: _bottomRight,
//                     builder: (context, _, __) => ValueListenableBuilder(
//                       valueListenable: _topWidth,
//                       builder: (context, _, __) => ValueListenableBuilder(
//                         valueListenable: _rightWidth,
//                         builder: (context, _, __) => ValueListenableBuilder(
//                           valueListenable: _bottomWidth,
//                           builder: (context, _, __) => ValueListenableBuilder(
//                             valueListenable: _leftWidth,
//                             builder: (context, _, __) => ValueListenableBuilder(
//                               valueListenable: _topAlignment,
//                               builder: (context, _, __) => ValueListenableBuilder(
//                                 valueListenable: _rightAlignment,
//                                 builder: (context, _, __) => ValueListenableBuilder(
//                                   valueListenable: _bottomAlignment,
//                                   builder: (context, _, __) => ValueListenableBuilder(
//                                     valueListenable: _leftAlignment,
//                                     builder: (context, _, __) => ValueListenableBuilder(
//                                       valueListenable: _topColor,
//                                       builder: (context, _, __) => ValueListenableBuilder(
//                                         valueListenable: _rightColor,
//                                         builder: (context, _, __) => ValueListenableBuilder(
//                                           valueListenable: _bottomColor,
//                                           builder: (context, _, __) => ValueListenableBuilder(
//                                             valueListenable: _leftColor,
//                                             builder: (context, _, __) => ValueListenableBuilder(
//                                               valueListenable: _borderStyle,
//                                               builder: (context, _, __) => ValueListenableBuilder(
//                                                 valueListenable: _dashArray,
//                                                 builder: (context, _, __) => ValueListenableBuilder(
//                                                   valueListenable: _strokeJoin,
//                                                   builder: (context, _, __) => ValueListenableBuilder(
//                                                     valueListenable: _strokeCap,
//                                                     builder: (context, _, __) {
//                                                       return Center(
//                                                         child: CustomPaint(
//                                                           size: const Size(300, 200),
//                                                           painter: _DemoBorderPainter(
//                                                             borderRadius: BorderRadius.only(
//                                                               topLeft: Radius.circular(_topLeft.value),
//                                                               topRight: Radius.circular(_topRight.value),
//                                                               bottomLeft: Radius.circular(_bottomLeft.value),
//                                                               bottomRight: Radius.circular(_bottomRight.value),
//                                                             ),
//                                                             border: b.BoxBorder(
//                                                               top: b.BoxBorderSide(width: _topWidth.value, alignment: _topAlignment.value, fill: b.BoxBorderColorFill(_topColor.value)),
//                                                               right: b.BoxBorderSide(width: _rightWidth.value, alignment: _rightAlignment.value, fill: b.BoxBorderColorFill(_rightColor.value)),
//                                                               bottom: b.BoxBorderSide(width: _bottomWidth.value, alignment: _bottomAlignment.value, fill: b.BoxBorderColorFill(_bottomColor.value)),
//                                                               left: b.BoxBorderSide(width: _leftWidth.value, alignment: _leftAlignment.value, fill: b.BoxBorderColorFill(_leftColor.value)),
//                                                             ),
//                                                             borderStyle: _borderStyle.value,
//                                                             strokeJoin: _strokeJoin.value,
//                                                             strokeCap: _strokeCap.value,
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildControls(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControls() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Border Radius', style: TextStyle(fontWeight: FontWeight.bold)),
//         _buildSlider('Top Left', _topLeft, 0, 100),
//         _buildSlider('Top Right', _topRight, 0, 100),
//         _buildSlider('Bottom Left', _bottomLeft, 0, 100),
//         _buildSlider('Bottom Right', _bottomRight, 0, 100),
//         const Divider(),
//         const Text('Border Width', style: TextStyle(fontWeight: FontWeight.bold)),
//         _buildSlider('Top', _topWidth, 0, 50),
//         _buildSlider('Right', _rightWidth, 0, 50),
//         _buildSlider('Bottom', _bottomWidth, 0, 50),
//         _buildSlider('Left', _leftWidth, 0, 50),
//         const Divider(),
//         const Text('Border Alignment', style: TextStyle(fontWeight: FontWeight.bold)),
//         _buildSlider('Top', _topAlignment, 0, 1),
//         _buildSlider('Right', _rightAlignment, 0, 1),
//         _buildSlider('Bottom', _bottomAlignment, 0, 1),
//         _buildSlider('Left', _leftAlignment, 0, 1),
//         const Divider(),
//         const Text('Border Color', style: TextStyle(fontWeight: FontWeight.bold)),
//         _buildColorPicker('Top', _topColor),
//         _buildColorPicker('Right', _rightColor),
//         _buildColorPicker('Bottom', _bottomColor),
//         _buildColorPicker('Left', _leftColor),
//         const Divider(),
//         const Text('Border Style', style: TextStyle(fontWeight: FontWeight.bold)),
//         _buildBorderStyleSelector(),
//         const Divider(),
//         const Text('Stroke Join', style: TextStyle(fontWeight: FontWeight.bold)),
//         _buildStrokeJoinSelector(),
//         const Divider(),
//         const Text('Stroke Cap', style: TextStyle(fontWeight: FontWeight.bold)),
//         _buildStrokeCapSelector(),
//       ],
//     );
//   }

//   Widget _buildSlider(String label, ValueNotifier<double> notifier, double min, double max) {
//     return Row(
//       children: [
//         SizedBox(width: 100, child: Text(label)),
//         Expanded(
//           child: ValueListenableBuilder<double>(
//             valueListenable: notifier,
//             builder: (context, value, child) {
//               return Slider(
//                 value: value,
//                 min: min,
//                 max: max,
//                 divisions: (max - min).toInt(),
//                 label: value.toStringAsFixed(2),
//                 onChanged: (newValue) => notifier.value = newValue,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildColorPicker(String label, ValueNotifier<Color> notifier) {
//     return Row(
//       children: [
//         SizedBox(width: 100, child: Text(label)),
//         ValueListenableBuilder<Color>(
//           valueListenable: notifier,
//           builder: (context, color, child) {
//             return GestureDetector(
//               onTap: () async {
//                 // This is a placeholder for a color picker.
//                 // A real implementation would use a color picker package.
//                 final newColor = await showDialog<Color>(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Pick a color'),
//                     content: SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           RadioListTile(value: Colors.red, groupValue: color, onChanged: (c) => Navigator.pop(context, c), title: const Text('Red')),
//                           RadioListTile(value: Colors.green, groupValue: color, onChanged: (c) => Navigator.pop(context, c), title: const Text('Green')),
//                           RadioListTile(value: Colors.blue, groupValue: color, onChanged: (c) => Navigator.pop(context, c), title: const Text('Blue')),
//                           RadioListTile(value: Colors.orange, groupValue: color, onChanged: (c) => Navigator.pop(context, c), title: const Text('Orange')),
//                           RadioListTile(value: Colors.purple, groupValue: color, onChanged: (c) => Navigator.pop(context, c), title: const Text('Purple')),
//                           RadioListTile(value: Colors.black, groupValue: color, onChanged: (c) => Navigator.pop(context, c), title: const Text('Black')),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//                 if (newColor != null) {
//                   notifier.value = newColor;
//                 }
//               },
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: color,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.black),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildBorderStyleSelector() {
//     return ValueListenableBuilder<b.BorderStyle>(
//       valueListenable: _borderStyle,
//       builder: (context, style, child) {
//         return DropdownButton<b.BorderStyle>(
//           value: style,
//           onChanged: (newValue) {
//             if (newValue != null) {
//               _borderStyle.value = newValue;
//             }
//           },
//           items: [
//             DropdownMenuItem(
//               value: const b.BorderStyle.solid(),
//               child: const Text('Solid'),
//             ),
//             DropdownMenuItem(
//               value: b.BorderStyle.dashed(_dashArray.value),
//               child: const Text('Dashed'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildStrokeJoinSelector() {
//     return ValueListenableBuilder<StrokeJoin>(
//       valueListenable: _strokeJoin,
//       builder: (context, join, child) {
//         return DropdownButton<StrokeJoin>(
//           value: join,
//           onChanged: (newValue) {
//             if (newValue != null) {
//               _strokeJoin.value = newValue;
//             }
//           },
//           items: StrokeJoin.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildStrokeCapSelector() {
//     return ValueListenableBuilder<StrokeCap>(
//       valueListenable: _strokeCap,
//       builder: (context, cap, child) {.
//         return DropdownButton<StrokeCap>(
//           value: cap,
//           onChanged: (newValue) {
//             if (newValue != null) {
//               _strokeCap.value = newValue;
//             }
//           },
//           items: StrokeCap.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
//         );
//       },
//     );
//   }
// }

// class _DemoBorderPainter extends CustomPainter {
//   final BorderRadius borderRadius;
//   final b.BoxBorder border;
//   final b.BorderStyle borderStyle;
//   final StrokeJoin strokeJoin;
//   final StrokeCap strokeCap;

//   _DemoBorderPainter({
//     required this.borderRadius,
//     required this.border,
//     required this.borderStyle,
//     required this.strokeJoin,
//     required this.strokeCap,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     b.paintBorder(
//       canvas: canvas,
//       rect: rect,
//       borderRadius: borderRadius,
//       border: border,
//       borderStyle: borderStyle,
//       strokeJoin: strokeJoin,
//       strokeCap: strokeCap,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant _DemoBorderPainter oldDelegate) {
//     return oldDelegate.borderRadius != borderRadius ||
//         oldDelegate.border != border ||
//         oldDelegate.borderStyle != borderStyle ||
//         oldDelegate.strokeJoin != strokeJoin ||
//         oldDelegate.strokeCap != strokeCap;
//   }
// }
