import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that renders as zero size, acting as a fallback for invalid or unsupported content.
///
/// This widget is useful when you need a placeholder that doesn't take up any space
/// in the layout. It can wrap child content but reports zero intrinsic dimensions,
/// making it invisible in the layout while still maintaining the widget tree structure.
///
/// The [FallbackWidget] uses [RenderFallback] which returns zero for all intrinsic
/// size calculations, effectively hiding its contents from the layout system.
class FallbackWidget extends SingleChildRenderObjectWidget {
  /// Creates a fallback widget that renders as zero size.
  ///
  /// The optional [child] parameter specifies the widget to wrap, though it
  /// will not contribute to layout dimensions.
  const FallbackWidget({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFallback();
  }
}

/// A render box that reports zero size for all intrinsic dimension queries.
///
/// This render object acts as a proxy but overrides all intrinsic size methods
/// to return zero, effectively making any child content invisible to the layout
/// algorithm. It's useful for fallback scenarios where content should not affect
/// the parent layout.
class RenderFallback extends RenderProxyBox {
  /// Creates a fallback render box with an optional child.
  ///
  /// Even if a [child] is provided, all intrinsic size calculations will
  /// return zero, hiding the child from layout computations.
  RenderFallback({RenderBox? child}) : super(child);

  @override
  double computeMinIntrinsicHeight(double width) {
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return 0.0;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return 0.0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size.zero;
  }
}
