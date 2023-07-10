import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/rows/row_stock_position.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:Investrend/component/button_outlined_rounded.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenProfilePortfolio extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  ScreenProfilePortfolio(this.tabIndex, this.tabController, {Key key}) : super(key: key);

  @override
    _ScreenProfilePortfolioState createState() => _ScreenProfilePortfolioState(tabIndex, tabController);
  }

class _ScreenProfilePortfolioState extends BaseStateNoTabsWithParentTab<ScreenProfilePortfolio> {
  final SlidableController slidableController = SlidableController();
  //PortfolioNotifier _portfolioNotifier = PortfolioNotifier(new PortfolioData());
  StockPositionNotifier _stockPositionNotifier = StockPositionNotifier(new StockPosition('', 0, 0, 0, 0, 0, 0, List.empty(growable: true)));
  final ValueNotifier<bool> _updateListNotifier = ValueNotifier<bool>(false);
  Map summarys = new Map();

  bool canTapRow = true;
  _ScreenProfilePortfolioState(int tabIndex, TabController tabController) : super('/profile_portfolio', tabIndex, tabController,parentTabIndex: Tabs.Portfolio.index);

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Widget _optionsPortfolio(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Container(
        //color: Colors.purple,
        child: Row(
          children: [
            ComponentCreator.subtitle(context, 'portfolio_stocks_title'.tr()),
            Spacer(
              flex: 1,
            ),
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


  void onChanged(StockPositionDetail stockPD, bool value){

  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {

    // int todayReturnValue = 3288000;
    // double todayReturnPercentage = 12.0;

    // int totalReturnValue = 20824000;
    // double totalReturnPercentage = 76.11;


    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if(!hasAccount){
      //return Center(child: EmptyLabel(),);
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
    return ValueListenableBuilder(
      valueListenable: _updateListNotifier,
      builder: (context, value, child) {
        if (_stockPositionNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }

        int itemCount = _stockPositionNotifier.value.count();
        return ListView(
          children: List<Widget>.generate(
            itemCount,
                (int index) {
              StockPositionDetail gp = _stockPositionNotifier.value.getStockPositionDetail(index);
              StockSummary summary;
              if(summarys.containsKey(gp.stockCode)){
                summary = summarys[gp.stockCode];
              }

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
                        InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Buy,);
                        /*
                        Navigator.push(context, CupertinoPageRoute(
                          builder: (_) => ScreenTrade(OrderType.Buy), settings: RouteSettings(name: '/trade'),));
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
                        InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Sell,);
                        /*
                        Navigator.push(context, CupertinoPageRoute(
                          builder: (_) => ScreenTrade(OrderType.Sell), settings: RouteSettings(name: '/trade'),));

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
                    firstRow: (index == 0),
                    modeProfile: true,
                    callbackChecked: onChanged,
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
                    paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
                    summary: summary,
                  ));
            },
          ),
        );
      },
    );


    /*
    return ValueListenableBuilder(
      valueListenable: _stockPositionNotifier,
      builder: (context, StockPosition data, child) {
        if (_stockPositionNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
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
    );
    */
    /*
    return ValueListenableBuilder(
      valueListenable: _stockPositionNotifier,
      builder: (context, StockPosition data, child) {
        if (_stockPositionNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
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
    );
    */
    /*
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: _portfolioNotifier,
            builder: (context, PortfolioData data, child) {
              if (_portfolioNotifier.invalid()) {
                return Center(child: CircularProgressIndicator());
              }
              return Column(
                children: List<Widget>.generate(
                  data.count(),
                      (int index) {
                    Portfolio gp = data.datas.elementAt(index);
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
                              print('buy clicked code : ' + gp.code);
                              Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                              if (stock == null) {
                                print('buy clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
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
                              print('sell clicked code : ' + gp.code);
                              Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                              if (stock == null) {
                                print('sell clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
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

                        child: RowPortfolio(
                          gp,
                          firstRow: (index == 0),
                          onTap: () {
                            print('clicked code : ' + gp.code+'  canTapRow : $canTapRow');
                            if(canTapRow){
                              canTapRow = false;

                              Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                              if (stock == null) {
                                print('clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
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
    */
  }

  @override
  void onActive() {
    //print(routeName + ' onActive');
    canTapRow = true;

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdate();
    // });
  }

  /*
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      PortfolioData dataUs = PortfolioData();
      dataUs.datas.add(Portfolio('ASII', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('BBCA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('BSDE', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('ANTM', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('BOLA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('BFIN', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('EMTK', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('GGRM', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('ASRI', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('BNBR', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('ELTY', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('ENRG', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('DOID', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      dataUs.datas.add(Portfolio('AISA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
      _portfolioNotifier.setValue(dataUs);

      

    });
  }
  */
  void doUpdate() async{
    String routeName = '/profile';


    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if(hasAccount){
      String accounCodes = '';
      context.read(dataHolderChangeNotifier).user?.accounts?.forEach((account) {
        if(StringUtils.isEmtpy(accounCodes)){
          accounCodes = account.accountcode;
        }else{
          accounCodes += '|'+account.accountcode;
        }
      });

      try {
        print(routeName+' try stockPosition');
        final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
            '', // broker
            accounCodes,
            '', // username
            InvestrendTheme.of(super.context).applicationPlatform,
            InvestrendTheme.of(super.context).applicationVersion);
        DebugWriter.information(routeName+' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());

        _stockPositionNotifier.setValue(stockPosition);
        _updateListNotifier.value = !_updateListNotifier.value;
      } catch (e) {
        DebugWriter.information(routeName+' stockPosition Exception : ' + e.toString());
        handleNetworkError(context, e);
        return;
      }


      try {
        print('try Summarys');
        String codes = _stockPositionNotifier.joinCode('_');
        if(!StringUtils.isEmtpy(codes)){
          final stockSummarys = await InvestrendTheme.datafeedHttp.fetchStockSummaryMultiple(codes, 'RG');
          if (stockSummarys != null && stockSummarys.isNotEmpty) {

            stockSummarys.forEach((summary) {
              if(summary != null){
                summarys[summary.code] = summary;
              }
            });
            _updateListNotifier.value = !_updateListNotifier.value;

          } else {
            print(routeName + ' Future Summarys NO DATA');
          }
        }else{
          print(routeName + ' Future Summarys codes EMPTY, not requesting');
        }

      } catch (e) {
        DebugWriter.information(routeName + ' Summarys Exception : ' + e.toString());
        print(e);
      }
    }

  }
  @override
  void dispose() {
    //_portfolioNotifier.dispose();
    _updateListNotifier.dispose();
    _stockPositionNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    super.context.read(accountChangeNotifier).addListener(() {
      if (mounted) {
        _stockPositionNotifier.setValue(null);
        doUpdate();
      }
    });

  }
  @override
  void onInactive() {
    //print(routeName + ' onInactive');
    slidableController.activeState = null;
    canTapRow = true;
  }
}
