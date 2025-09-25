import 'dart:math';

import 'package:flexiblebox/src/basic.dart';

// note: these values must NOT be null in order to lerp
// see how we handle absolute children with non-null top, left, right, and bottom
final class LayoutData {
  final LayoutBehavior behavior;
  final double flexGrow;
  final double flexShrink;
  final int? paintOrder;
  final SizeUnit? width;
  final SizeUnit? height;
  final SizeUnit? minWidth;
  final SizeUnit? maxWidth;
  final SizeUnit? minHeight;
  final SizeUnit? maxHeight;
  final PositionUnit? top;
  final PositionUnit? left;
  final PositionUnit? right;
  final PositionUnit? bottom;
  final double? aspectRatio;
  final BoxAlignmentGeometry? alignSelf;

  LayoutData({
    required this.behavior,
    required this.flexGrow,
    required this.flexShrink,
    required this.paintOrder,
    required this.width,
    required this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    required this.top,
    required this.left,
    required this.right,
    required this.bottom,
    required this.aspectRatio,
    this.alignSelf,
  });

  @override
  int get hashCode => Object.hash(
    flexGrow,
    flexShrink,
    paintOrder,
    width,
    height,
    top,
    left,
    right,
    bottom,
    aspectRatio,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LayoutData &&
        other.flexGrow == flexGrow &&
        other.flexShrink == flexShrink &&
        other.paintOrder == paintOrder &&
        other.width == width &&
        other.height == height &&
        other.top == top &&
        other.left == left &&
        other.right == right &&
        other.bottom == bottom &&
        other.aspectRatio == aspectRatio;
  }
}

enum LayoutBehavior {
  none,
  absolute,
}

enum LayoutAxis {
  horizontal,
  vertical,
}

class LayoutSize {
  static const LayoutSize zero = LayoutSize(0.0, 0.0);
  final double width;
  final double height;

  const LayoutSize(this.width, this.height);
}

class LayoutOffset {
  static const LayoutOffset zero = LayoutOffset(0.0, 0.0);
  final double dx;
  final double dy;

  const LayoutOffset(this.dx, this.dy);

  LayoutRect operator &(LayoutSize size) {
    return LayoutRect.fromLTWH(dx, dy, size.width, size.height);
  }
}

class LayoutRect {
  static const LayoutRect zero = LayoutRect.fromLTWH(0.0, 0.0, 0.0, 0.0);
  const LayoutRect.fromLTWH(this.left, this.top, this.width, this.height);

  const LayoutRect.fromLTRB(this.left, this.top, double right, double bottom)
    : width = right - left,
      height = bottom - top;

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  LayoutRect expandToInclude(LayoutRect childBounds) {
    return LayoutRect.fromLTRB(
      min(left, childBounds.left),
      min(top, childBounds.top),
      max(right, childBounds.right),
      max(bottom, childBounds.bottom),
    );
  }

  @override
  String toString() {
    return 'LayoutRect($left, $top, $right, $bottom)';
  }
}

enum LayoutTextBaseline {
  alphabetic,
  ideographic,
}

enum LayoutTextDirection {
  ltr,
  rtl,
}

class LayoutConstraints {
  // double get maxWidth;
  // double get maxHeight;
  // double get minWidth;
  // double get minHeight;
  // LayoutSize get biggest;
  // LayoutSize get smallest;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;

  const LayoutConstraints({
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
  });
  const LayoutConstraints.tightFor({
    double? width,
    double? height,
  }) : minWidth = width ?? 0.0,
       maxWidth = width ?? double.infinity,
       minHeight = height ?? 0.0,
       maxHeight = height ?? double.infinity;
  LayoutConstraints.tight(LayoutSize size)
    : minWidth = size.width,
      maxWidth = size.width,
      minHeight = size.height,
      maxHeight = size.height;

  LayoutSize get biggest => LayoutSize(maxWidth, maxHeight);
  LayoutSize get smallest => LayoutSize(minWidth, minHeight);

  LayoutSize constrain(LayoutSize size) {
    final width = size.width.clamp(minWidth, maxWidth);
    final height = size.height.clamp(minHeight, maxHeight);
    return LayoutSize(width, height);
  }
}

abstract class ChildLayoutCache {
  LayoutSize? cachedFitContentSize;
  LayoutSize? cachedAutoSize;
}

mixin ChildLayout {
  Object? get debugKey => null;
  void layout(LayoutConstraints constraints);
  LayoutSize dryLayout(LayoutConstraints constraints);
  double getMaxIntrinsicWidth(double height);
  double getMaxIntrinsicHeight(double width);
  double getMinIntrinsicWidth(double height);
  double getMinIntrinsicHeight(double width);
  LayoutSize get size;
  LayoutOffset get offset;
  set offset(LayoutOffset value);
  ChildLayoutCache get layoutCache;
  LayoutData get layoutData;
  ChildLayout? get nextSibling;
  ChildLayout? get previousSibling;

  double getDistanceToBaseline(LayoutTextBaseline baseline);

  void clearCache();
}

class ChildLayoutDryDelegate with ChildLayout {
  static ChildLayoutDryDelegate? forwardCopy(
    ChildLayout? firstChild,
    LayoutHandle<Layout> layoutHandle,
  ) {
    ChildLayoutDryDelegate? first;
    ChildLayoutDryDelegate? last;
    ChildLayout? child = firstChild;
    while (child != null) {
      final delegate = ChildLayoutDryDelegate(child, layoutHandle.setupCache());
      if (first == null) {
        first = delegate;
        last = delegate;
      } else {
        last!.nextSibling = delegate;
        delegate.previousSibling = last;
        last = delegate;
      }
      child = child.nextSibling;
    }
    return first;
  }

  static ChildLayoutDryDelegate? backwardCopy(
    ChildLayout? lastChild,
    LayoutHandle<Layout> layoutHandle,
  ) {
    ChildLayoutDryDelegate? first;
    ChildLayoutDryDelegate? last;
    ChildLayout? child = lastChild;
    while (child != null) {
      final delegate = ChildLayoutDryDelegate(child, layoutHandle.setupCache());
      if (last == null) {
        last = delegate;
        first = delegate;
      } else {
        first!.previousSibling = delegate;
        delegate.nextSibling = first;
        first = delegate;
      }
      child = child.previousSibling;
    }
    return last;
  }

  final ChildLayout child;
  @override
  final ChildLayoutCache layoutCache;

  ChildLayoutDryDelegate(this.child, this.layoutCache);

  @override
  void clearCache() {
    // do nothing, the child cache is automatically cleared
    // when the dry layout is performed
  }

  @override
  LayoutOffset get offset {
    throw Exception('offset is not supported in dry delegate');
  }

  @override
  set offset(LayoutOffset value) {
    throw Exception('offset is not supported in dry delegate');
  }

  @override
  LayoutSize dryLayout(LayoutConstraints constraints) {
    return child.dryLayout(constraints);
  }

  @override
  double getDistanceToBaseline(LayoutTextBaseline baseline) {
    return child.getDistanceToBaseline(baseline);
  }

  @override
  double getMaxIntrinsicHeight(double width) {
    return child.getMaxIntrinsicHeight(width);
  }

  @override
  double getMaxIntrinsicWidth(double height) {
    return child.getMaxIntrinsicWidth(height);
  }

  @override
  double getMinIntrinsicHeight(double width) {
    return child.getMinIntrinsicHeight(width);
  }

  @override
  double getMinIntrinsicWidth(double height) {
    return child.getMinIntrinsicWidth(height);
  }

  @override
  void layout(LayoutConstraints constraints) {
    throw Exception('layout is not supported in dry delegate');
  }

  @override
  LayoutData get layoutData => child.layoutData;

  @override
  ChildLayout? nextSibling;

  @override
  ChildLayout? previousSibling;

  @override
  LayoutSize get size {
    throw Exception('size is not supported in dry delegate');
  }
}

mixin ParentLayout {
  LayoutTextBaseline? get textBaseline;
  ChildLayout? get firstLayoutChild;
  ChildLayout? get lastLayoutChild;
  LayoutTextDirection get textDirection;
  LayoutSize get contentSize;
  LayoutSize get viewportSize;
  double get scrollOffsetX;
  double get scrollOffsetY;
  ChildLayout? getFirstDryLayout(LayoutHandle layoutHandle);
  ChildLayout? getLastDryLayout(LayoutHandle layoutHandle);
}

abstract class Layout {
  const Layout();
  LayoutHandle<Layout> createLayoutHandle(ParentLayout parent);
}

abstract class LayoutHandle<T extends Layout> {
  final T layout;
  final ParentLayout parent;

  LayoutHandle(this.layout, this.parent);

  ChildLayoutCache setupCache();

  LayoutSize performLayout(LayoutConstraints constraints, [bool dry = false]);

  LayoutRect performPositioning(
    LayoutSize viewportSize,
    LayoutSize contentSize,
  );

  double computeMinIntrinsicWidth(double height) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: height,
      ),
      true,
    );
    return dryLayout.width;
  }

  double computeMaxIntrinsicWidth(double height) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: height,
      ),
      true,
    );
    return dryLayout.width;
  }

  double computeMinIntrinsicHeight(double width) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: width,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      true,
    );
    return dryLayout.height;
  }

  double computeMaxIntrinsicHeight(double width) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: width,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      true,
    );
    return dryLayout.height;
  }
}
