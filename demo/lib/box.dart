import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Color _randomPastelColor(int hash) {
  return Colors.primaries[(hash + 4) % Colors.primaries.length];
}

class Box extends StatefulWidget {
  final int number;
  final Widget? child;

  const Box(this.number, {super.key, this.child});
  const Box.parent({super.key, this.child}) : number = 0;

  @override
  State<Box> createState() => _BoxState();
}

class _BoxState extends State<Box> {
  Size? _lastSize;
  bool showSize = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      onEnter: (_) {
        setState(() {
          showSize = true;
        });
      },
      onExit: (_) {
        setState(() {
          showSize = false;
        });
      },
      child: _LayoutReporter(
        onLayout: (size) {
          _lastSize = size;
        },
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            Container(
              alignment: widget.child == null ? Alignment.center : null,
              decoration: BoxDecoration(
                color: _randomPastelColor(widget.number),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                child:
                    widget.child ??
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        '${widget.number}',
                      ),
                    ),
              ),
            ),
            Positioned(
              top: widget.child == null ? 4 : null,
              left: widget.child == null ? 4 : null,
              bottom: widget.child != null ? 4 : null,
              right: widget.child != null ? 4 : null,
              child: AnimatedOpacity(
                opacity: showSize && _lastSize != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Builder(
                    builder: (context) {
                      return Text(
                        (_lastSize != null
                                ? '${_lastSize!.width.toStringAsFixed(0)} x ${_lastSize!.height.toStringAsFixed(0)}'
                                : 'Size unknown') +
                            (widget.child != null ? ' (parent)' : ''),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutReporter extends SingleChildRenderObjectWidget {
  final void Function(Size size) onLayout;

  const _LayoutReporter({
    required this.onLayout,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLayoutReporter(onLayout);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderLayoutReporter renderObject,
  ) {
    renderObject.onLayout = onLayout;
  }
}

class _RenderLayoutReporter extends RenderProxyBox {
  void Function(Size size) onLayout;

  _RenderLayoutReporter(this.onLayout);

  @override
  void performLayout() {
    super.performLayout();
    onLayout(size);
  }
}
