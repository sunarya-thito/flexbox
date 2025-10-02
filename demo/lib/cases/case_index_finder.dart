import 'package:demo/box.dart';
import 'package:demo/case.dart';
import 'package:demo/helper.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

class CaseIndexFinder extends TestCase {
  final ValueNotifier<int?> selectedIndex = ValueNotifier<int?>(null);
  final GlobalKey key0 = GlobalKey();
  @override
  Widget build() {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      onHover: (event) {
        final renderFlex = RenderLayoutBox.find(key0.currentContext!)!;
        final index = renderFlex.indexOfNearestChildAtOffset(
          event.localPosition,
        );
        selectedIndex.value = index;
      },
      child: SizedBox(
        width: 550,
        height: 300,
        child: Box.parent(
          child: FlexBox(
            key: key0,
            direction: FlexDirection.rowReverse,
            padding: const EdgeInsets.all(10).asEdgeSpacing,
            wrap: FlexWrap.wrap,
            rowGap: SpacingUnit.fixed(20),
            columnGap: SpacingUnit.fixed(15),
            children: [
              FlexItem(
                key: key1,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(0),
              ),
              FlexItem(
                key: key2,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(1),
              ),
              FlexItem(
                key: key3,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(2),
              ),
              FlexItem(
                key: key4,
                width: SizeUnit.fixed(350),
                height: SizeUnit.fixed(100),
                child: Box(3),
              ),
              FlexItem(
                key: key5,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(4),
              ),
              FlexItem(
                key: key6,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(5),
              ),
              FlexItem(
                key: key7,
                width: SizeUnit.fixed(150),
                height: SizeUnit.fixed(100),
                child: Box(6),
              ),

              // selected index display
              AbsoluteItem(
                top: PositionUnit.fixed(20),
                right: PositionUnit.fixed(20),
                width: SizeUnit.maxContent,
                height: SizeUnit.maxContent,
                child: ListenableBuilder(
                  listenable: selectedIndex,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      color: const Color(0xAA000000),
                      child: Text(
                        'Index: ${selectedIndex.value}',
                        style: const TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  String get name => 'Index Finder';

  @override
  String get path => 'case_index_finder.dart';
}
