import 'package:flutter/widgets.dart';

abstract class BoxBorderGeometry {
  const BoxBorderGeometry();
  BoxBorder resolve(TextDirection direction);
}

class BoxBorderDirectional extends BoxBorderGeometry {
  final BoxBorderSide start;
  final BoxBorderSide end;
  final BoxBorderSide top;
  final BoxBorderSide bottom;
  const BoxBorderDirectional({
    required this.start,
    required this.end,
    required this.top,
    required this.bottom,
  });
  @override
  BoxBorder resolve(TextDirection direction) {
    return switch (direction) {
      TextDirection.ltr => BoxBorder(
        left: start,
        right: end,
        top: top,
        bottom: bottom,
      ),
      TextDirection.rtl => BoxBorder(
        left: end,
        right: start,
        top: top,
        bottom: bottom,
      ),
    };
  }
}

class BoxBorder extends BoxBorderGeometry {
  final BoxBorderSide left;
  final BoxBorderSide right;
  final BoxBorderSide top;
  final BoxBorderSide bottom;
  const BoxBorder({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });
  @override
  BoxBorder resolve(TextDirection direction) => this;
}

abstract class BoxBorderFill {
  const BoxBorderFill();
  void applyToPaint(Paint paint, Rect rect);
}

class BoxBorderColorFill extends BoxBorderFill {
  final Color color;
  const BoxBorderColorFill(this.color);
  @override
  void applyToPaint(Paint paint, Rect rect) {
    paint.color = color;
  }
}

class BoxBorderGradientFill extends BoxBorderFill {
  final Gradient gradient;
  const BoxBorderGradientFill(this.gradient);
  @override
  void applyToPaint(Paint paint, Rect rect) {
    paint.shader = gradient.createShader(rect);
  }
}

class BoxBorderSide {
  static const none = BoxBorderSide._none();
  final double width;
  final double alignment;
  final BoxBorderFill? fill;
  const BoxBorderSide({
    required this.width,
    required this.alignment,
    required BoxBorderFill this.fill,
  });
  const BoxBorderSide._none() : width = 0, alignment = 0, fill = null;
}

class BorderStyle {
  final List<double> dashArray;
  const BorderStyle.dashed(this.dashArray);
  const BorderStyle.solid() : dashArray = const [];
}

enum BorderSideName { top, right, bottom, left }

void paintBorder({
  required Canvas canvas,
  required Rect rect,
  required BorderRadius borderRadius,
  required BoxBorder border,
  required BorderStyle borderStyle,
  required StrokeJoin strokeJoin,
  required StrokeCap strokeCap,
}) {
  // TODO: Implement border painting logic
}
