import 'package:flexiblebox/src/rendering.dart';
import 'package:flutter/cupertino.dart';

abstract class ChildLayoutCache {
  double offsetX = 0.0;
  double offsetY = 0.0;

  Size? cachedFitContentSize;
  Size? cachedAutoSize;
}

mixin ChildLayout {
  void layout(BoxConstraints constraints);
  Size dryLayout(BoxConstraints constraints);
  double computeMaxIntrinsicWidth(double height);
  double computeMaxIntrinsicHeight(double width);
  double computeMinIntrinsicWidth(double height);
  double computeMinIntrinsicHeight(double width);
  Size get size;
  ChildLayoutCache get layoutCache;
  LayoutData get layoutData;
  ChildLayout? get nextSibling;
  ChildLayout? get previousSibling;
}

mixin ParentLayout {
  LayoutHandle get layoutHandle;
  ChildLayout? get firstLayoutChild;
  ChildLayout? get lastLayoutChild;
  TextDirection get textDirection;
  Size get contentSize;
  Size get viewportSize;
  double get scrollOffsetX;
  double get scrollOffsetY;
  ChildLayout? get firstDryLayout;
  ChildLayout? get lastDryLayout;
}

abstract class Layout {
  LayoutHandle<Layout> createLayoutHandle(ParentLayout parent);
}

abstract class LayoutHandle<T extends Layout> {
  final T layout;
  final ParentLayout parent;

  double verticalOffset = 0.0;
  double horizontalOffset = 0.0;

  LayoutHandle(this.layout, this.parent);

  ChildLayoutCache setupCache();

  Size performLayout(BoxConstraints constraints, [bool dry = false]);

  void performPositioning(Size size);

  double computeMinIntrinsicWidth(double height) {
    Size dryLayout = performLayout(
      BoxConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: height,
        maxHeight: height,
      ),
      true,
    );
    return dryLayout.width;
  }

  double computeMaxIntrinsicWidth(double height) {
    Size dryLayout = performLayout(
      BoxConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: height,
        maxHeight: height,
      ),
      true,
    );
    return dryLayout.width;
  }

  double computeMinIntrinsicHeight(double width) {
    Size dryLayout = performLayout(
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      true,
    );
    return dryLayout.height;
  }

  double computeMaxIntrinsicHeight(double width) {
    Size dryLayout = performLayout(
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      true,
    );
    return dryLayout.height;
  }
}
