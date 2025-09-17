import 'package:flexiblebox/flexiblebox.dart';
import 'package:flutter/widgets.dart';
import 'package:typeson/typeson.dart';

JsonRegistry createRegistry() {
  return JsonRegistry(
    entries: [
      JsonRegistryEntry<IntrinsicSize>(
        type: 'IntrinsicSize',
        serializer: (object) => JsonObject({'key': object.key?.typeAsJson}),
        deserializer: (json) =>
            IntrinsicSize(key: json['key']?.asType<LocalKey>()),
      ),
      JsonRegistryEntry<FixedValue>(
        type: 'FixedValue',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'value': object.value.json,
          'target': object.target.index.json,
        }),
        deserializer: (json) => FixedValue(
          json['value']!.asNumber.doubleValue,
          key: json['key']?.asType<LocalKey>(),
          target: FlexTarget.values[json['target']!.asNumber.intValue],
        ),
      ),
      JsonRegistryEntry<ExpandingSize>(
        type: 'ExpandingSize',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'expansion': object.expansion.index.json,
        }),
        deserializer: (json) => ExpandingSize(
          key: json['key']?.asType<LocalKey>(),
          expansion: FlexExpansion.values[json['expansion']!.asNumber.intValue],
        ),
      ),
      JsonRegistryEntry<RatioSize>(
        type: 'RatioSize',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'ratio': object.ratio.json,
        }),
        deserializer: (json) => RatioSize(
          json['ratio']!.asNumber.doubleValue,
          key: json['key']?.asType<LocalKey>(),
        ),
      ),
      JsonRegistryEntry<RelativeValue>(
        type: 'RelativeValue',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'relative': object.relative.json,
          'target': object.target.index.json,
        }),
        deserializer: (json) => RelativeValue(
          json['relative']!.asNumber.doubleValue,
          key: json['key']?.asType<LocalKey>(),
          target: FlexTarget.values[json['target']!.asNumber.intValue],
        ),
      ),
      JsonRegistryEntry<FlexSize>(
        type: 'FlexSize',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'flex': object.flex.json,
        }),
        deserializer: (json) => FlexSize(
          json['flex']!.asNumber.doubleValue,
          key: json['key']?.asType<LocalKey>(),
        ),
      ),
      JsonRegistryEntry<TransformedValue>(
        type: 'TransformedValue',
        serializer: (object) {
          return JsonObject({
            'key': object.key?.typeAsJson,
            'original': object.original.typeAsJson,
            'transformer': object.transformer == TransformedValue.negate
                ? 'negate'.json
                : 'absolute'.json,
          });
        },
        deserializer: (json) => TransformedValue(
          json['original']!.asType<BoxValue>(),
          key: json['key']?.asType<LocalKey>(),
          transformer: json['transformer']!.asString.value == 'negate'
              ? TransformedValue.negate
              : TransformedValue.absolute,
        ),
      ),
      JsonRegistryEntry<BoxComputer>(
        type: 'BoxComputer',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'first': object.first.typeAsJson,
          'second': object.second.typeAsJson,
          'operation': object.operation == BoxComputer.addition
              ? 'addition'.json
              : object.operation == BoxComputer.subtraction
              ? 'subtraction'.json
              : object.operation == BoxComputer.max
              ? 'max'.json
              : 'min'.json,
        }),
        deserializer: (json) => BoxComputer(
          json['first']!.asType<BoxValue>(),
          json['second']!.asType<BoxValue>(),
          json['operation']!.asString.value == 'addition'
              ? BoxComputer.addition
              : json['operation']!.asString.value == 'subtraction'
              ? BoxComputer.subtraction
              : json['operation']!.asString.value == 'max'
              ? BoxComputer.max
              : BoxComputer.min,
          key: json['key']?.asType<LocalKey>(),
        ),
      ),
      JsonRegistryEntry<PrimitiveBoxComputer>(
        type: 'PrimitiveBoxComputer',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'original': object.original.typeAsJson,
          'operand': object.operand.json,
          'operation': object.operation == PrimitiveBoxComputer.multiplication
              ? 'multiplication'.json
              : object.operation == PrimitiveBoxComputer.division
              ? 'division'.json
              : object.operation == PrimitiveBoxComputer.modulo
              ? 'modulo'.json
              : 'floorDivision'.json,
        }),
        deserializer: (json) => PrimitiveBoxComputer(
          json['original']!.asType<BoxValue>(),
          json['operand']!.asNumber.doubleValue,
          json['operation']!.asString.value == 'multiplication'
              ? PrimitiveBoxComputer.multiplication
              : json['operation']!.asString.value == 'division'
              ? PrimitiveBoxComputer.division
              : json['operation']!.asString.value == 'modulo'
              ? PrimitiveBoxComputer.modulo
              : PrimitiveBoxComputer.floorDivision,
          key: json['key']?.asType<LocalKey>(),
        ),
      ),
      JsonRegistryEntry<ClampedValue>(
        type: 'ClampedValue',
        serializer: (object) => JsonObject({
          'key': object.key?.typeAsJson,
          'original': object.original.typeAsJson,
          'min': object.min?.typeAsJson,
          'max': object.max?.typeAsJson,
        }),
        deserializer: (json) => ClampedValue(
          json['original']!.asType<BoxValue>(),
          key: json['key']?.asType<LocalKey>(),
          min: json['min']?.asType<BoxValue>(),
          max: json['max']?.asType<BoxValue>(),
        ),
      ),
      JsonRegistryEntry<AlignmentGeometry>(
        type: 'AlignmentGeometry',
        serializer: (object) => JsonObject({
          'x': (object as AlignmentDirectional).start.json,
          'y': object.y.json,
        }),
        deserializer: (json) => AlignmentDirectional(
          json['x']!.asNumber.doubleValue,
          json['y']!.asNumber.doubleValue,
        ),
      ),
      JsonRegistryEntry<LocalKey>(
        type: 'LocalKey',
        serializer: (object) =>
            JsonObject({'value': (object as ValueKey<String>).value.json}),
        deserializer: (json) => ValueKey<String>(json['value']!.asString.value),
      ),
      JsonRegistryEntry<EdgeInsetsGeometry>(
        type: 'EdgeInsetsGeometry',
        serializer: (object) => JsonObject({
          'start': (object as EdgeInsetsDirectional).start.json,
          'top': object.top.json,
          'end': object.end.json,
          'bottom': object.bottom.json,
        }),
        deserializer: (json) => EdgeInsetsDirectional.fromSTEB(
          json['start']!.asNumber.doubleValue,
          json['top']!.asNumber.doubleValue,
          json['end']!.asNumber.doubleValue,
          json['bottom']!.asNumber.doubleValue,
        ),
      ),
      JsonRegistryEntry<Color>(
        type: 'Color',
        serializer: (object) => JsonObject({
          'r': object.r.json,
          'g': object.g.json,
          'b': object.b.json,
          'a': object.a.json,
        }),
        deserializer: (json) => Color.from(
          alpha: json['a']!.asNumber.doubleValue,
          red: json['r']!.asNumber.doubleValue,
          green: json['g']!.asNumber.doubleValue,
          blue: json['b']!.asNumber.doubleValue,
        ),
      ),
    ],
  );
}
