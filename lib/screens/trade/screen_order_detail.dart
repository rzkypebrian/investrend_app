// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_login_pin.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction.dart';
import 'package:Investrend/screens/trade/screen_amend.dart';
import 'package:Investrend/screens/trade/trade_component.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/*
class ScreenOrderDetailNew extends StatelessWidget {
  final BuySell _data;
  final OrderStatus _orderStatus;

  ScreenOrderDetailNew(this._data, this._orderStatus, {Key key}) : super(key: key);

  ValueNotifier<bool> notifier = ValueNotifier(false);

  Future onRefresh(BuildContext context) async {
    String username = context.read(dataHolderChangeNotifier).user.username;

    // int selected = context.read(accountChangeNotifier).index;
    // Account account = InvestrendTheme.of(context).user.getAccount(selected);
    // if(account == null){
    //   InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
    //   return;
    // }


    String orderid = _data != null ? _data.orderid : (_orderStatus != null ? _orderStatus.orderid : '-');
    print('try orderStatus orderid : ' + orderid);
    final orderStatusList = await InvestrendTheme.tradingHttp.orderStatus(
      /*account.brokercode*/
      '',
      /*account.accountcode*/
      '',
      username,
      InvestrendTheme.of(context).applicationPlatform,
      InvestrendTheme.of(context).applicationVersion,
      orderid: orderid,

    );

    int orderStatusCount = orderStatusList != null ? orderStatusList.length : 0;
    print('Got orderStatus : ' + orderStatusCount.toString());
    if (orderStatusCount > 0) {
      _orderStatus.copyValueFrom(orderStatusList.first);
      notifier.value = !notifier.value;
    } else {}
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText('order_detail_title'.tr()),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, value, child) {
                return RefreshIndicator(
                  onRefresh: () async {
                    onRefresh(context);
                  },
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text('Time : ' + DateTime.now().toString()),
                      Text(this._orderStatus.toString()),
                      TextButton(
                          onPressed: () {
                            onRefresh(context);
                          },
                          child: Text('Refresh')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text('close')),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
*/

const String PIN_SUCCESS = 'pin_success';

class ScreenOrderDetail extends StatefulWidget {
  final BuySell _data;
  final OrderStatus? _orderStatus;
  final bool historicalMode;

  const ScreenOrderDetail(this._data, this._orderStatus,
      {this.historicalMode = false, Key? key})
      : super(key: key);

  @override
  _ScreenOrderDetailState createState() =>
      _ScreenOrderDetailState(_data, _orderStatus!,
          historicalMode: historicalMode);
}

class _ScreenOrderDetailState extends BaseStateNoTabs<ScreenOrderDetail> {
  //static const Duration _durationUpdate = Duration(milliseconds: 5000);
  Duration? _durationUpdate;
  final BuySell? data;
  final bool historicalMode;

  Timer? _timer;
  OrderStatus? os;
  List<TradeStatusSummary?>? tradesSummary = List.empty(growable: true);

  _ScreenOrderDetailState(this.data, this.os, {this.historicalMode = false})
      : super(historicalMode ? '/order_detail_historical' : '/order_detail');

  @override
  void onActive() {
    if (historicalMode) {
      //doUpdate();
    } else {
      doUpdate();
      _startTimer();
    }
  }

  @override
  void onInactive() {
    _stopTimer();
  }

  @override
  void initState() {
    super.initState();

    if (InvestrendTheme.tradingHttp.is_production) {
      _durationUpdate = Duration(seconds: 30);
    } else {
      //_durationUpdate = Duration(milliseconds: 1000);
      _durationUpdate = Duration(seconds: 30);
    }
    if (historicalMode) {
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    if (_timer != null) _timer?.cancel();

    final container = ProviderContainer();
    if (onStatusRefreshEvent != null) {
      container
          .read(statusRefreshNotifier)
          .removeListener(onStatusRefreshEvent!);
    }
    onStatusRefreshEvent = null;

    super.dispose();
  }

  void _startTimer() {
    print(routeName + '._startTimer');
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(_durationUpdate!, (timer) {
        if (active) {
          if (onProgress) {
            print(routeName +
                '._startTimer skipped, onProgress : $onProgress at ' +
                DateTime.now().toString());
          } else {
            doUpdate();
          }
        }
      });
    }
  }

  VoidCallback? onStatusRefreshEvent;

  @override
  void didChangeDependencies() {
    print(routeName + ' didChangeDependencies');
    super.didChangeDependencies();

    final notifierRefreshStatus = context.read(statusRefreshNotifier);
    if (onStatusRefreshEvent != null) {
      notifierRefreshStatus.removeListener(onStatusRefreshEvent!);
    } else {
      onStatusRefreshEvent = () {
        if (mounted) {
          print('Triggered Refresh Order Status at : ' +
              notifierRefreshStatus.time +
              '  historicalMode : $historicalMode');
          if (historicalMode) {
          } else {
            doUpdate(pullToRefresh: true);
          }
        }
      };
    }
    notifierRefreshStatus.addListener(onStatusRefreshEvent!);
  }

  void _stopTimer() {
    print(routeName + '._stopTimer');
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }
  }

  bool onProgress = false;
  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  _active : $active  pullToRefresh : $pullToRefresh");

    if (!active) {
      print(routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  _active : $active  pullToRefresh : $pullToRefresh");
      onProgress = false;
      return;
    }

    String? username = context.read(dataHolderChangeNotifier).user.username;
    int selected = context.read(accountChangeNotifier).index;
    Account? account =
        context.read(dataHolderChangeNotifier).user.getAccount(selected);
    if (account == null) {
      print(routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  account is NULL");
      onProgress = false;
      return;
    }

    onProgress = true;
    // int selected = context.read(accountChangeNotifier).index;
    // Account account = InvestrendTheme.of(context).user.getAccount(selected);
    // if(account == null){
    //   InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
    //   return;
    // }

    String? orderid =
        data != null ? data?.orderid : (os != null ? os?.orderid : '-');
    bool reloadUI = false;
    try {
      print('try orderStatus orderid : ' + orderid!);
      final List<OrderStatus>? orderStatus =
          await InvestrendTheme.tradingHttp.orderStatus(
        /*account.brokercode*/
        '',
        /*account.accountcode*/
        '',
        username,
        InvestrendTheme.of(context).applicationPlatform,
        InvestrendTheme.of(context).applicationVersion,
        orderid: orderid,
        //historical: historicalMode
      );

      int orderStatusCount = orderStatus != null ? orderStatus.length : 0;
      print('Got orderStatus : ' + orderStatusCount.toString());
      if (orderStatusCount > 0) {
        for (int i = 0; i < orderStatusCount; i++) {
          OrderStatus? newOS = orderStatus?.elementAt(i);
          if (StringUtils.equalsIgnoreCase(newOS?.orderid, orderid)) {
            os = newOS;
            print('Found orderStatus with orderid : $orderid');
            break;
          }
        }
        /** ASLI 2022-04-22 */
        //os = orderStatus.first;

        //setState(() {});
        reloadUI = true;
      } else {}
    } catch (error) {
      print(routeName + ' doUpdate order_status error : ' + error.toString());
    }
    try {
      print('try tradeStatusSummary orderid : ' + orderid!);
      final List<TradeStatusSummary?>? tradeStatusSummary =
          await InvestrendTheme.tradingHttp.tradeStatusSummary(
              account.brokercode,
              account.accountcode,
              username,
              orderid,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);

      int? tradeStatusSummaryCount =
          tradeStatusSummary != null ? tradeStatusSummary.length : 0;
      print('Got tradeStatusSummary : ' + tradeStatusSummary.toString());
      /*
      tradeStatusSummary.add(TradeStatusSummary(1000, 500, '#1, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1025, 5000, '#4, #5, #6, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1050, 500, '#1, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1100, 5000, '#4, #5, #6, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1125, 500, '#1, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1150, 5000, '#4, #5, #6, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1200, 500, '#1, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1225, 5000, '#4, #5, #6, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1250, 500, '#1, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1275, 5000, '#4, #5, #6, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1300, 500, '#1, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1325, 5000, '#4, #5, #6, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1350, 500, '#1, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      tradeStatusSummary.add(TradeStatusSummary(1375, 5000, '#4, #5, #6, #2, #3, #2, #3, #2, #3, #2, #3, #2, #3'));
      */
      tradesSummary = tradeStatusSummary;
      reloadUI = true;
    } catch (error) {
      print(routeName + ' doUpdate trades_summary error : ' + error.toString());
    }

    if (reloadUI && mounted) {
      setState(() {});
    }
    // list.clear();
    // list.addAll(orderStatus);
    // _valueNotifier.value = orderStatusCount.toString();

    /*
    Stock stock = InvestrendTheme.storedData.findStock(amendData.stock_code);

    if (stock == null || !stock.isValid()) {
      print(orderType.routeName+'.doUpdate stock is NULL');
      return;
    }

    context.read(stockSummaryChangeNotifier).setStock(stock);
    context.read(orderBookChangeNotifier).setStock(stock);
    context.read(tradeBookChangeNotifier).setStock(stock);

    final stockSummary = await HttpSSI.fetchStockSummary(stock.code, stock.defaultBoard);
    if (stockSummary != null) {
      print(orderType.routeName + ' Future Summary DATA : ' + stockSummary.code+'  prev : '+stockSummary.prev.toString());
      //_summaryNotifier.setData(stockSummary);
      context.read(stockSummaryChangeNotifier).setData(stockSummary);
    } else {
      print(orderType.routeName + ' Future Summary NO DATA');
    }
    final orderbook = await HttpSSI.fetchOrderBook(stock.code, stock.defaultBoard);
    if (orderbook != null) {
      print(orderType.routeName + ' Future Orderbook DATA : ' + orderbook.code);
      //InvestrendTheme.of(context).orderbookNotifier.setData(orderbook);
      context.read(orderBookChangeNotifier).setData(orderbook);
    } else {
      print(orderType.routeName + ' Future Orderbook NO DATA');
    }

    final tradebook = await HttpSSI.fetchTradeBook(stock.code, stock.defaultBoard);
    if (tradebook != null) {
      print(orderType.routeName + ' Future Tradebook DATA : ' + tradebook.code);
      //InvestrendTheme.of(context).tradebookNotifier.setData(tradebook);
      context.read(tradeBookChangeNotifier).setData(tradebook);
    } else {
      print(orderType.routeName + ' Future Tradebook NO DATA');
    }
    */
    onProgress = false;
  }

  @override
  PreferredSizeWidget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return AppBar(
      elevation: elevation,
      shadowColor: shadowColor,
      title: AppBarTitleText(historicalMode
          ? 'order_detail_hitorical_title'.tr()
          : 'order_detail_title'.tr()),
    );
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    // String idx_order_no = os != null ? os.idxOrderNumber : '?'; // hardcode
    // String order_status = 'Open'; // hardcode
    // String order_date = '27 Apr 2021'; // hardcode
    // String order_time = '14:00:00'; // hardcode
    // int order_price = data.normalPriceLot.price;
    // int order_lot = data.normalPriceLot.lot;
    // int done_lot = 40; // hardcode
    // int balance_lot = order_lot - done_lot;

    String? idxOrderNo = '-'; // hardcode
    String? orderStatus = '-'; // hardcode
    String? orderDate = '-'; // hardcode
    String? orderTime = '-'; // hardcode
    int? orderPrice = 0;
    int? orderLot = 0;
    int doneLot = 0; // hardcode
    int balanceLot = 0;
    int? value = 0;

    String? orderId = '-';

    String accountInfo = '-';
    String? stockCode = '-';
    String? orderType = '-';

    if (os != null) {
      accountInfo = data!.accountName! +
          ' - ' +
          os!.accountcode +
          ' - ' +
          data!.accountType!;
      orderId = os?.orderid;
      idxOrderNo = os?.idxOrderNumber; // hardcode
      orderStatus = os?.orderStatus; // hardcode
      //order_date = os.orderDate; // hardcode
      orderDate = os?.getDateFormatted();
      //order_time = os.getTime(); // hardcode
      orderTime = os?.getTimeFormatted(); // hardcode
      orderPrice = os?.price;
      orderLot = os!.orderQty ~/ 100;
      doneLot = os!.matchQty ~/ 100; // hardcode
      balanceLot = os!.balanceQty ~/ 100;
      value = os!.price * os!.orderQty;
      stockCode = os?.stockCode;

      if (StringUtils.equalsIgnoreCase(os?.bs, 'B')) {
        orderType = 'buy_text'.tr();
      } else if (StringUtils.equalsIgnoreCase(os?.bs, 'S')) {
        orderType = 'sell_text'.tr();
      } else {
        orderType = os?.bs;
      }
    } else if (data != null) {
      accountInfo = data!.accountName! +
          ' - ' +
          data!.accountCode! +
          ' - ' +
          data!.accountType!;
      orderId = data?.orderid;
      //idx_order_no = os.idxOrderNumber; // hardcode
      //order_status = os.orderStatus; // hardcode
      //order_date = os.orderDate; // hardcode
      //order_time = os.getTime(); // hardcode
      if (!data!.fastMode!) {
        orderPrice = data?.normalPriceLot?.price;
        orderLot = data?.normalPriceLot?.lot;
      }
      //done_lot = 0; // hardcode
      //balance_lot = os.balanceQty;

      value = data!.fastMode! ? data?.fastTotalValue : data?.normalTotalValue;
      stockCode = data?.stock_code;
      orderType = data?.orderType?.text;
    }

    List<Widget> list = List.empty(growable: true);
    list.add(TradeComponentCreator.popupRow(
        context,
        'order_detail_account_label'.tr(),
        accountInfo /*data.accountName + ' - ' + data.accountType*/));
    list.add(TradeComponentCreator.popupRow(
        context, 'order_detail_idx_order_no_label'.tr(), idxOrderNo));
    list.add(TradeComponentCreator.popupRow(
        context, 'order_detail_order_no_label'.tr(), orderId));
    list.add(TradeComponentCreator.popupRow(
        context, 'order_detail_stock_code_label'.tr(), stockCode,
        textStyleValue: InvestrendTheme.of(context)
            .small_w600_compact
            ?.copyWith(color: Theme.of(context).colorScheme.secondary)));
    list.add(TradeComponentCreator.popupRow(
        context, 'order_detail_stock_name_label'.tr(), data?.stock_name));
    list.add(TradeComponentCreator.popupRow(
        context, 'order_detail_order_type_label'.tr(), orderType));
    list.add(TradeComponentCreator.popupRow(
        context, 'order_detail_order_status_label'.tr(), orderStatus));
    list.add(TradeComponentCreator.popupRow(context,
        'order_detail_order_time_label'.tr(), '$orderDate | $orderTime'));
    list.add(TradeComponentCreator.popupRow(
        context,
        'order_detail_order_price_label'.tr(),
        InvestrendTheme.formatMoney(orderPrice, prefixRp: true)));
    list.add(TradeComponentCreator.popupRow(
        context,
        'order_detail_order_lot_label'.tr(),
        InvestrendTheme.formatComma(orderLot)));
    list.add(TradeComponentCreator.popupRow(
        context,
        'order_detail_done_lot_label'.tr(),
        InvestrendTheme.formatComma(doneLot)));
    list.add(TradeComponentCreator.popupRow(
        context,
        'order_detail_balance_lot_label'.tr(),
        InvestrendTheme.formatComma(balanceLot)));
    list.add(SizedBox(height: 8.0));
    list.add(ComponentCreator.divider(context, thickness: 1.0));
    list.add(SizedBox(height: 8.0));
    list.add(TradeComponentCreator.popupRowCustom(
      context,
      TradeComponentCreator.popupTitle(
          context, 'order_detail_order_value_label'.tr(),
          color: InvestrendTheme.of(context).greyLighterTextColor) as Text,
      TradeComponentCreator.popupTitle(
          context, InvestrendTheme.formatMoney(value, prefixRp: true),
          textAlign: TextAlign.right) as Text,
    ));

    if (tradesSummary != null && tradesSummary!.isNotEmpty) {
      list.add(SizedBox(height: 8.0));
      list.add(ComponentCreator.divider(context, thickness: 1.0));
      list.add(SizedBox(height: 8.0));

      list.add(TradeComponentCreator.popupRow(
          context,
          'order_detail_done_summary_label'.tr(),
          'order_detail_done_summary_info_label'.tr(),
          textStyleValue: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(
                  color: InvestrendTheme.of(context).greyLighterTextColor)));
      tradesSummary?.forEach((trade) {
        int lot = trade!.matchQty ~/ 100;
        list.add(TradeComponentCreator.popupRow(
            context,
            ' ',
            InvestrendTheme.formatComma(lot) +
                '  |  ' +
                InvestrendTheme.formatMoney(trade.tradePrice)));
      });
      list.add(Center(
          child: TextButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0)),
                    ),
                    //backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return BottomSheetTradeSummary(tradesSummary);
                    });
              },
              child: Text('order_detail_button_detail_done'.tr()))));
    }

    list.add(SizedBox(height: (80.0 + paddingBottom)));
    return Container(
      //color: Colors.orange,
      width: double.maxFinite,
      height: double.maxFinite,
      child: ListView(
        padding: const EdgeInsets.all(14.0),
        shrinkWrap: true,
        children: list,
      ),
    );
  }

  void executeCancel(BuildContext context) {
    if (context.read(propertiesNotifier).isNeedPinTrading()) {
      Future result = Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ScreenLoginPin(),
            settings: RouteSettings(name: '/login_pin'),
          ));
      result.then((value) {
        if (value is TradingHttpException) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        } else if (value is String) {
          if (StringUtils.equalsIgnoreCase(value, PIN_SUCCESS)) {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  String reffID = Utils.createRefferenceID();
                  return BottomSheetConfirmationCancel(data, os, reffID);
                });
          }
        }
      });
    } else {
      showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0)),
          ),
          //backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            String reffID = Utils.createRefferenceID();
            return BottomSheetConfirmationCancel(data, os, reffID);
          });
    }
  }

  void showScreenAmend(BuildContext context) {
    if (context.read(propertiesNotifier).isNeedPinTrading()) {
      Future result = Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ScreenLoginPin(),
            settings: RouteSettings(name: '/login_pin'),
          ));
      result.then((value) {
        if (value is TradingHttpException) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        } else if (value is String) {
          if (StringUtils.equalsIgnoreCase(value, PIN_SUCCESS)) {
            InvestrendTheme.push(context, ScreenAmend(data?.cloneAsAmend()),
                    ScreenTransition.SlideLeft, '/amend')
                .then((value) {
              if (value != null && value is String) {
                if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
                  Navigator.popUntil(context, (route) {
                    print('popUntil : ' + route.toString());
                    if (StringUtils.equalsIgnoreCase(
                        route.settings.name, '/main')) {
                      return true;
                    }
                    return route.isFirst;
                  });
                  context.read(mainMenuChangeNotifier).setActive(
                      Tabs.Transaction, TabsTransaction.Intraday.index);
                }
              }
            });
          }
        }
      });
    } else {
      InvestrendTheme.push(context, ScreenAmend(data?.cloneAsAmend()),
              ScreenTransition.SlideLeft, '/amend')
          .then((value) {
        if (value != null && value is String) {
          if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
            Navigator.popUntil(context, (route) {
              print('popUntil : ' + route.toString());
              if (StringUtils.equalsIgnoreCase(route.settings.name, '/main')) {
                return true;
              }
              return route.isFirst;
            });
            context
                .read(mainMenuChangeNotifier)
                .setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
          }
        }
      });
    }
  }

  Widget? createBottomSheet(BuildContext context, double paddingBottom) {
    if (historicalMode) {
      return null;
    }
    String tag;
    if (data!.isBuy()) {
      tag = 'button_buy';
    } else if (data!.isSell()) {
      tag = 'button_sell';
    } else {
      tag = '???';
    }

    List<Widget> list = List.empty(growable: true);
    bool canWithdraw = os != null && os!.canWithdraw();
    if (canWithdraw) {
      list.add(Expanded(
        flex: 1,
        //child: TextButton,
        child: TextButton(
          child: Text(
            'order_detail_button_cancel'.tr(),
            //style: Theme.of(context).textTheme.button.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: InvestrendTheme.redText),
          ),
          onPressed: () {
            executeCancel(context);
            /*
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  String reffID = Utils.createRefferenceID();
                  return BottomSheetConfirmationCancel(data, os, reffID);
                });

             */
          },
        ),
      ));
    }

    if (list.isNotEmpty) {
      list.add(SizedBox(
        width: 24.0,
      ));
    }

    bool canAmend = os != null && os!.canAmend();
    // bool canAmend = true;
    if (canAmend) {
      list.add(Expanded(
        flex: 1,
        //child: OutlinedButton(child: Text('order_detail_button_amend'.tr()),
        child: ComponentCreator.roundedButton(
            context,
            'order_detail_button_amend'.tr(),
            Theme.of(context).colorScheme.secondary,
            InvestrendTheme.of(context).whiteColor,
            Theme.of(context).colorScheme.secondary, () {
          /*
              int index = context.read(dataHolderChangeNotifier).user.getIndexAccountByCode(os.brokercode, os.accountcode);
              print(routeName+' amend got indexAccount : $index  for '+os.accountcode);
              if(index >= 0){
                context.read(accountChangeNotifier).setIndex(index);
              }else{
                InvestrendTheme.of(context).showSnackBar(context, 'Can not find account in list Account [index]');
                return;
              }
              */
          /*
              Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(os.brokercode, os.accountcode);
              if(account != null){
                int index = context.read(dataHolderChangeNotifier).user.getIndexAccountByCode(os.brokercode, os.accountcode);
                print(routeName+' amend got indexAccount : $index  for '+os.accountcode);
                if(index >= 0){
                  context.read(accountChangeNotifier).setIndex(index);
                }else{
                  InvestrendTheme.of(context).showSnackBar(context, 'Can not find account in list Account [index]');
                  return;
                }
              }else{
                InvestrendTheme.of(context).showSnackBar(context, 'Can not find account in list Account');
                return;
              }
               */

          showScreenAmend(context);
          /*
              InvestrendTheme.push(context, ScreenAmend(data.cloneAsAmend()), ScreenTransition.SlideLeft, '/amend').then((value) {
                if (value != null && value is String) {
                  if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
                    //Navigator.pop(context,'FINISHED');
                    //InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.SlideLeft);
                    //Navigator.popUntil(context, ModalRoute.withName('/main'));
                    Navigator.popUntil(context, (route) {
                      print('popUntil : ' + route.toString());
                      if(StringUtils.equalsIgnoreCase(route?.settings?.name, '/main')){
                        return true;
                      }
                      return route.isFirst;
                    });
                    context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
                  }
                }
              });
              */
        }),
      ));
    }

    return Padding(
      padding: EdgeInsets.only(
          top: 8.0,
          bottom: paddingBottom > 0 ? paddingBottom : 8.0,
          right: 24.0,
          left: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: list,
        /*
        children: [
          Expanded(
            flex: 1,
            //child: TextButton,
            child: TextButton(
              child: Text(
                'order_detail_button_cancel'.tr(),
                style: Theme.of(context).textTheme.button.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
              ),
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                    ),
                    //backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      String reffID = Utils.createRefferenceID();
                      return BottomSheetConfirmationCancel(data, os, reffID);
                    });
              },
            ),
          ),
          SizedBox(
            width: 24.0,
          ),
          Expanded(
            flex: 1,
            //child: OutlinedButton(child: Text('order_detail_button_amend'.tr()),
            child: ComponentCreator.roundedButton(context, 'order_detail_button_amend'.tr(), Theme.of(context).accentColor,
                InvestrendTheme.of(context).whiteColor, Theme.of(context).accentColor, () {
              InvestrendTheme.push(context, ScreenAmend(data.cloneAsAmend()), ScreenTransition.SlideLeft, '/amend').then((value) {
                if (value != null && value is String) {
                  if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
                    //Navigator.pop(context,'FINISHED');
                    //InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.SlideLeft);
                    //Navigator.popUntil(context, ModalRoute.withName('/main'));
                    Navigator.popUntil(context, (route) {
                      print('popUntil : ' + route.toString());
                      return route.isFirst;
                    });
                    context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
                  }
                }
              });
            }),
          ),
        ],
        */
      ),
    );
  }
}

class BottomSheetTradeSummary extends StatelessWidget {
  final List<TradeStatusSummary?>? tradesSummary;

  const BottomSheetTradeSummary(this.tradesSummary, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double heightRowReguler = UIHelper.textSize(
            'WgjLl', InvestrendTheme.of(context).regular_w600_compact)
        .height;

    //double contentHeight = 0.0;
    //contentHeight += 30.0 + 24.0 + 39.0;
    // contentHeight += 200.0;
    // contentHeight += heightRowReguler;
    // contentHeight += 3.0;
    // contentHeight += 55.0 + 55.0 + 24.0 + 24.0 + 5.0;

    List<Widget> list = List.empty(growable: true);
    list.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TradeComponentCreator.popupTitle(
                context, 'order_detail_done_summary_label'.tr()),
            flex: 1,
          ),
          IconButton(
              //icon: Icon(Icons.clear),
              icon: Image.asset(
                'images/icons/action_clear.png',
                color: InvestrendTheme.of(context).greyLighterTextColor,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
    // contentHeight += heightRowReguler;
    list.add(SizedBox(
      height: 16.0,
    ));
    // contentHeight += 16.0;

    if (tradesSummary != null && tradesSummary!.isNotEmpty) {
      TextStyle? styleLabel = InvestrendTheme.of(context)
          .small_w400_compact
          ?.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
      TextStyle? styleValue = InvestrendTheme.of(context).small_w400_compact;
      list.add(Expanded(
          flex: 1,
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
              itemCount: tradesSummary!.length,
              separatorBuilder: (BuildContext context, int index) {
                return ComponentCreator.divider(context);
              },
              itemBuilder: (BuildContext context, int index) {
                TradeStatusSummary? trade = tradesSummary?.elementAt(index);
                int lot = trade!.matchQty ~/ 100;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: InvestrendTheme.cardPaddingVertical,
                          bottom: InvestrendTheme.cardPadding),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: RichText(
                              text: TextSpan(
                                  text: 'order_detail_order_price_label'.tr() +
                                      ' : ',
                                  style: styleLabel,
                                  children: [
                                    TextSpan(
                                        text: InvestrendTheme.formatMoney(
                                                trade.tradePrice) +
                                            '   ',
                                        style: styleValue),
                                    // TextSpan(text: 'order_detail_done_lot_label'.tr() + ' : ', style: styleLabel),
                                    // TextSpan(text: InvestrendTheme.formatComma(trade.matchQty), style: styleValue),
                                  ]),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: RichText(
                              text: TextSpan(
                                  text: 'order_detail_done_lot_label'.tr() +
                                      ' : ',
                                  style: styleLabel,
                                  children: [
                                    TextSpan(
                                        text: InvestrendTheme.formatComma(lot),
                                        style: styleValue),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'order_detail_idx_trade_no_label'.tr() + ' : ',
                      style: styleLabel,
                    ),
                    SizedBox(
                      height: InvestrendTheme.cardPadding,
                    ),
                    Text(
                      trade.idxTradeNumber!,
                      style: styleValue,
                      softWrap: true,
                    ),
                    SizedBox(
                      height: InvestrendTheme.cardPaddingVertical,
                    )
                  ],
                );
              },
            ),
          )));

      //
      // tradesSummary.forEach((trade) {
      //   list.add(Column(
      //     children: [
      //       RichText(
      //         text: TextSpan(text: 'order_detail_order_price_label'.tr() + ' : ', style: styleLabel, children: [
      //           TextSpan(text: InvestrendTheme.formatMoney(trade.tradePrice), style: styleValue),
      //           TextSpan(text: 'order_detail_done_lot_label'.tr() + ' : ', style: styleLabel),
      //           TextSpan(text: InvestrendTheme.formatComma(trade.matchQty), style: styleValue),
      //         ]),
      //       ),
      //       RichText(
      //         text: TextSpan(text: 'order_detail_done_lot_label'.tr() + ' : ', style: styleLabel, children: [
      //           TextSpan(text: trade.idxTradeId, style: styleValue),
      //         ]),
      //       ),
      //       /*
      //       Row(
      //         children: [
      //
      //           Text.rich(TextSpan(text: 'order_detail_order_price_label'.tr()+' : ', style: styleLabel)),
      //           Text('order_detail_order_price_label'.tr()+' : '+InvestrendTheme.formatMoney(trade.tradePrice)),
      //           Text('order_detail_done_lot_label'.tr()+' : '+InvestrendTheme.formatComma(trade.matchQty))
      //         ],
      //       ),
      //       Text('order_detail_done_lot_label'.tr()+' : '+InvestrendTheme.formatComma(trade.matchQty)),
      //       Text('order_detail_idx_trade_no_label'.tr()+' : '+trade.idxTradeId, softWrap: true,),
      //        */
      //     ],
      //   ));
      // });
    }

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        // color: Colors.orangeAccent,
        padding: const EdgeInsets.only(
            top: 30.0, bottom: 24.0, left: 24.0, right: 24.0),
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: list,
        ),
      ),
    );
  }
}

class BottomSheetConfirmationCancel extends StatelessWidget {
  final BuySell? data;
  final OrderStatus? orderStatus;
  final String reffID;

  BottomSheetConfirmationCancel(this.data, this.orderStatus, this.reffID);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double heightRowReguler = UIHelper.textSize(
            'WgjLl', InvestrendTheme.of(context).regular_w600_compact)
        .height;

    double contentHeight = 0.0;
    contentHeight += 30.0 + 24.0 + 39.0;
    // contentHeight += 200.0;
    // contentHeight += heightRowReguler;
    // contentHeight += 3.0;
    // contentHeight += 55.0 + 55.0 + 24.0 + 24.0 + 5.0;

    List<Widget> list = List.empty(growable: true);
    list.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TradeComponentCreator.popupTitle(
                context, 'order_detail_confirmation_cancel_title'.tr()),
            flex: 1,
          ),
          IconButton(
              //icon: Icon(Icons.clear),
              icon: Image.asset(
                'images/icons/action_clear.png',
                color: InvestrendTheme.of(context).greyLighterTextColor,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
    contentHeight += heightRowReguler;
    list.add(SizedBox(
      height: 16.0,
    ));
    contentHeight += 16.0;

    list.add(Center(
      child: Text('order_detail_confirmation_cancel_content'.tr(),
          style: InvestrendTheme.of(context).regular_w400_compact),
    ));
    contentHeight += heightRowReguler;
    list.add(SizedBox(
      height: 16.0,
    ));
    contentHeight += 16.0;
    list.add(Divider(
      thickness: 1.0,
    ));
    contentHeight += 3.0;
    list.add(SizedBox(
      height: 16.0,
    ));
    contentHeight += 16.0;
    /*
    list.add(Container(
      width: double.maxFinite,
      child: ComponentCreator.roundedButton(context, 'order_detail_confirmation_cancel_button_cancel'.tr(), InvestrendTheme.cancelColor,
          InvestrendTheme.of(context).whiteColor, InvestrendTheme.cancelColor, () {
        print('cancel order clicked');
        //Navigator.pop(context, data.clone()); // clear data

        String username = context.read(dataHolderChangeNotifier).user.username;
        if (orderStatus != null) {
          print('cancel order using orderStatus');
          InvestrendTheme.tradingHttp.withdraw(this.reffID, orderStatus.brokercode, orderStatus.accountcode, username, orderStatus.orderid,
              InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
        } else {
          print('cancel order using data buySell');
          InvestrendTheme.tradingHttp.withdraw(this.reffID, data.brokerCode, data.accountCode, username, data.orderid,
              InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
        }

        Navigator.popUntil(context, (route) {
          print('popUntil : ' + route.toString());
          if (StringUtils.equalsIgnoreCase(route?.settings?.name, '/main')) {
            return true;
          }
          return route.isFirst;
        });
        context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
      }),
    ));
    */
    list.add(Container(
      width: double.maxFinite,
      child: ComponentCreator.roundedButton(
          context,
          'order_detail_confirmation_cancel_button_cancel'.tr(),
          Theme.of(context).primaryColor,
          InvestrendTheme.cancelColor,
          InvestrendTheme.cancelColor, () {
        print('cancel order clicked');
        //Navigator.pop(context, data.clone()); // clear data

        String? username = context.read(dataHolderChangeNotifier).user.username;
        if (orderStatus != null) {
          print('cancel order using orderStatus');
          InvestrendTheme.tradingHttp.withdraw(
              this.reffID,
              orderStatus?.brokercode,
              orderStatus?.accountcode,
              username,
              orderStatus?.orderid,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
        } else {
          print('cancel order using data buySell');
          InvestrendTheme.tradingHttp.withdraw(
              this.reffID,
              data?.brokerCode,
              data?.accountCode,
              username,
              data?.orderid,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
        }

        Navigator.popUntil(context, (route) {
          print('popUntil : ' + route.toString());
          if (StringUtils.equalsIgnoreCase(route.settings.name, '/main')) {
            return true;
          }
          return route.isFirst;
        });
        context
            .read(mainMenuChangeNotifier)
            .setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
      }),
    ));
    contentHeight += 55.0;
    list.add(SizedBox(
      height: 16.0,
    ));
    contentHeight += 16.0;
    /*
    list.add(Container(
      width: double.maxFinite,
      child: TextButton(
          child: Text(
            'order_detail_confirmation_cancel_button_back'.tr(),
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            print('back clicked');

            Navigator.pop(context); // keep data
          }),
    ));
    */
    list.add(Container(
      width: double.maxFinite,
      child: ComponentCreator.roundedButton(
          context,
          'order_detail_confirmation_cancel_button_back'.tr(),
          InvestrendTheme.cancelColor,
          InvestrendTheme.of(context).whiteColor,
          InvestrendTheme.cancelColor, () {
        print('back clicked');

        Navigator.pop(context); // keep data
      }),
    ));

    contentHeight += 55.0;

    maxHeight = min(contentHeight, maxHeight);
    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        // color: Colors.orangeAccent,
        padding: const EdgeInsets.only(
            top: 30.0, bottom: 24.0, left: 24.0, right: 24.0),
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: list,
        ),
      ),
    );
  }
}
