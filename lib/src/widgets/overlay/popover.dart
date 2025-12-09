import 'dart:math';

import 'package:flexiblebox/src/widgets/paint_boundary.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class OverlayAnchor extends StatelessWidget {
  final WidgetBuilder builder;

  const OverlayAnchor({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

abstract interface class OverlayPopupLayout {
  BoxConstraints getConstraints(
    TextDirection direction,
    Size anchorSize,
  );
  Matrix4 computeTransform(
    TextDirection direction,
    Size popupSize,
    Rect anchorRect,
    Rect screenRect,
  );
}

enum OverlayConstraint {
  flexible(_flexible),
  minAnchor(_minAnchor),
  maxAnchor(_maxAnchor),
  anchor(_anchor);

  static ({double min, double max}) _flexible(double size) =>
      (min: 0, max: double.infinity);
  static ({double min, double max}) _minAnchor(double size) =>
      (min: size, max: double.infinity);
  static ({double min, double max}) _maxAnchor(double size) =>
      (min: 0, max: size);
  static ({double min, double max}) _anchor(double size) =>
      (min: size, max: size);

  final ({double min, double max}) Function(double size) constrainer;
  const OverlayConstraint(this.constrainer);
}

// Rules:
// 1. If popup overflows screen, flip it along that axis
// 2. If the flipped position still overflows, then undo the flip, but make sure it fits within the screen by shifting it (account for margins)
class _SimpleOverlayPopupLayout implements OverlayPopupLayout {
  final EdgeInsetsGeometry margin;
  final Matrix4
  transform; // don't forget to apply origin based on alignment (make sure its flipped correctly)
  final AlignmentGeometry alignment;
  final AlignmentGeometry anchorAlignment;
  final OverlayConstraint widthConstraint;
  final OverlayConstraint heightConstraint;
  const _SimpleOverlayPopupLayout({
    this.margin = EdgeInsets.zero,
    this.alignment = Alignment.topLeft,
    this.anchorAlignment = Alignment.bottomLeft,
    this.widthConstraint = OverlayConstraint.flexible,
    this.heightConstraint = OverlayConstraint.flexible,
    required this.transform,
  });
  @override
  BoxConstraints getConstraints(
    TextDirection direction,
    Size anchorSize,
  ) {
    final constraintX = widthConstraint.constrainer(anchorSize.width);
    final constraintY = heightConstraint.constrainer(anchorSize.height);
    return BoxConstraints(
      minWidth: constraintX.min,
      maxWidth: constraintX.max,
      minHeight: constraintY.min,
      maxHeight: constraintY.max,
    );
  }

  Matrix4 _computeEffectiveTransform(Matrix4 transform, Offset origin) {
    final Matrix4 result = Matrix4.identity();
    result.translateByDouble(origin.dx, origin.dy, 0, 1);
    result.multiply(transform);
    result.translateByDouble(-origin.dx, -origin.dy, 0, 1);
    return result;
  }

  @override
  Matrix4 computeTransform(
    TextDirection direction,
    Size popupSize,
    Rect anchorRect,
    Rect screenRect,
  ) {
    // Calculate anchor and popup alignment points
    final anchorAlign = anchorAlignment.resolve(direction);
    final popupAlign = alignment.resolve(direction);
    final anchorPoint =
        anchorRect.center + anchorAlign.alongSize(anchorRect.size);
    final popupOrigin = popupAlign.alongSize(popupSize);

    // Initial position
    Offset popupPos = anchorPoint - popupOrigin;

    // Apply margin
    final resolvedMargin = margin.resolve(direction);
    popupPos += Offset(resolvedMargin.left, resolvedMargin.top);

    // Compose initial transform: translation, then field transform at alignment origin
    // Helper to transform a rect with a matrix
    Rect transformRect(Rect rect, Matrix4 matrix) {
      final List<Offset> points = [
        rect.topLeft,
        rect.topRight,
        rect.bottomLeft,
        rect.bottomRight,
      ];
      final transformed = points
          .map((p) => MatrixUtils.transformPoint(matrix, p))
          .toList();
      double left = transformed
          .map((o) => o.dx)
          .reduce((a, b) => a < b ? a : b);
      double right = transformed
          .map((o) => o.dx)
          .reduce((a, b) => a > b ? a : b);
      double top = transformed.map((o) => o.dy).reduce((a, b) => a < b ? a : b);
      double bottom = transformed
          .map((o) => o.dy)
          .reduce((a, b) => a > b ? a : b);
      return Rect.fromLTRB(left, top, right, bottom);
    }

    // Start with no flip
    Alignment flipAlign = popupAlign;
    Offset flipOrigin = popupOrigin;
    Offset flipPos = popupPos;
    Matrix4 flipTransform = Matrix4.translationValues(flipPos.dx, flipPos.dy, 0)
      ..multiply(_computeEffectiveTransform(transform, flipOrigin));
    Rect popupRect = transformRect(
      Rect.fromLTWH(0, 0, popupSize.width, popupSize.height),
      flipTransform,
    );

    // --- X Axis ---
    if (popupRect.left < screenRect.left ||
        popupRect.right > screenRect.right) {
      // Try flipping X
      flipAlign = Alignment(-popupAlign.x, popupAlign.y);
      flipOrigin = Offset(
        popupSize.width * (flipAlign.x + 1) / 2,
        popupSize.height * (flipAlign.y + 1) / 2,
      );
      flipPos =
          anchorPoint -
          flipOrigin +
          Offset(resolvedMargin.left, resolvedMargin.top);
      flipTransform = Matrix4.translationValues(flipPos.dx, flipPos.dy, 0)
        ..multiply(_computeEffectiveTransform(transform, flipOrigin));
      popupRect = transformRect(
        Rect.fromLTWH(0, 0, popupSize.width, popupSize.height),
        flipTransform,
      );
      // If still overflow, undo flip and shift
      if (popupRect.left < screenRect.left ||
          popupRect.right > screenRect.right) {
        flipAlign = popupAlign;
        flipOrigin = popupOrigin;
        flipPos = popupPos;
        flipTransform = Matrix4.translationValues(flipPos.dx, flipPos.dy, 0)
          ..multiply(_computeEffectiveTransform(transform, flipOrigin));
        popupRect = transformRect(
          Rect.fromLTWH(0, 0, popupSize.width, popupSize.height),
          flipTransform,
        );
        double shiftX = 0;
        if (popupRect.left < screenRect.left) {
          shiftX = screenRect.left - popupRect.left;
        } else if (popupRect.right > screenRect.right) {
          shiftX = screenRect.right - popupRect.right;
        }
        flipPos = flipPos.translate(shiftX, 0);
        flipTransform = Matrix4.translationValues(flipPos.dx, flipPos.dy, 0)
          ..multiply(_computeEffectiveTransform(transform, flipOrigin));
        popupRect = transformRect(
          Rect.fromLTWH(0, 0, popupSize.width, popupSize.height),
          flipTransform,
        );
      }
    }

    // --- Y Axis ---
    if (popupRect.top < screenRect.top ||
        popupRect.bottom > screenRect.bottom) {
      // Try flipping Y
      flipAlign = Alignment(flipAlign.x, -flipAlign.y);
      flipOrigin = Offset(
        popupSize.width * (flipAlign.x + 1) / 2,
        popupSize.height * (flipAlign.y + 1) / 2,
      );
      flipPos =
          anchorPoint -
          flipOrigin +
          Offset(resolvedMargin.left, resolvedMargin.top);
      flipTransform = Matrix4.translationValues(flipPos.dx, flipPos.dy, 0)
        ..multiply(_computeEffectiveTransform(transform, flipOrigin));
      popupRect = transformRect(
        Rect.fromLTWH(0, 0, popupSize.width, popupSize.height),
        flipTransform,
      );
      // If still overflow, undo flip and shift
      if (popupRect.top < screenRect.top ||
          popupRect.bottom > screenRect.bottom) {
        flipAlign = Alignment(flipAlign.x, popupAlign.y);
        flipOrigin = Offset(
          popupSize.width * (flipAlign.x + 1) / 2,
          popupSize.height * (flipAlign.y + 1) / 2,
        );
        flipPos =
            anchorPoint -
            flipOrigin +
            Offset(resolvedMargin.left, resolvedMargin.top);
        flipTransform = Matrix4.translationValues(flipPos.dx, flipPos.dy, 0)
          ..multiply(_computeEffectiveTransform(transform, flipOrigin));
        popupRect = transformRect(
          Rect.fromLTWH(0, 0, popupSize.width, popupSize.height),
          flipTransform,
        );
        double shiftY = 0;
        if (popupRect.top < screenRect.top) {
          shiftY = screenRect.top - popupRect.top;
        } else if (popupRect.bottom > screenRect.bottom) {
          shiftY = screenRect.bottom - popupRect.bottom;
        }
        flipPos = flipPos.translate(0, shiftY);
        flipTransform = Matrix4.translationValues(flipPos.dx, flipPos.dy, 0)
          ..multiply(_computeEffectiveTransform(transform, flipOrigin));
        popupRect = transformRect(
          Rect.fromLTWH(0, 0, popupSize.width, popupSize.height),
          flipTransform,
        );
      }
    }

    // Final transform
    return flipTransform;
  }
}

class _OverlayPopupWidget extends SingleChildRenderObjectWidget {
  final OverlayPopupLayout popupLayout;
  const _OverlayPopupWidget({
    required this.popupLayout,
    super.child,
  });
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _OverlayPopupRenderObject(
      popupLayout: popupLayout,
      repaintManager: RepaintManager.of(context),
      direction: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _OverlayPopupRenderObject renderObject,
  ) {
    if (renderObject.popupLayout != popupLayout) {
      renderObject.popupLayout = popupLayout;
      renderObject.markNeedsLayout();
    }
    final newRepaintManager = RepaintManager.of(context);
    if (renderObject.repaintManager != newRepaintManager) {
      renderObject.repaintManager = newRepaintManager;
      renderObject.markNeedsPaint();
    }
    final newDirection = Directionality.of(context);
    if (renderObject.direction != newDirection) {
      renderObject.direction = newDirection;
      renderObject.markNeedsLayout();
    }
  }
}

Rect _transformRect(Rect rect, Matrix4 matrix) {
  Offset topLeft = MatrixUtils.transformPoint(matrix, rect.topLeft);
  Offset topRight = MatrixUtils.transformPoint(matrix, rect.topRight);
  Offset bottomLeft = MatrixUtils.transformPoint(matrix, rect.bottomLeft);
  Offset bottomRight = MatrixUtils.transformPoint(matrix, rect.bottomRight);
  double minX = min(
    min(topLeft.dx, topRight.dx),
    min(bottomLeft.dx, bottomRight.dx),
  );
  double maxX = max(
    max(topLeft.dx, topRight.dx),
    max(bottomLeft.dx, bottomRight.dx),
  );
  double minY = min(
    min(topLeft.dy, topRight.dy),
    min(bottomLeft.dy, bottomRight.dy),
  );
  double maxY = max(
    max(topLeft.dy, topRight.dy),
    max(bottomLeft.dy, bottomRight.dy),
  );
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

class _OverlayPopupRenderObject extends RenderShiftedBox {
  OverlayPopupLayout popupLayout;
  RepaintManager repaintManager;
  TextDirection direction;
  _OverlayPopupRenderObject({
    required this.popupLayout,
    required this.repaintManager,
    required this.direction,
  }) : super(null);
  @override
  void performLayout() {
    if (child == null) {
      size = constraints.biggest;
      return;
    }
    var anchorRect = repaintManager.paintBounds;
    final childConstraints = popupLayout.getConstraints(
      direction,
      anchorRect.size,
    );
    child!.layout(childConstraints, parentUsesSize: true);
    size = Size(
      child!.size.width,
      child!.size.height,
    );
  }

  Matrix4 get _effectiveTransform {
    var anchorRect = repaintManager.paintBounds;
    anchorRect = _transformRect(
      anchorRect,
      repaintManager.computeTransform(this),
    );
    return popupLayout.computeTransform(
      direction,
      size,
      anchorRect,
      Offset.zero & constraints.biggest,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _effectiveTransform,
      (context, offset) {
        child!.paint(context, offset);
      },
      oldLayer: layer as TransformLayer?,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _effectiveTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child!.hitTest(result, position: transformed);
      },
    );
  }
}
