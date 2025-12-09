import 'package:data_widget/data_widget.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class ActiveHero {
  RenderHero? target;
  TreeData sourceTreeData;
  WidgetShape currentShape;
  Duration? startTime;
  ValueNotifier<double> progress = ValueNotifier(0.0);
  WidgetShape? intermediateShape;
  HeroFlightState? flightState;
  TreeData? targetTreeData;
  ActiveHero({
    required this.currentShape,
    required this.sourceTreeData,
  });
}

class HeroScope extends StatefulWidget {
  final Widget child;
  const HeroScope({super.key, required this.child});

  @override
  State<HeroScope> createState() => _HeroScopeState();
}

class HeroFlight extends StatefulWidget {
  final ActiveHero activeHero;
  const HeroFlight({super.key, required this.activeHero});

  @override
  State<HeroFlight> createState() => HeroFlightState();
}

class HeroFlightState extends State<HeroFlight> {
  @override
  void initState() {
    super.initState();
    widget.activeHero.flightState = this;
  }

  @override
  void dispose() {
    widget.activeHero.flightState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.topLeft,
      transform: widget.activeHero.intermediateShape!.transform,
      child: SizedBox.fromSize(
        size: widget.activeHero.intermediateShape!.size,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Data<ActiveHero>.inherit(
                data: widget.activeHero,
                child: widget.activeHero.target!.widget,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroScopeState extends State<HeroScope>
    with SingleTickerProviderStateMixin
    implements HeroLayer {
  final Map<Object, ActiveHero> _active = {};
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    Set<Object> toRemove = {};
    for (final entry in _active.entries) {
      final hero = entry.value;
      if (hero.target == null) {
        // remove heroes without target
        toRemove.add(entry.key);
        continue;
      }
      hero.startTime ??= elapsed;
      final duration = hero.target!.duration;
      final curve = hero.target!.curve;
      final progress = curve.transform(
        ((elapsed - hero.startTime!).inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0),
      );
      hero.progress.value = progress;
      final currentShape = hero.currentShape;
      final targetShape = hero.target!.shape!;
      hero.intermediateShape = WidgetShape.lerp(
        currentShape,
        targetShape,
        progress,
      );
      if (progress >= 1.0) {
        // animation complete
        hero.target!.claimed = null;
        toRemove.add(entry.key);
      }
    }
    for (final key in toRemove) {
      _active.remove(key);
    }
    setState(() {});
  }

  @override
  void push(RenderHero hero) {
    if (_active.containsKey(hero.tag)) {
      return;
    }
    _active[hero.tag] = ActiveHero(
      currentShape: hero.shape!,
      sourceTreeData: TreeData.scan(hero.element),
    );
  }

  @override
  void claim(RenderHero hero) {
    final active = _active[hero.tag];
    if (active != null) {
      final previousTarget = active.target;
      if (previousTarget != null) {
        previousTarget.claimed = null;
        final intermediate = active.intermediateShape;
        if (intermediate != null) {
          active.startTime = null;
          active.currentShape = intermediate;
        }
      }
      active.target = hero;
      hero.claimed = active;
      hero.shape = null;
      active.sourceTreeData.pause();
      print(active.sourceTreeData.toDeepString());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        active.targetTreeData = TreeData.scan(hero.element);
        active.sourceTreeData.pairWith(active.targetTreeData!);
      });
      _check();
    }
  }

  void _check() {
    if (_active.isNotEmpty) {
      if (_ticker != null && !_ticker!.isActive) {
        _ticker!.start();
      }
    } else {
      if (_ticker != null && _ticker!.isActive) {
        _ticker!.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        _InternalHeroScope(
          heroLayer: this,
          child: widget.child,
        ),
        for (final active in _active.values)
          if (active.target != null)
            Positioned(
              top: 0,
              left: 0,
              child: HeroFlight(
                key: ValueKey(active),
                activeHero: active,
              ),
            ),
      ],
    );
  }
}

abstract class HeroLayer {
  void push(RenderHero hero);
  void claim(RenderHero hero);
}

class _InternalHeroScope extends SingleChildRenderObjectWidget {
  final HeroLayer heroLayer;

  const _InternalHeroScope({
    required this.heroLayer,
    Widget? child,
  }) : super(child: child);

  @override
  RenderHeroScope createRenderObject(BuildContext context) {
    return RenderHeroScope(heroLayer);
  }

  @override
  void updateRenderObject(BuildContext context, RenderHeroScope renderObject) {
    renderObject.heroLayer = heroLayer;
  }
}

class RenderHeroScope extends RenderProxyBox {
  HeroLayer heroLayer;

  RenderHeroScope(this.heroLayer);

  void claim(RenderHero hero) {
    heroLayer.claim(hero);
  }

  void push(RenderHero hero) {
    heroLayer.push(hero);
  }
}
