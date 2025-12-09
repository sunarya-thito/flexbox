import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

/// A widget that rotates its child by a specified angle while filling the available space.
///
/// The [RotatedWidget] automatically calculates the optimal child size based on the
/// rotation angle, then applies rotation and scaling transformations to ensure the
/// rotated child completely fills the viewport without gaps or overflow.
///
/// At 0° or 180°, the child matches the viewport dimensions.
/// At 90° or 270°, the child's width and height are swapped.
/// At intermediate angles (e.g., 45°), the child is sized smaller and then scaled
/// up after rotation to fill the viewport.
///
/// The rotation is performed around the center of the child widget.
///
/// Example:
/// ```dart
/// // Wrap a widget in a fixed-size container and rotate it
/// SizedBox(
///   width: 400,
///   height: 200,
///   child: RotatedWidget(
///     angle: pi / 4, // 45 degrees
///     filterQuality: FilterQuality.medium,
///     child: Container(
///       color: Colors.blue,
///       child: Center(child: Text('Rotated')),
///     ),
///   ),
/// )
/// ```
///
/// See also:
///
///  * [Transform.rotate], which provides basic rotation without automatic sizing.
///  * [RotatedBox], which rotates in 90-degree increments.
class RotatedWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that rotates its child.
  ///
  /// The [angle] and [child] arguments must not be null.
  const RotatedWidget({
    super.key,
    required this.angle,
    this.filterQuality,
    required super.child,
  });

  /// The angle of rotation in radians.
  ///
  /// Positive values rotate clockwise, negative values rotate counter-clockwise.
  /// The rotation is applied around the center of the child widget.
  final double angle;

  /// The quality of the image filtering applied during rotation.
  ///
  /// When non-null, an [ImageFilter] is applied to smoothly interpolate
  /// pixels during the rotation transformation. This can improve visual
  /// quality at the cost of performance.
  ///
  /// If null, no image filtering is applied.
  ///
  /// See also:
  ///
  ///  * [FilterQuality], which defines the available quality levels.
  final FilterQuality? filterQuality;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRotatedWidget(angle: angle, filterQuality: filterQuality);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRotatedWidget renderObject,
  ) {
    if (renderObject.angle != angle) {
      renderObject.angle = angle;
      renderObject.markNeedsLayout();
    }
    if (renderObject.filterQuality != filterQuality) {
      bool didNeedCompositing = renderObject.alwaysNeedsCompositing;
      renderObject.filterQuality = filterQuality;
      if (didNeedCompositing != renderObject.alwaysNeedsCompositing) {
        renderObject.markNeedsCompositingBitsUpdate();
      }
      renderObject.markNeedsPaint();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('angle', angle));
    properties.add(
      EnumProperty<FilterQuality>(
        'filterQuality',
        filterQuality,
        defaultValue: null,
      ),
    );
  }
}

/// Render object that handles the rotation transformation and layout of [RotatedWidget].
///
/// This render object calculates the appropriate child size based on the rotation angle,
/// then applies a transformation matrix to rotate and scale the child to fill the viewport.
class RenderRotatedWidget extends RenderProxyBox {
  /// Creates a render object for rotating a child.
  ///
  /// The [angle] must be finite and is specified in radians.
  RenderRotatedWidget({
    required double angle,
    required FilterQuality? filterQuality,
    RenderBox? child,
  }) : _angle = angle,
       _filterQuality = filterQuality,
       super(child);

  double _angle;

  /// The current rotation angle in radians.
  ///
  /// When this value changes, the render object is marked as needing layout.
  double get angle => _angle;
  set angle(double value) {
    if (_angle == value) return;
    _angle = value;
    markNeedsLayout();
  }

  FilterQuality? _filterQuality;

  /// The quality of image filtering to apply during rotation.
  ///
  /// When this value changes, the render object is marked as needing paint
  /// and potentially needing compositing bits update.
  FilterQuality? get filterQuality => _filterQuality;
  set filterQuality(FilterQuality? value) {
    if (_filterQuality == value) return;
    final bool didNeedCompositing = alwaysNeedsCompositing;
    _filterQuality = value;
    if (didNeedCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  /// Computes the transformation matrix for rotating and scaling the child.
  ///
  /// This method creates a single [Matrix4] that:
  /// 1. Translates the child center to the origin
  /// 2. Rotates around the Z-axis by [angle]
  /// 3. Scales to fill the viewport
  /// 4. Translates to the viewport center
  ///
  /// The scaling ensures the rotated child fills the viewport without empty spaces.
  static Matrix4 _computeTransform(
    Size viewportSize,
    Size rotatedSize,
    double angle,
  ) {
    final double rotatedCenterX = rotatedSize.width / 2;
    final double rotatedCenterY = rotatedSize.height / 2;
    final double viewportCenterX = viewportSize.width / 2;
    final double viewportCenterY = viewportSize.height / 2;

    // Calculate how much the rotated child's bounding box will be
    final double cosAngle = cos(angle).abs();
    final double sinAngle = sin(angle).abs();
    final double rotatedWidth =
        rotatedSize.width * cosAngle + rotatedSize.height * sinAngle;
    final double rotatedHeight =
        rotatedSize.width * sinAngle + rotatedSize.height * cosAngle;

    // Scale to fill viewport
    final double scaleX = viewportSize.width / rotatedWidth;
    final double scaleY = viewportSize.height / rotatedHeight;

    // Build transform in-place: translate to origin, rotate, scale, translate back
    final Matrix4 result = Matrix4.identity();
    result.translateByDouble(viewportCenterX, viewportCenterY, 0.0, 1.0);
    result.scaleByDouble(scaleX, scaleY, 1.0, 1.0);
    result.rotateZ(angle);
    result.translateByDouble(-rotatedCenterX, -rotatedCenterY, 0.0, 1.0);

    return result;
  }

  /// Returns the complete transformation matrix for the current state.
  ///
  /// This getter computes the child size using [_inverseRotateSize] and
  /// then creates the transformation matrix using [_computeTransform].
  Matrix4 get _effectiveTransform {
    if (child == null) {
      return Matrix4.identity();
    }
    final Size viewportSize = constraints.biggest;
    final Size rotatedSize = _inverseRotateSize(viewportSize, angle);
    return _computeTransform(viewportSize, rotatedSize, angle);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child != null) {
      Size size = constraints.biggest;
      assert(
        size.isFinite,
        'RotatedWidget does not support infinite constraints.',
      );
      Size rotatedSize = _inverseRotateSize(size, angle);
      child.layout(BoxConstraints.tight(rotatedSize));
      this.size = constraints.biggest;
    } else {
      size = constraints.biggest;
    }
  }

  /// Calculates the child size that will fill the viewport when rotated.
  ///
  /// This method calculates the optimal child size by:
  /// 1. Swapping dimensions based on the rotation angle (e.g., at 90°, width and height swap)
  /// 2. Scaling to ensure the rotated result fits within the viewport bounds
  ///
  /// At 0°, returns approximately the viewport size.
  /// At 90°, swaps width and height.
  /// At 45°, returns a smaller size that, when rotated and scaled, fills the viewport.
  Size _inverseRotateSize(Size size, double angle) {
    final double cosAngle = cos(angle).abs();
    final double sinAngle = sin(angle).abs();

    if (cosAngle < 0.0001 && sinAngle < 0.0001) {
      return Size.zero;
    }

    // The key insight: at 90°, a WxH viewport needs an HxW child
    // The formula: blend between original and swapped based on sin/cos
    // width gets more from height as angle approaches 90°
    // height gets more from width as angle approaches 90°
    final double width = size.width * cosAngle + size.height * sinAngle;
    final double height = size.height * cosAngle + size.width * sinAngle;

    // Now scale down to fit (contain behavior)
    final double rotatedW = width * cosAngle + height * sinAngle;
    final double rotatedH = width * sinAngle + height * cosAngle;

    final double scaleW = size.width / rotatedW;
    final double scaleH = size.height / rotatedH;
    final double scale = scaleW < scaleH ? scaleW : scaleH;

    return Size(width * scale, height * scale);
  }

  @override
  bool get alwaysNeedsCompositing => child != null && filterQuality != null;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _effectiveTransform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final Matrix4 transform = _effectiveTransform;
      if (filterQuality == null) {
        final Offset? childOffset = MatrixUtils.getAsTranslation(transform);
        if (childOffset == null) {
          // if the matrix is singular the children would be compressed to a line or
          // single point, instead short-circuit and paint nothing.
          final double det = transform.determinant();
          if (det == 0 || !det.isFinite) {
            layer = null;
            return;
          }
          layer = context.pushTransform(
            needsCompositing,
            offset,
            transform,
            super.paint,
            oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
          );
        } else {
          super.paint(context, offset + childOffset);
          layer = null;
        }
      } else {
        final Matrix4 effectiveTransform =
            Matrix4.translationValues(offset.dx, offset.dy, 0.0)
              ..multiply(transform)
              ..translateByDouble(-offset.dx, -offset.dy, 0, 1);
        final ui.ImageFilter filter = ui.ImageFilter.matrix(
          effectiveTransform.storage,
          filterQuality: filterQuality!,
        );
        if (layer case final ImageFilterLayer filterLayer) {
          filterLayer.imageFilter = filter;
        } else {
          layer = ImageFilterLayer(imageFilter: filter);
        }
        context.pushLayer(layer!, super.paint, offset);
        assert(() {
          layer!.debugCreator = debugCreator;
          return true;
        }());
      }
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_effectiveTransform);
  }
}
