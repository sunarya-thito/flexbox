import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lerp between two 2D transforms embedded in Matrix4 (column-major, OpenGL-style).
/// Decomposes into translate + rotate + shear + scale, interpolates, then recomposes.
/// This is robust to differing original op orders ("unordered" 2D lerp).
Matrix4 lerpMatrix4_2DUnordered(Matrix4 a, Matrix4 b, double t) {
  final da = _decompose2D(a);
  final db = _decompose2D(b);

  // Lerp translation.
  final tx = _lerp(da.tx, db.tx, t);
  final ty = _lerp(da.ty, db.ty, t);

  // Lerp rotation by shortest path.
  final dTheta = _shortestAngleDelta(da.theta, db.theta);
  final theta = da.theta + dTheta * t;

  // Lerp scale and shear linearly.
  final sx = _lerp(da.sx, db.sx, t);
  final sy = _lerp(da.sy, db.sy, t);
  final shear = _lerp(da.shear, db.shear, t);

  return _compose2D(tx, ty, theta, sx, sy, shear);
}

/// Holds a 2D affine decomposition: translate, rotate, shear (x), scale.
class _Aff2 {
  final double tx, ty; // translation
  final double theta; // rotation (radians)
  final double sx, sy; // scale
  final double shear; // x-shear (shear along x)
  _Aff2(this.tx, this.ty, this.theta, this.sx, this.sy, this.shear);
}

/// Decompose a Matrix4 that represents a 2D affine transform
/// into translation, rotation, shear(x), and scale using a stable 2D algorithm.
/// Based on Graphics Gems-style decomposition.
_Aff2 _decompose2D(Matrix4 m) {
  final s = m.storage; // column-major
  // 2x2 linear part (top-left), translation in last column
  double m00 = s[0], m01 = s[4];
  double m10 = s[1], m11 = s[5];
  final tx = s[12], ty = s[13];

  // Extract scale X = length of first column
  double sx = math.sqrt(m00 * m00 + m10 * m10);
  if (sx > 0) {
    m00 /= sx;
    m10 /= sx;
  }

  // Compute shear = dot(col0, col1)
  double shear = m00 * m01 + m10 * m11;

  // Make col1 orthogonal to col0
  m01 -= m00 * shear;
  m11 -= m10 * shear;

  // Extract scale Y = length of adjusted second column
  double sy = math.sqrt(m01 * m01 + m11 * m11);
  if (sy > 0) {
    m01 /= sy;
    m11 /= sy;
    shear /= sy;
  }

  // Handle reflection (negative determinant): fold it into X scale & shear
  double det = m00 * m11 - m10 * m01;
  if (det < 0) {
    sx = -sx;
    shear = -shear;
    m00 = -m00;
    m10 = -m10;
  }

  // Rotation is angle of (normalized) first column
  final theta = math.atan2(m10, m00);

  return _Aff2(tx, ty, theta, sx, sy, shear);
}

/// Recompose a 2D affine transform back into Matrix4:
/// M = T * R(theta) * ShearX(shear) * Scale(sx, sy)
Matrix4 _compose2D(
  double tx,
  double ty,
  double theta,
  double sx,
  double sy,
  double shear,
) {
  final c = math.cos(theta), s = math.sin(theta);

  // Build linear 2x2 = R * Shx * S
  // ShearX(s) = [1 s; 0 1], Scale = [sx 0; 0 sy]
  // Shx*S = [sx, shear*sy; 0, sy]
  final a = c * sx + (-s) * 0; // m00
  final b = s * sx + c * 0; // m10
  final c01 = c * (shear * sy) + (-s) * sy; // m01
  final d = s * (shear * sy) + c * sy; // m11

  // Assemble into a Matrix4 (column-major, with z untouched as identity)
  final out = Matrix4.identity();
  final o = out.storage;
  o[0] = a;
  o[4] = c01;
  o[8] = 0;
  o[12] = tx;
  o[1] = b;
  o[5] = d;
  o[9] = 0;
  o[13] = ty;
  o[2] = 0;
  o[6] = 0;
  o[10] = 1;
  o[14] = 0;
  o[3] = 0;
  o[7] = 0;
  o[11] = 0;
  o[15] = 1;
  return out;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Returns the smallest signed angle to rotate from a->b (in radians), in [-pi, pi].
double _shortestAngleDelta(double a, double b) {
  double diff = (b - a) % (2 * math.pi);
  if (diff > math.pi) diff -= 2 * math.pi;
  if (diff < -math.pi) diff += 2 * math.pi;
  return diff;
}

class _Linked<T> {
  final T current;
  final _Linked<T>? previous;

  _Linked(this.current, [this.previous]);
}

class MorphState {
  final RenderMorph root;
  // final Matrix4 targetTransform;
  final _Linked<RenderObject> parentPath;
  final MorphPath path;
  final Decoration? sourceDecoration;
  final Decoration? targetDecoration;
  // final Size? sourceSize;
  // final Size? targetSize;
  final bool isSource;
  final RenderMorphed current;

  MorphState({
    required this.root,
    required this.parentPath,
    required this.path,
    required this.sourceDecoration,
    required this.targetDecoration,
    required this.isSource,
    required this.current,
  });

  bool get isTarget => !isSource;
}

abstract class MorphPath {
  // Path can only go forward
  // (from root tree to leaf)
  MorphPath? next;
  MorphPath? previous;
  RenderObject get object;

  bool contains(RenderObject target);

  void applyTransform(RenderMorph root, Matrix4 transform);
  void defaultApplyTransform(RenderMorph root, Matrix4 transform) {
    if (object.parent is! RenderMorphed) {
      object.parent!.applyPaintTransform(object, transform);
    }
  }

  Decoration? applyDecoration(Object tag) {
    if (object is RenderMorphed && (object as RenderMorphed).tag == tag) {
      final morphedBox = object as RenderMorphed;
      return morphedBox.morphDecoration;
    }
    return next?.applyDecoration(tag);
  }

  Size? applySize(Object tag) {
    if (object is RenderMorphed && (object as RenderMorphed).tag == tag) {
      final morphedBox = object as RenderMorphed;
      return morphedBox.morphSize;
    }
    return next?.applySize(tag);
  }

  void collectNext(List<MorphPath> paths) {
    paths.add(this);
    next?.collectNext(paths);
  }

  String debugString() {
    return '$runtimeType(${object is RenderMorph
        ? '!${(object as RenderMorph).debugKey}'
        : object is RenderMorphed
        ? '#${(object as RenderMorphed).tag}:${(object as RenderMorphed).debugKey}'
        : object.runtimeType}) -> ${next?.debugString() ?? 'null'}';
  }
}

class SimpleMorphPath extends MorphPath {
  @override
  final RenderObject object;

  SimpleMorphPath({required this.object});

  @override
  bool contains(RenderObject target) {
    if (object == target) {
      return true;
    }
    return next?.contains(target) ?? false;
  }

  @override
  void applyTransform(RenderMorph root, Matrix4 transform) {
    defaultApplyTransform(root, transform);
    next?.applyTransform(root, transform);
  }
}

class MorphingMorphPath extends MorphPath {
  @override
  final RenderMorph object;
  final MorphPath? source;
  final MorphPath? target;
  final double interpolation;
  final bool isSource;

  MorphingMorphPath({
    required this.object,
    required this.source,
    required this.target,
    required this.interpolation,
    required this.isSource,
  });

  @override
  bool contains(RenderObject target) {
    if (object == target) {
      return true;
    }
    return source?.contains(target) == true ||
        this.target?.contains(target) == true;
  }

  @override
  String debugString() {
    return '$runtimeType(${object.debugKey}, source: ${source?.debugString()}, target: ${target?.debugString()}, interpolation: $interpolation, isSource: $isSource)';
  }

  @override
  void applyTransform(RenderMorph root, Matrix4 transform) {
    defaultApplyTransform(root, transform);
    final sourceCloned = Matrix4.identity();
    final targetCloned = Matrix4.identity();
    source?.applyTransform(object, sourceCloned);
    target?.applyTransform(object, targetCloned);
    final tweened = _lerpMatrix(
      sourceCloned,
      targetCloned,
      object.interpolation,
    );
    transform.multiply(tweened);
  }

  @override
  void collectNext(List<MorphPath> paths) {
    paths.add(this);
    // paths.add(source);
    // paths.add(target);
  }

  @override
  Decoration? applyDecoration(Object tag) {
    return Decoration.lerp(
      source?.applyDecoration(tag),
      target?.applyDecoration(tag),
      interpolation,
    );
  }

  @override
  Size? applySize(Object tag) {
    return Size.lerp(
      source?.applySize(tag),
      target?.applySize(tag),
      interpolation,
    );
  }

  @override
  MorphPath? get next {
    throw UnsupportedError('MorphingMorphPath does not support next.');
  }
}

Matrix4 _lerpMatrix(Matrix4 a, Matrix4 b, double t) {
  return lerpMatrix4_2DUnordered(a, b, t);
}

class MorphParentData extends ContainerBoxParentData<RenderBox> {}

class RenderMorph extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MorphParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MorphParentData> {
  Object? debugKey;
  double interpolation;

  RenderMorph({required this.interpolation, this.debugKey});

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MorphParentData) {
      child.parentData = MorphParentData();
    }
  }

  @override
  void performLayout() {
    final childCount = this.childCount;

    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    if (childCount == 1) {
      final child = firstChild!;
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
      return;
    }

    final (source, target) = _findMorph();

    source.layout(constraints, parentUsesSize: true);
    target.layout(constraints, parentUsesSize: true);

    size = constraints.constrain(
      Size.lerp(source.size, target.size, localInterpolation)!,
    );
    _pair(_Linked(source, _Linked(this)), target, true);
    _pair(_Linked(target, _Linked(this)), source, false);
  }

  bool get hasParentMorph {
    RenderObject? parent = this.parent;
    while (parent != null) {
      if (parent is RenderMorph) {
        return true;
      }
      parent = parent.parent;
    }
    return false;
  }

  @override
  void dispose() {
    _disposePair(this);
    super.dispose();
  }

  void _disposePair(RenderObject parent) {
    if (parent is RenderMorphed) {
      parent.disposeMorph(this);
    }
    parent.visitChildren((child) {
      _disposePair(child);
    });
  }

  void _pair(
    _Linked<RenderObject> currentPath,
    RenderObject opposite,
    bool isSource,
  ) {
    final current = currentPath.current;
    if (current is RenderMorph) {
      current.visitActiveChild((child) {
        _pair(_Linked(child, currentPath), opposite, isSource);
      });
      return;
    }
    if (current is RenderMorphed) {
      // Found a morphed object
      current.disposeMorph(this);
      // we need to find the morph pair
      // start looking on the next morph path
      final lookUpPath = SimpleMorphPath(object: this); // start from root
      final foundPair = current.findMorph(this, opposite, lookUpPath, isSource);
      if (foundPair) {
        // final transform = Matrix4.identity();
        // lookUpPath.next!.applyTransform(this, transform);
        // final upperTransform = Matrix4.identity();
        // _apply(currentPath, upperTransform);
        if (isSource) {
          current.replaceMorph(
            MorphState(
              root: this,
              // targetTransform: Matrix4.inverted(upperTransform) * transform,
              parentPath: currentPath,
              path: lookUpPath,
              sourceDecoration: current.morphDecoration,
              targetDecoration: lookUpPath.applyDecoration(current.tag),
              // sourceSize: current.morphSize,
              // targetSize: lookUpPath.applySize(current.tag),
              isSource: isSource,
              current: current,
            ),
          );
        } else {
          current.replaceMorph(
            MorphState(
              root: this,
              // targetTransform: Matrix4.inverted(upperTransform) * transform,
              parentPath: currentPath,
              path: lookUpPath,
              sourceDecoration: lookUpPath.applyDecoration(current.tag),
              targetDecoration: current.morphDecoration,
              // sourceSize: lookUpPath.applySize(current.tag),
              // targetSize: current.morphSize,
              isSource: isSource,
              current: current,
            ),
          );
        }
      }
    }
    current.visitChildren((child) {
      _pair(_Linked(child, currentPath), opposite, isSource);
    });
  }

  int get childSourceIndex {
    final childSegment = 1.0 / (childCount - 1);
    return (interpolation / childSegment).floor();
  }

  double get localInterpolation {
    if (interpolation <= 0) {
      return 0.0;
    }
    if (interpolation >= 1) {
      return 1.0;
    }
    final childSegment = 1.0 / (childCount - 1);
    final childSourceIndex = this.childSourceIndex;
    return (interpolation - (childSourceIndex * childSegment)) / childSegment;
  }

  (RenderBox source, RenderBox target) _findMorph() {
    RenderBox? sourceRoot;
    RenderBox? targetRoot;
    int childIndex = 0;

    final childSegment = 1.0 / (childCount - 1);
    final childSourceIndex = (interpolation / childSegment).floor();

    if (interpolation == 0) {
      return (firstChild!, childAfter(firstChild!)!);
    }
    if (interpolation == 1) {
      return (childBefore(lastChild!)!, lastChild!);
    }

    RenderBox? child = firstChild;
    while (child != null) {
      if (childIndex == childSourceIndex) {
        sourceRoot = child;
        targetRoot = childAfter(child);
        break;
      }
      child = childAfter(child);
      childIndex++;
    }
    return (sourceRoot!, targetRoot!);
  }

  double _lerpOpacity(double a, double b, double t) {
    t = Curves.easeInCubic.transform(t);
    // return a + (b - a) * t;
    return 255;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final (source, target) = _findMorph();
    // if (localInterpolation == 0) {
    //   source.paint(context, offset);
    //   return;
    // }
    // if (localInterpolation == 1) {
    //   target.paint(context, offset);
    //   return;
    // }

    final sourceAlpha = _lerpOpacity(255, 0, localInterpolation);
    context.pushOpacity(
      offset,
      sourceAlpha.toInt(),
      // 255,
      (context, offset) {
        source.paint(context, offset);
      },
      oldLayer: layer is OpacityLayer? ? layer as OpacityLayer? : null,
    );
    final targetAlpha = _lerpOpacity(0, 255, localInterpolation);
    context.pushOpacity(
      offset,
      targetAlpha.toInt(),
      // 255,
      (context, offset) {
        target.paint(context, offset);
      },
      oldLayer: layer is OpacityLayer? ? layer as OpacityLayer? : null,
    );
  }

  void visitActiveChild(RenderObjectVisitor visitor) {
    final (source, target) = _findMorph();
    visitor(source);
    visitor(target);
  }

  bool _hitTestChild(
    RenderBox child,
    BoxHitTestResult result, {
    required Offset position,
  }) {
    final parentData = child.parentData as MorphParentData;
    return result.addWithPaintOffset(
      offset: parentData.offset,
      position: position,
      hitTest: (result, position) {
        return child.hitTest(result, position: position);
      },
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final (source, target) = _findMorph();
    if (interpolation < 0.5) {
      return _hitTestChild(source, result, position: position);
    } else {
      return _hitTestChild(target, result, position: position);
    }
  }
}

class RenderMorphed extends RenderProxyBox {
  Object? debugKey;
  Object tag;

  MorphState? directInterpolation;
  final List<MorphState> interpolation = [];

  RenderMorphed(this.tag, {this.debugKey});

  Decoration? get morphDecoration => null;
  Size? get morphSize => null;

  RenderMorph get parentMorph {
    RenderObject? parent = this.parent;
    while (parent != null) {
      if (parent is RenderMorph) {
        return parent;
      }
      parent = parent.parent;
    }
    throw StateError('RenderMorphed must have a RenderMorph parent.');
  }

  void replaceMorph(MorphState progress) {
    for (int i = 0; i < interpolation.length; i++) {
      if (interpolation[i].root == progress.root) {
        interpolation[i] = progress;
        return;
      }
    }
    interpolation.add(progress);
  }

  bool findMorph(
    RenderMorph root,
    RenderObject candidate,
    MorphPath path,
    bool isSource,
  ) {
    if (candidate is RenderMorph) {
      final (source, target) = candidate._findMorph();
      final sourcePath = SimpleMorphPath(object: candidate);
      final foundSource = findMorph(root, source, sourcePath, isSource);
      final targetPath = SimpleMorphPath(object: candidate);
      final foundTarget = findMorph(root, target, targetPath, isSource);
      if (foundSource || foundTarget) {
        final morphingPath = MorphingMorphPath(
          object: candidate,
          source: sourcePath.next,
          target: targetPath.next,
          interpolation: candidate.localInterpolation,
          isSource: isSource,
        );
        path.next = morphingPath;
        return true;
      }
      return false;
    }
    if (candidate is RenderMorphed) {
      if (candidate.tag == tag) {
        final candidatePath = SimpleMorphPath(object: candidate);
        path.next = candidatePath;
        return true;
      }
    }
    bool found = false;
    candidate.visitChildren((child) {
      if (found) return; // don't waste
      final candidatePath = SimpleMorphPath(object: candidate);
      final result = findMorph(root, child, candidatePath, isSource);
      if (!found && result) {
        found = true;
        path.next = candidatePath;
      }
    });
    return found;
  }

  Matrix4 get computeMorphTransform {
    var transform = Matrix4.identity();
    for (final entry in interpolation) {
      Matrix4 result;
      final upperTransform = Matrix4.identity();
      _apply(entry.parentPath, upperTransform);
      final lookUpTransform = Matrix4.identity();
      entry.path.applyTransform(entry.root, lookUpTransform);
      if (entry.isSource) {
        result = _lerpMatrix(
          // Matrix4.identity(),
          transform,
          // entry.targetTransform,
          Matrix4.inverted(upperTransform) * lookUpTransform,
          entry.root.localInterpolation,
        );
      } else {
        result = _lerpMatrix(
          // entry.targetTransform,
          Matrix4.inverted(upperTransform) * lookUpTransform,
          // Matrix4.identity(),
          transform,
          entry.root.localInterpolation,
        );
      }
      // transform.multiply(result);
      transform = result;
    }
    return transform;
  }

  @override
  bool get alwaysNeedsCompositing => true;

  void transformedPaint(
    PaintingContext context,
    Offset offset,
    void Function(PaintingContext context, Offset offset) paint,
  ) {
    final Matrix4 transform = computeMorphTransform;
    final double det = transform.determinant();
    if (det == 0 || !det.isFinite) {
      layer = null;
      return;
    }
    layer = context.pushTransform(
      true,
      offset,
      transform,
      (context, offset) {
        paint(context, offset);
      },
      oldLayer: layer is TransformLayer? ? layer as TransformLayer? : null,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    transformedPaint(context, offset, (context, offset) {
      super.paint(context, offset);
    });
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    transform.multiply(computeMorphTransform);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null) {
      visitor(child!);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) {
      return false;
    }
    return result.addWithPaintTransform(
      transform: computeMorphTransform,
      position: position,
      hitTest: (result, position) {
        return child!.hitTest(result, position: position);
      },
    );
  }

  void disposeMorph(RenderMorph source) {
    interpolation.removeWhere((p) => p.root == source);
  }

  void clearMorphs() {
    interpolation.clear();
  }
}

class RenderMorphedDecoratedBox extends RenderMorphed {
  Decoration decoration;
  Clip clipBehavior;
  TextDirection textDirection;

  RenderMorphedDecoratedBox({
    required Object tag,
    required this.decoration,
    required this.clipBehavior,
    required this.textDirection,
    super.debugKey,
  }) : super(tag);

  BoxPainter? _boxPainter;

  @override
  Decoration? get morphDecoration => decoration;

  @override
  Size? get morphSize => size;

  Decoration get morphedDecoration {
    Decoration morphedDecoration = decoration;
    for (final entry in interpolation) {
      if (entry.isSource) {
        final result = entry.targetDecoration;
        morphedDecoration = Decoration.lerp(
          morphedDecoration,
          result,
          entry.root.localInterpolation,
        )!;
      } else {
        final result = entry.sourceDecoration;
        morphedDecoration = Decoration.lerp(
          result,
          morphedDecoration,
          entry.root.localInterpolation,
        )!;
      }
    }
    return morphedDecoration;
  }

  @override
  void dispose() {
    _boxPainter?.dispose();
    super.dispose();
  }

  @override
  void detach() {
    _boxPainter?.dispose();
    super.detach();
  }

  Size get morphedSize {
    var size = this.size;
    for (final entry in interpolation) {
      if (entry.isSource) {
        final result = entry.path.applySize(entry.current.tag);
        size = Size.lerp(size, result, entry.root.localInterpolation)!;
      } else if (entry.isTarget) {
        final result = entry.path.applySize(entry.current.tag);
        size = Size.lerp(result, size, entry.root.localInterpolation)!;
      }
    }
    return size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _boxPainter?.dispose();
    final decoration = morphedDecoration;
    _boxPainter = decoration.createBoxPainter(markNeedsPaint);
    transformedPaint(context, offset, (context, offset) {
      _boxPainter!.paint(
        context.canvas,
        offset,
        ImageConfiguration(size: morphedSize, textDirection: textDirection),
      );
      if (child == null) {
        return;
      }
      if (clipBehavior != Clip.none) {
        BorderRadius? borderRadius;
        if (decoration is BoxDecoration) {
          borderRadius = decoration.borderRadius?.resolve(textDirection);
        }
        if (borderRadius != null) {
          final rRect = borderRadius.toRRect(Offset.zero & morphedSize);
          layer = context.pushClipRRect(
            needsCompositing,
            offset,
            rRect.outerRect,
            rRect,
            (context, offset) {
              child!.paint(context, offset);
            },
            clipBehavior: clipBehavior,
            oldLayer: layer is ClipRRectLayer?
                ? layer as ClipRRectLayer?
                : null,
          );
        } else {
          layer = context.pushClipRect(
            needsCompositing,
            offset,
            Offset.zero & morphedSize,
            (context, offset) {
              child!.paint(context, offset);
            },
            clipBehavior: clipBehavior,
            oldLayer: layer is ClipRectLayer? ? layer as ClipRectLayer? : null,
          );
        }
      } else {
        child!.paint(context, offset);
      }
    });
    if (decoration.isComplex) {
      context.setIsComplexHint();
    }
  }
}

extension _MatrixExtension on Matrix4 {
  Matrix4 get invertedCopy {
    return Matrix4.inverted(this);
  }
}

String debugMatrix(Matrix4 matrix) {
  var translateTest = Offset.zero;
  translateTest = MatrixUtils.transformPoint(matrix, translateTest);
  var rotationTest1 = Offset.zero;
  var rotationTest2 = Offset(100, 100);
  var beforeRotation = (rotationTest2 - rotationTest1).direction;
  beforeRotation = beforeRotation * (180 / pi); // change to degrees
  // would have 45 degrees rotation
  rotationTest1 = MatrixUtils.transformPoint(matrix, rotationTest1);
  rotationTest2 = MatrixUtils.transformPoint(matrix, rotationTest2);
  var rotation = (rotationTest2 - rotationTest1).direction;
  // change to degrees
  rotation = rotation * (180 / pi);
  rotation = rotation - beforeRotation;
  List<String> debug = [];
  if (translateTest != Offset.zero) {
    debug.add(
      't(${translateTest.dx.toStringAsFixed(2)}, ${translateTest.dy.toStringAsFixed(2)})',
    );
  }
  if (rotation != 0) {
    debug.add('r(${rotation.toStringAsFixed(2)})');
  }
  return debug.isEmpty ? 'Matrix4.identity()' : 'Matrix4(${debug.join(', ')})';
}

String _debugPrintPath(_Linked<RenderObject> currentPath) {
  final buffer = StringBuffer();
  _Linked<RenderObject>? path = currentPath;
  while (path != null) {
    buffer.write('${_debugRenderObject(path.current)} -> ');
    path = path.previous;
  }
  return buffer.toString();
}

String _debugRenderObject(RenderObject object) {
  if (object is RenderMorph) {
    return 'RenderMorph(${object.debugKey}, interpolation: ${object.interpolation})';
  } else if (object is RenderMorphed) {
    return 'RenderMorphed(${object.tag}, debugKey: ${object.debugKey})';
  } else if (object is RenderTransform) {
    Matrix4 transform = Matrix4.identity();
    object.applyPaintTransform(object, transform);
    return 'RenderTransform(${debugMatrix(transform)})';
  } else {
    return object.runtimeType.toString();
  }
}

String _debugMorphPath(MorphPath? path) {
  if (path == null) {
    return 'null';
  }
  if (path is MorphingMorphPath) {
    return _debugMorphMorphingPath(path);
  }
  final buffer = StringBuffer();
  buffer.write(_debugRenderObject(path.object));
  if (path.next != null) {
    buffer.write(' -> ');
    buffer.write(_debugMorphPath(path.next!));
  }
  return buffer.toString();
}

String _debugMorphMorphingPath(MorphingMorphPath path) {
  final buffer = StringBuffer();
  buffer.write(_debugRenderObject(path.object));
  buffer.write(
    ' (source: ${_debugMorphPath(path.source)}, target: ${_debugMorphPath(path.target)}, interpolation: ${path.interpolation}, isSource: ${path.isSource})',
  );
  return buffer.toString();
}

void _apply(_Linked<RenderObject> currentPath, Matrix4 matrix) {
  final parentPath = currentPath.previous;
  if (parentPath != null) {
    _apply(parentPath, matrix);
    if (parentPath.current is! RenderMorphed) {
      parentPath.current.applyPaintTransform(currentPath.current, matrix);
    }
  }
}
