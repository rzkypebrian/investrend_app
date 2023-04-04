import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FilterTransaction { All, Buy, Sell }
enum FilterStatus { All, Open, Match, /*Partial,*/ Withdraw, Reject, New } //, Amend

enum FilterPeriod { /*All, */Today, ThisWeek, /*ThisMonth*/ }

// New, Open, Partial, Withdraw, Match, Reject
extension FilterTransactionExtension on FilterTransaction {
  String get text {
    switch (this) {
      case FilterTransaction.All:
        return 'filter_all_label'.tr();
      case FilterTransaction.Buy:
        return 'filter_buy_label'.tr();
      case FilterTransaction.Sell:
        return 'filter_sell_label'.tr();
      default:
        return '#unknown_type';
    }
  }
  String get filter {
    switch (this) {
      case FilterTransaction.All:
        return 'all';
      case FilterTransaction.Buy:
        return 'buy';
      case FilterTransaction.Sell:
        return 'sell';
      default:
        return '#unknown_type';
    }
  }
}

extension FilterStatusExtension on FilterStatus {
  String get text {
    switch (this) {
      case FilterStatus.All:
        return 'filter_all_label'.tr();
      case FilterStatus.Open:
        return 'filter_open_label'.tr();
      case FilterStatus.Match:
        return 'filter_match_label'.tr();
      // case FilterStatus.Partial:
      //   return 'filter_partial_label'.tr();
      case FilterStatus.Withdraw:
        return 'filter_withdraw_label'.tr();
      case FilterStatus.Reject:
        return 'filter_reject_label'.tr();
      case FilterStatus.New:
        return 'filter_new_label'.tr();
      default:
        return '#unknown_status';
    }
  }
}

extension FilterPeriodExtension on FilterPeriod {
  String get text {
    switch (this) {
      // case FilterPeriod.All:
      //   return 'filter_all_label'.tr();
      case FilterPeriod.Today:
        return 'filter_today_label'.tr();
      case FilterPeriod.ThisWeek:
        return 'filter_week_label'.tr();
      // case FilterPeriod.ThisMonth:
      //   return 'filter_month_label'.tr();
      default:
        return '#unknown_type';
    }
  }
  String get filter {
    switch (this) {
      // case FilterPeriod.All:
      //   return 'week';
      case FilterPeriod.Today:
        return 'day';
      case FilterPeriod.ThisWeek:
        return 'week';
      // case FilterPeriod.ThisMonth:
      //   return 'month';
      default:
        return '#unknown_type';
    }
  }
}

/*****************************************
 *
 * Historical FILTER
 *
 ******************************************/
class BottomSheetTransactionHistoricalFilter extends StatefulWidget {
  final int index_period;
  final int index_transaction;

  const BottomSheetTransactionHistoricalFilter(this.index_transaction, this.index_period, {Key key}) : super(key: key);

  @override
  _BottomSheetTransactionHistoricalFilterState createState() => _BottomSheetTransactionHistoricalFilterState();
}

class _BottomSheetTransactionHistoricalFilterState extends State<BottomSheetTransactionHistoricalFilter> {
  int index_period;
  int index_transaction;

  @override
  void initState() {
    super.initState();
    index_period = widget.index_period;
    index_transaction = widget.index_transaction;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + ((44.0 * 3) + ((16.0 + 8.0) * 2) + (16.0 * 2) + 8.0 + (20.0 * 2)) + padding;

    if (contentHeight > minHeight) {
      maxHeight = min(contentHeight, maxHeight);
      minHeight = min(minHeight, maxHeight);
    }

    List<Widget> transactionList = List.empty(growable: true);
    FilterTransaction.values.forEach((transaction) {
      transactionList.add(Expanded(
        flex: 1,
        child: ButtonSelectionFilter(transaction.text, index_transaction == transaction.index, () {
          //context.read(transactionHistoricalFilterChangeNotifier).setIndexTransaction(transaction.index);
          setState(() {
            this.index_transaction = transaction.index;
          });
        }),
        /*
        child: button(context, transaction.text, index_transaction == transaction.index, () {
          //context.read(transactionHistoricalFilterChangeNotifier).setIndexTransaction(transaction.index);
          setState(() {
            this.index_transaction = transaction.index;
          });
        }),
        */
      ));
    });

    List<Widget> periodList = List.empty(growable: true);
    FilterPeriod.values.forEach((period) {
      periodList.add(ButtonSelectionFilter(period.text, index_period == period.index, () {
        //context.read(transactionHistoricalFilterChangeNotifier).setIndexStatus(status.index);
        setState(() {
          this.index_period = period.index;
        });

        /*
      periodList.add(button(context, period.text, index_period == period.index, () {
        //context.read(transactionHistoricalFilterChangeNotifier).setIndexStatus(status.index);
        setState(() {
          this.index_period = period.index;
        });
      */
      }));
    });

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          //mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'filter_title'.tr(),
                      style: InvestrendTheme.of(context).regular_w600_compact,
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      //icon: Icon(Icons.clear),
                      icon: Image.asset(
                        'images/icons/action_clear.png',
                        color: InvestrendTheme.of(context).greyLighterTextColor,
                        width: 12.0,
                        height: 12.0,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'filter_transaction_label'.tr(),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 44.0,
              child: Row(
                children: transactionList,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'filter_period_label'.tr(),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 44.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: periodList,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: ComponentCreator.divider(context, thickness: 1.0),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              width: double.maxFinite,
              child: ComponentCreator.roundedButton(context, 'filter_apply_button'.tr(), Theme.of(context).accentColor,
                  Theme.of(context).primaryColor, Theme.of(context).accentColor, () {
                context.read(transactionHistoricalFilterChangeNotifier).setIndex(index_transaction, index_period);
                Navigator.pop(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget button(BuildContext context, String text, bool selected, VoidCallback onPressed) {
    //const colorSoft = Color(0xFFF5F0FF);
    TextStyle style = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    //Color colorBackground = selected ? colorSoft : Colors.transparent;
    Color colorBackground = selected ? InvestrendTheme.of(context).colorSoft : Colors.transparent;

    Color colorBorder = selected ? Theme.of(context).accentColor : Colors.transparent;
    Color colorText = selected ? Theme.of(context).accentColor : style.color;
    return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBackground //Colors.transparent
                : colorBackground; //Colors.transparent;
            return colors;
          }),
          padding: MaterialStateProperty.all(EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: BorderSide(color: Colors.red)
          )),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBorder //Theme.of(context).accentColor
                : colorBorder; //Theme.of(context).accentColor;
            return BorderSide(color: colors, width: 1.0);
          }),
        ),
        child: Text(
          text,
          style: style.copyWith(color: colorText),
        ),
        onPressed: onPressed);
  }
}

/*****************************************
 *
 * Intraday FILTER
 *
 ******************************************/
class BottomSheetTransactionIntradayFilter extends StatefulWidget {
  final int index_status;
  final int index_transaction;

  const BottomSheetTransactionIntradayFilter(this.index_transaction, this.index_status, {Key key}) : super(key: key);

  @override
  _BottomSheetTransactionIntradayFilterState createState() => _BottomSheetTransactionIntradayFilterState();
}

class _BottomSheetTransactionIntradayFilterState extends State<BottomSheetTransactionIntradayFilter> {
  int index_status;
  int index_transaction;

  @override
  void initState() {
    super.initState();
    index_status = widget.index_status;
    index_transaction = widget.index_transaction;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + ((44.0 * 3) + ((16.0 + 8.0) * 2) + (16.0 * 2) + 8.0 + (20.0 * 2)) + padding;

    if (contentHeight > minHeight) {
      maxHeight = min(contentHeight, maxHeight);
      minHeight = min(minHeight, maxHeight);
    }

    List<Widget> transactionList = List.empty(growable: true);
    FilterTransaction.values.forEach((transaction) {
      transactionList.add(Expanded(
        flex: 1,
        child: ButtonSelectionFilter(transaction.text, index_transaction == transaction.index, () {
          //context.read(transactionIntradayFilterChangeNotifier).setIndexTransaction(transaction.index);
          setState(() {
            this.index_transaction = transaction.index;
          });
        }),
        /*
        child: button(context, transaction.text, index_transaction == transaction.index, () {
          //context.read(transactionIntradayFilterChangeNotifier).setIndexTransaction(transaction.index);
          setState(() {
            this.index_transaction = transaction.index;
          });
        }),
        */
      ));
    });

    List<Widget> statusList = List.empty(growable: true);
    FilterStatus.values.forEach((status) {
      statusList.add(
        ButtonSelectionFilter( status.text, index_status == status.index, () {
          //context.read(transactionIntradayFilterChangeNotifier).setIndexStatus(status.index);
          setState(() {
            this.index_status = status.index;
          });
        }),
      );
      /*
      statusList.add(
        button(context, status.text, index_status == status.index, () {
          //context.read(transactionIntradayFilterChangeNotifier).setIndexStatus(status.index);
          setState(() {
            this.index_status = status.index;
          });
        }),
      );
      */
    });

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          //mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'filter_title'.tr(),
                      style: InvestrendTheme.of(context).regular_w600_compact,
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      //icon: Icon(Icons.clear),
                      icon: Image.asset(
                        'images/icons/action_clear.png',
                        color: InvestrendTheme.of(context).greyLighterTextColor,
                        width: 12.0,
                        height: 12.0,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'filter_transaction_label'.tr(),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 44.0,
              child: Row(
                children: transactionList,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'filter_status_label'.tr(),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 44.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: statusList,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: ComponentCreator.divider(context, thickness: 1.0),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              width: double.maxFinite,
              child: ComponentCreator.roundedButton(context, 'filter_apply_button'.tr(), Theme.of(context).accentColor,
                  Theme.of(context).primaryColor, Theme.of(context).accentColor, () {
                context.read(transactionIntradayFilterChangeNotifier).setIndex(index_transaction, index_status);
                Navigator.pop(context);
              }),
            ),
          ],
        ),
      ),
    );
  }
  /*
  Widget button(BuildContext context, String text, bool selected, VoidCallback onPressed) {
    const colorSoft = Color(0xFFF5F0FF);
    TextStyle style = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    Color colorBackground = selected ? colorSoft : Colors.transparent;
    Color colorBorder = selected ? Theme.of(context).accentColor : Colors.transparent;
    Color colorText = selected ? Theme.of(context).accentColor : style.color;
    return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBackground //Colors.transparent
                : colorBackground; //Colors.transparent;
            return colors;
          }),
          padding: MaterialStateProperty.all(EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: BorderSide(color: Colors.red)
          )),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBorder //Theme.of(context).accentColor
                : colorBorder; //Theme.of(context).accentColor;
            return BorderSide(color: colors, width: 1.0);
          }),
        ),
        child: Text(
          text,
          style: style.copyWith(color: colorText),
        ),
        onPressed: onPressed);
  }
  */
}
/*
class BottomSheetTransactionIntradayFilter extends StatelessWidget {
  const BottomSheetTransactionIntradayFilter({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + (44.0 * 5) + padding;

    if (contentHeight > minHeight) {
      maxHeight = min(contentHeight, maxHeight);
      minHeight = min(minHeight, maxHeight);
    }

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          //mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text('filter_title'.tr(), style: InvestrendTheme.of(context).regular_w600_compact,)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    //icon: Icon(Icons.clear),
                      icon: Image.asset('images/icons/action_clear.png', color: InvestrendTheme.of(context).greyLighterTextColor, width: 12.0, height: 12.0,),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text('filter_transaction_label'.tr(), style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
            ),

            Consumer(builder: (context, watch, child) {
              final notifier = watch(transactionIntradayFilterChangeNotifier);
              List<Widget> transactionList = List.empty(growable: true);
              FilterTransaction.values.forEach((transaction) {
                transactionList.add(Expanded(
                  flex: 1,
                  child: button(context, transaction.text, notifier.index_transaction == transaction.index, () {
                    context.read(transactionIntradayFilterChangeNotifier).setIndexTransaction(transaction.index);
                  }),
                ));
              });
              return Container(
                width: double.maxFinite,
                height: 44.0,
                child: Row(
                  children: transactionList,
                ),
              );
            }),

            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text('filter_status_label'.tr(), style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
            ),
            Consumer(builder: (context, watch, child) {
              final notifier = watch(transactionIntradayFilterChangeNotifier);
              List<Widget> statusList = List.empty(growable: true);
              FilterStatus.values.forEach((status) {
                statusList.add(button(context, status.text, notifier.index_status == status.index, () {
                  context.read(transactionIntradayFilterChangeNotifier).setIndexStatus(status.index);
                }));
              });
              return Container(
                width: double.maxFinite,
                height: 44.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: statusList,
                ),
              );
            }),
          ],
        ),
      ),

    );
  }

  Widget button(BuildContext context, String text, bool selected, VoidCallback onPressed){
    const colorSoft =  Color(0xFFF5F0FF);
    TextStyle style = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    Color colorBackground = selected ?  colorSoft : Colors.transparent;
    Color colorBorder     = selected ?  Theme.of(context).accentColor : Colors.transparent;
    Color colorText       = selected ?  Theme.of(context).accentColor : style.color;
    return OutlinedButton(
        style: ButtonStyle(

          backgroundColor: MaterialStateColor.resolveWith((states) {
            final Color colors =
            states.contains(MaterialState.pressed)
                ? colorBackground //Colors.transparent
                : colorBackground; //Colors.transparent;
            return colors;
          }),

          padding: MaterialStateProperty.all(EdgeInsets.only(
              left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                //side: BorderSide(color: Colors.red)
              )),
          side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                final Color colors =
                states.contains(MaterialState.pressed)
                    ? colorBorder //Theme.of(context).accentColor
                    : colorBorder; //Theme.of(context).accentColor;
                return BorderSide(color: colors, width: 1.0);
              }),
        ),
        child: Text(
          text,
          style: style.copyWith(color: colorText),
        ),
        onPressed: onPressed);

  }
}
 */
