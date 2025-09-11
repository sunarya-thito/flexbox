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

const Iterable<Key> _emptyDependency = Iterable.empty();

const ({
  bool needsCrossAxisParentSize,
  bool needsFlexFactor,
  bool needsMainAxisParentSize,
})
_noDependency = (
  needsCrossAxisParentSize: false,
  needsMainAxisParentSize: false,
  needsFlexFactor: false,
);

abstract class BoxSize {
  final Key? key;
  const BoxSize({this.key});
  const factory BoxSize.intrinsic({Key? key}) = IntrinsicSize;
  const factory BoxSize.fixed(double size, {Key? key}) = FixedSize;
  const factory BoxSize.expanding({bool intrinsicFallback, Key? key}) =
      ExpandingSize;
  const factory BoxSize.ratio(
    double ratio, {
    Key? key,
  }) = RatioSize;
  const factory BoxSize.relative(
    double relative, {
    bool intrinsicFallback,
    Key? key,
  }) = RelativeSize;
  const factory BoxSize.flex(double flex, {bool intrinsicFallback, Key? key}) =
      FlexSize;

  void debugIsValid() {}

  BoxSize clamp({BoxSize? min, BoxSize? max}) {
    if (min == null && max == null) {
      return this;
    }

    return ClampedSize(this, min: min, max: max);
  }

  ({
    // if true, it means this size needs to know the parent size in the cross axis before it can be computed
    bool needsCrossAxisParentSize,
    // if true, it means this size needs to know the parent size in the main axis before it can be computed
    bool needsMainAxisParentSize,
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

  Iterable<Key> get dependencies => _emptyDependency;

  bool get needsCrossAxis => false;

  double? computeTotalFlex(double? biggestFlex) => null;

  // if this returns null, it means
  // there is a dependency that has not been resolved yet
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  });

  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  });

  operator -() => NegatedBoxSize(this);

  BoxSize operator +(BoxSize other) =>
      BoxSizeComputer(this, other, BoxSizeComputer.addition);
  BoxSize operator -(BoxSize other) =>
      BoxSizeComputer(this, other, BoxSizeComputer.subtraction);
  BoxSize operator *(double other) => PrimitiveSizeComputer(
    this,
    other,
    PrimitiveSizeComputer.multiplication,
  );
  BoxSize operator /(double other) =>
      PrimitiveSizeComputer(this, other, PrimitiveSizeComputer.division);
  BoxSize operator %(double other) =>
      PrimitiveSizeComputer(this, other, PrimitiveSizeComputer.modulo);
  BoxSize operator ~() => NegatedBoxSize(this);
  BoxSize operator ~/(double other) => PrimitiveSizeComputer(
    this,
    other,
    PrimitiveSizeComputer.floorDivision,
  );
}

class IntrinsicSize extends BoxSize {
  const IntrinsicSize({super.key});

  @override
  ({
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsCrossAxisParentSize: !mainAxis,
      needsMainAxisParentSize: mainAxis,
      needsFlexFactor: false,
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
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    double result;
    switch (direction) {
      case Axis.horizontal:
        result = child.getMaxIntrinsicWidth(
          (mainAxis ? crossAxisParentSize : mainAxisParentSize) ??
              double.infinity,
        );
        break;
      case Axis.vertical:
        result = child.getMaxIntrinsicHeight(
          (mainAxis ? crossAxisParentSize : mainAxisParentSize) ??
              double.infinity,
        );
    }
    if (key != null && dependsOn.contains(key)) {
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

class FixedSize extends BoxSize {
  final double size;

  const FixedSize(this.size, {super.key})
    : assert(
        size == size,
        'FixedSize size must not be NaN',
      ),
      assert(
        size != double.infinity && size != double.negativeInfinity,
        'FixedSize size must be a finite number, got $size. If you want an infinite size, use ExpandingSize instead.',
      );

  @override
  void debugIsValid() {
    if (size.isNaN) {
      throw FlutterError('FixedSize size must be a finite number, got $size');
    }
    if (size.isInfinite) {
      throw FlutterError(
        'FixedSize size must be a finite number, got $size. If you want an infinite size, use ExpandingSize instead.',
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
    double result = size;
    if (key != null) {
      dependencies[key!] = result;
    }
    return result;
  }

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
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
  }) {
    if (key != null && dependsOn.contains(key)) {
      dependencies[key!] = size;
    }
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
    super.key,
  });

  @override
  ({
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsCrossAxisParentSize: !mainAxis,
      needsMainAxisParentSize: false,
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
    if (intrinsicFallback && child != null) {
      double result = switch (direction) {
        Axis.horizontal => child.getMaxIntrinsicWidth(extent),
        Axis.vertical => child.getMaxIntrinsicHeight(extent),
      };
      if (key != null) {
        dependencies[key!] = result;
      }
      return result;
    }
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
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
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
    if (key != null && dependsOn.contains(key)) {
      dependencies[key!] = result;
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

  const RatioSize(this.ratio, {super.key});

  @override
  void debugIsValid() {
    if (ratio.isNaN || ratio.isInfinite) {
      throw FlutterError('RatioSize ratio must be a finite number, got $ratio');
    }
  }

  @override
  ({
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsCrossAxisParentSize: false,
      needsMainAxisParentSize: false,
      needsFlexFactor: false,
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
  bool get needsCrossAxis => true;

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
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
    if (key != null && dependsOn.contains(key)) {
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
    super.key,
  });

  @override
  void debugIsValid() {
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
    if (intrinsicFallback) {
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
    if (key != null) {
      dependencies[key!] = 0.0;
    }
    return 0.0;
  }

  @override
  ({
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsCrossAxisParentSize: !mainAxis,
      needsMainAxisParentSize: mainAxis,
      needsFlexFactor: false,
    );
  }

  @override
  ({bool recomputeFlex, double result, double flexResult}) computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
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
    if (key != null && dependsOn.contains(key)) {
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
    super.key,
  });

  @override
  void debugIsValid() {
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
    if (intrinsicFallback && child != null) {
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
    if (key != null) {
      dependencies[key!] = 0.0;
    }
    return 0.0;
  }

  @override
  ({
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return (
      needsCrossAxisParentSize: !mainAxis,
      needsMainAxisParentSize: false,
      needsFlexFactor: mainAxis,
    );
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
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
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
    if (key != null && dependsOn.contains(key)) {
      dependencies[key!] = result;
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

  NegatedBoxSize(this.original, {super.key});

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? result = original.computeIntrinsicSize(
      child: child,
      direction: direction,
      extent: extent,
      dependencies: dependencies,
      computeMax: computeMax,
    );
    if (result == null) {
      return null;
    }
    if (key != null) {
      dependencies[key!] = -result;
    }
    return -result;
  }

  @override
  void debugIsValid() {
    original.debugIsValid();
  }

  @override
  ({
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return original.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
  }

  @override
  bool get needsCrossAxis => original.needsCrossAxis;

  @override
  double? computeTotalFlex(double? biggestFlex) {
    // do not negate this, the total flex needs to be positive
    // to compute the flex factor
    return original.computeTotalFlex(biggestFlex);
  }

  @override
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
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
      dependencies: dependencies,
      dependsOn: dependsOn,
    );
    if (result == null) {
      return null;
    }
    if (key != null && dependsOn.contains(key)) {
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

typedef BoxSizeComputerOperation = double Function(double first, double second);

class BoxSizeComputer extends BoxSize {
  static double addition(double first, double second) => first + second;
  // NOTE: multiplication and such is not supported here
  // because it can lead to very weird results
  // static double multiplication(double first, double second) => first * second;
  // static double division(double first, double second) => first / second;
  // static double modulo(double first, double second) => first % second;
  static double subtraction(double first, double second) => first - second;
  static double max(double first, double second) =>
      first > second ? first : second;
  static double min(double first, double second) =>
      first < second ? first : second;
  // static double floorDivision(double first, double second) =>
  //     (first / second).floorToDouble();
  final BoxSize first;
  final BoxSize second;
  final BoxSizeComputerOperation operation;

  BoxSizeComputer(this.first, this.second, this.operation, {super.key});

  @override
  void debugIsValid() {
    first.debugIsValid();
    second.debugIsValid();
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? firstResult = first.computeIntrinsicSize(
      child: child,
      direction: direction,
      extent: extent,
      dependencies: dependencies,
      computeMax: computeMax,
    );
    double? secondResult = second.computeIntrinsicSize(
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
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    final firstDep = first.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
    final secondDep = second.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
    return (
      needsCrossAxisParentSize:
          firstDep.needsCrossAxisParentSize ||
          secondDep.needsCrossAxisParentSize,
      needsMainAxisParentSize:
          firstDep.needsMainAxisParentSize || secondDep.needsMainAxisParentSize,
      needsFlexFactor: firstDep.needsFlexFactor || secondDep.needsFlexFactor,
    );
  }

  @override
  bool get needsCrossAxis => first.needsCrossAxis || second.needsCrossAxis;

  @override
  Iterable<Key> get dependencies =>
      first.dependencies.followedBy(second.dependencies);

  @override
  double? computeTotalFlex(double? biggestFlex) {
    // always add the flexes together
    // do not apply the operation here
    double total = 0;
    var firstFlex = first.computeTotalFlex(biggestFlex);
    if (firstFlex != null) {
      total += firstFlex;
    }
    var secondFlex = second.computeTotalFlex(biggestFlex);
    if (secondFlex != null) {
      total += secondFlex;
    }
    return total > 0 ? total : null;
  }

  @override
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Iterable<Key> dependsOn,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
    required Map<Key, double> dependencies,
  }) {
    final firstResult = first.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisParentSize: mainAxisParentSize,
      crossAxisParentSize: crossAxisParentSize,
      crossAxisSize: crossAxisSize,
      dependencies: dependencies,
      dependsOn: dependsOn,
    );
    final secondResult = second.computeSize(
      child: child,
      direction: direction,
      mainAxis: mainAxis,
      computeFlex: computeFlex,
      flexFactor: flexFactor,
      biggestFlex: biggestFlex,
      mainAxisParentSize: mainAxisParentSize,
      crossAxisParentSize: crossAxisParentSize,
      crossAxisSize: crossAxisSize,
      dependencies: dependencies,
      dependsOn: dependsOn,
    );
    if (firstResult == null || secondResult == null) {
      return null;
    }
    final result = operation(firstResult.result, secondResult.result);
    final flexResult = operation(
      firstResult.flexResult,
      secondResult.flexResult,
    );
    if (key != null && dependsOn.contains(key)) {
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
    return other is BoxSizeComputer &&
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
class PrimitiveSizeComputer extends BoxSize {
  static double multiplication(double first, double second) => first * second;
  static double division(double first, double second) => first / second;
  static double modulo(double first, double second) => first % second;
  static double floorDivision(double first, double second) =>
      (first / second).floorToDouble();
  final BoxSize original;
  final double operand;
  final BoxSizeComputerOperation operation;
  PrimitiveSizeComputer(
    this.original,
    this.operand,
    this.operation, {
    super.key,
  });

  @override
  void debugIsValid() {
    original.debugIsValid();
    if (operand.isNaN || operand.isInfinite) {
      throw FlutterError(
        'PrimitiveBoxSizeComputer operand must be a finite number, got $operand',
      );
    }
  }

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? result = original.computeIntrinsicSize(
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
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    return original.getRequiredInputs(
      mainAxis: mainAxis,
      crossRequiresSize: crossRequiresSize,
    );
  }

  @override
  bool get needsCrossAxis => original.needsCrossAxis;

  @override
  Iterable<Key> get dependencies => original.dependencies;

  @override
  double? computeTotalFlex(double? biggestFlex) {
    final result = original.computeTotalFlex(biggestFlex);
    if (result == null) {
      return null;
    }
    return operation(result, operand);
  }

  @override
  ({bool recomputeFlex, double result, double flexResult})? computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
    double? crossAxisSize,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
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
      dependencies: dependencies,
      dependsOn: dependsOn,
    );
    if (result == null) {
      return null;
    }
    final value = operation(result.result, operand);
    if (key != null && dependsOn.contains(key)) {
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
    return other is PrimitiveSizeComputer &&
        other.original == original &&
        other.operand == operand;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, original, operand);
  }
}

class ClampedSize extends BoxSize {
  final BoxSize original;
  final BoxSize? min;
  final BoxSize? max;

  ClampedSize(this.original, {this.min, this.max, super.key});

  @override
  double? computeIntrinsicSize({
    required RenderBox? child,
    required Axis direction,
    required double extent,
    required Map<Key, double> dependencies,
    required bool computeMax,
  }) {
    double? originalSize = original.computeIntrinsicSize(
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
    if (min != null) {
      minSize = min!.computeIntrinsicSize(
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
    if (max != null) {
      maxSize = max!.computeIntrinsicSize(
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
    bool needsCrossAxisParentSize,
    bool needsFlexFactor,
    bool needsMainAxisParentSize,
  })
  getRequiredInputs({required bool mainAxis, bool? crossRequiresSize}) {
    final originalDep = original.getRequiredInputs(
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
      needsCrossAxisParentSize:
          originalDep.needsCrossAxisParentSize ||
          minDep.needsCrossAxisParentSize ||
          maxDep.needsCrossAxisParentSize,
      needsMainAxisParentSize:
          originalDep.needsMainAxisParentSize ||
          minDep.needsMainAxisParentSize ||
          maxDep.needsMainAxisParentSize,
      needsFlexFactor:
          originalDep.needsFlexFactor ||
          minDep.needsFlexFactor ||
          maxDep.needsFlexFactor,
    );
  }

  @override
  void debugIsValid() {
    original.debugIsValid();
    min?.debugIsValid();
    max?.debugIsValid();
  }

  @override
  bool get needsCrossAxis =>
      original.needsCrossAxis ||
      (min?.needsCrossAxis ?? false) ||
      (max?.needsCrossAxis ?? false);

  @override
  Iterable<Key> get dependencies {
    var originalDep = original.dependencies;
    if (min != null) {
      originalDep = originalDep.followedBy(min!.dependencies);
    }
    if (max != null) {
      originalDep = originalDep.followedBy(max!.dependencies);
    }
    return originalDep;
  }

  @override
  double? computeTotalFlex(double? biggestFlex) {
    // do not clamp total flex
    return original.computeTotalFlex(biggestFlex);
  }

  @override
  ({double flexResult, bool recomputeFlex, double result})? computeSize({
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
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
      dependencies: dependencies,
      dependsOn: dependsOn,
    );
    if (result == null) {
      return null;
    }
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
        dependencies: dependencies,
        dependsOn: dependsOn,
      );
      if (minResult == null) {
        return null;
      }
      minSize = minResult.result + minResult.flexResult;
      recomputeFlex |= minResult.recomputeFlex;
      // hasFlexResult |= minResult.flexResult > 0;
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
        dependencies: dependencies,
        dependsOn: dependsOn,
      );
      if (maxResult == null) {
        return null;
      }
      maxSize = maxResult.result + maxResult.flexResult;
      recomputeFlex |= maxResult.recomputeFlex;
      // hasFlexResult |= maxResult.flexResult > 0;
    }
    final clamped = _clamp(combined, minSize, maxSize);
    if (clamped != combined) {
      if (key != null && dependsOn.contains(key)) {
        dependencies[key!] = clamped;
      }

      if (hasFlexResult) {
        return (recomputeFlex: true, result: clamped, flexResult: 0.0);
      }

      return (
        recomputeFlex: recomputeFlex,
        result: clamped,
        flexResult: 0.0,
      );
    }

    if (key != null && dependsOn.contains(key)) {
      dependencies[key!] = combined;
    }
    return (
      recomputeFlex: recomputeFlex,
      result: result.result,
      flexResult: result.flexResult,
    );
  }
}

class _SingleIterable<T> extends Iterable<T> {
  final T value;

  _SingleIterable(this.value);

  @override
  Iterator<T> get iterator => _SingleIterator(value);
}

class _SingleIterator<T> implements Iterator<T> {
  final T value;
  bool _hasNext = true;

  _SingleIterator(this.value);

  @override
  T get current => _hasNext ? value : throw StateError('No more elements');

  @override
  bool moveNext() {
    if (_hasNext) {
      _hasNext = false;
      return true;
    }
    return false;
  }
}

class LinkedSize extends BoxSize {
  final Key targetKey;

  const LinkedSize(this.targetKey, {super.key});

  @override
  Iterable<Key> get dependencies => _SingleIterable(targetKey);

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
    required RenderBox child,
    required Axis direction,
    required bool mainAxis,
    required bool computeFlex,
    required Map<Key, double> dependencies,
    required Iterable<Key> dependsOn,
    double? flexFactor,
    double? biggestFlex,
    double? mainAxisParentSize,
    double? crossAxisParentSize,
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
    if (key != null && dependsOn.contains(key)) {
      dependencies[key!] = result;
    }
    return (flexResult: 0.0, recomputeFlex: false, result: result);
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
