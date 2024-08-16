// ignore_for_file: non_constant_identifier_names

import 'package:Investrend/component/button_rounded.dart';
// import 'package:Investrend/component/charts/chart_bar_triple_line.dart';
// import 'package:Investrend/component/charts/chart_dual_bar_line.dart';
// import 'package:Investrend/component/charts/chart_triple_bar_line.dart';
import 'package:Investrend/component/charts/year_value.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenStockDetailFinancials extends StatefulWidget {
  final TabController? tabController;
  final int tabIndex;
  final ValueNotifier<bool>? visibilityNotifier;

  ScreenStockDetailFinancials(this.tabIndex, this.tabController,
      {Key? key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenStockDetailFinancialsState createState() =>
      _ScreenStockDetailFinancialsState(tabIndex, tabController!,
          visibilityNotifier: visibilityNotifier!);
}

class _ScreenStockDetailFinancialsState
    extends BaseStateNoTabsWithParentTab<ScreenStockDetailFinancials> {
  ChartIncomeStatementNotifier? _incomeStatementNotifier =
      ChartIncomeStatementNotifier(DataChartIncomeStatement.createBasic());
  ChartBalanceSheetNotifier? _balanceSheetNotifier =
      ChartBalanceSheetNotifier(DataChartBalanceSheet.createBasic());
  ChartCashFlowNotifier? _cashFlowNotifier =
      ChartCashFlowNotifier(DataChartCashFlow.createBasic());
  ChartEarningPerShareNotifier? _earningPerShareNotifier =
      ChartEarningPerShareNotifier(DataChartEarningPerShare.createBasic());
  ValueNotifier<bool> _showEarningPerShareNotifier = ValueNotifier(true);
  ValueNotifier<int>? _rangeNotifier = ValueNotifier<int>(0);
  List<String> _range_options = [
    'annual_label'.tr(),
    'quarterly_label'.tr(),
  ];

  _ScreenStockDetailFinancialsState(int tabIndex, TabController tabController,
      {ValueNotifier<bool>? visibilityNotifier})
      : super('/stock_detail_financials', tabIndex, tabController,
            notifyStockChange: true, visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  @override
  void onStockChanged(Stock? newStock) {
    super.onStockChanged(newStock);
    doUpdate(pullToRefresh: true);
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ComponentCreator.subtitle(context, 'segment_label'.tr()),
          ButtonDropdown(_rangeNotifier, _range_options),
        ],
      ),
    );
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString());
    if (!active) {
      print(routeName + '.doUpdate aborted active : $active');
      return;
    }
    Stock? stock = context.read(primaryStockChangeNotifier).stock;
    if (stock == null || !stock.isValid()) {
      Stock? stockDefault = InvestrendTheme.storedData!.listStock!.isEmpty
          ? null
          : InvestrendTheme.storedData?.listStock?.first;
      context.read(primaryStockChangeNotifier).setStock(stockDefault!);
      stock = context.read(primaryStockChangeNotifier).stock;
    }

    String showAs = _rangeNotifier?.value == 0 ? 'YEARLY' : 'QUARTERLY';
    String? code = stock != null ? stock.code : "";
    if (!StringUtils.isEmtpy(code)) {
      setNotifierLoading(_incomeStatementNotifier);
      try {
        final result = await InvestrendTheme.datafeedHttp
            .fetchFinancialChart(code, 'INCOME_STATEMENT', showAs);
        if (result != null && result is DataChartIncomeStatement) {
          if (mounted) {
            print('Got INCOME_STATEMENT : ' + result.toString());
            _incomeStatementNotifier?.setValue(result);
          } else {
            print('ignored researchRank, mounted : $mounted');
          }
        } else {
          setNotifierNoData(_incomeStatementNotifier);
        }
      } catch (error) {
        print('incomeStatement : ' + error.toString());
        setNotifierError(_incomeStatementNotifier, error);
      }

      setNotifierLoading(_balanceSheetNotifier);
      try {
        final result = await InvestrendTheme.datafeedHttp
            .fetchFinancialChart(code, 'BALANCE_SHEET', showAs);
        if (result != null && result is DataChartBalanceSheet) {
          if (mounted) {
            print('Got BALANCE_SHEET : ' + result.toString());
            _balanceSheetNotifier?.setValue(result);
          } else {
            print('ignored balanceSheet, mounted : $mounted');
          }
        } else {
          setNotifierNoData(_balanceSheetNotifier);
        }
      } catch (error) {
        print('balanceSheet : ' + error.toString());
        setNotifierError(_balanceSheetNotifier, error);
      }
    }

    setNotifierLoading(_cashFlowNotifier);
    try {
      final result = await InvestrendTheme.datafeedHttp
          .fetchFinancialChart(code, 'CASH_FLOW', showAs);
      if (result != null && result is DataChartCashFlow) {
        if (mounted) {
          print('Got CASH_FLOW : ' + result.toString());
          _cashFlowNotifier?.setValue(result);
        } else {
          print('ignored cashFlow, mounted : $mounted');
        }
      } else {
        setNotifierNoData(_cashFlowNotifier);
      }
    } catch (error) {
      print('cashFlow : ' + error.toString());
      setNotifierError(_cashFlowNotifier, error);
    }

    setNotifierLoading(_earningPerShareNotifier);
    try {
      final result = await InvestrendTheme.datafeedHttp
          .fetchFinancialChart(code, 'EARNING_PER_SHARE', showAs);
      if (result != null && result is DataChartEarningPerShare) {
        if (mounted) {
          print('Got EARNING_PER_SHARE : ' + result.toString());
          _earningPerShareNotifier?.setValue(result);
        } else {
          print('ignored earningPerShare, mounted : $mounted');
        }
      } else {
        setNotifierNoData(_earningPerShareNotifier);
      }
    } catch (error) {
      print('earningPerShare : ' + error.toString());
      setNotifierError(_earningPerShareNotifier, error);
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    if (!active) {
      active = true;
      //onActive();
      context
          .read(stockDetailScreenVisibilityChangeNotifier)
          .setActive(tabIndex, true);
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      _title(context),
      ComponentCreator.divider(context),

      //SizedBox(height: 10.0),

      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: ComponentCreator.subtitle(
            context, 'stock_detail_financials_income_statement_title'.tr()),
      ),
      /*
      Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ChartDualBarLine(
            data_bar_1,
            data_bar_2,
            data_line,
            'net_income_label'.tr(),
            'revenue_label'.tr(),
            'net_profit_margin_label'.tr(),
            Theme.of(context).accentColor,
            InvestrendTheme.redText,
            InvestrendTheme.greenText,
            animate: true,
          ),
        ),
      ),
      */
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _incomeStatementNotifier!,
              builder: (context, DataChartIncomeStatement? value, child) {
                Widget? noWidget = _incomeStatementNotifier?.currentState
                    .getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }

                // double max_net_income = value.max_net_income;
                // double min_net_income = value.min_net_income;
                //
                // double max_revenue = value.max_revenue;
                // double min_revenue = value.min_revenue;
                //
                // double max_net_profit_margin = value.max_net_profit_margin;
                // double min_net_profit_margin = value.min_net_profit_margin;

                //TODO: chart_dual_bar_line.dart saya comment karena charts_flutter package nya sudah deprecate
                return Container();
                // return ChartDualBarLine(
                //   value.net_income,
                //   value.revenue,
                //   value.net_profit_margin,
                //   'net_income_label'.tr(),
                //   'revenue_label'.tr(),
                //   'net_profit_margin_label'.tr(),
                //   Theme.of(context).colorScheme.secondary,
                //   InvestrendTheme.redText,
                //   InvestrendTheme.greenText,
                //   animate: true,
                //   max_value: value.max_net_income,
                //   min_value: value.min_net_income,
                // );
              }),
        ),
      ),

      // SizedBox(height: 10.0),
      ComponentCreator.divider(context),
      // SizedBox(height: 10.0),

      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: ComponentCreator.subtitle(
            context, 'stock_detail_financials_balance_sheet_title'.tr()),
      ),
      /*
      Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ChartTripleBarLine(
            data_bar_1,
            data_bar_2,
            data_bar_3,
            data_line,
            'equity_label'.tr(),
            'liabilities_label'.tr(),
            'assets_label'.tr(),
            'debt_equity_ratio_label'.tr(),
            InvestrendTheme.greenText,
            Colors.orange,
            InvestrendTheme.redText,
            Theme.of(context).accentColor,
            animate: true,
          ),
        ),
      ),
      */
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _balanceSheetNotifier!,
              builder: (context, DataChartBalanceSheet? value, child) {
                Widget? noWidget = _balanceSheetNotifier?.currentState
                    .getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }
                //TODO: chart_triple_bar_line.dart saya comment karena charts_flutter package nya sudah deprecate
                return Container();
                // return ChartTripleBarLine(
                //   value.equity,
                //   value.liabilities,
                //   value.assets,
                //   value.debt_equity_ratio,
                //   'equity_label'.tr(),
                //   'liabilities_label'.tr(),
                //   'assets_label'.tr(),
                //   'debt_equity_ratio_label'.tr(),
                //   InvestrendTheme.greenText,
                //   Colors.orange,
                //   InvestrendTheme.redText,
                //   Theme.of(context).colorScheme.secondary,
                //   animate: true,
                // );
              }),
        ),
      ),

      // SizedBox(height: 10.0),
      ComponentCreator.divider(context),
      // SizedBox(height: 10.0),

      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: ComponentCreator.subtitle(
            context, 'stock_detail_financials_cash_flow_title'.tr()),
      ),
      /*
      Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ChartBarTripleLine(
            data_bar,
            data_line_1,
            data_line_2,
            data_line_3,
            'cash_reserve_label'.tr(),
            'investing_label'.tr(),
            'operating_label'.tr(),
            'financing_label'.tr(),

            InvestrendTheme.redText,
            Colors.orange,
            Colors.blue,
            InvestrendTheme.greenText,
            animate: true,
          ),
        ),
      ),
      */
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _cashFlowNotifier!,
              builder: (context, DataChartCashFlow? value, child) {
                Widget? noWidget = _cashFlowNotifier?.currentState
                    .getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }
                //TODO: chart_triple_bar_line.dart saya comment karena charts_flutter package nya sudah deprecate
                return Container();
                // return ChartBarTripleLine(
                //   value.cash_reserve,
                //   value.investing,
                //   value.operating,
                //   value.financing,
                //   'cash_reserve_label'.tr(),
                //   'investing_label'.tr(),
                //   'operating_label'.tr(),
                //   'financing_label'.tr(),
                //   InvestrendTheme.redText,
                //   Colors.orange,
                //   Colors.blue,
                //   InvestrendTheme.greenText,
                //   animate: true,
                // );
              }),
        ),
      ),

      // SizedBox(height: 10.0),
      ComponentCreator.divider(context),
      // SizedBox(height: 10.0),
      ValueListenableBuilder(
          valueListenable: _showEarningPerShareNotifier,
          builder: (context, bool value, child) {
            if (!value) {
              return SizedBox(
                height: 1.0,
              );
            }
            return Padding(
              padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingVertical,
                bottom: InvestrendTheme.cardPaddingVertical,
              ),
              child: ComponentCreator.subtitle(context,
                  'stock_detail_financials_earning_per_share_title'.tr()),
            );
          }),
      /*
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: ComponentCreator.subtitle(context, 'stock_detail_financials_earning_per_share_title'.tr()),
      ),
      
       */
      /*
      Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ChartDualBarLine(
            data_bar_1,
            data_bar_2,
            data_line,
            'dividend_per_share_label'.tr(),
            'earning_per_share_label'.tr(),
            'dividend_payout_ratio_label'.tr(),
            Theme.of(context).accentColor,
            InvestrendTheme.redText,
            InvestrendTheme.greenText,
            animate: true,
          ),
        ),
      ),
      */

      ValueListenableBuilder(
        valueListenable: _showEarningPerShareNotifier,
        builder: (context, bool value, child) {
          if (!value) {
            return SizedBox(
              height: 1.0,
            );
          }
          return Padding(
            padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              bottom: InvestrendTheme.cardPaddingVertical,
            ),
            child: Container(
              width: double.maxFinite,
              height: 300.0,
              //child: ChartBarLine.withSampleData(),
              child: ValueListenableBuilder(
                  valueListenable: _earningPerShareNotifier!,
                  builder: (context, DataChartEarningPerShare? value, child) {
                    Widget? noWidget = _earningPerShareNotifier?.currentState
                        .getNoWidget(
                            onRetry: () => doUpdate(pullToRefresh: true));
                    if (noWidget != null) {
                      return Center(child: noWidget);
                    }
                    //TODO: chart_dual_bar_line.dart saya comment karena charts_flutter package nya sudah deprecate
                    return Container();
                    // return ChartDualBarLine(
                    //   value.dividend_per_share,
                    //   value.earning_per_share,
                    //   value.dividend_payout_ratio,
                    //   'dividend_per_share_label'.tr(),
                    //   'earning_per_share_label'.tr(),
                    //   'dividend_payout_ratio_label'.tr(),
                    //   Theme.of(context).colorScheme.secondary,
                    //   InvestrendTheme.redText,
                    //   InvestrendTheme.greenText,
                    //   animate: true,
                    // );
                  }),
            ),
          );
        },
      ),
      /*
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _earningPerShareNotifier,
              builder: (context, DataChartEarningPerShare value, child) {
                Widget noWidget = _earningPerShareNotifier.currentState.getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }
                return ChartDualBarLine(
                  value.dividend_per_share,
                  value.earning_per_share,
                  value.dividend_payout_ratio,
                  'dividend_per_share_label'.tr(),
                  'earning_per_share_label'.tr(),
                  'dividend_payout_ratio_label'.tr(),
                  Theme.of(context).accentColor,
                  InvestrendTheme.redText,
                  InvestrendTheme.greenText,
                  animate: true,
                );
              }),
        ),
      ),
      */
      SizedBox(
        height: paddingBottom + 80,
        // height: paddingBottom,
      ),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ListView(
        controller: pScrollController,
        shrinkWrap: false,
        children: childs,
      ),
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(context),
          ComponentCreator.divider(context),

          SizedBox(height: 10.0),

          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: ComponentCreator.subtitle(context, 'stock_detail_financials_income_statement_title'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: Container(
              width: double.maxFinite,
              height: 300.0,
              //child: ChartBarLine.withSampleData(),
              child: ChartDualBarLine(
                data_bar_1,
                data_bar_2,
                data_line,
                'net_income_label'.tr(),
                'revenue_label'.tr(),
                'net_profit_margin_label'.tr(),
                Theme.of(context).accentColor,
                InvestrendTheme.redText,
                InvestrendTheme.greenText,
                animate: true,
              ),
            ),
          ),

          SizedBox(height: 10.0),
          ComponentCreator.divider(context),
          SizedBox(height: 10.0),

          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: ComponentCreator.subtitle(context, 'stock_detail_financials_balance_sheet_title'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: Container(
              width: double.maxFinite,
              height: 300.0,
              //child: ChartBarLine.withSampleData(),
              child: ChartTripleBarLine(
                data_bar_1,
                data_bar_2,
                data_bar_3,
                data_line,
                'equity_label'.tr(),
                'liabilities_label'.tr(),
                'assets_label'.tr(),
                'debt_equity_ratio_label'.tr(),
                InvestrendTheme.greenText,
                Colors.orange,
                InvestrendTheme.redText,
                Theme.of(context).accentColor,
                animate: true,
              ),
            ),
          ),

          SizedBox(height: 10.0),
          ComponentCreator.divider(context),
          SizedBox(height: 10.0),

          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: ComponentCreator.subtitle(context, 'stock_detail_financials_cash_flow_title'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: Container(
              width: double.maxFinite,
              height: 300.0,
              //child: ChartBarLine.withSampleData(),
              child: ChartBarTripleLine(
                data_bar,
                data_line_1,
                data_line_2,
                data_line_3,
                'cash_reserve_label'.tr(),
                'investing_label'.tr(),
                'operating_label'.tr(),
                'financing_label'.tr(),

                InvestrendTheme.redText,
                Colors.orange,
                Colors.blue,
                InvestrendTheme.greenText,
                animate: true,
              ),
            ),
          ),

          SizedBox(height: 10.0),
          ComponentCreator.divider(context),
          SizedBox(height: 10.0),

          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: ComponentCreator.subtitle(context, 'stock_detail_financials_earning_per_share_title'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
            child: Container(
              width: double.maxFinite,
              height: 300.0,
              //child: ChartBarLine.withSampleData(),
              child: ChartDualBarLine(
                data_bar_1,
                data_bar_2,
                data_line,
                'dividend_per_share_label'.tr(),
                'earning_per_share_label'.tr(),
                'dividend_payout_ratio_label'.tr(),
                Theme.of(context).accentColor,
                InvestrendTheme.redText,
                InvestrendTheme.greenText,
                animate: true,
              ),
            ),
          ),

          // Container(
          //   width: double.maxFinite,
          //   height: 300.0,
          //   child: ChartBarLine2(),
          // ),

          // Container(
          //   width: double.maxFinite,
          //   height: 600.0,
          //   child: ScrollablePositionedListPage(),
          // ),
          SizedBox(
            height: paddingBottom + 80,
          ),
        ],
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName+' onActive');
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, true);
    doUpdate();
  }

  final data_bar_1 = [
    // new YearValue('2014', 10),
    new YearValue('2015', 20),
    new YearValue('2016', 30),
    new YearValue('2017', 50),
    new YearValue('2018', 5),
    new YearValue('2019', 15),
    new YearValue('2020', 70),
    // new YearValue('2021', 30),
  ];

  final data_bar_2 = [
    // new YearValue('2014', 2000000),
    new YearValue('2015', 9000000),
    new YearValue('2016', 8000000),
    new YearValue('2017', 3000000),
    new YearValue('2018', 6000000),
    new YearValue('2019', 2000000),
    new YearValue('2020', 8000000),
    // new YearValue('2021', 10000000),
  ];

  final data_bar_3 = [
    // new YearValue('2014', 4000000),
    new YearValue('2015', 5000000),
    new YearValue('2016', 2500000),
    new YearValue('2017', 3000000),
    new YearValue('2018', 7000000),
    new YearValue('2019', 5500000),
    new YearValue('2020', 6000000),
    // new YearValue('2021', 9000000),
  ];

  final data_line = [
    // new YearValue('2014', 17),
    new YearValue('2015', 28),
    new YearValue('2016', 33),
    new YearValue('2017', 55),
    new YearValue('2018', 10),
    new YearValue('2019', 20),
    new YearValue('2020', 50),
    // new YearValue('2021', 20),
  ];

  final data_bar = [
    new YearValue('2014', 2000000),
    new YearValue('2015', 9000000),
    new YearValue('2016', 8000000),
    new YearValue('2017', 3000000),
    new YearValue('2018', 6000000),
    new YearValue('2019', 6000000),
    new YearValue('2020', 8000000),
    new YearValue('2021', 10000000),
  ];

  final data_line_1 = [
    new YearValue('2014', 4500000),
    new YearValue('2015', 3000000),
    new YearValue('2016', 9000000),
    new YearValue('2017', 8000000),
    new YearValue('2018', 2000000),
    new YearValue('2019', 5000000),
    new YearValue('2020', 6500000),
    new YearValue('2021', 2000000),
  ];

  final data_line_2 = [
    new YearValue('2014', 2000000),
    new YearValue('2015', 9000000),
    new YearValue('2016', 8000000),
    new YearValue('2017', 3000000),
    new YearValue('2018', 6000000),
    new YearValue('2019', 2000000),
    new YearValue('2020', 8000000),
    new YearValue('2021', 6000000),
  ];

  final data_line_3 = [
    new YearValue('2014', 7800000),
    new YearValue('2015', 5500000),
    new YearValue('2016', 2000000),
    new YearValue('2017', 5000000),
    new YearValue('2018', 7000000),
    new YearValue('2019', 1500000),
    new YearValue('2020', 6800000),
    new YearValue('2021', 5000000),
  ];

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate(pullToRefresh: true);
    // });

    _rangeNotifier?.addListener(() {
      _showEarningPerShareNotifier.value = _rangeNotifier!.value == 0;
      doUpdate(pullToRefresh: true);
    });
    //news = HttpSSI.fetchNews();
    /*
    Future.delayed(Duration(milliseconds: 500),(){

      LabelValueData dataHistory = new LabelValueData();
      dataHistory.datas.add(LabelValue('card_history_listing_date_label'.tr(), '28 Oct 2007'));
      dataHistory.datas.add(LabelValue('card_history_effective_date_label'.tr(), '11 Oct 2007'));
      dataHistory.datas.add(LabelValue('card_history_nominal_label'.tr(), '100'));
      dataHistory.datas.add(LabelValue('card_history_ipo_price_label'.tr(), '420'));
      dataHistory.datas.add(LabelValue('card_history_ipo_shares_label'.tr(), '1,85 B'));
      dataHistory.datas.add(LabelValue('card_history_ipo_amount_label'.tr(), '775,43 B'));
      dataHistory.datas.add(LabelValueDivider());
      dataHistory.datas.add(LabelValue('card_history_underwriter_label'.tr(), 'PT Bahana Securities'));
      dataHistory.datas.add(LabelValue(' ', 'PT CIMB-GK Securities Indonesia'));
      dataHistory.datas.add(LabelValue(' ', 'PT Indo Premier Securities'));
      dataHistory.datas.add(LabelValueDivider());
      dataHistory.datas.add(LabelValue('card_history_share_registrar_label'.tr(), 'PT Datindo Entrycom'));


      _historyNotifier.setValue(dataHistory);

      LabelValueData dataShareholders = new LabelValueData();
      dataShareholders.additionalInfo = '(Effective 31 Dec 2020)';
      dataShareholders.datas.add(LabelValuePercent('Negara Republik Indonesia (P)', '5.834.850.000','65,049%'));
      dataShareholders.datas.add(LabelValuePercent('Public', '3.134.001.372','34,939%'));
      dataShareholders.datas.add(LabelValuePercent('Saham Treasury', '1.100.000','0,012%'));
      dataShareholders.datas.add(LabelValueDivider());
      dataShareholders.datas.add(LabelValuePercent('Total', '8.969.951.372','100%'));
      dataShareholders.datas.add(LabelValuePercent('Shareholders Total', '46.105','(+9.423)',valuePercentColor: InvestrendTheme.greenText));
      dataShareholders.datas.add(LabelValueDivider());
      dataShareholders.datas.add(LabelValueSubtitle('Shareholders by BoC and BoD'));
      dataShareholders.datas.add(LabelValuePercent('Ade Wahyu', '457.435','0,0051%'));
      dataShareholders.datas.add(LabelValuePercent('Agung Budi Waskito', '34.200','0,0004%'));

      _shareHolderCompositionNotifier.setValue(dataShareholders);

      LabelValueData dataCommisioners = new LabelValueData();
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_commissioner_label'.tr(), 'Jarot Widyoko'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_commissioner_label'.tr(), 'Phil Foden'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_commissioner_label'.tr(), 'Edy Sudarmanto'));
      dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
      dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
      dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
      dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));
      dataCommisioners.datas.add(LabelValueDivider());
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_director_label'.tr(), 'Agung Budi Waskito'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_director_label'.tr(), 'Agung Budi Waskito'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_director_label'.tr(), 'Edy Sudarmanto'));
      dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
      dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
      dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
      dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));
      _boardOfCommisionersNotifier.setValue(dataCommisioners);





    });
     */
  }

  @override
  void dispose() {
    _showEarningPerShareNotifier.dispose();
    _rangeNotifier?.dispose();
    _incomeStatementNotifier?.dispose();
    _balanceSheetNotifier?.dispose();
    _cashFlowNotifier?.dispose();
    _earningPerShareNotifier?.dispose();
    final container = ProviderContainer();
    container
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);

    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName+' onInactive');
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);
  }
}
