import 'dart:math';
import 'dart:ui';

import 'package:demo/case.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/material.dart';

class CaseHero extends TestCase {
  final ValueNotifier<bool> _switch = ValueNotifier<bool>(true);

  Container lerp(Container a, Container b, double t) {
    final lerpedWidth = lerpDouble(
      a.constraints?.maxWidth,
      b.constraints?.maxWidth,
      t,
    );
    final lerpedHeight = lerpDouble(
      a.constraints?.maxHeight,
      b.constraints?.maxHeight,
      t,
    );
    final lerpedDecoration = Decoration.lerp(
      a.decoration,
      b.decoration,
      t,
    );
    final lerpedColor = Color.lerp(
      a.color,
      b.color,
      t,
    );
    return Container(
      width: lerpedWidth,
      height: lerpedHeight,
      decoration: lerpedDecoration,
      color: lerpedColor,
    );
  }

  @override
  Widget build() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _switch.value = !_switch.value;
      },
      child: ColoredBox(
        color: Colors.blue,
        child: ListenableBuilder(
          listenable: _switch,
          builder: (context, _) {
            return HeroScope(
              child: _switch.value
                  ? Stack(
                      key: const Key('true'),
                      children: [
                        Positioned(
                          top: 30,
                          left: 30,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: LocalHero(
                              key: const Key('A'),
                              tag: 'hero',
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HeroData(
                                      interpolator: lerp,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      key: const Key('false'),
                      children: [
                        Positioned(
                          bottom: 30,
                          right: 30,
                          child: Transform.rotate(
                            angle: pi / 2,
                            child: SizedBox(
                              width: 200,
                              height: 100,
                              child: LocalHero(
                                key: const Key('B'),
                                tag: 'hero',
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      HeroData(
                                        interpolator: lerp,
                                        child: Container(
                                          width: 200,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  @override
  String get name => 'Hero';

  @override
  String get path => 'case_hero.dart';
}
