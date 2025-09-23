import 'dart:math';
import 'dart:ui';

import 'package:flexiblebox/src/layout.dart';
import 'package:flexiblebox/src/layout/flex.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
    required Axis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  });

  double? adjustSize({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
    required double viewportSize,
    required double contentSize,
  }) => null;

  bool needsBaseline({
    required ParentLayout parent,
    required Axis axis,
  });
}

// does not support baseline or stretch,
// usually used for main-axis alignment
abstract class BoxAlignmentBase extends BoxAlignmentContent {
  static const BoxAlignmentBase start = DirectionalBoxAlignment.start;
  static const BoxAlignmentBase center = DirectionalBoxAlignment.center;
  static const BoxAlignmentBase end = DirectionalBoxAlignment.end;
  const BoxAlignmentBase();
  const factory BoxAlignmentBase.directional(double value) =
      DirectionalBoxAlignment;
  const factory BoxAlignmentBase.absolute(double value) = BoxAlignment;

  @override
  bool needsBaseline({required ParentLayout parent, required Axis axis}) {
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
  const factory BoxAlignmentContent.directional(double value) =
      DirectionalBoxAlignment;
  const factory BoxAlignmentContent.absolute(double value) = BoxAlignment;

  const BoxAlignmentContent();
}

class _StretchBoxAlignment extends BoxAlignmentContent {
  const _StretchBoxAlignment();
  @override
  double align({
    required ParentLayout parent,
    required Axis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return 0.0;
  }

  @override
  bool needsBaseline({required ParentLayout parent, required Axis axis}) {
    return false;
  }

  @override
  double? adjustSize({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
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
    required Axis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    double center = (viewportSize - contentSize) / 2.0;
    return center * value;
  }
}

class _BaselineBoxAlignment extends BoxAlignmentGeometry {
  const _BaselineBoxAlignment();

  @override
  double align({
    required ParentLayout parent,
    required Axis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return maxBaseline - childBaseline;
  }

  @override
  bool needsBaseline({required ParentLayout parent, required Axis axis}) {
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
    required Axis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    double center = (viewportSize - contentSize) / 2.0;
    return switch (parent.textDirection) {
      TextDirection.ltr => center * value,
      TextDirection.rtl => center * -value,
    };
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
// Inset Unit: computed initially to reduce the viewport size
// Size Unit: computed after the viewport size has been reduced by the padding
// Spacing Unit: computed before the size unit to add additional flex-basis and after the size unit
// Position Unit: computed after inset, size, and spacing has been resolved

abstract class BoxInsetsGeometry {
  final InsetUnit top;
  final InsetUnit bottom;

  const BoxInsetsGeometry({
    this.top = InsetUnit.zero,
    this.bottom = InsetUnit.zero,
  });

  BoxInsets resolve(TextDirection direction);
}

class BoxInsets extends BoxInsetsGeometry {
  final InsetUnit left;
  final InsetUnit right;

  const BoxInsets.only({
    this.left = InsetUnit.zero,
    this.right = InsetUnit.zero,
    super.top,
    super.bottom,
  }) : super();

  const BoxInsets.all(InsetUnit value)
    : left = value,
      right = value,
      super(
        top: value,
        bottom: value,
      );

  const BoxInsets.symmetric({
    InsetUnit horizontal = InsetUnit.zero,
    InsetUnit vertical = InsetUnit.zero,
  }) : left = horizontal,
       right = horizontal,
       super(
         top: vertical,
         bottom: vertical,
       );

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

  @override
  BoxInsets resolve(TextDirection direction) {
    return this;
  }
}

class DirectionalBoxInsets extends BoxInsetsGeometry {
  final InsetUnit start;
  final InsetUnit end;

  const DirectionalBoxInsets.only({
    this.start = InsetUnit.zero,
    super.top,
    this.end = InsetUnit.zero,
    super.bottom,
  }) : super();

  const DirectionalBoxInsets.all(InsetUnit value)
    : this.only(
        start: value,
        end: value,
        top: value,
        bottom: value,
      );

  const DirectionalBoxInsets.symmetric({
    InsetUnit horizontal = InsetUnit.zero,
    InsetUnit vertical = InsetUnit.zero,
  }) : this.only(
         start: horizontal,
         end: horizontal,
         top: vertical,
         bottom: vertical,
       );

  @override
  BoxInsets resolve(TextDirection direction) {
    if (direction == TextDirection.ltr) {
      return BoxInsets.only(
        left: start,
        top: top,
        right: end,
        bottom: bottom,
      );
    } else {
      return BoxInsets.only(
        left: end,
        top: top,
        right: start,
        bottom: bottom,
      );
    }
  }
}

abstract class InsetUnit {
  static const InsetUnit viewportSize = _InsetViewportSizeReference();
  static const InsetUnit zero = _FixedInset(0);
  const factory InsetUnit.fixed(double value) = _FixedInset;
  const factory InsetUnit.cross(InsetUnit insets) = _CrossInsets;
  const factory InsetUnit.computed({
    required InsetUnit first,
    required InsetUnit second,
    required CalculationOperation operation,
  }) = _ComputedInsets;
  const factory InsetUnit.constrained({
    required InsetUnit insets,
    InsetUnit min,
    InsetUnit max,
  }) = _ConstrainedInsets;
  static InsetUnit lerp(InsetUnit a, InsetUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * _FixedInset(1.0 - t) + b * _FixedInset(t);
  }

  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
  });
}

class _FixedInset implements InsetUnit {
  final double value;
  const _FixedInset(this.value);

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
  }) {
    return value;
  }
}

class _InsetViewportSizeReference implements InsetUnit {
  const _InsetViewportSizeReference();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
  }) {
    return switch (axis) {
      Axis.horizontal => parent.viewportSize.width,
      Axis.vertical => parent.viewportSize.height,
    };
  }
}

class _ComputedInsets implements InsetUnit {
  final InsetUnit first;
  final InsetUnit second;
  final CalculationOperation operation;
  const _ComputedInsets({
    required this.first,
    required this.second,
    required this.operation,
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
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

class _ConstrainedInsets implements InsetUnit {
  final InsetUnit insets;
  final InsetUnit min;
  final InsetUnit max;

  const _ConstrainedInsets({
    required this.insets,
    this.min = const _FixedInset(0),
    this.max = const _FixedInset(double.infinity),
  });

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
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

class _CrossInsets implements InsetUnit {
  final InsetUnit insets;

  const _CrossInsets(this.insets);

  @override
  double computeSpacing({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis axis,
  }) {
    return insets.computeSpacing(
      parent: parent,
      child: child,
      axis: switch (axis) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
      },
    );
  }
}

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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
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
    required Axis direction,
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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
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
    required Axis direction,
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
    required Axis direction,
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
    required Axis direction,
  }) {
    return switch (direction) {
      Axis.horizontal => parent.viewportSize.width,
      Axis.vertical => parent.viewportSize.height,
    };
  }
}

class _ContentSizeReference implements PositionUnit {
  const _ContentSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis direction,
  }) {
    return switch (direction) {
      Axis.horizontal => parent.contentSize.width,
      Axis.vertical => parent.contentSize.height,
    };
  }
}

class _ChildSizeReference implements PositionUnit {
  const _ChildSizeReference();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis direction,
  }) {
    return switch (direction) {
      Axis.horizontal => child.size.width,
      Axis.vertical => child.size.height,
    };
  }
}

class _BoxOffset implements PositionUnit {
  const _BoxOffset();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis direction,
  }) {
    return switch (direction) {
      Axis.horizontal => parent.scrollOffsetX,
      Axis.vertical => parent.scrollOffsetY,
    };
  }
}

class _ScrollOffset implements PositionUnit {
  const _ScrollOffset();

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis direction,
  }) {
    return switch (direction) {
      Axis.horizontal => parent.scrollOffsetX,
      Axis.vertical => parent.scrollOffsetY,
    };
  }
}

class _ContentOverflow implements PositionUnit {
  const _ContentOverflow();
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required Axis direction,
  }) {
    return max(
      0.0,
      switch (direction) {
        Axis.horizontal => parent.contentSize.width - parent.viewportSize.width,
        Axis.vertical => parent.contentSize.height - parent.viewportSize.height,
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
    required Axis direction,
  }) {
    return max(
      0.0,
      switch (direction) {
        Axis.horizontal => parent.viewportSize.width - parent.contentSize.width,
        Axis.vertical => parent.viewportSize.height - parent.contentSize.height,
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
    required Axis direction,
  }) {
    return switch (direction) {
      Axis.horizontal => parent.contentSize.width + parent.scrollOffsetX,
      Axis.vertical => parent.contentSize.height + parent.scrollOffsetY,
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
    required Axis direction,
  }) {
    return position.computePosition(
      parent: parent,
      child: child,
      direction: switch (direction) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
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
    required Axis direction,
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

  EdgePosition resolve(TextDirection direction);
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
  EdgePosition resolve(TextDirection direction) {
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
  EdgePosition resolve(TextDirection direction) {
    if (direction == TextDirection.ltr) {
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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    double result = switch (axis) {
      Axis.horizontal => viewportSize.width,
      Axis.vertical => viewportSize.height,
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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    return switch (axis) {
      Axis.horizontal => child.getMinIntrinsicWidth(viewportSize.height),
      Axis.vertical => child.getMinIntrinsicHeight(viewportSize.width),
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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    return switch (axis) {
      Axis.horizontal => child.getMaxIntrinsicWidth(viewportSize.height),
      Axis.vertical => child.getMaxIntrinsicHeight(viewportSize.width),
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
    required Axis axis,
    required Size contentSize,
    required Size viewportSize,
  }) {
    Size? cachedSize = child.layoutCache.cachedFitContentSize;
    if (cachedSize == null) {
      cachedSize = child.dryLayout(BoxConstraints());
      child.layoutCache.cachedFitContentSize = cachedSize;
    }
    return switch (axis) {
      Axis.horizontal => cachedSize.width,
      Axis.vertical => cachedSize.height,
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

  EdgeSpacing resolve(TextDirection direction);
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
  EdgeSpacing resolve(TextDirection direction) {
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
  EdgeSpacing resolve(TextDirection direction) {
    if (direction == TextDirection.ltr) {
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
  static const SpacingUnit even = _EvenSpacing();
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
    required Axis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  });
  bool get needsPostAdjustment => false;
}

class _FixedSpacing implements SpacingUnit {
  final double value;
  const _FixedSpacing(this.value);

  @override
  double computeSpacing({
    required ParentLayout parent,
    required Axis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    return value;
  }

  @override
  bool get needsPostAdjustment => false;
}

class _EvenSpacing implements SpacingUnit {
  const _EvenSpacing();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required Axis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    if (affectedCount <= 0) return 0;
    int totalGap = affectedCount - 1;
    return availableSpace / totalGap;
  }

  @override
  bool get needsPostAdjustment => true;
}

class _SpacingViewportSizeReference implements SpacingUnit {
  const _SpacingViewportSizeReference();

  @override
  double computeSpacing({
    required ParentLayout parent,
    required Axis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    return switch (axis) {
      Axis.horizontal => parent.viewportSize.width,
      Axis.vertical => parent.viewportSize.height,
    };
  }

  @override
  bool get needsPostAdjustment => true;
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
    required Axis axis,
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

  @override
  bool get needsPostAdjustment =>
      first.needsPostAdjustment || second.needsPostAdjustment;
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
    required Axis axis,
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

  @override
  bool get needsPostAdjustment =>
      spacing.needsPostAdjustment ||
      min.needsPostAdjustment ||
      max.needsPostAdjustment;
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

extension InsetsUnitExtension on InsetUnit {
  InsetUnit operator +(InsetUnit other) {
    return _ComputedInsets(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  InsetUnit operator -(InsetUnit other) {
    return _ComputedInsets(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  InsetUnit operator *(InsetUnit other) {
    return _ComputedInsets(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  InsetUnit operator /(InsetUnit other) {
    return _ComputedInsets(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  InsetUnit operator -() {
    return _ComputedInsets(
      first: const _FixedInset(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  InsetUnit clamp({
    InsetUnit min = const _FixedInset(0),
    InsetUnit max = const _FixedInset(double.infinity),
  }) {
    return _ConstrainedInsets(
      insets: this,
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
