import 'package:data_widget/data_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds a widget with a [RepaintManager].
///
/// This callback is used to construct widgets that need access to a [RepaintManager],
/// typically for custom repaint logic or synchronization.
///
/// Example:
/// ```dart
/// RepaintForwarder(
///   builder: (context, manager) {
///     return Container();
///   },
/// )
/// ```
///
/// - [context]: The build context in which the widget is built.
/// - [painter]: The [RepaintManager] instance for managing repaint notifications.
typedef WidgetRepainterCallback =
    Widget Function(BuildContext context, RepaintManager painter);

/// A widget that triggers a callback when a repaint is needed.
///
/// Wrap any widget with [RepaintCallback] to be notified when its render object
/// needs to repaint. Useful for custom repaint logic or debugging.
///
/// Example:
/// ```dart
/// RepaintCallback(
///   onRepaintNeeded: () {
///     print('Repaint needed!');
///   },
///   child: Container(),
/// )
/// ```
///
/// Parameters:
/// - [onRepaintNeeded]: Callback invoked when a repaint is required.
/// - [child]: The widget subtree to wrap.
class RepaintCallback extends SingleChildRenderObjectWidget {
  /// Callback invoked when a repaint is required.
  final ValueChanged<RenderBox> onRepaintNeeded;

  /// Creates a [RepaintCallback] widget.
  const RepaintCallback({
    super.key,
    required this.onRepaintNeeded,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RepaintCallbackRenderObject(onRepaintNeeded);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RepaintCallbackRenderObject renderObject,
  ) {
    renderObject.onRepaintNeeded = onRepaintNeeded;
  }
}

/// Render object for [RepaintCallback] that calls a callback when repaint is needed.
///
/// This render object overrides [markNeedsPaint] to notify the provided callback.
class RepaintCallbackRenderObject extends RenderProxyBox {
  /// Callback invoked when a repaint is required.
  ValueChanged<RenderBox> onRepaintNeeded;

  /// Creates a [RepaintCallbackRenderObject].
  ///
  /// - [onRepaintNeeded]: Callback to invoke when repaint is needed.
  RepaintCallbackRenderObject(this.onRepaintNeeded);

  @override
  void markNeedsPaint() {
    super.markNeedsPaint();
    onRepaintNeeded(this);
  }
}

/// A widget that forwards repaint notifications to its builder.
///
/// [RepaintForwarder] provides a [RepaintManager] to its builder, allowing widgets
/// to listen for repaint events and trigger UI updates accordingly.
///
/// Example:
/// ```dart
/// RepaintForwarder(
///   builder: (context, manager) {
///     return AnimatedBuilder(
///       animation: manager,
///       builder: (context, _) => Container(),
///     );
///   },
/// )
/// ```
///
/// Parameters:
/// - [builder]: Function that builds a widget with the provided [RepaintManager].
class RepaintForwarder extends StatefulWidget {
  /// Function that builds a widget with the provided [RepaintManager].
  final WidgetRepainterCallback builder;

  /// Creates a [RepaintForwarder] widget.
  const RepaintForwarder({super.key, required this.builder});

  @override
  State<RepaintForwarder> createState() => _RepaintForwarderState();
}

/// State for [RepaintForwarder] that implements [RepaintManager].
///
/// This state object notifies listeners when a repaint is needed.
class _RepaintForwarderState extends State<RepaintForwarder>
    with ChangeNotifier
    implements RepaintManager {
  RenderBox? _renderBox;
  @override
  Rect get paintBounds => _renderBox?.paintBounds ?? Rect.zero;

  @override
  Matrix4 computeTransform(RenderObject target) {
    return _renderBox?.getTransformTo(target) ?? Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Data<RepaintManager>.inherit(
      data: this,
      child: RepaintCallback(
        onRepaintNeeded: (renderBox) {
          _renderBox = renderBox;
          markNeedsRepaint();
        },
        child: widget.builder(context, this),
      ),
    );
  }

  /// Marks that a repaint is needed and notifies listeners.
  ///
  /// Call this to trigger a repaint for widgets listening to this manager.
  @override
  void markNeedsRepaint() {
    notifyListeners();
  }
}

/// Interface for managing repaint notifications.
///
/// [RepaintManager] allows widgets to listen for repaint events and trigger UI updates.
///
/// Example:
/// ```dart
/// final manager = RepaintManager.of(context);
/// manager.markNeedsRepaint();
/// ```
abstract interface class RepaintManager implements Listenable {
  /// The bounds of the area that needs to be repainted.
  Rect get paintBounds;

  /// Computes the transform matrix for the given [RenderObject].
  ///
  /// - [target]: The render object to compute the transform for.
  Matrix4 computeTransform(RenderObject target);

  /// Gets the [RepaintManager] from the given [BuildContext].
  ///
  /// - [context]: The build context to retrieve the manager from.
  static RepaintManager of(BuildContext context) {
    return Data.of<RepaintManager>(context);
  }

  /// Marks that a repaint is needed.
  void markNeedsRepaint();
}

/// A widget that synchronizes repaint notifications with a [RepaintManager].
///
/// [RepaintSynchronizer] listens to a [RepaintManager] and triggers repaint for its child
/// when the manager notifies listeners.
///
/// Example:
/// ```dart
/// RepaintSynchronizer(
///   repaintManager: manager,
///   child: Container(),
/// )
/// ```
///
/// Parameters:
/// - [repaintManager]: The [RepaintManager] to synchronize with.
/// - [child]: The widget subtree to wrap.
class RepaintSynchronizer extends SingleChildRenderObjectWidget {
  /// The [RepaintManager] to synchronize with.
  final RepaintManager repaintManager;

  /// Creates a [RepaintSynchronizer] widget.
  const RepaintSynchronizer({
    super.key,
    required this.repaintManager,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RepaintSynchronizerRenderObject(repaintManager);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RepaintSynchronizerRenderObject renderObject,
  ) {
    renderObject.repaintManager = repaintManager;
  }
}

/// Render object for [RepaintSynchronizer] that listens to a [RepaintManager].
///
/// This render object attaches and detaches listeners to the [RepaintManager]
/// to trigger repaints when notified.
class RepaintSynchronizerRenderObject extends RenderProxyBox {
  /// The [RepaintManager] being synchronized.
  RepaintManager _repaintManager;

  /// Creates a [RepaintSynchronizerRenderObject].
  ///
  /// - [repaintManager]: The manager to listen to for repaint events.
  RepaintSynchronizerRenderObject(this._repaintManager);

  /// The [RepaintManager] being synchronized.
  RepaintManager get repaintManager => _repaintManager;
  set repaintManager(RepaintManager value) {
    if (_repaintManager != value) {
      _repaintManager.removeListener(markNeedsPaint);
      _repaintManager = value;
      _repaintManager.addListener(markNeedsPaint);
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    repaintManager.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    repaintManager.removeListener(markNeedsPaint);
    super.detach();
  }
}
