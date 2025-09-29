import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flexiblebox/flexiblebox_dart.dart';

class FlexWrapBenchmark extends BenchmarkBase {
  FlexWrapBenchmark() : super('Flex Layout with Wrap');

  static void main() {
    FlexWrapBenchmark().report();
  }

  @override
  void setup() {}

  @override
  void run() {
    Box root;
    List<Box> children;
    // Create a flex layout with wrap enabled
    final layout = FlexLayout(
      direction: FlexDirection.row,
      wrap: FlexWrap.wrap,
      alignItems: BoxAlignment.start,
      justifyContent: BoxAlignment.start,
    );

    // Create root box
    root = Box(
      textDirection: LayoutTextDirection.ltr,
      horizontalOverflow: LayoutOverflow.visible,
      verticalOverflow: LayoutOverflow.visible,
      boxLayout: layout,
    );

    // Create many children to test wrapping performance
    children = List.generate(1000, (index) {
      return Box(
        debugKey: index,
        textDirection: LayoutTextDirection.ltr,
        horizontalOverflow: LayoutOverflow.visible,
        verticalOverflow: LayoutOverflow.visible,
        layoutData: LayoutData(
          width: SizeUnit.fixed(50 + (index % 3) * 20), // Varying widths
          height: SizeUnit.fixed(50),
        ),
        boxLayout: FlexLayout(), // Simple layout for children
      );
    });

    // Add children to root
    root.addChildren(children);
    // Perform layout with constraints that will cause wrapping
    final constraints = LayoutConstraints(
      minWidth: 0,
      maxWidth: 800, // Limited width to force wrapping
      minHeight: 0,
      maxHeight: double.infinity,
    );

    root.layout(constraints);
  }

  @override
  void teardown() {
    // Clean up if needed
  }
}

void main() {
  FlexWrapBenchmark.main();
}
