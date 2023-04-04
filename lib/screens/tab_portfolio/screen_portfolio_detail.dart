import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenPortfolioDetail extends StatelessWidget {
  final String title;
  final double value;
  final String date;
  final List<LabelValueColor> list;

  const ScreenPortfolioDetail(this.title, this.value, this.date, this.list,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: createBody(context, paddingBottom),
        ),
      ),
    );
  }

  void addWidgetWithPadding(List<Widget> listWidget, Widget widget,
      {double paddingTop = 8.0, double paddingBottom = 8.0}) {
    listWidget.add(Padding(
      padding: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: paddingTop,
          bottom: paddingBottom),
      child: widget,
    ));
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    TextStyle styleLabel = InvestrendTheme.of(context)
        .small_w400_compact
        .copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    TextStyle styleValue = InvestrendTheme.of(context).small_w400_compact;
    TextStyle subtitle = InvestrendTheme.of(context).regular_w600_compact;

    double paddingTopBottom = 8.0;
    double paddingTopBottomDouble = 16.0;

    int countData = list != null ? list.length : 0;

    List<Widget> listWidget = List.empty(growable: true);
    //listWidget.add(SizedBox(height: InvestrendTheme.cardPaddingPlusMargin,));
    addWidgetWithPadding(
        listWidget,
        Text(
          'portfolio_detail_value_label'.tr(),
          style: subtitle,
        ),
        paddingTop: paddingTopBottomDouble);

    addWidgetWithPadding(
        listWidget,
        Text(
          InvestrendTheme.formatMoneyDouble(value,
              prefixPlus: true, prefixRp: true),
          style: Theme.of(context).textTheme.headline4.copyWith(
              color: InvestrendTheme.changeTextColor(value),
              fontWeight: FontWeight.w600),
        ));
    addWidgetWithPadding(listWidget, ComponentCreator.divider(context));
    addWidgetWithPadding(
        listWidget, Text('portfolio_detail_date_label'.tr(), style: subtitle));
    addWidgetWithPadding(
        listWidget,
        Text(date,
            style: styleValue.copyWith(
                color: InvestrendTheme.of(context).greyDarkerTextColor)),
        paddingBottom: paddingTopBottomDouble);
    listWidget.add(ComponentCreator.divider(context));
    addWidgetWithPadding(
        listWidget, Text('portfolio_detail_detail_label'.tr(), style: subtitle),
        paddingTop: paddingTopBottomDouble);

    // "portfolio_detail_value_label": "Value",
    // "portfolio_detail_date_label": "Date",
    // "portfolio_detail_detail_label": "Detail",
    //
    List<Widget> listContent = List<Widget>.generate(
      countData,
      (int index) {
        LabelValueColor lbc = list.elementAt(index);
        return Padding(
          padding: EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              top: paddingTopBottom,
              bottom: paddingTopBottom),
          child: Row(
            //mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(lbc.label, style: styleLabel),
              Expanded(
                flex: 1,
                child: Text(
                  lbc.value,
                  style: lbc.color != null
                      ? styleValue.copyWith(color: lbc.color)
                      : styleValue,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
    int countContent = listContent != null ? listContent.length : 0;
    if (countContent > 0) {
      listWidget.addAll(listContent);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listWidget,
    );
    /*
    return Column(
      children: List<Widget>.generate(
        countData,
        (int index) {
          LabelValueColor lbc = list.elementAt(index);
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(lbc.label, style: styleLabel),
              Expanded(
                flex: 1,
                child: Text(lbc.value, style: lbc.color != null ? styleValue.copyWith(color: lbc.color) : styleValue),
              ),
            ],
          );
        },
      ),
    );
    */
  }

  Widget createAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).backgroundColor,
      title: AppBarTitleText(title),
    );
  }
}

class LabelValueColor {
  String label = '';
  String value = '';
  Color color;
  bool isShown;

  LabelValueColor(
    this.label,
    this.value, {
    this.color,
    this.isShown = true,
  });
}
