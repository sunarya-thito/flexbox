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
  const factory BoxSize.relativeContent(
    double relative, {
    double? min,
    double? max,
  }) = RelativeContentSize;
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

  const RelativeSize(this.relative, {super.min, super.max});

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

class RelativeContentSize extends BoxSize {
  final double relative;

  const RelativeContentSize(this.relative, {super.min, super.max});

  @override
  String toString() {
    return 'RelativeContentSize(relative: $relative, min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelativeContentSize &&
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

  const FlexSize(this.flex, {super.min, super.max});

  @override
  String toString() {
    return 'FlexSize(flex: $flex, min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlexSize &&
        other.flex == flex &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, flex, min, max);
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
  /// Fixed position, not affected by scrolling
  fixed,

  /// Relative position, affected by scrolling
  relativeViewport,

  /// Relative position anchored to the viewport instead of the flexbox,
  /// affected by scrolling but positions are calculated relative to viewport size
  relativeContent,

  /// Sticky position, affected by scrolling until it goes out of bounds.
  /// It will constrain the position to the viewport bounds.
  stickyViewport,

  /// Sticky position, but it will stick to the start (of the main axis) of the parent
  stickyStartViewport,

  /// Sticky position, but it will stick to the end (of the main axis) of the parent
  stickyEndViewport,

  /// Sticky position anchored to content, affected by scrolling until it goes out of bounds.
  /// It will constrain the position to the content bounds. Uses content dimensions as reference.
  stickyContent,

  /// Sticky position anchored to content, but it will stick to the start of the content.
  /// Uses content dimensions as reference.
  stickyStartContent,

  /// Sticky position anchored to content, but it will stick to the end of the content.
  /// Uses content dimensions as reference.
  stickyEndContent,
}
