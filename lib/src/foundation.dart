import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// FlexBoxWrap is still WIP and not used yet
// its so cunty 💅 cant wait to implement this (i can)
enum FlexBoxWrap {
  none,

  /// If the items overflow the main axis,
  /// they will be wrapped to the next line
  /// in the cross axis direction.
  wrap,
  wrapReverse,
}

double _clamp(double value, double? min, double? max) {
  if (min != null && value < min) {
    return min;
  }
  if (max != null && value > max) {
    return max;
  }
  return value;
}

const ({
  bool needsFlexFactor,
  bool needsMainAxisViewportSize,
  bool needsCrossAxisViewportSize,
  bool needsMainAxisContentSize,
  bool needsCrossAxisContentSize,
})
_noDependency = (
  needsFlexFactor: false,
  needsMainAxisViewportSize: false,
  needsCrossAxisViewportSize: false,
  needsMainAxisContentSize: false,
  needsCrossAxisContentSize: false,
);

abstract class BoxValue {
  final LocalKey? key;
  final FlexTarget target;
  const BoxValue({this.key, this.target = FlexTarget.viewport});
  const factory BoxValue.intrinsic({LocalKey? key}) = IntrinsicSize;
  const factory BoxValue.fixed(double size, {LocalKey? key}) = FixedValue;
  const factory BoxValue.expanding({
    LocalKey? key,
    FlexExpansion expansion,
  }) = ExpandingSize;
  const factory BoxValue.ratio(
    double ratio, {
    LocalKey? key,
  }) = RatioSize;
  const factory BoxValue.relative(
    double relative, {
    LocalKey? key,
    FlexTarget target,
  }) = RelativeValue;
  const factory BoxValue.flex(double flex, {LocalKey? key}) = FlexSize;
  const factory BoxValue.linked(LocalKey targetKey, {LocalKey? key}) =
      LinkedValue;
  const factory BoxValue.computer(
    BoxValue first,
    BoxValue second,
    BoxComputerOperation operation, {
    LocalKey? key,
  }) = BoxComputer;
  const factory BoxValue.transformed(
    BoxValue original, {
    required BoxTransformer transformer,
    LocalKey? key,
  }) = TransformedValue;
  const factory BoxValue.clamped(
    BoxValue original, {
    BoxValue? min,
    BoxValue? max,
    LocalKey? key,
  }) = ClampedValue;
  const factory BoxValue.aligned({
    BoxAlignmentGeometry alignment,
    BoxAlignmentGeometry anchor,
    LocalKey? key,
    FlexTarget target,
  }) = AlignedPosition;

  bool get isPosition => true;
  bool get isSize => true;

  BoxValue withKey(LocalKey key);
  BoxValue withTarget(FlexTarget target);
  BoxValue copyWith({LocalKey? key, FlexTarget? target});

  void debugIsSizeValid() {}

  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required bool reverse,
    required Map<Key, double> dependencies,
  });

  ({
    // if true, it means this size needs to know the parent size in the main axis before it can be computed
    bool needsMainAxisViewportSize,
    // if true, it means this size needs to know the parent size in the cross axis before it can be computed
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
    // if true, it means the parent needs to consensus the flex sizes of all children
    // then compute the flex factor for this child, THEN this size can be computed
    bool needsFlexFactor,
    // Iterable<Key> dependencies,
  })
  getRequiredInputs({
    // if true and the direction is horizontal, then this size is for width
    // if false and the direction is horizontal, then this size is for height
    // if true and the direction is vertical, then this size is for height
    // if false and the direction is vertical, then this size is for width
    required bool mainAxis,
    // if true, then the cross axis requires this size to be computed first
    // if false, then the cross axis does not care whether this size is computed first or later
    // if null, then we don't know whether the cross axis is a very needy boy or not yet
    bool? crossRequiresSize,
  }) {
    return _noDependency;
  }

  bool get needsCrossAxis => false;

  double? computeTotalFlex(double? biggestFlex) => null;

  // if this returns null, it means
  // there is a dependency that has not been resolved yet
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  });

  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  });

  BoxValue operator -() =>
      TransformedValue(this, transformer: TransformedValue.negate);

  BoxValue operator +(BoxValue other) =>
      BoxComputer(this, other, BoxComputer.addition);
  BoxValue operator -(BoxValue other) =>
      BoxComputer(this, other, BoxComputer.subtraction);
  BoxValue operator *(double other) => PrimitiveBoxComputer(
    this,
    other,
    PrimitiveBoxComputer.multiplication,
  );
  BoxValue operator /(double other) =>
      PrimitiveBoxComputer(this, other, PrimitiveBoxComputer.division);
  BoxValue operator %(double other) =>
      PrimitiveBoxComputer(this, other, PrimitiveBoxComputer.modulo);
  BoxValue operator ~() =>
      TransformedValue(this, transformer: TransformedValue.negate);
  BoxValue operator ~/(double other) => PrimitiveBoxComputer(
    this,
    other,
    PrimitiveBoxComputer.floorDivision,
  );
  BoxValue abs() =>
      TransformedValue(this, transformer: TransformedValue.absolute);
  BoxValue clamp({BoxValue? min, BoxValue? max}) {
    if (min == null && max == null) {
      return this;
    }
    return ClampedValue(this, min: min, max: max);
  }
}

class IntrinsicSize extends BoxValue {
  const IntrinsicSize({super.key, super.target})
    : assert(
        target != FlexTarget.child,
        'IntrinsicSize cannot be relative to child',
      );

  @override
  IntrinsicSize withKey(LocalKey key) {
    return IntrinsicSize(key: key, target: target);
  }

  @override
  IntrinsicSize withTarget(FlexTarget target) {
    return IntrinsicSize(key: key, target: target);
  }

  @override
  IntrinsicSize copyWith({LocalKey? key, FlexTarget? target}) {
    return IntrinsicSize(
      key: key ?? this.key,
      target: target ?? this.target,
    );
  }

  @override
  bool get isPosition => false;

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required bool reverse,
    required Map<Key, double> dependencies,
  }) {
    throw FlutterError('IntrinsicSize cannot be used for positioning');
  }

  @override
  double computeIntrinsicSize({
    required RenderBox? child,
    required Axis
    direction, // not the direction of the flex box, but the direction of the size being computed
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    if (child == null) {
      if (key != null) {
        dependencies[key!] = 0.0;
      }
      return 0.0;
    }
    double result = switch ((direction, computeMax)) {
      (Axis.horizontal, true) => child.getMaxIntrinsicWidth(extent),
      (Axis.horizontal, false) => child.getMinIntrinsicWidth(extent),
      (Axis.vertical, true) => child.getMaxIntrinsicHeight(extent),
      (Axis.vertical, false) => child.getMinIntrinsicHeight(extent),
    };
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    // double? mainAxisParentSize,
    // double? crossAxisParentSize,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    if (child == null) {
      if (key != null) {
        dependencies[key!] = 0.0;
      }
      return (recomputeFlex: false, result: 0.0, flexResult: 0.0);
    }
    double mainAxisParentSize = _getBaseSize(
      target,
      contentSize: mainAxisContentSize,
      viewportSize: mainAxisViewportSize,
    );
    double crossAxisParentSize = _getBaseSize(
      target,
      contentSize: crossAxisContentSize ?? double.infinity,
      viewportSize: crossAxisViewportSize ?? double.infinity,
    );
    double result;
    switch (direction) {
      case Axis.horizontal:
        result = child.getMaxIntrinsicWidth(
          mainAxis ? crossAxisParentSize : mainAxisParentSize,
        );
        break;
      case Axis.vertical:
        result = child.getMaxIntrinsicHeight(
          mainAxis ? crossAxisParentSize : mainAxisParentSize,
        );
    }
    if (key != null) {
      dependencies[key!] = result;
    }
    return (
      recomputeFlex: false,
      result: result,
      flexResult: 0.0,
    );
  }

  @override
  String toString() {
    return 'IntrinsicSize()';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntrinsicSize;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode;
  }
}

class FixedValue extends BoxValue {
  final double value;

  const FixedValue(this.value, {super.key, super.target})
    : assert(
        value == value,
        'FixedValue size must not be NaN',
      ),
      assert(
        value != double.infinity && value != double.negativeInfinity,
        'FixedValue size must be a finite number, got $value. If you want an infinite size, use ExpandingSize instead.',
      );

  @override
  FixedValue withKey(LocalKey key) {
    return FixedValue(value, key: key, target: target);
  }

  @override
  FixedValue withTarget(FlexTarget target) {
    return FixedValue(value, key: key, target: target);
  }

  @override
  FixedValue copyWith({LocalKey? key, FlexTarget? target, double? value}) {
    return FixedValue(
      value ?? this.value,
      key: key ?? this.key,
      target: target ?? this.target,
    );
  }

  @override
  double computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required bool reverse,
    required TextDirection textDirection,
    required Map<Key, double> dependencies,
  }) {
    double value = this.value;
    if (reverse) {
      switch (target) {
        case FlexTarget.viewport:
          value = viewportSize - value;
          break;
        case FlexTarget.content:
          value = contentSize - value;
          break;
        case FlexTarget.line:
          // for now, we treat line as content
          // because we do not have line information here
          value = contentSize - value;
          break;
        case FlexTarget.child:
          value = childSize - value;
          break;
      }
    }
    if (key != null) {
      dependencies[key!] = value;
    }
    return value;
  }

  @override
  void debugIsSizeValid() {
    if (value.isNaN) {
      throw FlutterError('FixedSize size must be a finite number, got $value');
    }
    if (value.isInfinite) {
      throw FlutterError(
        'FixedSize size must be a finite number, got $value. If you want an infinite size, use ExpandingSize instead.',
      );
    }
  }

  @override
  double computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double result = value;
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  String toString() {
    return 'FixedSize(size: $value)';
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    if (key != null) {
      dependencies[key!] = value;
    }
    return (recomputeFlex: false, result: value, flexResult: 0.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedValue && other.value == value;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, value);
  }
}

enum FlexExpansion {
  /// Will expand based on the smallest flex factor in the flexbox
  smallest,

  /// Will expand based on the biggest flex factor in the flexbox
  biggest,
}

class ExpandingSize extends BoxValue {
  final FlexExpansion expansion;
  const ExpandingSize({
    super.key,
    this.expansion = FlexExpansion.biggest,
    super.target,
  }) : assert(
         target != FlexTarget.child,
         'ExpandingSize cannot be relative to child',
       );

  @override
  ExpandingSize withKey(LocalKey key) {
    return ExpandingSize(key: key, expansion: expansion, target: target);
  }

  @override
  ExpandingSize withTarget(FlexTarget target) {
    return ExpandingSize(key: key, expansion: expansion, target: target);
  }

  @override
  ExpandingSize copyWith({
    LocalKey? key,
    FlexTarget? target,
    FlexExpansion? expansion,
  }) {
    return ExpandingSize(
      key: key ?? this.key,
      target: target ?? this.target,
      expansion: expansion ?? this.expansion,
    );
  }

  @override
  bool get isPosition => false;

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required bool reverse,
    required Map<Key, double> dependencies,
  }) {
    throw FlutterError('ExpandingSize cannot be used for positioning');
  }

  @override
  ({
    bool needsFlexFactor,
    bool needsMainAxisViewportSize,
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsMainAxisViewportSize: false,
      needsCrossAxisViewportSize: !mainAxis && target == FlexTarget.viewport,
      needsMainAxisContentSize: false,
      needsCrossAxisContentSize: !mainAxis && target == FlexTarget.content,
      needsFlexFactor: mainAxis,
    );
  }

  @override
  double computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    if (key != null) {
      dependencies[key!] = 0.0;
    }
    return 0.0;
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    if (biggestFlex == null) {
      return double.nan;
    }
    return biggestFlex;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    double result;
    if (mainAxis) {
      if (flexFactor == null) {
        result = 0.0;
      } else {
        if (expansion == FlexExpansion.biggest) {
          biggestFlex ??= 1;
          result = biggestFlex * flexFactor;
        } else {
          smallestFlex ??= 1;
          result = smallestFlex * flexFactor;
        }
      }
    } else {
      result = _getBaseSize(
        target,
        contentSize: crossAxisContentSize ?? 0.0,
        viewportSize: crossAxisViewportSize ?? 0.0,
      );
    }
    if (key != null) {
      dependencies[key!] = result;
    }
    return (
      recomputeFlex: false,
      flexResult: mainAxis ? result : 0.0,
      result: mainAxis ? 0.0 : result,
    );
  }

  @override
  String toString() {
    return 'UnconstrainedSize()';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpandingSize;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode;
  }
}

class RatioSize extends BoxValue {
  final double ratio;

  const RatioSize(this.ratio, {super.key});

  @override
  RatioSize withKey(LocalKey key) {
    return RatioSize(ratio, key: key);
  }

  @override
  RatioSize withTarget(FlexTarget target) {
    throw FlutterError('RatioSize does not have a target');
  }

  @override
  RatioSize copyWith({LocalKey? key, FlexTarget? target, double? ratio}) {
    return RatioSize(
      ratio ?? this.ratio,
      key: key ?? this.key,
    );
  }

  @override
  bool get isPosition => false;

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required bool reverse,
    required Map<Key, double> dependencies,
  }) {
    throw FlutterError('RatioSize cannot be used for positioning');
  }

  @override
  void debugIsSizeValid() {
    if (ratio.isNaN || ratio.isInfinite) {
      throw FlutterError('RatioSize ratio must be a finite number, got $ratio');
    }
  }

  @override
  double computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    if (key != null) {
      dependencies[key!] = 0.0;
    }
    return 0.0;
  }

  @override
  bool get needsCrossAxis => true;

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    if (crossAxisSize == null) {
      // circular dependency
      throw FlutterError(
        'RatioSize requires the cross axis size to be known before it can be computed. '
        'This usually means that you have a circular dependency in your BoxSize definitions. '
        'For example, if you have a horizontal FlexBox, and one of its children has a RatioSize for width, '
        'but the height of that child is also defined in terms of the width (e.g. RatioSize), '
        'then this will cause a circular dependency. '
        'To fix this, make sure that the cross axis size can be determined independently of the main axis size.',
      );
    }
    double result = crossAxisSize * ratio;
    if (key != null) {
      dependencies[key!] = result;
    }
    return (
      recomputeFlex: false,
      result: result,
      flexResult: 0.0,
    );
  }

  @override
  String toString() {
    return 'RatioSize(ratio: $ratio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatioSize && other.ratio == ratio;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, ratio);
  }
}

enum FlexTarget {
  /// The size is relative to the flexbox content size
  content,

  /// The size is relative to the flexbox viewport size
  viewport,

  /// The size is relative to the flex wrap line
  line,

  /// Relative to the child size (only used for positioning)
  child,
}

double _getBaseSize(
  FlexTarget target, {
  double? contentSize,
  double? viewportSize,
  double? lineSize,
  double? childSize,
}) {
  double result;
  if (target == FlexTarget.content) {
    assert(
      contentSize != null,
      'FlexRelativeTarget.content is not available',
    );
    result = contentSize!;
  } else if (target == FlexTarget.viewport) {
    assert(
      viewportSize != null,
      'FlexRelativeTarget.viewport is not available',
    );
    result = viewportSize!;
  } else if (target == FlexTarget.line) {
    assert(
      lineSize != null,
      'FlexRelativeTarget.line is not available',
    );
    result = lineSize!;
  } else {
    assert(
      childSize != null,
      'FlexRelativeTarget.child is not available',
    );
    result = childSize!;
  }
  return result;
}

double? _getNullableBaseSize(
  FlexTarget target, {
  double? contentSize,
  double? viewportSize,
  double? lineSize,
  double? childSize,
}) {
  return switch (target) {
    FlexTarget.content => contentSize,
    FlexTarget.viewport => viewportSize,
    FlexTarget.line => lineSize,
    FlexTarget.child => childSize,
  };
}

class RelativeValue extends BoxValue {
  final double relative;

  const RelativeValue(
    this.relative, {
    super.key,
    super.target,
  });

  @override
  RelativeValue withKey(LocalKey key) {
    return RelativeValue(relative, key: key, target: target);
  }

  @override
  RelativeValue withTarget(FlexTarget target) {
    return RelativeValue(relative, key: key, target: target);
  }

  @override
  RelativeValue copyWith({
    LocalKey? key,
    FlexTarget? target,
    double? relative,
  }) {
    return RelativeValue(
      relative ?? this.relative,
      key: key ?? this.key,
      target: target ?? this.target,
    );
  }

  @override
  double computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required bool reverse,
    required Map<Key, double> dependencies,
  }) {
    double baseSize = _getBaseSize(
      target,
      viewportSize: viewportSize,
      contentSize: contentSize,
      childSize: childSize,
    );
    double result = baseSize * relative;
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  void debugIsSizeValid() {
    if (relative.isNaN || relative.isInfinite) {
      throw FlutterError(
        'RelativeSize relative must be a finite number, got $relative',
      );
    }
  }

  @override
  double computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    if (child == null) {
      if (key != null) {
        dependencies[key!] = 0.0;
      }
      return 0.0;
    }
    if (key != null) {
      dependencies[key!] = 0.0;
    }
    return 0.0;
  }

  @override
  ({
    bool needsFlexFactor,
    bool needsMainAxisViewportSize,
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsMainAxisViewportSize: mainAxis && target == FlexTarget.viewport,
      needsCrossAxisViewportSize: !mainAxis && target == FlexTarget.viewport,
      needsMainAxisContentSize: mainAxis && target == FlexTarget.content,
      needsCrossAxisContentSize: !mainAxis && target == FlexTarget.content,
      needsFlexFactor: false,
    );
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    double? mainAxisParentSize = _getNullableBaseSize(
      target,
      contentSize: mainAxisContentSize,
      viewportSize: mainAxisViewportSize,
    );
    double? crossAxisParentSize = _getNullableBaseSize(
      target,
      contentSize: crossAxisContentSize,
      viewportSize: crossAxisViewportSize,
    );
    double result;
    if (mainAxis) {
      if (mainAxisParentSize == null) {
        result = 0.0;
      } else {
        result = mainAxisParentSize * relative;
      }
    } else {
      if (crossAxisParentSize == null) {
        result = 0.0;
      } else {
        result = crossAxisParentSize * relative;
      }
    }
    if (key != null) {
      dependencies[key!] = result;
    }
    return (
      recomputeFlex: false,
      result: result,
      flexResult: 0.0,
    );
  }

  @override
  String toString() {
    return 'RelativeSize(relative: $relative)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelativeValue && other.relative == relative;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, relative);
  }
}

class FlexSize extends BoxValue {
  final double flex;

  const FlexSize(
    this.flex, {
    super.key,
  });

  @override
  FlexSize withKey(LocalKey key) {
    return FlexSize(flex, key: key);
  }

  @override
  FlexSize withTarget(FlexTarget target) {
    throw FlutterError('FlexSize does not have a target');
  }

  @override
  FlexSize copyWith({LocalKey? key, FlexTarget? target, double? flex}) {
    return FlexSize(
      flex ?? this.flex,
      key: key ?? this.key,
    );
  }

  @override
  bool get isPosition => false;

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required bool reverse,
    required Map<Key, double> dependencies,
  }) {
    throw FlutterError('FlexSize cannot be used for positioning');
  }

  @override
  void debugIsSizeValid() {
    if (flex.isNaN || flex.isInfinite) {
      throw FlutterError(
        'FlexSize flex must be a finite number, got $flex',
      );
    }
  }

  @override
  double computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    if (key != null) {
      dependencies[key!] = 0.0;
    }
    return 0.0;
  }

  @override
  ({
    bool needsFlexFactor,
    bool needsMainAxisViewportSize,
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsMainAxisViewportSize: false,
      needsCrossAxisViewportSize: !mainAxis,
      needsMainAxisContentSize: false,
      needsCrossAxisContentSize: !mainAxis,
      needsFlexFactor: mainAxis,
    );
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    return flex;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    double result;
    if (!computeFlex) {
      result = 0;
    } else if (mainAxis) {
      if (flexFactor == null) {
        result = 0.0;
      } else {
        result = flexFactor * flex;
      }
    } else {
      double? crossAxisParentSize = _getNullableBaseSize(
        FlexTarget.viewport,
        viewportSize: crossAxisViewportSize,
        contentSize: crossAxisContentSize,
      );
      if (crossAxisParentSize == null) {
        result = 0.0;
      } else {
        result = crossAxisParentSize;
      }
    }
    if (key != null) {
      dependencies[key!] = result;
    }
    return (recomputeFlex: false, flexResult: result, result: 0.0);
  }

  @override
  String toString() {
    return 'FlexSize(flex: $flex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlexSize && other.flex == flex;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, flex);
  }
}

class TransformedValue extends BoxValue {
  static double negate(double value) => -value;
  static double absolute(double value) => value.abs();
  final BoxValue? original;
  final BoxTransformer transformer;

  const TransformedValue(
    this.original, {
    super.key,
    required this.transformer,
  });

  @override
  TransformedValue withKey(LocalKey key) {
    return TransformedValue(original, key: key, transformer: transformer);
  }

  @override
  TransformedValue withTarget(FlexTarget target) {
    throw FlutterError('TransformedValue does not have a target');
  }

  @override
  TransformedValue copyWith({
    LocalKey? key,
    FlexTarget? target,
    BoxTransformer? transformer,
    BoxValue? original,
  }) {
    return TransformedValue(
      original ?? this.original,
      key: key ?? this.key,
      transformer: transformer ?? this.transformer,
    );
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? result = original!.computeIntrinsicSize(
      child: child,
      direction: direction,
      extent: extent,
      dependencies: dependencies,
      computeMax: computeMax,
    );
    if (result == null) {
      return null;
    }
    result = transformer(result);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  void debugIsSizeValid() {
    original!.debugIsSizeValid();
  }

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required Map<Key, double> dependencies,
    required bool reverse,
  }) {
    double? result = original!.computePosition(
      viewportSize: viewportSize,
      contentSize: contentSize,
      childSize: childSize,
      textDirection: textDirection,
      dependencies: dependencies,
      reverse: reverse,
    );
    if (result == null) {
      return null;
    }
    result = transformer(result);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  ({
    bool needsFlexFactor,
    bool needsMainAxisViewportSize,
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return original!.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
  }

  @override
  bool get needsCrossAxis => original!.needsCrossAxis;

  @override
  double? computeTotalFlex(double? biggestFlex) {
    // do not negate this, the total flex needs to be positive
    // to compute the flex factor
    return original!.computeTotalFlex(biggestFlex);
  }

  @override
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    final result = original!.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisViewportSize: mainAxisViewportSize,
      crossAxisViewportSize: crossAxisViewportSize,
      mainAxisContentSize: mainAxisContentSize,
      crossAxisContentSize: crossAxisContentSize,
      crossAxisSize: crossAxisSize,
      dependencies: dependencies,
    );
    if (result == null) {
      return null;
    }
    if (key != null) {
      dependencies[key!] = -result.result + -result.flexResult;
    }
    return (
      recomputeFlex: result.recomputeFlex,
      result: -result.result,
      flexResult: -result.flexResult,
    );
  }

  @override
  String toString() {
    return 'TransformedBoxSize(original: $original, transformer: $transformer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformedValue && other.original == original;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, original);
  }
}

typedef BoxComputerOperation = double Function(double first, double second);

class BoxComputer extends BoxValue {
  static double addition(double first, double second) => first + second;
  // NOTE: multiplication and such is not supported here
  // because it can lead to very weird results
  static double subtraction(double first, double second) => first - second;
  static double max(double first, double second) =>
      first > second ? first : second;
  static double min(double first, double second) =>
      first < second ? first : second;
  final BoxValue? first;
  final BoxValue? second;
  final BoxComputerOperation operation;

  const BoxComputer(this.first, this.second, this.operation, {super.key});

  @override
  BoxComputer withKey(LocalKey key) {
    return BoxComputer(first, second, operation, key: key);
  }

  @override
  BoxComputer withTarget(FlexTarget target) {
    throw FlutterError('BoxComputer does not have a target');
  }

  @override
  BoxComputer copyWith({
    LocalKey? key,
    FlexTarget? target,
    BoxValue? first,
    BoxValue? second,
    BoxComputerOperation? operation,
  }) {
    return BoxComputer(
      first ?? this.first,
      second ?? this.second,
      operation ?? this.operation,
      key: key ?? this.key,
    );
  }

  @override
  void debugIsSizeValid() {
    first!.debugIsSizeValid();
    second!.debugIsSizeValid();
  }

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required Map<Key, double> dependencies,
    required bool reverse,
  }) {
    double? firstResult = first!.computePosition(
      viewportSize: viewportSize,
      contentSize: contentSize,
      childSize: childSize,
      textDirection: textDirection,
      dependencies: dependencies,
      reverse: reverse,
    );
    double? secondResult = second!.computePosition(
      viewportSize: viewportSize,
      contentSize: contentSize,
      childSize: childSize,
      textDirection: textDirection,
      dependencies: dependencies,
      reverse: reverse,
    );
    if (firstResult == null || secondResult == null) {
      return null;
    }
    double result = reverse
        ? operation(secondResult, firstResult)
        : operation(firstResult, secondResult);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? firstResult = first!.computeIntrinsicSize(
      child: child,
      direction: direction,
      extent: extent,
      dependencies: dependencies,
      computeMax: computeMax,
    );
    double? secondResult = second!.computeIntrinsicSize(
      child: child,
      direction: direction,
      extent: extent,
      dependencies: dependencies,
      computeMax: computeMax,
    );
    if (firstResult == null || secondResult == null) {
      return null;
    }
    double result = operation(firstResult, secondResult);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  ({
    bool needsFlexFactor,
    bool needsMainAxisViewportSize,
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    final firstDep = first!.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
    final secondDep = second!.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
    return (
      needsFlexFactor: firstDep.needsFlexFactor || secondDep.needsFlexFactor,
      needsMainAxisViewportSize:
          firstDep.needsMainAxisViewportSize ||
          secondDep.needsMainAxisViewportSize,
      needsCrossAxisViewportSize:
          firstDep.needsCrossAxisViewportSize ||
          secondDep.needsCrossAxisViewportSize,
      needsMainAxisContentSize:
          firstDep.needsMainAxisContentSize ||
          secondDep.needsMainAxisContentSize,
      needsCrossAxisContentSize:
          firstDep.needsCrossAxisContentSize ||
          secondDep.needsCrossAxisContentSize,
    );
  }

  @override
  bool get needsCrossAxis => first!.needsCrossAxis || second!.needsCrossAxis;

  @override
  double? computeTotalFlex(double? biggestFlex) {
    // always add the flexes together
    // do not apply the operation here
    double total = 0;
    var firstFlex = first!.computeTotalFlex(biggestFlex);
    if (firstFlex != null) {
      total += firstFlex;
    }
    var secondFlex = second!.computeTotalFlex(biggestFlex);
    if (secondFlex != null) {
      total += secondFlex;
    }
    return total > 0 ? total : null;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
    required Map<Key, double> dependencies,
  }) {
    final firstResult = first!.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisViewportSize: mainAxisViewportSize,
      crossAxisViewportSize: crossAxisViewportSize,
      mainAxisContentSize: mainAxisContentSize,
      crossAxisContentSize: crossAxisContentSize,
      crossAxisSize: crossAxisSize,
      dependencies: dependencies,
    );
    final secondResult = second!.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisViewportSize: mainAxisViewportSize,
      crossAxisViewportSize: crossAxisViewportSize,
      mainAxisContentSize: mainAxisContentSize,
      crossAxisContentSize: crossAxisContentSize,
      crossAxisSize: crossAxisSize,
      dependencies: dependencies,
    );
    if (firstResult == null || secondResult == null) {
      return null;
    }
    final result = operation(firstResult.result, secondResult.result);
    final flexResult = operation(
      firstResult.flexResult,
      secondResult.flexResult,
    );
    if (key != null) {
      dependencies[key!] = result + flexResult;
    }
    return (
      recomputeFlex: firstResult.recomputeFlex || secondResult.recomputeFlex,
      result: result,
      flexResult: flexResult,
    );
  }

  @override
  String toString() {
    return 'PairBoxSize(first: $first, second: $second)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoxComputer &&
        other.first == first &&
        other.second == second;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, first, second);
  }
}

// same as BoxSizeComputer, but only allow
// computation against double
class PrimitiveBoxComputer extends BoxValue {
  static double multiplication(double first, double second) => first * second;
  static double division(double first, double second) => first / second;
  static double modulo(double first, double second) => first % second;
  static double floorDivision(double first, double second) =>
      (first / second).floorToDouble();
  final BoxValue? original;
  final double operand;
  final BoxComputerOperation operation;
  const PrimitiveBoxComputer(
    this.original,
    this.operand,
    this.operation, {
    super.key,
  });

  @override
  PrimitiveBoxComputer withKey(LocalKey key) {
    return PrimitiveBoxComputer(original, operand, operation, key: key);
  }

  @override
  PrimitiveBoxComputer withTarget(FlexTarget target) {
    return PrimitiveBoxComputer(original, operand, operation, key: key);
  }

  @override
  PrimitiveBoxComputer copyWith({
    LocalKey? key,
    FlexTarget? target,
    BoxValue? original,
    double? operand,
    BoxComputerOperation? operation,
  }) {
    return PrimitiveBoxComputer(
      original ?? this.original,
      operand ?? this.operand,
      operation ?? this.operation,
      key: key ?? this.key,
    );
  }

  @override
  void debugIsSizeValid() {
    original?.debugIsSizeValid();
    if (operand.isNaN || operand.isInfinite) {
      throw FlutterError(
        'PrimitiveBoxSizeComputer operand must be a finite number, got $operand',
      );
    }
  }

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required Map<Key, double> dependencies,
    required bool reverse,
  }) {
    double? result = original!.computePosition(
      viewportSize: viewportSize,
      contentSize: contentSize,
      childSize: childSize,
      textDirection: textDirection,
      dependencies: dependencies,
      reverse: reverse,
    );
    if (result == null) {
      return null;
    }
    result = operation(result, reverse ? -operand : operand);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? result = original!.computeIntrinsicSize(
      child: child,
      direction: direction,
      extent: extent,
      dependencies: dependencies,
      computeMax: computeMax,
    );
    if (result == null) {
      return null;
    }
    result = operation(result, operand);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  ({
    bool needsFlexFactor,
    bool needsMainAxisViewportSize,
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return original!.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
  }

  @override
  bool get needsCrossAxis => original!.needsCrossAxis;

  @override
  double? computeTotalFlex(double? biggestFlex) {
    final result = original!.computeTotalFlex(biggestFlex);
    if (result == null) {
      return null;
    }
    return operation(result, operand);
  }

  @override
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
    required Map<Key, double> dependencies,
  }) {
    final result = original.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisViewportSize: mainAxisViewportSize,
      crossAxisViewportSize: crossAxisViewportSize,
      mainAxisContentSize: mainAxisContentSize,
      crossAxisContentSize: crossAxisContentSize,
      crossAxisSize: crossAxisSize,
      dependencies: dependencies,
    );
    if (result == null) {
      return null;
    }
    final value = operation(result.result, operand);
    if (key != null) {
      dependencies[key!] = value + result.flexResult;
    }
    return (
      recomputeFlex: result.recomputeFlex,
      result: value,
      // do NOT apply operation to flexResult
      // because its already done in computeTotalFlex
      flexResult: result.flexResult,
    );
  }

  @override
  String toString() {
    return 'PrimitiveBoxSizeComputer(original: $original, operand: $operand)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrimitiveBoxComputer &&
        other.original == original &&
        other.operand == operand;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, original, operand);
  }
}

class ClampedValue extends BoxValue {
  final BoxValue? original;
  final BoxValue? min;
  final BoxValue? max;

  const ClampedValue(
    this.original, {
    this.min,
    this.max,
    super.key,
    super.target,
  });

  @override
  ClampedValue withKey(LocalKey key) {
    return ClampedValue(original, min: min, max: max, key: key, target: target);
  }

  @override
  ClampedValue withTarget(FlexTarget target) {
    return ClampedValue(original, min: min, max: max, key: key, target: target);
  }

  @override
  ClampedValue copyWith({
    LocalKey? key,
    FlexTarget? target,
    BoxValue? original,
    BoxValue? min,
    BoxValue? max,
  }) {
    return ClampedValue(
      original ?? this.original,
      min: min ?? this.min,
      max: max ?? this.max,
      key: key ?? this.key,
      target: target ?? this.target,
    );
  }

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required Map<Key, double> dependencies,
    required bool reverse,
  }) {
    double? originalSize = original!.computePosition(
      viewportSize: viewportSize,
      contentSize: contentSize,
      childSize: childSize,
      textDirection: textDirection,
      dependencies: dependencies,
      reverse: reverse,
    );
    if (originalSize == null) {
      return null;
    }
    double? minSize;
    if (min != null) {
      minSize = min!.computePosition(
        viewportSize: viewportSize,
        contentSize: contentSize,
        childSize: childSize,
        textDirection: textDirection,
        dependencies: dependencies,
        reverse: reverse,
      );
    }
    double? maxSize;
    if (max != null) {
      maxSize = max!.computePosition(
        viewportSize: viewportSize,
        contentSize: contentSize,
        childSize: childSize,
        textDirection: textDirection,
        dependencies: dependencies,
        reverse: reverse,
      );
    }
    double result = _clamp(originalSize, minSize, maxSize);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? originalSize = this.original!.computeIntrinsicSize(
      child: child,
      direction: direction,
      extent: extent,
      dependencies: dependencies,
      computeMax: computeMax,
    );
    if (originalSize == null) {
      return null;
    }
    double? minSize;
    if (this.min != null) {
      minSize = this.min!.computeIntrinsicSize(
        child: child,
        direction: direction,
        extent: extent,
        dependencies: dependencies,
        computeMax: computeMax,
      );
      if (minSize == null) {
        // has not resolved its dependencies yet
        return null;
      }
    }
    double? maxSize;
    if (this.max != null) {
      maxSize = this.max!.computeIntrinsicSize(
        child: child,
        direction: direction,
        extent: extent,
        dependencies: dependencies,
        computeMax: computeMax,
      );
      if (maxSize == null) {
        // has not resolved its dependencies yet
        return null;
      }
    }
    double result = _clamp(originalSize, minSize, maxSize);
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  ({
    bool needsFlexFactor,
    bool needsMainAxisViewportSize,
    bool needsCrossAxisViewportSize,
    bool needsMainAxisContentSize,
    bool needsCrossAxisContentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    final originalDep = original!.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
    final minDep =
        min?.getRequiredInputs(
          mainAxis: mainAxis,
          crossRequiresSize: crossRequiresSize,
        ) ??
        _noDependency;
    final maxDep =
        max?.getRequiredInputs(
          mainAxis: mainAxis,
          crossRequiresSize: crossRequiresSize,
        ) ??
        _noDependency;
    return (
      needsMainAxisViewportSize:
          originalDep.needsMainAxisViewportSize ||
          minDep.needsMainAxisViewportSize ||
          maxDep.needsMainAxisViewportSize,
      needsCrossAxisViewportSize:
          originalDep.needsCrossAxisViewportSize ||
          minDep.needsCrossAxisViewportSize ||
          maxDep.needsCrossAxisViewportSize,
      needsMainAxisContentSize:
          originalDep.needsMainAxisContentSize ||
          minDep.needsMainAxisContentSize ||
          maxDep.needsMainAxisContentSize,
      needsCrossAxisContentSize:
          originalDep.needsCrossAxisContentSize ||
          minDep.needsCrossAxisContentSize ||
          maxDep.needsCrossAxisContentSize,
      needsFlexFactor:
          originalDep.needsFlexFactor ||
          minDep.needsFlexFactor ||
          maxDep.needsFlexFactor,
    );
  }

  @override
  void debugIsSizeValid() {
    original!.debugIsSizeValid();
    min?.debugIsSizeValid();
    max?.debugIsSizeValid();
  }

  @override
  bool get needsCrossAxis =>
      original!.needsCrossAxis ||
      (min?.needsCrossAxis ?? false) ||
      (max?.needsCrossAxis ?? false);

  @override
  double? computeTotalFlex(double? biggestFlex) {
    // do not clamp total flex
    return original!.computeTotalFlex(biggestFlex);
  }

  @override
  ({double flexResult, bool recomputeFlex, double result})? computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    final result = original!.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisViewportSize: mainAxisViewportSize,
      crossAxisViewportSize: crossAxisViewportSize,
      mainAxisContentSize: mainAxisContentSize,
      crossAxisContentSize: crossAxisContentSize,
      crossAxisSize: crossAxisSize,
      dependencies: dependencies,
    );
    if (result == null) {
      return null;
    }
    bool recomputeFlex = result.recomputeFlex;
    double resultSize = result.result;
    double flexSize = result.flexResult;
    double? minSize;
    if (this.min != null) {
      final minResult = this.min!.computeSize(
        child: child,
        direction: direction,
        mainAxis: mainAxis,
        computeFlex: computeFlex,
        flexFactor: flexFactor,
        biggestFlex: biggestFlex,
        mainAxisViewportSize: mainAxisViewportSize,
        crossAxisViewportSize: crossAxisViewportSize,
        mainAxisContentSize: mainAxisContentSize,
        crossAxisContentSize: crossAxisContentSize,
        crossAxisSize: crossAxisSize,
        dependencies: dependencies,
      );
      if (minResult == null) {
        return null;
      }
      minSize = minResult.result + minResult.flexResult;
      recomputeFlex |= minResult.recomputeFlex;
      // hasFlexResult |= minResult.flexResult > 0;
    }
    double? maxSize;
    if (this.max != null) {
      final maxResult = this.max!.computeSize(
        child: child,
        direction: direction,
        mainAxis: mainAxis,
        computeFlex: computeFlex,
        flexFactor: flexFactor,
        biggestFlex: biggestFlex,
        mainAxisViewportSize: mainAxisViewportSize,
        crossAxisViewportSize: crossAxisViewportSize,
        mainAxisContentSize: mainAxisContentSize,
        crossAxisContentSize: crossAxisContentSize,
        crossAxisSize: crossAxisSize,
        dependencies: dependencies,
      );
      if (maxResult == null) {
        return null;
      }
      maxSize = maxResult.result + maxResult.flexResult;
      recomputeFlex |= maxResult.recomputeFlex;
      // hasFlexResult |= maxResult.flexResult > 0;
    }
    // if this is true, then part of the flex size
    // has been clamped, so we need to recompute
    bool clampedFlex = false;
    if (maxSize != null && (resultSize + flexSize) > maxSize) {
      // we need to clamp it, but first, lets check
      // if we can take it from the non-flex part
      if (resultSize > maxSize) {
        // this means that resultSize is sufficient
        // to cover the clamping, therefore we do not
        // need to clamp the flex part
        resultSize = maxSize;
      } else {
        // but if the resultSize cannot cover it
        // we turn flex size into non-flex size
        resultSize = maxSize;
        if (flexSize > 0) {
          flexSize = 0.0;
          clampedFlex = true;
        }
      }
    }
    if (minSize != null && (resultSize + flexSize) < minSize) {
      // minSize gives the child more size
      // to meet the minimum requirement
      // therefore, flex size turns into non-flex size
      resultSize = minSize;
      if (flexSize > 0) {
        flexSize = 0.0;
        clampedFlex = true;
      }
    }
    if (key != null) {
      dependencies[key!] = resultSize + flexSize;
    }
    if (clampedFlex) {
      recomputeFlex = true;
    }
    return (
      recomputeFlex: recomputeFlex,
      result: resultSize,
      flexResult: flexSize,
    );
  }
}

class LinkedValue extends BoxValue {
  final LocalKey targetKey;

  const LinkedValue(this.targetKey, {super.key});

  @override
  LinkedValue withKey(LocalKey key) {
    return LinkedValue(targetKey, key: key);
  }

  @override
  LinkedValue withTarget(FlexTarget target) {
    throw FlutterError('LinkedValue does not have a target');
  }

  @override
  LinkedValue copyWith({
    LocalKey? key,
    FlexTarget? target,
    LocalKey? targetKey,
  }) {
    return LinkedValue(
      targetKey ?? this.targetKey,
      key: key ?? this.key,
    );
  }

  @override
  double? computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required Map<Key, double> dependencies,
    required bool reverse,
  }) {
    // here we assume no circular dependency
    // because its already handled in the flexbox render object
    // here we also assume that our dependency
    // is completed
    final result = dependencies[targetKey];
    if (result == null) {
      return null;
    }

    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? result = dependencies[targetKey];
    if (result == null) {
      return null;
    }
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  ({double flexResult, bool recomputeFlex, double result})? computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    // here we assume no circular dependency
    // because its already handled in the flexbox render object
    // here we also assume that our dependency
    // is completed
    final result = dependencies[targetKey];
    if (result == null) {
      return null;
    }
    if (key != null) {
      dependencies[key!] = result;
    }
    return (flexResult: 0.0, recomputeFlex: false, result: result);
  }
}

abstract class BoxAlignmentGeometry {
  static const BoxAlignmentGeometry start = BoxAlignmentDirectional.start;
  static const BoxAlignmentGeometry center = BoxAlignment.center;
  static const BoxAlignmentGeometry end = BoxAlignmentDirectional.end;
  final double alignment;

  const BoxAlignmentGeometry({this.alignment = 0.0});

  BoxAlignment resolve(TextDirection? textDirection);

  double alongWithSize(double size) {
    double center = size / 2;
    return center + alignment * center;
  }

  BoxAlignmentGeometry get flipped;

  @override
  String toString() {
    return 'BoxAlignment(alignment: $alignment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other.runtimeType == runtimeType &&
        (other as BoxAlignmentGeometry).alignment == alignment;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, alignment);
  }
}

class BoxAlignment extends BoxAlignmentGeometry {
  static const start = BoxAlignment(alignment: -1.0);
  static const center = BoxAlignment(alignment: 0.0);
  static const end = BoxAlignment(alignment: 1.0);
  const BoxAlignment({super.alignment});

  @override
  BoxAlignmentGeometry get flipped => BoxAlignment(alignment: -alignment);

  @override
  BoxAlignment resolve(TextDirection? textDirection) {
    return this;
  }

  @override
  String toString() {
    return 'BoxAlignment(alignment: $alignment)';
  }
}

class BoxAlignmentDirectional extends BoxAlignmentGeometry {
  static const start = BoxAlignmentDirectional(alignment: -1.0);
  static const center = BoxAlignmentDirectional(alignment: 0.0);
  static const end = BoxAlignmentDirectional(alignment: 1.0);
  const BoxAlignmentDirectional({super.alignment});

  @override
  BoxAlignment resolve(TextDirection? textDirection) {
    if (textDirection == TextDirection.rtl) {
      return BoxAlignment(alignment: -alignment);
    }
    return BoxAlignment(alignment: alignment);
  }

  @override
  BoxAlignmentGeometry get flipped =>
      BoxAlignmentDirectional(alignment: -alignment);

  @override
  String toString() {
    return 'BoxAlignmentDirectional(alignment: $alignment)';
  }
}

class AlignedPosition extends BoxValue {
  final BoxAlignmentGeometry alignment;
  final BoxAlignmentGeometry anchor;

  const AlignedPosition({
    this.alignment = BoxAlignment.center,
    this.anchor = BoxAlignment.center,
    super.target,
    super.key,
  });

  @override
  AlignedPosition withKey(LocalKey key) {
    return AlignedPosition(
      alignment: alignment,
      anchor: anchor,
      key: key,
      target: target,
    );
  }

  @override
  AlignedPosition withTarget(FlexTarget target) {
    return AlignedPosition(
      alignment: alignment,
      anchor: anchor,
      key: key,
      target: target,
    );
  }

  @override
  AlignedPosition copyWith({
    LocalKey? key,
    FlexTarget? target,
    BoxAlignmentGeometry? alignment,
    BoxAlignmentGeometry? anchor,
  }) {
    return AlignedPosition(
      alignment: alignment ?? this.alignment,
      anchor: anchor ?? this.anchor,
      key: key ?? this.key,
      target: target ?? this.target,
    );
  }

  @override
  bool get isSize => false;

  @override
  double computePosition({
    required double viewportSize,
    required double contentSize,
    required double childSize,
    required TextDirection textDirection,
    required Map<Key, double> dependencies,
    required bool reverse,
  }) {
    final resolvedAlignment = alignment.resolve(textDirection);
    final resolvedAnchor = anchor.resolve(textDirection);
    double baseSize = _getBaseSize(
      target,
      viewportSize: viewportSize,
      contentSize: contentSize,
      childSize: childSize,
    );
    double result =
        resolvedAlignment.alongWithSize(baseSize) -
        resolvedAnchor.alongWithSize(childSize);
    if (reverse) {
      result = baseSize - result;
    }
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    throw FlutterError('AlignedPosition cannot be used as size');
  }

  @override
  ({double flexResult, bool recomputeFlex, double result})? computeSize({
    required RenderBox? child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    double? flexFactor,
    double? biggestFlex,
    double? smallestFlex,
    double? mainAxisViewportSize,
    double? crossAxisViewportSize,
    double? mainAxisContentSize,
    double? crossAxisContentSize,
    double? crossAxisSize,
  }) {
    throw FlutterError('AlignedPosition cannot be used as size');
  }
}

typedef BoxTransformer = double Function(double original);

enum BoxPositionType {
  /// Fixed position
  fixed,

  /// Sticky position keeps the child within the viewport bounds
  /// It prioritizes to stay at upper bound if the viewport bounds
  /// is too small to fit the child, but if the direction is reversed,
  /// it will prioritize to stay at lower bound.
  sticky,

  /// Sticky position, but it will only stick to the upper bound of the viewport bounds
  stickyStart,

  /// Sticky position, but it will only stick to the lower bound of the viewport bounds
  stickyEnd,
}
