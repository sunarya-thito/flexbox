import 'package:demo/cases/case_absolute.dart';
import 'package:demo/cases/case_column.dart';
import 'package:demo/cases/case_column_reverse.dart';
import 'package:demo/cases/case_flex_wrap_column.dart';
import 'package:demo/cases/case_flex_wrap_column_reverse.dart';
import 'package:demo/cases/case_flex_wrap_reverse_column.dart';
import 'package:demo/cases/case_flex_wrap_reverse_column_reverse.dart';
import 'package:demo/cases/case_flex_wrap_reverse_row_reverse.dart';
import 'package:demo/cases/case_flex_wrap_row_reverse.dart';
import 'package:demo/cases/case_items_start.dart';
import 'package:demo/cases/case_row_reverse.dart';
import 'package:demo/cases/case_rtl_column.dart';
import 'package:demo/cases/case_rtl_column_reverse.dart';
import 'package:demo/cases/case_rtl_row.dart';
import 'package:demo/cases/case_rtl_row_reverse.dart';
import 'package:demo/cases/case_rtl_wrap.dart';
import 'package:demo/cases/case_rtl_wrap_column.dart';
import 'package:demo/cases/case_rtl_wrap_column_reverse.dart';
import 'package:demo/cases/case_rtl_wrap_reverse.dart';
import 'package:demo/cases/case_rtl_wrap_reverse_column.dart';
import 'package:demo/cases/case_rtl_wrap_reverse_column_reverse.dart';
import 'package:demo/cases/case_scrollable.dart';
import 'package:demo/cases/case_scrollable_sticky.dart';
import 'package:demo/cases/case_scrollable_unclipped.dart';
import 'package:demo/cases/case_simple.dart';
import 'package:demo/cases/case_justify_start.dart';
import 'package:demo/cases/case_flex_grow.dart';
import 'package:demo/cases/case_flex_shrink.dart';
import 'package:demo/cases/case_flex_wrap.dart';
import 'package:demo/cases/case_flex_wrap_reverse.dart';
import 'package:demo/cases/case_spacing_around.dart';
import 'package:demo/cases/case_spacing_between.dart';
import 'package:demo/cases/case_spacing_evenly.dart';
import 'package:demo/cases/case_wrap_content_around.dart';
import 'package:demo/cases/case_wrap_content_between.dart';
import 'package:demo/cases/case_wrap_items_center.dart';
import 'package:demo/cases/case_wrap_content_evenly.dart';
import 'package:demo/cases/case_wrap_content_center.dart';
import 'package:demo/cases/case_padded.dart';
import 'package:demo/cases/case_spacing.dart';
import 'package:demo/cases/case_items_center.dart';
import 'package:demo/cases/case_items_end.dart';
import 'package:demo/cases/case_items_stretch.dart';
import 'package:demo/cases/case_items_baseline.dart';
import 'package:demo/cases/case_justify_center.dart';
import 'package:demo/cases/case_justify_end.dart';
import 'package:demo/cases/case_wrap_content_end.dart';
import 'package:demo/cases/case_wrap_content_start.dart';
import 'package:demo/cases/case_wrap_items_end.dart';
import 'package:demo/cases/case_wrap_items_start.dart';
import 'package:demo/demo.dart';
import 'package:flutter/material.dart';

final testCases = [
  CaseAbsolute(),
  CaseColumn(),
  CaseColumnReverse(),
  CaseFlexGrow(),
  CaseFlexShrink(),
  CaseFlexWrap(),
  CaseFlexWrapColumn(),
  CaseFlexWrapColumnReverse(),
  CaseFlexWrapReverse(),
  CaseFlexWrapReverseColumn(),
  CaseFlexWrapReverseColumnReverse(),
  CaseFlexWrapReverseRowReverse(),
  CaseFlexWrapRowReverse(),
  // CaseItemsBaseline(),
  CaseItemsCenter(),
  CaseItemsEnd(),
  CaseItemsStart(),
  CaseItemsStretch(),
  CaseJustifyCenter(),
  CaseJustifyEnd(),
  CaseJustifyStart(),
  CasePadded(),
  CaseRowReverse(),
  CaseRTLColumn(),
  CaseRTLColumnReverse(),
  CaseRTLRow(),
  CaseRTLRowReverse(),
  CaseRTLWrap(),
  CaseRTLWrapColumn(),
  CaseRTLWrapColumnReverse(),
  CaseRTLWrapReverse(),
  CaseRTLWrapReverseColumn(),
  CaseRTLWrapReverseColumnReverse(),
  CaseScrollable(),
  CaseScrollableSticky(),
  CaseSimple(),
  CaseSpacing(),
  CaseSpacingAround(),
  CaseSpacingBetween(),
  CaseSpacingEvenly(),
  CaseUnclippedScrollable(),
  CaseWrapContentAround(),
  CaseWrapContentBetween(),
  CaseWrapContentCenter(),
  CaseWrapContentEnd(),
  CaseWrapContentEvenly(),
  CaseWrapContentStart(),
  CaseWrapItemsCenter(),
  CaseWrapItemsEnd(),
  CaseWrapItemsStart(),
];

void main(List<String> args) {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: DemoApp(
          testCases: testCases,
        ),
      ),
    ),
  );
}
