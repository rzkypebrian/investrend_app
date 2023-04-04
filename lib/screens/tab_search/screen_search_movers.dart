import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/button_rounded.dart';

import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/rows/row_general_price.dart';
import 'package:Investrend/component/rows/row_watchlist.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/component/text_button_retry.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/trade/screen_trade.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenSearchMovers extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;
  ScreenSearchMovers(this.tabIndex, this.tabController,
      {Key key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenSearchMoversState createState() =>
      _ScreenSearchMoversState(tabIndex, tabController,
          visibilityNotifier: visibilityNotifier);
}

class _ScreenSearchMoversState
    extends BaseStateNoTabsWithParentTab<ScreenSearchMovers> {
  final GeneralPriceNotifier _moversDataNotifier =
      GeneralPriceNotifier(new GeneralPriceData());
  final SlidableController slidableController = SlidableController();
  final ValueNotifier<int> _moversTypeNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _rangeNotifier = ValueNotifier<int>(0);
  static const Duration _durationUpdate = Duration(milliseconds: 2500);

  bool canTapRow = true;
  Timer _timer;

  _ScreenSearchMoversState(int tabIndex, TabController tabController,
      {ValueNotifier<bool> visibilityNotifier})
      : super('/search_movers', tabIndex, tabController,
            parentTabIndex: Tabs.Search.index,
            visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;

  final List<String> _movers_options = [
    'search_movers_option_gainers_label'.tr(),
    'search_movers_option_losers_label'.tr(),
    'search_movers_option_frequency_label'.tr(),
    'search_movers_option_volume_label'.tr(),
    'search_movers_option_value_label'.tr(),
  ];

  final List<String> _movers_types = [
    'GAINERS',
    'LOSERS',
    'ACTIVE',
    'VOLUME',
    'VALUE'
  ];

  Widget _options(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 8.0,
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        children: [
          Spacer(
            flex: 1,
          ),
          ButtonDropdown(
            _moversTypeNotifier,
            _movers_options,
            clickAndClose: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  List<String> _listChipRange = <String>[
    '1D',
    '1W',
    '1M',
    '3M',
    '6M',
    '1Y',
    '5Y'
  ];
  List<String> _movers_ranges = <String>[
    'INTRADAY',
    '1_WEEK',
    '1_MONTH',
    '3_MONTH',
    '6_MONTH',
    '1_YEAR',
    '5_YEAR'
  ];
  // 1_WEEK MTD 1_MONTH 3_MONTH 6_MONTH 1_YEAR 2_YEAR 3_YEAR 4_YEAR 5_YEAR

  bool onProgress = false;
  Future doUpdate({bool pullToRefresh = false}) async {
    if (!active) {
      print(routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  active : $active  pullToRefresh : $pullToRefresh");
      return false;
    }
    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if (!isForeground) {
        print(
          routeName +
              ' doUpdate ignored isForeground : $isForeground  isVisible : ' +
              isVisible().toString(),
        );
        return false;
      }
    }
    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  active : $active  pullToRefresh : $pullToRefresh");
    onProgress = true;
    /*
      _groupedNotifier.setLoading();
      try {
        final groupedData = await HttpSSI.fetchGlobal();
        if(groupedData != null){
          if(mounted) {
            _groupedNotifier.setValue(groupedData);
          }else{
            print('ignored global data, mounted : $mounted');
          }
        }else{
          setNotifierNoData(_groupedNotifier);
        }
      } catch (error) {
        setNotifierError(_groupedNotifier, error.toString());
      }
      */
    if (pullToRefresh || _moversDataNotifier.value.isEmpty()) {
      _moversDataNotifier.setLoading();
    }
    String type = _movers_types.elementAt(_moversTypeNotifier.value);
    String range = _movers_ranges.elementAt(_rangeNotifier.value);
    if (_rangeNotifier.value == 0) {
      // intraday
      try {
        print(routeName + ' try movers');

        final topStocks =
            await InvestrendTheme.datafeedHttp.fetchTopStock(type);
        if (topStocks != null && !topStocks.isEmpty()) {
          String current_type =
              _movers_types.elementAt(_moversTypeNotifier.value);
          String current_range = _movers_ranges.elementAt(_rangeNotifier.value);

          bool valid_type =
              StringUtils.equalsIgnoreCase(current_type, topStocks.type);
          bool valid_range =
              StringUtils.equalsIgnoreCase(current_range, topStocks.range);
          if (valid_type && valid_range) {
            GeneralPriceData dataMovers = GeneralPriceData();

            topStocks.datas.forEach((mover) {
              Stock stock = InvestrendTheme.storedData.findStock(mover.code);
              String name = stock != null ? stock.name : '-';
              //dataMovers.datas.add(GeneralPrice(mover.code, InvestrendTheme.formatPrice(mover.close), InvestrendTheme.formatPrice(mover.change), InvestrendTheme.formatPercent(mover.percentChange), InvestrendTheme.changeTextColor(mover.percentChange), name: name));

              WatchlistPrice gp = WatchlistPrice(
                  mover.code,
                  mover.close.toDouble(),
                  mover.change.toDouble(),
                  mover.percentChange,
                  name);

              try {
                gp.notation =
                    context.read(remark2Notifier).getSpecialNotation(gp.code);
                gp.status = context
                    .read(remark2Notifier)
                    .getSpecialNotationStatus(gp.code);
                gp.suspendStock = context
                    .read(suspendedStockNotifier)
                    .getSuspended(gp.code, Stock.defaultBoardByCode(gp.code));
                if (gp.suspendStock != null) {
                  gp.status = StockInformationStatus.Suspended;
                }
                gp.corporateAction = context
                    .read(corporateActionEventNotifier)
                    .getEvent(gp.code);
                gp.corporateActionColor =
                    CorporateActionEvent.getColor(gp.corporateAction);
                String attentionCodes = context
                    .read(remark2Notifier)
                    .getSpecialNotationCodes(gp.code);
                gp.attentionCodes = attentionCodes;
              } catch (e) {
                print(e);
              }
              dataMovers.datas.add(gp);
            });
            if (mounted) {
              _moversDataNotifier.setValue(dataMovers);
            }
          } else {
            print(routeName +
                ' Future movers IGNORED valid_type : $valid_type  valid_range : $valid_range   current_type : $current_type  topStocks.type : ' +
                topStocks.type +
                '  current_range : $current_range  topStocks.range : ' +
                topStocks.range);
          }
        } else {
          print(routeName + ' Future movers NO DATA');
          setNotifierNoData(_moversDataNotifier);
        }
      } catch (error) {
        print(routeName + ' movers Exception : ' + error.toString());
        print(error);
        setNotifierError(_moversDataNotifier, error);
      }
    } else {
      try {
        print(routeName + ' try movers historical $range');

        final topStocks = await InvestrendTheme.datafeedHttp
            .fetchTopStockHistorical(type, range);
        if (topStocks != null && !topStocks.isEmpty()) {
          GeneralPriceData dataMovers = GeneralPriceData();
          String current_type =
              _movers_types.elementAt(_moversTypeNotifier.value);
          String current_range = _movers_ranges.elementAt(_rangeNotifier.value);

          bool valid_type =
              StringUtils.equalsIgnoreCase(current_type, topStocks.type);
          bool valid_range =
              StringUtils.equalsIgnoreCase(current_range, topStocks.range);
          if (valid_type && valid_range) {
            topStocks.datas.forEach((mover) {
              Stock stock = InvestrendTheme.storedData.findStock(mover.code);
              String name = stock != null ? stock.name : '-';
              //dataMovers.datas.add(GeneralPrice(mover.code, InvestrendTheme.formatPrice(mover.close), InvestrendTheme.formatPrice(mover.change), InvestrendTheme.formatPercent(mover.percentChange), InvestrendTheme.changeTextColor(mover.percentChange), name: name));
              //dataMovers.datas.add(GeneralPrice(mover.code, mover.close.toDouble(), mover.change.toDouble(), mover.percentChange, name: name));

              WatchlistPrice gp = WatchlistPrice(
                  mover.code,
                  mover.close.toDouble(),
                  mover.change.toDouble(),
                  mover.percentChange,
                  name);
              /*
              try{
                gp.notation = context.read(remark2Notifier).getSpecialNotation(gp.code);
                gp.status = context.read(remark2Notifier).getSpecialNotationStatus(gp.code);
                gp.suspendStock = context.read(suspendedStockNotifier).getSuspended(gp.code, Stock.defaultBoardByCode(gp.code));
                if(gp.suspendStock != null){
                  gp.status = StockInformationStatus.Suspended;
                }
                gp.corporateAction = context.read(corporateActionEventNotifier).getEvent(gp.code);
                gp.corporateActionColor = CorporateActionEvent.getColor(gp.corporateAction);
              }catch(e){
                print(e);

              }
              */
              try {
                gp.notation =
                    context.read(remark2Notifier).getSpecialNotation(gp.code);
                gp.status = context
                    .read(remark2Notifier)
                    .getSpecialNotationStatus(gp.code);
                gp.suspendStock = context
                    .read(suspendedStockNotifier)
                    .getSuspended(gp.code, Stock.defaultBoardByCode(gp.code));
                if (gp.suspendStock != null) {
                  gp.status = StockInformationStatus.Suspended;
                }
                gp.corporateAction = context
                    .read(corporateActionEventNotifier)
                    .getEvent(gp.code);
                gp.corporateActionColor =
                    CorporateActionEvent.getColor(gp.corporateAction);
                String attentionCodes = context
                    .read(remark2Notifier)
                    .getSpecialNotationCodes(gp.code);
                gp.attentionCodes = attentionCodes;
              } catch (e) {
                print(e);
              }

              dataMovers.datas.add(gp);
            });
            if (mounted) {
              _moversDataNotifier.setValue(dataMovers);
            }
          } else {
            print(routeName +
                ' Future movers IGNORED valid_type : $valid_type  valid_range : $valid_range   current_type : $current_type  topStocks.type : ' +
                topStocks.type +
                '  current_range : $current_range  topStocks.range : ' +
                topStocks.range);
          }
        } else {
          print(routeName + ' Future movers historical NO DATA');
          setNotifierNoData(_moversDataNotifier);
        }
      } catch (error) {
        print(routeName + ' movers historical Exception : ' + error.toString());
        print(error);
        setNotifierError(_moversDataNotifier, error);
      }
    }
    onProgress = false;
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    if (!active) {
      active = true;
      //onActive();
      canTapRow = true;
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody2(BuildContext context, double paddingBottom) {
    List<Widget> pre_childs = List.empty(growable: true);
    pre_childs.add(_options(context));
    pre_childs.add(ChipsRange(_listChipRange, _rangeNotifier,
        paddingLeftRight: InvestrendTheme.cardPaddingGeneral));
    pre_childs.add(SizedBox(height: 8.0));
    /*
    pre_childs.add(ValueListenableBuilder(
      valueListenable: _moversDataNotifier,
      builder: (context, GeneralPriceData data, child) {
        Widget noWidget = _moversDataNotifier.currentState.getNoWidget(onRetry: () {
          doUpdate(pullToRefresh: true);
        });

        if (noWidget != null) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.width - 80.0),
            child: Center(child: noWidget),
          );
        }

        return Column(
          children: List<Widget>.generate(
            data.count(),
            (int index) {
              GeneralPrice gp = data.datas.elementAt(index);
              return Slidable(
                  controller: slidableController,
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
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

                        Navigator.push(
                            context, CupertinoPageRoute(builder: (_) => ScreenTrade(OrderType.Buy), settings: RouteSettings(name: '/trade')));
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

                        Navigator.push(
                            context, CupertinoPageRoute(builder: (_) => ScreenTrade(OrderType.Sell), settings: RouteSettings(name: '/trade')));
                      },
                      tag: 'button_sell',
                    ),
                    CancelSlideAction('button_cancel'.tr(), Theme.of(context).backgroundColor, () {
                      InvestrendTheme.of(context).showSnackBar(context, 'cancel');
                    }),
                  ],
                  child: RowGeneralPrice(
                    gp.code,
                    gp.price,
                    gp.change,
                    gp.percent,
                    gp.priceColor,
                    name: gp.name,
                    firstRow: (index == 0),
                    onTap: () {
                      print('clicked code : ' + gp.code + '  canTapRow : $canTapRow');
                      if (canTapRow) {
                        canTapRow = false;
                        Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                        if (stock == null) {
                          canTapRow = true;
                          print('clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
                          return;
                        }

                        context.read(primaryStockChangeNotifier).setStock(stock);
                        Future.delayed(Duration(milliseconds: 200), () {
                          canTapRow = true;
                          InvestrendTheme.of(context).showStockDetail(context);
                        });
                      }
                    },
                    paddingLeftRight: InvestrendTheme.cardPaddingPlusMargin,
                    priceDecimal: false,
                  ));
            },
          ),
        );
      },
    ));
    */
    //pre_childs.add(SizedBox(height: paddingBottom + 80));

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: Padding(
        padding: EdgeInsets.only(
            top: InvestrendTheme.cardPaddingGeneral,
            bottom:
                paddingBottom + 80 /*InvestrendTheme.cardPaddingPlusMargin*/),
        child: ValueListenableBuilder(
            valueListenable: _moversDataNotifier,
            builder: (context, GeneralPriceData data, child) {
              Widget noWidget =
                  _moversDataNotifier.currentState.getNoWidget(onRetry: () {
                doUpdate(pullToRefresh: true);
              });
              if (noWidget != null) {
                return ListView.builder(
                    shrinkWrap: false,
                    padding: const EdgeInsets.all(8),
                    itemCount: pre_childs.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < pre_childs.length) {
                        return pre_childs.elementAt(index);
                      } else {
                        return noWidget;
                      }
                    });
              }

              return ListView.builder(
                  shrinkWrap: false,
                  padding: const EdgeInsets.all(8),
                  itemCount: pre_childs.length + data.count(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index < pre_childs.length) {
                      return pre_childs.elementAt(index);
                    } else if (index < (pre_childs.length + data.count())) {
                      int indexData = index - pre_childs.length;
                      GeneralPrice gp = data.datas.elementAt(indexData);
                      return createRow(context, gp, indexData);
                    }
                  });
            }),
      ),
    );
  }

  Widget createRow(BuildContext context, GeneralPrice gp, int indexData) {
    return Slidable(
        controller: slidableController,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          TradeSlideAction(
            'button_buy'.tr(),
            InvestrendTheme.buyColor,
            () {
              print('buy clicked code : ' + gp.code);
              Stock stock = InvestrendTheme.storedData.findStock(gp.code);
              if (stock == null) {
                print('buy clicked code : ' +
                    gp.code +
                    ' aborted, not find stock on StockStorer');
                return;
              }

              context.read(primaryStockChangeNotifier).setStock(stock);

              bool hasAccount =
                  context.read(dataHolderChangeNotifier).user.accountSize() > 0;
              InvestrendTheme.pushScreenTrade(context, hasAccount,
                  type: OrderType.Buy);

              /*
              Navigator.push(
                  context, CupertinoPageRoute(builder: (_) => ScreenTrade(OrderType.Buy), settings: RouteSettings(name: '/trade')));
              */
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
                print('sell clicked code : ' +
                    gp.code +
                    ' aborted, not find stock on StockStorer');
                return;
              }

              context.read(primaryStockChangeNotifier).setStock(stock);

              bool hasAccount =
                  context.read(dataHolderChangeNotifier).user.accountSize() > 0;
              InvestrendTheme.pushScreenTrade(context, hasAccount,
                  type: OrderType.Sell);
              /*
              Navigator.push(
                  context, CupertinoPageRoute(builder: (_) => ScreenTrade(OrderType.Sell), settings: RouteSettings(name: '/trade')));

               */
            },
            tag: 'button_sell',
          ),
          CancelSlideAction(
              'button_cancel'.tr(), Theme.of(context).backgroundColor, () {
            InvestrendTheme.of(context).showSnackBar(context, 'cancel');
          }),
        ],
        child: RowGeneralPrice(
          gp.code,
          gp.price,
          gp.change,
          gp.percent,
          gp.priceColor,
          name: gp.name,
          firstRow: (indexData == 0),
          onTap: () {
            print('clicked code : ' + gp.code + '  canTapRow : $canTapRow');
            if (canTapRow) {
              canTapRow = false;
              Stock stock = InvestrendTheme.storedData.findStock(gp.code);
              if (stock == null) {
                canTapRow = true;
                print('clicked code : ' +
                    gp.code +
                    ' aborted, not find stock on StockStorer');
                return;
              }

              context.read(primaryStockChangeNotifier).setStock(stock);
              Future.delayed(Duration(milliseconds: 200), () {
                canTapRow = true;
                InvestrendTheme.of(context).showStockDetail(context);
              });
            }
          },
          paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
          priceDecimal: false,
        ));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = List.empty(growable: true);
    childs.add(_options(context));
    childs.add(ChipsRange(_listChipRange, _rangeNotifier,
        paddingLeftRight: InvestrendTheme.cardPaddingGeneral));
    childs.add(SizedBox(height: 8.0));
    childs.add(Expanded(
      flex: 1,
      child: ValueListenableBuilder(
        valueListenable: _moversDataNotifier,
        builder: (context, GeneralPriceData data, child) {
          Widget noWidget =
              _moversDataNotifier.currentState.getNoWidget(onRetry: () {
            doUpdate(pullToRefresh: true);
          });

          if (noWidget != null) {
            return Padding(
              //padding: EdgeInsets.only(top: MediaQuery.of(context).size.width - 80.0),
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
              child: Center(child: noWidget),
            );
          }

          return ListView(
            padding: EdgeInsets.only(bottom: paddingBottom),
            children: List<Widget>.generate(
              data.count(),
              (int index) {
                GeneralPrice generalPrice = data.datas.elementAt(index);
                //GeneralPrice generalPrice = data.datas.elementAt(indexData);
                WatchlistPrice gp;
                if (generalPrice is WatchlistPrice) {
                  gp = generalPrice;
                }
                return Slidable(
                    controller: slidableController,
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      TradeSlideAction(
                        'button_buy'.tr(),
                        InvestrendTheme.buyColor,
                        () {
                          print('buy clicked code : ' + gp.code);
                          Stock stock =
                              InvestrendTheme.storedData.findStock(gp.code);
                          if (stock == null) {
                            print('buy clicked code : ' +
                                gp.code +
                                ' aborted, not find stock on StockStorer');
                            return;
                          }

                          context
                              .read(primaryStockChangeNotifier)
                              .setStock(stock);

                          bool hasAccount = context
                                  .read(dataHolderChangeNotifier)
                                  .user
                                  .accountSize() >
                              0;
                          InvestrendTheme.pushScreenTrade(context, hasAccount,
                              type: OrderType.Buy);

                          /*
                          Navigator.push(
                              context, CupertinoPageRoute(builder: (_) => ScreenTrade(OrderType.Buy), settings: RouteSettings(name: '/trade')));
                          */
                        },
                        tag: 'button_buy',
                      ),
                      TradeSlideAction(
                        'button_sell'.tr(),
                        InvestrendTheme.sellColor,
                        () {
                          print('sell clicked code : ' + gp.code);
                          Stock stock =
                              InvestrendTheme.storedData.findStock(gp.code);
                          if (stock == null) {
                            print('sell clicked code : ' +
                                gp.code +
                                ' aborted, not find stock on StockStorer');
                            return;
                          }

                          context
                              .read(primaryStockChangeNotifier)
                              .setStock(stock);

                          bool hasAccount = context
                                  .read(dataHolderChangeNotifier)
                                  .user
                                  .accountSize() >
                              0;
                          InvestrendTheme.pushScreenTrade(context, hasAccount,
                              type: OrderType.Sell);

                          /*
                          Navigator.push(
                              context, CupertinoPageRoute(builder: (_) => ScreenTrade(OrderType.Sell), settings: RouteSettings(name: '/trade')));
                          */
                        },
                        tag: 'button_sell',
                      ),
                      // CancelSlideAction('button_cancel'.tr(), Theme.of(context).backgroundColor, () {
                      //   InvestrendTheme.of(context).showSnackBar(context, 'cancel');
                      // }),
                    ],
                    child: RowWatchlist(
                      gp,
                      firstRow: (index == 0),
                      onTap: () {
                        print('clicked code : ' +
                            gp.code +
                            '  canTapRow : $canTapRow');
                        if (canTapRow) {
                          canTapRow = false;
                          Stock stock =
                              InvestrendTheme.storedData.findStock(gp.code);
                          if (stock == null) {
                            canTapRow = true;
                            print('clicked code : ' +
                                gp.code +
                                ' aborted, not find stock on StockStorer');
                            return;
                          }

                          context
                              .read(primaryStockChangeNotifier)
                              .setStock(stock);
                          Future.delayed(Duration(milliseconds: 200), () {
                            canTapRow = true;
                            InvestrendTheme.of(context)
                                .showStockDetail(context);
                          });
                        }
                      },
                      paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
                      showBidOffer: false,
                      onPressedButtonCorporateAction: () =>
                          onPressedButtonCorporateAction(
                              context, gp.corporateAction),
                      //onPressedButtonSpecialNotation: ()=> onPressedButtonSpecialNotation(context, gp.notation),
                      onPressedButtonSpecialNotation: () =>
                          onPressedButtonImportantInformation(
                              context, gp.notation, gp.suspendStock),
                      stockInformationStatus: gp.status,
                    ));
              },
            ),
          );
        },
      ),
    ));
    //childs.add(SizedBox(height: paddingBottom + 80));

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: Padding(
        padding: const EdgeInsets.only(
            top: InvestrendTheme.cardPadding,
            bottom: InvestrendTheme.cardPaddingGeneral),
        child: Column(
          children: childs,
        ),
        // child: ListView(
        //   shrinkWrap: false,
        //   children: childs,
        // ),
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
          children: [
            // CardGeneralPrice('search_currency_card_idr_rate_title'.tr(), _idrNotifier),
            // ComponentCreator.divider(context),
            // CardGeneralPrice('search_currency_card_cross_rate_title'.tr(), _crossNotifier),
            _options(context),
            ChipsRange(_listChipRange, _rangeNotifier, paddingLeftRight: InvestrendTheme.cardPaddingPlusMargin),
            SizedBox(height: 8.0),
            ValueListenableBuilder(
              valueListenable: _moversDataNotifier,
              builder: (context, GeneralPriceData data, child) {
                if (_moversDataNotifier.invalid()) {
                  return Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: List<Widget>.generate(
                    data.count(),
                    (int index) {
                      GeneralPrice gp = data.datas.elementAt(index);
                      return Slidable(
                          controller: slidableController,
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
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

                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => ScreenTrade(OrderType.Buy),
                                      settings: RouteSettings(name: '/trade'),
                                    ));
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

                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => ScreenTrade(OrderType.Sell),
                                      settings: RouteSettings(name: '/trade'),
                                    ));
                              },
                              tag: 'button_sell',
                            ),
                            CancelSlideAction('button_cancel'.tr(), Theme.of(context).backgroundColor, () {
                              InvestrendTheme.of(context).showSnackBar(context, 'cancel');
                            }),
                            // SlideAction(
                            //   child: MaterialButton(
                            //
                            //     onPressed: () {},
                            //
                            //
                            //     child: Text(
                            //       'button_buy'.tr(),
                            //       style: InvestrendTheme.of(context).small_w700_compact.copyWith(color: InvestrendTheme.textWhite),
                            //     ),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(4.0),
                            //     ),
                            //     color: InvestrendTheme.buyColor,
                            //     minWidth: 70.0,
                            //     height: double.maxFinite,
                            //   ),
                            // ),
                            // IconSlideAction(
                            //   caption: 'button_buy'.tr(),
                            //   color: InvestrendTheme.buyColor,
                            //   icon: Icons.archive,
                            //   onTap: () => InvestrendTheme.of(context).showSnackBar(context, 'Archive'),
                            // ),
                            // IconSlideAction(
                            //   caption: 'button_sell'.tr(),
                            //   color: InvestrendTheme.sellColor,
                            //   icon: Icons.share,
                            //   onTap: () => InvestrendTheme.of(context).showSnackBar(context, 'Share'),
                            // ),
                          ],

                          child: RowGeneralPrice(
                            gp.code,
                            gp.price,
                            gp.change,
                            gp.percent,
                            gp.priceColor,
                            name: gp.name,
                            firstRow: (index == 0),
                            onTap: () {
                              print('clicked code : ' + gp.code + '  canTapRow : $canTapRow');
                              if (canTapRow) {
                                canTapRow = false;
                                Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                                if (stock == null) {
                                  canTapRow = true;
                                  print('clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
                                  return;
                                }

                                context.read(primaryStockChangeNotifier).setStock(stock);
                                Future.delayed(Duration(milliseconds: 200), () {
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
      ),
    );
  }
  */

  void onPressedButtonImportantInformation(BuildContext context,
      List<Remark2Mapping> notation, SuspendStock suspendStock) {
    int count = notation == null ? 0 : notation.length;
    if (count == 0 && suspendStock == null) {
      print(routeName +
          '.onPressedButtonImportantInformation not showing anything');
      return;
    }
    print(routeName + '.onPressedButtonImportantInformation');
    List<Widget> childs = List.empty(growable: true);

    double height = 0;
    if (suspendStock != null) {
      String infoSuspend = 'suspended_time_info'.tr();

      DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
      DateFormat dateParser = DateFormat('yyyy-MM-dd');
      DateTime dateTime = dateParser.parseUtc(suspendStock.date);
      print('dateTime : ' + dateTime.toString());
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
        child: Text(
          'Suspended ' + suspendStock.board,
          style: InvestrendTheme.of(context).small_w600,
        ),
      ));

      height += 50.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: RichText(
          text: TextSpan(
              text: '•  ',
              style: InvestrendTheme.of(context).small_w600,
              children: [
                TextSpan(
                  text: infoSuspend,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
        ),
      ));
    }
    bool titleSpecialNotation = true;
    for (int i = 0; i < count; i++) {
      /*
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
      if (remark2 != null) {
        if (remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              remark2.code + ' : ' + remark2.value,
              style: InvestrendTheme.of(context).small_w600,
            ),
          ));
        } else {
          if (titleSpecialNotation) {
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                'bottom_sheet_alert_title'.tr(),
                style: InvestrendTheme.of(context).small_w600,
              ),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(
                  text: /*remark2.code + " : "*/ '•  ',
                  style: InvestrendTheme.of(context).small_w600,
                  children: [
                    TextSpan(
                      text: remark2.code,
                      style: InvestrendTheme.of(context).small_w600,
                    ),
                    TextSpan(
                      text: ' : ' + remark2.value,
                      style: InvestrendTheme.of(context).small_w400,
                    )
                  ]),
            ),
          ));
        }
      }
    }
    if (childs.isNotEmpty) {
      showAlert(context, childs, childsHeight: height, title: ' ');
    }
  }

  /*
  void onPressedButtonSpecialNotation(BuildContext context, List<Remark2Mapping> notation) {
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
  void onPressedButtonCorporateAction(
      BuildContext context, List<CorporateActionEvent> corporateAction) {
    print('onPressedButtonCorporateAction : ' + corporateAction.toString());

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

      showAlert(context, childs,
          childsHeight: (childs.length * 50).toDouble(),
          title: 'Corporate Action');
    }
  }

  @override
  void onActive() {
    //print(routeName + ' onActive');
    canTapRow = true;

    doUpdate();
    // runPostFrame(doUpdate);
  }

  final String PROP_SELECTED_RANGE = 'selectedRange';
  final String PROP_SELECTED_TYPE = 'selectedType';
  @override
  void initState() {
    super.initState();

    // Future.delayed(Duration(milliseconds: 500), () {
    //   GeneralPriceData dataMovers = GeneralPriceData();
    //   dataMovers.datas.add(GeneralPrice('UNVR', '1.750', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Unilever Indonesia Tbk.'));
    //   dataMovers.datas.add(GeneralPrice('BOLA', '250', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Bali Bintang Sejahtera Tbk.'));
    //   dataMovers.datas.add(GeneralPrice('ASII', '7.100', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Astra International Tbk.'));
    //   dataMovers.datas.add(GeneralPrice('ITIC', '470', '-30,00', '-0,31%', InvestrendTheme.redText, name: 'Indonesian Tobacco Tbk.'));
    //   dataMovers.datas.add(GeneralPrice('ELSA', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Elnusa Tbk.'));
    //   _moversDataNotifier.setValue(dataMovers);
    // });

    // _moversTypeNotifier.addListener(()=>doUpdate(pullToRefresh: true));
    // _rangeNotifier.addListener(()=>doUpdate(pullToRefresh: true));

    _moversTypeNotifier.addListener(() {
      context
          .read(propertiesNotifier)
          .properties
          .saveInt(routeName, PROP_SELECTED_TYPE, _moversTypeNotifier.value);
      doUpdate(pullToRefresh: true);
    });
    _rangeNotifier.addListener(() {
      //context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_RANGE, _rangeNotifier.value);
      doUpdate(pullToRefresh: true);
    });

    runPostFrame(() {
      // #1 get properties
      //int selectedRange = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_RANGE, 0);
      int selectedType = context
          .read(propertiesNotifier)
          .properties
          .getInt(routeName, PROP_SELECTED_TYPE, 0);

      // #2 use properties
      //int usedRange = min(selectedRange, _movers_ranges.length - 1) ;
      int usedType = min(selectedType, _movers_types.length - 1);
      //_rangeNotifier.value = usedRange;
      _moversTypeNotifier.value = usedType;

      // #3 check properties if changed, then save again
      // if(selectedRange != usedRange){
      //   context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_RANGE, usedRange);
      // }
      if (selectedType != usedType) {
        context
            .read(propertiesNotifier)
            .properties
            .saveInt(routeName, PROP_SELECTED_TYPE, usedType);
      }
    });
  }

  void _startTimer() {
    print(routeName + '._startTimer');
    if (_timer == null || !_timer.isActive) {
      _timer = Timer.periodic(_durationUpdate, (timer) {
        print(routeName + ' _timer.tick : ' + _timer.tick.toString());
        if (active) {
          if (onProgress) {
            print(routeName +
                ' timer aborted caused by onProgress : $onProgress');
          } else {
            doUpdate();
          }
        }
      });
    }
  }

  void _stopTimer() {
    print(routeName + '._stopTimer');
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _moversDataNotifier.dispose();
    _moversTypeNotifier.dispose();
    _rangeNotifier.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
    slidableController.activeState = null;
    canTapRow = true;
    _stopTimer();
  }
}
/*
class MoversBottomSheet extends StatelessWidget {
  final ValueNotifier caTypeNotifier;
  final List<String> movers_options;

  const MoversBottomSheet(this.caTypeNotifier, this.movers_options, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    double contentHeight = padding + 44.0 + (44.0 * movers_options.length) + padding;

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
          valueListenable: caTypeNotifier,
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
            int count = movers_options.length;
            for (int i = 0; i < count; i++) {
              String ca = movers_options.elementAt(i);
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
          caTypeNotifier.value = index;
        },
      ),
    );
  }
}
*/
/*
class TradeSlideAction extends ClosableSlideAction {
  final String text;
  final String tag;

  TradeSlideAction(
    this.text,
    Color color,
    VoidCallback onTap, {
    this.tag,
  }) : super(onTap: onTap, color: color, closeOnTap: true);

  void _handleCloseAfterTap(BuildContext context) {
    onTap?.call();
    Slidable.of(context)?.close();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      color: color,
      borderRadius: BorderRadius.circular(4.0),
      child: InkWell(
        onTap: !closeOnTap ? onTap : () => _handleCloseAfterTap(context),
        child: buildAction(context),
      ),
    );
    if (!StringUtils.isEmtpy(tag)) {
      child = Hero(tag: tag, child: child);
    }
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: child,
      ),
    );

  }

  @override
  Widget buildAction(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          text,
          style: InvestrendTheme.of(context).small_w700_compact.copyWith(color: InvestrendTheme.textWhite),
        ),
      ),
    );
  }
}

class CancelSlideAction extends ClosableSlideAction {
  final String text;

  CancelSlideAction(this.text, Color color, VoidCallback onTap) : super(onTap: onTap, color: color, closeOnTap: true);

  @override
  Widget buildAction(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          text,
          style: InvestrendTheme.of(context).small_w700_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
        ),
      ),
    );
  }
}
*/
