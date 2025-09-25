import 'dart:math';

import 'package:flexiblebox/src/layout.dart';

enum FlexDirection {
  row(LayoutAxis.horizontal, false),
  rowReverse(LayoutAxis.horizontal, true),
  column(LayoutAxis.vertical, false),
  columnReverse(LayoutAxis.vertical, true);

  final LayoutAxis axis;
  final bool reverse;

  const FlexDirection(this.axis, this.reverse);
}

// supports baseline alignment and stretch alignment
// and fixed alignment (start center end)
abstract class BoxAlignmentGeometry {
  const BoxAlignmentGeometry();
  static const BoxAlignmentGeometry stretch = _StretchBoxAlignment();
  static const BoxAlignmentGeometry start = DirectionalBoxAlignment.start;
  static const BoxAlignmentGeometry center = DirectionalBoxAlignment.center;
  static const BoxAlignmentGeometry end = DirectionalBoxAlignment.end;
  static const BoxAlignmentGeometry baseline = _BaselineBoxAlignment();
  const factory BoxAlignmentGeometry.directional(double value) =
      DirectionalBoxAlignment;
  const factory BoxAlignmentGeometry.absolute(double value) = BoxAlignment;

  /// Determines the top/left position
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  });

  double? adjustSize({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
  }) => null;

  bool needsBaseline({
    required ParentLayout parent,
    required LayoutAxis axis,
  });
}

// does not support baseline or stretch,
// usually used for main-axis alignment
abstract class BoxAlignmentBase extends BoxAlignmentContent {
  static const BoxAlignmentBase start = DirectionalBoxAlignment.start;
  static const BoxAlignmentBase center = DirectionalBoxAlignment.center;
  static const BoxAlignmentBase end = DirectionalBoxAlignment.end;
  static const BoxAlignmentBase spaceBetween = _EvenSpacingAlignment.between();
  static const BoxAlignmentBase spaceEvenly = _EvenSpacingAlignment.even();
  static const BoxAlignmentBase spaceAround = _EvenSpacingAlignment.around();
  const factory BoxAlignmentBase.spaceAroundSymmetric(double ratio) =
      _EvenSpacingAlignment.aroundSymmetric;
  const factory BoxAlignmentBase.spaceAroundRatio(
    double startRatio,
    double endRatio,
  ) = _EvenSpacingAlignment;
  const BoxAlignmentBase();
  const factory BoxAlignmentBase.directional(double value) =
      DirectionalBoxAlignment;
  const factory BoxAlignmentBase.absolute(double value) = BoxAlignment;

  @override
  bool needsBaseline({required ParentLayout parent, required LayoutAxis axis}) {
    return false;
  }
}

// does not support baseline, but supports stretch and also fixed alignment
// usually used for cross-axis alignment (specifically in align-content)
abstract class BoxAlignmentContent extends BoxAlignmentGeometry {
  static const BoxAlignmentContent stretch = _StretchBoxAlignment();
  static const BoxAlignmentContent start = DirectionalBoxAlignment.start;
  static const BoxAlignmentContent center = DirectionalBoxAlignment.center;
  static const BoxAlignmentContent end = DirectionalBoxAlignment.end;
  static const BoxAlignmentContent spaceBetween =
      _EvenSpacingAlignment.between();
  static const BoxAlignmentContent spaceEvenly = _EvenSpacingAlignment.even();
  static const BoxAlignmentContent spaceAround = _EvenSpacingAlignment.around();
  const factory BoxAlignmentContent.spaceAroundSymmetric(double ratio) =
      _EvenSpacingAlignment.aroundSymmetric;
  const factory BoxAlignmentContent.spaceAroundRatio(
    double startRatio,
    double endRatio,
  ) = _EvenSpacingAlignment;
  const factory BoxAlignmentContent.directional(double value) =
      DirectionalBoxAlignment;
  const factory BoxAlignmentContent.absolute(double value) = BoxAlignment;

  const BoxAlignmentContent();

  ({
    double additionalStartSpacing,
    double additionalSpacing,
    double additionalEndSpacing,
  })?
  adjustSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double startSpacing,
    required double spacing,
    required double endSpacing,
    required int affectedCount,
  }) => null;
}

class _StretchBoxAlignment extends BoxAlignmentContent {
  const _StretchBoxAlignment();
  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return 0.0;
  }

  @override
  bool needsBaseline({required ParentLayout parent, required LayoutAxis axis}) {
    return false;
  }

  @override
  double? adjustSize({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
  }) {
    return contentSize;
  }
}

class BoxAlignment extends BoxAlignmentBase {
  static const BoxAlignmentBase start = BoxAlignment(-1.0);
  static const BoxAlignmentBase center = BoxAlignment(0.0);
  static const BoxAlignmentBase end = BoxAlignment(1.0);
  static const BoxAlignmentGeometry baseline = _BaselineBoxAlignment();
  final double value;

  const BoxAlignment(this.value);

  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    double center = (viewportSize - contentSize) / 2.0;
    return center + center * value;
  }
}

class _BaselineBoxAlignment extends BoxAlignmentGeometry {
  const _BaselineBoxAlignment();

  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return maxBaseline - childBaseline;
  }

  @override
  bool needsBaseline({required ParentLayout parent, required LayoutAxis axis}) {
    return true;
  }
}

class DirectionalBoxAlignment extends BoxAlignmentBase {
  static const BoxAlignmentBase start = DirectionalBoxAlignment(-1.0);
  static const BoxAlignmentBase center = DirectionalBoxAlignment(0.0);
  static const BoxAlignmentBase end = DirectionalBoxAlignment(1.0);
  static const BoxAlignmentGeometry baseline = _BaselineBoxAlignment();
  final double value;

  const DirectionalBoxAlignment(this.value);

  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    double center = (viewportSize - contentSize) / 2.0;
    return switch (parent.textDirection) {
      LayoutTextDirection.ltr => center + center * value,
      LayoutTextDirection.rtl => center - center * value,
    };
  }
}

class _EvenSpacingAlignment extends BoxAlignmentBase {
  final double aroundStart;
  final double aroundEnd;

  const _EvenSpacingAlignment(this.aroundStart, this.aroundEnd);
  const _EvenSpacingAlignment.between() : aroundStart = 0.0, aroundEnd = 0.0;
  const _EvenSpacingAlignment.even() : aroundStart = 1.0, aroundEnd = 1.0;
  const _EvenSpacingAlignment.around() : aroundStart = 0.5, aroundEnd = 0.5;
  const _EvenSpacingAlignment.aroundSymmetric(double ratio)
    : aroundStart = ratio,
      aroundEnd = ratio;

  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return 0.0;
  }

  @override
  ({
    double additionalStartSpacing,
    double additionalSpacing,
    double additionalEndSpacing,
  })?
  adjustSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double startSpacing,
    required double spacing,
    required double endSpacing,
    required int affectedCount,
  }) {
    if (affectedCount <= 1) {
      return null;
    }
    // initial startSpacing, spacing, and endSpacing acts as minimum values
    // startSpacing and endSpacing are obtained from padding
    // spacing is obtained from the horizontalSpacing/verticalSpacing
    // note that viewportSize is already reduced by padding
    // and contentSize already contains the spacing between items
    double remainingSpace = max(0.0, viewportSize - contentSize);
    double totalFlex = (affectedCount - 1).toDouble() + aroundStart + aroundEnd;
    if (totalFlex <= 0.0) {
      return null;
    }
    double flexUnit = remainingSpace / totalFlex;
    return (
      additionalStartSpacing: flexUnit * aroundStart,
      additionalSpacing: flexUnit,
      additionalEndSpacing: flexUnit * aroundEnd,
    );
  }
}

final class LayoutOverflow {
  /// Content does not scroll and is not clipped.
  static const LayoutOverflow visible = LayoutOverflow(false, false);

  /// Content scrolls and is clipped.
  static const LayoutOverflow hidden = LayoutOverflow(true, true);

  /// Content scrolls but is not clipped.
  static const LayoutOverflow scroll = LayoutOverflow(true, false);

  /// Content does not scroll but is clipped.
  static const LayoutOverflow clip = LayoutOverflow(false, true);
  final bool scrollable;
  final bool clipContent;

  const LayoutOverflow(this.scrollable, this.clipContent);

  @override
  String toString() {
    return 'LayoutOverflow(scrollable: $scrollable, clip: $clipContent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LayoutOverflow) return false;
    return scrollable == other.scrollable && clipContent == other.clipContent;
  }

  @override
  int get hashCode => Object.hash(scrollable, clipContent);
}

// Units:
// Size Unit: computed after the viewport size has been reduced by the padding
// Spacing Unit: computed before the size unit to add additional flex-basis and after the size unit
// Position Unit: computed after inset, size, and spacing has been resolved

abstract class SizeUnit {
  static SizeUnit lerp(SizeUnit a, SizeUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * _FixedSize(1.0 - t) + b * _FixedSize(t);
  }

  static const SizeUnit zero = _FixedSize(0);
  const factory SizeUnit.fixed(double value) = _FixedSize;
  static const SizeUnit minContent = _MinContent();
  static const SizeUnit maxContent = _MaxContent();
  static const SizeUnit fitContent = _FitContent();
  static const SizeUnit viewportSize = _SizeViewportSizeReference();

  const SizeUnit();

  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  });
}

abstract class PositionUnit {
  static PositionUnit lerp(PositionUnit a, PositionUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * _FixedPosition(1.0 - t) + b * _FixedPosition(t);
  }

  static const PositionUnit zero = _FixedPosition(0);
  static const PositionUnit viewportSize = _ViewportSizeReference();
  static const PositionUnit contentSize = _ContentSizeReference();
  static const PositionUnit childSize = _ChildSizeReference();
  static const PositionUnit boxOffset = _BoxOffset();
  static const PositionUnit scrollOffset = _ScrollOffset();
  static const PositionUnit contentOverflow = _ContentOverflow();
  static const PositionUnit contentUnderflow = _ContentUnderflow();
  static const PositionUnit viewportStartBound = _ScrollOffset();
  static const PositionUnit viewportEndBound = _ViewportEndBound();
  const factory PositionUnit.fixed(double value) = _FixedPosition;
  const factory PositionUnit.cross(PositionUnit position) = _CrossPosition;
  const factory PositionUnit.constrained({
    required PositionUnit position,
    PositionUnit min,
    PositionUnit max,
  }) = _ConstrainedPosition;

  const PositionUnit();
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  });
}

typedef CalculationOperation = double Function(double a, double b);

double calculationAdd(double a, double b) => a + b;
double calculationSubtract(double a, double b) => a - b;
double calculationMultiply(double a, double b) => a * b;
double calculationDivide(double a, double b) => a / b;

class _CalculatedSize extends SizeUnit {
  final SizeUnit first;
  final SizeUnit second;
  final CalculationOperation operation;
  const _CalculatedSize({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    double first = this.first.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double second = this.second.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    return operation(first, second);
  }
}

class _CalculatedPosition implements PositionUnit {
  final PositionUnit first;
  final PositionUnit second;
  final CalculationOperation operation;
  const _CalculatedPosition({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
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

class _FixedPosition implements PositionUnit {
  final double value;
  const _FixedPosition(this.value);

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return value;
  }
}

class _ViewportSizeReference implements PositionUnit {
  const _ViewportSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.viewportSize.width,
      LayoutAxis.vertical => parent.viewportSize.height,
    };
  }
}

class _ContentSizeReference implements PositionUnit {
  const _ContentSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.contentSize.width,
      LayoutAxis.vertical => parent.contentSize.height,
    };
  }
}

class _ChildSizeReference implements PositionUnit {
  const _ChildSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => child.size.width,
      LayoutAxis.vertical => child.size.height,
    };
  }
}

class _BoxOffset implements PositionUnit {
  const _BoxOffset();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.scrollOffsetX,
      LayoutAxis.vertical => parent.scrollOffsetY,
    };
  }
}

class _ScrollOffset implements PositionUnit {
  const _ScrollOffset();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.scrollOffsetX,
      LayoutAxis.vertical => parent.scrollOffsetY,
    };
  }
}

class _ContentOverflow implements PositionUnit {
  const _ContentOverflow();
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return max(
      0.0,
      switch (direction) {
        LayoutAxis.horizontal =>
          parent.contentSize.width - parent.viewportSize.width,
        LayoutAxis.vertical =>
          parent.contentSize.height - parent.viewportSize.height,
      },
    );
  }
}

class _ContentUnderflow implements PositionUnit {
  const _ContentUnderflow();
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return max(
      0.0,
      switch (direction) {
        LayoutAxis.horizontal =>
          parent.viewportSize.width - parent.contentSize.width,
        LayoutAxis.vertical =>
          parent.viewportSize.height - parent.contentSize.height,
      },
    );
  }
}

class _ViewportEndBound implements PositionUnit {
  const _ViewportEndBound();
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.contentSize.width + parent.scrollOffsetX,
      LayoutAxis.vertical => parent.contentSize.height + parent.scrollOffsetY,
    };
  }
}

class _CrossPosition implements PositionUnit {
  final PositionUnit position;

  const _CrossPosition(this.position);

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return position.computePosition(
      parent: parent,
      child: child,
      direction: switch (direction) {
        LayoutAxis.horizontal => LayoutAxis.vertical,
        LayoutAxis.vertical => LayoutAxis.horizontal,
      },
    );
  }
}

class _ConstrainedPosition implements PositionUnit {
  final PositionUnit position;
  final PositionUnit min;
  final PositionUnit max;

  const _ConstrainedPosition({
    required this.position,
    this.min = const _FixedPosition(double.negativeInfinity),
    this.max = const _FixedPosition(double.infinity),
  });

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
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

abstract class EdgePositionGeometry {
  final PositionUnit top;
  final PositionUnit bottom;

  const EdgePositionGeometry({
    this.top = PositionUnit.zero,
    this.bottom = PositionUnit.zero,
  });

  EdgePosition resolve(LayoutTextDirection direction);
}

class EdgePosition extends EdgePositionGeometry {
  final PositionUnit left;
  final PositionUnit right;

  const EdgePosition.only({
    this.left = PositionUnit.zero,
    this.right = PositionUnit.zero,
    super.top,
    super.bottom,
  }) : super();

  const EdgePosition.all(PositionUnit value)
    : left = value,
      right = value,
      super(
        top: value,
        bottom: value,
      );

  const EdgePosition.symmetric({
    PositionUnit horizontal = PositionUnit.zero,
    PositionUnit vertical = PositionUnit.zero,
  }) : left = horizontal,
       right = horizontal,
       super(
         top: vertical,
         bottom: vertical,
       );

  static EdgePosition lerp(EdgePosition a, EdgePosition b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return EdgePosition.only(
      left: PositionUnit.lerp(a.left, b.left, t),
      top: PositionUnit.lerp(a.top, b.top, t),
      right: PositionUnit.lerp(a.right, b.right, t),
      bottom: PositionUnit.lerp(a.bottom, b.bottom, t),
    );
  }

  @override
  EdgePosition resolve(LayoutTextDirection direction) {
    return this;
  }
}

class DirectionalEdgePosition extends EdgePositionGeometry {
  final PositionUnit start;
  final PositionUnit end;

  const DirectionalEdgePosition.only({
    this.start = PositionUnit.zero,
    super.top,
    this.end = PositionUnit.zero,
    super.bottom,
  }) : super();

  const DirectionalEdgePosition.all(PositionUnit value)
    : this.only(
        start: value,
        end: value,
        top: value,
        bottom: value,
      );

  const DirectionalEdgePosition.symmetric({
    PositionUnit horizontal = PositionUnit.zero,
    PositionUnit vertical = PositionUnit.zero,
  }) : this.only(
         start: horizontal,
         end: horizontal,
         top: vertical,
         bottom: vertical,
       );

  @override
  EdgePosition resolve(LayoutTextDirection direction) {
    if (direction == LayoutTextDirection.ltr) {
      return EdgePosition.only(
        left: start,
        top: top,
        right: end,
        bottom: bottom,
      );
    } else {
      return EdgePosition.only(
        left: end,
        top: top,
        right: start,
        bottom: bottom,
      );
    }
  }
}

class _ConstrainedSize extends SizeUnit {
  final SizeUnit size;
  final SizeUnit min;
  final SizeUnit max;

  const _ConstrainedSize({
    required this.size,
    this.min = const _FixedSize(0),
    this.max = const _FixedSize(double.infinity),
  });

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    double sz = size.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double minSz = min.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double maxSz = max.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    return sz.clamp(minSz, maxSz);
  }
}

class _FixedSize extends SizeUnit {
  final double value;
  const _FixedSize(this.value);

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    return value;
  }
}

class _SizeViewportSizeReference extends SizeUnit {
  const _SizeViewportSizeReference();

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    double result = switch (axis) {
      LayoutAxis.horizontal => viewportSize.width,
      LayoutAxis.vertical => viewportSize.height,
    };
    // if result is infinite, it might be coming from intrinsic sizing
    return result.isFinite ? result : 0.0;
  }
}

class _MinContent extends SizeUnit {
  const _MinContent();
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    return switch (axis) {
      LayoutAxis.horizontal => child.getMinIntrinsicWidth(viewportSize.height),
      LayoutAxis.vertical => child.getMinIntrinsicHeight(viewportSize.width),
    };
  }
}

class _MaxContent extends SizeUnit {
  const _MaxContent();

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    return switch (axis) {
      LayoutAxis.horizontal => child.getMaxIntrinsicWidth(viewportSize.height),
      LayoutAxis.vertical => child.getMaxIntrinsicHeight(viewportSize.width),
    };
  }
}

class _FitContent extends SizeUnit {
  const _FitContent();

  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    LayoutSize? cachedSize = child.layoutCache.cachedFitContentSize;
    if (cachedSize == null) {
      cachedSize = child.dryLayout(LayoutConstraints());
      child.layoutCache.cachedFitContentSize = cachedSize;
    }
    return switch (axis) {
      LayoutAxis.horizontal => cachedSize.width,
      LayoutAxis.vertical => cachedSize.height,
    };
  }
}

abstract class EdgeSpacingGeometry {
  final SpacingUnit top;
  final SpacingUnit bottom;

  const EdgeSpacingGeometry({
    this.top = SpacingUnit.zero,
    this.bottom = SpacingUnit.zero,
  });

  EdgeSpacing resolve(LayoutTextDirection direction);
}

class EdgeSpacing extends EdgeSpacingGeometry {
  static const EdgeSpacing zero = EdgeSpacing.all(SpacingUnit.zero);
  final SpacingUnit left;
  final SpacingUnit right;

  const EdgeSpacing.only({
    this.left = SpacingUnit.zero,
    this.right = SpacingUnit.zero,
    super.top,
    super.bottom,
  }) : super();

  const EdgeSpacing.all(SpacingUnit value)
    : left = value,
      right = value,
      super(
        top: value,
        bottom: value,
      );

  const EdgeSpacing.symmetric({
    SpacingUnit horizontal = SpacingUnit.zero,
    SpacingUnit vertical = SpacingUnit.zero,
  }) : left = horizontal,
       right = horizontal,
       super(
         top: vertical,
         bottom: vertical,
       );

  static EdgeSpacing lerp(EdgeSpacing a, EdgeSpacing b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return EdgeSpacing.only(
      left: SpacingUnit.lerp(a.left, b.left, t),
      top: SpacingUnit.lerp(a.top, b.top, t),
      right: SpacingUnit.lerp(a.right, b.right, t),
      bottom: SpacingUnit.lerp(a.bottom, b.bottom, t),
    );
  }

  @override
  EdgeSpacing resolve(LayoutTextDirection direction) {
    return this;
  }
}

class DirectionalEdgeSpacing extends EdgeSpacingGeometry {
  final SpacingUnit start;
  final SpacingUnit end;

  const DirectionalEdgeSpacing.only({
    this.start = SpacingUnit.zero,
    super.top,
    this.end = SpacingUnit.zero,
    super.bottom,
  }) : super();

  const DirectionalEdgeSpacing.all(SpacingUnit value)
    : this.only(
        start: value,
        end: value,
        top: value,
        bottom: value,
      );

  const DirectionalEdgeSpacing.symmetric({
    SpacingUnit horizontal = SpacingUnit.zero,
    SpacingUnit vertical = SpacingUnit.zero,
  }) : this.only(
         start: horizontal,
         end: horizontal,
         top: vertical,
         bottom: vertical,
       );

  @override
  EdgeSpacing resolve(LayoutTextDirection direction) {
    if (direction == LayoutTextDirection.ltr) {
      return EdgeSpacing.only(
        left: start,
        top: top,
        right: end,
        bottom: bottom,
      );
    } else {
      return EdgeSpacing.only(
        left: end,
        top: top,
        right: start,
        bottom: bottom,
      );
    }
  }
}

abstract class SpacingUnit {
  static SpacingUnit lerp(SpacingUnit a, SpacingUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * _FixedSpacing(1.0 - t) + b * _FixedSpacing(t);
  }

  static const SpacingUnit zero = _FixedSpacing(0);
  static const SpacingUnit viewportSize = _SpacingViewportSizeReference();
  const factory SpacingUnit.fixed(double value) = _FixedSpacing;
  const factory SpacingUnit.constrained({
    required SpacingUnit spacing,
    SpacingUnit min,
    SpacingUnit max,
  }) = _ConstrainedSpacing;
  const factory SpacingUnit.computed({
    required SpacingUnit first,
    required SpacingUnit second,
    required CalculationOperation operation,
  }) = _CalculatedSpacing;
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  });
}

class _FixedSpacing implements SpacingUnit {
  final double value;
  const _FixedSpacing(this.value);

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    return value;
  }
}

class _SpacingViewportSizeReference implements SpacingUnit {
  const _SpacingViewportSizeReference();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    return switch (axis) {
      LayoutAxis.horizontal => parent.viewportSize.width,
      LayoutAxis.vertical => parent.viewportSize.height,
    };
  }
}

class _CalculatedSpacing implements SpacingUnit {
  final SpacingUnit first;
  final SpacingUnit second;
  final CalculationOperation operation;
  const _CalculatedSpacing({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
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

class _ConstrainedSpacing implements SpacingUnit {
  final SpacingUnit spacing;
  final SpacingUnit min;
  final SpacingUnit max;

  const _ConstrainedSpacing({
    required this.spacing,
    this.min = const _FixedSpacing(0),
    this.max = const _FixedSpacing(double.infinity),
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
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
  PositionUnit operator +(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  PositionUnit operator -(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  PositionUnit operator *(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  PositionUnit operator /(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  PositionUnit operator -() {
    return _CalculatedPosition(
      first: const _FixedPosition(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  PositionUnit clamp({
    PositionUnit min = const _FixedPosition(double.negativeInfinity),
    PositionUnit max = const _FixedPosition(double.infinity),
  }) {
    return _ConstrainedPosition(
      position: this,
      min: min,
      max: max,
    );
  }
}

extension SizeUnitExtension on SizeUnit {
  SizeUnit operator +(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  SizeUnit operator -(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  SizeUnit operator *(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  SizeUnit operator /(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  SizeUnit operator -() {
    return _CalculatedSize(
      first: const _FixedSize(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  SizeUnit clamp({
    SizeUnit min = const _FixedSize(0),
    SizeUnit max = const _FixedSize(double.infinity),
  }) {
    return _ConstrainedSize(
      size: this,
      min: min,
      max: max,
    );
  }
}

extension SpacingUnitExtension on SpacingUnit {
  SpacingUnit operator +(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  SpacingUnit operator -(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  SpacingUnit operator *(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  SpacingUnit operator /(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  SpacingUnit operator -() {
    return _CalculatedSpacing(
      first: const _FixedSpacing(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  SpacingUnit clamp({
    SpacingUnit min = const _FixedSpacing(0),
    SpacingUnit max = const _FixedSpacing(double.infinity),
  }) {
    return _ConstrainedSpacing(
      spacing: this,
      min: min,
      max: max,
    );
  }
}
