import 'package:data_widget/data_widget.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef WidgetInterpolator<T extends Widget> =
    Widget Function(
      T from,
      T to,
      double t,
    );

class HeroData<T extends Widget> extends StatelessWidget {
  final T child;
  final WidgetInterpolator<T> interpolator;
  const HeroData({
    super.key,
    required this.child,
    required this.interpolator,
  });

  @override
  Widget build(BuildContext context) {
    final activeHero = Data.maybeOf<ActiveHero>(context);
    if (activeHero != null) {
      return ListenableBuilder(
        listenable: activeHero.progress,
        builder: (context, _) {
          final sourceTree = activeHero.sourceTreeData;
          final targetTree = activeHero.targetTreeData;

          if (targetTree != null) {
            // Find nodes with data of type T in both trees
            final sourceNode = TreeData.findNodeByType<T>(sourceTree);
            final targetNode = TreeData.findNodeByType<T>(targetTree);

            if (sourceNode != null && targetNode != null) {
              final sourceData = sourceNode.data as T;
              final targetData = targetNode.data as T;

              final t = activeHero.progress.value;
              final interpolated = interpolator(sourceData, targetData, t);
              sourceNode.intermediateData = interpolated;
              return interpolated;
            }
          }
          return SizedBox.shrink();
        },
      );
    }
    return TreeDataWidget(data: child, child: child);
  }
}

class TreeData {
  TreeData? parent;
  final Element element;
  Object? data;
  Object? pairData;
  Object? intermediateData;
  final Map<Object?, TreeData> children = {};
  TreeData({
    required this.element,
    required this.data,
  });

  /// Pairs this tree with another tree, matching nodes by their slot structure.
  /// Sets [pairData] on each node to the corresponding [data] from the other tree.
  void pairWith(TreeData other) {
    // Pair the current nodes
    pairData = other.data;
    other.pairData = data;

    // Recursively pair children that exist in both trees
    for (final entry in children.entries) {
      final slot = entry.key;
      final child = entry.value;
      final otherChild = other.children[slot];
      if (otherChild != null) {
        child.pairWith(otherChild);
      }
    }
  }

  void pause() {
    if (intermediateData != null) {
      data = intermediateData;
    }
    for (final child in children.values) {
      child.pause();
    }
  }

  String toDeepString([int indent = 0, String? prefix]) {
    final buffer = StringBuffer();
    final indentStr = '  ' * indent;
    buffer.writeln(
      prefix == null
          ? '$indentStr- ${data.runtimeType} (${data.toString()})'
          : '$indentStr- $prefix: ${data.runtimeType} (${data.toString()})',
    );
    for (final entry in children.entries) {
      buffer.write(
        entry.value.toDeepString(indent + 1, 'Slot(${entry.key})'),
      );
    }
    return buffer.toString();
  }

  static TreeData scan(Element element) {
    final data = TreeData(
      element: element,
      data:
          element is SingleChildRenderObjectElement &&
              element.renderObject is RenderTreeData
          ? (element.renderObject as RenderTreeData).data
          : null,
    );
    element.visitChildren((child) {
      final childData = TreeData.scan(child);
      childData.parent = data;
      data.children[child.slot] = childData;
    });
    return data;
  }

  /// Finds a node in the tree that corresponds to the given element.
  static TreeData? findNode(TreeData root, Element target) {
    // Check if this node matches
    if (root.element == target) {
      return root;
    }

    // Recursively search children
    for (final child in root.children.values) {
      final found = findNode(child, target);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  /// Finds a node in the tree by following a slot path from the root.
  /// The path should be a list of slots from root to target (first element is skipped as it's the root's slot).
  static TreeData? findNodeByPath(TreeData root, List<Object?> path) {
    TreeData? current = root;
    // Skip the first slot (root's own slot) and traverse
    for (int i = 1; i < path.length && current != null; i++) {
      current = current.children[path[i]];
    }
    return current;
  }

  /// Finds the first node in the tree whose data is of type T.
  static TreeData? findNodeByType<T>(TreeData root) {
    if (root.data is T) {
      return root;
    }
    for (final child in root.children.values) {
      final found = findNodeByType<T>(child);
      if (found != null) {
        return found;
      }
    }
    return null;
  }
}

class TreeDataWidget extends SingleChildRenderObjectWidget {
  final Object? data;
  const TreeDataWidget({
    super.key,
    required this.data,
    Widget? child,
  }) : super(child: child);

  @override
  RenderTreeData createRenderObject(BuildContext context) {
    return RenderTreeData(
      data: data,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTreeData renderObject) {
    renderObject.data = data;
  }
}

class RenderTreeData extends RenderProxyBox {
  Object? data;
  RenderTreeData({
    required this.data,
    RenderBox? child,
  }) : super(child);
}
