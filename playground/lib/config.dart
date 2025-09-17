import 'package:flexiblebox/flexiblebox.dart';
import 'package:flutter/widgets.dart';
import 'package:playground/templates/default.dart';
import 'package:typeson/typeson.dart';

final flexBoxTemplates = [
  FlexBoxTemplate(
    name: 'Default',
    configuration: defaultConfiguration,
  ),
];

class FlexBoxTemplate {
  final String name;
  final FlexBoxConfiguration configuration;

  FlexBoxTemplate({
    required this.name,
    required this.configuration,
  });
}

class FlexBoxConfiguration {
  final Axis direction;
  final BoxValue? spacing;
  final BoxValue? spacingStart;
  final BoxValue? spacingEnd;
  final AlignmentGeometry alignment;
  final List<FlexItemConfiguration> children;
  final bool scrollHorizontal;
  final bool scrollVertical;
  final Clip clipBehavior;
  final EdgeInsetsGeometry padding;
  final bool reverse;
  final bool reversePaint;
  final TextDirection textDirection;
  final double? width;
  final double? height;

  FlexBoxConfiguration({
    this.direction = Axis.horizontal,
    this.spacing,
    this.spacingStart,
    this.spacingEnd,
    this.alignment = AlignmentGeometry.center,
    this.children = const [],
    this.scrollHorizontal = false,
    this.scrollVertical = false,
    this.clipBehavior = Clip.hardEdge,
    this.padding = EdgeInsets.zero,
    this.reverse = false,
    this.reversePaint = false,
    this.textDirection = TextDirection.ltr,
    this.width,
    this.height,
  });

  factory FlexBoxConfiguration.fromJson(JsonObject json) {
    return FlexBoxConfiguration(
      direction: Axis.values[json['direction']!.asNumber.intValue],
      spacing: json['spacing']?.asType<BoxValue>(),
      spacingStart: json['spacingStart']?.asType<BoxValue>(),
      spacingEnd: json['spacingEnd']?.asType<BoxValue>(),
      alignment:
          json['alignment']?.asType<AlignmentGeometry>() ??
          AlignmentGeometry.center,
      children:
          json['children']?.asArray
              .map((e) => FlexItemConfiguration.fromJson(e!.asObject))
              .toList() ??
          [],
      scrollHorizontal: json['scrollHorizontal']!.asBoolean.value,
      scrollVertical: json['scrollVertical']!.asBoolean.value,
      clipBehavior: Clip.values[json['clipBehavior']!.asNumber.intValue],
      padding: json['padding']!.asType<EdgeInsetsGeometry>(),
      reverse: json['reverse']!.asBoolean.value,
      reversePaint: json['reversePaint']!.asBoolean.value,
      textDirection:
          TextDirection.values[json['textDirection']!.asNumber.intValue],
      width: json['width']?.asNumber.doubleValue,
      height: json['height']?.asNumber.doubleValue,
    );
  }

  JsonObject toJson() {
    return JsonObject({
      'direction': direction.index.json,
      'spacing': spacing?.typeAsJson,
      'spacingStart': spacingStart?.typeAsJson,
      'spacingEnd': spacingEnd?.typeAsJson,
      'alignment': alignment.typeAsJson,
      'children': children.map((e) => e.toJson()).toList().json,
      'scrollHorizontal': scrollHorizontal.json,
      'scrollVertical': scrollVertical.json,
      'clipBehavior': clipBehavior.index.json,
      'padding': padding.typeAsJson,
      'reverse': reverse.json,
      'reversePaint': reversePaint.json,
      'textDirection': textDirection.index.json,
      'width': width?.json,
      'height': height?.json,
    });
  }
}

class FlexItemConfiguration {
  final bool absolute;
  final BoxValue? mainStart;
  final BoxValue? mainEnd;
  final BoxValue? crossStart;
  final BoxValue? crossEnd;
  final BoxValue? mainSize;
  final BoxValue? crossSize;
  final BoxPositionType mainPosition;
  final BoxPositionType crossPosition;
  final int? zOrder;
  final bool mainScrollAffected;
  final bool crossScrollAffected;
  final Color? color;
  final String? label;
  final bool showLabel;
  final BoxShape shape;

  FlexItemConfiguration({
    this.absolute = false,
    this.mainStart,
    this.mainEnd,
    this.crossStart,
    this.crossEnd,
    this.mainSize,
    this.crossSize,
    this.mainPosition = BoxPositionType.fixed,
    this.crossPosition = BoxPositionType.fixed,
    this.zOrder,
    this.mainScrollAffected = true,
    this.crossScrollAffected = true,
    this.color,
    this.label,
    this.showLabel = false,
    this.shape = BoxShape.rectangle,
  });

  factory FlexItemConfiguration.fromJson(JsonObject json) {
    return FlexItemConfiguration(
      absolute: json['absolute']!.asBoolean.value,
      mainStart: json['mainStart']?.asType<BoxValue>(),
      mainEnd: json['mainEnd']?.asType<BoxValue>(),
      crossStart: json['crossStart']?.asType<BoxValue>(),
      crossEnd: json['crossEnd']?.asType<BoxValue>(),
      mainSize: json['mainSize']?.asType<BoxValue>(),
      crossSize: json['crossSize']?.asType<BoxValue>(),
      mainPosition:
          BoxPositionType.values[json['mainPosition']!.asNumber.intValue],
      crossPosition:
          BoxPositionType.values[json['crossPosition']!.asNumber.intValue],
      zOrder: json['zOrder']?.asNumber.intValue,
      mainScrollAffected: json['mainScrollAffected']!.asBoolean.value,
      crossScrollAffected: json['crossScrollAffected']!.asBoolean.value,
      color: json['color']?.asType<Color>(),
      label: json['label']?.asString.value,
      showLabel: json['showLabel']!.asBoolean.value,
      shape: BoxShape.values[json['shape']!.asNumber.intValue],
    );
  }

  JsonObject toJson() {
    return JsonObject({
      'absolute': absolute.json,
      'mainStart': mainStart?.typeAsJson,
      'mainEnd': mainEnd?.typeAsJson,
      'crossStart': crossStart?.typeAsJson,
      'crossEnd': crossEnd?.typeAsJson,
      'mainSize': mainSize?.typeAsJson,
      'crossSize': crossSize?.typeAsJson,
      'mainPosition': mainPosition.index.json,
      'crossPosition': crossPosition.index.json,
      'zOrder': zOrder?.json,
      'mainScrollAffected': mainScrollAffected.json,
      'crossScrollAffected': crossScrollAffected.json,
      'color': color?.typeAsJson,
      'label': label?.json,
      'showLabel': showLabel.json,
      'shape': shape.index.json,
    });
  }
}
