import 'dart:io';
import 'dart:math';

import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/bottom_sheet/bottom_sheet_alert.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/buttons_attention.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/tab_bar_trade.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_community/screen_community.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_account.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_error.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_unknown_response.dart';
import 'package:Investrend/screens/trade/screen_amend.dart';
import 'package:Investrend/screens/trade/screen_order_detail.dart';
import 'package:Investrend/screens/trade/screen_trade_buy.dart';
import 'package:Investrend/screens/trade/screen_trade_sell.dart';
import 'package:Investrend/screens/trade/trade_component.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:Investrend/utils/utils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenTrade extends StatefulWidget {
  final OrderType _orderType;
  final bool onlyFastOrder;
  final PriceLot initialPriceLot;

  const ScreenTrade(
    this._orderType, {
    this.initialPriceLot,
    Key key,
    this.onlyFastOrder = false,
  }) : super(key: key);

  @override
  _ScreenTradeState createState() =>
      _ScreenTradeState(this._orderType, this.onlyFastOrder,
          initialPriceLot: this.initialPriceLot);
}

class _ScreenTradeState
    extends BaseStateWithTabs<ScreenTrade> //with SingleTickerProviderStateMixin
{
  OrderType _initialOrderType;
  final bool _onlyFastOrder;

  String timeCreation = '-';
  List<String> tabs = [
    'trade_tabs_buy_title'.tr(),
    'trade_tabs_sell_title'.tr(),
  ];

  // final int initialPrice;
  // final int initialLot;
  final PriceLot initialPriceLot;

  _ScreenTradeState(this._initialOrderType, this._onlyFastOrder,
      {this.initialPriceLot})
      : super('/trade');

  // Key buttonKey = UniqueKey();
  //TabController _tabController;
  ValueNotifier<bool> _fastModeNotifier;
  ValueNotifier<OrderType> _orderTypeNotifier;
  OrderbookNotifier _orderbookNotifier = OrderbookNotifier(OrderbookData());
  ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);

  //OrderDataNotifier _orderDataNotifier;

  ValueNotifier<bool> _updateDataNotifier = ValueNotifier<bool>(false);

  ValueNotifier<bool> _bottomSheetNotifier = ValueNotifier(true);
  ValueNotifier<bool> _keyboardNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    //_tabController = new TabController(vsync: this, length: tabs.length);
    print('ScreenTrade.initState set pTabController.index = ' +
        _initialOrderType.index.toString());
    pTabController.index = _initialOrderType.index;

    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    //_fastModeNotifier = ValueNotifier<bool>(false);
    _fastModeNotifier = ValueNotifier<bool>(this._onlyFastOrder);
    _orderTypeNotifier = ValueNotifier<OrderType>(_initialOrderType);
  }

  // VoidCallback onTabChanged = (){
  //
  // };

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    bool keyboardShowed = MediaQuery.of(context).viewInsets.bottom > 0;
    print(
        'ScreenTrade.didChangeDependencies set pTabController.addListener _onlyFastOrder : $_onlyFastOrder keyboardShowed : $keyboardShowed');

    if (_onlyFastOrder) {
      context.read(buySellChangeNotifier).setFastMode(_onlyFastOrder);
    }

    _keyboardNotifier.value = keyboardShowed;
    _bottomSheetNotifier.value = !keyboardShowed;

    // load froms existing
    OrderBook currentOrderbook =
        context.read(orderBookChangeNotifier).orderbook;
    Stock currentStock = context.read(primaryStockChangeNotifier).stock;
    if (currentOrderbook != null &&
        currentStock != null &&
        (currentOrderbook.countBids() > 0 ||
            currentOrderbook.countOffers() > 0) &&
        StringUtils.equalsIgnoreCase(
            currentOrderbook.code, currentStock.code)) {
      OrderbookData orderbookData = OrderbookData();
      orderbookData.orderbook = currentOrderbook;
      StockSummary stockSummary =
          context.read(stockSummaryChangeNotifier).summary;
      orderbookData.close = stockSummary != null ? stockSummary.close : 0;
      //orderbookData.prev = context.read(stockSummaryChangeNotifier).summary?.prev;
      orderbookData.prev = stockSummary != null ? stockSummary.prev : 0;
      orderbookData.averagePrice =
          stockSummary != null ? stockSummary.averagePrice : 0;
      _orderbookNotifier.setValue(orderbookData);
    }
    print('AAAA 1');
    pTabController.addListener(() {
      print('AAAA 1 0');
      _orderTypeNotifier.value =
          OrderType.values.elementAt(pTabController.index);
      if (mounted) {
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    });
    print('AAAA 2');
    _fastModeNotifier.addListener(() {
      print('AAAA 2 0');
      FocusScope.of(context).requestFocus(new FocusNode());
    });
    //_orderDataNotifier = OrderDataNotifier(new OrderData());
    print('AAAA 3');
  }

  @override
  void dispose() {
    _keyboardNotifier.dispose();
    //_tabController.dispose();
    _fastModeNotifier.dispose();
    _orderTypeNotifier.dispose();
    _orderbookNotifier.dispose();
    //_orderDataNotifier.dispose();
    _loadingNotifier.dispose();
    _bottomSheetNotifier.dispose();
    super.dispose();
  }

  @override
  int tabsLength() {
    return tabs.length;
  }

  /*ASLI 2021-10-01
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: createTabs(context),
        body: createBody(context, paddingBottom),
      ),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }
  */
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: createAppBarNew(context),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  void doUpdate() async {
    //Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
    int accountSize = context.read(dataHolderChangeNotifier).user.accountSize();
    if (accountSize > 0) {
      List<String> listAccountCode = List.empty(growable: true);
      // InvestrendTheme.of(context).user.accounts.forEach((account) {
      //   listAccountCode.add(account.accountcode);
      // });
      context.read(dataHolderChangeNotifier).user.accounts.forEach((account) {
        listAccountCode.add(account.accountcode);
      });
      try {
        print(routeName + ' try accountStockPosition');
        final accountStockPosition = await InvestrendTheme.tradingHttp
            .accountStockPosition(
                '',
                listAccountCode,
                context.read(dataHolderChangeNotifier).user.username,
                InvestrendTheme.of(context).applicationPlatform,
                InvestrendTheme.of(context).applicationVersion);
        DebugWriter.information(routeName +
            ' Got accountStockPosition  accountStockPosition.size : ' +
            accountStockPosition.length.toString());
        if (!mounted) {
          print(
              routeName + ' accountStockPosition ignored.  mounted : $mounted');
          return;
        }
        AccountStockPosition first =
            (accountStockPosition != null && accountStockPosition.length > 0)
                ? accountStockPosition.first
                : null;
        if (first != null && first.ignoreThis()) {
          // ignore in aja
          print(routeName +
              ' accountStockPosition ignored.  message : ' +
              first.message);
        } else {
          context.read(accountsInfosNotifier).updateList(accountStockPosition);
        }
      } catch (e) {
        DebugWriter.information(
            routeName + ' accountStockPosition Exception : ' + e.toString());
        if (!mounted) {
          print(
              routeName + ' accountStockPosition Exception mounted : $mounted');
          return;
        }
        if (e is TradingHttpException) {
          if (e.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return;
          } else if (e.isErrorTrading()) {
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            return;
          } else {
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel =
                networkErrorLabel.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context)
                .showSnackBar(context, networkErrorLabel);
            return;
          }
        } else {
          String errorText = Utils.removeServerAddress(e.toString());
          InvestrendTheme.of(context).showSnackBar(context, errorText);
          //InvestrendTheme.of(context).showSnackBar(context, e.toString());
          return;
        }
      }
    }
  }

  void updateAccountCashPosition(BuildContext context) {
    int accountSize = context.read(dataHolderChangeNotifier).user.accountSize();
    if (accountSize > 0) {
      List<String> listAccountCode = List.empty(growable: true);
      // InvestrendTheme.of(context).user.accounts.forEach((account) {
      //   listAccountCode.add(account.accountcode);
      // });
      context.read(dataHolderChangeNotifier).user.accounts.forEach((account) {
        listAccountCode.add(account.accountcode);
      });

      print(routeName + ' try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp
          .accountStockPosition(
              '' /*account.brokercode*/,
              listAccountCode,
              context.read(dataHolderChangeNotifier).user.username,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((value) {
        DebugWriter.information(
            'Got accountStockPosition  accountStockPosition.size : ' +
                value.length.toString());
        AccountStockPosition first =
            (value != null && value.length > 0) ? value.first : null;
        if (first != null && first.ignoreThis()) {
          // ignore in aja
          print(routeName +
              ' accountStockPosition ignored.  message : ' +
              first.message);
        } else {
          context.read(accountsInfosNotifier).updateList(value);
        }

        /* ga tau perlu ga disini
        Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
        if(activeAccount != null){
          AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
          if(accountInfo != null){
            context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, 0/*cashPosition.rdnBalance*/);
          }
        }
        popUntil
         */
      }).onError((error, stackTrace) {
        DebugWriter.information(routeName +
            ' accountStockPosition Exception : ' +
            error.toString());
        if (!mounted) {
          DebugWriter.information(
              routeName + ' accountStockPosition Exception mounted : $mounted');
          return;
        }
        if (error is TradingHttpException) {
          if (error.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return;
          } else if (error.isErrorTrading()) {
            InvestrendTheme.of(context).showSnackBar(context, error.message());
          } else {
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel = networkErrorLabel.replaceFirst(
                "#CODE#", error.code.toString());
            InvestrendTheme.of(context)
                .showSnackBar(context, networkErrorLabel);
            return;
          }
        } else {
          //InvestrendTheme.of(context).showSnackBar(context, error.toString());

          String errorText = Utils.removeServerAddress(error.toString());
          InvestrendTheme.of(context).showSnackBar(context, errorText);
        }
      });
    }
  }

  Widget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    List<Widget> actions = List.empty(growable: true);
    if (!_onlyFastOrder) {
      actions.add(AppBarActionIcon('images/icons/action_search.png', () {
        FocusScope.of(context).requestFocus(new FocusNode());
        final result = InvestrendTheme.showFinderScreen(context);
        result.then((value) {
          if (value == null) {
            print('result finder = null');
          } else if (value is Stock) {
            print('result finder = ' + value.code);
            // InvestrendTheme.of(context).stockNotifier.setStock(value);
            context.read(primaryStockChangeNotifier).setStock(value);
          } else if (value is People) {
            print('result finder = ' + value.name);
          }
        });
      }));
    }

    actions.add(Consumer(builder: (context, watch, child) {
      final notifier = watch(avatarChangeNotifier);
      return AvatarProfileButton(
        url: notifier.url,
        fullname: context.read(dataHolderChangeNotifier).user.realname,
        onPressed: () {
          updateAccountCashPosition(context);
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              context: context,
              builder: (context) {
                return AccountBottomSheet();
              });
        },
      );
    }));

    Widget title;
    if (_onlyFastOrder) {
      title = AppBarTitleText('trade_fast_order_title'.tr());
    } else {
      Size textSize =
          UIHelper.textSize('ABCD', InvestrendTheme.of(context).headline3);

      title = Consumer(builder: (context, watch, child) {
        final notifier = watch(stockSummaryChangeNotifier);
        if (notifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        notation = context
            .read(remark2Notifier)
            .getSpecialNotation(notifier.stock.code);
        status = context
            .read(remark2Notifier)
            .getSpecialNotationStatus(notifier.stock.code);
        suspendStock = context
            .read(suspendedStockNotifier)
            .getSuspended(notifier.stock.code, notifier.stock.defaultBoard);
        if (suspendStock != null) {
          status = StockInformationStatus.Suspended;
        }
        VoidCallback onImportantInformation;
        if (notation.isNotEmpty || suspendStock != null) {
          onImportantInformation = () => onPressedButtonImportantInformation(
              context, notation, suspendStock);
        }

        return Row(
          children: [
            Column(
              children: [
                AppBarTitleText(notifier.stock.code),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  InvestrendTheme.formatPrice(notifier.summary.close),
                  style: InvestrendTheme.of(context)
                      .support_w400_compact
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            ButtonTextAttention(
                'LEXP', textSize.height, onImportantInformation),
          ],
        );
      });
    }

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      title: title,

      /*
      title: Consumer(builder: (context, watch, child) {
        final notifier = watch(primaryStockChangeNotifier);
        if (notifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        return Text(
          notifier.stock.code,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        );
      }),

       */
      /*
      title: ValueListenableBuilder(
        valueListenable: InvestrendTheme.of(context).stockNotifier,
        builder: (context, Stock value, child) {
          if (InvestrendTheme.of(context).stockNotifier.invalid()) {
            return Center(child: CircularProgressIndicator());
          }
          return Text(
            value.code,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          );
        },
      ),
      */
      actions: actions,
      /*
      actions: [
        AppBarActionIcon('images/icons/action_search.png', () {
          FocusScope.of(context).requestFocus(new FocusNode());
          final result = InvestrendTheme.showFinderScreen(context);
          result.then((value) {
            if (value == null) {
              print('result finder = null');
            } else if (value is Stock) {
              print('result finder = ' + value.code);

              // InvestrendTheme.of(context).stockNotifier.setStock(value);

              context.read(primaryStockChangeNotifier).setStock(value);
            } else if (value is People) {
              print('result finder = ' + value.name);
            }
          });
        }),
        AvatarButton(
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return AccountBottomSheet();
                });
          },
        ),
      ],
      */
    );
  }

  void onPressedButtonCorporateAction() {
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

  void onPressedButtonImportantInformation(BuildContext context,
      List<Remark2Mapping> notation, SuspendStock suspendStock) {
    List<Widget> childs = List.empty(growable: true);
    int count = notation == null ? 0 : notation.length;

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
                ),
              ]),
        ),
      ));
    }
    bool titleSpecialNotation = true;
    for (int i = 0; i < count; i++) {
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
      //showAlert(context, childs, childsHeight: (childs.length * 40).toDouble(), title: ' ');
      showAlert(context, childs, childsHeight: height, title: ' ');
    }
  }

  void showAlert(BuildContext context, List<Widget> childs,
      {String title, double childsHeight = 0}) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return BottomSheetAlert(
            childs,
            title: title,
            childsHeight: childsHeight,
          );
        });
  }

  Widget createAppBarNew(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    List<Widget> actions = List.empty(growable: true);

    if (!_onlyFastOrder) {
      actions.add(AppBarActionIcon('images/icons/action_search.png', () {
        FocusScope.of(context).requestFocus(new FocusNode());
        final result = InvestrendTheme.showFinderScreen(context);
        result.then((value) {
          if (value == null) {
            print('result finder = null');
          } else if (value is Stock) {
            print('result finder = ' + value.code);
            context.read(primaryStockChangeNotifier).setStock(value);
          } else if (value is People) {
            print('result finder = ' + value.name);
          }
        });
      }));
    }
    actions.add(
      AppBarConnectionStatus(
        child: Consumer(builder: (context, watch, child) {
          final notifier = watch(avatarChangeNotifier);
          return AvatarProfileButton(
            url: notifier.url,
            fullname: context.read(dataHolderChangeNotifier).user.realname,
            onPressed: () {
              updateAccountCashPosition(context);
              showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0)),
                  ),
                  context: context,
                  builder: (context) {
                    return AccountBottomSheet();
                  });
            },
          );
        }),
      ),
    );

    Widget title;
    if (_onlyFastOrder) {
      title = AppBarTitleText('trade_fast_order_title'.tr());
    } else {
      title = Consumer(builder: (context, watch, child) {
        final notifier = watch(stockSummaryChangeNotifier);
        if (notifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }

        TextStyle styleAttention = InvestrendTheme.of(context).headline3;
        Size textSize = UIHelper.textSize('ABCD', styleAttention);
        attentionCodes = context
            .read(remark2Notifier)
            .getSpecialNotationCodes(notifier.stock.code);
        notation = context
            .read(remark2Notifier)
            .getSpecialNotation(notifier.stock.code);
        status = context
            .read(remark2Notifier)
            .getSpecialNotationStatus(notifier.stock.code);
        suspendStock = context
            .read(suspendedStockNotifier)
            .getSuspended(notifier.stock.code, notifier.stock.defaultBoard);
        if (suspendStock != null) {
          status = StockInformationStatus.Suspended;
        }
        VoidCallback onImportantInformation;
        if (notation.isNotEmpty || suspendStock != null) {
          onImportantInformation = () => onPressedButtonImportantInformation(
              context, notation, suspendStock);
        }

        corporateAction = context
            .read(corporateActionEventNotifier)
            .getEvent(notifier.stock.code);
        corporateActionColor = CorporateActionEvent.getColor(corporateAction);
        VoidCallback onPressedCorporateAction;
        if ((corporateAction != null && corporateAction.isNotEmpty)) {
          onPressedCorporateAction = () => onPressedButtonCorporateAction();
        }

        Widget codePriceWidget = Column(
          children: [
            Hero(
                tag: 'trade_code', child: AppBarTitleText(notifier.stock.code)),
            SizedBox(
              height: 5.0,
            ),
            Text(
              InvestrendTheme.formatPrice(notifier.summary.close),
              style: InvestrendTheme.of(context)
                  .support_w400_compact
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        );

        List<Widget> list = List.empty(growable: true);
        if (onImportantInformation != null &&
            (!StringUtils.isEmtpy(attentionCodes) ||
                status == StockInformationStatus.Suspended)) {
          list.add(ButtonTextAttentionMozaic(attentionCodes,
              textSize.height - 3, status, onImportantInformation));
        }
        if ((corporateAction != null && corporateAction.isNotEmpty)) {
          list.add(ButtonCorporateAction(textSize.height, corporateActionColor,
              onPressedButtonCorporateAction));
        }

        if (list.isNotEmpty) {
          list.insert(0, codePriceWidget);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: list,
          );
        } else {
          return codePriceWidget;
        }
        /*
        if (onImportantInformation != null && (!StringUtils.isEmtpy(attentionCodes) || status == StockInformationStatus.Suspended)) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              codePriceWidget,
              SizedBox(width: InvestrendTheme.cardPadding,),
              //ButtonTextAttention(attentionCodes, textSize.height, onImportantInformation,),
              ButtonTextAttentionMozaic(attentionCodes, textSize.height -3 , status, onImportantInformation)
            ],
          );
        }else{
          return codePriceWidget;
        }
        */
        /*
        if(onImportantInformation == null || StringUtils.isEmtpy(attentionCodes)){
          return codePriceWidget;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            codePriceWidget,
            SizedBox(width: InvestrendTheme.cardPadding,),
            //ButtonTextAttention(attentionCodes, textSize.height, onImportantInformation,),
            ButtonTextAttentionMozaic(attentionCodes, textSize.height -3 , status, onImportantInformation)
          ],
        );
         */
      });
    }
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      title: title,
      actions: actions,
      bottom: createTabsNew(context),
    );
  }

  String attentionCodes;
  List<Remark2Mapping> notation = List.empty(growable: true);
  StockInformationStatus status;
  SuspendStock suspendStock;
  List<CorporateActionEvent> corporateAction = List.empty(growable: true);
  Color corporateActionColor = Colors.black;

  //bool fastMode = false;

  Widget createTabs(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    tabs.forEach((title) {
      list.add(new Tab(text: title));
    });

    List<Widget> rows = List.empty(growable: true);
    rows.add(Expanded(
      child: TabBarTrade(list, pTabController),
      flex: 1,
    ));

    /** HIDE dulu fast order */
    if (InvestrendTheme.FAST_ORDER) {
      if (_onlyFastOrder) {
        rows.add(ButtonDropdownStock());
      } else {
        rows.add(ValueListenableBuilder(
          valueListenable: _fastModeNotifier,
          builder: (context, value, child) {
            return CupertinoSwitch(
                value: value,
                onChanged: (newValue) {
                  print('onChanged : ' + newValue.toString());
                  _fastModeNotifier.value = newValue;
                });
          },
        ));

        rows.add(SizedBox(
          width: 3.0,
        ));

        rows.add(ValueListenableBuilder(
          valueListenable: _orderTypeNotifier,
          builder: (context, OrderType value, child) {
            String text = '';
            if (value == OrderType.Buy) {
              text = 'trade_button_fast_buy'.tr();
            } else if (value == OrderType.Sell) {
              text = 'trade_button_fast_sell'.tr();
            }
            return Text(
              text,
              style: InvestrendTheme.of(context).small_w400.copyWith(
                  color: Theme.of(context).tabBarTheme.unselectedLabelColor,
                  height: 1.0),
            );
          },
        ));
      }
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(InvestrendTheme.appBarTabHeight),
      child: Container(
        //color: Colors.blue,
        margin:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 0.0),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: rows,
        ),
      ),
    );
  }

  Widget createTabsNew(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    tabs.forEach((title) {
      list.add(new Tab(text: title));
    });

    List<Widget> rows = List.empty(growable: true);
    rows.add(Expanded(
      child: SizedBox(height: 36.0, child: TabBarTrade(list, pTabController)),
      flex: 1,
    ));

    /** HIDE dulu fast order */
    if (InvestrendTheme.FAST_ORDER) {
      if (_onlyFastOrder) {
        rows.add(ButtonDropdownStock());
      } else {
        rows.add(ValueListenableBuilder(
          valueListenable: _fastModeNotifier,
          builder: (context, value, child) {
            return CupertinoSwitch(
                value: value,
                onChanged: (newValue) {
                  print('onChanged : ' + newValue.toString());
                  _fastModeNotifier.value = newValue;
                });
          },
        ));

        rows.add(SizedBox(
          width: 3.0,
        ));

        rows.add(ValueListenableBuilder(
          valueListenable: _orderTypeNotifier,
          builder: (context, OrderType value, child) {
            String text = '';
            if (value == OrderType.Buy) {
              text = 'trade_button_fast_buy'.tr();
            } else if (value == OrderType.Sell) {
              text = 'trade_button_fast_sell'.tr();
            }
            return Text(
              text,
              style: InvestrendTheme.of(context).small_w400.copyWith(
                  color: Theme.of(context).tabBarTheme.unselectedLabelColor,
                  height: 1.0),
            );
          },
        ));
      }
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(InvestrendTheme.appBarTabHeight),
      child: Container(
        //color: Colors.blue,
        margin:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 0.0),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: rows,
        ),
      ),
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    return TabBarView(
      controller: pTabController,
      children: List<Widget>.generate(
        tabs.length,
        (int index) {
          print('createBody tab : ' + tabs[index].toString());

          if (index == OrderType.Buy.index) {
            return ComponentCreator.keyboardHider(
              context,
              ScreenTradeBuy(
                _fastModeNotifier,
                pTabController,
                _orderbookNotifier,
                _updateDataNotifier,
                _onlyFastOrder,
                initialPriceLot: initialPriceLot,
                keyboardNotifier: _keyboardNotifier,
              ),
            );
          }
          if (index == OrderType.Sell.index) {
            return ComponentCreator.keyboardHider(
                context,
                ScreenTradeSell(
                  _fastModeNotifier,
                  pTabController,
                  _orderbookNotifier,
                  _updateDataNotifier,
                  _onlyFastOrder,
                  initialPriceLot: initialPriceLot,
                  keyboardNotifier: _keyboardNotifier,
                ));
          }
          return Container(
            child: Center(
              child: Text(tabs[index]),
            ),
          );
        },
      ),
    );
  }

  bool isBuy() {
    return _orderTypeNotifier.value == OrderType.Buy;
  }

  bool isFastMode() {
    return _fastModeNotifier.value;
  }

  //bool small = true;

  bool canTap = true;

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    String tag;
    if (_orderTypeNotifier.value == OrderType.Buy) {
      tag = 'button_buy';
    } else if (_orderTypeNotifier.value == OrderType.Sell) {
      tag = 'button_sell';
    } else {
      tag = '???';
    }

    // Widget buttonOrder = Hero(tag: tag, child: ButtonOrder(_orderType, () {
    //   setState(() {
    //     small = !small;
    //     print('small $small');
    //   });
    // }));

    // Widget buttonOrder;
    // buttonOrder = Hero(
    //     tag: tag,
    //     child: ButtonOrder(_orderType, () {
    //       FocusScope.of(context).requestFocus(new FocusNode());
    //       setState(() {
    //         small = !small;
    //         print('small $small');
    //
    //         showModalBottomSheet(
    //             context: context,
    //             builder: (context) {
    //               return ConfirmationBottomSheet();
    //             });
    //       });
    //     }));

    //MediaQuery.of(context).size.height
    if (paddingBottom > 0 && MediaQuery.of(context).viewInsets.bottom > 0) {
      paddingBottom = 8.0;
    }

    // trade of kalo keyboard nongol bakal nutupin textfield, kalo ga mau gitu, musti kehilangan bottom sheet
    // if(MediaQuery.of(context).viewInsets.bottom > 0){
    //   return null;
    // }

    return ValueListenableBuilder(
      valueListenable: _bottomSheetNotifier,
      builder: (context, value, child) {
        if (!value) {
          if (Platform.isIOS) {
            return Container(
              width: double.maxFinite,
              height: 40.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.only(
                          left: InvestrendTheme.cardPaddingGeneral,
                          right: InvestrendTheme.cardPaddingGeneral),
                      visualDensity: VisualDensity.comfortable),
                  child: Text(
                    'button_done'.tr(),
                    style: InvestrendTheme.of(context)
                        .small_w500_compact
                        .copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () {
                    _bottomSheetNotifier.value = true;
                    hideKeyboard(context: context);
                  },
                ),
              ),
            );
          } else {
            return SizedBox(
              width: 1.0,
            );
          }
        } else {
          return Padding(
            //color: Colors.cyan,
            padding: EdgeInsets.only(
                top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    //color: Colors.yellow,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _orderTypeNotifier,
                            builder: (context, OrderType value, child) {
                              String text = '';
                              if (value == OrderType.Buy) {
                                text = 'trade_total_buy_label'.tr();
                              } else if (value == OrderType.Sell) {
                                text = 'trade_total_sell_label'.tr();
                              }
                              return Text(
                                text,
                                style: InvestrendTheme.of(context)
                                    .small_w400_compact,
                              );
                            },
                          ),

                          SizedBox(
                            height: InvestrendTheme.cardPadding,
                          ),
                          Consumer(builder: (context, watch, child) {
                            final notifier = watch(buySellChangeNotifier);
                            // if (notifier.stock.invalid()) {
                            //   return Center(child: CircularProgressIndicator());
                            // }
                            BuySell data =
                                notifier.getData(_orderTypeNotifier.value);

                            int value;
                            if (_fastModeNotifier.value) {
                              value = data.fastTotalValue;

                              // if(data.orderType.isBuyOrAmendBuy()){
                              //   double feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
                              //   Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
                              //   if(activeAccount != null){
                              //     feeBuy = activeAccount.commission;
                              //   }
                              //   if(feeBuy > 0){
                              //     value = (value * (1.0 + (feeBuy / 100))).toInt();
                              //   }
                              // }

                            } else {
                              value = data.normalTotalValue;
                            }

                            return Text(
                              InvestrendTheme.formatMoney(value,
                                  prefixRp: true),
                              style: InvestrendTheme.of(context)
                                  .medium_w600_compact,
                            );
                          }),
                          /*
                    ValueListenableBuilder(
                      valueListenable: _orderDataNotifier,
                      builder: (context, value, child) {
                        // if (_o) {
                        //   return Center(child: CircularProgressIndicator());
                        // }
                        return Text(
                          InvestrendTheme.formatMoney(value.value, prefixRp: true),
                          style: InvestrendTheme.of(context).medium_w700,
                        );
                      },
                    ),
                    */
                          //Text(DateTime.now().toString()),
                        ],
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                //   child: buttonOrder,
                // ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: ValueListenableBuilder(
                    valueListenable: _orderTypeNotifier,
                    builder: (context, OrderType value, child) {
                      String tag;
                      if (value == OrderType.Buy) {
                        tag = 'button_buy';
                      } else if (value == OrderType.Sell) {
                        tag = 'button_sell';
                      } else {
                        tag = '???';
                      }
                      print('tag : $tag  ' + DateTime.now().toString());

                      return Hero(
                        tag: tag,
                        child: Consumer(
                          builder: (context, watch, child) {
                            final notifier = watch(buySellChangeNotifier);

                            bool enableButton = true;
                            int selected =
                                context.read(accountChangeNotifier).index;
                            Account account = context
                                .read(dataHolderChangeNotifier)
                                .user
                                .getAccount(selected);
                            if (account == null) {
                              //InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
                              enableButton = false;
                            }
                            BuySell dataNotifier = context
                                .read(buySellChangeNotifier)
                                .getData(_orderTypeNotifier.value);
                            print('==== dataNotifier =====');
                            print(dataNotifier.toString());
                            BuySell data = dataNotifier.clone();
                            print('==== dataCloned =====');
                            print(data.toString());
                            String reffID = Utils.createRefferenceID();
                            // override yah, karena di irwan kejadian, bukan fast mode tapi data nya fastmode.
                            data.fastMode = isFastMode();

                            if (data.fastMode) {
                              if (data.fastTotalValue == 0) {
                                //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                                enableButton = false;
                              }
                            } else {
                              if (data.normalTotalValue == 0) {
                                //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr()+ ' [NormalMode][isFastMode=$isFastMode()]');
                                // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                                enableButton = false;
                              }
                            }

                            if (data.transactionType !=
                                    TransactionType.Normal &&
                                data.transactionCounter < 2) {
                              String error =
                                  'trade_validation_error_split_loop'.tr();
                              //String type = data.transactionType == TransactionType.Loop ? 'Loop' : 'Split';

                              error = error.replaceFirst(
                                  '#TYPE#', data.transactionTypeText());
                              // InvestrendTheme.of(context).showSnackBar(context, error);
                              enableButton = false;
                            }

                            return ButtonOrder(
                              value,
                              !enableButton
                                  ? null
                                  : () {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      if (!canTap) {
                                        InvestrendTheme.of(context).showSnackBar(
                                            context,
                                            'Trade canTap : $canTap waiting for Future.delayed 500ms');
                                        return;
                                      }
                                      canTap = false;
                                      _updateDataNotifier.value =
                                          !_updateDataNotifier.value;
                                      Future.delayed(
                                        Duration(milliseconds: 500),
                                        () {
                                          int selected = context
                                              .read(accountChangeNotifier)
                                              .index;
                                          //Account account = InvestrendTheme.of(context).user.getAccount(selected);
                                          Account account = context
                                              .read(dataHolderChangeNotifier)
                                              .user
                                              .getAccount(selected);
                                          if (account == null) {
                                            //InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');

                                            InvestrendTheme.of(context)
                                                .showSnackBar(
                                                    context,
                                                    'error_no_account_selected'
                                                        .tr());
                                            canTap = true;
                                            return;
                                          }
                                          BuySell dataNotifier = context
                                              .read(buySellChangeNotifier)
                                              .getData(
                                                  _orderTypeNotifier.value);
                                          print('==== dataNotifier =====');
                                          print(dataNotifier.toString());
                                          BuySell data = dataNotifier.clone();
                                          print('==== dataCloned =====');
                                          print(data.toString());
                                          String reffID =
                                              Utils.createRefferenceID();
                                          //DateFormat formatter = DateFormat('HHmmss');

                                          // override yah, karena di irwan kejadian, bukan fast mode tapi data nya fastmode.
                                          data.fastMode = isFastMode();

                                          if (data.fastMode) {
                                            if (data.fastTotalValue == 0) {
                                              InvestrendTheme.of(context)
                                                  .showSnackBar(
                                                      context,
                                                      'trade_validation_error_price_qty'
                                                          .tr());

                                              // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                                              //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                                              //   InvestrendTheme.of(context).showInfoDialog(context,
                                              //       title: 'Debug', content: '[FastMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                                              // });

                                              canTap = true;
                                              return;
                                            }
                                          } else {
                                            if (data.normalTotalValue == 0) {
                                              //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr()+ ' [NormalMode][isFastMode=$isFastMode()]');
                                              InvestrendTheme.of(context)
                                                  .showSnackBar(
                                                      context,
                                                      'trade_validation_error_price_qty'
                                                          .tr());

                                              // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                                              //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                                              //   InvestrendTheme.of(context).showInfoDialog(context,
                                              //       title: 'Debug', content: '[NormalMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                                              // });
                                              canTap = true;
                                              return;
                                            }
                                          }

                                          if (data.transactionType !=
                                                  TransactionType.Normal &&
                                              data.transactionCounter < 2) {
                                            String error =
                                                'trade_validation_error_split_loop'
                                                    .tr();
                                            //String type = data.transactionType == TransactionType.Loop ? 'Loop' : 'Split';

                                            error = error.replaceFirst('#TYPE#',
                                                data.transactionTypeText());
                                            InvestrendTheme.of(context)
                                                .showSnackBar(context, error);
                                            canTap = true;
                                            return;
                                          }
                                          _loadingNotifier.value = false;
                                          canTap = true;
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(24.0),
                                                    topRight:
                                                        Radius.circular(24.0)),
                                              ),
                                              //backgroundColor: Colors.transparent,
                                              context: context,
                                              builder: (context) {
                                                return ConfirmationBottomSheet(
                                                    _orderTypeNotifier.value,
                                                    account,
                                                    data,
                                                    reffID,
                                                    _loadingNotifier);
                                              });
                                        },
                                      );

                                      // setState(() {
                                      //
                                      // });
                                    },
                            );
                          },
                        ),
                        /*
                  child: ButtonOrder(
                    value,
                    () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if (!canTap) {
                        InvestrendTheme.of(context).showSnackBar(context, 'Trade canTap : $canTap waiting for Future.delayed 500ms');
                        return;
                      }
                      canTap = false;
                      _updateDataNotifier.value = !_updateDataNotifier.value;
                      Future.delayed(
                        Duration(milliseconds: 500),
                        () {
                          int selected = context.read(accountChangeNotifier).index;
                          //Account account = InvestrendTheme.of(context).user.getAccount(selected);
                          Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
                          if (account == null) {
                            InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
                            canTap = true;
                            return;
                          }
                          BuySell dataNotifier = context.read(buySellChangeNotifier).getData(_orderTypeNotifier.value);
                          print('==== dataNotifier =====');
                          print(dataNotifier.toString());
                          BuySell data = dataNotifier.clone();
                          print('==== dataCloned =====');
                          print(data.toString());
                          String reffID = Utils.createRefferenceID();
                          //DateFormat formatter = DateFormat('HHmmss');

                          // override yah, karena di irwan kejadian, bukan fast mode tapi data nya fastmode.
                          data.fastMode = isFastMode();

                          if (data.fastMode) {
                            if (data.fastTotalValue == 0) {
                              InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                              // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                              //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                              //   InvestrendTheme.of(context).showInfoDialog(context,
                              //       title: 'Debug', content: '[FastMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                              // });

                              canTap = true;
                              return;
                            }
                          } else {
                            if (data.normalTotalValue == 0) {
                              //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr()+ ' [NormalMode][isFastMode=$isFastMode()]');
                              InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                              // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                              //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                              //   InvestrendTheme.of(context).showInfoDialog(context,
                              //       title: 'Debug', content: '[NormalMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                              // });
                              canTap = true;
                              return;
                            }
                          }

                          if (data.transactionType != TransactionType.Normal && data.transactionCounter < 2) {
                            String error = 'trade_validation_error_split_loop'.tr();
                            //String type = data.transactionType == TransactionType.Loop ? 'Loop' : 'Split';

                            error = error.replaceFirst('#TYPE#', data.transactionTypeText());
                            InvestrendTheme.of(context).showSnackBar(context, error);
                            canTap = true;
                            return;
                          }
                          _loadingNotifier.value = false;
                          canTap = true;
                          showModalBottomSheet(
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                              ),
                              //backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return ConfirmationBottomSheet(_orderTypeNotifier.value, account, data, reffID, _loadingNotifier);
                              });
                        },
                      );

                      // setState(() {
                      //
                      // });
                    },
                  ),
                  */
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );

    /*
    return Padding(
      //color: Colors.cyan,
      padding: EdgeInsets.only(top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              //color: Colors.yellow,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _orderTypeNotifier,
                      builder: (context, OrderType value, child) {
                        String text = '';
                        if (value == OrderType.Buy) {
                          text = 'trade_total_buy_label'.tr();
                        } else if (value == OrderType.Sell) {
                          text = 'trade_total_sell_label'.tr();
                        }
                        return Text(
                          text,
                          style: InvestrendTheme.of(context).small_w400_compact,
                        );
                      },
                    ),

                    SizedBox(height: InvestrendTheme.cardPadding,),
                    Consumer(builder: (context, watch, child) {
                      final notifier = watch(buySellChangeNotifier);
                      // if (notifier.stock.invalid()) {
                      //   return Center(child: CircularProgressIndicator());
                      // }
                      BuySell data = notifier.getData(_orderTypeNotifier.value);

                      int value;
                      if (_fastModeNotifier.value) {
                        value = data.fastTotalValue;

                        // if(data.orderType.isBuyOrAmendBuy()){
                        //   double feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
                        //   Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
                        //   if(activeAccount != null){
                        //     feeBuy = activeAccount.commission;
                        //   }
                        //   if(feeBuy > 0){
                        //     value = (value * (1.0 + (feeBuy / 100))).toInt();
                        //   }
                        // }

                      } else {
                        value = data.normalTotalValue;
                      }

                      return Text(
                        InvestrendTheme.formatMoney(value, prefixRp: true),
                        style: InvestrendTheme.of(context).medium_w600_compact,
                      );
                    }),
                    /*
                    ValueListenableBuilder(
                      valueListenable: _orderDataNotifier,
                      builder: (context, value, child) {
                        // if (_o) {
                        //   return Center(child: CircularProgressIndicator());
                        // }
                        return Text(
                          InvestrendTheme.formatMoney(value.value, prefixRp: true),
                          style: InvestrendTheme.of(context).medium_w700,
                        );
                      },
                    ),
                    */
                    //Text(DateTime.now().toString()),
                  ],
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 18.0, right: 18.0),
          //   child: buttonOrder,
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0),
            child: ValueListenableBuilder(
              valueListenable: _orderTypeNotifier,
              builder: (context, OrderType value, child) {
                String tag;
                if (value == OrderType.Buy) {
                  tag = 'button_buy';
                } else if (value == OrderType.Sell) {
                  tag = 'button_sell';
                } else {
                  tag = '???';
                }
                print('tag : $tag  ' + DateTime.now().toString());

                return Hero(
                  tag: tag,
                  child: Consumer(
                    builder: (context, watch, child) {
                      final notifier = watch(buySellChangeNotifier);

                      bool enableButton = true;
                      int selected = context.read(accountChangeNotifier).index;
                      Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
                      if (account == null) {
                        //InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
                        enableButton = false;
                      }
                      BuySell dataNotifier = context.read(buySellChangeNotifier).getData(_orderTypeNotifier.value);
                      print('==== dataNotifier =====');
                      print(dataNotifier.toString());
                      BuySell data = dataNotifier.clone();
                      print('==== dataCloned =====');
                      print(data.toString());
                      String reffID = Utils.createRefferenceID();
                      // override yah, karena di irwan kejadian, bukan fast mode tapi data nya fastmode.
                      data.fastMode = isFastMode();

                      if (data.fastMode) {
                        if (data.fastTotalValue == 0) {
                          //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                          enableButton = false;
                        }
                      } else {
                        if (data.normalTotalValue == 0) {
                          //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr()+ ' [NormalMode][isFastMode=$isFastMode()]');
                          // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                          enableButton = false;
                        }
                      }

                      if (data.transactionType != TransactionType.Normal && data.transactionCounter < 2) {
                        String error = 'trade_validation_error_split_loop'.tr();
                        //String type = data.transactionType == TransactionType.Loop ? 'Loop' : 'Split';

                        error = error.replaceFirst('#TYPE#', data.transactionTypeText());
                        // InvestrendTheme.of(context).showSnackBar(context, error);
                        enableButton = false;
                      }

                      return ButtonOrder(
                        value,
                        !enableButton ? null :  () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          if (!canTap) {
                            InvestrendTheme.of(context).showSnackBar(context, 'Trade canTap : $canTap waiting for Future.delayed 500ms');
                            return;
                          }
                          canTap = false;
                          _updateDataNotifier.value = !_updateDataNotifier.value;
                          Future.delayed(
                            Duration(milliseconds: 500),
                            () {
                              int selected = context.read(accountChangeNotifier).index;
                              //Account account = InvestrendTheme.of(context).user.getAccount(selected);
                              Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
                              if (account == null) {
                                InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
                                canTap = true;
                                return;
                              }
                              BuySell dataNotifier = context.read(buySellChangeNotifier).getData(_orderTypeNotifier.value);
                              print('==== dataNotifier =====');
                              print(dataNotifier.toString());
                              BuySell data = dataNotifier.clone();
                              print('==== dataCloned =====');
                              print(data.toString());
                              String reffID = Utils.createRefferenceID();
                              //DateFormat formatter = DateFormat('HHmmss');

                              // override yah, karena di irwan kejadian, bukan fast mode tapi data nya fastmode.
                              data.fastMode = isFastMode();

                              if (data.fastMode) {
                                if (data.fastTotalValue == 0) {
                                  InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                                  // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                                  //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                                  //   InvestrendTheme.of(context).showInfoDialog(context,
                                  //       title: 'Debug', content: '[FastMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                                  // });

                                  canTap = true;
                                  return;
                                }
                              } else {
                                if (data.normalTotalValue == 0) {
                                  //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr()+ ' [NormalMode][isFastMode=$isFastMode()]');
                                  InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                                  // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                                  //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                                  //   InvestrendTheme.of(context).showInfoDialog(context,
                                  //       title: 'Debug', content: '[NormalMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                                  // });
                                  canTap = true;
                                  return;
                                }
                              }

                              if (data.transactionType != TransactionType.Normal && data.transactionCounter < 2) {
                                String error = 'trade_validation_error_split_loop'.tr();
                                //String type = data.transactionType == TransactionType.Loop ? 'Loop' : 'Split';

                                error = error.replaceFirst('#TYPE#', data.transactionTypeText());
                                InvestrendTheme.of(context).showSnackBar(context, error);
                                canTap = true;
                                return;
                              }
                              _loadingNotifier.value = false;
                              canTap = true;
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                                  ),
                                  //backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return ConfirmationBottomSheet(_orderTypeNotifier.value, account, data, reffID, _loadingNotifier);
                                  });
                            },
                          );

                          // setState(() {
                          //
                          // });
                        },
                      );
                    },
                  ),
                  /*
                  child: ButtonOrder(
                    value,
                    () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if (!canTap) {
                        InvestrendTheme.of(context).showSnackBar(context, 'Trade canTap : $canTap waiting for Future.delayed 500ms');
                        return;
                      }
                      canTap = false;
                      _updateDataNotifier.value = !_updateDataNotifier.value;
                      Future.delayed(
                        Duration(milliseconds: 500),
                        () {
                          int selected = context.read(accountChangeNotifier).index;
                          //Account account = InvestrendTheme.of(context).user.getAccount(selected);
                          Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
                          if (account == null) {
                            InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
                            canTap = true;
                            return;
                          }
                          BuySell dataNotifier = context.read(buySellChangeNotifier).getData(_orderTypeNotifier.value);
                          print('==== dataNotifier =====');
                          print(dataNotifier.toString());
                          BuySell data = dataNotifier.clone();
                          print('==== dataCloned =====');
                          print(data.toString());
                          String reffID = Utils.createRefferenceID();
                          //DateFormat formatter = DateFormat('HHmmss');

                          // override yah, karena di irwan kejadian, bukan fast mode tapi data nya fastmode.
                          data.fastMode = isFastMode();

                          if (data.fastMode) {
                            if (data.fastTotalValue == 0) {
                              InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                              // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                              //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                              //   InvestrendTheme.of(context).showInfoDialog(context,
                              //       title: 'Debug', content: '[FastMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                              // });

                              canTap = true;
                              return;
                            }
                          } else {
                            if (data.normalTotalValue == 0) {
                              //InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr()+ ' [NormalMode][isFastMode=$isFastMode()]');
                              InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr());

                              // InvestrendTheme.of(context).showSnackBar(context, 'trade_validation_error_price_qty'.tr(),
                              //     buttonLabel: 'Debug', buttonColor: Colors.red, buttonOnPress: () {
                              //   InvestrendTheme.of(context).showInfoDialog(context,
                              //       title: 'Debug', content: '[NormalMode][isFastMode=' + isFastMode().toString() + ']\n' + data.toString());
                              // });
                              canTap = true;
                              return;
                            }
                          }

                          if (data.transactionType != TransactionType.Normal && data.transactionCounter < 2) {
                            String error = 'trade_validation_error_split_loop'.tr();
                            //String type = data.transactionType == TransactionType.Loop ? 'Loop' : 'Split';

                            error = error.replaceFirst('#TYPE#', data.transactionTypeText());
                            InvestrendTheme.of(context).showSnackBar(context, error);
                            canTap = true;
                            return;
                          }
                          _loadingNotifier.value = false;
                          canTap = true;
                          showModalBottomSheet(
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                              ),
                              //backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return ConfirmationBottomSheet(_orderTypeNotifier.value, account, data, reffID, _loadingNotifier);
                              });
                        },
                      );

                      // setState(() {
                      //
                      // });
                    },
                  ),
                  */
                );
              },
            ),
          ),
        ],
      ),
    );
    */
  }

  @override
  void onActive() {
    // TODO: implement onActive
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Theme.of(context).backgroundColor,
//     appBar: createAppBar(context),
//     body: DefaultTabController(
//       length: tabs.length,
//       child: Scaffold(
//         backgroundColor: Theme.of(context).backgroundColor,
//         appBar: createTabs(context),
//         body: createBody(context),
//       ),
//     ),
//   );
//   /*
//   return DefaultTabController(
//     length: tabs.length,
//     child: Scaffold(
//       backgroundColor: Theme.of(context).backgroundColor,
//       appBar: createAppBar(context),
//       body: createBody(context),
//     ),
//   );
//
//    */
// }

}

class OrderFinishedFullscreenBottomSheet extends BaseTradeBottomSheet {
  final BuySell data;

  OrderFinishedFullscreenBottomSheet(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0.0,
            leading: IconButton(
                icon: Image.asset('images/icons/action_clear.png',
                    color: InvestrendTheme.greenText,
                    width: 12.0,
                    height: 12.0),

                //visualDensity: VisualDensity.compact,
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 36.0,
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Center(
                    child: Image.asset(
                      'images/order_succes_fast_mode.png',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 64.0,
              ),
              Text(
                'trade_finished_info_success_label'.tr(),
                style: InvestrendTheme.of(context)
                    .regular_w600_compact
                    .copyWith(color: InvestrendTheme.greenText),
              ),
              SizedBox(
                height: 8.0,
              ),
              Spacer(
                flex: 3,
              ),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: ComponentCreator.roundedButton(
                    context,
                    'trade_finished_button_order_again'.tr(),
                    InvestrendTheme.greenText,
                    InvestrendTheme.of(context).whiteColor,
                    InvestrendTheme.greenText, () {
                  print('order Lagi clicked');
                  Navigator.pop(context, 'KEEP'); // clear data
                }),
              ),
              TextButton(
                  child: Text(
                    'trade_finished_button_show_order'.tr(),
                    style: InvestrendTheme.of(context)
                        .small_w400_compact
                        .copyWith(
                            color: InvestrendTheme.of(context)
                                .greyDarkerTextColor),
                  ),
                  onPressed: () {
                    print('lihat order clicked fullscreen');

                    // lansung, show transaction Intraday
                    Navigator.pop(
                        context, 'SHOW_TRANSACTION_INTRADAY'); // clear data
                  }),
              /* Hide sosmed dulu untuk test launching
              TextButton(
                  child: Text(
                    'trade_finished_button_post_order'.tr(),
                    style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    print('lihat order clicked fullscreen');
                    Navigator.push(context, CupertinoPageRoute(
                      builder: (_) => ScreenCreatePost('/trade',orderData: data,), settings: RouteSettings(name: '/create_post'),)).then((value) {
                      if( value is String &&
                        StringUtils.equalsIgnoreCase(value, 'SHOW_COMMUNITY_FEED')
                      ){
                        Navigator.pop(context, value);
                      }
                    });
                  }),
              */
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderFinishedBottomSheet extends BaseTradeBottomSheet {
  final BuySell data;

  OrderFinishedBottomSheet(this.data);

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
    contentHeight += 30.0 + 24.0 + 30;
    // contentHeight += 200.0;
    // contentHeight += heightRowReguler;
    // contentHeight += 3.0;
    // contentHeight += 55.0 + 55.0 + 24.0 + 24.0 + 5.0;

    List<Widget> list = List.empty(growable: true);
    //list.add(TradeComponentCreator.popupTitle(context, 'trade_finished_title'.tr()));

    list.add(Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TradeComponentCreator.popupTitle(
              context, 'trade_finished_title'.tr()),
          // child: Text(
          //   confirmationTitle,
          //   style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
          // ),
          flex: 1,
        ),
        IconButton(
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
      ],
    ));

    list.add(Spacer(
      flex: 1,
    ));

    contentHeight += heightRowReguler;
    list.add(SizedBox(
      height: 27.0,
    ));
    contentHeight += 27.0;
    list.add(Center(
        child: Image.asset(
      'images/order_success_normal_mode.png',
      width: 50.0,
      height: 50.0,
    )));
    contentHeight += 50.0;
    list.add(SizedBox(
      height: 14.0,
    ));
    contentHeight += 14.0;
    list.add(
      Center(
          child: Text(
        (data.isBuy()
            ? 'trade_finished_order_buy_sent_label'.tr()
            : 'trade_finished_order_sell_sent_label'.tr()),
        style: InvestrendTheme.of(context)
            .regular_w400_compact
            .copyWith(color: Color(0xFF25B792)),
      )),
    );
    contentHeight += heightRowReguler;
    list.add(SizedBox(
      height: 24.0,
    ));
    list.add(Spacer(
      flex: 1,
    ));
    contentHeight += 24.0;
    list.add(Divider(
      thickness: 1.0,
    ));
    contentHeight += 3.0;
    list.add(SizedBox(
      height: 16.0,
    ));
    contentHeight += 16.0;
    list.add(Container(
      width: double.maxFinite,
      child: ComponentCreator.roundedButton(
          context,
          'trade_finished_button_show_order'.tr(),
          Theme.of(context).colorScheme.secondary,
          InvestrendTheme.of(context).whiteColor,
          Theme.of(context).colorScheme.secondary, () {
        print('lihat order clicked');
        Navigator.pop(context, data.clone()); // clear data
      }),
    ));
    contentHeight += 55.0;
    list.add(SizedBox(
      height: 16.0,
    ));
    contentHeight += 16.0;
    list.add(Container(
      width: double.maxFinite,
      child: TextButton(
          child: Text(
            (data.isBuy()
                ? 'trade_finished_button_buy_again'.tr()
                : 'trade_finished_button_sell_again'.tr()),
            style: InvestrendTheme.of(context)
                .small_w600_compact
                .copyWith(color: Theme.of(context).buttonColor),
          ),
          onPressed: () {
            print('beli lagi clicked');
            Navigator.pop(context, 'KEEP'); // keep data
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

class ConfirmationBottomSheet extends BaseTradeBottomSheet {
  final OrderType orderType;
  final Account account;
  final BuySell data;
  final String reff;
  final ValueNotifier<bool> loadingNotifier;

  const ConfirmationBottomSheet(
    this.orderType,
    this.account,
    this.data,
    this.reff,
    this.loadingNotifier, {
    Key key,
  }) : super(key: key);

  void showNextPage(BuildContext context, Widget pageNext, String routeNext) {
    InvestrendTheme.push(context, pageNext, ScreenTransition.SlideUp, routeNext)
        .then((value) {
      if (value == null) {
        print('Order Finished value : NULL  clearData : true');
        context.read(clearOrderChangeNotifier).mustNotifyListener();
        Navigator.pop(context);
      } else if (value is BuySell) {
        print('Order Finished value : BuySell  clearData : true');
        context.read(clearOrderChangeNotifier).mustNotifyListener();
        print('Order Finished value : BuySell  pop');
        Navigator.pop(context);
        print('Order Finished value : BuySell  push order detail');
        InvestrendTheme.push(context, ScreenOrderDetail(value, null),
            ScreenTransition.SlideDown, '/order_detail');

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //
        // });

      } else {
        if (value is String) {
          if (StringUtils.equalsIgnoreCase(value, 'KEEP')) {
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            Navigator.pop(context);
          } else if (StringUtils.equalsIgnoreCase(
              value, 'SHOW_TRANSACTION_INTRADAY')) {
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            Navigator.popUntil(context, (route) {
              print('popUntil : ' + route.toString());
              if (StringUtils.equalsIgnoreCase(
                  route?.settings?.name, '/main')) {
                return true;
              }
              return route.isFirst;
            });
            context
                .read(mainMenuChangeNotifier)
                .setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
          } else if (StringUtils.equalsIgnoreCase(
              value, 'SHOW_COMMUNITY_FEED')) {
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            Navigator.popUntil(context, (route) {
              print('popUntil : ' + route.toString());
              if (StringUtils.equalsIgnoreCase(
                  route?.settings?.name, '/main')) {
                return true;
              }
              return route.isFirst;
            });
            context
                .read(mainMenuChangeNotifier)
                .setActive(Tabs.Community, TabsCommunity.Feed.index);
          } else {
            print('Order Finished value : $value  clearData : true');
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            Navigator.pop(context);
          }
          // if (!StringUtils.equalsIgnoreCase(value, 'KEEP')) {
          //   print('Order Finished value : $value  clearData : true');
          //   context.read(clearOrderChangeNotifier).mustNotifyListener();
          // }

        } else {
          print('Order Finished value : [NOT a String]  clearData : true');
          context.read(clearOrderChangeNotifier).mustNotifyListener();
          Navigator.pop(context);
        }
      }
    });
  }

  void buttonConfirmClicked(
      BuildContext context, BuySell data, String prices, String qtys) {
    //InvestrendTheme.of(context).showSnackBar(context, 'Confirm clicked');
    print('order confirm clicked AAA');
    bool fastMode = data.fastMode;
    //Navigator.pop(context);
    data.setAccount(account.accountname, account.type, account.accountcode,
        account.brokercode);

    int type = 0;
    if (fastMode) {
      type = 3;
    } else if (data.transactionType != null) {
      type = data.transactionType.index;
    }

    String loadingText = 'loading_submiting_order_label'.tr();
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return LoadingBottomSheet(loadingNotifier);
        });

    Future<OrderReply> result = InvestrendTheme.tradingHttp.orderNew(
      reff,
      account.brokercode,
      account.accountcode,
      context.read(dataHolderChangeNotifier).user.username,
      data.orderType.shortSymbol,
      data.stock_code,
      Stock.defaultBoardByCode(data.stock_code),
      prices,
      qtys,
      InvestrendTheme.of(context).applicationPlatform,
      InvestrendTheme.of(context).applicationVersion,
      type: type,
      counter: data.transactionCounter,
    );
    result.then((reply) {
      print('Got order_new --> ' + reply.toString());
      //{"message":"RF|OK|NEW|E108|A21"}

      loadingNotifier.value = true;

      // harus diganti ke reply.order_date
      //String order_date = Utils.formatDate(DateTime.now().toLocal());
      data.setOrderInformation(reply.orderid, reply.orderdate);

      Widget pageNext;
      String routeNext;

      if (StringUtils.equalsIgnoreCase(reply.result, 'OK')) {
        pageNext = OrderFinishedFullscreenBottomSheet(data);
        //pageNext = OrderFinishedBottomSheet(data);
        routeNext = '/order_finished_bottom_sheet';
      } else if (StringUtils.equalsIgnoreCase(reply.result, 'BAD')) {
        pageNext = ErrorBottomSheet(
          data,
          message: reply.message,
        );
        routeNext = '/order_error_bottom_sheet';
      } else {
        pageNext = UnknownResponseSheet(data, reply.toString());
        routeNext = '/order_unknown_response_bottom_sheet';
      }

      showNextPage(context, pageNext, routeNext);
    }).onError((error, stackTrace) {
      print(error);
      loadingNotifier.value = true;

      //InvestrendTheme.of(context).showSnackBar(context, 'error : ' + error.toString());

      Widget pageNext = ErrorBottomSheet(
        data,
        message: error.toString(),
      );
      String routeNext = '/order_error_bottom_sheet';

      showNextPage(context, pageNext, routeNext);
    });
    // .whenComplete(() {
    //   loadingNotifier.value = true;
    // });

    // String prices = '';
    // String qtys = '';
    // if(fastMode){
    //   List<PriceLot> listPriceLot = data.listFastPriceLot;
    //   int count = listPriceLot != null ? listPriceLot.length : 0;
    //   for(int i = 0; i < count; i++){
    //     PriceLot pl = listPriceLot.add(value);
    //   }
    // }else{
    //   prices = data.normalPriceLot.price.toString();
    //   qtys = data.normalPriceLot.lot.toString();
    // }

    //=============================
    /*
    if (fastMode) {
      bool testShowError = orderType.isSellOrAmendSell();

      Widget pageFinished;
      if (testShowError) {
        pageFinished = ErrorBottomSheet(data);
      } else {
        pageFinished = OrderFinishedFullscreenBottomSheet(data);
      }

      InvestrendTheme.push(context, pageFinished, ScreenTransition.SlideUp, '/order_finished_fast_mode_bottom_sheet').then((value) {
        if (value == null) {
          print('Order Finished value : NULL  clearData : true');
          context.read(clearOrderChangeNotifier).mustNotifyListener();
          Navigator.pop(context);
        } else if (value is BuySell) {
          print('Order Finished value : BuySell  clearData : true');
          context.read(clearOrderChangeNotifier).mustNotifyListener();
          Navigator.pop(context);
          InvestrendTheme.push(context, ScreenOrderDetail(value, null), ScreenTransition.SlideDown, '/order_detail');
        } else {
          if (value is String) {
            if (!StringUtils.equalsIgnoreCase(value, 'KEEP')) {
              print('Order Finished value : $value  clearData : true');
              context.read(clearOrderChangeNotifier).mustNotifyListener();
            }
          } else {
            print('Order Finished value : [NOT a String]  clearData : true');
            context.read(clearOrderChangeNotifier).mustNotifyListener();
          }
          Navigator.pop(context);
        }
      });
    } else {
      Future<OrderReply> result = InvestrendTheme.tradingHttp.order_new(
          account.brokercode,
          account.accountcode,
          '',
          data.orderType.shortSymbol,
          data.stock_code,
          Stock.defaultBoardByCode(data.stock_code),
          data.normalPriceLot.price.toString(),
          data.normalPriceLot.lot.toString(),
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      result.then((value) {
        print('Got order_new --> ' + value.toString());
        //{"message":"RF|OK|NEW|E108|A21"}

        data.setOrderId(value.orderid);
        Widget pageNext;
        String routeNext;

        if (StringUtils.equalsIgnoreCase(value.result, 'OK')) {
          pageNext = OrderFinishedFullscreenBottomSheet(data);
          routeNext = '/order_finished_bottom_sheet';
        } else if (StringUtils.equalsIgnoreCase(value.result, 'BAD')) {
          pageNext = ErrorBottomSheet(data);
          routeNext = '/order_error_bottom_sheet';
        } else {
          pageNext = UnknownResponseSheet(data, value.toString());
          routeNext = '/order_unknown_response_bottom_sheet';
        }
        InvestrendTheme.push(
            context, pageNext, ScreenTransition.SlideUp, routeNext)
            .then((value) {
          if (value == null) {
            print('Order Finished value : NULL  clearData : true');
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            Navigator.pop(context);
          } else if (value is BuySell) {
            print('Order Finished value : BuySell  clearData : true');
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            print('Order Finished value : BuySell  pop');
            Navigator.pop(context);
            print('Order Finished value : BuySell  push order detail');
            InvestrendTheme.push(context, ScreenOrderDetail(value, null), ScreenTransition.SlideDown, '/order_detail');

            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //
            // });

          } else {
            if (value is String) {
              if (!StringUtils.equalsIgnoreCase(value, 'KEEP')) {
                print('Order Finished value : $value  clearData : true');
                context.read(clearOrderChangeNotifier).mustNotifyListener();
              }
            } else {
              print('Order Finished value : [NOT a String]  clearData : true');
              context.read(clearOrderChangeNotifier).mustNotifyListener();
            }
            Navigator.pop(context);
          }
        });

      }).onError((error, stackTrace) {
        print(error);
        //InvestrendTheme.of(context).showSnackBar(context, 'error : ' + error.toString());

        Widget pageNext = ErrorBottomSheet(data);
        String routeNext = '/order_error_bottom_sheet';
        InvestrendTheme.push(
            context, pageNext, ScreenTransition.SlideUp, routeNext)
            .then((value) {
          if (value == null) {
            print('Order Finished value : NULL  clearData : true');
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            Navigator.pop(context);
          } else if (value is BuySell) {
            print('Order Finished value : BuySell  clearData : true');
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            print('Order Finished value : BuySell  pop');
            Navigator.pop(context);
            print('Order Finished value : BuySell  push order detail');
            InvestrendTheme.push(context, ScreenOrderDetail(value, null), ScreenTransition.SlideDown, '/order_detail');

            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //
            // });

          } else {
            if (value is String) {
              if (!StringUtils.equalsIgnoreCase(value, 'KEEP')) {
                print('Order Finished value : $value  clearData : true');
                context.read(clearOrderChangeNotifier).mustNotifyListener();
              }
            } else {
              print('Order Finished value : [NOT a String]  clearData : true');
              context.read(clearOrderChangeNotifier).mustNotifyListener();
            }
            Navigator.pop(context);
          }
        });
      });
    }
    */
    //.whenComplete(() => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    // int selected = context.read(accountChangeNotifier).index;
    // Account account = InvestrendTheme.of(context).user.accounts.elementAt(i);
    // if(account == null){
    //
    //     return;
    // }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minHeight = height * 0.3;
    double maxHeight = height * 0.8;

    //BuySell data = context.read(buySellChangeNotifier).getData(orderType);

    print('CONFIRMATION for data --> ' + data.toString());
    String accountName = account.accountname;
    String accountType = account.accountcode;
    String code = data.stock_code;
    String name = data.stock_name;
    bool fastMode = data.fastMode;
    int tradingLimitUsage = data.tradingLimitUsage;
    int totalValue =
        data.fastMode ? data.fastTotalValue : data.normalTotalValue;

    //OrderType orderType = odc.orderType;
    String orderTypeText = orderType == OrderType.Buy
        ? 'trade_tabs_buy_title'.tr()
        : 'trade_tabs_sell_title'.tr();
    String confirmationTitle = orderType == OrderType.Buy
        ? 'trade_confirmation_buy_label'.tr()
        : 'trade_confirmation_sell_label'.tr();

    List<Widget> list = List.empty(growable: true);

    double heightListView = 0.0;
    double heightRowSmallPlusPadding = 20.0 +
        UIHelper.textSize(
                'WgjLl', InvestrendTheme.of(context).small_w400_compact)
            .height;
    double heightRowReguler = UIHelper.textSize(
            'WgjLl', InvestrendTheme.of(context).regular_w600_compact)
        .height;

    list.add(TradeComponentCreator.popupRow(
        context,
        'trade_confirmation_account_label'.tr(),
        accountName + ' - ' + accountType));
    heightListView += heightRowSmallPlusPadding;
    list.add(TradeComponentCreator.popupRow(
        context, 'trade_confirmation_stock_code_label'.tr(), code));
    heightListView += heightRowSmallPlusPadding;
    list.add(TradeComponentCreator.popupRow(
        context, 'trade_confirmation_stock_name_label'.tr(), name));
    heightListView += heightRowSmallPlusPadding;
    list.add(TradeComponentCreator.popupRow(
        context, 'trade_confirmation_order_type_label'.tr(), orderTypeText));
    heightListView += heightRowSmallPlusPadding;

    String prices = '';
    String qtys = '';

    if (fastMode) {
      List<PriceLot> listPriceLot = data.listFastPriceLot;
      int count = listPriceLot != null ? listPriceLot.length : 0;
      if (count == 0) {
        list.add(TradeComponentCreator.popupRow(context,
            'trade_confirmation_fast_mode_lot_price_label'.tr(), '-  |  -'));
        heightListView += heightRowSmallPlusPadding;
      } else {
        bool first = true;
        for (int i = 0; i < count; i++) {
          PriceLot pl = listPriceLot.elementAt(i);
          if (pl != null) {
            if (first) {
              prices = pl.price.toString();
              qtys = pl.lot.toString();
              list.add(TradeComponentCreator.popupRow(
                  context,
                  'trade_confirmation_fast_mode_lot_price_label'.tr(),
                  InvestrendTheme.formatComma(pl.lot) +
                      '   |   ' +
                      InvestrendTheme.formatMoney(pl.price, prefixRp: true)));
              first = false;
            } else {
              prices = prices + '|' + pl.price.toString();
              qtys = qtys + '|' + pl.lot.toString();
              list.add(TradeComponentCreator.popupRow(
                  context,
                  '  ',
                  InvestrendTheme.formatComma(pl.lot) +
                      '   |   ' +
                      InvestrendTheme.formatMoney(pl.price, prefixRp: true)));
            }
            heightListView += heightRowSmallPlusPadding;
          }
        }
        if (first) {
          list.add(TradeComponentCreator.popupRow(context,
              'trade_confirmation_fast_mode_lot_price_label'.tr(), '-  |  -'));
          heightListView += heightRowSmallPlusPadding;
        }
      }
    } else {
      PriceLot pl = data.normalPriceLot;
      if (pl != null) {
        prices = pl.price.toString();
        qtys = pl.lot.toString();
        list.add(TradeComponentCreator.popupRow(
            context,
            'trade_confirmation_price_label'.tr(),
            InvestrendTheme.formatMoney(pl.price, prefixRp: true)));
        heightListView += heightRowSmallPlusPadding;
        list.add(TradeComponentCreator.popupRow(
            context,
            'trade_confirmation_lot_label'.tr(),
            InvestrendTheme.formatComma(pl.lot)));
        heightListView += heightRowSmallPlusPadding;

        if (data.transactionType != null &&
            (data.transactionType == TransactionType.Loop ||
                data.transactionType == TransactionType.Split)) {
          String type = data.transactionTypeText();
          list.add(TradeComponentCreator.popupRow(context, type,
              InvestrendTheme.formatComma(data.transactionCounter)));
          heightListView += heightRowSmallPlusPadding;
        }
      } else {
        list.add(TradeComponentCreator.popupRow(
            context,
            'trade_confirmation_price_label'.tr(),
            InvestrendTheme.formatMoney(0, prefixRp: true)));
        heightListView += heightRowSmallPlusPadding;
        list.add(TradeComponentCreator.popupRow(
            context,
            'trade_confirmation_lot_label'.tr(),
            InvestrendTheme.formatComma(0)));
        heightListView += heightRowSmallPlusPadding;
      }
    }

    list.add(Divider(
      thickness: 1.0,
    ));
    heightListView += 3.0;
    list.add(Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'trade_confirmation_total_label'.tr(),
            style: InvestrendTheme.of(context).regular_w600_compact.copyWith(
                color: InvestrendTheme.of(context).greyLighterTextColor),
          ),
          Expanded(
            child: Text(
              InvestrendTheme.formatMoney(totalValue, prefixRp: true),
              style: InvestrendTheme.of(context).regular_w600_compact.copyWith(
                  color: InvestrendTheme.of(context).blackAndWhiteText),
              textAlign: TextAlign.right,
            ),
            flex: 1,
          ),
        ],
      ),
    ));
    heightListView += heightRowReguler + 30.0;

    heightListView += 70.0 + 70.0 + 24.0 + 24.0;
    if (heightListView < maxHeight) {
      maxHeight = heightListView;
    }

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        padding: const EdgeInsets.only(
            top: 30.0, bottom: 24.0, left: 24.0, right: 10.0),
        width: double.maxFinite,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TradeComponentCreator.popupTitle(
                      context, confirmationTitle),
                  flex: 1,
                ),
                IconButton(
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
              ],
            ),
            Expanded(
                flex: 1,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(right: 14.0),
                    children: list,
                  ),
                )),
            /*
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(top: 24.0, right: 14.0),
              child: ButtonOrder(orderType, () {
                buttonConfirmClicked(context, data, prices, qtys);
              }),
            ),
            */
            Padding(
              padding: EdgeInsets.only(top: 24.0, right: 14.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ButtonOrderOutlined(orderType, () {
                      buttonConfirmClicked(context, data, prices, qtys);
                    }),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardPaddingGeneral,
                  ),
                  Expanded(
                    flex: 1,
                    child: ButtonCancel(() {
                      Navigator.pop(context);
                    }),
                  ),
                  //ComponentCreator.roundedButtonSolid(context, 'button_cancel'.tr(), InvestrendTheme.cancelColor, Theme.of(context).primaryColor, () { }),

                  // ButtonRounded('button_cancel'.tr(), (){
                  //   Navigator.pop(context);
                  // }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
class AccountBottomSheet extends ConsumerWidget {
  //const AccountBottomSheet({Key key}) : super(key: key);

  Widget getIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2.0),
      ),
      //color:const Color(0xFFE0E0E0),
      height: 4.0,
      width: 64.0,
    );
  }

  //final int selected = 0;
  Widget createRow(BuildContext context, Account account, int index, AccountStockPosition info) {
    bool isSelected = index == context.read(accountChangeNotifier).index;
    print('index : $index  current : ' + context.read(accountChangeNotifier).index.toString() + '  isSelected : $isSelected');

    Color color = isSelected ? Theme.of(context).accentColor : InvestrendTheme.of(context).blackAndWhiteText;

    String type = StringUtils.equalsIgnoreCase(account.type, 'R')
        ? 'Regular'
        : (StringUtils.equalsIgnoreCase(account.type, 'M') ? 'Margin' : 'Don\'t Know : ' + account.type);
    // int portfolio_value = 200005965;
    // int buying_power = 200005789;
    // int gain_loss_idr = 30000000;
    // double gain_loss_percentage = 14.56;

    int portfolio_value = 0;
    double buying_power = 0;
    int gain_loss_idr = 0;
    double gain_loss_percentage = 0;
    if (info != null) {
      portfolio_value = info.totalMarket;
      buying_power = info.outstandingLimit; // harus diisi
      gain_loss_idr = info.totalGL;
      gain_loss_percentage = info.totalGLPct;
    }

    Color colorGain = InvestrendTheme.priceTextColor(gain_loss_idr);

    List<Widget> list = List.empty(growable: true);
    if (isSelected) {
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: Text(type, style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: color))),
          Image.asset(
            'images/icons/check.png',
            width: 20.0,
            height: 20.0,
          ),
          // Icon(
          //   Icons.check_circle,
          //   color: Theme.of(context).accentColor,
          //   //size: 16.0,
          // ),
        ],
      ));
    } else {
      list.add(Container(
          width: double.maxFinite,
          child: Text(
            type,
            style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: color),
            textAlign: TextAlign.left,
          )));
    }
    list.add(SizedBox(
      height: 10.0,
    ));

    list.add(Row(
      children: [
        Expanded(
            flex: 1,
            child: Text('trade_account_portfolio_value_label'.tr(),
                style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor))),
        Expanded(
            flex: 1,
            child: Text(
              'trade_account_buyer_power_label'.tr(),
              style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              textAlign: TextAlign.end,
            )),
      ],
    ));
    list.add(SizedBox(
      height: 4.0,
    ));
    list.add(Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(InvestrendTheme.formatMoney(portfolio_value, prefixRp: true),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText))),
        Expanded(
            flex: 1,
            child: Text(
              InvestrendTheme.formatMoneyDouble(buying_power, prefixRp: true),
              style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
              textAlign: TextAlign.end,
            )),
      ],
    ));
    list.add(SizedBox(
      height: 4.0,
    ));
    list.add(Row(
      children: [
        Text(InvestrendTheme.formatMoney(gain_loss_idr, prefixRp: true),
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: colorGain)),
        SizedBox(
          width: 4.0,
        ),
        Text(
          '(' + InvestrendTheme.formatPercentChange(gain_loss_percentage, sufixPercent: true) + ')',
          style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: colorGain),
          textAlign: TextAlign.end,
        ),
      ],
    ));

    return InkWell(
      onTap: () {
        context.read(accountChangeNotifier).setIndex(index);
        //context.read(rdnBalanceStateProvider).state = 0;
        context.read(buyRdnBuyingPowerChangeNotifier).update(0.0, 0.0);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 24.0, left: 24.0, right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: list,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final selected = watch(accountChangeNotifier);
    final infos = watch(accountsInfosNotifier);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    // double heightRowReguler = UIHelper.textSize('WgjLl', InvestrendTheme.of(context).regular_w700_compact).height;
    //
    // double contentHeight = 0.0;
    // contentHeight += 30.0 + 24.0 + 30;

    List<Widget> list = List.empty(growable: true);
    //list.add(getIndicator());
    //int count = InvestrendTheme.of(context).user.accountSize();
    int count = context.read(dataHolderChangeNotifier).user.accountSize();

    print('accountSize : ' + count.toString());
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        //Account account = InvestrendTheme.of(context).user.getAccount(i);
        Account account = context.read(dataHolderChangeNotifier).user.getAccount(i);
        AccountStockPosition info = infos.getInfo(account.accountcode);
        if (i != 0) {
          list.add(Divider());
        }
        list.add(createRow(context, account, i, info));
      }
    }
    //
    // list.add(createRow(context, null, 0));
    // list.add(Divider());
    // list.add(createRow(context, null, 1));
    // list.add(Divider());
    // list.add(createRow(context, null, 2));
    // list.add(Divider());
    // list.add(createRow(context, null, 3));

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        // color: Colors.orangeAccent,
        padding: const EdgeInsets.only(top: 30.0, bottom: 24.0 /*, left: 24.0, right: 24.0*/),
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            getIndicator(),
            Expanded(
              flex: 1,
              child: ListView(
                shrinkWrap: true,
                children: list,
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/
