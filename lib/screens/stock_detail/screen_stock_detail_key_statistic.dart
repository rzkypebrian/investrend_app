import 'package:Investrend/component/cards/card_earning_pershare.dart';
import 'package:Investrend/component/cards/card_label_value.dart';
import 'package:Investrend/component/cards/card_local_foreign.dart';
import 'package:Investrend/component/cards/card_performance.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenStockDetailKeyStatistic extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;
  ScreenStockDetailKeyStatistic(this.tabIndex, this.tabController,  {Key key, this.visibilityNotifier}) : super( key: key);

  @override
  _ScreenStockDetailKeyStatisticState createState() => _ScreenStockDetailKeyStatisticState(tabIndex, tabController,visibilityNotifier: visibilityNotifier);

}

class _ScreenStockDetailKeyStatisticState extends BaseStateNoTabsWithParentTab<ScreenStockDetailKeyStatistic>
{
  EarningPerShareNotifier _earningPerShareNotifier = EarningPerShareNotifier(EarningPerShareData.createBasic());
  LabelValueNotifier _performanceYTDNotifier = LabelValueNotifier(new LabelValueData());
  LabelValueNotifier _balanceSheetNotifier = LabelValueNotifier(new LabelValueData());
  LabelValueNotifier _valuationNotifier = LabelValueNotifier(new LabelValueData());
  LabelValueNotifier _perShareNotifier = LabelValueNotifier(new LabelValueData());
  LabelValueNotifier _profitabilityNotifier = LabelValueNotifier(new LabelValueData());
  LabelValueNotifier _liquidityNotifier = LabelValueNotifier(new LabelValueData());

  // LocalForeignNotifier _localForeignNotifier = LocalForeignNotifier(new LocalForeignData());
  // PerformanceNotifier _performanceNotifier = PerformanceNotifier(new PerformanceData());

  // _localForeignNotifier = LocalForeignNotifier(new LocalForeignData());
  // _performanceNotifier = PerformanceNotifier(new PerformanceData());

  _ScreenStockDetailKeyStatisticState(int tabIndex, TabController tabController,{ValueNotifier<bool> visibilityNotifier})
      : super('/stock_detail_key_statistic', tabIndex, tabController, notifyStockChange: true,visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;



  @override
  void onStockChanged(Stock newStock) {
    super.onStockChanged(newStock);
    doUpdate(pullToRefresh: true);
  }
  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString());
    if( !active ){
      print(routeName + '.doUpdate aborted active : $active' );
      return;
    }
    Stock stock = context.read(primaryStockChangeNotifier).stock;
    if (stock == null || !stock.isValid()) {
      Stock stockDefault = InvestrendTheme.storedData.listStock.isEmpty ? null : InvestrendTheme.storedData.listStock.first;
      context.read(primaryStockChangeNotifier).setStock(stockDefault);
      stock = context.read(primaryStockChangeNotifier).stock;
    }
    String code = stock != null ? stock.code : "";
    if( !StringUtils.isEmtpy(code) ){
      setNotifierLoading(_earningPerShareNotifier);
      setNotifierLoading(_performanceYTDNotifier);
      setNotifierLoading(_balanceSheetNotifier);
      setNotifierLoading(_valuationNotifier);
      setNotifierLoading(_perShareNotifier);
      setNotifierLoading(_profitabilityNotifier);
      setNotifierLoading(_liquidityNotifier);

      try {
        int close = context.read(stockSummaryChangeNotifier).summary.close;
        final result = await InvestrendTheme.datafeedHttp.fetchKeyStatistic(code, close.toString());
        if(result != null && !result.isEmpty()){
          if(mounted){
            //_groupedNotifier.setValue(groupedData);
            _earningPerShareNotifier.setValue(result.earningPerShare);

            LabelValueData dataPerformanceYTD = new LabelValueData();
            dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_sales_label'.tr(), InvestrendTheme.formatValue(context, result.sales)));
            dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_operating_profit_label'.tr(), InvestrendTheme.formatValue(context, result.operating_profit)));
            dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_net_profit_label'.tr(), InvestrendTheme.formatValue(context, result.net_profit)));
            dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_cash_flow_label'.tr(), InvestrendTheme.formatValue(context, result.cash_flow), valueColor: InvestrendTheme.priceTextColor(result.cash_flow)));

            _performanceYTDNotifier.setValue(dataPerformanceYTD);

            LabelValueData dataBalanceSheet = new LabelValueData();
            dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_assets_label'.tr(), InvestrendTheme.formatValue(context, result.assets)));
            dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_cash_and_equiv_label'.tr(), InvestrendTheme.formatValue(context, result.cash_and_equiv)));
            dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_liability_label'.tr(), InvestrendTheme.formatValue(context, result.liability)));
            dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_debt_label'.tr(), InvestrendTheme.formatValue(context, result.debt)));
            dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_equity_label'.tr(), InvestrendTheme.formatValue(context, result.equity)));

            _balanceSheetNotifier.setValue(dataBalanceSheet);

            LabelValueData dataValuation = new LabelValueData();
            dataValuation.datas.add(LabelValue('card_valuation_price_earning_ratio_label'.tr(), InvestrendTheme.formatPercent(result.price_earning_ratio, sufixPercent: false, prefixPlus: false)+'x'));
            dataValuation.datas.add(LabelValue('card_valuation_price_sales_ratio_label'.tr(), InvestrendTheme.formatPercent(result.price_sales_ratio, sufixPercent: false, prefixPlus: false)+'x'));
            dataValuation.datas.add(LabelValue('card_valuation_price_book_value_ratio_label'.tr(), InvestrendTheme.formatPercent(result.price_book_value_ratio, sufixPercent: false, prefixPlus: false)+'x'));
            dataValuation.datas.add(LabelValue('card_valuation_price_cash_flow_ratio_label'.tr(), InvestrendTheme.formatPercent(result.price_cash_flow_ratio, sufixPercent: false, prefixPlus: false)+'x', valueColor: InvestrendTheme.changeTextColor(result.price_cash_flow_ratio)));
            dataValuation.datas.add(LabelValue('card_valuation_dividend_yield_label'.tr(), InvestrendTheme.formatPercentChange(result.dividend_yield)));

            _valuationNotifier.setValue(dataValuation);

            LabelValueData dataPerShare = new LabelValueData();
            dataPerShare.datas.add(LabelValue('card_per_share_earning_per_share_label'.tr(), InvestrendTheme.formatPrice(result.earning_per_share)));
            dataPerShare.datas.add(LabelValue('card_per_share_dividend_per_share_label'.tr(), InvestrendTheme.formatPrice(result.dividend_per_share)));
            dataPerShare.datas.add(LabelValue('card_per_share_revenue_per_share_label'.tr(), InvestrendTheme.formatPrice(result.revenue_per_share)));
            dataPerShare.datas.add(LabelValue('card_per_share_book_value_per_share_label'.tr(), InvestrendTheme.formatPrice(result.book_value_per_share)));
            dataPerShare.datas.add(LabelValue('card_per_share_cash_equiv_per_share_label'.tr(), InvestrendTheme.formatPrice(result.cash_equiv_per_share)));
            dataPerShare.datas.add(LabelValue('card_per_share_cash_flow_per_share_label'.tr(), InvestrendTheme.formatPrice(result.cash_flow_per_share), valueColor: InvestrendTheme.priceTextColor(result.cash_flow_per_share)));
            dataPerShare.datas.add(LabelValue('card_per_share_net_assets_per_share_label'.tr(), InvestrendTheme.formatPrice(result.net_assets_per_share)));

            _perShareNotifier.setValue(dataPerShare);

            LabelValueData dataProfitability = new LabelValueData();
            dataProfitability.datas.add(LabelValue('card_profitability_operating_profit_margin_label'.tr(), InvestrendTheme.formatPercent(result.operating_profit_margin, prefixPlus: false)));
            dataProfitability.datas.add(LabelValue('card_profitability_net_profit_margin_label'.tr(), InvestrendTheme.formatPercent(result.net_profit_margin, prefixPlus: false)));
            dataProfitability.datas.add(LabelValue('card_profitability_return_on_equity_label'.tr(), InvestrendTheme.formatPercent(result.return_on_equity, prefixPlus: false)));
            dataProfitability.datas.add(LabelValue('card_profitability_return_on_assets_label'.tr(), InvestrendTheme.formatPercent(result.return_on_assets, prefixPlus: false)));

            _profitabilityNotifier.setValue(dataProfitability);

            LabelValueData dataLiquidity = new LabelValueData();
            dataLiquidity.datas.add(LabelValue('card_liquidity_debt_equity_ratio_label'.tr(), InvestrendTheme.formatPercent(result.debt_equity_ratio, prefixPlus: false)));
            dataLiquidity.datas.add(LabelValue('card_liquidity_current_ratio_label'.tr(), InvestrendTheme.formatPercent(result.current_ratio, prefixPlus: false)));
            dataLiquidity.datas.add(LabelValue('card_liquidity_cash_ratio_label'.tr(), InvestrendTheme.formatPercent(result.cash_ratio, prefixPlus: false)));

            _liquidityNotifier.setValue(dataLiquidity);
          }
        }else{
          //setNotifierNoData(_groupedNotifier);
          setNotifierNoData(_earningPerShareNotifier);
          setNotifierNoData(_performanceYTDNotifier);
          setNotifierNoData(_balanceSheetNotifier);
          setNotifierNoData(_valuationNotifier);
          setNotifierNoData(_perShareNotifier);
          setNotifierNoData(_profitabilityNotifier);
          setNotifierNoData(_liquidityNotifier);
        }

      } catch (error) {
        //setNotifierError(_groupedNotifier, error);
        print(error);
        setNotifierError(_earningPerShareNotifier, error);
        setNotifierError(_performanceYTDNotifier, error);
        setNotifierError(_balanceSheetNotifier, error);
        setNotifierError(_valuationNotifier, error);
        setNotifierError(_perShareNotifier, error);
        setNotifierError(_profitabilityNotifier, error);
        setNotifierError(_liquidityNotifier, error);
      }
    }



    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }
  Future onRefresh() {
    context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    if(!active){
      active = true;
      //onActive();
      context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      CardEarningPerShare(_earningPerShareNotifier, onRetry: (){
        doUpdate(pullToRefresh: true);
      },),
      CardLabelValueNotifier('card_performance_ytd_title'.tr(), _performanceYTDNotifier),
      ComponentCreator.divider(context),
      CardLabelValueNotifier('card_balance_sheet_title'.tr(), _balanceSheetNotifier),
      ComponentCreator.divider(context),
      CardLabelValueNotifier('card_valuation_title'.tr(), _valuationNotifier),
      ComponentCreator.divider(context),
      CardLabelValueNotifier('card_per_share_title'.tr(), _perShareNotifier),
      ComponentCreator.divider(context),
      CardLabelValueNotifier('card_profitability_title'.tr(), _profitabilityNotifier),
      ComponentCreator.divider(context),
      CardLabelValueNotifier('card_liquidity_title'.tr(), _liquidityNotifier),
      SizedBox(height: paddingBottom + 80,),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
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
        children: [
          CardEarningPerShare(_earningPerShareNotifier),
          // SizedBox(height: 16.0,),
          //SizedBox(height: 16.0,),
          //ComponentCreator.divider(context),
          // SizedBox(height: 16.0,),
          // CardPerformance(_performanceNotifier),
          CardLabelValueNotifier('card_performance_ytd_title'.tr(), _performanceYTDNotifier),
          ComponentCreator.divider(context),
          CardLabelValueNotifier('card_balance_sheet_title'.tr(), _balanceSheetNotifier),
          ComponentCreator.divider(context),
          CardLabelValueNotifier('card_valuation_title'.tr(), _valuationNotifier),
          ComponentCreator.divider(context),
          CardLabelValueNotifier('card_per_share_title'.tr(), _perShareNotifier),
          ComponentCreator.divider(context),
          CardLabelValueNotifier('card_profitability_title'.tr(), _profitabilityNotifier),
          ComponentCreator.divider(context),
          CardLabelValueNotifier('card_liquidity_title'.tr(), _liquidityNotifier),

          SizedBox(height: paddingBottom + 80,),
        ],
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName+' onActive');
    context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    doUpdate();
  }


  @override
  void initState() {
    super.initState();
/*
    Future.delayed(Duration(milliseconds: 500),(){

      EarningPerShareData data = EarningPerShareData.createBasic();
      data.years[0] = 2017;
      data.years[1] = 2018;
      data.years[2] = 2019;
      data.years[3] = 2020;

      data.quarter1[0] = 27;
      data.quarter1[1] = 19;
      data.quarter1[2] = 32;
      data.quarter1[3] = 11;

      data.quarter2[0] = 21;
      data.quarter2[1] = 39;
      data.quarter2[2] = 67;
      data.quarter2[3] = 17;

      data.quarter3[0] = 28;
      data.quarter3[1] = 38;
      data.quarter3[2] = 51;
      data.quarter3[3] = -22;

      data.quarter4[0] = 58;
      data.quarter4[1] = 97;
      data.quarter4[2] = 104;
      data.quarter4[3] = 15;

      data.eps[0] = 134;
      data.eps[1] = 193;
      data.eps[2] = 255;
      data.eps[3] = 21;

      data.dps[0] = 26.8;
      data.dps[1] = 38.6;
      data.dps[2] = 50.9;
      data.dps[3] = 0.0;

      data.dpr[0] = 20;
      data.dpr[1] = 30;
      data.dpr[2] = 25.4;
      data.dpr[3] = 0.0;
      data.recentQuarter = '31 Mar 2021';
      _earningPerShareNotifier.setValue(data);


      LabelValueData dataPerformanceYTD = new LabelValueData();
      dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_sales_label'.tr(), '10,384 T'));
      dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_operating_profit_label'.tr(), '277,51 B'));
      dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_net_profit_label'.tr(), '50.19 B'));
      dataPerformanceYTD.datas.add(LabelValue('card_performance_ytd_cash_flow_label'.tr(), '-5,77 T', valueColor: InvestrendTheme.redText));

      _performanceYTDNotifier.setValue(dataPerformanceYTD);

      LabelValueData dataBalanceSheet = new LabelValueData();
      dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_assets_label'.tr(), '61,43 T'));
      dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_cash_and_equiv_label'.tr(), '5,7 B'));
      dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_liability_label'.tr(), '47,91 B'));
      dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_debt_label'.tr(), '11,23 T'));
      dataBalanceSheet.datas.add(LabelValue('card_balance_sheet_equity_label'.tr(), '13,52 T'));

      _balanceSheetNotifier.setValue(dataBalanceSheet);

      LabelValueData dataValuation = new LabelValueData();
      dataValuation.datas.add(LabelValue('card_valuation_price_earning_ratio_label'.tr(), '263,38x'));
      dataValuation.datas.add(LabelValue('card_valuation_price_sales_ratio_label'.tr(), '1,27x'));
      dataValuation.datas.add(LabelValue('card_valuation_price_book_value_ratio_label'.tr(), '1,30x'));
      dataValuation.datas.add(LabelValue('card_valuation_price_cash_flow_ratio_label'.tr(), '-2,29x', valueColor: InvestrendTheme.redText));
      dataValuation.datas.add(LabelValue('card_valuation_dividend_yield_label'.tr(), '2,59%'));

      _valuationNotifier.setValue(dataValuation);

      LabelValueData dataPerShare = new LabelValueData();
      dataPerShare.datas.add(LabelValue('card_per_share_earning_per_share_label'.tr(), '7'));
      dataPerShare.datas.add(LabelValue('card_per_share_dividend_per_share_label'.tr(), '50.955'));
      dataPerShare.datas.add(LabelValue('card_per_share_revenue_per_share_label'.tr(), '1543'));
      dataPerShare.datas.add(LabelValue('card_per_share_book_value_per_share_label'.tr(), '1508'));
      dataPerShare.datas.add(LabelValue('card_per_share_cash_equiv_per_share_label'.tr(), '1508'));
      dataPerShare.datas.add(LabelValue('card_per_share_cash_flow_per_share_label'.tr(), '-857', valueColor: InvestrendTheme.redText));
      dataPerShare.datas.add(LabelValue('card_per_share_net_assets_per_share_label'.tr(), '1803'));

      _perShareNotifier.setValue(dataPerShare);

      LabelValueData dataProfitability = new LabelValueData();
      dataProfitability.datas.add(LabelValue('card_profitability_operational_profit_margin_label'.tr(), '2,67%'));
      dataProfitability.datas.add(LabelValue('card_profitability_net_profit_margin_label'.tr(), '0,48%'));
      dataProfitability.datas.add(LabelValue('card_profitability_return_on_equity_label'.tr(), '0,49%'));
      dataProfitability.datas.add(LabelValue('card_profitability_return_on_assets_label'.tr(), '0,11%'));

      _profitabilityNotifier.setValue(dataProfitability);

      LabelValueData dataLiquidity = new LabelValueData();
      dataLiquidity.datas.add(LabelValue('card_liquidity_debt_equity_ratio_label'.tr(), '334,67%'));
      dataLiquidity.datas.add(LabelValue('card_liquidity_current_ratio_label'.tr(), '101,18%'));
      dataLiquidity.datas.add(LabelValue('card_liquidity_cash_ratio_label'.tr(), '19,13%'));

      _liquidityNotifier.setValue(dataLiquidity);

    });
    */

  }
  /*
  void onSummaryChanged(){

    bool notMounted   = !mounted;
    if(notMounted){
      print(routeName+' stockSummaryChangeNotifier aborted -->  notMounted : $notMounted');
      return;
    }

    bool contexIsNull = context == null;
    if(contexIsNull){
      print(routeName+' stockSummaryChangeNotifier aborted -->  contexIsNull : $contexIsNull');
      return;
    }


    print(routeName+' stockSummaryChangeNotifier called');
    LocalForeignData lf = LocalForeignData();
    _localForeignNotifier.setValue(lf);

    StockSummary summary = context.read(stockSummaryChangeNotifier).summary;
    PerformanceData pd = PerformanceData();
    pd.intraday_change = summary.change;
    pd.intraday_percent_change = summary.percentChange;
    pd.year_1_percent_change = summary.returnYTD;
    pd.year_1_change = summary.returnYTD;

    pd.month_1_percent_change = summary.returnMTD;
    pd.month_1_change = summary.returnMTD;
    _performanceNotifier.setValue(pd);

  }

  // bool listenerAdded = false;
  // VoidCallback summaryListener = VoidCallback(){
  //   print(routeName+' summaryListener called');
  // };
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // if(listenerAdded){
    //   context.read(stockSummaryChangeNotifier).removeListener(summaryListener);
    // }
    context.read(stockSummaryChangeNotifier).addListener(onSummaryChanged);


  }
  */


  @override
  void dispose() {
    _earningPerShareNotifier.dispose();
    _performanceYTDNotifier.dispose();
    _balanceSheetNotifier.dispose();
    _valuationNotifier.dispose();
    _perShareNotifier.dispose();
    _profitabilityNotifier.dispose();
    _liquidityNotifier.dispose();
    // _localForeignNotifier.dispose();
    // _performanceNotifier.dispose();
    final container = ProviderContainer();
    container.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, false);
    super.dispose();
  }



  @override
  void onInactive() {
    //print(routeName+' onInactive');
    context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, false);
  }
}
