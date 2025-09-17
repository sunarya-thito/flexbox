import 'dart:math';
import 'dart:ui';

import 'package:flexiblebox/src/flex.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flutter/widgets.dart';

abstract base class LayoutDirection {
  static const LayoutDirection horizontal = HorizontalLayoutDirection();
  static const LayoutDirection vertical = VerticalLayoutDirection();
  static LayoutDirection lerp(
    LayoutDirection a,
    LayoutDirection b,
    double t,
  ) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return _LerpedLayoutDirection(a, b, t);
  }

  const LayoutDirection();

  double getViewportSize(ParentLayout parent) {
    return lerpDoubleValue(
      parent.viewportSize.width,
      parent.viewportSize.height,
    );
  }

  double getContentSize(ParentLayout parent) {
    return lerpDoubleValue(parent.contentSize.width, parent.contentSize.height);
  }

  double getChildSize(ChildLayout child) {
    return lerpDoubleValue(child.size.width, child.size.height);
  }

  double getScrollOffset(ParentLayout parent) {
    return lerpDoubleValue(parent.scrollOffsetX, parent.scrollOffsetY);
  }

  double getLayoutOffset(LayoutHandle layout) {
    return lerpDoubleValue(layout.horizontalOffset, layout.verticalOffset);
  }

  double getContentOverflow(ParentLayout parent) {
    Size contentSize = parent.contentSize;
    Size viewportSize = parent.viewportSize;
    return (contentSize.width - viewportSize.width).clamp(0.0, double.infinity);
  }

  double getContentUnderflow(ParentLayout parent) {
    Size contentSize = parent.contentSize;
    Size viewportSize = parent.viewportSize;
    return (viewportSize.width - contentSize.width).clamp(0.0, double.infinity);
  }

  double getMaxConstraint(BoxConstraints constraints) {
    return lerpDoubleValue(constraints.maxWidth, constraints.maxHeight);
  }

  double getMinIntrinsic(ChildLayout child, BoxConstraints constraints) {
    return lerpDoubleValue(
      child.computeMinIntrinsicWidth(constraints.maxHeight),
      child.computeMinIntrinsicHeight(constraints.maxWidth),
    );
  }

  double getMaxIntrinsic(ChildLayout child, BoxConstraints constraints) {
    return lerpDoubleValue(
      child.computeMaxIntrinsicWidth(constraints.maxHeight),
      child.computeMaxIntrinsicHeight(constraints.maxWidth),
    );
  }

  double getAxisSize(Size size) {
    return lerpDoubleValue(size.width, size.height);
  }

  SizeUnit getMainSizeUnit(SizeUnit width, SizeUnit height) {
    return SizeUnit.lerp(width, height, verticalValue);
  }

  SizeUnit getCrossSizeUnit(SizeUnit width, SizeUnit height) {
    return SizeUnit.lerp(width, height, horizontalValue);
  }

  double get verticalValue;
  double get horizontalValue;
  double lerpDoubleValue(double horizontal, double vertical) {
    return horizontal * horizontalValue + vertical * verticalValue;
  }

  SpacingUnit getMainSpacingUnit(SpacingUnit horizontal, SpacingUnit vertical) {
    return SpacingUnit.lerp(horizontal, vertical, verticalValue);
  }

  SpacingUnit getCrossSpacingUnit(
    SpacingUnit horizontal,
    SpacingUnit vertical,
  ) {
    return SpacingUnit.lerp(horizontal, vertical, horizontalValue);
  }

  LayoutDirection operator ~();
}

final class HorizontalLayoutDirection extends LayoutDirection {
  const HorizontalLayoutDirection();

  @override
  double get horizontalValue => 1.0;

  @override
  double get verticalValue => 0.0;

  @override
  LayoutDirection operator ~() {
    return LayoutDirection.vertical;
  }
}

final class VerticalLayoutDirection extends LayoutDirection {
  const VerticalLayoutDirection();

  @override
  double get horizontalValue => 0.0;

  @override
  double get verticalValue => 1.0;

  @override
  LayoutDirection operator ~() {
    return LayoutDirection.horizontal;
  }
}

final class _LerpedLayoutDirection implements LayoutDirection {
  final LayoutDirection a;
  final LayoutDirection b;
  final double t;

  const _LerpedLayoutDirection(this.a, this.b, this.t);

  @override
  double get horizontalValue =>
      lerpDouble(a.horizontalValue, b.horizontalValue, t)!;

  @override
  double get verticalValue => lerpDouble(a.verticalValue, b.verticalValue, t)!;

  @override
  SizeUnit getMainSizeUnit(SizeUnit width, SizeUnit height) {
    return SizeUnit.lerp(
      a.getMainSizeUnit(width, height),
      b.getMainSizeUnit(width, height),
      t,
    );
  }

  @override
  SizeUnit getCrossSizeUnit(SizeUnit width, SizeUnit height) {
    return SizeUnit.lerp(
      a.getCrossSizeUnit(width, height),
      b.getCrossSizeUnit(width, height),
      t,
    );
  }

  @override
  double getAxisSize(Size size) {
    return lerpDouble(a.getAxisSize(size), b.getAxisSize(size), t)!;
  }

  @override
  double getChildSize(ChildLayout child) {
    return lerpDouble(a.getChildSize(child), b.getChildSize(child), t)!;
  }

  @override
  double getContentOverflow(ParentLayout parent) {
    return lerpDouble(
      a.getContentOverflow(parent),
      b.getContentOverflow(parent),
      t,
    )!;
  }

  @override
  double getContentSize(ParentLayout parent) {
    return lerpDouble(a.getContentSize(parent), b.getContentSize(parent), t)!;
  }

  @override
  double getContentUnderflow(ParentLayout parent) {
    return lerpDouble(
      a.getContentUnderflow(parent),
      b.getContentUnderflow(parent),
      t,
    )!;
  }

  @override
  double getLayoutOffset(LayoutHandle<Layout> layout) {
    return lerpDouble(
      a.getLayoutOffset(layout),
      b.getLayoutOffset(layout),
      t,
    )!;
  }

  @override
  double getMaxConstraint(BoxConstraints constraints) {
    return lerpDouble(
      a.getMaxConstraint(constraints),
      b.getMaxConstraint(constraints),
      t,
    )!;
  }

  @override
  double getMaxIntrinsic(ChildLayout child, BoxConstraints constraints) {
    return lerpDouble(
      a.getMaxIntrinsic(child, constraints),
      b.getMaxIntrinsic(child, constraints),
      t,
    )!;
  }

  @override
  double getMinIntrinsic(ChildLayout child, BoxConstraints constraints) {
    return lerpDouble(
      a.getMinIntrinsic(child, constraints),
      b.getMinIntrinsic(child, constraints),
      t,
    )!;
  }

  @override
  double getScrollOffset(ParentLayout parent) {
    return lerpDouble(
      a.getScrollOffset(parent),
      b.getScrollOffset(parent),
      t,
    )!;
  }

  @override
  double getViewportSize(ParentLayout parent) {
    return lerpDouble(
      a.getViewportSize(parent),
      b.getViewportSize(parent),
      t,
    )!;
  }

  @override
  LayoutDirection operator ~() {
    return _LerpedLayoutDirection(~a, ~b, t);
  }

  @override
  SpacingUnit getCrossSpacingUnit(
    SpacingUnit horizontal,
    SpacingUnit vertical,
  ) {
    return SpacingUnit.lerp(
      a.getCrossSpacingUnit(horizontal, vertical),
      b.getCrossSpacingUnit(horizontal, vertical),
      t,
    );
  }

  @override
  SpacingUnit getMainSpacingUnit(SpacingUnit horizontal, SpacingUnit vertical) {
    return SpacingUnit.lerp(
      a.getMainSpacingUnit(horizontal, vertical),
      b.getMainSpacingUnit(horizontal, vertical),
      t,
    );
  }

  @override
  double lerpDoubleValue(double horizontal, double vertical) {
    return lerpDouble(
      a.lerpDoubleValue(horizontal, vertical),
      b.lerpDoubleValue(horizontal, vertical),
      t,
    )!;
  }
}

class AspectRatioUnit {
  static const AspectRatioUnit normal = AspectRatioUnit(
    1.0,
    widthFactor: 0.0,
    heightFactor: 0.0,
  );

  /// How much should the aspect ratio affect width.
  final double widthFactor;

  /// How much should the aspect ratio affect height.
  final double heightFactor;
  final double value;
  const AspectRatioUnit(
    this.value, {
    this.widthFactor = 1.0,
    this.heightFactor = 1.0,
  });

  static AspectRatioUnit lerp(AspectRatioUnit a, AspectRatioUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return AspectRatioUnit(
      lerpDouble(a.value, b.value, t)!,
      widthFactor: lerpDouble(a.widthFactor, b.widthFactor, t)!,
      heightFactor: lerpDouble(a.heightFactor, b.heightFactor, t)!,
    );
  }
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

// enum BoxPosition {
//   // static positioning is not supported
//   // static,
//   // absolute positioning is controlled
//   // absolute,
//   relative,
//   sticky,
//   // fixed,
// }

// enum BoxPosition {
//   fixed,
//   relative,
// }
enum PositionTarget {
  viewport,
  content,
}

// enum FlexContentAlignment {
//   flexStart,
//   flexEnd,
//   start,
//   end,
//   center,
//   spaceBetween,
//   spaceAround,
//   spaceEvenly,
//   stretch,
//   normal,
//   baseline,
//   firstBaseline,
//   lastBaseline,
// }

class BoxInsets {
  final InsetUnit left;
  final InsetUnit top;
  final InsetUnit right;
  final InsetUnit bottom;

  const BoxInsets.only({
    this.left = InsetUnit.zero,
    this.top = InsetUnit.zero,
    this.right = InsetUnit.zero,
    this.bottom = InsetUnit.zero,
  });

  const BoxInsets.all(InsetUnit value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  const BoxInsets.symmetric({
    InsetUnit horizontal = InsetUnit.zero,
    InsetUnit vertical = InsetUnit.zero,
  }) : left = horizontal,
       right = horizontal,
       top = vertical,
       bottom = vertical;

  static BoxInsets lerp(BoxInsets a, BoxInsets b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return BoxInsets.only(
      left: InsetUnit.lerp(a.left, b.left, t),
      top: InsetUnit.lerp(a.top, b.top, t),
      right: InsetUnit.lerp(a.right, b.right, t),
      bottom: InsetUnit.lerp(a.bottom, b.bottom, t),
    );
  }

  static const BoxInsets zero = BoxInsets.all(InsetUnit.zero);

  BoxInsets resolve(TextDirection direction) {
    return this;
  }
}

class DirectionalBoxInsets extends BoxInsets {
  const DirectionalBoxInsets.only({
    InsetUnit start = InsetUnit.zero,
    super.top,
    InsetUnit end = InsetUnit.zero,
    super.bottom,
  }) : super.only(
         left: start,
         right: end,
       );

  const DirectionalBoxInsets.all(super.value) : super.all();

  const DirectionalBoxInsets.symmetric({
    super.horizontal,
    super.vertical,
  }) : super.symmetric();

  @override
  BoxInsets resolve(TextDirection direction) {
    if (direction == TextDirection.ltr) {
      return BoxInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
    } else {
      return BoxInsets.only(
        left: right,
        top: top,
        right: left,
        bottom: bottom,
      );
    }
  }
}

abstract class InsetUnit {
  static const InsetUnit viewportSize = InsetViewportSizeReference();
  static const InsetUnit zero = FixedInset(0);
  const factory InsetUnit.fixed(double value) = FixedInset;
  const factory InsetUnit.cross(InsetUnit insets) = CrossInsets;
  const factory InsetUnit.computed({
    required InsetUnit first,
    required InsetUnit second,
    required CalculationOperation operation,
  }) = ComputedInsets;
  const factory InsetUnit.constrained({
    required InsetUnit insets,
    InsetUnit min,
    InsetUnit max,
  }) = ConstrainedInsets;
  static InsetUnit lerp(InsetUnit a, InsetUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * FixedInset(1.0 - t) + b * FixedInset(t);
  }

  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection axis,
  });
}

class FixedInset implements InsetUnit {
  final double value;
  const FixedInset(this.value);

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection axis,
  }) {
    return value;
  }
}

class InsetViewportSizeReference implements InsetUnit {
  const InsetViewportSizeReference();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection axis,
  }) {
    return axis.getViewportSize(parent);
  }
}

class ComputedInsets implements InsetUnit {
  final InsetUnit first;
  final InsetUnit second;
  final CalculationOperation operation;
  const ComputedInsets({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection axis,
  }) {
    double first = this.first.computeSpacing(
      parent: parent,
      child: child,
      axis: axis,
    );
    double second = this.second.computeSpacing(
      parent: parent,
      child: child,
      axis: axis,
    );
    return operation(first, second);
  }
}

class ConstrainedInsets implements InsetUnit {
  final InsetUnit insets;
  final InsetUnit min;
  final InsetUnit max;

  const ConstrainedInsets({
    required this.insets,
    this.min = const FixedInset(0),
    this.max = const FixedInset(double.infinity),
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection axis,
  }) {
    double sz = insets.computeSpacing(
      parent: parent,
      child: child,
      axis: axis,
    );
    double minSz = min.computeSpacing(
      parent: parent,
      child: child,
      axis: axis,
    );
    double maxSz = max.computeSpacing(
      parent: parent,
      child: child,
      axis: axis,
    );
    return sz.clamp(minSz, maxSz);
  }
}

class CrossInsets implements InsetUnit {
  final InsetUnit insets;

  const CrossInsets(this.insets);

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection axis,
  }) {
    return insets.computeSpacing(
      parent: parent,
      child: child,
      axis: ~axis,
    );
  }
}

abstract class SizeUnit {
  static SizeUnit lerp(SizeUnit a, SizeUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * FixedSize(1.0 - t) + b * FixedSize(t);
  }

  static const SizeUnit zero = FixedSize(0);
  const factory SizeUnit.fixed(double value) = FixedSize;
  static const SizeUnit minContent = MinContent();
  static const SizeUnit maxContent = MaxContent();
  static const SizeUnit fitContent = FitContent();
  static const SizeUnit viewportSize = SizeViewportSizeReference();
  static const SizeUnit maxViewportSize = SizeMaxViewportSizeReference();
  static const SizeUnit auto = AutoSize();

  const SizeUnit();

  bool get needsPostAdjustment;

  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  });
}

abstract class PositionUnit {
  static PositionUnit lerp(PositionUnit a, PositionUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * FixedPosition(1.0 - t) + b * FixedPosition(t);
  }

  static const PositionUnit zero = FixedPosition(0);
  static const PositionUnit viewportSize = ViewportSizeReference();
  static const PositionUnit contentSize = ContentSizeReference();
  static const PositionUnit childSize = ChildSizeReference();
  static const PositionUnit lineOffset = LineOffset();
  static const PositionUnit boxOffset = BoxOffset();
  static const PositionUnit scrollOffset = ScrollOffset();
  static const PositionUnit contentOverflow = ContentOverflow();
  static const PositionUnit contentUnderflow = ContentUnderflow();
  const factory PositionUnit.fixed(double value) = FixedPosition;
  const factory PositionUnit.cross(PositionUnit position) = CrossPosition;
  const factory PositionUnit.constrained({
    required PositionUnit position,
    PositionUnit min,
    PositionUnit max,
  }) = ConstrainedPosition;

  const PositionUnit();
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  });
}

typedef CalculationOperation = double Function(double a, double b);

double calculationAdd(double a, double b) => a + b;
double calculationSubtract(double a, double b) => a - b;
double calculationMultiply(double a, double b) => a * b;
double calculationDivide(double a, double b) => a / b;

class CalculatedSize implements SizeUnit {
  final SizeUnit first;
  final SizeUnit second;
  final CalculationOperation operation;
  const CalculatedSize({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  bool get needsPostAdjustment =>
      first.needsPostAdjustment || second.needsPostAdjustment;

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    double first = this.first.computeSize(
      parent: parent,
      child: child,
      constraints: constraints,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double second = this.second.computeSize(
      parent: parent,
      child: child,
      constraints: constraints,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    return operation(first, second);
  }
}

class CalculatedPosition implements PositionUnit {
  final PositionUnit first;
  final PositionUnit second;
  final CalculationOperation operation;
  const CalculatedPosition({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    double first = this.first.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    double second = this.second.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    return operation(first, second);
  }
}

class FixedPosition implements PositionUnit {
  final double value;
  const FixedPosition(this.value);

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    return value;
  }
}

class ViewportSizeReference implements PositionUnit {
  const ViewportSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    return direction.getViewportSize(parent);
  }
}

class ContentSizeReference implements PositionUnit {
  const ContentSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    return direction.getContentSize(parent);
  }
}

class ChildSizeReference implements PositionUnit {
  const ChildSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    return direction.getChildSize(child);
  }
}

class LineOffset implements PositionUnit {
  const LineOffset();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    final layout = parent.layoutHandle;
    assert(
      layout is FlexLayoutHandle,
      'LineSize can only be used in FlexLayout',
    );
    final flexLayout = layout as FlexLayoutHandle;
    final childCache = child.layoutCache;
    assert(
      childCache is FlexChildLayoutCache,
      'LineSize can only be used in FlexLayout',
    );
    final flexChildCache = childCache as FlexChildLayoutCache;
    double line = flexChildCache.line - 1;
    return flexLayout.cache.getCrossSizesUntilLine(line);
  }
}

class BoxOffset implements PositionUnit {
  const BoxOffset();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    return direction.getLayoutOffset(parent.layoutHandle);
  }
}

class ScrollOffset implements PositionUnit {
  const ScrollOffset();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    return direction.getScrollOffset(parent);
  }
}

class ContentOverflow implements PositionUnit {
  const ContentOverflow();
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    // Size contentSize = parent.contentSize;
    // Size viewportSize = parent.viewportSize;
    // return direction == LayoutDirection.horizontal
    //     ? (contentSize.width - viewportSize.width).clamp(0.0, double.infinity)
    //     : (contentSize.height - viewportSize.height).clamp(
    //         0.0,
    //         double.infinity,
    //       );
    return direction.getContentOverflow(parent);
  }
}

class ContentUnderflow implements PositionUnit {
  const ContentUnderflow();
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    // Size contentSize = parent.contentSize;
    // Size viewportSize = parent.viewportSize;
    // return direction == LayoutDirection.horizontal
    //     ? (contentSize.width - viewportSize.width).clamp(0.0, double.infinity)
    //     : (contentSize.height - viewportSize.height).clamp(
    //         0.0,
    //         double.infinity,
    //       );
    return direction.getContentUnderflow(parent);
  }
}

class CrossPosition implements PositionUnit {
  final PositionUnit position;

  const CrossPosition(this.position);

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    return position.computePosition(
      parent: parent,
      child: child,
      direction: ~direction,
    );
  }
}

class ConstrainedPosition implements PositionUnit {
  final PositionUnit position;
  final PositionUnit min;
  final PositionUnit max;

  const ConstrainedPosition({
    required this.position,
    this.min = const FixedPosition(double.negativeInfinity),
    this.max = const FixedPosition(double.infinity),
  });

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutDirection direction,
  }) {
    double pos = position.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    double minPos = min.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    double maxPos = max.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    return pos.clamp(minPos, maxPos);
  }
}

class ConstrainedSize implements SizeUnit {
  final SizeUnit size;
  final SizeUnit min;
  final SizeUnit max;

  const ConstrainedSize({
    required this.size,
    this.min = const FixedSize(0),
    this.max = const FixedSize(double.infinity),
  });

  @override
  bool get needsPostAdjustment =>
      size.needsPostAdjustment ||
      min.needsPostAdjustment ||
      max.needsPostAdjustment;

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    double sz = size.computeSize(
      parent: parent,
      child: child,
      constraints: constraints,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double minSz = min.computeSize(
      parent: parent,
      child: child,
      constraints: constraints,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double maxSz = max.computeSize(
      parent: parent,
      child: child,
      constraints: constraints,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    return sz.clamp(minSz, maxSz);
  }
}

class FixedSize implements SizeUnit {
  final double value;
  const FixedSize(this.value);

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    return value;
  }

  @override
  bool get needsPostAdjustment => false;
}

// class RelativeSize implements SizeUnit {
//   final double factor;
//   const RelativeSize(this.factor);

//   @override
//   double computeSize({
//     required ParentLayout parent,
//     required ChildLayout child,
//     required BoxConstraints constraints,
//     required LayoutDirection axis,
//   }) {
//     return axis.getMaxConstraint(constraints) * factor;
//   }
// }

class SizeViewportSizeReference implements SizeUnit {
  const SizeViewportSizeReference();

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    return axis.getViewportSize(parent);
  }

  @override
  bool get needsPostAdjustment => true;
}

class SizeMaxViewportSizeReference implements SizeUnit {
  const SizeMaxViewportSizeReference();

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    return axis.getMaxConstraint(constraints);
  }

  @override
  bool get needsPostAdjustment => false;
}

class MinContent implements SizeUnit {
  const MinContent();
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    return axis.getMinIntrinsic(child, constraints);
  }

  @override
  bool get needsPostAdjustment => false;
}

class MaxContent implements SizeUnit {
  const MaxContent();

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    return axis.getMaxIntrinsic(child, constraints);
  }

  @override
  bool get needsPostAdjustment => false;
}

class FitContent implements SizeUnit {
  const FitContent();

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    Size? cachedSize = child.layoutCache.cachedFitContentSize;
    if (cachedSize == null) {
      cachedSize = child.dryLayout(constraints);
      child.layoutCache.cachedFitContentSize = cachedSize;
    }
    // return axis == LayoutDirection.horizontal ? cachedSize.width : cachedSize.height;
    return axis.getAxisSize(cachedSize);
  }

  @override
  bool get needsPostAdjustment => false;
}

class AutoSize implements SizeUnit {
  const AutoSize();
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required BoxConstraints constraints,
    required LayoutDirection axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    Size? cachedSize = child.layoutCache.cachedAutoSize;
    if (cachedSize == null) {
      cachedSize = child.dryLayout(constraints);
      child.layoutCache.cachedAutoSize = cachedSize;
    }
    return axis.getAxisSize(cachedSize);
  }

  @override
  bool get needsPostAdjustment => false;
}

abstract class SpacingUnit {
  static SpacingUnit lerp(SpacingUnit a, SpacingUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * FixedSpacing(1.0 - t) + b * FixedSpacing(t);
  }

  static const SpacingUnit zero = FixedSpacing(0);
  static const SpacingUnit viewportSize = SpacingViewportSizeReference();

  /// Uses distributed spacing given the available space and the number of affected items.
  static const SpacingUnit even = EvenSpacing();

  /// Uses all the available space.
  static const SpacingUnit fill = FillSpacing();

  /// Uses the maximum available space across all flex lines in a flex wrap layout.
  static const SpacingUnit maxFill = MaxFillSpacing();

  /// Uses the minimum available space across all flex lines in a flex wrap layout.
  static const SpacingUnit minFill = MinFillSpacing();
  const factory SpacingUnit.fixed(double value) = FixedSpacing;
  const factory SpacingUnit.constrained({
    required SpacingUnit spacing,
    SpacingUnit min,
    SpacingUnit max,
  }) = ConstrainedSpacing;
  const factory SpacingUnit.computed({
    required SpacingUnit first,
    required SpacingUnit second,
    required CalculationOperation operation,
  }) = CalculatedSpacing;
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  });
}

class FixedSpacing implements SpacingUnit {
  final double value;
  const FixedSpacing(this.value);

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    return value;
  }
}

class EvenSpacing implements SpacingUnit {
  const EvenSpacing();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    if (affectedCount <= 0) return 0;
    return availableSpace / affectedCount;
  }
}

class FillSpacing implements SpacingUnit {
  const FillSpacing();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    return availableSpace;
  }
}

class MaxFillSpacing implements SpacingUnit {
  const MaxFillSpacing();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    double? maxSpacing;
    final layout = parent.layoutHandle;
    assert(
      layout is FlexLayoutHandle,
      'MaxFillSpacing can only be used in FlexLayout',
    );
    final caches = (layout as FlexLayoutHandle).cache;

    for (final cache in caches.caches.values) {
      double usedSize = cache.mainContentSize;
      double freeSpace = (maxSpace - usedSize).clamp(0.0, double.infinity);
      maxSpacing = maxSpacing == null ? freeSpace : min(maxSpacing, freeSpace);
    }
    return maxSpacing ?? 0.0;
  }
}

class MinFillSpacing implements SpacingUnit {
  const MinFillSpacing();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    double? minSpacing;
    final layout = parent.layoutHandle;
    assert(
      layout is FlexLayoutHandle,
      'MinFillSpacing can only be used in FlexLayout',
    );
    final caches = (layout as FlexLayoutHandle).cache;

    for (final cache in caches.caches.values) {
      double usedSize = cache.mainContentSize;
      double freeSpace = (maxSpace - usedSize).clamp(0.0, double.infinity);
      minSpacing = minSpacing == null ? freeSpace : max(minSpacing, freeSpace);
    }
    return minSpacing ?? 0.0;
  }
}

class SpacingViewportSizeReference implements SpacingUnit {
  const SpacingViewportSizeReference();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    return axis.getViewportSize(parent);
  }
}

class CalculatedSpacing implements SpacingUnit {
  final SpacingUnit first;
  final SpacingUnit second;
  final CalculationOperation operation;
  const CalculatedSpacing({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    double first = this.first.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    double second = this.second.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    return operation(first, second);
  }
}

class ConstrainedSpacing implements SpacingUnit {
  final SpacingUnit spacing;
  final SpacingUnit min;
  final SpacingUnit max;

  const ConstrainedSpacing({
    required this.spacing,
    this.min = const FixedSpacing(0),
    this.max = const FixedSpacing(double.infinity),
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutDirection axis,
    required double maxSpace,
    required double availableSpace,
    required double affectedCount,
  }) {
    double sz = spacing.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    double minSz = min.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    double maxSz = max.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    return sz.clamp(minSz, maxSz);
  }
}

extension PositionUnitExtension on PositionUnit {
  CalculatedPosition operator +(PositionUnit other) {
    return CalculatedPosition(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  CalculatedPosition operator -(PositionUnit other) {
    return CalculatedPosition(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  CalculatedPosition operator *(PositionUnit other) {
    return CalculatedPosition(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  CalculatedPosition operator /(PositionUnit other) {
    return CalculatedPosition(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  CalculatedPosition operator -() {
    return CalculatedPosition(
      first: const FixedPosition(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  ConstrainedPosition clamp({
    PositionUnit min = const FixedPosition(double.negativeInfinity),
    PositionUnit max = const FixedPosition(double.infinity),
  }) {
    return ConstrainedPosition(
      position: this,
      min: min,
      max: max,
    );
  }
}

extension SizeUnitExtension on SizeUnit {
  CalculatedSize operator +(SizeUnit other) {
    return CalculatedSize(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  CalculatedSize operator -(SizeUnit other) {
    return CalculatedSize(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  CalculatedSize operator *(SizeUnit other) {
    return CalculatedSize(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  CalculatedSize operator /(SizeUnit other) {
    return CalculatedSize(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  CalculatedSize operator -() {
    return CalculatedSize(
      first: const FixedSize(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  ConstrainedSize clamp({
    SizeUnit min = const FixedSize(0),
    SizeUnit max = const FixedSize(double.infinity),
  }) {
    return ConstrainedSize(
      size: this,
      min: min,
      max: max,
    );
  }
}

extension InsetsUnitExtension on InsetUnit {
  ComputedInsets operator +(InsetUnit other) {
    return ComputedInsets(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  ComputedInsets operator -(InsetUnit other) {
    return ComputedInsets(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  ComputedInsets operator *(InsetUnit other) {
    return ComputedInsets(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  ComputedInsets operator /(InsetUnit other) {
    return ComputedInsets(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  ComputedInsets operator -() {
    return ComputedInsets(
      first: const FixedInset(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  ConstrainedInsets clamp({
    InsetUnit min = const FixedInset(0),
    InsetUnit max = const FixedInset(double.infinity),
  }) {
    return ConstrainedInsets(
      insets: this,
      min: min,
      max: max,
    );
  }
}

extension SpacingUnitExtension on SpacingUnit {
  CalculatedSpacing operator +(SpacingUnit other) {
    return CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  CalculatedSpacing operator -(SpacingUnit other) {
    return CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  CalculatedSpacing operator *(SpacingUnit other) {
    return CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  CalculatedSpacing operator /(SpacingUnit other) {
    return CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  CalculatedSpacing operator -() {
    return CalculatedSpacing(
      first: const FixedSpacing(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  ConstrainedSpacing clamp({
    SpacingUnit min = const FixedSpacing(0),
    SpacingUnit max = const FixedSpacing(double.infinity),
  }) {
    return ConstrainedSpacing(
      spacing: this,
      min: min,
      max: max,
    );
  }
}
