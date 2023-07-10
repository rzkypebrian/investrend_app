import 'dart:io';

import 'package:Investrend/component/bottom_sheet/bottom_sheet_alert.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/buttons_attention.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_error.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_unknown_response.dart';
import 'package:Investrend/screens/trade/screen_amend_buy.dart';
import 'package:Investrend/screens/trade/screen_amend_sell.dart';
import 'package:Investrend/screens/trade/screen_order_detail.dart';
import 'package:Investrend/screens/trade/trade_component.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenAmend extends StatefulWidget {
  final BuySell amendData;

  const ScreenAmend(
    this.amendData, {
    Key key,
  }) : super(key: key);

  @override
  _ScreenAmendState createState() =>
      _ScreenAmendState(amendData.orderType, amendData);
}

class _ScreenAmendState extends BaseStateNoTabs<ScreenAmend>
    with SingleTickerProviderStateMixin {
  String timeCreation = '-';
  OrderType _initialOrderType;
  final BuySell amendData;
  final UniqueKey keyAmendBuy = UniqueKey();
  final UniqueKey keyAmendSell = UniqueKey();
  ValueNotifier<bool> _updateDataNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> _bottomSheetNotifier = ValueNotifier(true);
  ValueNotifier<bool> _keyboardNotifier = ValueNotifier(false);
  _ScreenAmendState(this._initialOrderType, this.amendData) : super('/amend');

  List<String> logs = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    runPostFrame(() {
      int index = context
          .read(dataHolderChangeNotifier)
          .user
          .getIndexAccountByCode(amendData.brokerCode, amendData.accountCode);
      print(routeName +
          ' initState amend got indexAccount : $index  for ' +
          amendData.accountCode);
      if (index >= 0) {
        context.read(accountChangeNotifier).setIndex(index);
        Account account = context
            .read(dataHolderChangeNotifier)
            .user
            .getAccountByCode(amendData.brokerCode, amendData.accountCode);

        if (account != null) {
          AccountStockPosition info = context
              .read(accountsInfosNotifier)
              .getInfo(amendData.accountCode);
          if (info != null) {
            double buyingPower = info.outstandingLimit; // harus diisi
            //double rdnBalance = info.rdnBalance;
            double cashBalance = info.cashBalance;
            //context.read(buyRdnBuyingPowerChangeNotifier).update(buying_power, cashBalance);
            context
                .read(buyRdnBuyingPowerChangeNotifier)
                .update(buyingPower, info.availableCash, info.creditLimit);
          }
        }
      } else {
        InvestrendTheme.of(context).showSnackBar(
            context, 'Can not find account in list Account [index]');
        return;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bool keyboardShowed = MediaQuery.of(context).viewInsets.bottom > 0;
    print(
        'ScreenAmend.didChangeDependencies   keyboardShowed : $keyboardShowed');
    _keyboardNotifier.value = keyboardShowed;
    _bottomSheetNotifier.value = !keyboardShowed;
  }

  @override
  void dispose() {
    print('ScreenAmend.dispose');
    logs.clear();
    _updateDataNotifier.dispose();
    _loadingNotifier.dispose();
    _bottomSheetNotifier.dispose();
    _keyboardNotifier.dispose();
    super.dispose();
  }

  @override
  void onActive() {
    // TODO: implement onActive
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  //
  //
  // @override
  // Widget build(BuildContext context) {
  //   double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
  //   return Scaffold(
  //     backgroundColor: Theme.of(context).backgroundColor,
  //     appBar: createAppBar(context),
  //     body: Scaffold(
  //       backgroundColor: Theme.of(context).backgroundColor,
  //       appBar: createTabs(context),
  //       body: createBody(context),
  //     ),
  //     bottomSheet: createBottomSheet(context, paddingBottom),
  //   );
  // }
  String attentionCodes;
  List<Remark2Mapping> notation = List.empty(growable: true);
  StockInformationStatus status;
  SuspendStock suspendStock;
  List<CorporateActionEvent> corporateAction = List.empty(growable: true);
  Color corporateActionColor = Colors.black;

  Widget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    Widget title = Consumer(builder: (context, watch, child) {
      final notifier = watch(stockSummaryChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }

      TextStyle styleAttention = InvestrendTheme.of(context).headline3;
      Size textSize = UIHelper.textSize('ABCD', styleAttention);
      attentionCodes = context
          .read(remark2Notifier)
          .getSpecialNotationCodes(notifier.stock.code);
      notation =
          context.read(remark2Notifier).getSpecialNotation(notifier.stock.code);
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
      /*
      return Column(
        children: [
          Hero(tag: 'trade_code', child: AppBarTitleText(amendData.stock_code)),
          SizedBox(
            height: 5.0,
          ),
          Text(
            InvestrendTheme.formatPrice(notifier.summary.close),
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: Theme.of(context).accentColor),
          ),
        ],
      );
       */
      Widget codePriceWidget = Column(
        children: [
          Hero(tag: 'trade_code', child: AppBarTitleText(amendData.stock_code)),
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
        list.add(ButtonTextAttentionMozaic(attentionCodes, textSize.height - 3,
            status, onImportantInformation));
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
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      //title: AppBarTitleText(amendData.stock_code),
      title: title,

      // title: Consumer(builder: (context, watch, child) {
      //   final notifier = watch(primaryStockChangeNotifier);
      //   if (notifier.invalid()) {
      //     return Center(child: CircularProgressIndicator());
      //   }
      //   return Text(
      //     notifier.stock.code,
      //     style: Theme.of(context).appBarTheme.titleTextStyle,
      //   );
      // }),

      actions: [
        AppBarConnectionStatus(
          child: SizedBox(
            width: 20.0,
          ),
          // child: TextButton(
          //     onPressed: () {
          //       InvestrendTheme.of(context).showInfoDialog(context, title: 'Debug', content: logs.join('\n'));
          //     },
          //     child: Text(
          //       'Debug',
          //       style: TextStyle(color: Colors.red),
          //     )),
        ),
        /*
        TextButton(onPressed: (){
          InvestrendTheme.of(context).showInfoDialog(context,title: 'Debug', content: logs.join('\n'));
        }, child: Text('Debug', style: TextStyle(color: Colors.red),)),
        */
        //   AppBarActionIcon('images/icons/action_search.png', () {
        //     FocusScope.of(context).requestFocus(new FocusNode());
        //     final result = InvestrendTheme.showFinderScreen(context);
        //     result.then((value) {
        //       if (value == null) {
        //         print('result finder = null');
        //       } else if (value is Stock) {
        //         print('result finder = ' + value.code);
        //
        //         // InvestrendTheme.of(context).stockNotifier.setStock(value);
        //
        //         context.read(primaryStockChangeNotifier).setStock(value);
        //       } else if (value is People) {
        //         print('result finder = ' + value.name);
        //       }
        //     });
        //   }),
      ],
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

  //bool fastMode = false;

  Widget createBody(BuildContext context, double paddingBottom) {
    if (_initialOrderType.isBuyOrAmendBuy()) {
      return ComponentCreator.keyboardHider(
          context,
          ScreenAmendBuy(
            amendData,
            _updateDataNotifier,
            key: keyAmendBuy,
            keyboardNotifier: _keyboardNotifier,
          ));
    } else if (_initialOrderType.isSellOrAmendSell()) {
      return ComponentCreator.keyboardHider(
          context,
          ScreenAmendSell(
            amendData,
            _updateDataNotifier,
            key: keyAmendSell,
            keyboardNotifier: _keyboardNotifier,
          ));
    } else {
      return Center(
          child: Text(
        'Amend Unknown Type',
        style: Theme.of(context).textTheme.bodyText2,
      ));
    }

    // return TabBarView(
    //   controller: _tabController,
    //   children: List<Widget>.generate(
    //     tabs.length,
    //     (int index) {
    //       print(tabs[index]);
    //
    //       if (index == OrderType.Buy.index) {
    //         return ComponentCreator.keyboardHider(context, ScreenAmendBuy(_fastModeNotifier, _tabController));
    //       }
    //       if (index == OrderType.Sell.index) {
    //         return ComponentCreator.keyboardHider(context, ScreenAmendSell(_fastModeNotifier, _tabController));
    //       }
    //       return Container(
    //         child: Center(
    //           child: Text(tabs[index]),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  // bool isBuy() {
  //   return _orderTypeNotifier.value == OrderType.Buy;
  // }

  //bool small = true;
  bool canTap = true;

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    String tag;
    if (_initialOrderType.isBuyOrAmendBuy()) {
      tag = 'button_buy';
    } else if (_initialOrderType.isSellOrAmendSell()) {
      tag = 'button_sell';
    } else {
      tag = '???';
    }
    return ValueListenableBuilder(
      valueListenable: _bottomSheetNotifier,
      builder: (context, value, child) {
        if (!value) {
          if (Platform.isIOS) {
            return Container(
              //color: Colors.green,
              width: double.maxFinite,
              height: 40.0,
              //padding: EdgeInsets.only(top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0, right: InvestrendTheme.cardPaddingGeneral),
              // padding: EdgeInsets.only( bottom: paddingBottom > 0 ? paddingBottom : 0.0, right: InvestrendTheme.cardPaddingGeneral),
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
                        .copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () {
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
            padding: EdgeInsets.only(
                top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _initialOrderType.isBuyOrAmendBuy()
                                ? 'trade_total_buy_label'.tr()
                                : 'trade_total_sell_label'.tr(),
                            style: InvestrendTheme.of(context).small_w400,
                          ),
                          Consumer(builder: (context, watch, child) {
                            final notifier = watch(amendChangeNotifier);

                            BuySell data = notifier.getData(_initialOrderType);

                            int value = data.normalTotalValue;

                            return Text(
                              InvestrendTheme.formatMoney(value,
                                  prefixRp: true),
                              style: InvestrendTheme.of(context).medium_w600,
                            );
                          }),
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
                  child: Hero(
                    tag: tag,
                    child: ButtonOrder(
                      _initialOrderType,
                      () {
                        FocusScope.of(context).requestFocus(new FocusNode());

                        if (!canTap) {
                          InvestrendTheme.of(context).showSnackBar(context,
                              'Trade canTap : $canTap waiting for Future.delayed 500ms');
                          return;
                        }
                        canTap = false;
                        _updateDataNotifier.value = !_updateDataNotifier.value;
                        Future.delayed(Duration(milliseconds: 500), () {
                          BuySell data = context
                              .read(amendChangeNotifier)
                              .getData(_initialOrderType);
                          BuySell newData = data.clone();

                          logs.insertAll(0, [
                            '--------------',
                            DateTime.now().toString(),
                            '--------------',
                            '## AMEND INITIAL DATA',
                            amendData.toString(),
                            '  ',
                            '## NEW DATA',
                            newData.toString(),
                            '--------------',
                            '  ',
                            '  '
                          ]);
                          // logs.add('  ');
                          // logs.add('--------------');
                          // logs.add(DateTime.now().toString());
                          // logs.add('--------------');
                          // logs.add('Amend Initial Data');
                          // logs.add(amendData.toString());
                          // logs.add('  ');
                          // logs.add('New Data');
                          // logs.add(newData.toString());
                          // logs.add('--------------');

                          Account account = context
                              .read(dataHolderChangeNotifier)
                              .user
                              .getAccountByCode(
                                  amendData.brokerCode, amendData.accountCode);
                          if (account == null) {
                            InvestrendTheme.of(context).showSnackBar(
                                context, 'error_no_account_selected'.tr());
                            canTap = true;
                            return;
                          }
                          String reffID = Utils.createRefferenceID();
                          canTap = true;
                          _loadingNotifier.value = false;
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
                                return ConfirmationBottomSheet(
                                    amendData,
                                    _initialOrderType,
                                    newData,
                                    reffID,
                                    _loadingNotifier);
                              }).then((value) {
                            bool finished = value != null &&
                                value is String &&
                                StringUtils.equalsIgnoreCase(value, 'FINISHED');
                            if (finished) {
                              Navigator.pop(context, 'FINISHED');
                            }
                          });
                        });
                      },
                    ),
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
      padding: EdgeInsets.only(top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ValueListenableBuilder(
                    //   valueListenable: _orderTypeNotifier,
                    //   builder: (context, OrderType value, child) {
                    //     String text = '';
                    //     if (value == OrderType.Buy) {
                    //       text = 'trade_total_buy_label'.tr();
                    //     } else if (value == OrderType.Sell) {
                    //       text = 'trade_total_sell_label'.tr();
                    //     }
                    //     return Text(
                    //       text,
                    //       style: InvestrendTheme.of(context).small_w400,
                    //     );
                    //   },
                    // ),
                    Text(
                      _initialOrderType.isBuyOrAmendBuy() ? 'trade_total_buy_label'.tr() : 'trade_total_sell_label'.tr(),
                      style: InvestrendTheme.of(context).small_w400,
                    ),
                    Consumer(builder: (context, watch, child) {
                      final notifier = watch(amendChangeNotifier);
                      // if (notifier.stock.invalid()) {
                      //   return Center(child: CircularProgressIndicator());
                      // }
                      BuySell data = notifier.getData(_initialOrderType);

                      int value = data.normalTotalValue;

                      return Text(
                        InvestrendTheme.formatMoney(value, prefixRp: true),
                        style: InvestrendTheme.of(context).medium_w600,
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
            child: Hero(
              tag: tag,
              child: ButtonOrder(
                _initialOrderType,
                () {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  if (!canTap) {
                    InvestrendTheme.of(context).showSnackBar(context, 'Trade canTap : $canTap waiting for Future.delayed 500ms');
                    return;
                  }
                  canTap = false;
                  _updateDataNotifier.value = !_updateDataNotifier.value;
                  Future.delayed(Duration(milliseconds: 500), () {
                    BuySell data = context.read(amendChangeNotifier).getData(_initialOrderType);
                    BuySell newData = data.clone();

                    logs.insertAll(0, [
                      '--------------',
                      DateTime.now().toString(),
                      '--------------',
                      '## AMEND INITIAL DATA',
                      amendData.toString(),
                      '  ',
                      '## NEW DATA',
                      newData.toString(),
                      '--------------',
                      '  ',
                      '  '
                    ]);
                    // logs.add('  ');
                    // logs.add('--------------');
                    // logs.add(DateTime.now().toString());
                    // logs.add('--------------');
                    // logs.add('Amend Initial Data');
                    // logs.add(amendData.toString());
                    // logs.add('  ');
                    // logs.add('New Data');
                    // logs.add(newData.toString());
                    // logs.add('--------------');

                    Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(amendData.brokerCode, amendData.accountCode);
                    if (account == null) {
                      InvestrendTheme.of(context).showSnackBar(context, 'No Account Selected');
                      canTap = true;
                      return;
                    }
                    String reffID = Utils.createRefferenceID();
                    canTap = true;
                    _loadingNotifier.value = false;
                    showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                        ),
                        //backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return ConfirmationBottomSheet(amendData, _initialOrderType, newData, reffID, _loadingNotifier);
                        }).then((value) {
                      bool finished = value != null && value is String && StringUtils.equalsIgnoreCase(value, 'FINISHED');
                      if (finished) {
                        Navigator.pop(context, 'FINISHED');
                      }
                    });
                  });

                  /*
                  setState(() {
                    // small = !small;
                    // print('small $small');


                  });
                  */
                },
              ),
            ),
          ),

          // child: ValueListenableBuilder(
          //   valueListenable: _orderTypeNotifier,
          //   builder: (context, OrderType value, child) {
          //     String tag;
          //     if (value == OrderType.Buy) {
          //       tag = 'button_buy';
          //     } else if (value == OrderType.Sell) {
          //       tag = 'button_sell';
          //     } else {
          //       tag = '???';
          //     }
          //     print('tag : $tag  ' + DateTime.now().toString());
          //     return Hero(
          //         tag: tag,
          //         child: ButtonOrder(
          //           value,
          //           () {
          //             FocusScope.of(context).requestFocus(new FocusNode());
          //             setState(() {
          //               small = !small;
          //               print('small $small');
          //
          //               showModalBottomSheet(
          //                   isScrollControlled: true,
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          //                   ),
          //                   //backgroundColor: Colors.transparent,
          //                   context: context,
          //                   builder: (context) {
          //                     return ConfirmationBottomSheet(_orderTypeNotifier.value);
          //                   });
          //             });
          //           },
          //         ));
          //   },
          //),
          //),
        ],
      ),
    );
    */
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

class BaseTradeBottomSheet extends StatelessWidget {
  const BaseTradeBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {}

// Widget TradeComponentCreator.popupRow(BuildContext context, String label, String value) {
//   return Container(
//     //color: Colors.purple,
//     padding: const EdgeInsets.only(top: 10, bottom: 10),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _labelText(context, label),
//         Expanded(
//           flex: 1,
//           child: _valueText(context, value),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget _createTitle(BuildContext context, String title) {
//   return Text(
//     title,
//     style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
//   );
// }
//
// Widget _labelText(BuildContext context, String label) {
//   return Container(
//     // color: Colors.yellow,
//     child: Text(
//       label,
//       style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
//     ),
//   );
// }
//
// Widget _valueText(BuildContext context, String label) {
//   return Container(
//     // color: Colors.greenAccent,
//     child: Text(
//       label,
//       style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
//       textAlign: TextAlign.right,
//     ),
//   );
// }
// Widget _createButtonSolid(OrderType orderType, VoidCallback onPressed){
//   return Container(
//       width: double.maxFinite,
//       padding: EdgeInsets.only(top: 24.0, right: 14.0),
//       child: ButtonOrder(orderType,onPressed));
// }
}

class AmendFinishedBottomSheet extends BaseTradeBottomSheet {
  final BuySell data;

  AmendFinishedBottomSheet(this.data);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    double heightRowReguler = UIHelper.textSize(
            'WgjLl', InvestrendTheme.of(context).regular_w600_compact)
        .height;

    double contentHeight = 0.0;
    contentHeight += 30.0 + 24.0 + 20.0;
    // contentHeight += 200.0;
    // contentHeight += heightRowReguler;
    // contentHeight += 3.0;
    // contentHeight += 55.0 + 55.0 + 24.0 + 24.0 + 5.0;

    List<Widget> list = List.empty(growable: true);
    //list.add(TradeComponentCreator.popupTitle(context, 'amend_finished_title'.tr()));

    list.add(Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TradeComponentCreator.popupTitle(
              context, 'amend_finished_title'.tr()),
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

    contentHeight += heightRowReguler;
    list.add(SizedBox(
      height: 27.0,
    ));
    contentHeight += 27.0;
    list.add(Spacer(
      flex: 1,
    ));
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
            ? 'amend_finished_order_buy_sent_label'.tr()
            : 'amend_finished_order_sell_sent_label'.tr()),
        style: InvestrendTheme.of(context)
            .regular_w400_compact
            .copyWith(color: Color(0xFF25B792)),
      )),
    );
    list.add(Spacer(
      flex: 1,
    ));
    contentHeight += heightRowReguler;
    list.add(SizedBox(
      height: 24.0,
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

    contentHeight += 16.0;
    list.add(Container(
      width: double.maxFinite,
      child: TextButton(
          child: Text(
            'amend_finished_button_close'.tr(),
            style: InvestrendTheme.of(context)
                .small_w600_compact
                .copyWith(color: Theme.of(context).buttonColor),
          ),
          onPressed: () {
            print('closed clicked');
            Navigator.pop(context, 'FINISHED');
          }),
    ));
    contentHeight += 55.0;

    //maxHeight = min(contentHeight, maxHeight);
    print('AmendFinishedBottomSheet maxHeight : $maxHeight');
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
  final BuySell initialAmendData;
  final BuySell data;
  final String reff;
  final ValueNotifier<bool> loadingNotifier;

  const ConfirmationBottomSheet(this.initialAmendData, this.orderType,
      this.data, this.reff, this.loadingNotifier,
      {Key key})
      : super(key: key);

  /*
  void buttonConfirmClicked(BuildContext context, BuySell data) {
    //InvestrendTheme.of(context).showSnackBar(context, 'Confirm clicked');
    print('order confirm AMEND clicked AAA');
    bool fastMode = data.fastMode;
    //Navigator.pop(context);
    //String broker, String account, String user, String orderid, int price, int qty,
    //String platform, String version

    Future<OrderReply> result = InvestrendTheme.tradingHttp.amend(
        data.brokerCode,
        data.accountCode,
        '',
        data.orderid,
        data.,
        Stock.defaultBoardByCode(data.stock_code),
        data.normalPriceLot.price,
        data.normalPriceLot.lot,
        InvestrendTheme.of(context).applicationPlatform,
        InvestrendTheme.of(context).applicationVersion);
    result.then((value) {
      print('Got order_new --> ' + value.toString());
      //{"message":"RF|OK|NEW|E108|A21"}

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
      InvestrendTheme.push(context, pageNext, ScreenTransition.SlideUp, routeNext).then((value) {
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
          InvestrendTheme.push(context, ScreenOrderDetail(value), ScreenTransition.SlideDown, '/order_detail');

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
      InvestrendTheme.push(context, pageNext, ScreenTransition.SlideUp, routeNext).then((value) {
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
          InvestrendTheme.push(context, ScreenOrderDetail(value), ScreenTransition.SlideDown, '/order_detail');

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
  void buttonConfirmClicked(
      BuildContext context, BuySell oldData, BuySell newData) {
    String loadingText = 'loading_submiting_amend_label'.tr();
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

    Future<OrderReply> result = InvestrendTheme.tradingHttp.amend(
        reff,
        newData.brokerCode,
        newData.accountCode,
        context.read(dataHolderChangeNotifier).user.username,
        newData.orderid,
        newData.normalPriceLot.price,
        newData.normalPriceLot.lot,
        InvestrendTheme.of(context).applicationPlatform,
        InvestrendTheme.of(context).applicationVersion);

    result.then((reply) {
      print('Got order_new --> ' + reply.toString());
      //{"message":"RF|OK|NEW|E108|A21"}
      loadingNotifier.value = true;
      //String order_date = Utils.formatDate(DateTime.now().toLocal());
      data.setOrderInformation(reply.orderid, reply.orderdate);

      if (StringUtils.equalsIgnoreCase(reply.result, 'OK')) {
        //pageNext = AmendFinishedBottomSheet(data);
        //routeNext = '/order_finished_bottom_sheet';

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
              return AmendFinishedBottomSheet(data);
            }).whenComplete(() => Navigator.pop(context, 'FINISHED'));
      } else {
        Widget pageNext;
        String routeNext;
        if (StringUtils.equalsIgnoreCase(reply.result, 'BAD')) {
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
      }
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

      if (error is TradingHttpException) {
        if (error.isUnauthorized()) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
          return;
        } else if (error.isErrorTrading()) {
          InvestrendTheme.of(context).showSnackBar(context, error.message());
          return;
        } else {
          String networkErrorLabel = 'network_error_label'.tr();
          networkErrorLabel =
              networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
          return;
        }
      } else {
        InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
    });
  }

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
          } else {
            print('Amend Finished value : $value  clearData : true');
            context.read(clearOrderChangeNotifier).mustNotifyListener();
            Navigator.pop(context);
          }
        } else {
          print('Amend Finished value : [NOT a String]  clearData : true');
          context.read(clearOrderChangeNotifier).mustNotifyListener();
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minHeight = height * 0.3;
    double maxHeight = height * 0.8;

    //BuySell data = context.read(amendChangeNotifier).getData(orderType);

    data.setAccount(initialAmendData.accountName, initialAmendData.accountType,
        initialAmendData.accountCode, initialAmendData.brokerCode);
    data.setOrderInformation(
        initialAmendData.orderid, initialAmendData.orderdate);
    //data.setStock(initialAmendData.stock_code, initialAmendData.stock_name);

    print('CONFIRMATION AMEND for data --> ' + data.toString());
    String accountName = data.accountName;
    String accountType = data.accountType;
    //String code = data.stock_code;
    //String name = data.stock_name;

    String code = initialAmendData.stock_code;
    String name = initialAmendData.stock_name;

    bool fastMode = data.fastMode;
    int tradingLimitUsage = data.tradingLimitUsage;
    int totalValue =
        data.fastMode ? data.fastTotalValue : data.normalTotalValue;
    //OrderType orderType = odc.orderType;
    String orderTypeText =
        orderType.isBuyOrAmendBuy() ? 'buy_text'.tr() : 'sell_text'.tr();
    String confirmationTitle = orderType.isBuyOrAmendBuy()
        ? 'amend_confirmation_buy_label'.tr()
        : 'amend_confirmation_sell_label'.tr();

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
        'amend_confirmation_account_label'.tr(),
        accountName + ' - ' + accountType));
    heightListView += heightRowSmallPlusPadding;
    list.add(TradeComponentCreator.popupRow(
        context, 'amend_confirmation_stock_code_label'.tr(), code));
    heightListView += heightRowSmallPlusPadding;
    list.add(TradeComponentCreator.popupRow(
        context, 'amend_confirmation_stock_name_label'.tr(), name));
    heightListView += heightRowSmallPlusPadding;
    list.add(TradeComponentCreator.popupRow(
        context, 'amend_confirmation_order_type_label'.tr(), orderTypeText));
    heightListView += heightRowSmallPlusPadding;
    if (fastMode) {
      List<PriceLot> listPriceLot = data.listFastPriceLot;
      int count = listPriceLot != null ? listPriceLot.length : 0;
      if (count == 0) {
        list.add(TradeComponentCreator.popupRow(context,
            'amend_confirmation_fast_mode_lot_price_label'.tr(), '-  |  -'));
        heightListView += heightRowSmallPlusPadding;
      } else {
        bool first = true;
        for (int i = 0; i < count; i++) {
          PriceLot pl = listPriceLot.elementAt(i);
          if (pl != null) {
            if (first) {
              list.add(TradeComponentCreator.popupRow(
                  context,
                  'amend_confirmation_fast_mode_lot_price_label'.tr(),
                  InvestrendTheme.formatComma(pl.lot) +
                      '   |   ' +
                      InvestrendTheme.formatMoney(pl.price, prefixRp: true)));
              first = false;
            } else {
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
              'amend_confirmation_fast_mode_lot_price_label'.tr(), '-  |  -'));
          heightListView += heightRowSmallPlusPadding;
        }
      }
    } else {
      PriceLot newPriceLot = data.normalPriceLot;
      PriceLot oldPriceLot = initialAmendData.normalPriceLot;
      if (newPriceLot != null) {
        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_price_old_label'.tr(),
            InvestrendTheme.formatMoney(oldPriceLot.price, prefixRp: true)));
        heightListView += heightRowSmallPlusPadding;
        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_lot_old_label'.tr(),
            InvestrendTheme.formatComma(oldPriceLot.lot)));
        heightListView += heightRowSmallPlusPadding;
        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_price_new_label'.tr(),
            InvestrendTheme.formatMoney(newPriceLot.price, prefixRp: true)));
        heightListView += heightRowSmallPlusPadding;
        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_lot_new_label'.tr(),
            InvestrendTheme.formatComma(newPriceLot.lot)));
        heightListView += heightRowSmallPlusPadding;
      } else {
        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_price_old_label'.tr(),
            InvestrendTheme.formatMoney(0, prefixRp: true)));
        heightListView += heightRowSmallPlusPadding;
        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_lot_old_label'.tr(),
            InvestrendTheme.formatComma(0)));
        heightListView += heightRowSmallPlusPadding;

        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_price_new_label'.tr(),
            InvestrendTheme.formatMoney(0, prefixRp: true)));
        heightListView += heightRowSmallPlusPadding;
        list.add(TradeComponentCreator.popupRow(
            context,
            'amend_confirmation_lot_new_label'.tr(),
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

    // list.add(TradeComponentCreator.popupRow(
    //     context, 'trade_confirmation_trading_limit_used_label'.tr(), InvestrendTheme.formatMoney(tradingLimitUsage, prefixRp: true)));
    // heightListView += heightRowSmallPlusPadding;

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
          // children: list,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TradeComponentCreator.popupTitle(
                      context, confirmationTitle),
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
                  buttonConfirmClicked(context, initialAmendData, data);
                })),
            */
            Padding(
              padding: EdgeInsets.only(top: 24.0, right: 14.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ButtonOrderOutlined(orderType, () {
                      buttonConfirmClicked(context, initialAmendData, data);
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
