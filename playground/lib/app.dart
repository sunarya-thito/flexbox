import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:playground/config.dart';
import 'package:playground/controller.dart';
import 'package:playground/editor.dart';
import 'package:playground/templates/default.dart';
import 'package:playground/value.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  final FlexBoxController box = FlexBoxController();

  @override
  void initState() {
    super.initState();
    _initializeDefaultBox();
  }

  void _initializeDefaultBox() {
    box.applyConfiguration(defaultConfiguration);
  }

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: Icon(Icons.menu),
              onPressed: () {
                openDrawer(
                  context: context,
                  builder: (context) {
                    return Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Templates').muted.semiBold.small,
                          gap(12),
                          for (final template in flexBoxTemplates) ...[
                            GhostButton(
                              alignment: Alignment.centerLeft,
                              leading: Icon(
                                Icons.file_copy,
                              ).iconSmall().iconMutedForeground(),
                              onPressed: () {
                                box.applyConfiguration(
                                  template.configuration,
                                );
                                closeDrawer(context);
                              },
                              child: Text(template.name),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  position: OverlayPosition.left,
                );
              },
            ),
          ],
        ),
      ],
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              box.multiSelect = true;
              return KeyEventResult.handled;
            }
          } else if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              box.multiSelect = false;
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        focusNode: focusNode,
        child: Listener(
          onPointerDown: (_) {
            focusNode.requestFocus();
          },
          child: ResizablePanel(
            direction: Axis.horizontal,
            children: [
              ResizablePane.flex(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (!box.multiSelect) {
                        box.select(null);
                      }
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          fit: StackFit.passthrough,
                          children: [
                            Container(
                              color: Colors.gray,
                              child: Center(child: box.build()),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: IgnorePointer(
                                child: Text(
                                  '(${constraints.maxWidth.toInt()} x ${constraints.maxHeight.toInt()})',
                                ).muted.small,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              ResizablePane(
                initialSize: 300,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 18,
                  ),
                  child: ListenableBuilder(
                    listenable: box,
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final property in box.selectedProperties) ...[
                            Padding(
                              key: ValueKey(property),
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    spacing: 8,
                                    children: [
                                      Flexible(child: Text(property.name)),
                                      Tooltip(
                                        tooltip: TooltipContainer(
                                          child: Text(property.description),
                                        ).call,
                                        child: Icon(
                                          Icons.help_outline,
                                        ).iconSmall().iconMutedForeground(),
                                      ),
                                    ],
                                  ),
                                  gap(8),
                                  PropertyEditorField(property: property),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Generated Code'),
                                gap(8),
                                CodeSnippet(
                                  code: box.buildCode().buildCode(0),
                                  mode: 'dart',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyEditorField extends StatefulWidget {
  const PropertyEditorField({
    super.key,
    required this.property,
  });

  final Property property;

  @override
  State<PropertyEditorField> createState() => _PropertyEditorFieldState();
}

class _PropertyEditorFieldState extends State<PropertyEditorField> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KeyedSubtree(
          key: ValueKey(count),
          child: PropertyEditor.getEditor(
            widget.property.type,
          ).buildEditor(widget.property).expanded(),
        ),
        gap(8),
        IconButton.outline(
          onPressed: () {
            setState(() {
              count++;
              widget.property.reset();
            });
          },
          size: ButtonSize.small,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
