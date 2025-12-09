import 'dart:math';

import 'package:data_widget/data_widget.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flexiblebox/src/constraints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that handles gestures on the scrollbar track.
///
/// [ScrollTrackGesture] detects tap-down events on the scrollbar track and
/// animates the scroll position to the tapped location. This allows users
/// to quickly jump to different parts of the scrollable content by tapping
/// anywhere on the scrollbar track.
class ScrollTrackGesture extends StatelessWidget {
  /// Optional child widget to wrap with gesture detection.
  final Widget? child;

  /// Duration for the animated scroll jump when the track is tapped.
  final Duration jumpDuration;

  /// Animation curve for the scroll jump.
  final Curve jumpCurve;

  /// Creates a scroll track gesture handler.
  ///
  /// The [jumpDuration] and [jumpCurve] parameters control the animation
  /// when jumping to a tapped position on the track.
  const ScrollTrackGesture({
    super.key,
    required this.jumpDuration,
    required this.jumpCurve,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scrollbarHandler = ScrollbarHandler.of(context);
    return GestureDetector(
      onTapDown: (details) {
        scrollbarHandler.handleTapDown(
          context,
          details,
          jumpDuration,
          jumpCurve,
        );
      },
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('jumpDuration', jumpDuration));
    properties.add(DiagnosticsProperty<Curve>('jumpCurve', jumpCurve));
  }
}

/// A widget that handles drag gestures on the scrollbar thumb.
///
/// [ScrollThumbGesture] detects pan gestures on the scrollbar thumb and
/// updates the scroll position accordingly. It also absorbs taps to prevent
/// them from propagating to the track below.
///
/// Optionally notifies when dragging starts or stops via [isDraggingChanged].
class ScrollThumbGesture extends StatelessWidget {
  /// The child widget representing the visible scrollbar thumb.
  final Widget child;

  /// Callback invoked when dragging state changes.
  ///
  /// Called with `true` when dragging starts and `false` when it ends.
  /// Useful for showing visual feedback during dragging.
  final ValueChanged<bool>? isDraggingChanged;

  /// Creates a scroll thumb gesture handler.
  ///
  /// The [child] parameter is required and represents the scrollbar thumb widget.
  /// Optionally provide [isDraggingChanged] to respond to drag state changes.
  const ScrollThumbGesture({
    super.key,
    required this.child,
    this.isDraggingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scrollbarHandler = ScrollbarHandler.of(context);
    return GestureDetector(
      onTap: () {}, // just to absorb taps
      onPanUpdate: scrollbarHandler.handlePanUpdate,
      onPanStart: (_) {
        if (isDraggingChanged != null) {
          isDraggingChanged!(true);
        }
      },
      onPanEnd: (_) {
        if (isDraggingChanged != null) {
          isDraggingChanged!(false);
        }
      },
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<ValueChanged<bool>>.has(
        'isDraggingChanged',
        isDraggingChanged,
      ),
    );
  }
}

/// A widget that combines scrollbar track and thumb gesture handling.
///
/// [ScrollTrack] provides a complete scrollbar track with both track-tap
/// jumping and thumb dragging capabilities. It automatically sizes and
/// positions the scrollbar thumb based on the scrollable content's state.
///
/// This widget combines [ScrollTrackGesture] and [ScrollThumbGesture]
/// functionality into a single convenient widget.
class ScrollTrack extends StatelessWidget {
  /// The child widget representing the scrollbar track and thumb.
  final Widget child;

  /// Duration for animated scroll jumps when the track is tapped.
  final Duration jumpDuration;

  /// Animation curve for scroll jumps.
  final Curve jumpCurve;

  /// Callback invoked when dragging state changes.
  ///
  /// Called with `true` when thumb dragging starts and `false` when it ends.
  final ValueChanged<bool>? isDraggingChanged;

  /// Creates a scrollbar track with gesture handling.
  ///
  /// The [child] parameter is required. The [jumpDuration] and [jumpCurve]
  /// control the animation when jumping to a tapped position.
  const ScrollTrack({
    super.key,
    this.jumpDuration = const Duration(milliseconds: 200),
    this.jumpCurve = Curves.easeInOut,
    this.isDraggingChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scrollbarHandler = ScrollbarHandler.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListenableBuilder(
          listenable: scrollbarHandler,
          child: child,
          builder: (context, child) {
            if (!scrollbarHandler.shouldShowScrollbar) {
              return SizedBox.shrink();
            }
            final (
              thumbLength: thumbLength,
              thumbOffset: thumbOffset,
            ) = scrollbarHandler.computeThumbMetrics(
              switch (scrollbarHandler.scrollDirection) {
                Axis.vertical => constraints.maxHeight,
                Axis.horizontal => constraints.maxWidth,
              },
              48.0,
            );
            return Stack(
              children: [
                Positioned.fill(
                  child: ScrollTrackGesture(
                    jumpDuration: jumpDuration,
                    jumpCurve: jumpCurve,
                  ),
                ),
                Positioned(
                  left: scrollbarHandler.scrollDirection == Axis.vertical
                      ? 0.0
                      : thumbOffset,
                  top: scrollbarHandler.scrollDirection == Axis.vertical
                      ? thumbOffset
                      : 0.0,
                  width: scrollbarHandler.scrollDirection == Axis.vertical
                      ? null
                      : thumbLength,
                  height: scrollbarHandler.scrollDirection == Axis.vertical
                      ? thumbLength
                      : null,
                  right: scrollbarHandler.scrollDirection == Axis.vertical
                      ? 0.0
                      : null,
                  bottom: scrollbarHandler.scrollDirection == Axis.vertical
                      ? null
                      : 0.0,
                  child: ScrollThumbGesture(
                    isDraggingChanged: isDraggingChanged,
                    child: child!,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>('jumpDuration', jumpDuration));
    properties.add(DiagnosticsProperty<Curve>('jumpCurve', jumpCurve));
    properties.add(
      ObjectFlagProperty<ValueChanged<bool>>.has(
        'isDraggingChanged',
        isDraggingChanged,
      ),
    );
  }
}

/// A default implementation of a scrollbar with customizable appearance.
///
/// [DefaultScrollbar] provides a pre-configured scrollbar widget with reasonable
/// defaults for thumb and track appearance. It supports hover states, drag interactions,
/// and smooth animations for showing/hiding and jumping to positions.
///
/// The scrollbar automatically shows/hides based on content overflow and user interaction.
/// It can be customized via decoration properties to match any design system.
///
/// Example:
/// ```dart
/// DefaultScrollbar(
///   thumbDecoration: BoxDecoration(
///     color: Colors.blue.withOpacity(0.5),
///     borderRadius: BorderRadius.circular(8),
///   ),
///   minThumbLength: 60.0,
/// )
/// ```
class DefaultScrollbar extends StatefulWidget {
  /// Minimum length of the scrollbar thumb in pixels.
  ///
  /// Ensures the thumb remains grabbable even for very long content.
  final double minThumbLength;

  /// Decoration for the scrollbar thumb in its default state.
  final Decoration thumbDecoration;

  /// Decoration for the scrollbar track in its default state.
  final Decoration trackDecoration;

  /// Decoration for the scrollbar thumb when active (hovered or dragged).
  final Decoration thumbActiveDecoration;

  /// Decoration for the scrollbar track when active (hovered).
  final Decoration trackActiveDecoration;

  /// Margin around the entire scrollbar widget.
  ///
  /// Creates space between the scrollbar and its container edges.
  final EdgeInsetsGeometry margin;

  /// Padding inside the scrollbar track.
  ///
  /// Creates space between the track edges and the thumb.
  final EdgeInsetsGeometry padding;

  /// Duration for fade in/out animations when showing/hiding the scrollbar.
  final Duration fadeDuration;

  /// Duration for animated scroll jumps when the track is tapped.
  final Duration jumpDuration;

  /// Animation curve for scroll jumps.
  final Curve jumpCurve;

  /// Creates a default scrollbar with customizable appearance.
  ///
  /// All parameters have sensible defaults. The scrollbar will automatically
  /// style itself with semi-transparent decorations that work well in most contexts.
  const DefaultScrollbar({
    super.key,
    this.minThumbLength = 48.0,
    this.thumbDecoration = const BoxDecoration(
      color: Color.fromARGB(50, 0, 0, 0),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.thumbActiveDecoration = const BoxDecoration(
      color: Color.fromARGB(131, 0, 0, 0),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.trackDecoration = const BoxDecoration(
      color: Color.fromARGB(0, 0, 0, 0),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.trackActiveDecoration = const BoxDecoration(
      color: Color.fromARGB(0, 0, 0, 0),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.margin = const EdgeInsets.all(2.0),
    this.padding = EdgeInsets.zero,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.jumpDuration = const Duration(milliseconds: 200),
    this.jumpCurve = Curves.easeInOut,
  });

  @override
  State<DefaultScrollbar> createState() => _DefaultScrollbarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('minThumbLength', minThumbLength));
    properties.add(
      DiagnosticsProperty<Decoration>('thumbDecoration', thumbDecoration),
    );
    properties.add(
      DiagnosticsProperty<Decoration>('trackDecoration', trackDecoration),
    );
    properties.add(
      DiagnosticsProperty<Decoration>(
        'thumbActiveDecoration',
        thumbActiveDecoration,
      ),
    );
    properties.add(
      DiagnosticsProperty<Decoration>(
        'trackActiveDecoration',
        trackActiveDecoration,
      ),
    );
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(DiagnosticsProperty<Duration>('fadeDuration', fadeDuration));
    properties.add(DiagnosticsProperty<Duration>('jumpDuration', jumpDuration));
    properties.add(DiagnosticsProperty<Curve>('jumpCurve', jumpCurve));
  }
}

class _DefaultScrollbarState extends State<DefaultScrollbar> {
  bool _hovered = false;
  bool _dragging = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        onEnter: (_) {
          setState(() {
            _hovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _hovered = false;
          });
        },
        child: AnimatedContainer(
          duration: widget.fadeDuration,
          decoration: _dragging || _hovered
              ? widget.trackActiveDecoration
              : widget.trackDecoration,
          child: ScrollTrack(
            isDraggingChanged: (isDragging) {
              setState(() {
                _dragging = isDragging;
              });
            },
            jumpDuration: widget.jumpDuration,
            jumpCurve: widget.jumpCurve,
            child: AnimatedContainer(
              duration: widget.fadeDuration,
              decoration: _dragging || _hovered
                  ? widget.thumbActiveDecoration
                  : widget.thumbDecoration,
            ),
          ),
        ),
      ),
    );
  }
}

/// Abstract interface for handling scrollbar interactions and state.
///
/// Defines the contract for scrollbar behavior including scroll position tracking,
/// thumb metrics calculation, and user interaction handling (pan, tap).
abstract class ScrollbarHandler implements Listenable {
  /// The scroll direction (horizontal or vertical).
  Axis get scrollDirection;

  /// The scroll progress as a value between 0.0 and 1.0.
  double get scrollProgress;

  /// The current scroll offset in pixels.
  double get scroll;

  /// Sets the scroll progress (0.0 to 1.0) instantly.
  set scrollProgress(double value);

  /// Animates the scroll progress to [value] over [duration] with the given [curve].
  void setScrollProgress(double value, Duration duration, Curve curve);

  /// The maximum scroll offset in pixels.
  double get maxScroll;

  /// The total size of the scrollable content.
  double get contentSize;

  /// The size of the visible viewport.
  double get viewportSize;

  /// Whether the scrollbar should be visible (true if content exceeds viewport).
  bool get shouldShowScrollbar => contentSize > viewportSize;

  /// Computes the thumb length and offset for the scrollbar.
  ///
  /// Returns a record with [thumbLength] (the size of the scrollbar thumb) and
  /// [thumbOffset] (its position in the scrollbar track).
  ({double thumbLength, double thumbOffset}) computeThumbMetrics(
    double viewportSize,
    double minThumbLength,
  ) {
    final thumbLength = max(
      minThumbLength,
      (viewportSize / contentSize) * viewportSize,
    );
    final maxThumbOffset = viewportSize - thumbLength;
    final thumbOffset = scrollProgress * maxThumbOffset;
    return (thumbLength: thumbLength, thumbOffset: thumbOffset);
  }

  /// Handles pan/drag updates on the scrollbar.
  ///
  /// Updates the scroll position based on the drag delta.
  void handlePanUpdate(DragUpdateDetails details) {
    final delta = scrollDirection == Axis.vertical
        ? details.delta.dy
        : details.delta.dx;
    final maxScroll = this.maxScroll;
    if (maxScroll <= 0) {
      return;
    }
    final scrollDelta = (delta / viewportSize) * contentSize;
    final newScroll = (scroll + scrollDelta).clamp(
      0.0,
      maxScroll,
    );
    scrollProgress = newScroll / maxScroll;
  }

  /// Handles tap events on the scrollbar track.
  ///
  /// Jumps to the tapped position with animation over [jumpDuration] using [curve].
  void handleTapDown(
    BuildContext context,
    TapDownDetails details,
    Duration jumpDuration,
    Curve curve,
  ) {
    final localOffset = details.localPosition;
    final thumbOffset = scrollDirection == Axis.vertical
        ? localOffset.dy
        : localOffset.dx;
    final box = context.findRenderObject() as RenderBox;
    final boxSize = scrollDirection == Axis.vertical
        ? box.size.height
        : box.size.width;
    setScrollProgress(thumbOffset / boxSize, jumpDuration, curve);
  }

  /// Retrieves the [ScrollbarHandler] from the widget tree.
  ///
  /// Uses [Data.of] to find the nearest [ScrollbarHandler] ancestor.
  static ScrollbarHandler of(BuildContext context) {
    return Data.of(context);
  }
}

class _DelegateScrollbarHandler extends ScrollbarHandler {
  @override
  final Axis scrollDirection;
  final RenderLayoutBox renderBox;
  final Listenable listenable;

  _DelegateScrollbarHandler(
    this.renderBox,
    this.scrollDirection,
    this.listenable,
  );

  @override
  void addListener(VoidCallback listener) {
    listenable.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listenable.removeListener(listener);
  }

  @override
  void setScrollProgress(double value, Duration duration, Curve curve) {
    switch (scrollDirection) {
      case Axis.vertical:
        renderBox.setScrollProgressY(value, duration, curve);
        break;
      case Axis.horizontal:
        renderBox.setScrollProgressX(value, duration, curve);
        break;
    }
  }

  @override
  double get contentSize => scrollDirection == Axis.vertical
      ? renderBox.contentSize.height
      : renderBox.contentSize.width;

  @override
  double get viewportSize => scrollDirection == Axis.vertical
      ? renderBox.viewportSize.height
      : renderBox.viewportSize.width;

  @override
  double get scrollProgress {
    return scrollDirection == Axis.vertical
        ? renderBox.scrollProgressY
        : renderBox.scrollProgressX;
  }

  @override
  set scrollProgress(double value) {
    if (scrollDirection == Axis.vertical) {
      renderBox.scrollProgressY = value;
    } else {
      renderBox.scrollProgressX = value;
    }
  }

  @override
  double get scroll {
    return scrollDirection == Axis.vertical
        ? renderBox.scrollOffsetY
        : renderBox.scrollOffsetX;
  }

  @override
  double get maxScroll {
    return scrollDirection == Axis.vertical
        ? renderBox.maxScrollY
        : renderBox.maxScrollX;
  }

  @override
  int get hashCode => Object.hash(renderBox, scrollDirection);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is _DelegateScrollbarHandler &&
        other.renderBox == renderBox &&
        other.scrollDirection == scrollDirection;
  }
}

/// Function signature for building scrollbar widgets.
///
/// This typedef defines the signature for a builder function that creates
/// a scrollbar widget. The builder receives:
/// - [context]: The build context
/// - [constraints]: The layout constraints for the scrollbar
/// - [scrollbarHandler]: Handler for scrollbar interactions and state
///
/// Returns a widget that represents the scrollbar UI.
typedef ScrollbarWidgetBuilder =
    Widget Function(
      BuildContext context,
      BoxConstraints constraints,
      ScrollbarHandler scrollbarHandler,
    );

class _ScrollbarHandlerBuilder extends StatelessWidget {
  final ScrollbarWidgetBuilder builder;

  const _ScrollbarHandlerBuilder({
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints is BoxConstraintsWithData<ScrollbarHandler>,
          'ScrollbarBox constraints do not contain ScrollbarHandler (found $constraints instead)',
        );
        final scrollbarHandler =
            (constraints as BoxConstraintsWithData<ScrollbarHandler>).data;
        return builder(context, constraints, scrollbarHandler);
      },
    );
  }
}

/// A widget that provides scrollbars for a scrollable child.
///
/// [Scrollbars] wraps a scrollable widget and adds vertical and/or horizontal
/// scrollbars as needed. The scrollbars automatically show/hide based on content
/// overflow and provide both track-tapping and thumb-dragging interactions.
///
/// The scrollbars can be customized independently, and you can control whether
/// they pad the content (pushing it inward) or overlay it.
///
/// Example:
/// ```dart
/// Scrollbars(
///   verticalScrollbar: DefaultScrollbar(
///     thumbDecoration: BoxDecoration(color: Colors.blue),
///   ),
///   verticalScrollbarThickness: 16.0,
///   verticalScrollbarPadsContent: true,
///   child: FlexBox(
///     // Scrollable content here
///   ),
/// )
/// ```
class Scrollbars extends StatefulWidget {
  /// The scrollbar widget to use for vertical scrolling.
  ///
  /// Typically a [DefaultScrollbar] or custom implementation.
  final Widget verticalScrollbar;

  /// The scrollbar widget to use for horizontal scrolling.
  ///
  /// Typically a [DefaultScrollbar] or custom implementation.
  final Widget horizontalScrollbar;

  /// Widget to display in the corner where scrollbars meet.
  ///
  /// Only visible when both scrollbars are showing. Typically empty
  /// or a decorative element matching the scrollbar design.
  final Widget corner;

  /// The scrollable content widget.
  final Widget child;

  /// Whether the vertical scrollbar should push content inward.
  ///
  /// When true, content is padded by [verticalScrollbarThickness] to make
  /// room for the scrollbar. When false, the scrollbar overlays the content.
  final bool verticalScrollbarPadsContent;

  /// Whether the horizontal scrollbar should push content inward.
  ///
  /// When true, content is padded by [horizontalScrollbarThickness] to make
  /// room for the scrollbar. When false, the scrollbar overlays the content.
  final bool horizontalScrollbarPadsContent;

  /// Width of the vertical scrollbar in pixels.
  final double verticalScrollbarThickness;

  /// Height of the horizontal scrollbar in pixels.
  final double horizontalScrollbarThickness;

  /// Creates a widget with scrollbars for the given child.
  ///
  /// The [child] parameter is required. All other parameters have sensible
  /// defaults that provide a basic scrollbar experience.
  const Scrollbars({
    super.key,
    required this.child,
    this.corner = const SizedBox.shrink(),
    this.verticalScrollbar = const DefaultScrollbar(),
    this.horizontalScrollbar = const DefaultScrollbar(),
    this.verticalScrollbarPadsContent = false,
    this.horizontalScrollbarPadsContent = false,
    this.verticalScrollbarThickness = 12.0,
    this.horizontalScrollbarThickness = 12.0,
  });

  @override
  State<Scrollbars> createState() => _ScrollbarsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Widget>('verticalScrollbar', verticalScrollbar),
    );
    properties.add(
      DiagnosticsProperty<Widget>('horizontalScrollbar', horizontalScrollbar),
    );
    properties.add(DiagnosticsProperty<Widget>('corner', corner));
    properties.add(
      DiagnosticsProperty<bool>(
        'verticalScrollbarPadsContent',
        verticalScrollbarPadsContent,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'horizontalScrollbarPadsContent',
        horizontalScrollbarPadsContent,
      ),
    );
    properties.add(
      DoubleProperty('verticalScrollbarThickness', verticalScrollbarThickness),
    );
    properties.add(
      DoubleProperty(
        'horizontalScrollbarThickness',
        horizontalScrollbarThickness,
      ),
    );
  }
}

class _ScrollbarsNotifier with ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class _ScrollbarsState extends State<Scrollbars> {
  final _notifier = _ScrollbarsNotifier();

  @override
  void dispose() {
    super.dispose();
    _notifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) {
          _notifier.notifyListeners();
          // keep going to allow other listeners to receive this notification
        }
        return false;
      },
      child: _ScrollbarBox(
        verticalScrollbarPadsContent: widget.verticalScrollbarPadsContent,
        horizontalScrollbarPadsContent: widget.horizontalScrollbarPadsContent,
        horizontalScrollbarThickness: widget.horizontalScrollbarThickness,
        verticalScrollbarThickness: widget.verticalScrollbarThickness,
        listenable: _notifier,
        textDirection: Directionality.of(context),
        children: [
          widget.child,
          _wrapData(widget.verticalScrollbar, Axis.vertical),
          _wrapData(widget.horizontalScrollbar, Axis.horizontal),
          widget.corner,
        ],
      ),
    );
  }

  Widget _wrapData(Widget child, Axis axis) {
    return _ScrollbarHandlerBuilder(
      builder: (context, constraints, scrollbarHandler) {
        return Data<ScrollbarHandler>.inherit(
          data: scrollbarHandler,
          child: child,
        );
      },
    );
  }
}

class _ScrollbarBox extends MultiChildRenderObjectWidget {
  final bool verticalScrollbarPadsContent;
  final bool horizontalScrollbarPadsContent;
  final double horizontalScrollbarThickness;
  final double verticalScrollbarThickness;
  final TextDirection textDirection;
  final Listenable listenable;

  const _ScrollbarBox({
    required super.children,
    required this.verticalScrollbarPadsContent,
    required this.horizontalScrollbarPadsContent,
    required this.horizontalScrollbarThickness,
    required this.verticalScrollbarThickness,
    required this.textDirection,
    required this.listenable,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderScrollbarBox(
      verticalScrollbarPadsContent: verticalScrollbarPadsContent,
      horizontalScrollbarPadsContent: horizontalScrollbarPadsContent,
      horizontalScrollbarThickness: horizontalScrollbarThickness,
      verticalScrollbarThickness: verticalScrollbarThickness,
      textDirection: textDirection,
      listenable: listenable,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderScrollbarBox renderObject,
  ) {
    bool needsLayout = false;
    if (renderObject.verticalScrollbarPadsContent !=
        verticalScrollbarPadsContent) {
      renderObject.verticalScrollbarPadsContent = verticalScrollbarPadsContent;
      needsLayout = true;
    }
    if (renderObject.horizontalScrollbarPadsContent !=
        horizontalScrollbarPadsContent) {
      renderObject.horizontalScrollbarPadsContent =
          horizontalScrollbarPadsContent;
      needsLayout = true;
    }
    if (renderObject.textDirection != textDirection) {
      renderObject.textDirection = textDirection;
      needsLayout = true;
    }
    if (renderObject.horizontalScrollbarThickness !=
        horizontalScrollbarThickness) {
      renderObject.horizontalScrollbarThickness = horizontalScrollbarThickness;
      needsLayout = true;
    }
    if (renderObject.verticalScrollbarThickness != verticalScrollbarThickness) {
      renderObject.verticalScrollbarThickness = verticalScrollbarThickness;
      needsLayout = true;
    }
    if (renderObject.listenable != listenable) {
      renderObject.listenable = listenable;
      needsLayout = true;
    }
    if (needsLayout) {
      renderObject.markNeedsLayout();
    }
  }
}

class _ScrollbarBoxParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderScrollbarBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ScrollbarBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ScrollbarBoxParentData> {
  bool verticalScrollbarPadsContent;
  bool horizontalScrollbarPadsContent;
  TextDirection textDirection;
  double horizontalScrollbarThickness;
  double verticalScrollbarThickness;
  Listenable listenable;
  _RenderScrollbarBox({
    required this.verticalScrollbarPadsContent,
    required this.horizontalScrollbarPadsContent,
    required this.textDirection,
    required this.horizontalScrollbarThickness,
    required this.verticalScrollbarThickness,
    required this.listenable,
  });

  // order is:
  // 1. the content (RenderLayoutBox)
  // 2. the vertical scrollbar (RenderBox)
  // 3. the horizontal scrollbar (RenderBox)
  // 4. the corner (RenderBox) -

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ScrollbarBoxParentData) {
      child.parentData = _ScrollbarBoxParentData();
    }
  }

  RenderLayoutBox _findLayoutBox(RenderBox box) {
    int maxDepthSearch = 15;
    RenderObject? current = box;
    while (current != null && maxDepthSearch > 0) {
      if (current is RenderLayoutBox) {
        return current;
      }
      current = _firstDepthChild(current);
      maxDepthSearch--;
    }
    throw FlutterError(
      'ScrollbarBox child does not contain a RenderLayoutBox (found $current instead)',
    );
  }

  RenderObject? _firstDepthChild(RenderObject? box) {
    RenderObject? child;
    box?.visitChildren((c) {
      child ??= c;
    });
    return child;
  }

  @override
  void performLayout() {
    final contentBox = firstChild!;
    final verticalScrollbar = childAfter(contentBox)!;
    final horizontalScrollbar = childAfter(verticalScrollbar)!;
    final cornerBox = childAfter(horizontalScrollbar)!;
    final layoutBox = _findLayoutBox(contentBox);

    // note: content must be laid out first!
    contentBox.layout(
      constraints.deflate(
        EdgeInsets.only(
          right: verticalScrollbarPadsContent
              ? verticalScrollbarThickness
              : 0.0,
          bottom: horizontalScrollbarPadsContent
              ? horizontalScrollbarThickness
              : 0.0,
        ),
      ),
      parentUsesSize: true,
    );
    final shouldShowVerticalScrollbar =
        layoutBox.contentSize.height > layoutBox.viewportSize.height;
    final shouldShowHorizontalScrollbar =
        layoutBox.contentSize.width > layoutBox.viewportSize.width;

    final contentSize = contentBox.size;
    verticalScrollbar.layout(
      BoxConstraintsWithData<ScrollbarHandler>.fromConstraints(
        shouldShowHorizontalScrollbar
            ? BoxConstraints.tightFor(
                width: verticalScrollbarThickness,
                height: max(
                  0,
                  contentSize.height - horizontalScrollbarThickness,
                ),
              )
            : BoxConstraints.tightFor(
                width: verticalScrollbarThickness,
                height: contentSize.height,
              ),
        data: _DelegateScrollbarHandler(layoutBox, Axis.vertical, listenable),
      ),
      parentUsesSize: true,
    );
    horizontalScrollbar.layout(
      BoxConstraintsWithData<ScrollbarHandler>.fromConstraints(
        shouldShowVerticalScrollbar
            ? BoxConstraints.tightFor(
                width: max(contentSize.width - verticalScrollbarThickness, 0),
                height: horizontalScrollbarThickness,
              )
            : BoxConstraints.tightFor(
                width: contentSize.width,
                height: horizontalScrollbarThickness,
              ),
        data: _DelegateScrollbarHandler(layoutBox, Axis.horizontal, listenable),
      ),
      parentUsesSize: true,
    );

    cornerBox.layout(
      BoxConstraints.tightFor(
        width: verticalScrollbarThickness,
        height: horizontalScrollbarThickness,
      ),
      parentUsesSize: true,
    );
    size = Size(
      contentBox.size.width +
          (verticalScrollbarPadsContent ? verticalScrollbarThickness : 0.0),
      contentBox.size.height +
          (horizontalScrollbarPadsContent ? horizontalScrollbarThickness : 0.0),
    );
    final verticalScrollbarParentData =
        verticalScrollbar.parentData as _ScrollbarBoxParentData;
    switch (textDirection) {
      case TextDirection.ltr:
        verticalScrollbarParentData.offset = Offset(
          size.width - verticalScrollbarThickness,
          0.0,
        );
        break;
      case TextDirection.rtl:
        verticalScrollbarParentData.offset = Offset.zero;
        break;
    }
    final horizontalScrollbarParentData =
        horizontalScrollbar.parentData as _ScrollbarBoxParentData;
    horizontalScrollbarParentData.offset = Offset(
      0.0,
      size.height - horizontalScrollbarThickness,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
