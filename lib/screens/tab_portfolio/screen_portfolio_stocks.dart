import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/button_account.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/button_outlined_rounded.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/rows/row_stock_position.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/component/text_button_retry.dart';
import 'package:Investrend/component/widget_returns.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/group_style.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_portfolio/screen_detail_portfolio.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenPortfolioStocks extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  ScreenPortfolioStocks(this.tabIndex, this.tabController, {Key key}) : super(key: key);

  @override
  _ScreenPortfolioStocksState createState() => _ScreenPortfolioStocksState(tabIndex, tabController);
}


class WrapperPortfolioWithSummary{
  StockSummary summary;
  StockPositionDetail portfolio;


}
class _ScreenPortfolioStocksState extends BaseStateNoTabsWithParentTab<ScreenPortfolioStocks> {
  //ChartNotifier _chartNotifier = ChartNotifier(ChartLineData());
  final SlidableController slidableController = SlidableController();
  final ValueNotifier<int> _sortNotifier = ValueNotifier<int>(0);
  //PortfolioNotifier _portfolioNotifier = PortfolioNotifier(new PortfolioData());
  StockPositionNotifier _stockPositionNotifier = StockPositionNotifier(new StockPosition('', 0, 0, 0, 0, 0, 0, List.empty(growable: true)));
  final ValueNotifier<bool> _accountNotifier = ValueNotifier<bool>(false);

  final BaseValueNotifier<bool> _updateListNotifier = BaseValueNotifier<bool>(false);

  GroupStyle groupStyle = GroupStyle();

  List<WrapperPortfolioWithSummary> listDisplay = List.empty(growable: true);
  Map summarys = new Map();
  static const Duration durationUpdate = Duration(milliseconds: 1000);
  Timer timer;
  bool canTapRow = true;

  List<String> _sort_by_option = [

    'portfolio_stock_sort_by_a_to_z'.tr(),
    'portfolio_stock_sort_by_z_to_a'.tr(),

    'portfolio_stock_sort_by_movers_highest'.tr(),
    'portfolio_stock_sort_by_movers_lowest'.tr(),

    'portfolio_stock_sort_by_market_value_highest'.tr(),
    'portfolio_stock_sort_by_market_value_lowest'.tr(),

    'portfolio_stock_sort_by_return_highest'.tr(),
    'portfolio_stock_sort_by_return_lowest'.tr(),

    'portfolio_stock_sort_by_return_highest_percent'.tr(),
    'portfolio_stock_sort_by_return_lowest_percent'.tr(),


  ];


  _ScreenPortfolioStocksState(int tabIndex, TabController tabController)
      : super('/portfolio_stocks', tabIndex, tabController, parentTabIndex: Tabs.Portfolio.index);


  void sort(){
    switch(_sortNotifier.value){
      case 0: //a_to_z
        {
          //numbers.sort((a, b) => a.length.compareTo(b.length));
          _stockPositionNotifier.value.stocksList.sort((a, b) => a.stockCode.compareTo(b.stockCode));
        }
        break;
      case 1: // z_to_a
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) => b.stockCode.compareTo(a.stockCode));
        }
        break;
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
      case 6: // return_highest
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) => b.stockGL.compareTo(a.stockGL));
        }
        break;
      case 7: // return_lowest
        {
          _stockPositionNotifier.value.stocksList.sort((a, b) => a.stockGL.compareTo(b.stockGL));
        }
        break;
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

    }
    _updateListNotifier.value = !_updateListNotifier.value;
    context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
  }
  bool onProgress = false;
  Future doUpdate({bool pullToRefresh = false}) async {
    if(!active){
      print(routeName+' doUpdate ignored active : $active');
      return false;
    }
    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if(!isForeground){
        print(routeName + ' doUpdate ignored isForeground : $isForeground  isVisible : ' + isVisible().toString());
        return false;
      }
    }
    print(routeName+' doUpdate perform at : '+DateTime.now().toString());
    onProgress = true;
    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (hasAccount) {
      int selected = context.read(accountChangeNotifier).index;
      Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
      if (account == null) {
        //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
        //String text = routeName + ' No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
        String errorNoAccount = 'error_no_account_selected'.tr();
        String text = routeName + ' $errorNoAccount. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
        InvestrendTheme.of(context).showSnackBar(context, text);
        onProgress = false;
        return;
      } else {
        if (_stockPositionNotifier.value.isEmpty()) {
          //_stockPositionNotifier.setLoading();
          setNotifierLoading(_stockPositionNotifier);
        }
        try {
          print(routeName + ' try stockPosition');
          final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
              account.brokercode,
              account.accountcode,
              context.read(dataHolderChangeNotifier).user.username,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
          //DebugWriter.info(routeName + ' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
          DebugWriter.info(routeName + ' Got stockPosition ' +stockPosition.toString());
          if (stockPosition != null) {
            if (mounted) {
              _stockPositionNotifier.setValue(stockPosition);
              sort();
              //_updateListNotifier.value = !_updateListNotifier.value;
            }
          } else {
            setNotifierNoData(_stockPositionNotifier);
          }
        } catch (e) {
          DebugWriter.information(routeName + ' stockPosition Exception : ' + e.toString());
          //_stockPositionNotifier?.setError(message: e.toString());
          setNotifierError(_stockPositionNotifier, e);
          handleNetworkError(context, e);
          /*
        if(e is TradingHttpException){
          if(e.isUnauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }
        */
        }

        try {
          print('try Summarys');
          String codes = _stockPositionNotifier.joinCode('_');
          if (!StringUtils.isEmtpy(codes)) {
            final stockSummarys = await InvestrendTheme.datafeedHttp.fetchStockSummaryMultiple(codes, 'RG');
            if (stockSummarys != null && stockSummarys.isNotEmpty) {
              stockSummarys.forEach((summary) {
                if (summary != null) {
                  summarys[summary.code] = summary;
                }
              });
              _updateListNotifier.value = !_updateListNotifier.value;
              //print(routeName + ' Future Summary DATA : ' + stockSummary.code + '  prev : ' + stockSummary.prev.toString());
              //_summaryNotifier.setData(stockSummary);
              //context.read(stockSummaryChangeNotifier).setData(stockSummary);
              //_watchlistDataNotifier.updateBySummarys(stockSummarys);
            } else {
              print(routeName + ' Future Summarys NO DATA');
            }
          } else {
            print(routeName + ' Future Summarys codes EMPTY, not requesting');
          }
        } catch (e) {
          DebugWriter.information(routeName + ' Summarys Exception : ' + e.toString());
          print(e);
        }
      }
    } else {
      setNotifierNoData(_stockPositionNotifier);
      _updateListNotifier.value = !_updateListNotifier.value;
    }
    onProgress = false;
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }


  bool onProgressListStockHist = false;
  Future loadStockHist() async {
    if(onProgressListStockHist){
      return false;
    }
    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (hasAccount) {
      int selected = context
          .read(accountChangeNotifier)
          .index;
      Account account = context
          .read(dataHolderChangeNotifier)
          .user
          .getAccount(selected);
      if (account == null) {
        //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
        //String text = routeName + ' No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
        String errorNoAccount = 'error_no_account_selected'.tr();
        String text = routeName + ' $errorNoAccount. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
        InvestrendTheme.of(context).showSnackBar(context, text);
        onProgressListStockHist = false;
        return;
      } else {
        // if (_stockPositionNotifier.value.isEmpty()) {
        //   //_stockPositionNotifier.setLoading();
        //   setNotifierLoading(_stockPositionNotifier);
        // }
        onProgressListStockHist = true;
        try {
          print(routeName + ' try list_stock_hist');
          final list_stock_hist = await InvestrendTheme.tradingHttp.list_stock_hist(
              account.brokercode,
              account.accountcode,
              context
                  .read(dataHolderChangeNotifier)
                  .user
                  .username,
              InvestrendTheme
                  .of(context)
                  .applicationPlatform,
              InvestrendTheme
                  .of(context)
                  .applicationVersion);
          //DebugWriter.info(routeName + ' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());

          int count = list_stock_hist != null ? list_stock_hist.length : 0;
          DebugWriter.information(routeName + ' Got list_stock_hist $count');
          if (mounted) {
            if (count > 0 ) {
              List<Stock> stockList = List.empty(growable: true);
              for(int i=0; i < count; i++){
                StockHist stockHist = list_stock_hist.elementAt(i);
                if(stockHist != null){
                  Stock stock = InvestrendTheme.storedData.findStock(stockHist.stockCode);
                  if(stock != null){
                    stockList.add(stock);
                  }else{
                    stockList.add(Stock(stockHist.stockCode, '-'));
                  }
                }
              }
              DebugWriter.information(routeName + ' find stockList : '+stockList.length.toString());
              final result = InvestrendTheme.showFinderScreen(context, showStockOnly: true, fromListStocks: stockList);
              result.then((value) {
                if (value == null) {
                  print('result finder = null');
                } else if (value is Stock) {
                  print('result finder = ' + value.code);

                  StockPositionDetail foundPortfolio = _stockPositionNotifier.value.getStockPositionDetailByCode(value.code);


                  String accountInfo = '?';
                  bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
                  if (hasAccount) {
                    int selected = context
                        .read(accountChangeNotifier)
                        .index;
                    Account account = context
                        .read(dataHolderChangeNotifier)
                        .user
                        .getAccount(selected);
                    if (account != null) {
                      accountInfo = account.typeString() + ' - ' + account.accountcode;
                      if(foundPortfolio == null){
                        foundPortfolio = StockPositionDetail.createBasic();
                        foundPortfolio.stockCode = value.code;
                      }
                      Stock stock = InvestrendTheme.storedData.findStock(value.code);
                      if(stock != null){
                        context.read(primaryStockChangeNotifier).setStock(value);
                      }
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            //builder: (_) => ScreenDetailPortfolio(accountInfo,stock.code, stock.name, gp),
                            builder: (_) => ScreenDetailPortfolio(foundPortfolio, value.code, value.name, accountInfo, account.accountcode, context.read(dataHolderChangeNotifier).user.username, account.brokercode, init_historical: true,),
                            settings: RouteSettings(name: '/detail_portfolio'),
                          ));
                    }
                  }




                  // context.read(primaryStockChangeNotifier).setStock(value);
                  //
                  // bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
                  // InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Buy);
                } else if (value is People) {
                  print('result finder = ' + value.name);
                }
              });
            }else{
              InvestrendTheme.of(context).showSnackBar(context, 'error_list_stock_hist_empty'.tr());
            }
          }
        } catch (e) {
          DebugWriter.information(routeName + ' stockPosition Exception : ' + e.toString());
          //_stockPositionNotifier?.setError(message: e.toString());
          setNotifierError(_stockPositionNotifier, e);
          handleNetworkError(context, e);
        }
      }
    }else{
      InvestrendTheme.of(context).showSnackBar(context, 'error_no_account_selected'.tr());
    }
    onProgressListStockHist = false;

  }
  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }




  Widget _optionsPortfolio(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: InvestrendTheme.cardPaddingVertical),
      child: Container(
        //color: Colors.purple,
        child: Row(
          children: [
            ComponentCreator.subtitle(context, 'portfolio_stocks_title'.tr()),
            Spacer(
              flex: 1,
            ),
            ButtonRounded('historical_text'.tr(), (){
              loadStockHist();
            }),
            SizedBox(width: 5.0,),
            ButtonDropdown(_sortNotifier, _sort_by_option, clickAndClose: true,showEmojiDescendingAscending: true,),
            /*
            OutlinedButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 10.0,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      'button_filter'.tr(),
                      style: InvestrendTheme.of(context).more_support_w400_compact,
                    ),
                  ],
                )),

             */
          ],
        ),
      ),
    );
  }

  // Widget buttonAccount(BuildContext context) {
  //   return TextButton(
  //       onPressed: () {},
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Ackerman - Reguler',
  //             style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
  //           ),
  //           SizedBox(
  //             width: 5.0,
  //           ),
  //           Image.asset(
  //             'images/icons/arrow_down.png',
  //             width: 6.0,
  //             height: 6.0,
  //           ),
  //         ],
  //       ));
  // }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {

    int todayReturnValue = 3288000;
    double todayReturnPercentage = 12.0;

    int totalReturnValue = 20824000;
    double totalReturnPercentage = 76.11;





    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
            //child: buttonAccount(context),
            child: ButtonAccount(/*_accountNotifier*/),
          ),

          ValueListenableBuilder(
            valueListenable: _accountNotifier,
            builder: (context, data, child) {
              User user = context.read(dataHolderChangeNotifier).user;
              Account activeAccount = user.getAccount(context.read(accountChangeNotifier).index);
              String portfolioValue = ' ';
              String portfolioGainLoss = ' ';
              String portfolioGainLossPercentage = ' ';
              int gainLossIDR = 0;
              if(activeAccount != null){
                AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
                if(accountInfo != null){
                  gainLossIDR = accountInfo.totalGL;
                  portfolioValue = InvestrendTheme.formatMoney(accountInfo.totalMarket, prefixRp: true);
                  portfolioGainLoss = InvestrendTheme.formatMoney(accountInfo.totalGL, prefixRp: true) + ' (' + InvestrendTheme.formatPercentChange(accountInfo.totalGLPct, sufixPercent: true) + ')';
                }
              }
              return Padding(
                padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin, bottom: InvestrendTheme.cardPaddingPlusMargin),
                child: Text(
                  portfolioValue,
                  style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w800),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin, top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPaddingPlusMargin),
            child: WidgetReturns(todayReturnValue, todayReturnPercentage, totalReturnValue, totalReturnPercentage),
          ),
          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin, top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPaddingPlusMargin),
            child: CardChart(_chartNotifier, callbackRange: (from, to){
              print(routeName+' chart callbackRange : $from , $to ');
            }, numberFormatRight: NumberFormat.compact(locale: EasyLocalization.of(context).locale.languageCode),),//'en_US'
          ),
          ComponentCreator.divider(context),
          SizedBox(height: 14.0,),
          _optionsPortfolio(context),
          //RowPortfolio('ASII', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58, firstRow: true,paddingLeftRight: InvestrendTheme.cardPaddingPlusMargin,),
          //RowPortfolio('BUMI', 90000000, -14000000, -14.58, 1000, 6000, 5150, -200, -14.58,paddingLeftRight: InvestrendTheme.cardPaddingPlusMargin),
          ValueListenableBuilder(
            valueListenable: _stockPositionNotifier,
            builder: (context, StockPosition data, child) {
              if (_stockPositionNotifier.invalid()) {
                return Center(child: CircularProgressIndicator());
              }
              return Column(
                children: List<Widget>.generate(
                  data.count(),
                      (int index) {
                    StockPositionDetail gp = data.getStockPositionDetail(index);
                    return Slidable(
                        controller: slidableController,
                        closeOnScroll: true,
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.22,
                        secondaryActions: <Widget>[
                          TradeSlideAction(
                            'button_buy'.tr(),
                            InvestrendTheme.buyColor,
                                () {
                              print('buy clicked code : ' + gp.stockCode);
                              Stock stock = InvestrendTheme.storedData.findStock(gp.stockCode);
                              if (stock == null) {
                                print('buy clicked code : ' + gp.stockCode + ' aborted, not find stock on StockStorer');
                                return;
                              }

                              context.read(primaryStockChangeNotifier).setStock(stock);

                              //InvestrendTheme.push(context, ScreenTrade(OrderType.Buy), ScreenTransition.SlideLeft, '/trade');

                              Navigator.push(context, CupertinoPageRoute(
                                builder: (_) => ScreenTrade(OrderType.Buy), settings: RouteSettings(name: '/trade'),));
                            },
                            tag: 'button_buy',
                          ),
                          TradeSlideAction(
                            'button_sell'.tr(),
                            InvestrendTheme.sellColor,
                                () {
                              print('sell clicked code : ' + gp.stockCode);
                              Stock stock = InvestrendTheme.storedData.findStock(gp.stockCode);
                              if (stock == null) {
                                print('sell clicked code : ' + gp.stockCode + ' aborted, not find stock on StockStorer');
                                return;
                              }

                              context.read(primaryStockChangeNotifier).setStock(stock);
                              //InvestrendTheme.push(context, ScreenTrade(OrderType.Sell), ScreenTransition.SlideLeft, '/trade');

                              Navigator.push(context, CupertinoPageRoute(
                                builder: (_) => ScreenTrade(OrderType.Sell), settings: RouteSettings(name: '/trade'),));
                            },
                            tag: 'button_sell',
                          ),
                          CancelSlideAction('button_cancel'.tr(), Theme.of(context).backgroundColor, () {
                            InvestrendTheme.of(context).showSnackBar(context, 'cancel');
                          }),

                        ],

                        // actions: <Widget>[
                        //   IconSlideAction(
                        //     caption: 'button_remove'.tr(),
                        //     color: Colors.orange,
                        //     icon: Icons.delete_forever_outlined,
                        //     onTap: () {
                        //       print('Clicked Remove on : '+gp.code);
                        //       InvestrendTheme.of(context).showSnackBar(context, 'Clicked Remove on : '+gp.code);
                        //     },
                        //     foregroundColor: Colors.white,
                        //   ),
                        // ],

                        child: RowStockPositions(
                          gp,
                          firstRow: (index == 0),
                          onTap: () {
                            print('clicked code : ' + gp.stockCode+'  canTapRow : $canTapRow');
                            if(canTapRow){
                              canTapRow = false;

                              Stock stock = InvestrendTheme.storedData.findStock(gp.stockCode);
                              if (stock == null) {
                                print('clicked code : ' + gp.stockCode + ' aborted, not find stock on StockStorer');
                                canTapRow = true;
                                return;
                              }
                              context.read(primaryStockChangeNotifier).setStock(stock);

                              Future.delayed(Duration(milliseconds: 200),(){
                                canTapRow = true;
                                InvestrendTheme.of(context).showStockDetail(context);
                              });
                            }


                          },
                          paddingLeftRight: InvestrendTheme.cardPaddingPlusMargin,
                        ));
                  },
                ),
              );
            },
          ),

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
    //print(routeName + ' onActive');
    canTapRow = true;
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if(mounted){
    //     doUpdate();
    //   }
    // });

    doUpdate(pullToRefresh: true);
    startTimer();
    //runPostFrame(doUpdate);
  }

  Future onRefresh() {
    if(!active){
      active = true;
      canTapRow = true;
      startTimer();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  Widget row(BuildContext context, StockPositionDetail gp, StockSummary summary, int index, {bool firstRow = false}) {

    return Slidable(
        controller: slidableController,
        closeOnScroll: true,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.22,
        secondaryActions: <Widget>[
          TradeSlideAction(
            'button_buy'.tr(),
            InvestrendTheme.buyColor,
            () {
              print('buy clicked code : ' + gp.stockCode);
              Stock stock = InvestrendTheme.storedData.findStock(gp.stockCode);
              if (stock == null) {
                print('buy clicked code : ' + gp.stockCode + ' aborted, not find stock on StockStorer');
                return;
              }

              context.read(primaryStockChangeNotifier).setStock(stock);

              //InvestrendTheme.push(context, ScreenTrade(OrderType.Buy), ScreenTransition.SlideLeft, '/trade');

              bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
              InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Buy, );


              /*
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ScreenTrade(OrderType.Buy),
                    settings: RouteSettings(name: '/trade'),
                  ));
              */
            },
            tag: 'button_buy',
          ),
          TradeSlideAction(
            'button_sell'.tr(),
            InvestrendTheme.sellColor,
            () {
              print('sell clicked code : ' + gp.stockCode);
              Stock stock = InvestrendTheme.storedData.findStock(gp.stockCode);
              if (stock == null) {
                print('sell clicked code : ' + gp.stockCode + ' aborted, not find stock on StockStorer');
                return;
              }

              context.read(primaryStockChangeNotifier).setStock(stock);
              //InvestrendTheme.push(context, ScreenTrade(OrderType.Sell), ScreenTransition.SlideLeft, '/trade');

              bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
              InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Sell, );
              /*
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ScreenTrade(OrderType.Sell),
                    settings: RouteSettings(name: '/trade'),
                  ));
              */
            },
            tag: 'button_sell',
          ),
          // CancelSlideAction('button_cancel'.tr(), Theme.of(context).backgroundColor, () {
          //   InvestrendTheme.of(context).showSnackBar(context, 'cancel');
          // }),
        ],
        child: RowStockPositions(
          gp,
          firstRow: firstRow, //(index == 0),
          onTap: () {
            print('clicked code : ' + gp.stockCode + '  canTapRow : $canTapRow');
            if (canTapRow) {
              canTapRow = false;

              Stock stock = InvestrendTheme.storedData.findStock(gp.stockCode);
              if (stock == null) {
                print('clicked code : ' + gp.stockCode + ' aborted, not find stock on StockStorer');
                canTapRow = true;
                return;
              }
              context.read(primaryStockChangeNotifier).setStock(stock);


              Future.delayed(Duration(milliseconds: 200), () {
                canTapRow = true;

                //InvestrendTheme.of(context).showStockDetail(context);

                String accountInfo = '?';
                bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
                if (hasAccount) {
                  int selected = context
                      .read(accountChangeNotifier)
                      .index;
                  Account account = context
                      .read(dataHolderChangeNotifier)
                      .user
                      .getAccount(selected);
                  if (account != null) {
                    accountInfo = account.typeString() + ' - ' + account.accountcode;
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          //builder: (_) => ScreenDetailPortfolio(accountInfo,stock.code, stock.name, gp),
                          builder: (_) => ScreenDetailPortfolio(gp, stock.code, stock.name, accountInfo, account.accountcode, context.read(dataHolderChangeNotifier).user.username, account.brokercode),
                          settings: RouteSettings(name: '/detail_portfolio'),
                        ));
                  }
                }


              });




            }
          },
          paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
          summary: summary,
          onPressedButtonCorporateAction: ()=> onPressedButtonCorporateAction(context, gp.stockCode),
          //onPressedButtonSpecialNotation: ()=> onPressedButtonSpecialNotation(context, gp.stockCode),
          onPressedButtonSpecialNotation: ()=> onPressedButtonImportantInformation(context, gp.stockCode),

        ));
  }

  void onPressedButtonImportantInformation(BuildContext context, String code ) {
    List<Remark2Mapping> notation = context.read(remark2Notifier).getSpecialNotation(code);
    SuspendStock suspendStock = context.read(suspendedStockNotifier).getSuspended(code, Stock.defaultBoardByCode(code));

    int count = notation == null ? 0 : notation.length;
    if(count == 0 && suspendStock == null){
      print(routeName+'.onPressedButtonImportantInformation not showing anything');
      return;
    }
    print(routeName+'.onPressedButtonImportantInformation');
    List<Widget> childs = List.empty(growable: true);


    double height = 0;
    if(suspendStock != null){


      String infoSuspend = 'suspended_time_info'.tr();

      DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
      DateFormat dateParser = DateFormat('yyyy-MM-dd');
      DateTime dateTime = dateParser.parseUtc(suspendStock.date);
      print('dateTime : '+dateTime.toString());
      //print('indexSummary.date : '+data.date+' '+data.time);
      String formatedDate = dateFormatter.format(dateTime);
      //String formatedTime = timeFormatter.format(dateTime);
      //infoSuspend = infoSuspend.replaceAll('#BOARD#', suspendStock.board);
      infoSuspend = infoSuspend.replaceAll('#DATE#', formatedDate);
      infoSuspend = infoSuspend.replaceAll('#TIME#', suspendStock.time);
      //displayTime = infoTime;
      height += 25.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text('Suspended '+suspendStock.board, style: InvestrendTheme.of(context).small_w600,),
      ));

      height += 50.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: RichText(
          text: TextSpan(text:  '•  ', style: InvestrendTheme.of(context).small_w600, children: [
            TextSpan(
              text: infoSuspend,
              style: InvestrendTheme.of(context).small_w400,
            )
          ]),
        ),
      ));
    }
    bool titleSpecialNotation = true;
    for(int i = 0; i < count; i++){
      /* SEBELUM AUDIT
      Remark2Mapping remark2 = notation.elementAt(i);
      if(remark2 != null){
        if(remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(remark2.value, style: InvestrendTheme.of(context).small_w600,),
          ));

        }else {
          if(titleSpecialNotation){
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('bottom_sheet_alert_title'.tr(), style: InvestrendTheme.of(context).small_w600,),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      }
      */
      Remark2Mapping remark2 = notation.elementAt(i);
      if(remark2 != null){
        if(remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(remark2.code+' : '+remark2.value, style: InvestrendTheme.of(context).small_w600,),
          ));
        }else {
          if(titleSpecialNotation){
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('bottom_sheet_alert_title'.tr(), style: InvestrendTheme.of(context).small_w600,),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.code,
                  style: InvestrendTheme.of(context).small_w600,
                ),
                TextSpan(
                  text: ' : '+remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      }
    }
    if(childs.isNotEmpty){
      showAlert(context, childs, childsHeight: height, title: ' ');
    }
  }

  /*
  void onPressedButtonSpecialNotation(BuildContext context, String code) {
    List<Remark2Mapping> notation = context.read(remark2Notifier).getSpecialNotation(code);
    List<Widget> childs = List.empty(growable: true);
    if (notation != null && notation.isNotEmpty) {
      notation.forEach((remark2) {
        if (remark2 != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      });

      showAlert(context, childs, childsHeight: (childs.length * 40).toDouble());
    }
  }
  */
  void onPressedButtonCorporateAction(BuildContext context, String code ) {


    List<CorporateActionEvent> corporateAction = context.read(corporateActionEventNotifier).getEvent(code);
    //print('onPressedButtonCorporateAction : '+corporateAction.toString());
    List<Widget> childs = List.empty(growable: true);
    if (corporateAction != null && corporateAction.isNotEmpty) {
      corporateAction.forEach((ca) {
        if (ca != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ca.getInformationWidget(context),

          ));
        }
      });

      showAlert(context, childs, childsHeight: (childs.length * 50).toDouble(),title: 'Corporate Action');
    }

  }
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    // int todayReturnValue = 0;
    // double todayReturnPercentage = 0;
    //
    // int totalReturnValue = 0;
    // double totalReturnPercentage = 0;

    List<Widget> preWidget = List.empty(growable: true);
    preWidget.add(Align(alignment: Alignment.centerLeft, child: ButtonAccount(/*_accountNotifier*/)));
    preWidget.add(ValueListenableBuilder(
      valueListenable: _accountNotifier,
      builder: (context, data, child) {
        User user = context.read(dataHolderChangeNotifier).user;
        Account activeAccount = user.getAccount(context.read(accountChangeNotifier).index);
        String portfolioValue = ' ';
        String portfolioGainLoss = ' ';
        String portfolioGainLossPercentage = ' ';
        int gainLossIDR = 0;
        if (activeAccount != null) {
          AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
          if (accountInfo != null) {
            gainLossIDR = accountInfo.totalGL;
            portfolioValue = InvestrendTheme.formatMoney(accountInfo.totalMarket, prefixRp: true);
            portfolioGainLoss = InvestrendTheme.formatMoney(accountInfo.totalGL, prefixRp: true) +
                ' (' +
                InvestrendTheme.formatPercentChange(accountInfo.totalGLPct, sufixPercent: true) +
                ')';
          }
        }
        return Padding(
          padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
          child: Text(
            portfolioValue,
            style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w800),
          ),
        );
      },
    ));
    preWidget.add(Padding(
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPadding,
          bottom: 10.0),
      child: ValueListenableBuilder(
          valueListenable: _stockPositionNotifier,
          builder: (context, StockPosition data, child) {
            if(data != null){
              DebugWriter.info('WidgetReturns build --> '+data.toString());
              return WidgetReturns(data.totalTodayGL.toInt(), data.totalTodayGLPct, data.totalGL.toInt(), data.totalGLPct, groupStyle: groupStyle,);
            }else{
              return Container(
                width: double.maxFinite,
                height: 60,
                child: Center(
                  child: EmptyLabel(),
                ),
              );
            }
          }),
    ));
    /*
    preWidget.add(Padding(
      padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin, top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPaddingPlusMargin),
      child: CardChart(_chartNotifier, callbackRange: (from, to){
        print(routeName+' chart callbackRange : $from , $to ');
      }, numberFormatRight: NumberFormat.compact(locale: EasyLocalization.of(context).locale.languageCode),),//'en_US'
    ));
    */
    preWidget.add(ComponentCreator.dividerCard(context));
    // preWidget.add(SizedBox(
    //   height: 14.0,
    // ));
    preWidget.add(_optionsPortfolio(context));

    Widget postWidget = SizedBox(
      height: paddingBottom,
    );

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ValueListenableBuilder(
          valueListenable: _updateListNotifier,
          builder: (context, value, child) {
            //bool hasData = _stockPositionNotifier.value.isEmpty();

            if (_stockPositionNotifier.value.isEmpty()) {

              return ListView.builder(
                  shrinkWrap: false,
                  //padding: const EdgeInsets.all(8),
                  itemCount: preWidget.length + 2,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < preWidget.length) {
                      return preWidget.elementAt(index);
                    } else if (index == preWidget.length) {
                      if (_stockPositionNotifier.currentState.isLoading()) {
                        return Center(child: CircularProgressIndicator());
                      } else if (_stockPositionNotifier.currentState.isError()) {
                        return Center(child: TextButtonRetry(
                          onPressed: () {
                            doUpdate(pullToRefresh: true);
                          },
                        ));
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 4,
                            ),
                            EmptyTitleLabel(text: 'portfolio_stock_list_empty_title'.tr()),
                            SizedBox(
                              height: InvestrendTheme.cardPaddingGeneral,
                            ),
                            EmptyLabel(text: 'portfolio_stock_list_empty_description'.tr()),
                            SizedBox(
                              height: 40.0,
                            ),
                            ButtonOutlinedRounded(
                              'button_find_stock'.tr(),
                              onPressed: () {
                                final result = InvestrendTheme.showFinderScreen(context, showStockOnly: true);
                                result.then((value) {
                                  if (value == null) {
                                    print('result finder = null');
                                  } else if (value is Stock) {
                                    print('result finder = ' + value.code);
                                    context.read(primaryStockChangeNotifier).setStock(value);

                                    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
                                    InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Buy);
                                    /*
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) => ScreenTrade(
                                            OrderType.Buy,
                                          ),
                                          settings: RouteSettings(name: '/trade'),
                                        ));
                                    */
                                  } else if (value is People) {
                                    print('result finder = ' + value.name);
                                  }
                                });

                                // return Navigator.push(context, CupertinoPageRoute(
                                //   builder: (_) => ScreenTrade(OrderType.Buy,onlyFastOrder: true,), settings: RouteSettings(name: '/trade'),));
                              },
                            ),
                          ],
                        );
                      }
                    } else {
                      return postWidget;
                    }
                  });
            }

            int itemCount = preWidget.length + 1 + _stockPositionNotifier.value.count();
            int portfolioCount = _stockPositionNotifier.value.count();
            return ListView.builder(
                shrinkWrap: false,
                //padding: const EdgeInsets.all(8),
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int index) {
                  if (index < preWidget.length) {
                    return preWidget.elementAt(index);
                  } else if (index < (preWidget.length + portfolioCount)) {
                    int indexPortfolioRow = index - preWidget.length;
                    StockPositionDetail gp = _stockPositionNotifier.value.getStockPositionDetail(indexPortfolioRow);
                    StockSummary summary;
                    if (summarys.containsKey(gp.stockCode)) {
                      summary = summarys[gp.stockCode];
                    }

                    return row(context, gp, summary, index, firstRow: indexPortfolioRow == 0);
                  } else {
                    return postWidget;
                  }
                });
          }),
      /*
      child: ValueListenableBuilder(
          valueListenable: _stockPositionNotifier,
          builder: (context, StockPosition data, child) {
            if (_stockPositionNotifier.invalid()) {
              return ListView.builder(
                  shrinkWrap: false,
                  padding: const EdgeInsets.all(8),
                  itemCount: preWidget.length + 2,
                  itemBuilder: (BuildContext context, int index) {
                    if(index < preWidget.length){
                      return preWidget.elementAt(index);
                    }else if(index == preWidget.length){
                      return Center(child: CircularProgressIndicator());
                    }else{
                      return postWidget;
                    }
                  });
            }
            return ListView.builder(

                shrinkWrap: false,
                padding: const EdgeInsets.all(8),
                itemCount: preWidget.length + 1 + data.count(),
                itemBuilder: (BuildContext context, int index) {
                  if(index < preWidget.length){
                    return preWidget.elementAt(index);
                  }else if(index < (preWidget.length + data.count()) ){
                    StockPositionDetail gp = data.getStockPositionDetail(index - preWidget.length);
                    return row(context, gp, index);
                  }else{
                    return postWidget;
                  }
                });
          }),
      */
    );
  }

  void startTimer() {
    if (!InvestrendTheme.DEBUG) {
      if (timer == null || !timer.isActive) {
        print(routeName+' startTimer');
        timer = Timer.periodic(durationUpdate, (timer) {
          if (active) {
            if(onProgress){
              print(routeName+' timer aborted caused by onProgress : $onProgress');
            }else{
              doUpdate();
            }
          }
        });
      }
    }
  }

  void stopTimer() {

    if (timer == null || !timer.isActive) {
      return;
    }
    print(routeName+' _stopTimer');
    timer.cancel();
    timer = null;
  }

  final String PROP_SELECTED_SORT       = 'selectedSort';
  @override
  void initState() {
    super.initState();
    _sortNotifier.addListener(sort);

    runPostFrame((){
      // #1 get properties
      int selectedSort = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_SORT, 0);

      // #2 use properties
      _sortNotifier.value = min(selectedSort, _sort_by_option.length - 1) ;

      // #3 check properties if changed, then save again
      if(selectedSort != _sortNotifier.value){
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
      }
    });
    /*
    Future.delayed(Duration(milliseconds: 500), () {
      //doUpdate();
      // PortfolioData dataUs = PortfolioData();
      // dataUs.datas.add(Portfolio('ASII', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('BBCA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('BSDE', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('ANTM', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('BOLA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('BFIN', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('EMTK', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('GGRM', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('ASRI', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('BNBR', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('ELTY', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('ENRG', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('DOID', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // dataUs.datas.add(Portfolio('AISA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      // _portfolioNotifier.setValue(dataUs);


      ChartLineData lineData = ChartLineData();
      lineData.addOhlcv(new Line(200000000, '2021-01-01', '2021-01-01'));
      lineData.addOhlcv(new Line(250000000, '2021-01-04', '2021-01-04'));
      lineData.addOhlcv(new Line(150000000, '2021-01-07', '2021-01-07'));
      lineData.addOhlcv(new Line(400000000, '2021-01-08', '2021-01-08'));
      lineData.addOhlcv(new Line(800000000, '2021-02-01', '2021-02-01'));
      lineData.addOhlcv(new Line(350000000, '2021-03-01', '2021-03-01'));
      lineData.addOhlcv(new Line(600000000, '2021-04-01', '2021-04-01'));
      lineData.addOhlcv(new Line(280000000, '2021-05-01', '2021-05-01'));
      lineData.addOhlcv(new Line(750000000, '2021-06-01', '2021-06-01'));
      lineData.addOhlcv(new Line(900000000, '2021-06-17', '2021-06-17'));
      _chartNotifier.setValue(lineData);

    });

     */
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
            _stockPositionNotifier.setValue(null);
            _updateListNotifier.value = !_updateListNotifier.value;
            doUpdate(pullToRefresh: true);
          }
        }
      };
    }
    context.read(accountChangeNotifier).addListener(_activeAccountChangedListener);

    /*
    context.read(accountChangeNotifier).addListener(() {
      if (mounted) {
        bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
        if (hasAccount) {
          _accountNotifier.value = !_accountNotifier.value;
          _stockPositionNotifier.setValue(null);
          _updateListNotifier.value = !_updateListNotifier.value;
          doUpdate();
        }
      }
    });

     */
    context.read(accountsInfosNotifier).addListener(() {
      if (mounted) {
        _accountNotifier.value = !_accountNotifier.value;
      }
    });
  }

  @override
  void dispose() {
    _updateListNotifier.dispose();
    //_chartNotifier.dispose();
    //_portfolioNotifier.dispose();
    _accountNotifier.dispose();
    _stockPositionNotifier.dispose();
    _sortNotifier.dispose();



    final container = ProviderContainer();
    if (_activeAccountChangedListener != null) {
      container.read(accountChangeNotifier).removeListener(_activeAccountChangedListener);
    }

    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
    slidableController.activeState = null;
    canTapRow = true;
    stopTimer();
  }
}
