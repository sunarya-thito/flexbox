import 'package:flutter/rendering.dart';

enum FlexBoxWrap {
  /// If the children overflow to the end of the main axis,
  /// they will wrap to the next line. The cross axis will
  /// become scrolled if necessary.
  wrapMainAxis,

  /// If the children overflow to the end of the cross axis,
  /// they will wrap to the next column. The main axis will
  /// become scrolled if necessary.
  wrapCrossAxis,

  /// If the children overflow to the end of the main axis,
  /// they will wrap to the previous line.
  /// The cross axis will become scrolled if necessary.
  wrapMainAxisReverse,

  /// If the children overflow to the end of the cross axis,
  /// they will wrap to the previous column.
  /// The main axis will become scrolled if necessary.
  wrapCrossAxisReverse,
}

class ChildSizing {
  final double parentSize;
  final double crossAxisSize;
  final double flexFactor;
  final double remainingSpace;
  final double Function() computeIntrinsic;

  ChildSizing({
    required this.parentSize,
    required this.crossAxisSize,
    required this.flexFactor,
    required this.remainingSpace,
    required this.computeIntrinsic,
  });

  @override
  String toString() {
    return 'ChildSizing(parentSize: $parentSize, crossAxisSize: $crossAxisSize, flexFactor: $flexFactor, remainingSpace: $remainingSpace)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildSizing &&
        other.parentSize == parentSize &&
        other.crossAxisSize == crossAxisSize &&
        other.flexFactor == flexFactor &&
        other.remainingSpace == remainingSpace;
    // Note: Function comparison is not reliable, so we exclude computeIntrinsic
  }

  @override
  int get hashCode {
    return Object.hash(parentSize, crossAxisSize, flexFactor, remainingSpace);
  }
}

abstract class BoxSize {
  final double? min;
  final double? max;
  const BoxSize({this.min, this.max});
  const factory BoxSize.intrinsic({double? min, double? max}) = IntrinsicSize;
  const factory BoxSize.fixed(double size) = FixedSize;
  const factory BoxSize.unconstrained({double? min, double? max}) =
      UnconstrainedSize;
  const factory BoxSize.ratio(double ratio, {double? min, double? max}) =
      RatioSize;
  const factory BoxSize.relative(double relative, {double? min, double? max}) =
      RelativeSize;
  const factory BoxSize.flex(double flex, {double? min, double? max}) =
      FlexSize;

  @override
  String toString() {
    return 'BoxSize(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoxSize && other.min == min && other.max == max;
  }

  @override
  int get hashCode {
    return Object.hash(min, max);
  }
}

class IntrinsicSize extends BoxSize {
  const IntrinsicSize({super.min, super.max});

  @override
  String toString() {
    return 'IntrinsicSize(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntrinsicSize && other.min == min && other.max == max;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, min, max);
  }
}

class FixedSize extends BoxSize {
  final double size;

  const FixedSize(this.size);

  @override
  String toString() {
    return 'FixedSize(size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedSize && other.size == size;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, size, min, max);
  }
}

class UnconstrainedSize extends BoxSize {
  const UnconstrainedSize({super.min, super.max});

  @override
  String toString() {
    return 'UnconstrainedSize(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnconstrainedSize && other.min == min && other.max == max;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, min, max);
  }
}

class RatioSize extends BoxSize {
  final double ratio;

  const RatioSize(this.ratio, {super.min, super.max});

  @override
  String toString() {
    return 'RatioSize(ratio: $ratio, min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatioSize &&
        other.ratio == ratio &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, ratio, min, max);
  }
}

class RelativeSize extends BoxSize {
  final double relative;

  /// If true, when the flex box is in an unconstrained environment,
  /// it will fallback to using the intrinsic size of the child.
  /// If false, it will use zero size in unconstrained environments.
  /// Defaults to true.
  final bool intrinsicFallback;

  const RelativeSize(
    this.relative, {
    super.min,
    super.max,
    this.intrinsicFallback = true,
  });

  @override
  String toString() {
    return 'RelativeSize(relative: $relative, min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelativeSize &&
        other.relative == relative &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, relative, min, max);
  }
}

class FlexSize extends BoxSize {
  final double flex;

  /// If true, when the flex box is in an unconstrained environment,
  /// it will fallback to using the intrinsic size of the child.
  /// If false, it will use zero size in unconstrained environments.
  /// Defaults to true.
  final bool intrinsicFallback;

  const FlexSize(
    this.flex, {
    super.min,
    super.max,
    this.intrinsicFallback = true,
  });

  @override
  String toString() {
    return 'FlexSize(flex: $flex, min: $min, max: $max, intrinsicFallback: $intrinsicFallback)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlexSize &&
        other.flex == flex &&
        other.min == min &&
        other.max == max &&
        other.intrinsicFallback == intrinsicFallback;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, flex, min, max, intrinsicFallback);
  }
}

abstract class BoxAlignmentGeometry {
  final double alignment;

  const BoxAlignmentGeometry({this.alignment = 0.0});

  BoxAlignment resolve(TextDirection? textDirection);

  double alongWithSize(double size) {
    return (alignment + 1) / 2 * size;
  }

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
  String toString() {
    return 'BoxAlignmentDirectional(alignment: $alignment)';
  }
}

abstract class BoxPosition {
  const BoxPosition();
  const factory BoxPosition.fixed(double value) = FixedPosition;
  const factory BoxPosition.relative(double relative) = RelativePosition;

  double computePosition(double parentSize);

  @override
  String toString() {
    return 'BoxPosition()';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoxPosition && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode;
  }
}

class FixedPosition extends BoxPosition {
  final double value;

  const FixedPosition(this.value);

  @override
  double computePosition(double parentSize) {
    return value;
  }

  @override
  String toString() {
    return 'FixedPosition(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedPosition && other.value == value;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, value);
  }
}

class RelativePosition extends BoxPosition {
  final double relative;

  const RelativePosition(this.relative);

  @override
  double computePosition(double parentSize) {
    return parentSize * relative;
  }

  @override
  String toString() {
    return 'RelativePosition(relative: $relative)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelativePosition && other.relative == relative;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, relative);
  }
}

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

  // /// Relative position, affected by scrolling
  // relative,

  // /// Relative position anchored to the viewport instead of the flexbox,
  // /// affected by scrolling but positions are calculated relative to viewport size
  // relative,

  // /// Sticky position, affected by scrolling until it goes out of bounds.
  // /// It will constrain the position to the viewport bounds.
  // sticky,

  // /// Sticky position, but it will stick to the start (of the main axis) of the parent
  // stickyStart,

  // /// Sticky position, but it will stick to the end (of the main axis) of the parent
  // stickyEnd,

  // /// Sticky position anchored to content, affected by scrolling until it goes out of bounds.
  // /// It will constrain the position to the content bounds. Uses content dimensions as reference.
  // sticky,

  // /// Sticky position anchored to content, but it will stick to the start of the content.
  // /// Uses content dimensions as reference.
  // stickyStart,

  // /// Sticky position anchored to content, but it will stick to the end of the content.
  // /// Uses content dimensions as reference.
  // stickyEnd,
}
