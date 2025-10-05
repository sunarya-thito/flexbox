import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class FallbackWidget extends SingleChildRenderObjectWidget {
  const FallbackWidget({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFallback();
  }
}

class RenderFallback extends RenderProxyBox {
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
