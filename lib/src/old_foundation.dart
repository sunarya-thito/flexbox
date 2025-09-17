import 'package:flexiblebox/src/old_flex.dart';
import 'package:flexiblebox/src/helper.dart';
import 'package:flutter/cupertino.dart';

enum FlexWrap {
  none,

  /// If the items overflow the main axis,
  /// they will be wrapped to the next line
  /// in the cross axis direction.
  wrap,

  /// Like [wrap], but the items will be wrapped
  /// in the reverse cross axis direction.
  /// For example, if the flexbox is horizontal,
  /// the items will be wrapped to the top
  /// instead of the bottom.
  wrapReverse,
}

enum FlexItemAlignment {
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
  flexStart,
  flexEnd,
  baseline,
  firstBaseline,
  lastBaseline,
}

enum FlexJustifyContent {
  flexStart,
  flexEnd,
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
  stretch,
  normal,
}

enum FlexPosition {
  static,
  absolute,
  relative,
  sticky,
  fixed,
}

enum FlexContentAlignment {
  flexStart,
  flexEnd,
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
  stretch,
  normal,
  baseline,
  firstBaseline,
  lastBaseline,
}

enum FlexDirection {
  column,
  row,
  columnReverse,
  rowReverse,
}

abstract class BoxValue {
  final FlexTarget target;
  const BoxValue({this.target = FlexTarget.viewport});
  const factory BoxValue.minContent() = IntrinsicSize.min;
  const factory BoxValue.maxContent() = IntrinsicSize.max;
  const factory BoxValue.fixed(double size) = FixedValue;
  const factory BoxValue.ratio(
    double ratio,
  ) = RatioSize;
  const factory BoxValue.relative(
    double relative, {
    FlexTarget target,
  }) = RelativeValue;

  bool get isPosition => true;
  bool get isSize => true;

  BoxValue withTarget(FlexTarget target);

  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  });

  static const ({double? result, bool computeAdditionalFlexBasis})
  _noFlexBasis = (
    result: null,
    computeAdditionalFlexBasis: false,
  );

  ({double? result, bool computeAdditionalFlexBasis}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) => _noFlexBasis;

  double? computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) => null;

  static const _noPostLayout = (
    result: null,
    computePostLayout: false,
  );

  // compute post flex can only adjust cross axis size
  // main axis size is finalized after flexing
  ({double? result, bool computePostLayout}) computePostFlex({
    required FlexParent parent,
    required FlexChild child,
  }) => _noPostLayout;

  // compute post layout can only adjust cross axis size
  // main axis size is finalized after flexing
  double? computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  }) => null;

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
  BoxValue divideBy(double other) => PrimitiveBoxComputer(
    this,
    other,
    PrimitiveBoxComputer.division,
    reverse: true,
  );
  BoxValue floorDivideBy(double other) => PrimitiveBoxComputer(
    this,
    other,
    PrimitiveBoxComputer.floorDivision,
    reverse: true,
  );
  BoxValue abs() =>
      TransformedValue(this, transformer: TransformedValue.absolute);
}

class IntrinsicSize extends BoxValue {
  final bool min;
  const IntrinsicSize.max() : min = false;
  const IntrinsicSize.min() : min = true;

  @override
  IntrinsicSize withTarget(FlexTarget target) {
    throw FlutterError('IntrinsicSize does not have a target');
  }

  @override
  bool get isPosition => false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntrinsicSize && other.min == min;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, min);
  }

  @override
  ({double? result, bool computeAdditionalFlexBasis}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    return (
      computeAdditionalFlexBasis: false,
      result: child.computeIntrinsic(
        parent.getDirection(mainAxis),
        parent.viewportCrossSize,
        min,
      ),
    );
  }

  @override
  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    throw FlutterError('IntrinsicSize cannot be used for positioning');
  }

  @override
  String toString() {
    return toStringObject(
      min ? 'IntrinsicSize.min' : 'IntrinsicSize.max',
    );
  }
}

class FixedValue extends BoxValue {
  final double value;

  const FixedValue(this.value, {super.target})
    : assert(
        value == value,
        'FixedValue size must not be NaN',
      ),
      assert(
        value != double.infinity && value != double.negativeInfinity,
        'FixedValue size must be a finite number, got $value. If you want an infinite size, use ExpandingSize instead.',
      );

  @override
  FixedValue withTarget(FlexTarget target) {
    return FixedValue(value, target: target);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedValue &&
        other.value == value &&
        other.target == target;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, value, target);
  }

  @override
  ({double? result, bool computeAdditionalFlexBasis}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    return (
      computeAdditionalFlexBasis: false,
      result: value,
    );
  }

  @override
  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    return value;
  }

  @override
  String toString() {
    return toStringObject(
      'FixedValue',
      params: ['$value'],
      namedParams: {
        if (target != FlexTarget.viewport)
          'target': 'FlexTarget.${target.name}',
      },
    );
  }
}

class RatioSize extends BoxValue {
  final double ratio;

  const RatioSize(this.ratio);

  @override
  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    throw FlutterError('RatioSize cannot be used for positioning');
  }

  @override
  ({double? result, bool computeAdditionalFlexBasis}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    return (
      computeAdditionalFlexBasis: mainAxis,
      result: null,
    );
  }

  @override
  double? computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    if (!mainAxis) {
      return null;
    }
    return child.data.getFlexBasis(false) * ratio;
  }

  @override
  ({double? result, bool computePostLayout}) computePostFlex({
    required FlexParent parent,
    required FlexChild child,
  }) {
    return (
      result: child.data.computedMainSize * ratio,
      computePostLayout: false,
    );
  }

  @override
  RatioSize withTarget(FlexTarget target) {
    throw FlutterError('RatioSize does not have a target');
  }

  @override
  bool get isPosition => false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatioSize && other.ratio == ratio;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, ratio);
  }

  @override
  String toString() {
    return toStringObject(
      'RatioSize',
      params: ['$ratio'],
    );
  }
}

enum FlexTarget {
  /// The size is relative to the flexbox content size
  content,
  contentCross,

  /// The size is relative to the flexbox viewport size
  viewport,
  viewportCross,

  /// The size is relative to the flex wrap line
  line,
  lineCross,

  /// Relative to the child size (only used for positioning)
  child,
  childCross,
}

class RelativeValue extends BoxValue {
  final double relative;

  const RelativeValue(
    this.relative, {
    super.target,
  });

  @override
  bool get isPosition => true;

  @override
  bool get isSize =>
      target != FlexTarget.child && target != FlexTarget.childCross;

  @override
  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    switch (target) {
      case FlexTarget.child:
        return mainAxis
            ? child.data.computedMainSize * relative
            : child.data.computedCrossSize * relative;
      case FlexTarget.childCross:
        return mainAxis
            ? child.data.computedCrossSize * relative
            : child.data.computedMainSize * relative;
      case FlexTarget.line:
        return parent.getLineContentSize(mainAxis) * relative;
      case FlexTarget.lineCross:
        return parent.getLineContentSize(!mainAxis) * relative;
      case FlexTarget.content:
        return parent.getContentSize(mainAxis) * relative;
      case FlexTarget.contentCross:
        return parent.getContentSize(!mainAxis) * relative;
      case FlexTarget.viewport:
        return mainAxis
            ? parent.viewportMainSize * relative
            : parent.viewportCrossSize * relative;
      case FlexTarget.viewportCross:
        return mainAxis
            ? parent.viewportCrossSize * relative
            : parent.viewportMainSize * relative;
    }
  }

  @override
  ({double? result, bool computeAdditionalFlexBasis}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    switch (target) {
      case FlexTarget.viewport:
        return (
          computeAdditionalFlexBasis: false,
          result: mainAxis
              ? parent.viewportMainSize * relative
              : parent.viewportCrossSize * relative,
        );
      case FlexTarget.viewportCross:
        return (
          computeAdditionalFlexBasis: false,
          result: mainAxis
              ? parent.viewportCrossSize * relative
              : parent.viewportMainSize * relative,
        );
      case FlexTarget.content:
      case FlexTarget.line:
        return (
          computeAdditionalFlexBasis: true,
          result: null,
        );
      default:
        return (
          computeAdditionalFlexBasis: false,
          result: null,
        );
    }
  }

  @override
  double? computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    switch (target) {
      case FlexTarget.content:
        return parent.getContentSize(mainAxis) * relative;
      case FlexTarget.line:
        return parent.getLineContentSize(mainAxis) * relative;
      default:
        return null;
    }
  }

  @override
  ({bool computePostLayout, double? result}) computePostFlex({
    required FlexParent parent,
    required FlexChild child,
  }) {
    switch (target) {
      case FlexTarget.viewport:
      case FlexTarget.viewportCross:
        return (computePostLayout: false, result: null);
      default:
        return (computePostLayout: true, result: null);
    }
  }

  @override
  double? computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  }) {
    switch (target) {
      case FlexTarget.contentCross:
        return parent.getContentSize(false) * relative;
      case FlexTarget.lineCross:
        return parent.getLineContentSize(false) * relative;
      default:
        return null;
    }
  }

  @override
  RelativeValue withTarget(FlexTarget target) {
    return RelativeValue(relative, target: target);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelativeValue &&
        other.relative == relative &&
        other.target == target;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, relative, target);
  }

  @override
  String toString() {
    return toStringObject(
      'RelativeValue',
      params: ['$relative'],
      namedParams: {
        if (target != FlexTarget.viewport)
          'target': 'FlexTarget.${target.name}',
      },
    );
  }
}

class TransformedValue extends BoxValue {
  static double negate(double value) => -value;
  static double absolute(double value) => value.abs();
  final BoxValue original;
  final BoxTransformer transformer;

  const TransformedValue(
    this.original, {
    required this.transformer,
  });

  @override
  bool get isPosition => original.isPosition;

  @override
  bool get isSize => original.isSize;

  @override
  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    return transformer(
      original.computePosition(
        parent: parent,
        child: child,
        mainAxis: mainAxis,
      ),
    );
  }

  @override
  double? computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    final basis = original.computeAdditionalFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    if (basis == null) {
      return null;
    }
    return transformer(basis);
  }

  @override
  ({bool computeAdditionalFlexBasis, double? result}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    final basis = original.computeFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    if (basis.result == null) {
      return (
        computeAdditionalFlexBasis: basis.computeAdditionalFlexBasis,
        result: null,
      );
    }
    return (
      computeAdditionalFlexBasis: basis.computeAdditionalFlexBasis,
      result: transformer(basis.result!),
    );
  }

  @override
  ({double? result, bool computePostLayout}) computePostFlex({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final postFlex = original.computePostFlex(
      parent: parent,
      child: child,
    );
    if (postFlex.result == null) {
      return (
        computePostLayout: postFlex.computePostLayout,
        result: null,
      );
    }
    return (
      computePostLayout: postFlex.computePostLayout,
      result: transformer(postFlex.result!),
    );
  }

  @override
  double? computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final postLayout = original.computePostLayout(
      parent: parent,
      child: child,
    );
    if (postLayout == null) {
      return null;
    }
    return transformer(postLayout);
  }

  @override
  TransformedValue withTarget(FlexTarget target) {
    throw FlutterError('TransformedValue does not have a target');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformedValue &&
        other.original == original &&
        other.transformer == transformer;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, original, transformer);
  }

  @override
  String toString() {
    String transformerName;
    switch (transformer) {
      case TransformedValue.negate:
        transformerName = 'TransformedValue.negate';
        break;
      case TransformedValue.absolute:
        transformerName = 'TransformedValue.absolute';
        break;
      default:
        transformerName = '$transformer';
    }
    return toStringObject(
      'TransformedValue',
      params: [original.toString()],
      namedParams: {
        'transformer': transformerName,
      },
    );
  }
}

typedef BoxComputerOperation = double Function(double first, double second);

class BoxComputer extends BoxValue {
  static double addition(double first, double second) => first + second;
  // NOTE: multiplication and such is not supported here
  // because it can lead to very weird results
  static double subtraction(double first, double second) => first - second;
  final BoxValue first;
  final BoxValue second;
  final BoxComputerOperation operation;

  const BoxComputer(this.first, this.second, this.operation);

  @override
  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    return operation(
      first.computePosition(parent: parent, child: child, mainAxis: mainAxis),
      second.computePosition(parent: parent, child: child, mainAxis: mainAxis),
    );
  }

  @override
  double? computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    final firstBasis = first.computeAdditionalFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    final secondBasis = second.computeAdditionalFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    if (firstBasis == null || secondBasis == null) {
      return firstBasis ?? secondBasis;
    }
    return operation(firstBasis, secondBasis);
  }

  @override
  ({bool computeAdditionalFlexBasis, double? result}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    final firstBasis = first.computeFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    final secondBasis = second.computeFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    if (firstBasis.result == null || secondBasis.result == null) {
      return (
        computeAdditionalFlexBasis:
            firstBasis.computeAdditionalFlexBasis ||
            secondBasis.computeAdditionalFlexBasis,
        result: null,
      );
    }
    return (
      computeAdditionalFlexBasis:
          firstBasis.computeAdditionalFlexBasis ||
          secondBasis.computeAdditionalFlexBasis,
      result: operation(firstBasis.result!, secondBasis.result!),
    );
  }

  @override
  ({bool computePostLayout, double? result}) computePostFlex({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final firstFlex = first.computePostFlex(parent: parent, child: child);
    final secondFlex = second.computePostFlex(parent: parent, child: child);
    if (firstFlex.result == null || secondFlex.result == null) {
      return (
        computePostLayout:
            firstFlex.computePostLayout || secondFlex.computePostLayout,
        result: null,
      );
    }
    return (
      computePostLayout:
          firstFlex.computePostLayout || secondFlex.computePostLayout,
      result: operation(firstFlex.result!, secondFlex.result!),
    );
  }

  @override
  double? computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final firstLayout = first.computePostLayout(parent: parent, child: child);
    final secondLayout = second.computePostLayout(parent: parent, child: child);
    if (firstLayout == null || secondLayout == null) {
      return firstLayout ?? secondLayout;
    }
    return operation(firstLayout, secondLayout);
  }

  @override
  bool get isPosition => first.isPosition && second.isPosition;

  @override
  bool get isSize => first.isSize && second.isSize;

  @override
  BoxComputer withTarget(FlexTarget target) {
    throw FlutterError('BoxComputer does not have a target');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoxComputer &&
        other.first == first &&
        other.second == second &&
        other.operation == operation;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, first, second, operation);
  }

  @override
  String toString() {
    String op;
    switch (operation) {
      case BoxComputer.addition:
        op = 'BoxComputer.addition';
        break;
      case BoxComputer.subtraction:
        op = 'BoxComputer.subtraction';
        break;
      default:
        op = '$operation';
    }
    return toStringObject(
      'BoxComputer',
      namedParams: {
        'first': first.toString(),
        'second': second.toString(),
        'operation': op,
      },
    );
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
  final BoxValue original;
  final double operand;
  final BoxComputerOperation operation;
  final bool reverse;
  const PrimitiveBoxComputer(
    this.original,
    this.operand,
    this.operation, {
    this.reverse = false,
  });

  @override
  double computePosition({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    return operation(
      reverse
          ? operand
          : original.computePosition(
              parent: parent,
              child: child,
              mainAxis: mainAxis,
            ),
      reverse
          ? original.computePosition(
              parent: parent,
              child: child,
              mainAxis: mainAxis,
            )
          : operand,
    );
  }

  @override
  double? computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    final basis = original.computeAdditionalFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    if (basis == null) {
      return null;
    }
    return operation(reverse ? operand : basis, reverse ? basis : operand);
  }

  @override
  ({bool computeAdditionalFlexBasis, double? result}) computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
    required bool mainAxis,
  }) {
    final basis = original.computeFlexBasis(
      parent: parent,
      child: child,
      mainAxis: mainAxis,
    );
    if (basis.result == null) {
      return (
        computeAdditionalFlexBasis: basis.computeAdditionalFlexBasis,
        result: null,
      );
    }
    return (
      computeAdditionalFlexBasis: basis.computeAdditionalFlexBasis,
      result: operation(
        reverse ? operand : basis.result!,
        reverse ? basis.result! : operand,
      ),
    );
  }

  @override
  ({bool computePostLayout, double? result}) computePostFlex({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final postFlex = original.computePostFlex(
      parent: parent,
      child: child,
    );
    if (postFlex.result == null) {
      return (
        computePostLayout: postFlex.computePostLayout,
        result: null,
      );
    }
    return (
      computePostLayout: postFlex.computePostLayout,
      result: operation(
        reverse ? operand : postFlex.result!,
        reverse ? postFlex.result! : operand,
      ),
    );
  }

  @override
  double? computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final postLayout = original.computePostLayout(
      parent: parent,
      child: child,
    );
    if (postLayout == null) {
      return null;
    }
    return operation(
      reverse ? operand : postLayout,
      reverse ? postLayout : operand,
    );
  }

  @override
  PrimitiveBoxComputer withTarget(FlexTarget target) {
    return PrimitiveBoxComputer(
      original,
      operand,
      operation,
      reverse: reverse,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrimitiveBoxComputer &&
        other.original == original &&
        other.operand == operand &&
        other.operation == operation;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, original, operand, operation);
  }

  @override
  String toString() {
    String op;
    if (operation == PrimitiveBoxComputer.multiplication) {
      op = 'PrimitiveBoxComputer.multiplication';
    } else if (operation == PrimitiveBoxComputer.division) {
      op = 'PrimitiveBoxComputer.division';
    } else if (operation == PrimitiveBoxComputer.modulo) {
      op = 'PrimitiveBoxComputer.modulo';
    } else if (operation == PrimitiveBoxComputer.floorDivision) {
      op = 'PrimitiveBoxComputer.floorDivision';
    } else {
      op = '$operation';
    }
    return toStringObject(
      'PrimitiveBoxComputer',
      namedParams: {
        'original': original.toString(),
        'operand': operand.toString(),
        'operation': op,
        'reverse': reverse.toString(),
      },
    );
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
