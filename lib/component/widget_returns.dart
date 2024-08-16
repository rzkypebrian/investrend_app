// ignore_for_file: must_be_immutable, dead_code

import 'package:Investrend/objects/group_style.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WidgetReturns extends StatelessWidget {
  final int? todayReturnValue;
  final double? todayReturnPercentage;

  final int? totalReturnValue;
  final double? totalReturnPercentage;
  //final AutoSizeGroup groupValue = AutoSizeGroup();
  //final AutoSizeGroup groupLabel = AutoSizeGroup();

  // final FlexibleTextGroup groupValue = FlexibleTextGroup();
  // final FlexibleTextGroup groupLabel = FlexibleTextGroup();
  GroupStyle? groupStyle;

  WidgetReturns(this.todayReturnValue, this.todayReturnPercentage,
      this.totalReturnValue, this.totalReturnPercentage,
      {Key? key, this.groupStyle})
      : super(key: key);

  /*
  Widget cellLabel(BuildContext context, String text, FlexibleTextGroup group) {
    TextStyle style = InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: FlexibleText(
        text,
        style: style,
        group: group,
      ),
    );
  }

  Widget cellValue(BuildContext context, int value, double percentage, FlexibleTextGroup group) {
    String valueText = InvestrendTheme.formatMoney(value, prefixPlus: true, prefixRp: true);
    String percentageText = ' (' + InvestrendTheme.formatPercentChange(percentage, sufixPercent: true) + ')';
    TextStyle valueStyle = InvestrendTheme.of(context).regular_w600_compact.copyWith(height: null);
    TextStyle percentageStyle = InvestrendTheme.of(context).small_w400_compact.copyWith(height: null);

    Color color = InvestrendTheme.priceTextColor(value);
    if (color != null) {
      valueStyle = valueStyle.copyWith(color: color);
      percentageStyle = percentageStyle.copyWith(color: color);
    }

    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: FlexibleText.rich(
        TextSpan(text: valueText, style: valueStyle, children: [TextSpan(text: percentageText, style: percentageStyle)]),
        group: group,
        maxLines: 1,
        minFontSize: 8.0,
      ),
    );
  }
  */

  Widget cellLabel(BuildContext context, String text, AutoSizeGroup group) {
    TextStyle? style = InvestrendTheme.of(context)
        .support_w400_compact
        ?.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: AutoSizeText(
        text,
        style: style,
        group: group,
      ),
    );
  }

  Widget cellLabelNew(BuildContext context, String text, TextStyle style) {
    //TextStyle style = InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Text(
        text,
        style: style,
      ),
    );
  }

  Widget cellValue(
      BuildContext context, int value, double percentage, AutoSizeGroup group) {
    String valueText =
        InvestrendTheme.formatMoney(value, prefixPlus: true, prefixRp: true);
    String percentageText = ' (' +
        InvestrendTheme.formatPercentChange(percentage, sufixPercent: true) +
        ')';
    TextStyle valueStyle = InvestrendTheme.of(context)
        .regular_w600_compact!
        .copyWith(height: null);
    TextStyle? percentageStyle =
        InvestrendTheme.of(context).small_w400_compact?.copyWith(height: null);

    Color? color = InvestrendTheme.priceTextColor(value);
    if (color != null) {
      valueStyle = valueStyle.copyWith(color: color);
      percentageStyle = percentageStyle?.copyWith(color: color);
    }

    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: AutoSizeText.rich(
        TextSpan(
            text: valueText,
            style: valueStyle,
            children: [TextSpan(text: percentageText, style: percentageStyle)]),
        group: group,
        maxLines: 1,
        minFontSize: 8.0,
      ),
    );
  }

  Widget cellValueNew(BuildContext context, String text_1, String text_2,
      TextStyle style_1, TextStyle style_2,
      {Color? color}) {
    style_1 = style_1.copyWith(color: color);
    style_2 = style_2.copyWith(color: color);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: RichText(
        text: TextSpan(text: text_1, style: style_1, children: [
          TextSpan(
            text: text_2,
            style: style_2,
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthAvailable = MediaQuery.of(context).size.width -
        InvestrendTheme.cardPaddingGeneral -
        InvestrendTheme.cardPaddingGeneral;
    print('WidgetReturns .widthAvailable : $widthAvailable');
    double leftWidth = widthAvailable * 0.4;
    double rightWidth = widthAvailable - leftWidth;

    String returnsTodaysReturnLabel = 'returns_todays_return_label'.tr();
    String returnsTotalReturnLabel = 'returns_total_return_label'.tr();

    TextStyle? styleLabel = InvestrendTheme.of(context)
        .support_w400_compact
        ?.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    styleLabel =
        useFontSize(context, styleLabel, leftWidth, returnsTodaysReturnLabel);
    styleLabel =
        useFontSize(context, styleLabel, leftWidth, returnsTotalReturnLabel);

    String todayValueText = InvestrendTheme.formatMoney(todayReturnValue,
        prefixPlus: true, prefixRp: true);
    String todayPercentageText = ' (' +
        InvestrendTheme.formatPercentChange(todayReturnPercentage,
            sufixPercent: true) +
        ')';

    String totalValueText = InvestrendTheme.formatMoney(totalReturnValue,
        prefixPlus: true, prefixRp: true);
    String totalPercentageText = ' (' +
        InvestrendTheme.formatPercentChange(totalReturnPercentage,
            sufixPercent: true) +
        ')';

    TextStyle? valueStyle = InvestrendTheme.of(context)
        .regular_w600_compact!
        .copyWith(height: null);
    TextStyle? percentageStyle =
        InvestrendTheme.of(context).small_w400_compact?.copyWith(height: null);

    if (groupStyle != null) {
      if (groupStyle?.style_1 == null) {
        groupStyle?.style_1 = valueStyle;
      } else {
        valueStyle = groupStyle!.style_1;
      }
      if (groupStyle?.style_2 == null) {
        groupStyle?.style_2 = percentageStyle;
      } else {
        percentageStyle = groupStyle!.style_2;
      }
    }

    List<TextStyle?>? styles = calculateFontSizes(
        context,
        [valueStyle, percentageStyle],
        rightWidth,
        [todayValueText, todayPercentageText]);
    styles = calculateFontSizes(context, [valueStyle, percentageStyle],
        rightWidth, [totalValueText, totalPercentageText]);
    if (groupStyle != null) {
      groupStyle?.style_1 = styles!.elementAt(0)!;
      groupStyle?.style_2 = styles!.elementAt(1);
    }
    Color? colorToday = InvestrendTheme.priceTextColor(todayReturnValue);
    Color? colorTotal = InvestrendTheme.priceTextColor(totalReturnValue);

    return Column(
      children: [
        Row(
          children: [
            Container(
              // color: Colors.amber,
              width: leftWidth,
              child:
                  cellLabelNew(context, returnsTodaysReturnLabel, styleLabel),
            ),
            Container(
              // color: Colors.deepPurple,
              width: rightWidth,
              child: cellValueNew(context, todayValueText, todayPercentageText,
                  groupStyle!.style_1, groupStyle!.style_2,
                  color: colorToday),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              // color: Colors.cyan,
              width: leftWidth,
              child: cellLabelNew(context, returnsTotalReturnLabel, styleLabel),
            ),
            Container(
              // color: Colors.grey,
              width: rightWidth,
              child: cellValueNew(context, totalValueText, totalPercentageText,
                  groupStyle!.style_1, groupStyle!.style_2,
                  color: colorTotal),
            ),
          ],
        ),
      ],
    );

    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        //border: TableBorder.all(color: Colors.black),
        columnWidths: {
          0: FractionColumnWidth(.4)
        },
        children: [
          TableRow(children: [
            cellLabelNew(context, returnsTodaysReturnLabel, styleLabel),
            cellValueNew(context, todayValueText, todayPercentageText,
                groupStyle!.style_1, groupStyle!.style_2,
                color: colorToday),
          ]),
          TableRow(children: [
            cellLabelNew(context, returnsTotalReturnLabel, styleLabel),
            cellValueNew(context, totalValueText, totalPercentageText,
                groupStyle!.style_1, groupStyle!.style_2,
                color: colorTotal),
          ]),
        ]);
    /*
    return LayoutBuilder(builder: (context, constrains) {
      print('WidgetReturns .constrains ' + constrains.maxWidth.toString());
      double leftWidth = constrains.maxWidth * 0.4;
      double rightWidth = constrains.maxWidth - leftWidth;

      String returns_todays_return_label = 'returns_todays_return_label'.tr();
      String returns_total_return_label = 'returns_total_return_label'.tr();

      TextStyle styleLabel = InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
      styleLabel = useFontSize(context, styleLabel, leftWidth, returns_todays_return_label);
      styleLabel = useFontSize(context, styleLabel, leftWidth, returns_total_return_label);

      String todayValueText = InvestrendTheme.formatMoney(todayReturnValue, prefixPlus: true, prefixRp: true);
      String todayPercentageText = ' (' + InvestrendTheme.formatPercentChange(todayReturnPercentage, sufixPercent: true) + ')';

      String totalValueText = InvestrendTheme.formatMoney(totalReturnValue, prefixPlus: true, prefixRp: true);
      String totalPercentageText = ' (' + InvestrendTheme.formatPercentChange(totalReturnPercentage, sufixPercent: true) + ')';

      TextStyle valueStyle = InvestrendTheme.of(context).regular_w600_compact.copyWith(height: null);
      TextStyle percentageStyle = InvestrendTheme.of(context).small_w400_compact.copyWith(height: null);

      List<TextStyle> styles = calculateFontSizes(context, [valueStyle, percentageStyle], rightWidth, [todayValueText, todayPercentageText]);
      styles = calculateFontSizes(context, [valueStyle, percentageStyle], rightWidth, [totalValueText, totalPercentageText]);

      Color colorToday = InvestrendTheme.priceTextColor(todayReturnValue);
      Color colorTotal = InvestrendTheme.priceTextColor(totalReturnValue);


      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: leftWidth, child: cellLabelNew(context, returns_todays_return_label, styleLabel)),
              SizedBox(
                width: rightWidth,
                child: cellValueNew(context, todayValueText, todayPercentageText, styles.elementAt(0), styles.elementAt(1), color: colorToday),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              SizedBox(width: leftWidth, child: cellLabelNew(context, returns_total_return_label, styleLabel)),
              SizedBox(
                width: rightWidth,
                child: cellValueNew(context, totalValueText, totalPercentageText, styles.elementAt(0), styles.elementAt(1), color: colorTotal),
              ),
            ],
          ),
        ],
      );


    });
    */
    /*
    return Table(defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        //border: TableBorder.all(color: Colors.black),
        columnWidths: {
          0: FractionColumnWidth(.4)
        }, children: [
      TableRow(children: [
        cellLabel(context, 'returns_todays_return_label'.tr(), groupLabel),
        cellValue(context, todayReturnValue, todayReturnPercentage, groupValue),
      ]),
      TableRow(children: [
        cellLabel(context, 'returns_total_return_label'.tr(), groupLabel),
        cellValue(context, totalReturnValue, totalReturnPercentage, groupValue),
      ]),
    ]);
    */
  }

  List<TextStyle?>? calculateFontSizes(BuildContext context,
      List<TextStyle?> styles, double width, List<String> texts,
      {int tried = 1}) {
    print('WidgetReturns.calculateFontSize  try  : $tried  ');
    const double font_step = 1.5;

    double widthText = 0;
    for (int i = 0; i < styles.length; i++) {
      TextStyle? style = styles.elementAt(i);
      String text = texts.elementAt(i);
      print('WidgetReturns.calculateFontSize   style[$i] : ' +
          style!.fontSize.toString() +
          '  text[$i] : $text');
      widthText += UIHelper.textSize(text, style).width;
    }
    bool reduceFont = widthText > width;
    print(
        'WidgetReturns.calculateFontSize  reduceFont  : $reduceFont  widthText[$widthText] > width[$width]  ');
    if (reduceFont) {
      List<TextStyle> stylesNew = List.empty(growable: true);
      for (int i = 0; i < styles.length; i++) {
        TextStyle? style = styles.elementAt(i);
        style = style?.copyWith(fontSize: style.fontSize! - font_step);
        stylesNew.add(style!);
      }

      return calculateFontSizes(context, stylesNew, width, texts,
          tried: tried++);
    } else {
      print('WidgetReturns.calculateFontSizes Final  tried : $tried');
      return styles;
    }
  }

  TextStyle useFontSize(
      BuildContext context, TextStyle? style, double width, String text,
      {int tried = 1}) {
    print('WidgetReturns.useFontSize  try fontSize  : ' +
        style!.fontSize.toString() +
        '  width : $width  text : $text  ');
    const double font_step = 1.5;

    double widthText = UIHelper.textSize(text, style).width;
    bool reduceFont = widthText > width;
    if (reduceFont) {
      style = style.copyWith(fontSize: style.fontSize! - font_step);
      return useFontSize(context, style, width, text, tried: tried++);
    } else {
      print('WidgetReturns.useFontSize Final fontSize  : ' +
          style.fontSize!.toString() +
          '  text : $text  tried : $tried');
      return style;
    }
  }
}
