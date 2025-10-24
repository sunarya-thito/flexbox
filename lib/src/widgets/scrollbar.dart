import 'dart:math';

import 'package:data_widget/data_widget.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flexiblebox/src/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScrollTrackGesture extends StatelessWidget {
  final Widget? child;
  final Duration jumpDuration;
  final Curve jumpCurve;

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
}

class ScrollThumbGesture extends StatelessWidget {
  final Widget child;
  final ValueChanged<bool>? isDraggingChanged;

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
}

class ScrollTrack extends StatelessWidget {
  final Widget child;
  final Duration jumpDuration;
  final Curve jumpCurve;
  final ValueChanged<bool>? isDraggingChanged;

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
}

class DefaultScrollbar extends StatefulWidget {
  final double minThumbLength;
  final Decoration thumbDecoration;
  final Decoration trackDecoration;
  final Decoration thumbActiveDecoration;
  final Decoration trackActiveDecoration;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Duration fadeDuration;
  final Duration jumpDuration;
  final Curve jumpCurve;

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

abstract class ScrollbarHandler implements Listenable {
  Axis get scrollDirection;
  double get scrollProgress;
  double get scroll;
  set scrollProgress(double value);
  void setScrollProgress(double value, Duration duration, Curve curve);
  double get maxScroll;
  double get contentSize;
  double get viewportSize;
  bool get shouldShowScrollbar => contentSize > viewportSize;

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

class Scrollbars extends StatefulWidget {
  final Widget verticalScrollbar;
  final Widget horizontalScrollbar;
  final Widget corner;
  final Widget child;
  final bool verticalScrollbarPadsContent;
  final bool horizontalScrollbarPadsContent;
  final double verticalScrollbarThickness;
  final double horizontalScrollbarThickness;

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
