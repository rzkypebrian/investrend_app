import 'dart:math';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/cards/card_earning_pershare.dart';
import 'package:Investrend/component/cards/card_general_price.dart';
import 'package:Investrend/component/cards/card_label_value.dart';
import 'package:Investrend/component/cards/card_local_foreign.dart';
import 'package:Investrend/component/cards/card_performance.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rows/row_general_price.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_screen_tabs.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_portfolio/component/bottom_sheet_list.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_detail.dart';
import 'package:Investrend/screens/trade/screen_trade.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenPortfolioRealized extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  ScreenPortfolioRealized(this.tabIndex, this.tabController, {Key key}) : super(key: key);

  @override
  _ScreenPortfolioRealizedState createState() => _ScreenPortfolioRealizedState(tabIndex, tabController);
}

class _ScreenPortfolioRealizedState extends BaseStateNoTabsWithParentTab<ScreenPortfolioRealized> {
  final RealizedNotifier _realizedDataNotifier = RealizedNotifier(new RealizedStockData());
  final ValueNotifier<bool> _accountNotifier = ValueNotifier<bool>(false);
  final ValueNotifier _rangeNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _sortNotifier = ValueNotifier<int>(0);
  //final ValueNotifier _filterNotifier = ValueNotifier<int>(0);

  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenPortfolioRealizedState(int tabIndex, TabController tabController)
      : super('/portfolio_realized', tabIndex, tabController, parentTabIndex: Tabs.Portfolio.index);

  // @override
  // bool get wantKeepAlive => true;
  List<String> _sort_by_option = [

    'portfolio_stock_sort_by_a_to_z'.tr(),
    'portfolio_stock_sort_by_z_to_a'.tr(),

    // 'portfolio_stock_sort_by_movers_highest'.tr(),
    // 'portfolio_stock_sort_by_movers_lowest'.tr(),

    // 'portfolio_stock_sort_by_market_value_highest'.tr(),
    // 'portfolio_stock_sort_by_market_value_lowest'.tr(),

    'portfolio_stock_sort_by_return_highest'.tr(),
    'portfolio_stock_sort_by_return_lowest'.tr(),

    // 'portfolio_stock_sort_by_return_highest_percent'.tr(),
    // 'portfolio_stock_sort_by_return_lowest_percent'.tr(),


  ];

  List<String> _range_options = [
    //'filter_today_label'.tr(),
    'filter_week_label'.tr(),
    'filter_month_label'.tr(),
    'filter_year_label'.tr(),
    'filter_all_label'.tr(),
  ];
  List<String> _range_type = [
    //'day',
    'week',
    'month',
    'year',
    'all',
  ];


  void sort(){
    switch(_sortNotifier.value){
      case 0: //a_to_z
        {
          _realizedDataNotifier.value.datas.sort((a, b) => a.stockCode.compareTo(b.stockCode));
        }
        break;
      case 1: // z_to_a
        {
          _realizedDataNotifier.value.datas.sort((a, b) => b.stockCode.compareTo(a.stockCode));
        }
        break;
      /*
      case 2: // movers_highest
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) {
            StockSummary summary_a = summarys[a.stockCode];
            StockSummary summary_b = summarys[b.stockCode];
            if(summary_a != null && summary_b != null){
              return summary_b.percentChange.compareTo(summary_a.percentChange);
            }
            return b.stockCode.compareTo(a.stockCode);
          });
        }
        break;
      case 3: // movers_lowest
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) {
            StockSummary summary_a = summarys[a.stockCode];
            StockSummary summary_b = summarys[b.stockCode];
            if(summary_a != null && summary_b != null){
              return summary_a.percentChange.compareTo(summary_b.percentChange);
            }
            return a.stockCode.compareTo(b.stockCode);
          });
        }
        break;
      case 4: // market_value_highest
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) => b.marketVal.compareTo(a.marketVal));
        }
        break;
      case 5: // market_value_lowest
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) => a.marketVal.compareTo(b.marketVal));
        }
        break;

       */
      case 2: // return_highest
        {
          _realizedDataNotifier.value.datas.sort((a, b) => b.gl.compareTo(a.gl));
        }
        break;
      case 3: // return_lowest
        {
          _realizedDataNotifier.value.datas.sort((a, b) => a.gl.compareTo(b.gl));
        }
        break;
      /*
      case 8: // return_highest percent
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) => b.stockGLPct.compareTo(a.stockGLPct));
        }
        break;
      case 9: // return_lowest percent
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) => a.stockGLPct.compareTo(b.stockGLPct));
        }
        break;
        */
    }
    //_updateListNotifier.value = !_updateListNotifier.value;
    _realizedDataNotifier.mustNotifyListeners();
    context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
  }
  final String PROP_SELECTED_SORT       = 'selectedSort';
  final String PROP_SELECTED_RANGE       = 'selectedRange';

  List<String> _filter_options = ['all_stocks_label'.tr()];

  // "choose_date_label": "Select Date",
  // "choose_filter_label": "Select Filter",
  /*
  ValueNotifier<String> _fromNotifier = ValueNotifier<String>('from_label'.tr());
  ValueNotifier<String> _toNotifier = ValueNotifier<String>('to_label'.tr());

  List<String> _range_options = [
    'daily_label'.tr(),
    'weekly_label'.tr(),
    'monthly_label'.tr(),
    'annual_label'.tr(),
  ];
  Widget _options(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(
                    'choose_date_label'.tr(),
                    style: InvestrendTheme.of(context).more_support_w400_compact,
                  )),
              Expanded(
                flex: 5,
                child: ButtonDateRounded(_fromNotifier),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Text(
                  '-',
                  style: InvestrendTheme.of(context).more_support_w400_compact,
                ),
              ),
              Expanded(
                flex: 5,
                child: ButtonDateRounded(_toNotifier),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(
                    'choose_filter_label'.tr(),
                    style: InvestrendTheme.of(context).more_support_w400_compact,
                  )),
              Expanded(flex: 5, child: ButtonDropdown(_filterNotifier, _filter_options)),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Text(
                  '-',
                  style: InvestrendTheme.of(context).more_support_w400_compact,
                ),
              ),
              Expanded(flex: 5, child: ButtonDropdown(_rangeNotifier, _range_options)),
            ],
          ),
        ],
      ),
    );
  }
  */
  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  //int netGainLoss = 149999789;

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");

    final notifier = context.read(accountChangeNotifier);

    User user = context.read(dataHolderChangeNotifier).user;
    Account activeAccount = user.getAccount(notifier.index);
    if (activeAccount == null) {
      print(routeName + '  active Account is NULL');
      return false;
    }

    try {
      if (_realizedDataNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_realizedDataNotifier);
      }
      String range = _range_type.elementAt(_rangeNotifier.value);
      final result = await InvestrendTheme.tradingHttp.realizedStock(activeAccount.brokercode, activeAccount.accountcode, user.username, range,
          InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future realizedStock DATA : ' + result.toString());
        if (mounted) {
          _realizedDataNotifier.setValue(result);
          sort();
        }
      } else {
        print(routeName + ' Future realizedStock NO DATA');
        setNotifierNoData(_realizedDataNotifier);
      }
    } catch (error) {
      print(routeName + ' Future realizedStock Error');
      print(error);
      setNotifierError(_realizedDataNotifier, error.toString());
      handleNetworkError(context, error);
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [



      //_options(context),
      Row(
        children: [
          SizedBox(width: InvestrendTheme.cardPaddingGeneral,),
          ButtonDropdown(_rangeNotifier, _range_options),
          Spacer(flex: 1,),
        ],
      ),

      Padding(
        padding: const EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral,
            top: InvestrendTheme.cardPaddingGeneral,
            bottom: InvestrendTheme.cardPaddingGeneral),
        child: Row(
          children: [
            Text(
              'net_gain_loss_label'.tr(),
              style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
            SizedBox(
              width: 5.0,
            ),
            //Icon(Icons.info_outline, size: 15.0),
            Image.asset('images/icons/information.png', width: 10.0, height: 10.0),
          ],
        ),
      ),
      /*
      Padding(
        padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
        child: ValueListenableBuilder(
          valueListenable: _accountNotifier,
          builder: (context, data, child) {
            User user = context.read(dataHolderChangeNotifier).user;
            Account activeAccount = user.getAccount(context.read(accountChangeNotifier).index);
            int netGainLoss = 0;
            if(activeAccount != null){
              AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
              if(accountInfo != null){
                netGainLoss = accountInfo.totalGL;
              }
            }
            return Text(
              InvestrendTheme.formatMoney(netGainLoss, prefixRp: true, prefixPlus: true),
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: InvestrendTheme.priceTextColor(netGainLoss), fontWeight: FontWeight.w600),
            );
          },
        ),
      ),
      */
      Padding(
        padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
        child: ValueListenableBuilder(
          valueListenable: _realizedDataNotifier,
          builder: (context, RealizedStockData data, child) {

            Widget noWidget = _realizedDataNotifier.currentState.getNoWidget(onRetry: (){
              doUpdate(pullToRefresh: true);
            });

            String text = '';
            if(noWidget != null){
              //return Center(child: noWidget);
              text = '';
              // return Text(
              //   '',
              //   style: Theme.of(context)
              //       .textTheme
              //       .headline4
              //       .copyWith(color: InvestrendTheme.changeTextColor(data.totalGL), fontWeight: FontWeight.w600),
              // );
            }else{
              text = InvestrendTheme.formatMoneyDouble(data.totalGL, prefixRp: true, prefixPlus: true);
            }
            return Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: InvestrendTheme.changeTextColor(data.totalGL), fontWeight: FontWeight.w600),
            );

          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral,
            top: 20.0,
            //bottom: InvestrendTheme.cardPaddingGeneral
        ),
        //padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
        child: Row(
          children: [
            ComponentCreator.subtitle(context, 'detail_label'.tr()),
            Spacer(
              flex: 1,
            ),
            ButtonDropdown(_sortNotifier, _sort_by_option, clickAndClose: true,showEmojiDescendingAscending: true,),
          ],
        ),
      ),
      ValueListenableBuilder(
        valueListenable: _realizedDataNotifier,
        builder: (context, RealizedStockData data, child) {
          // if (_realizedDataNotifier.invalid()) {
          //   return Center(child: CircularProgressIndicator());
          // }
          Widget noWidget = _realizedDataNotifier.currentState.getNoWidget(onRetry: (){
            doUpdate(pullToRefresh: true);
          });
          if(noWidget != null){
            return Center(child: noWidget);
          }
          return tableRealized(context, data);
        },
      ),

      SizedBox(
        height: paddingBottom ,
      ),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
        shrinkWrap: false,
        children: childs,
      ),
    );
  }
  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingPlusMargin, bottom: InvestrendTheme.cardPaddingPlusMargin),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingPlusMargin,
                  right: InvestrendTheme.cardPaddingPlusMargin,
                  top: InvestrendTheme.cardPaddingPlusMargin,
                  bottom: InvestrendTheme.cardPaddingPlusMargin),
              child: Row(
                children: [
                  Text(
                    'Net Gain/Loss',
                    style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  //Icon(Icons.info_outline, size: 15.0),
                  Image.asset('images/icons/information.png', width: 10.0, height: 10.0),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin),
              child: ValueListenableBuilder(
                valueListenable: _accountNotifier,
                builder: (context, data, child) {
                  User user = context.read(dataHolderChangeNotifier).user;
                  Account activeAccount = user.getAccount(context.read(accountChangeNotifier).index);
                  int netGainLoss = 0;
                  if(activeAccount != null){
                    AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
                    if(accountInfo != null){
                      netGainLoss = accountInfo.totalGL;
                    }
                  }
                  return Text(
                    InvestrendTheme.formatMoney(netGainLoss, prefixRp: true, prefixPlus: true),
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: InvestrendTheme.priceTextColor(netGainLoss), fontWeight: FontWeight.w700),
                  );
                },
              ),
            ),
            /*
            Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin),
              child: Text(
                InvestrendTheme.formatMoney(netGainLoss, prefixRp: true, prefixPlus: true),
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: InvestrendTheme.priceTextColor(netGainLoss), fontWeight: FontWeight.w700),
              ),
            ),
            */
            SizedBox(height: 20.0),
            _options(context),
            //SizedBox(height: 20.0),
            //ComponentCreator.divider(context),
            //SizedBox(height: 20.0,),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingPlusMargin,
                  right: InvestrendTheme.cardPaddingPlusMargin,
                  top: 20.0,
                  bottom: InvestrendTheme.cardPaddingPlusMargin),
              //padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
              child: ComponentCreator.subtitle(context, 'card_activity_rdn_title'.tr()),
            ),
            ValueListenableBuilder(
              valueListenable: _realizedDataNotifier,
              builder: (context, RealizedData data, child) {
                if (_realizedDataNotifier.invalid()) {
                  return Center(child: CircularProgressIndicator());
                }
                return tableRealized(context, data);
              },
            ),

            SizedBox(
              height: paddingBottom + 80,
            ),
          ],
        ),
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName + ' onActive');
    doUpdate();
  }

  @override
  void initState() {
    super.initState();
    _sortNotifier.addListener(sort);
    _rangeNotifier.addListener(() {
      context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_RANGE, _rangeNotifier.value);
    });
    runPostFrame((){
      // #1 get properties
      int selectedSort = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_SORT, 0);
      int selectedRange = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_RANGE, 0);

      // #2 use properties
      _sortNotifier.value = min(selectedSort, _sort_by_option.length - 1) ;
      _rangeNotifier.value = min(selectedRange, _range_options.length - 1) ;

      // #3 check properties if changed, then save again
      if(selectedSort != _sortNotifier.value){
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
      }
      if(selectedRange != _rangeNotifier.value){
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_RANGE, _sortNotifier.value);
      }
    });
    /*
    Future.delayed(Duration(milliseconds: 500), () {
      RealizedData dataMovers = RealizedData();
      dataMovers.datas.add(Realized('WIKA', '28/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Realized('WIKA', '27/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Realized('WIKA', '26/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Realized('WIKA', '25/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Realized('WIKA', '24/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Realized('WIKA', '23/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Realized('WIKA', '22/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Realized('WIKA', '21/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Realized('WIKA', '20/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Realized('WIKA', '19/01/2021', 3000000, 1.96));
      _realizedDataNotifier.setValue(dataMovers);
    });
    */


    _rangeNotifier.addListener(() {
      if(mounted){
        doUpdate(pullToRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _realizedDataNotifier.dispose();
    _rangeNotifier.dispose();
    _accountNotifier.dispose();
    _sortNotifier.dispose();
    final container = ProviderContainer();
    if (_activeAccountChangedListener != null) {
      container.read(accountChangeNotifier).removeListener(_activeAccountChangedListener);
    }

    super.dispose();
  }

  VoidCallback _activeAccountChangedListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_activeAccountChangedListener != null) {
      context.read(accountChangeNotifier).removeListener(_activeAccountChangedListener);
    } else {
      _activeAccountChangedListener = () {
        if (mounted) {
          bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          if (hasAccount) {
            _accountNotifier.value = !_accountNotifier.value;
            doUpdate(pullToRefresh: true);
          }
        }
      };
    }
    context.read(accountChangeNotifier).addListener(_activeAccountChangedListener);

    /*
    context.read(accountChangeNotifier).addListener(() {
      if(mounted){
        _accountNotifier.value = !_accountNotifier.value;
      }
    });
    */

    context.read(accountsInfosNotifier).addListener(() {
      if(mounted){
        _accountNotifier.value = !_accountNotifier.value;
      }
    });
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
  }

  Widget tableRealized(BuildContext context, RealizedStockData data) {
    TextStyle small500 = InvestrendTheme.of(context).small_w500;
    TextStyle small400 = InvestrendTheme.of(context).small_w400;
    TextStyle smallLighter400 = small400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    TextStyle smallDarker400 = small400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle reguler700 = InvestrendTheme.of(context).regular_w600;

    const double paddingTopBottom = 15.0;
    const double paddingHeaderTopBottom = 10.0;
    List<TableRow> list = List.empty(growable: true);
    list.add(TableRow(children: [
      // Padding(
      //   padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
      //   child: Text('date_label'.tr(), style: small500),
      // ),
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        child: Text('stock_label'.tr(), style: small500),
      ),
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        //child: Text('value_label'.tr(), style: small500, textAlign: TextAlign.left),
        child: Text('value_not_include_fee_label'.tr(), style: small500, textAlign: TextAlign.left),
      ),
      // Padding(
      //   padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
      //   child: Text(
      //     'yield_percent_label'.tr(),
      //     style: small500,
      //     textAlign: TextAlign.right,
      //   ),
      // ),
    ]));

    if (data.count() > 0) {
      bool first = true;
      data.datas.forEach((rdn) {
        if (!first) {
          list.add(TableRow(children: [
            // ComponentCreator.divider(context),
            ComponentCreator.divider(context),
            ComponentCreator.divider(context),
            // ComponentCreator.divider(context),
          ]));
        }
        first = false;

        GestureTapCallback onTap = () {
          print('onTap rdn : ' + rdn.date);

          int quantity_lot = rdn.lot;
          double average_buy = rdn.avgBuy;
          double average_sell = rdn.avgSell;
          int sell_value = rdn.valueSell;
          double gain_loss = rdn.gl;
          double yield = rdn.yield;

          List<LabelValueColor> listLVC = [
            LabelValueColor(
              'portfolio_detail_stock_code_label'.tr(),
              rdn.stockCode,
            ),
            LabelValueColor(
              'portfolio_detail_quantity_lot_label'.tr(),
              InvestrendTheme.formatComma(quantity_lot),
            ),
            LabelValueColor(
              'portfolio_detail_average_buy_label'.tr(),
              InvestrendTheme.formatPriceDouble(average_buy),
            ),
            LabelValueColor(
              'portfolio_detail_average_sell_label'.tr(),
              InvestrendTheme.formatPriceDouble(average_sell),
            ),
            LabelValueColor(
              'portfolio_detail_sell_value_label'.tr(),
              InvestrendTheme.formatMoney(sell_value),
            ),
            LabelValueColor('portfolio_detail_gain_loss_label'.tr(), InvestrendTheme.formatMoneyDouble(gain_loss, prefixPlus: true, prefixRp: true),
                color: InvestrendTheme.changeTextColor(rdn.gl)),
            LabelValueColor(
              'portfolio_detail_yield_label'.tr(),
              InvestrendTheme.formatPercent(yield),
            ),
          ];

          InvestrendTheme.push(
              context, ScreenPortfolioDetail(rdn.stockCode, rdn.gl, rdn.date, listLVC), ScreenTransition.SlideUp, '/portfolio_detail');
        };

        Color colorValue = InvestrendTheme.changeTextColor(rdn.gl);
        list.add(TableRow(children: [
          // TableRowInkWell(
          //   onTap: onTap,
          //   child: Padding(
          //     padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
          //     child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(rdn.date, style: smallDarker400)),
          //   ),
          // ),
          TableRowInkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
              child: Text(rdn.stockCode, style: smallLighter400),
            ),
          ),
          TableRowInkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
              child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    InvestrendTheme.formatMoneyDouble(rdn.gl, prefixRp: true),
                    style: reguler700.copyWith(color: colorValue),
                    textAlign: TextAlign.left,
                  )),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
          //   child: Text(
          //     InvestrendTheme.formatPercentChange(rdn.yield, sufixPercent: false),
          //     style: smallDarker400,
          //     textAlign: TextAlign.right,
          //   ),
          // ),
        ]));
      });
    }

    return Padding(
      padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.25),
          // 1: FractionColumnWidth(.15),
          // 2: FractionColumnWidth(.38),
          // 3: FractionColumnWidth(.22),
        },
        children: list,
      ),
    );
  }
}
/*
class ReturnBottomSheet extends StatelessWidget {
  final ValueNotifier returnTypeNotifier;
  final List<String> return_options;

  const ReturnBottomSheet(this.returnTypeNotifier, this.return_options, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    double contentHeight = padding + 44.0 + (44.0 * return_options.length) + padding;

    //if (contentHeight > minHeight) {
    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);
    //}

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        padding: EdgeInsets.all(padding),
        // color: Colors.yellow,
        width: double.maxFinite,
        child: ValueListenableBuilder(
          valueListenable: returnTypeNotifier,
          builder: (context, selectedIndex, child) {
            List<Widget> list = List.empty(growable: true);
            list.add(Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(Icons.clear),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ));
            int count = return_options.length;
            for (int i = 0; i < count; i++) {
              String ca = return_options.elementAt(i);
              list.add(createRow(context, ca, selectedIndex == i, i));
            }
            return Column(
              children: list,
            );
          },
        ),
      ),
    );
  }

  Widget createRow(BuildContext context, String label, bool selected, int index) {
    TextStyle style = InvestrendTheme.of(context).regular_w400_compact;
    //Color colorText = style.color;
    Color colorIcon = Colors.transparent;

    if (selected) {
      style = InvestrendTheme.of(context).regular_w700_compact.copyWith(color: Theme.of(context).accentColor);
      //colorText = Theme.of(context).accentColor;
      colorIcon = Theme.of(context).accentColor;
    }

    return SizedBox(
      height: 44.0,
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.0,
              height: 20.0,
            ),
            Expanded(
                flex: 1,
                child: Text(
                  label,
                  style: style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
                  textAlign: TextAlign.center,
                )),
            (selected
                ? Image.asset(
                    'images/icons/check.png',
                    color: colorIcon,
                    width: 20.0,
                    height: 20.0,
                  )
                : SizedBox(
                    width: 20.0,
                    height: 20.0,
                  )),
          ],
        ),
        onPressed: () {
          // setState(() {
          //   selectedIndex = index;
          // });
          //context.read(marketChangeNotifier).setIndex(index);
          returnTypeNotifier.value = index;
        },
      ),
    );
  }
}

 */
