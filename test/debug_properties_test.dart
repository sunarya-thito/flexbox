import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/src/widgets/builder.dart';
import 'package:flexiblebox/src/widgets/fallback.dart';
import 'package:flexiblebox/src/widgets/flex.dart';
import 'package:flexiblebox/src/widgets/rotated.dart';
import 'package:flexiblebox/src/widgets/scrollbar.dart';
import 'package:flexiblebox/src/widgets/widget.dart';
import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout/flex.dart';

void main() {
  test('LayoutBoxBuilder debug properties', () {
    final widget = LayoutBoxBuilder(builder: (context, box) => Container());
    final builder = DiagnosticPropertiesBuilder();
    widget.debugFillProperties(builder);
    expect(builder.properties, isNotEmpty);
    expect(builder.properties.where((p) => p.name == 'builder'), isNotEmpty);
  });

  test('FallbackWidget debug properties', () {
    final widget = FallbackWidget();
    final builder = DiagnosticPropertiesBuilder();
    widget.debugFillProperties(builder);
    // Should be empty or just default properties, but we called super.
  });

  test('FlexBox debug properties', () {
    final widget = FlexBox(
      direction: FlexDirection.column,
      wrap: FlexWrap.wrap,
      maxItemsPerLine: 5,
    );
    final builder = DiagnosticPropertiesBuilder();
    widget.debugFillProperties(builder);
    expect(builder.properties, isNotEmpty);
    expect(builder.properties.where((p) => p.name == 'direction'), isNotEmpty);
    expect(builder.properties.where((p) => p.name == 'wrap'), isNotEmpty);
    expect(
      builder.properties.where((p) => p.name == 'maxItemsPerLine'),
      isNotEmpty,
    );
  });

  test('FlexItem debug properties', () {
    final widget = FlexItem(
      flexGrow: 2.0,
      width: SizeUnit.fixed(100),
      child: Container(),
    );
    final builder = DiagnosticPropertiesBuilder();
    widget.debugFillProperties(builder);
    expect(builder.properties, isNotEmpty);
    expect(builder.properties.where((p) => p.name == 'flexGrow'), isNotEmpty);
    expect(builder.properties.where((p) => p.name == 'width'), isNotEmpty);
  });

  test('RotatedWidget debug properties', () {
    final widget = RotatedWidget(angle: 45, child: Container());
    final builder = DiagnosticPropertiesBuilder();
    widget.debugFillProperties(builder);
    expect(builder.properties, isNotEmpty);
    expect(builder.properties.where((p) => p.name == 'angle'), isNotEmpty);
  });

  test('Scrollbar debug properties', () {
    final widget = DefaultScrollbar();
    final builder = DiagnosticPropertiesBuilder();
    widget.debugFillProperties(builder);
    expect(builder.properties, isNotEmpty);
    expect(
      builder.properties.where((p) => p.name == 'minThumbLength'),
      isNotEmpty,
    );
  });

  test('LayoutBoxWidget debug properties', () {
    final widget = LayoutBoxWidget(
      layout: FlexLayout(direction: FlexDirection.row),
      horizontalOverflow: LayoutOverflow.scroll,
      verticalOverflow: LayoutOverflow.hidden,
      children: [],
    );
    final builder = DiagnosticPropertiesBuilder();
    widget.debugFillProperties(builder);
    expect(builder.properties, isNotEmpty);
    expect(
      builder.properties.where((p) => p.name == 'horizontalOverflow'),
      isNotEmpty,
    );
    expect(builder.properties.where((p) => p.name == 'layout'), isNotEmpty);
  });
}
