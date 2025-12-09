import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class LocalHero extends SingleChildRenderObjectWidget {
  final Object tag;
  final Duration duration;
  final Curve curve;

  const LocalHero({
    super.key,
    required this.tag,
    this.duration = const Duration(milliseconds: 3000),
    this.curve = Curves.linear,
    Widget? child,
  }) : super(child: child);

  @override
  RenderHero createRenderObject(BuildContext context) {
    return RenderHero(
      widget: this,
      element: context as Element,
      debugKey: key,
      tag: tag,
      duration: duration,
      curve: curve,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHero renderObject) {
    renderObject
      ..debugKey = key
      ..widget = this
      ..element = context as Element
      ..tag = tag
      ..duration = duration
      ..curve = curve;
  }
}

class WidgetShape {
  final Size size;
  final Matrix4 transform;
  WidgetShape({
    required this.size,
    required this.transform,
  });

  Offset get translation => MatrixUtils.transformPoint(transform, Offset.zero);

  static WidgetShape lerp(WidgetShape a, WidgetShape b, double t) {
    final lerpedSize = Size.lerp(a.size, b.size, t)!;
    final lerpedTransform = Matrix4Tween(
      begin: a.transform,
      end: b.transform,
    ).lerp(t);
    return WidgetShape(
      size: lerpedSize,
      transform: lerpedTransform,
    );
  }
}

class RenderHero extends RenderProxyBox {
  Key? debugKey;
  Widget widget;
  Element element;
  Object tag;
  Duration duration;
  Curve curve;

  RenderHero({
    this.debugKey,
    required this.widget,
    required this.element,
    required this.tag,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    RenderBox? child,
  }) : super(child);

  RenderHeroScope? _scope;
  WidgetShape? shape; // shape before any transformation

  ActiveHero? claimed;

  @override
  void detach() {
    super.detach();
    _scope?.push(this);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    final scope = _scope = _find();
    if (scope != null) {
      scope.claim(this);
    }
  }

  RenderHeroScope? _find() {
    RenderObject? parent = this.parent;
    while (parent != null) {
      if (parent is RenderHeroScope) {
        return parent;
      }
      parent = parent.parent;
    }
    return null;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (claimed != null) {
      return false;
    }
    return super.hitTest(result, position: position);
  }

  @override
  void performLayout() {
    if (claimed == null) {
      shape = null;
    }
    super.performLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scope != null) {
      shape ??= WidgetShape(
        size: size,
        transform: getTransformTo(_scope!),
      );
    }
    if (claimed != null) {
      return;
    }
    super.paint(context, offset);
  }
}
