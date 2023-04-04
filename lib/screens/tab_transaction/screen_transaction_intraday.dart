import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/bottom_sheet/bottom_sheet_transaction_filter.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_login_pin.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction.dart';
import 'package:Investrend/screens/trade/screen_amend.dart';
import 'package:Investrend/screens/trade/screen_order_detail.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenTransactionIntraday extends StatefulWidget {
  /*
  final int tabIndex;
  final TabController tabController;

  @override
  _ScreenTransactionIntradayState createState() => _ScreenTransactionIntradayState();

  ScreenTransactionIntraday(this.tabIndex, this.tabController, {Key key}) : super(key: key);
  */

  final TabController tabController;
  final int tabIndex;

  ScreenTransactionIntraday(this.tabIndex, this.tabController, {Key key}) : super(key: key);

  @override
  _ScreenTransactionIntradayState createState() => _ScreenTransactionIntradayState(tabIndex, tabController);
}

class _ScreenTransactionIntradayState extends BaseStateNoTabsWithParentTab<ScreenTransactionIntraday> {
  //bool _active = false;
  Timer _timer;
  //static const Duration _durationUpdate = Duration(milliseconds: 1000);
  Duration _durationUpdate;
  static const String PIN_SUCCESS = 'pin_success';
  _ScreenTransactionIntradayState(int tabIndex, TabController tabController)
      : super('/transaction_intraday', tabIndex, tabController, parentTabIndex: Tabs.Transaction.index);

  // List<String> _sort_by_option = [
  //   'transaction_sort_by_open'.tr(),
  //   'transaction_sort_by_amend'.tr(),
  //   'transaction_sort_by_cancelled'.tr(),
  //   'transaction_sort_by_matched'.tr(),
  //   'transaction_sort_by_buy'.tr(),
  //   'transaction_sort_by_sell'.tr(),
  //   'transaction_sort_by_stock'.tr(),
  // ];

  final ValueNotifier _sortByNotifier = ValueNotifier<int>(0);
  final SlidableController slidableController = SlidableController();
  ValueNotifier<int> _valueNotifier = ValueNotifier<int>(0);
  List<OrderStatus> listDisplay = List.empty(growable: true);
  List<OrderStatus> list = List.empty(growable: true);
  bool canTapRow = true;

  // @override
  // bool get wantKeepAlive => true;
  /*
  bool isCurrentTab() {
    print('TransactionIntraday.isCurrentTab widget.tabIndex : ' +
        widget.tabIndex.toString() +
        '   tabController : ' +
        widget.tabController.index.toString());
    return widget.tabIndex == widget.tabController.index;
  }
  */
  void onActive() {
    canTapRow = true;
    // if (!isCurrentTab()) {
    //   print('TransactionIntraday.onActive [aborted] _active : $_active  --> caused by not not on current Tab.');
    //   return;
    // }
    // _active = true;
    // print('TransactionIntraday.onActive _active : $_active');
    //print('TransactionIntraday.onActive _active : $_active');
    //_startTimer();
    // WidgetsBinding.instance.addPostFrameCallback((_){
    //   context.read(buySellChangeNotifier).mustNotifyListener();
    //
    //   doUpdate();
    //   _startTimer();
    // });

    context.read(buySellChangeNotifier).mustNotifyListener();
    doUpdate();
    _startTimer();

    // runPostFrame(() {
    //   context.read(buySellChangeNotifier).mustNotifyListener();
    //
    //   doUpdate();
    //   _startTimer();
    // });
  }

  void onInactive() {
    //_active = false;
    //print('TransactionIntraday.onInactive _active : $_active');
    slidableController.activeState = null;
    canTapRow = true;
    _stopTimer();
  }

  void _startTimer() {
    if (_timer == null || !_timer.isActive) {
      print(routeName + ' _startTimer');
      _timer = Timer.periodic(_durationUpdate, (timer) {
        if (active && mounted) {
          if (onProgress) {
            print(routeName + ' timer aborted caused by onProgress : $onProgress');
          } else {
            doUpdate();
          }
        }
      });
    }
  }

  void _stopTimer() {
    if (_timer == null || !_timer.isActive) {
      return;
    }
    print(routeName + ' _stopTimer');
    _timer.cancel();
    _timer = null;
  }

  bool onProgress = false;

  Future doUpdate({bool pullToRefresh = false}) async {
    print('TransactionIntraday.doUpdate : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");

    if (!active) {
      print(routeName + '.doUpdate Aborted : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");
      return;
    }
    onProgress = true;

    try {
      User user = context.read(dataHolderChangeNotifier).user;
      int selected = context.read(accountChangeNotifier).index;
      Account account = user.getAccount(selected);
      if (account == null) {
        String errorNoAccount = 'error_no_account_selected'.tr();
        //InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
        InvestrendTheme.of(context).showSnackBar(context, errorNoAccount);
        onProgress = false;
        return false;
      }

      final orderStatus = await InvestrendTheme.tradingHttp.orderStatus(account.brokercode /*''*/, account.accountcode /*''*/, user.username,
          InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      int orderStatusCount = orderStatus != null ? orderStatus.length : 0;
      DebugWriter.info('Got orderStatus : ' + orderStatusCount.toString());

      listDisplay.clear();
      list.clear();
      if (orderStatus != null) {
        final notifier = context.read(transactionIntradayFilterChangeNotifier);
        orderStatus.forEach((status) {
          if (status.isFilterValid(notifier.index_transaction, notifier.index_status)) {
            listDisplay.add(status);
          }
        });

        list.addAll(orderStatus);
      }
      if(mounted){
        if (_valueNotifier.value == orderStatusCount) {
          _valueNotifier.value = Random().nextInt(1000).toInt();
        } else {
          _valueNotifier.value = orderStatusCount;
        }
      }
    } catch (error) {
      print(routeName + ' doUpdate Exception : ' + error.toString());
      print(error);
      handleNetworkError(context, error);
    }

    onProgress = false;
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  //VoidCallback tabListener;
  final String PROP_SELECTED_FILTER_TRANSACTION = 'filterTransaction';
  final String PROP_SELECTED_FILTER_STATUS = 'filterStatus';

  @override
  void initState() {
    super.initState();
    print('TransactionIntraday.initState');
    groupStatus = AutoSizeGroup();


    if(InvestrendTheme.tradingHttp.is_production){
      _durationUpdate = Duration(seconds: 30);
    }else{
      //_durationUpdate = Duration(milliseconds: 1000);
      _durationUpdate = Duration(seconds: 30);
    }


    runPostFrame(() {
      // #1 get properties
      int filterTransaction = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_FILTER_TRANSACTION, 0);
      int filterStatus = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_FILTER_STATUS, 0);

      // #2 use properties
      int usedTransaction = min(filterTransaction, FilterTransaction.values.length - 1);
      int usedStatus = min(filterStatus, FilterStatus.values.length - 1);
      context.read(transactionIntradayFilterChangeNotifier).setIndex(usedTransaction, usedStatus);

      // #3 check properties if changed, then save again
      if (filterTransaction != usedTransaction) {
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_FILTER_TRANSACTION, usedTransaction);
      }
      if (filterStatus != usedStatus) {
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_FILTER_STATUS, usedStatus);
      }
    });
  }

  VoidCallback filterApplied;
  VoidCallback onAccountChanged;

  VoidCallback onStatusRefreshEvent;

  @override
  void didChangeDependencies() {
    print('TransactionIntraday.didChangeDependencies');
    super.didChangeDependencies();
    final notifier = context.read(transactionIntradayFilterChangeNotifier);
    if (filterApplied != null) {
      notifier.removeListener(filterApplied);
    } else {
      filterApplied = () {
        if (mounted) {
          context
              .read(propertiesNotifier)
              .properties
              .saveInt(routeName, PROP_SELECTED_FILTER_TRANSACTION, context.read(transactionIntradayFilterChangeNotifier).index_transaction);
          context
              .read(propertiesNotifier)
              .properties
              .saveInt(routeName, PROP_SELECTED_FILTER_STATUS, context.read(transactionIntradayFilterChangeNotifier).index_status);
          doUpdate(pullToRefresh: true);
        }
      };
    }
    notifier.addListener(filterApplied);

    final notifierAccount = context.read(accountChangeNotifier);
    if (onAccountChanged != null) {
      notifierAccount.removeListener(onAccountChanged);
    } else {
      onAccountChanged = () {
        if (mounted) {
          doUpdate(pullToRefresh: true);
        }
      };
    }
    notifierAccount.addListener(onAccountChanged);

    // tabListener = (){
    //   print('TransactionIntraday.tabListener : '+DefaultTabController.of(context).index.toString());
    // };
    // DefaultTabController.of(context).addListener(tabListener);


    final notifierRefreshStatus = context.read(statusRefreshNotifier);
    if (onStatusRefreshEvent != null) {
      notifierRefreshStatus.removeListener(onStatusRefreshEvent);
    } else {
      onStatusRefreshEvent = () {
        if (mounted) {
          print('Triggered Refresh Order Status at : '+notifierRefreshStatus.time);
          doUpdate(pullToRefresh: true);
        }
      };
    }
    notifierRefreshStatus.addListener(onStatusRefreshEvent);
  }

  @override
  void dispose() {
    print('TransactionIntraday.dispose start');

    final container = ProviderContainer();
    if (filterApplied != null) {
      container.read(transactionIntradayFilterChangeNotifier).removeListener(filterApplied);
    }
    filterApplied = null;

    if (onAccountChanged != null) {
      container.read(accountChangeNotifier).removeListener(onAccountChanged);
    }
    onAccountChanged = null;

    if (onStatusRefreshEvent != null) {
      container.read(statusRefreshNotifier).removeListener(onStatusRefreshEvent);
    }
    onStatusRefreshEvent = null;

    _stopTimer();
    _sortByNotifier.dispose();
    _valueNotifier.dispose();
    //DefaultTabController.of(context).removeListener(tabListener);
    print('TransactionIntraday.dispose end');
    super.dispose();
  }

  /*
  @override
  Widget build(BuildContext context) {
    double statusWidth = UIHelper
        .textSize('PARTIAL', InvestrendTheme
        .of(context)
        .more_support_w400_compact)
        .width +
        InvestrendTheme.cardPadding +
        InvestrendTheme.cardPadding;

    return ScreenAware(
      routeName: '/transaction_intraday',
      onActive: onActive,
      onInactive: onInactive,
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
        child: Column(
          children: [
            Row(
              children: [
                OutlinedButton(
                  //elevation: 0.0,
                  //visualDensity: VisualDensity.compact,
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 15,
                        color: Colors.grey,
                      ),
                      Text(
                        'Filter',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText2,
                      ),
                    ],
                  ),
                ),

                Spacer(
                  flex: 1,
                ),
                MaterialButton(
                  elevation: 0.0,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: InvestrendTheme
                      .of(context)
                      .tileBackground,
                  child: Row(
                    children: [
                      Text(
                        'Sort by Amend',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(fontWeight: FontWeight.w300),
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onPressed: () {
                    InvestrendTheme.of(context).showSnackBar(context, 'Action sort');
                  },
                ),
              ],
            ),

            Expanded(
              flex: 1,
              child: ValueListenableBuilder<int>(
                  valueListenable: _valueNotifier,
                  builder: (context, value, child) {
                    return ListView.builder(
                        shrinkWrap: false,
                        padding: const EdgeInsets.all(8),
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return tileTransaction(context, list.elementAt(index), statusWidth);
                          // return tile(context, list.elementAt(index), statusWidth);

                          // return Container(
                          //   height: 50,
                          //   color: Colors.amber[colorCodes[index]],
                          //   child: Center(child: Text('Entry ${entries[index]}')),
                          // );
                        });
                  }),
            ),

            // Expanded(
            //   flex: 1,
            //   child: ListView.builder(
            //       shrinkWrap: false,
            //       padding: const EdgeInsets.all(8),
            //       itemCount: 20,
            //       itemBuilder: (BuildContext context, int index) {
            //         return tileTransaction(context);
            //         // return Container(
            //         //   height: 50,
            //         //   color: Colors.amber[colorCodes[index]],
            //         //   child: Center(child: Text('Entry ${entries[index]}')),
            //         // );
            //       }),
            // ),
          ],
        ),
      ),
    );
  }
  */
  /*
  Widget tile(BuildContext context, OrderStatus os, double statusWidth) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 800),

      ///Widget displayed by default
      closedBuilder: (BuildContext context, void Function() action) {
        ///A picture displayed by the entry
        return row(context, os, statusWidth);
      },

      ///Click to open the page
      openBuilder: (BuildContext context, void Function({Object returnValue}) action) {
        return detailPage(context, os, statusWidth);
      },
      tappable: true,
    );
  }
  */

  Widget tileTransactionNew(BuildContext context, OrderStatus os, double statusWidth) {
    String bs = '-';
    Color bsColor = Colors.yellow;
    if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
      bs = 'order_status_buy'.tr();
      bsColor = InvestrendTheme.buyTextColor;
    } else {
      bs = 'order_status_sell'.tr();
      bsColor = InvestrendTheme.sellTextColor;
    }
    //double widthDateTime = 100.0;

    return InkWell(
      onTap: () {
        Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(os.brokercode, os.accountcode);
        if (account != null) {
          OrderType orderType;
          if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
            orderType = OrderType.Buy;
          } else if (StringUtils.equalsIgnoreCase(os.bs, 'S')) {
            orderType = OrderType.Sell;
          } else {
            orderType = OrderType.Unknown;
          }

          BuySell data = BuySell(orderType);
          data.orderid = os.orderid;
          data.accountType = account.type;
          data.accountName = account.accountname;
          data.accountCode = os.accountcode;
          data.brokerCode = os.brokercode;
          data.stock_code = os.stockCode;

          Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
          data.stock_name = stock != null ? stock.name : '-';
          //data.normalTotalValue = os.price * os.orderQty;
          data.fastTotalValue = 0;
          data.fastMode = false;
          data.tradingLimitUsage = 0;
          data.setNormalPriceLot(os.price, os.orderQty ~/ 100);

          //InvestrendTheme.push(context, ScreenOrderDetail(data, os), ScreenTransition.SlideDown, '/order_detail');
          //InvestrendTheme.push(context, ScreenOrderDetail(data, os), ScreenTransition.SlideLeft, '/order_detail', durationMilisecond: 300);
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => ScreenOrderDetail(
                        data,
                        os,
                        historicalMode: false,
                      ),
                  settings: RouteSettings(name: '/order_detail')));
        } else {
          String error = 'validation_account_not_related_to_user'.tr();
          error = error.replaceAll('#account#', os.accountcode);
          error = error.replaceAll('#user#', context.read(dataHolderChangeNotifier).user.username);
          InvestrendTheme.of(context).showSnackBar(context, error);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 10.0,
          bottom: 10.0,
        ),
        // color: Colors.cyan,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(os.stockCode, style: InvestrendTheme.of(context).regular_w600_compact),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      bs,
                      style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: bsColor),
                    ),
                  ],
                ),
                SizedBox(
                  width: InvestrendTheme.cardMargin,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        InvestrendTheme.formatComma((os.orderQty ~/ 100)) + ' Lot',
                        style: InvestrendTheme.of(context).more_support_w600_compact,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        InvestrendTheme.formatMoney(os.price, prefixRp: true),
                        style: InvestrendTheme.of(context).more_support_w600_compact,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        InvestrendTheme.formatMoney((os.price * os.orderQty), prefixRp: true),
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                SizedBox(
                  width: statusWidth,
                  child: Row(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        //width: statusWidth,
                        padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          color: os.backgroundColor(context),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: AutoSizeText(
                          os.orderStatus,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          group: groupStatus,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // debug purpose
            /*
            Text(
              'Debug -->  order_id : ' +
                  os.orderid +
                  '  account : ' +
                  os.accountcode +
                  '\namendPrice : ' +
                  os.amendPrice.toString() +
                  '  amendQty : ' +
                  (os.amendQty ~/ 100).toString(),
              style: InvestrendTheme.of(context).support_w400_compact,
            ),
            */

            // SizedBox(
            //   height: 15,
            // ),
            (os.gotMessage()
                ? Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      os.message,
                      style: InvestrendTheme.of(context)
                          .more_support_w400_compact
                          .copyWith(fontSize: 10.0, color: InvestrendTheme.of(context).greyLighterTextColor),
                    ),
                  )
                : SizedBox(
                    width: 1.0,
                  )),
            //ComponentCreator.divider(context),
          ],
        ),
      ),
    );
  }

  Widget tileTransaction(BuildContext context, OrderStatus os, double statusWidth) {
    String bs = '-';
    Color bsColor = Colors.yellow;
    if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
      bs = 'order_status_buy'.tr();
      bsColor = InvestrendTheme.buyTextColor;
    } else {
      bs = 'order_status_sell'.tr();
      bsColor = InvestrendTheme.sellTextColor;
    }

    return InkWell(
      onTap: () {
        Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(os.brokercode, os.accountcode);
        if (account != null) {
          OrderType orderType;
          if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
            orderType = OrderType.Buy;
          } else if (StringUtils.equalsIgnoreCase(os.bs, 'S')) {
            orderType = OrderType.Sell;
          } else {
            orderType = OrderType.Unknown;
          }

          BuySell data = BuySell(orderType);
          data.orderid = os.orderid;
          data.accountType = account.type;
          data.accountName = account.accountname;
          data.accountCode = os.accountcode;
          data.brokerCode = os.brokercode;
          data.stock_code = os.stockCode;

          Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
          data.stock_name = stock != null ? stock.name : '-';
          //data.normalTotalValue = os.price * os.orderQty;
          data.fastTotalValue = 0;
          data.fastMode = false;
          data.tradingLimitUsage = 0;
          data.setNormalPriceLot(os.price, os.orderQty ~/ 100);

          //InvestrendTheme.push(context, ScreenOrderDetail(data, os), ScreenTransition.SlideDown, '/order_detail');
          //InvestrendTheme.push(context, ScreenOrderDetail(data, os), ScreenTransition.SlideLeft, '/order_detail', durationMilisecond: 300);
          Navigator.push(
              context, CupertinoPageRoute(builder: (_) => ScreenOrderDetail(data, os), settings: RouteSettings(name: '/order_detail')));
        } else {
          String error = 'validation_account_not_related_to_user'.tr();
          error = error.replaceAll('#account#', os.accountcode);
          error = error.replaceAll('#user#', context.read(dataHolderChangeNotifier).user.username);
          InvestrendTheme.of(context).showSnackBar(context, error);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(os.stockCode, style: InvestrendTheme.of(context).regular_w600_compact),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      bs,
                      style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: bsColor),
                    ),
                  ],
                ),
                SizedBox(
                  width: InvestrendTheme.cardMargin,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        InvestrendTheme.formatComma((os.orderQty ~/ 100)) + ' Lot',
                        style: InvestrendTheme.of(context).more_support_w600_compact,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        InvestrendTheme.formatMoney(os.price, prefixRp: true),
                        style: InvestrendTheme.of(context).more_support_w600_compact,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        InvestrendTheme.formatMoney((os.price * os.orderQty), prefixRp: true),
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                SizedBox(
                  width: statusWidth,
                  child: Row(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        //width: statusWidth,
                        padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          color: os.backgroundColor(context),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: AutoSizeText(
                          os.orderStatus,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          group: groupStatus,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // debug purpose
            /*
            Text(
              'Debug -->  order_id : ' +
                  os.orderid +
                  '  account : ' +
                  os.accountcode +
                  '\namendPrice : ' +
                  os.amendPrice.toString() +
                  '  amendQty : ' +
                  (os.amendQty ~/ 100).toString(),
              style: InvestrendTheme.of(context).support_w400_compact,
            ),
            */

            // SizedBox(
            //   height: 15,
            // ),
            (os.gotMessage()
                ? Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                    child: Text(
                      os.message,
                      style: InvestrendTheme.of(context)
                          .more_support_w400
                          .copyWith(fontSize: 10.0, color: InvestrendTheme.of(context).greyLighterTextColor),
                    ),
                  )
                : SizedBox(
                    height: 15.0,
                  )),
            ComponentCreator.divider(context),
          ],
        ),
      ),
    );
  }

  void executeCancel(BuildContext context, OrderStatus os) {
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  String reffID = Utils.createRefferenceID();
                  return BottomSheetConfirmationCancel(null, os, reffID);
                });
          }
        }
      });
    } else {
      showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          ),
          //backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            String reffID = Utils.createRefferenceID();
            return BottomSheetConfirmationCancel(null, os, reffID);
          });
    }
  }

  void showScreenAmend(BuildContext context, OrderStatus os) {

    Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(os.brokercode, os.accountcode);
    if (account != null) {
      OrderType orderType;
      if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
        orderType = OrderType.Buy;
      } else if (StringUtils.equalsIgnoreCase(os.bs, 'S')) {
        orderType = OrderType.Sell;
      } else {
        orderType = OrderType.Unknown;
      }

      BuySell data = BuySell(orderType);
      data.orderid = os.orderid;
      data.accountType = account.type;
      data.accountName = account.accountname;
      data.accountCode = os.accountcode;
      data.brokerCode = os.brokercode;
      data.stock_code = os.stockCode;

      Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
      data.stock_name = stock != null ? stock.name : '-';
      //data.normalTotalValue = os.price * os.orderQty;
      data.fastTotalValue = 0;
      data.fastMode = false;
      data.tradingLimitUsage = 0;
      data.setNormalPriceLot(os.price, os.orderQty ~/ 100);

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
              InvestrendTheme.push(context, ScreenAmend(data.cloneAsAmend()), ScreenTransition.SlideLeft, '/amend').then((value) {
                if (value != null && value is String) {
                  if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
                    Navigator.popUntil(context, (route) {
                      print('popUntil : ' + route.toString());
                      if (StringUtils.equalsIgnoreCase(route?.settings?.name, '/main')) {
                        return true;
                      }
                      return route.isFirst;
                    });
                    context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
                  }
                }
              });
            }
          }
        });
      } else {
        InvestrendTheme.push(context, ScreenAmend(data.cloneAsAmend()), ScreenTransition.SlideLeft, '/amend').then((value) {
          if (value != null && value is String) {
            if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
              Navigator.popUntil(context, (route) {
                print('popUntil : ' + route.toString());
                if (StringUtils.equalsIgnoreCase(route?.settings?.name, '/main')) {
                  return true;
                }
                return route.isFirst;
              });
              context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
            }
          }
        });
      }
    }else{
      InvestrendTheme.of(context).showSnackBar(context, 'Can\'t find order information locally.');
      print('Can\'t find order information locally.');
    }
  }

  AutoSizeGroup autoSizeGroup = AutoSizeGroup();
  Widget createSlidableRowAmendWithdraw(BuildContext context, OrderStatus os, double statusWidth) {
    List<Widget> listActions = List.empty(growable: true);
    bool isBuy = StringUtils.equalsIgnoreCase(os.bs, 'B');
    if (os.canAmend()) {
      String button_amend = 'button_amend'.tr();
      Color buySellColor = isBuy ? InvestrendTheme.buyColor : InvestrendTheme.sellColor;
      listActions.add(TradeSlideAction(
        button_amend,
        buySellColor,

        () {
          print('amend clicked code : ' + os.stockCode);
          // Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
          // if (stock == null) {
          //   print('amend clicked code : ' + os.stockCode + ' aborted, not find stock on StockStorer');
          //   return;
          // }

          //context.read(primaryStockChangeNotifier).setStock(stock);
          showScreenAmend(context, os);


          // bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          // InvestrendTheme.pushScreenTrade(
          //   context,
          //   hasAccount,
          //   type: OrderType.Buy,
          // );
        },
        tag: isBuy ? 'button_buy' : 'button_sell',
        autoGroup: autoSizeGroup,
      ));
    }

    if (os.canWithdraw()) {
      listActions.add(TradeSlideAction(
        'button_withdraw'.tr(),
        Colors.orange,
        () {
          print('withdraw clicked code : ' + os.stockCode);
          executeCancel(context, os);
          // Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
          // if (stock == null) {
          //   print('withdraw clicked code : ' + os.stockCode + ' aborted, not find stock on StockStorer');
          //   return;
          // }
          //
          // context.read(primaryStockChangeNotifier).setStock(stock);
          //
          // bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          // InvestrendTheme.pushScreenTrade(
          //   context,
          //   hasAccount,
          //   type: OrderType.Sell,
          // );
        },
        tag: 'button_withdraw',
        autoGroup: autoSizeGroup,
      ));
    }

    if (listActions.isNotEmpty) {
      return Slidable(
        controller: slidableController,
        closeOnScroll: true,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.22,
        secondaryActions: listActions,
        child: tileTransactionNew(context, os, statusWidth),
      );
    } else {
      return tileTransactionNew(context, os, statusWidth);
    }
  }

  Widget createSlidableRow(BuildContext context, OrderStatus os, double statusWidth) {
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
              print('buy clicked code : ' + os.stockCode);
              Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
              if (stock == null) {
                print('buy clicked code : ' + os.stockCode + ' aborted, not find stock on StockStorer');
                return;
              }

              context.read(primaryStockChangeNotifier).setStock(stock);

              //InvestrendTheme.push(context, ScreenTrade(OrderType.Buy), ScreenTransition.SlideLeft, '/trade');

              bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
              InvestrendTheme.pushScreenTrade(
                context,
                hasAccount,
                type: OrderType.Buy,
              );
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
              print('sell clicked code : ' + os.stockCode);
              Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
              if (stock == null) {
                print('sell clicked code : ' + os.stockCode + ' aborted, not find stock on StockStorer');
                return;
              }

              context.read(primaryStockChangeNotifier).setStock(stock);
              //InvestrendTheme.push(context, ScreenTrade(OrderType.Sell), ScreenTransition.SlideLeft, '/trade');

              bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
              InvestrendTheme.pushScreenTrade(
                context,
                hasAccount,
                type: OrderType.Sell,
              );
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
        child: tileTransactionNew(
          context,
          os,
          statusWidth,
          /*
          //firstRow: firstRow, //(index == 0),
          onTap: () {
            print('clicked code : ' + os.stockCode + '  canTapRow : $canTapRow');
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
                InvestrendTheme.of(context).showStockDetail(context);
              });
            }
          },
          paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
          summary: summary,
        */
        ));
  }

  Widget createRow(BuildContext context, OrderStatus os, double statusWidth) {
    String bs = '-';
    Color bsColor = Colors.yellow;
    if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
      bs = 'order_status_buy'.tr();
      bsColor = InvestrendTheme.buyTextColor;
    } else {
      bs = 'order_status_sell'.tr();
      bsColor = InvestrendTheme.sellTextColor;
    }
    Color greyDarkerText = InvestrendTheme.of(context).greyDarkerTextColor;
    Color greyLighterText = InvestrendTheme.of(context).greyLighterTextColor;
    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(os.stockCode, style: InvestrendTheme.of(context).regular_w600_compact),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    bs,
                    style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: bsColor),
                  ),
                ],
              ),
              SizedBox(
                width: InvestrendTheme.cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      InvestrendTheme.formatComma((os.orderQty ~/ 100)) + ' Lot',
                      style: InvestrendTheme.of(context).more_support_w600_compact,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      InvestrendTheme.formatMoney(os.price, prefixRp: true),
                      style: InvestrendTheme.of(context).more_support_w600_compact,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      InvestrendTheme.formatMoney((os.price * os.orderQty), prefixRp: true),
                      style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: greyDarkerText),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Container(
                width: statusWidth,
                padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, top: 4.0, bottom: 4.0),
                decoration: BoxDecoration(
                  color: os.backgroundColor(context),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Text(
                  os.orderStatus,
                  textAlign: TextAlign.center,
                  style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: greyDarkerText),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          (os.gotMessage()
              ? Text(
                  os.message,
                  style: InvestrendTheme.of(context).more_support_w400.copyWith(color: greyLighterText),
                )
              : SizedBox(
                  width: 1.0,
                )),
          ComponentCreator.divider(context),
        ],
      ),
    );
  }

  Widget row(BuildContext context, OrderStatus os, double statusWidth) {
    String bs = '-';
    Color bsColor = Colors.yellow;
    if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
      bs = 'order_status_buy'.tr();
      bsColor = InvestrendTheme.buyTextColor;
    } else {
      bs = 'order_status_sell'.tr();
      bsColor = InvestrendTheme.sellTextColor;
    }
    Color greyDarkerText = InvestrendTheme.of(context).greyDarkerTextColor;
    Color greyLighterText = InvestrendTheme.of(context).greyLighterTextColor;
    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(os.stockCode, style: InvestrendTheme.of(context).regular_w600_compact),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    bs,
                    style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: bsColor),
                  ),
                ],
              ),
              SizedBox(
                width: InvestrendTheme.cardMargin,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      InvestrendTheme.formatComma((os.orderQty ~/ 100)) + ' Lot',
                      style: InvestrendTheme.of(context).more_support_w600_compact,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      InvestrendTheme.formatMoney(os.price, prefixRp: true),
                      style: InvestrendTheme.of(context).more_support_w600_compact,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      InvestrendTheme.formatMoney((os.price * os.orderQty), prefixRp: true),
                      style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: greyDarkerText),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Container(
                width: statusWidth,
                padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, top: 4.0, bottom: 4.0),
                decoration: BoxDecoration(
                  //color: InvestrendTheme.of(context).tileBackground,
                  color: os.backgroundColor(context),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Text(
                  os.orderStatus,
                  textAlign: TextAlign.center,
                  style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: greyDarkerText),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          (os.gotMessage()
              ? Text(
                  os.message,
                  style: InvestrendTheme.of(context).more_support_w400.copyWith(color: greyLighterText),
                )
              : SizedBox(
                  width: 1.0,
                )),
          ComponentCreator.divider(context),
        ],
      ),
    );
  }
  /*
  Widget detailPage(BuildContext context, OrderStatus os, double statusWidth) {
    Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(os.brokercode, os.accountcode);
    if (account != null) {
      OrderType orderType;
      if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
        orderType = OrderType.Buy;
      } else if (StringUtils.equalsIgnoreCase(os.bs, 'S')) {
        orderType = OrderType.Sell;
      } else {
        orderType = OrderType.Unknown;
      }

      BuySell data = BuySell(orderType);
      data.orderid = os.orderid;
      data.accountType = account.type;
      data.accountName = account.accountname;
      data.accountCode = os.accountcode;
      data.brokerCode = os.brokercode;
      data.stock_code = os.stockCode;

      Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
      data.stock_name = stock != null ? stock.name : '-';
      data.normalTotalValue = 0;
      data.fastTotalValue = 0;
      data.fastMode = false;
      data.tradingLimitUsage = 0;
      //InvestrendTheme.push(context, ScreenOrderDetail(data, os), ScreenTransition.SlideDown, '/order_detail');
      //return ScreenOrderDetail(data, os);

      return ScreenOrderDetailNew(data, os);
    }
    return Text('open');
  }
  */
  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Widget _options(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8.0 /*, left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin*/),
      child: Row(
        children: [
          OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                    ),
                    //backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      final notifier = context.read(transactionIntradayFilterChangeNotifier);
                      return BottomSheetTransactionIntradayFilter(notifier.index_transaction, notifier.index_status);
                    });
              },
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
          Spacer(
            flex: 1,
          ),
          /*
          ButtonDropdown(_sortByNotifier, _sort_by_option),
          */
        ],
      ),
    );
  }

  Future onRefresh() {
    if (!active) {
      active = true;
      canTapRow = true;
      context.read(buySellChangeNotifier).mustNotifyListener();
      //doUpdate();
      _startTimer();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  AutoSizeGroup groupStatus;

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    double statusWidth = UIHelper.textSize('Withdraw-P', InvestrendTheme.of(context).more_support_w400_compact).width +
        InvestrendTheme.cardPadding +
        InvestrendTheme.cardPadding;

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ValueListenableBuilder<int>(
          valueListenable: _valueNotifier,
          builder: (context, value, child) {
            final filter = context.read(transactionIntradayFilterChangeNotifier);
            bool filterTransaction = filter.index_transaction != FilterTransaction.All.index;
            bool filterStatus = filter.index_status != FilterStatus.All.index;

            if (listDisplay.isEmpty) {
              String emptyDescription = 'transaction_today_empty_description'.tr();
              if (list.isNotEmpty || filterTransaction || filterStatus) {
                if (filterTransaction && filterStatus) {
                  emptyDescription = 'transaction_today_filter_description'.tr();
                } else if (filterTransaction) {
                  emptyDescription = 'transaction_today_filter_transaction_description'.tr();
                } else if (filterStatus) {
                  emptyDescription = 'transaction_today_filter_status_description'.tr();
                }

                emptyDescription = emptyDescription.replaceFirst('#TRX#', FilterTransaction.values.elementAt(filter.index_transaction).text);
                emptyDescription = emptyDescription.replaceFirst('#STS#', FilterStatus.values.elementAt(filter.index_status).text);
                //Filter diterapkan untuk Transaksi #TRX# dan Status #STS#
              } else {
                emptyDescription = 'transaction_today_empty_description'.tr();
              }
              return ListView(
                padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                children: [
                  _options(context),
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 4,
                  ),
                  EmptyTitleLabel(text: 'transaction_today_empty_title'.tr()),
                  SizedBox(
                    height: InvestrendTheme.cardPaddingGeneral,
                  ),
                  EmptyLabel(text: emptyDescription),
                  /*
                  Container(
                      //color: Colors.orange,
                      height: MediaQuery.of(context).size.width,
                      child: EmptyLabel()),
                  */
                ],
              );
            }

            int count = listDisplay.length + 1;
            String filtered;
            if (filterTransaction || filterStatus) {
              //count = count + 1;

              if (filterTransaction && filterStatus) {
                filtered = 'transaction_today_filter_description'.tr();
              } else if (filterTransaction) {
                filtered = 'transaction_today_filter_transaction_description'.tr();
              } else if (filterStatus) {
                filtered = 'transaction_today_filter_status_description'.tr();
              }
              filtered = filtered.replaceFirst('#TRX#', FilterTransaction.values.elementAt(filter.index_transaction).text);
              filtered = filtered.replaceFirst('#STS#', FilterStatus.values.elementAt(filter.index_status).text);
            }
            //count = count + 1;
            return ListView.separated(
              shrinkWrap: false,
              //padding: const EdgeInsets.all(8),
              //padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
              padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
              itemCount: count + 1,
              // di + 1 supaya muncul divider di paling bawah
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _options(context);
                }
                int indexDisplay = index - 1;
                if (indexDisplay < listDisplay.length) {
                  //return tileTransactionNew(context, listDisplay.elementAt(indexDisplay), statusWidth);
                  //return createSlidableRow(context, listDisplay.elementAt(indexDisplay), statusWidth);
                  return createSlidableRowAmendWithdraw(context, listDisplay.elementAt(indexDisplay), statusWidth);
                } else {
                  if (StringUtils.isEmtpy(filtered)) {
                    return SizedBox(
                      width: 1.0,
                    );
                  } else {
                    return EmptyLabel(text: filtered);
                  }
                }
                //return tileTransaction(context, listDisplay.elementAt(index - 1), statusWidth);
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index > 0) {
                  return ComponentCreator.divider(context);
                } else {
                  return SizedBox(
                    width: 1.0,
                  );
                }
              },
            );
          }),
    );
  }
/*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    double statusWidth = UIHelper
        .textSize('PARTIAL', InvestrendTheme
        .of(context)
        .more_support_w400_compact)
        .width +
        InvestrendTheme.cardPadding +
        InvestrendTheme.cardPadding;

    return Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Column(
        children: [

          _options(context),
          Expanded(
            flex: 1,
            child: ValueListenableBuilder<int>(
                valueListenable: _valueNotifier,
                builder: (context, value, child) {
                  return ListView.builder(
                      shrinkWrap: false,
                      padding: const EdgeInsets.all(8),
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return tileTransaction(context, list.elementAt(index), statusWidth);
                        // return tile(context, list.elementAt(index), statusWidth);

                        // return Container(
                        //   height: 50,
                        //   color: Colors.amber[colorCodes[index]],
                        //   child: Center(child: Text('Entry ${entries[index]}')),
                        // );
                      });
                }),
          ),

          // Expanded(
          //   flex: 1,
          //   child: ListView.builder(
          //       shrinkWrap: false,
          //       padding: const EdgeInsets.all(8),
          //       itemCount: 20,
          //       itemBuilder: (BuildContext context, int index) {
          //         return tileTransaction(context);
          //         // return Container(
          //         //   height: 50,
          //         //   color: Colors.amber[colorCodes[index]],
          //         //   child: Center(child: Text('Entry ${entries[index]}')),
          //         // );
          //       }),
          // ),
        ],
      ),
    );
  }
  */
}

/*
class SortByBottomSheet extends StatelessWidget {
  final ValueNotifier sortByNotifier;
  final List<String> sort_by_option;

  const SortByBottomSheet(this.sortByNotifier, this.sort_by_option, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    double contentHeight = padding + 44.0 + (44.0 * sort_by_option.length) + padding;

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
          valueListenable: sortByNotifier,
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
            int count = sort_by_option.length;
            for (int i = 0; i < count; i++) {
              String ca = sort_by_option.elementAt(i);
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
          sortByNotifier.value = index;
        },
      ),
    );
  }
}
*/
