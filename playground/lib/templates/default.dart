import 'package:flexiblebox/flexiblebox_extensions.dart';
import 'package:playground/config.dart';

FlexBoxConfiguration get defaultConfiguration => FlexBoxConfiguration(
  children: [
    for (var i = 0; i < 3; i++)
      FlexItemConfiguration(
        mainSize: 100.px,
        crossSize: 100.px,
      ),
  ],
);
