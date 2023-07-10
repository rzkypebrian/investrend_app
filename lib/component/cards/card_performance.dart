import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class CardPerformance extends StatefulWidget {
  final PerformanceNotifier notifier;
  const CardPerformance(this.notifier,{Key key}) : super(key: key);

  @override
  _CardPerformanceState createState() => _CardPerformanceState();
}

class _CardPerformanceState extends State<CardPerformance> {
  PerformanceData data = PerformanceData();
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.lightBlue,
      margin: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //SizedBox(height: InvestrendTheme.cardPaddingGeneral,),
          ComponentCreator.subtitleNoButtonMore(
            context,
            'card_performance_title'.tr(),
          ),
          // SizedBox(height: 8.0,),
          ValueListenableBuilder(
            valueListenable: widget.notifier,
            builder: (context, PerformanceData data, child) {
              if (widget.notifier.invalid()) {
                return Center(child: CircularProgressIndicator());
              }
              /*
              'TODAY'
              '1_WEEK'
              '1_MONTH'
              '3_MONTH'
              '6_MONTH'
              'YTD'
              '1_YEAR'
              '2_YEAR'
              '3_YEAR'
              '4_YEAR'
              '5_YEAR'
              */

              Performance today = data.getPerformance('TODAY');
              double intradayChange          = today?.change;
              double intradayPercentChange  = today?.percentChange;

              Performance week = data.getPerformance('1_WEEK');
              double weekChange          = week?.change;
              double weekPercentChange  = week?.percentChange;

              Performance month = data.getPerformance('1_MONTH');
              double month1Change          = month?.change;
              double month1PercentChange  = month?.percentChange;

              Performance month3 = data.getPerformance('3_MONTH');
              double month3Change          = month3?.change;
              double month3PercentChange  = month3?.percentChange;

              Performance month6 = data.getPerformance('6_MONTH');
              double month6Change          = month6?.change;
              double month6PercentChange  = month6?.percentChange;

              Performance year = data.getPerformance('1_YEAR');
              double year1Change          = year?.change;
              double year1PercentChange  = year?.percentChange;

              Performance year5 = data.getPerformance('5_YEAR');
              double year5Change          = year5?.change;
              double year5PercentChange  = year5?.percentChange;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  progressPerformance(context, 'card_performance_intraday'.tr(), intradayChange, intradayPercentChange, paddingBottom: 0,paddingTop: 0),
                  progressPerformance(context, 'card_performance_week'.tr(), weekChange, weekPercentChange, paddingBottom: 0),
                  progressPerformance(context, 'card_performance_month_1'.tr(), month1Change, month1PercentChange, paddingBottom: 0),
                  progressPerformance(context, 'card_performance_month_3'.tr(), month3Change, month3PercentChange, paddingBottom: 0),
                  progressPerformance(context, 'card_performance_month_6'.tr(), month6Change, month6PercentChange, paddingBottom: 0),
                  progressPerformance(context, 'card_performance_year_1'.tr(), year1Change, year1PercentChange, paddingBottom: 0),
                  progressPerformance(context, 'card_performance_year_5'.tr(), year5Change, year5PercentChange, paddingBottom: 0),
                ],
              );
            },
          ),
          /*
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              progressPerformance(context, 'card_performance_intraday'.tr(), data.intraday_change, data.intraday_percent_change),
              progressPerformance(context, 'card_performance_week'.tr(), data.week_change, data.week_percent_change),
              progressPerformance(context, 'card_performance_month_1'.tr(), data.month_1_change, data.month_1_percent_change),
              progressPerformance(context, 'card_performance_month_3'.tr(), data.month_3_change, data.month_3_percent_change),
              progressPerformance(context, 'card_performance_month_6'.tr(), data.month_6_change, data.month_6_percent_change),
              progressPerformance(context, 'card_performance_year_1'.tr(), data.year_1_change, data.year_1_percent_change),
              progressPerformance(context, 'card_performance_year_5'.tr(), data.year_5_change, data.year_5_percent_change),
            ],
          ),
          */
        ],
      ),
    );
  }

  Widget progressPerformance(BuildContext context, String label, double change, double percentChange,
      {double paddingTop = InvestrendTheme.cardPaddingVertical, double paddingBottom = InvestrendTheme.cardPaddingVertical}) {
    double progressValue = percentChange.abs() / 100;

    return Padding(
      padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
      child: Row(
        children: [
          SizedBox(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: InvestrendTheme.of(context).small_w400_compact,

                //textAlign: TextAlign.start,
              ),
            ),
            width: 65.0,
          ),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
            flex: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                minHeight: 12.0,
                value: progressValue,
                valueColor: new AlwaysStoppedAnimation<Color>(InvestrendTheme.changeTextColor(percentChange)),
                backgroundColor: InvestrendTheme.of(context).tileBackground,
              ),
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          SizedBox(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                //formatterNumber.format(value) + '%',
                InvestrendTheme.formatPercentChange(percentChange),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.changeTextColor(percentChange)),
                textAlign: TextAlign.end,
              ),
            ),
            width: 65,
          ),
        ],
      ),
    );
  }

}
