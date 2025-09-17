import 'dart:math';

import 'package:flexiblebox/flexiblebox.dart';
import 'package:playground/controller.dart';
import 'package:playground/value.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

abstract class PropertyEditor<T> {
  Type get type => T;
  Widget buildEditor(Property<T> property);

  static final List<PropertyEditor> _editorInstances = [
    EnumPropertyEditor<Axis>(Axis.values),
    EnumPropertyEditor<TextDirection>(TextDirection.values),
    BooleanPropertyEditor(),
    EnumPropertyEditor<BoxPositionType>(BoxPositionType.values),
    BoxValuePropertyEditor(),
    DoublePropertyEditor(),
    NullableIntegerPropertyEditor(),
    IntegerPropertyEditor(),
    EnumPropertyEditor<Clip>(Clip.values),
    EnumPropertyEditor<BoxShape>(BoxShape.values),
    EdgeInsetsEditor(),
    AlignmentEditor(),
    NullableDoublePropertyEditor(),
    NullableStringEditor(),
    NullableColorEditor(),
  ];

  static PropertyEditor getEditor(Type type) {
    for (final editor in _editorInstances) {
      if (editor.type == type) {
        return editor;
      }
    }
    return NoPropertyEditor();
  }
}

class NoPropertyEditor<T> extends PropertyEditor<T> {
  @override
  Widget buildEditor(Property<T> property) {
    return TextField(
      readOnly: true,
      initialValue: property.value.toString(),
    );
  }
}

class EnumPropertyEditor<T extends Enum> extends PropertyEditor<T> {
  final List<T> values;

  EnumPropertyEditor(this.values);

  @override
  Widget buildEditor(Property<T> property) {
    return Select<T>(
      value: property.value,
      onChanged: (value) {
        if (value != null) {
          property.value = value;
        }
      },
      popup: SelectPopup<T>(
        items: SelectItemList(
          children: [
            for (final value in values)
              SelectItemButton(
                value: value,
                child: Text(value.name),
              ),
          ],
        ),
      ).call,
      itemBuilder: (context, value) {
        return Text(value.name);
      },
    );
  }
}

class BooleanPropertyEditor extends PropertyEditor<bool> {
  @override
  Widget buildEditor(Property<bool> property) {
    return Switch(
      value: property.value,
      onChanged: (value) {
        property.value = value;
      },
    );
  }
}

class BoxValuePropertyEditor extends PropertyEditor<BoxValue?> {
  @override
  Widget buildEditor(Property<BoxValue?> property) {
    return TextField(
      initialValue: property.value == null
          ? ''
          : boxValueToString(property.value!),
      onChanged: (value) {
        StringTokenizer tokenizer = StringTokenizer(value);
        property.value = tokenizer.nextBoxValue();
      },
      features: [
        InputFeature.hint(
          popupBuilder: (context) {
            return TooltipContainer(
              child: Text(
                'You can use values like:\n'
                '- 100px\n'
                '- 50% viewportSize\n'
                '- 30% contentSize\n'
                '- 2 flex\n'
                '- 3 ratio\n'
                '- intrinsic\n'
                '- expanding\n'
                '- smallestExpanding\n'
                '- alignCenter\n'
                '- alignStartEnd\n'
                '- alignEndStart\n'
                '- alignCenterStart\n'
                '- alignCenterEnd\n'
                '- alignStartCenter\n'
                '- alignEndCenter\n'
                '- alignStart\n'
                '- alignEnd\n'
                'You can also combine multiple values with math operations, e.g. 50% + 20px\n'
                'You can add reference to a value like "20px (#myKey)"\n'
                'and then reference it like #myKey',
              ),
            );
          },
        ),
      ],
    );
  }
}

class DoublePropertyEditor extends PropertyEditor<double> {
  @override
  Widget buildEditor(Property<double> property) {
    return TextField(
      initialValue: optimalDoubleString(property.value),
      onChanged: (value) {
        property.value =
            (_nullableMax(double.tryParse(value), 0)) ?? property.value;
      },
      features: [
        InputFeature.spinner(),
      ],
    );
  }
}

class NullableDoublePropertyEditor extends PropertyEditor<double?> {
  @override
  Widget buildEditor(Property<double?> property) {
    return TextField(
      initialValue: property.value?.toString(),
      onChanged: (value) {
        property.value = _nullableMax(
          double.tryParse(value),
          0,
        );
      },
      features: [
        InputFeature.spinner(),
      ],
    );
  }
}

double? _nullableMax(double? a, double? b) {
  if (a == null && b == null) return null;
  if (a == null) return b;
  if (b == null) return a;
  return max(a, b);
}

int? _nullableIntMax(int? a, int? b) {
  if (a == null && b == null) return null;
  if (a == null) return b;
  if (b == null) return a;
  return max(a, b);
}

class NullableIntegerPropertyEditor extends PropertyEditor<int?> {
  @override
  Widget buildEditor(Property<int?> property) {
    return TextField(
      initialValue: property.value?.toString(),
      onChanged: (value) {
        property.value = _nullableIntMax(int.tryParse(value), 0);
      },
      features: [
        InputFeature.spinner(),
      ],
    );
  }
}

class IntegerPropertyEditor extends PropertyEditor<int> {
  @override
  Widget buildEditor(Property<int> property) {
    return TextField(
      initialValue: property.value.toString(),
      onChanged: (value) {
        property.value =
            _nullableIntMax(int.tryParse(value), 0) ?? property.value;
      },
      features: [
        InputFeature.spinner(),
      ],
    );
  }
}

class EdgeInsetsEditor extends PropertyEditor<EdgeInsetsGeometry> {
  EdgeInsetsDirectional fromEdgeInsets(EdgeInsets insets) {
    return EdgeInsetsDirectional.fromSTEB(
      insets.left,
      insets.top,
      insets.right,
      insets.bottom,
    );
  }

  @override
  Widget buildEditor(Property<EdgeInsetsGeometry> property) {
    final edgeInsets = property.value is EdgeInsets
        ? fromEdgeInsets(property.value as EdgeInsets)
        : property.value as EdgeInsetsDirectional;
    const width = 70.0;
    return Center(
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: width,
                child: TextField(
                  initialValue: optimalDoubleString(edgeInsets.top),
                  onChanged: (value) {
                    final top = double.tryParse(value) ?? edgeInsets.top;
                    property.value = EdgeInsetsDirectional.fromSTEB(
                      edgeInsets.start,
                      max(top, 0),
                      edgeInsets.end,
                      edgeInsets.bottom,
                    );
                  },
                  features: [
                    InputFeature.spinner(),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: width,
                  child: TextField(
                    initialValue: optimalDoubleString(edgeInsets.start),
                    onChanged: (value) {
                      final start = double.tryParse(value) ?? edgeInsets.start;
                      property.value = EdgeInsetsDirectional.fromSTEB(
                        max(start, 0),
                        edgeInsets.top,
                        edgeInsets.end,
                        edgeInsets.bottom,
                      );
                    },
                    features: [
                      InputFeature.spinner(),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: width,
                  child: TextField(
                    initialValue: optimalDoubleString(edgeInsets.end),
                    onChanged: (value) {
                      final end = double.tryParse(value) ?? edgeInsets.end;
                      property.value = EdgeInsetsDirectional.fromSTEB(
                        edgeInsets.start,
                        edgeInsets.top,
                        max(end, 0),
                        edgeInsets.bottom,
                      );
                    },
                    features: [
                      InputFeature.spinner(),
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: SizedBox(
                width: width,
                child: TextField(
                  initialValue: optimalDoubleString(edgeInsets.bottom),
                  onChanged: (value) {
                    final bottom = double.tryParse(value) ?? edgeInsets.bottom;
                    property.value = EdgeInsetsDirectional.fromSTEB(
                      edgeInsets.start,
                      edgeInsets.top,
                      edgeInsets.end,
                      max(bottom, 0),
                    );
                  },
                  features: [
                    InputFeature.spinner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlignmentEditor extends PropertyEditor<AlignmentGeometry> {
  AlignmentDirectional fromAlignment(Alignment alignment) {
    return AlignmentDirectional(alignment.x, alignment.y);
  }

  @override
  Widget buildEditor(Property<AlignmentGeometry> property) {
    final alignment = property.value is Alignment
        ? fromAlignment(property.value as Alignment)
        : property.value as AlignmentDirectional;
    final selectedVariance = ButtonVariance.primary;
    final unselectedVariance = ButtonVariance.ghost;
    return Center(
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.format_align_left),
                  variance: alignment == AlignmentDirectional.topStart
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.topStart;
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.align_vertical_top),
                  variance: alignment == AlignmentDirectional.topCenter
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.topCenter;
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.format_align_right),
                  variance: alignment == AlignmentDirectional.topEnd
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.topEnd;
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.align_horizontal_left),
                  variance: alignment == AlignmentDirectional.centerStart
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.centerStart;
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.format_align_center),
                  variance: alignment == AlignmentDirectional.center
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = Alignment.center;
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.align_horizontal_right),
                  variance: alignment == AlignmentDirectional.centerEnd
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.centerEnd;
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.format_align_left),
                  variance: alignment == AlignmentDirectional.bottomStart
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.bottomStart;
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.align_vertical_bottom),
                  variance: alignment == AlignmentDirectional.bottomCenter
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.bottomCenter;
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.format_align_right),
                  variance: alignment == AlignmentDirectional.bottomEnd
                      ? selectedVariance
                      : unselectedVariance,
                  onPressed: () {
                    property.value = AlignmentDirectional.bottomEnd;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NullableStringEditor extends PropertyEditor<String?> {
  @override
  Widget buildEditor(Property<String?> property) {
    return TextField(
      initialValue: property.value,
      onChanged: (value) {
        property.value = value.isEmpty ? null : value;
      },
    );
  }
}

class NullableColorEditor extends PropertyEditor<Color?> {
  @override
  Widget buildEditor(Property<Color?> property) {
    return ColorInput(
      color: ColorDerivative.fromColor(
        property.value ?? Colors.transparent,
      ),
      onChanged: (value) {
        property.value = value.toColor();
      },
    ).sized(height: 28);
  }
}
