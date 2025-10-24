import 'package:flexiblebox/flexiblebox_dart.dart';
import 'package:flexiblebox/src/eval/eval.dart';
import 'package:test/test.dart';

void main() {
  group('PositionUnit toCodeString', () {
    test('fixed position converts to string', () {
      final unit = PositionUnit.fixed(100);
      expect(unit.toCodeString(), '100.0px');
    });

    test('viewport size converts to string', () {
      final unit = PositionUnit.viewportSize;
      expect(unit.toCodeString(), 'viewportSize');
    });

    test('content size converts to string', () {
      final unit = PositionUnit.contentSize;
      expect(unit.toCodeString(), 'contentSize');
    });

    test('box offset converts to string', () {
      final unit = PositionUnit.boxOffset;
      expect(unit.toCodeString(), 'boxOffset');
    });

    test('scroll offset converts to string', () {
      final unit = PositionUnit.scrollOffset;
      expect(unit.toCodeString(), 'scrollOffset');
    });

    test('content overflow converts to string', () {
      final unit = PositionUnit.contentOverflow;
      expect(unit.toCodeString(), 'contentOverflow');
    });

    test('content underflow converts to string', () {
      final unit = PositionUnit.contentUnderflow;
      expect(unit.toCodeString(), 'contentUnderflow');
    });

    test('viewport end bound converts to string', () {
      final unit = PositionUnit.viewportEndBound;
      expect(unit.toCodeString(), 'viewportEndBound');
    });

    test('calculated position (addition) converts to string', () {
      final unit = PositionUnit.fixed(50) + PositionUnit.fixed(30);
      expect(unit.toCodeString(), '(50.0px + 30.0px)');
    });

    test('calculated position (subtraction) converts to string', () {
      final unit = PositionUnit.viewportSize - PositionUnit.fixed(20);
      expect(unit.toCodeString(), '(viewportSize - 20.0px)');
    });

    test('calculated position (multiplication) converts to string', () {
      final unit = PositionUnit.viewportSize * 0.5;
      expect(unit.toCodeString(), '(viewportSize * 0.5px)');
    });

    test('calculated position (division) converts to string', () {
      final unit = PositionUnit.fixed(100) / PositionUnit.fixed(2);
      expect(unit.toCodeString(), '(100.0px / 2.0px)');
    });

    test('complex calculated position converts to string', () {
      final unit = (PositionUnit.contentSize * 0.5) + PositionUnit.fixed(20);
      expect(unit.toCodeString(), '((contentSize * 0.5px) + 20.0px)');
    });

    test('childSize without key converts to string', () {
      final unit = PositionUnit.childSize();
      expect(unit.toCodeString(), 'childSize');
    });

    test('childSize with string key converts to string', () {
      final unit = PositionUnit.childSize('myKey');
      expect(unit.toCodeString(), 'childSize("myKey")');
    });

    test('childSize with symbol key converts to string', () {
      final unit = PositionUnit.childSize(#mySymbol);
      expect(unit.toCodeString(), 'childSize(#Symbol("mySymbol"))');
    });

    test('cross position converts to string', () {
      final unit = PositionUnit.cross(PositionUnit.fixed(100));
      expect(unit.toCodeString(), 'cross(100.0px)');
    });
  });

  group('PositionUnit evaluate from toCodeString', () {
    test('evaluates fixed position from toCodeString', () {
      final original = PositionUnit.fixed(100);
      final str = original.toCodeString();
      final evaluated = evaluatePositionUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates viewport size from toCodeString', () {
      final original = PositionUnit.viewportSize;
      final str = original.toCodeString();
      final evaluated = evaluatePositionUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates content size from toCodeString', () {
      final original = PositionUnit.contentSize;
      final str = original.toCodeString();
      final evaluated = evaluatePositionUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates calculated position from toCodeString', () {
      final original = PositionUnit.fixed(50) + PositionUnit.fixed(30);
      final str = original.toCodeString();
      final evaluated = evaluatePositionUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates complex expression from toCodeString', () {
      final original =
          (PositionUnit.viewportSize * 0.5) + PositionUnit.fixed(20);
      final str = original.toCodeString();
      final evaluated = evaluatePositionUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });
  });

  group('PositionUnit evaluate from normal strings', () {
    test('evaluates fixed pixel value', () {
      final unit = evaluatePositionUnit('100px');
      expect(unit.toCodeString(), PositionUnit.fixed(100).toCodeString());
    });

    test('evaluates fixed value without px', () {
      final unit = evaluatePositionUnit('100');
      expect(unit.toCodeString(), PositionUnit.fixed(100).toCodeString());
    });

    test('evaluates percentage', () {
      final unit = evaluatePositionUnit('50%');
      expect(
        unit.toCodeString(),
        (PositionUnit.viewportSize * 0.5).toCodeString(),
      );
    });

    test('evaluates viewportSize', () {
      final unit = evaluatePositionUnit('viewportSize');
      expect(unit.toCodeString(), PositionUnit.viewportSize.toCodeString());
    });

    test('evaluates contentSize', () {
      final unit = evaluatePositionUnit('contentSize');
      expect(unit.toCodeString(), PositionUnit.contentSize.toCodeString());
    });

    test('evaluates boxOffset', () {
      final unit = evaluatePositionUnit('boxOffset');
      expect(unit.toCodeString(), PositionUnit.boxOffset.toCodeString());
    });

    test('evaluates scrollOffset', () {
      final unit = evaluatePositionUnit('scrollOffset');
      expect(unit.toCodeString(), PositionUnit.scrollOffset.toCodeString());
    });

    test('evaluates contentOverflow', () {
      final unit = evaluatePositionUnit('contentOverflow');
      expect(unit.toCodeString(), PositionUnit.contentOverflow.toCodeString());
    });

    test('evaluates contentUnderflow', () {
      final unit = evaluatePositionUnit('contentUnderflow');
      expect(unit.toCodeString(), PositionUnit.contentUnderflow.toCodeString());
    });

    test('evaluates viewportEndBound', () {
      final unit = evaluatePositionUnit('viewportEndBound');
      expect(unit.toCodeString(), PositionUnit.viewportEndBound.toCodeString());
    });

    test('evaluates addition expression', () {
      final unit = evaluatePositionUnit('100px + 50px');
      expect(
        unit.toCodeString(),
        (PositionUnit.fixed(100) + PositionUnit.fixed(50)).toCodeString(),
      );
    });

    test('evaluates subtraction expression', () {
      final unit = evaluatePositionUnit('viewportSize - 20px');
      expect(
        unit.toCodeString(),
        (PositionUnit.viewportSize - PositionUnit.fixed(20)).toCodeString(),
      );
    });

    test('evaluates multiplication expression', () {
      final unit = evaluatePositionUnit('contentSize * 0.5');
      expect(
        unit.toCodeString(),
        (PositionUnit.contentSize * 0.5).toCodeString(),
      );
    });

    test('evaluates division expression', () {
      final unit = evaluatePositionUnit('100px / 2');
      expect(
        unit.toCodeString(),
        (PositionUnit.fixed(100) / PositionUnit.fixed(2)).toCodeString(),
      );
    });

    test('evaluates complex expression', () {
      final unit = evaluatePositionUnit('(viewportSize * 0.5) + 20px');
      expect(
        unit.toCodeString(),
        ((PositionUnit.viewportSize * 0.5) + PositionUnit.fixed(20))
            .toCodeString(),
      );
    });

    test('evaluates parenthesized expression', () {
      final unit = evaluatePositionUnit('(100px + 50px) * 2');
      expect(
        unit.toCodeString(),
        ((PositionUnit.fixed(100) + PositionUnit.fixed(50)) * 2.0)
            .toCodeString(),
      );
    });

    test('respects operator precedence', () {
      final unit = evaluatePositionUnit('100px + 50px * 2');
      expect(
        unit.toCodeString(),
        (PositionUnit.fixed(100) + (PositionUnit.fixed(50) * 2.0))
            .toCodeString(),
      );
    });

    test('evaluates childSize without argument', () {
      final unit = evaluatePositionUnit('childSize');
      expect(unit.toCodeString(), PositionUnit.childSize().toCodeString());
    });

    test('evaluates childSize with string argument', () {
      final unit = evaluatePositionUnit('childSize("test")');
      expect(
        unit.toCodeString(),
        PositionUnit.childSize('test').toCodeString(),
      );
    });

    test('evaluates childSize with symbol argument', () {
      final unit = evaluatePositionUnit('childSize(#test)');
      expect(unit.toCodeString(), PositionUnit.childSize(#test).toCodeString());
    });

    test('evaluates negative values', () {
      final unit = evaluatePositionUnit('-50px');
      expect(
        unit.toCodeString(),
        (PositionUnit.fixed(0) - PositionUnit.fixed(50)).toCodeString(),
      );
    });

    test('evaluates decimal values', () {
      final unit = evaluatePositionUnit('12.5px');
      expect(unit.toCodeString(), PositionUnit.fixed(12.5).toCodeString());
    });
  });
}
