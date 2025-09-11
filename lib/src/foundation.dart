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

double _clamp(double value, double? min, double? max) {
  if (min != null && value < min) {
    return min;
  }
  if (max != null && value > max) {
    return max;
  }
  return value;
}

abstract class BoxSize {
  const BoxSize();
  const factory BoxSize.intrinsic() = IntrinsicSize;
  const factory BoxSize.fixed(double size) = FixedSize;
  const factory BoxSize.expanding() = ExpandingSize;
  const factory BoxSize.ratio(double ratio) = RatioSize;
  const factory BoxSize.relative(double relative) = RelativeSize;
  const factory BoxSize.flex(double flex) = FlexSize;

  BoxSize clamp({BoxSize? min, BoxSize? max}) =>
      ClampedBoxSize(this, min: min, max: max);

  bool requiresCrossAxisSize(bool mainAxis, bool crossRequires) => false;
  bool requiresCrossAxisParentSize(bool mainAxis) => false;
  bool requiresMainAxisParentSize(bool mainAxis) => false;
  bool requiresFlexFactor(bool mainAxis) => false;

  double? computeTotalFlex(double? biggestFlex) => null;

  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  });

  operator -() => NegatedBoxSize(this);
  BoxSize operator +(BoxSize other) => CompoundBoxSize([this, other]);
  BoxSize operator *(BoxSize other) => CompoundBoxSize([this, other]);
  BoxSize operator /(BoxSize other) => CompoundBoxSize([this, other]);
  BoxSize operator %(BoxSize other) => CompoundBoxSize([this, other]);
  BoxSize operator ~() => NegatedBoxSize(this);
  BoxSize operator -(BoxSize other) =>
      CompoundBoxSize([this, NegatedBoxSize(other)]);
}

class IntrinsicSize extends BoxSize {
  const IntrinsicSize();

  @override
  bool requiresCrossAxisSize(bool mainAxis, bool crossRequires) {
    return !crossRequires;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    double result;
    switch (direction) {
      case Axis.horizontal:
        result = child.getMaxIntrinsicWidth(crossAxisSize ?? double.infinity);
        break;
      case Axis.vertical:
        result = child.getMaxIntrinsicHeight(crossAxisSize ?? double.infinity);
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

class FixedSize extends BoxSize {
  final double size;

  const FixedSize(this.size);

  @override
  String toString() {
    return 'FixedSize(size: $size)';
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    return (recomputeFlex: false, result: size, flexResult: 0.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedSize && other.size == size;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, size);
  }
}

class ExpandingSize extends BoxSize {
  final bool intrinsicFallback;
  const ExpandingSize({
    this.intrinsicFallback = true,
  });

  @override
  bool requiresFlexFactor(bool mainAxis) {
    return mainAxis;
  }

  @override
  bool requiresCrossAxisParentSize(bool mainAxis) {
    return !mainAxis;
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    biggestFlex ??= 1;
    return biggestFlex;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    double result;
    if (mainAxis) {
      if (flexFactor == null) {
        if (intrinsicFallback) {
          result = switch (direction) {
            Axis.horizontal => child.getMaxIntrinsicWidth(
              crossAxisSize ?? double.infinity,
            ),
            Axis.vertical => child.getMaxIntrinsicHeight(
              crossAxisSize ?? double.infinity,
            ),
          };
        } else {
          result = 0;
        }
      } else {
        biggestFlex ??= 1;
        result = biggestFlex * flexFactor;
      }
    } else {
      result = crossAxisParentSize ?? 0;
    }
    return (recomputeFlex: false, flexResult: 0.0, result: result);
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

class RatioSize extends BoxSize {
  final double ratio;

  const RatioSize(this.ratio);

  @override
  bool requiresCrossAxisSize(bool mainAxis, bool crossRequires) {
    return !crossRequires;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    double result = crossAxisSize == null ? 0 : crossAxisSize * ratio;
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

class RelativeSize extends BoxSize {
  final double relative;

  /// If true, when the flex box is in an unconstrained environment,
  /// it will fallback to using the intrinsic size of the child.
  /// If false, it will use zero size in unconstrained environments.
  /// Defaults to true.
  final bool intrinsicFallback;

  const RelativeSize(
    this.relative, {
    this.intrinsicFallback = true,
  });

  @override
  bool requiresCrossAxisParentSize(bool mainAxis) {
    return mainAxis;
  }

  @override
  bool requiresMainAxisParentSize(bool mainAxis) {
    return !mainAxis;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    double result;
    if (mainAxis) {
      if (mainAxisParentSize == null) {
        if (intrinsicFallback) {
          result = switch (direction) {
            Axis.horizontal => child.getMaxIntrinsicWidth(
              crossAxisSize ?? double.infinity,
            ),
            Axis.vertical => child.getMaxIntrinsicHeight(
              crossAxisSize ?? double.infinity,
            ),
          };
        } else {
          result = 0;
        }
      } else {
        result = mainAxisParentSize * relative;
      }
    } else {
      if (crossAxisParentSize == null) {
        if (intrinsicFallback) {
          result = switch (direction) {
            Axis.horizontal => child.getMaxIntrinsicWidth(
              crossAxisSize ?? double.infinity,
            ),
            Axis.vertical => child.getMaxIntrinsicHeight(
              crossAxisSize ?? double.infinity,
            ),
          };
        } else {
          result = 0;
        }
      } else {
        result = crossAxisParentSize * relative;
      }
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
    return other is RelativeSize && other.relative == relative;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, relative);
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
    this.intrinsicFallback = true,
  });

  @override
  bool requiresFlexFactor(bool mainAxis) {
    return mainAxis;
  }

  @override
  bool requiresCrossAxisParentSize(bool mainAxis) {
    return !mainAxis;
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    return flex;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    double result;
    if (!computeFlex) {
      result = 0;
    } else if (mainAxis) {
      if (flexFactor == null) {
        if (intrinsicFallback) {
          result = switch (direction) {
            Axis.horizontal => child.getMaxIntrinsicWidth(
              crossAxisSize ?? double.infinity,
            ),
            Axis.vertical => child.getMaxIntrinsicHeight(
              crossAxisSize ?? double.infinity,
            ),
          };
        } else {
          result = 0;
        }
      } else {
        result = flexFactor * flex;
      }
    } else {
      if (crossAxisParentSize == null) {
        if (intrinsicFallback) {
          result = switch (direction) {
            Axis.horizontal => child.getMaxIntrinsicWidth(
              crossAxisSize ?? double.infinity,
            ),
            Axis.vertical => child.getMaxIntrinsicHeight(
              crossAxisSize ?? double.infinity,
            ),
          };
        } else {
          result = 0;
        }
      } else {
        result = crossAxisParentSize;
      }
    }
    return (recomputeFlex: false, flexResult: result, result: 0.0);
  }

  @override
  String toString() {
    return 'FlexSize(flex: $flex, intrinsicFallback: $intrinsicFallback)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlexSize &&
        other.flex == flex &&
        other.intrinsicFallback == intrinsicFallback;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, flex, intrinsicFallback);
  }
}

class NegatedBoxSize extends BoxSize {
  final BoxSize original;

  NegatedBoxSize(this.original);

  @override
  bool requiresCrossAxisSize(bool mainAxis, bool crossRequires) {
    return original.requiresCrossAxisSize(mainAxis, crossRequires);
  }

  @override
  bool requiresCrossAxisParentSize(bool mainAxis) {
    return original.requiresCrossAxisParentSize(mainAxis);
  }

  @override
  bool requiresMainAxisParentSize(bool mainAxis) {
    return original.requiresMainAxisParentSize(mainAxis);
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    return original.computeTotalFlex(biggestFlex);
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    final result = original.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisParentSize: mainAxisParentSize,
      crossAxisParentSize: crossAxisParentSize,
      crossAxisSize: crossAxisSize,
    );
    return (
      recomputeFlex: result.recomputeFlex,
      result: -result.result,
      flexResult: -result.flexResult,
    );
  }

  @override
  String toString() {
    return 'NegatedBoxSize(original: $original)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NegatedBoxSize && other.original == original;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, original);
  }
}

class CompoundBoxSize extends BoxSize {
  final Iterable<BoxSize> sizes;

  CompoundBoxSize(this.sizes);

  @override
  bool requiresCrossAxisSize(bool mainAxis, bool crossRequires) {
    for (var size in sizes) {
      if (size.requiresCrossAxisSize(mainAxis, crossRequires)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool requiresCrossAxisParentSize(bool mainAxis) {
    for (var size in sizes) {
      if (size.requiresCrossAxisParentSize(mainAxis)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool requiresMainAxisParentSize(bool mainAxis) {
    for (var size in sizes) {
      if (size.requiresMainAxisParentSize(mainAxis)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool requiresFlexFactor(bool mainAxis) {
    for (var size in sizes) {
      if (size.requiresFlexFactor(mainAxis)) {
        return true;
      }
    }
    return false;
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    double total = 0;
    for (var size in sizes) {
      var flex = size.computeTotalFlex(biggestFlex);
      if (flex != null) {
        total += flex;
      }
    }
    return total > 0 ? total : null;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    double total = 0;
    double flexTotal = 0;
    bool recomputeFlex = false;
    for (var size in sizes) {
      final result = size.computeSize(
        child: child,
        direction: direction,
        mainAxis: mainAxis,
        computeFlex: computeFlex,
        flexFactor: flexFactor,
        biggestFlex: biggestFlex,
        mainAxisParentSize: mainAxisParentSize,
        crossAxisParentSize: crossAxisParentSize,
        crossAxisSize: crossAxisSize,
      );
      total += result.result;
      flexTotal += result.flexResult;
      recomputeFlex |= result.recomputeFlex;
    }
    return (recomputeFlex: recomputeFlex, result: total, flexResult: flexTotal);
  }

  @override
  String toString() {
    return 'CompoundBoxSize(sizes: $sizes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompoundBoxSize &&
        other.sizes.length == sizes.length &&
        other.sizes.every((size) => sizes.contains(size));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, Object.hashAll(sizes));
  }
}

class ClampedBoxSize extends BoxSize {
  final BoxSize original;
  final BoxSize? min;
  final BoxSize? max;

  ClampedBoxSize(this.original, {this.min, this.max});

  @override
  bool requiresFlexFactor(bool mainAxis) {
    return original.requiresFlexFactor(mainAxis) ||
        (min?.requiresFlexFactor(mainAxis) ?? false) ||
        (max?.requiresFlexFactor(mainAxis) ?? false);
  }

  @override
  bool requiresCrossAxisParentSize(bool mainAxis) {
    return original.requiresCrossAxisParentSize(mainAxis) ||
        (min?.requiresCrossAxisParentSize(mainAxis) ?? false) ||
        (max?.requiresCrossAxisParentSize(mainAxis) ?? false);
  }

  @override
  bool requiresCrossAxisSize(bool mainAxis, bool crossRequires) {
    return original.requiresCrossAxisSize(mainAxis, crossRequires) ||
        (min?.requiresCrossAxisSize(mainAxis, crossRequires) ?? false) ||
        (max?.requiresCrossAxisSize(mainAxis, crossRequires) ?? false);
  }

  @override
  bool requiresMainAxisParentSize(bool mainAxis) {
    return original.requiresMainAxisParentSize(mainAxis) ||
        (min?.requiresMainAxisParentSize(mainAxis) ?? false) ||
        (max?.requiresMainAxisParentSize(mainAxis) ?? false);
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    double? total = original.computeTotalFlex(biggestFlex);
    double? minFlex = min?.computeTotalFlex(biggestFlex);
    double? maxFlex = max?.computeTotalFlex(biggestFlex);
    if (minFlex != null) {
      if (total == null || minFlex > total) {
        total = minFlex;
      }
    }
    if (maxFlex != null) {
      if (total == null || maxFlex < total) {
        total = maxFlex;
      }
    }
    return total;
  }

  @override
  ({double flexResult, bool recomputeFlex, double result}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    final result = original.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisParentSize: mainAxisParentSize,
      crossAxisParentSize: crossAxisParentSize,
      crossAxisSize: crossAxisSize,
    );
    bool recomputeFlex = result.recomputeFlex;
    double combined = result.result + result.flexResult;
    bool hasFlexResult = result.flexResult > 0;
    double? minSize;
    if (min != null) {
      final minResult = min!.computeSize(
        child: child,
        direction: direction,
        mainAxis: mainAxis,
        computeFlex: computeFlex,
        flexFactor: flexFactor,
        biggestFlex: biggestFlex,
        mainAxisParentSize: mainAxisParentSize,
        crossAxisParentSize: crossAxisParentSize,
        crossAxisSize: crossAxisSize,
      );
      minSize = minResult.result + minResult.flexResult;
      recomputeFlex |= minResult.recomputeFlex;
      hasFlexResult |= minResult.flexResult > 0;
    }
    double? maxSize;
    if (max != null) {
      final maxResult = max!.computeSize(
        child: child,
        direction: direction,
        mainAxis: mainAxis,
        computeFlex: computeFlex,
        flexFactor: flexFactor,
        biggestFlex: biggestFlex,
        mainAxisParentSize: mainAxisParentSize,
        crossAxisParentSize: crossAxisParentSize,
        crossAxisSize: crossAxisSize,
      );
      maxSize = maxResult.result + maxResult.flexResult;
      recomputeFlex |= maxResult.recomputeFlex;
      hasFlexResult |= maxResult.flexResult > 0;
    }
    final clamped = _clamp(combined, minSize, maxSize);
    if (clamped != combined) {
      if (hasFlexResult) {
        return (recomputeFlex: true, result: clamped, flexResult: 0.0);
      }
      return (
        recomputeFlex: recomputeFlex,
        result: clamped,
        flexResult: 0.0,
      );
    }
    return (
      recomputeFlex: recomputeFlex,
      result: result.result,
      flexResult: result.flexResult,
    );
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
}

enum FlexSpacing {
  /// Equal spacing between children, with no spacing at the start and end
  between,

  /// Equal spacing between children, with equal spacing at the start and end
  around,

  /// Equal spacing between children, with double spacing at the start and end
  evenly,
}
