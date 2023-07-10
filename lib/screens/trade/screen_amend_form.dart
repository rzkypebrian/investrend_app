import 'dart:async';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/cards/card_orderbook.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/widget_tradebook.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/stock_detail/screen_order_queue.dart';
import 'package:Investrend/screens/trade/trade_component.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';


abstract class BaseAmendState<T extends StatefulWidget> extends VisibilityAwareState //with AutomaticKeepAliveClientMixin<StatefulWidget>
{
  final OrderType orderType;
  final BuySell amendData;
  final ValueNotifier<bool> updateDataNotifier;
  final ValueNotifier<bool> keyboardNotifier;
  BaseAmendState(this.orderType, this.amendData, this.updateDataNotifier,{this.keyboardNotifier});

  bool active = false;
  //Timer _timer;
  Timer _timerAccount;
  FocusNode focusNodePrice;
  FocusNode focusNodeLot;

  final fieldPriceController = TextEditingController();
  final fieldLotController = TextEditingController();
  final ValueNotifier<int> valueOrderNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> predefineLotNotifier = ValueNotifier<int>(0);
  static const Duration _durationUpdate = Duration(milliseconds: 2000);
  static const Duration _durationUpdateAccount = Duration(milliseconds: 5000);
  //ValueNotifier<double> animatePaddingNotifier;
  final OrderbookNotifier orderbookNotifier = OrderbookNotifier(OrderbookData());
  final ValueNotifier<String> predefineLotSourceNotifier = ValueNotifier<String>('cash_available_label'.tr());
  // @override
  // bool get wantKeepAlive => true;
  VoidCallback resetPredefineLot;
  final ScrollController scrollController = ScrollController();

  void onVisibilityChanged(WidgetVisibility visibility) {
    // TODO: Use visibility
    switch (visibility) {
      case WidgetVisibility.VISIBLE:
        // Like Android's Activity.onResume()
        print('*** ScreenVisibility.VISIBLE: ${orderType.routeName}');
        onActive(caller: 'onVisibilityChanged.VISIBLE');
        break;
      case WidgetVisibility.INVISIBLE:
        // Like Android's Activity.onPause()
        print('*** ScreenVisibility.INVISIBLE: ${orderType.routeName}');
        onInactive(caller: 'onVisibilityChanged.INVISIBLE');
        break;
      case WidgetVisibility.GONE:
        // Like Android's Activity.onDestroy()
        print('*** ScreenVisibility.GONE: ${orderType.routeName}   mounted : $mounted');
        //onInactive(caller: 'onVisibilityChanged.GONE');
        break;
    }

    super.onVisibilityChanged(visibility);
  }

  void onActive({String caller = ''}) {
    // if( !isCurrentTab() ){
    //   print(orderType.routeName + '.onActive [aborted] _active : $_active  --> caused by not not on current Tab.'  );
    //   return;
    // }
    active = true;
    print(orderType.routeName + '.onActive _active : $active  caller : $caller');
    //_startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted){
        context.read(amendChangeNotifier).mustNotifyListener();

        Stock stock = InvestrendTheme.storedData.findStock(amendData.stock_code);

        if (stock == null || !stock.isValid()) {
          print(orderType.routeName + '.doUpdate stock is NULL');
          return;
        }
        unsubscribe(context, 'onActive');
        //Stock stock = context.read(primaryStockChangeNotifier).stock;
        subscribe(context, stock, 'onActive');

        //doUpdate(pullToRefresh: true);
        doUpdateAccount(pullToRefresh: true);
        _startTimer();


      }

    });
  }

  void onInactive({String caller = ''}) {
    active = false;
    print(orderType.routeName + '.onInactive _active : $active  caller : $caller');
    _stopTimer();
    unsubscribe(context, 'onInactive');
  }


  @override
  void initState() {
    super.initState();

    resetPredefineLot = (){
      print('resetPredefineLot on text : '+fieldLotController.text);
      if (predefineLotNotifier.value != 0) {
        predefineLotNotifier.value = 0;
      }
    };
    // riverpod di initstate
    final container = ProviderContainer();
    // bug fix ketemu irwan
    // error kepanggil terus saat pencet amend keyboard masih showed, found by irwan karena di didChangeDepencies()
    container.read(amendChangeNotifier).setData(amendData);
    fieldLotController.addListener(resetPredefineLot);
    fieldLotController.addListener(calculateOrder);
    fieldPriceController.addListener(calculateOrder);
    print(orderType.routeName + '.initState');
    fieldPriceController.text = amendData.normalPriceLot.price.toString();
    fieldLotController.text = amendData.normalPriceLot.lot.toString();
    focusNodePrice = FocusNode();
    focusNodeLot = FocusNode();

    updateDataNotifier.addListener(() {
      print(orderType.routeName + '.updateDataNotifier triggered --> mounted : $mounted');
      if (mounted) {
        calculateOrder(caller: 'updateDataNotifier');
      }
    });

    // stockChangeListener = () {
    //   print(orderType.routeName + '.stockChangeListener');
    //   //final container = ProviderContainer();
    //   //Stock stock = context.read(primaryStockChangeNotifier).stock;
    //   BuySell data = context.read(amendChangeNotifier).getData(orderType);
    //   //String existingCode = context.read(amendChangeNotifier).getData(orderType).stock_code;
    //   bool isChanged = !StringUtils.equalsIgnoreCase(stock.code, data.stock_code);
    //   print(orderType.routeName+'.stockChangeListener newCode : '+stock.code+'  existingCode : '+data.stock_code+'  isChanged : $isChanged');
    //
    //   //context.read(amendChangeNotifier).setStock(stock.code, stock.name);
    //   data.setStock(stock.code, stock.name);
    //   if(isChanged){
    //     fieldPriceController.text = '';
    //     fieldLotController.text = '';
    //     context.read(amendChangeNotifier).mustNotifyListener();
    //   }
    //   if(_active){
    //     doUpdate();
    //   }
    // };

    // final container = ProviderContainer();
    // container.read(primaryStockChangeNotifier).addListener(stockChangeListener);
    predefineLotSourceNotifier.addListener(() {
      print(orderType.routeName + '.predefineLotSourceNotifier changed '+predefineLotSourceNotifier.value.toString());
      if(predefineLotNotifier.value != 0){
        fieldLotController.text = '';
      }
      //resetPredefineLot();
    });

    _startTimer();
  }

  VoidCallback clearChangeListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(orderType.routeName + '.didChangeDependencies  _active ' + active.toString());
    //Stock stock = InvestrendTheme.of(context).stock;
    Stock stock = InvestrendTheme.storedData.findStock(amendData.stock_code);
    //Stock stock = context.read(primaryStockChangeNotifier).stock;

    // error kepanggil terus saat pencet amend keyboard masih showed, found by irwan
    //context.read(amendChangeNotifier).setData(amendData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(primaryStockChangeNotifier).setStock(stock);
    });

    if (clearChangeListener == null) {
      clearChangeListener = () {
        if (!mounted) {
          print(orderType.routeName + '.clearChangeListener aborted, caused by widget mounted : ' + mounted.toString());
          return;
        }
        BuySell data = context.read(amendChangeNotifier).getData(orderType);
        data.clearOrderOnly();
        fieldPriceController.text = '';
        fieldLotController.text = '';
        context.read(amendChangeNotifier).mustNotifyListener();
      };
    }
    context.read(clearOrderChangeNotifier).addListener(clearChangeListener);
    //context.read(amendChangeNotifier).getData(orderType).setStock(stock.code, stock.name);
  }

  @override
  void dispose() {
    print(orderType.routeName + '.dispose');
    scrollController.dispose();
    final container = ProviderContainer();
    //container.read(primaryStockChangeNotifier).removeListener(stockChangeListener);
    container.read(clearOrderChangeNotifier).removeListener(clearChangeListener);
    clearChangeListener = null;

    if(subscribeSummary != null){
      container.read(managerDatafeedNotifier).unsubscribe(subscribeSummary,'dispose');
    }
    if(subscribeOrderbook != null){
      container.read(managerDatafeedNotifier).unsubscribe(subscribeOrderbook,'dispose');
    }
    if(subscribeTradebook != null){
      container.read(managerDatafeedNotifier).unsubscribe(subscribeTradebook,'dispose');
    }
    orderbookNotifier.dispose();

    //_timer?.cancel();
    //_stopTimer();
    //calculateNotifier.dispose();
    valueOrderNotifier.dispose();
    fieldPriceController.dispose();
    fieldLotController.dispose();
    focusNodeLot.dispose();
    focusNodePrice.dispose();
    predefineLotNotifier.dispose();
    predefineLotSourceNotifier.dispose();
    super.dispose();
  }

  void _startTimer() {

    if (!InvestrendTheme.DEBUG) {
      /*
      if (_timer == null || !_timer.isActive) {
        print(orderType.routeName + '._startTimer _timer');
        _timer = Timer.periodic(_durationUpdate, (timer) {
          print(orderType.routeName + ' _timer.tick : ' + _timer.tick.toString());
          if (active) {
            if (onProgress) {
              print(orderType.routeName + ' timer aborted caused by onProgress : $onProgress');
            } else {
              doUpdate();
            }
          }
        });
      }
      */

      if (_timerAccount == null || !_timerAccount.isActive) {
        print(orderType.routeName + '._startTimer _timerAccount');
        _timerAccount = Timer.periodic(_durationUpdateAccount, (timer) {
          print(orderType.routeName+' _timerAccount.tick : '+_timerAccount.tick.toString());
          if (active) {
            if(onProgressAccount){
              print(orderType.routeName+' timer aborted caused by onProgressAccount : $onProgressAccount');
            }else{
              doUpdateAccount();
            }

          }
        });
      }
    }
  }

  void _stopTimer() {
    // print(orderType.routeName + '._stopTimer');
    // if (_timer != null && _timer.isActive) {
    //   _timer.cancel();
    // }

    print(orderType.routeName + '._stopTimer _timerAccount');
    if (_timerAccount != null && _timerAccount.isActive) {
      _timerAccount.cancel();
    }
  }

  bool onProgressAccount = false;
  Future doUpdateAccount({bool pullToRefresh = false}) async {
    onProgressAccount =  false;
    return true;
  }

  bool onProgress = false;

  Future doUpdate({bool pullToRefresh = false}) async {


    if (!active || !mounted) {
      print(orderType.routeName + '.doUpdate Aborted : ' + DateTime.now().toString() + "  _active : $active  mounted : $mounted  pullToRefresh : $pullToRefresh");
      return;
    }
    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if(!isForeground){
        print(orderType.routeName + ' doUpdate ignored isForeground : $isForeground  isVisible : ' + isVisible().toString());
        return;
      }
    }

    print(orderType.routeName + '.doUpdate : ' + DateTime.now().toString() + "  _active : $active  mounted : $mounted  pullToRefresh : $pullToRefresh");
    //Stock stock = context.read(primaryStockChangeNotifier).stock;
    Stock stock = InvestrendTheme.storedData.findStock(amendData.stock_code);

    if (stock == null || !stock.isValid()) {
      print(orderType.routeName + '.doUpdate stock is NULL');
      return;
    }
    onProgress = true;
    /*
    context.read(orderDataChangeNotifier).update(
        stock_code: stock.code,
        stock_name: stock.name,
        accountType: 'Reguler',
        accountName: 'Ackerman',
        orderType: orderType,
        tradingLimitUsage: 0,
        fastMode: isFastMode());
    */
    /*
    context.read(stockSummaryChangeNotifier).setStock(stock);
    context.read(orderBookChangeNotifier).setStock(stock);
    context.read(tradeBookChangeNotifier).setStock(stock);

    final stockSummary = await HttpSSI.fetchStockSummary(stock.code, stock.defaultBoard);
    if (stockSummary != null) {
      print(orderType.routeName + ' Future Summary DATA : ' + stockSummary.code + '  prev : ' + stockSummary.prev.toString());
      //_summaryNotifier.setData(stockSummary);
      if(mounted){
        context.read(stockSummaryChangeNotifier).setData(stockSummary);
      }

    } else {
      print(orderType.routeName + ' Future Summary NO DATA');
    }
    final orderbook = await HttpSSI.fetchOrderBook(stock.code, stock.defaultBoard);
    if (orderbook != null) {
      print(orderType.routeName + ' Future Orderbook DATA : ' + orderbook.code);
      //InvestrendTheme.of(context).orderbookNotifier.setData(orderbook);
      if(mounted) {
        context.read(orderBookChangeNotifier).setData(orderbook);
      }
    } else {
      print(orderType.routeName + ' Future Orderbook NO DATA');
    }

    final tradebook = await HttpSSI.fetchTradeBook(stock.code, stock.defaultBoard);
    if (tradebook != null) {
      print(orderType.routeName + ' Future Tradebook DATA : ' + tradebook.code);
      //InvestrendTheme.of(context).tradebookNotifier.setData(tradebook);
      if(mounted) {
        context.read(tradeBookChangeNotifier).setData(tradebook);
      }
    } else {
      print(orderType.routeName + ' Future Tradebook NO DATA');
    }
     */
    onProgress = false;
    print(orderType.routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
  }

  // Widget getTextField(TextEditingController controller, Color colorForm, {String hint}) {
  //   return TextField(
  //     controller: controller,
  //     inputFormatters: [
  //       PriceFormatter(),
  //     ],
  //     maxLines: 1,
  //     style: InvestrendTheme.of(context).regular_w700.copyWith(height: null),
  //     textInputAction: TextInputAction.next,
  //     keyboardType: TextInputType.number,
  //     cursorColor: colorForm,
  //     decoration: InputDecoration(
  //       hintText: hint,
  //       border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
  //       focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorForm, width: 1.0)),
  //       focusColor: colorForm,
  //       prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
  //       hintStyle: InvestrendTheme.of(context).inputHintStyle,
  //       helperStyle: InvestrendTheme.of(context).inputHelperStyle,
  //       errorStyle: InvestrendTheme.of(context).inputErrorStyle,
  //       fillColor: Colors.grey,
  //       contentPadding: EdgeInsets.all(0.0),
  //     ),
  //     textAlign: TextAlign.end,
  //   );
  // }

  Widget createTopInfo(BuildContext context);

  Widget createForm(BuildContext context) {
    double iconSize = 20.0;

    String labelType;
    Color colorForm;
    if (orderType.isBuyOrAmendBuy()) {
      labelType = 'trade_buy_type_order_label'.tr();
      colorForm = InvestrendTheme.buyColor;
    } else {
      labelType = 'trade_sell_type_order_label'.tr();
      colorForm = InvestrendTheme.sellColor;
    }
    const double paddingLeftRight = 10.0;
    return Container(
      margin: EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
      padding: EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
      //height: 225,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: colorForm,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            //color: Colors.blue,
            //padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            padding: const EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight),
            child: Table(
              columnWidths: {
                0: FractionColumnWidth(.5),
                1: FractionColumnWidth(.1),
                2: FractionColumnWidth(.3),
                3: FractionColumnWidth(.1),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Text(labelType, style: InvestrendTheme.of(context).small_w500.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 2,
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      child: Text(
                        'Normal',
                        style: InvestrendTheme.of(context).small_w400,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    IconButton(
                        icon: Image.asset(
                          'images/icons/arrow_down.png',
                          height: iconSize,
                          width: iconSize,
                        ),
                        onPressed: () {}),
                  ],
                ),
                TableRow(
                  children: [
                    Text('trade_form_price_label'.tr(), style: InvestrendTheme.of(context).small_w500.copyWith(fontWeight: FontWeight.w600)),
                    TradeComponentCreator.minusButton(iconSize, () {
                      addOrSubstractPriceTick(-1);
                    }),
                    // IconButton(
                    //     icon: Image.asset(
                    //       'images/icons/minus.png',
                    //       height: iconSize,
                    //       width: iconSize,
                    //     ),
                    //     onPressed: () {addOrSubstractPriceTick(-1);}),
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      //child: getTextField(fieldPriceController, colorForm, hint: amendData.normalPriceLot.price.toString()),
                      child: TradeComponentCreator.textField(context, fieldPriceController, colorForm, focusNodePrice,
                          hint: amendData.normalPriceLot.price.toString(), nextFocusNode: focusNodeLot),
                    ),
                    TradeComponentCreator.plusButton(iconSize, () {
                      addOrSubstractPriceTick(1);
                    }),
                    // IconButton(
                    //     icon: Image.asset(
                    //       'images/icons/plus.png',
                    //       height: iconSize,
                    //       width: iconSize,
                    //     ),
                    //     onPressed: () {addOrSubstractPriceTick(1);}),
                  ],
                ),
                TableRow(
                  children: [
                    Text('trade_form_lot_label'.tr(), style: InvestrendTheme.of(context).small_w500.copyWith(fontWeight: FontWeight.w600)),
                    TradeComponentCreator.minusButton(iconSize, () {
                      addOrSubstractLot(-1);
                    }),
                    // IconButton(
                    //     icon: Image.asset(
                    //       'images/icons/minus.png',
                    //       height: iconSize,
                    //       width: iconSize,
                    //     ),
                    //     onPressed: () {addOrSubstractLot(-1);}),
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      //child: getTextField(fieldLotController, colorForm, hint: amendData.normalPriceLot.lot.toString()),
                      child: TradeComponentCreator.textField(context, fieldLotController, colorForm, focusNodeLot,
                          hint: amendData.normalPriceLot.lot.toString()),
                    ),
                    TradeComponentCreator.plusButton(iconSize, () {
                      addOrSubstractLot(1);
                    }),
                    // IconButton(
                    //     icon: Image.asset(
                    //       'images/icons/plus.png',
                    //       height: iconSize,
                    //       width: iconSize,
                    //     ),
                    //     onPressed: () {addOrSubstractLot(1);}),
                  ],
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: predefineLotNotifier,
            builder: (context, int value, child) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        predefineButton(5),
                        predefineButton(10),
                        predefineButton(25),
                        predefineButton(50),
                        predefineButton(75),
                        predefineButton(100),
                      ],
                    ),
                    (value > 0 && orderType.isBuyOrAmendBuy()) ?
                    ValueListenableBuilder(
                      valueListenable: predefineLotSourceNotifier,
                      builder: (context, valueSource, child) {

                        //#PERCENT#% of your #VALUE#
                        String text = 'predefine_lot_by_text'.tr();
                        text = text.replaceFirst("#VALUE#", valueSource);
                        text = text.replaceFirst("#PERCENT#", value.toString());
                        //AlignmentGeometry textAlign = StringUtils.equalsIgnoreCase(valueSource, 'trade_buy_label_buying_power'.tr()) ? Alignment.centerLeft : Alignment.centerRight;
                        return Text(text,
                          style: InvestrendTheme.of(context).support_w500_compact.copyWith(color: InvestrendTheme.of(context).investrendPurpleText),

                        );
                      },
                    )
                        : SizedBox(width: 1.0,),
                  ],
                ),
              );
            },
          ),
          /*
          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '25%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '50%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '75%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '100%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
              ],
            ),
          ),
          */
          ComponentCreator.divider(context),
          Padding(
            padding: const EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight),
            child: Row(
              children: [
                Text(
                  'trade_form_total_label'.tr(),
                  style: InvestrendTheme.of(context).small_w600,
                ),
                Expanded(
                  flex: 1,
                  child: ValueListenableBuilder(
                    valueListenable: valueOrderNotifier,
                    builder: (context, int value, child) {
                      String totalValueText = InvestrendTheme.formatMoney(value, prefixRp: true);
                      return Text(
                        totalValueText,
                        style: InvestrendTheme.of(context).regular_w600,
                        textAlign: TextAlign.end,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: InvestrendTheme.cardMargin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _normalMode() {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: orderType.color,
      onRefresh: onRefresh,
      child: ListView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          createTopInfo(context),
          accelerationLabel(context),
          createForm(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),


          CardOrderbook(orderbookNotifier, 10,owner: orderType.routeName, onTap: onTapOrderbook,),
          /*
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitle(context, 'trade_title_order_book'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            child: WidgetOrderbook(
              10,
              owner: orderType.routeName,
            ),
          ),
          */
          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitle(context, 'trade_title_trade_book'.tr()),
          ),
          WidgetTradebook(),
          SizedBox(
            height: 90.0,
          ),
        ],
      ),
    );

    /*
    return SingleChildScrollView(
      //key: _normalKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   height: 5.0,
          // ),
          //createMoneyInfo(context),
          //createStockInfo(context),
          createTopInfo(context),

          //createFormSell(context),
          createForm(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitle(context, 'trade_title_order_book'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            //color: Colors.yellow,
            //child: WidgetOrderbook(InvestrendTheme.of(context).orderbookNotifier, 10),
            child: WidgetOrderbook(
              10,
              owner: orderType.routeName,
            ),
          ),
          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitle(context, 'trade_title_trade_book'.tr()),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(
          //       left: InvestrendTheme.cardPaddingPlusMargin,
          //       right: InvestrendTheme.cardPaddingPlusMargin,
          //       top: InvestrendTheme.cardPadding,
          //       bottom: InvestrendTheme.cardPadding),
          //   //child: WidgetTradebook(InvestrendTheme.of(context).tradebookNotifier),
          //   child: WidgetTradebook(),
          // ),
          WidgetTradebook(),
          SizedBox(
            height: 90.0,
          ),
        ],
      ),
    );
    */
  }
  void onTapOrderbook(TypeOrderbook type, TypeField field, PriceLotQueue data){
    print('onTapOrderbook  '+type.text+'  '+field.text+'  '+data.toString());
    if(field == TypeField.Price){
      OrderType orderType = OrderType.Buy;
      fieldPriceController.text = InvestrendTheme.formatComma(data.price);
      scrollController.animateTo(0.0,duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuint);
    }else if (field == TypeField.Queue) {
      if(data.queue > 0){
        Stock stock = context.read(primaryStockChangeNotifier).stock;
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenOrderQueue(stock.code, stock.defaultBoard, type.text, data.price),
              settings: RouteSettings(name: '/order_queue'),
            ));
      }
    }
  }
  Widget predefineButton(int percentValue) {
    Color color = InvestrendTheme.of(context).support_w400.color;
    if (percentValue == predefineLotNotifier.value) {
      color = Theme.of(context).colorScheme.secondary;
    }
    return TextButton(
        style: ButtonStyle(visualDensity: VisualDensity.compact),
        onPressed: () {
          predefineLot(percentValue);
        },
        child: Text(
          '$percentValue%',
          style: InvestrendTheme.of(context).support_w600.copyWith(color: color),
        ));
  }

  void predefineLot(int percentage) {
    fieldLotController.removeListener(resetPredefineLot);
    predefineLotNotifier.value = percentage;

    if (orderType.isBuyOrAmendBuy()) {
      print('predefineLot ' + orderType.text + '  $percentage %   availableMoney : belum');
      int price = Utils.safeInt(fieldPriceController.text.replaceAll(',', ''));
      double buyingPower = context.read(buyRdnBuyingPowerChangeNotifier).buyingPower;
      double cashAvailable = context.read(buyRdnBuyingPowerChangeNotifier).cashAvailable;
      //double feeBuy = 0.02;
      double feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
      Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
      if (activeAccount != null) {
        feeBuy = activeAccount.commission;
      }



      if(price <= 0){
        InvestrendTheme.of(context).showSnackBar(context, 'predefine_price_error_text'.tr());
        focusNodePrice.requestFocus();
        predefineLotNotifier.value = 0;
        return;
      }
      double usedValue = 0.0;
      if(StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value, 'trade_buy_label_buying_power'.tr())){
        usedValue = buyingPower;
      }else if(StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value, 'cash_available_label'.tr())){
        usedValue = cashAvailable;
      }

      if(buyingPower <= 0 && StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value, 'trade_buy_label_buying_power'.tr())){
        String error = 'predefine_data_error_text'.tr();
        error = error.replaceFirst("#VALUE#", predefineLotSourceNotifier.value);
        InvestrendTheme.of(context).showSnackBar(context,
            //'Please wait for buyingPower first.'
            error
        );
        focusNodePrice.requestFocus();
        predefineLotNotifier.value = 0;
        return;
      }

      if(cashAvailable <= 0 && StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value, 'cash_available_label'.tr())){
        String error = 'predefine_data_error_text'.tr();
        error = error.replaceFirst("#VALUE#", predefineLotSourceNotifier.value);
        InvestrendTheme.of(context).showSnackBar(context,
            //'Please wait for buyingPower first.'
            error
        );
        focusNodePrice.requestFocus();
        predefineLotNotifier.value = 0;
        return;
      }

      //if (price > 0 && buyingPower > 0) {
      if (price > 0 && usedValue > 0) {
        print('predefineLot ' + orderType.text + '  usedValue : $usedValue  price : $price  feeBuy : $feeBuy');
        //int lot = ((buyingPower * (percentage / 100)) / (price * 100 * (1.0 + (feeBuy / 100)))).toInt();
        int lot = (usedValue * (percentage / 100)) ~/ (price * 100 * (1.0 + (feeBuy / 100)));

        //int value = price * lot * fee;
        //lot = value / price / fee
        print('predefineLot ' + orderType.text + '  result lot : $lot');
        fieldLotController.text = InvestrendTheme.formatComma(lot);
        focusNodeLot.unfocus();
      } else {
        //InvestrendTheme.of(context).showSnackBar(context, 'Please fill price first.');
        InvestrendTheme.of(context).showSnackBar(context, 'predefine_price_error_text'.tr());
        focusNodePrice.requestFocus();
        predefineLotNotifier.value = 0;
      }
    } else {
      int availableLot = context.read(sellLotAvgChangeNotifier).lot;

      print('predefineLot ' + orderType.text + '  $percentage %   availableLot : $availableLot');
      int lot = 0;
      if (availableLot > 0 && percentage > 0) {
        if (percentage == 100) {
          lot = availableLot;
        } else {
          lot = ((percentage / 100) * availableLot).toInt();
        }
      }
      print('predefineLot ' + orderType.text + '  result lot : $lot');
      fieldLotController.text = InvestrendTheme.formatComma(lot);
      focusNodeLot.unfocus();
    }
    fieldLotController.addListener(resetPredefineLot);
  }

  void addOrSubstractLot(int step) {
    String lottext = fieldLotController.text;

    lottext = lottext.replaceAll(',', '');
    int lot = Utils.safeInt(lottext);
    lot += step;
    if (lot < 0) {
      lot = 0;
    }
    fieldLotController.text = lot.toString();
    //focusNodeLot.requestFocus();
    focusNodeLot.unfocus();
    if (predefineLotNotifier.value != 0) {
      predefineLotNotifier.value = 0;
    }
  }

  int priceTickUp(int price) {
    int tick = 1;
    if (price >= 5000) {
      tick = 25;
    } else if (price >= 2000) {
      tick = 10;
    } else if (price >= 500) {
      tick = 5;
    } else if (price >= 200) {
      tick = 2;
    } else {
      tick = 1;
    }
    return tick;
  }

  int priceTickDown(int price) {
    int tick = 1;
    if (price > 5000) {
      tick = 25;
    } else if (price > 2000) {
      tick = 10;
    } else if (price > 500) {
      tick = 5;
    } else if (price > 200) {
      tick = 2;
    } else {
      tick = 1;
    }
    return tick;
  }

  void addOrSubstractPriceTick(int addSubtick) {
    String pricetext = fieldPriceController.text;
    pricetext = pricetext.replaceAll(',', '');
    int price = Utils.safeInt(pricetext);
    int newPrice = price;
    int tick = addSubtick > 0 ? priceTickUp(price) : priceTickDown(price);
    int precised = price % tick;
    print('addOrSubstractPriceTick addSubtick $addSubtick   price : $price  tick : $tick  precised : $precised');
    if (precised == 0) {
      int tickPrice = tick * addSubtick;
      newPrice += tickPrice;
    } else {
      int hasilBagi = (price ~/ tick);
      newPrice = hasilBagi * tick;
      if (addSubtick > 0) {
        newPrice = newPrice + tick;
      }
    }
    print('addOrSubstractPriceTick addSubtick $addSubtick   price : $price  newPrice : $newPrice');
    if (newPrice < 0) {
      newPrice = 0;
      fieldPriceController.text = newPrice.toString();
    } else {
      fieldPriceController.text = InvestrendTheme.formatComma(newPrice);
    }

    //focusNodePrice.requestFocus();
    focusNodePrice.unfocus();
  }

  bool isActiveAndMounted(){
    return active && mounted;
  }
  
  Future onRefresh() {
    unsubscribe(context,'onRefresh');
    Stock stock = context.read(primaryStockChangeNotifier).stock;
    subscribe(context, stock,'onRefresh');

    return doUpdateAccount(pullToRefresh: true);
    //return doUpdate(pullToRefresh: true);
  }

  Widget getIndicator(Color color) {
    return Container(
      color: color,
      height: 2.0,
      width: 60,
    );
  }
  Widget accelerationLabel(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(primaryStockChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }
      if (notifier.stock.isAccelerationBoard()) {
        return Container(
          margin: const EdgeInsets.only(top: InvestrendTheme.cardPadding,),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
          width: double.maxFinite,
          color: InvestrendTheme.of(context).tileBackground,
          child: Text(
            'stock_detail_overview_card_detail_special_notation'.tr(),
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).investrendPurple),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        return SizedBox(
          width: 1.0,
          height: 1.0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _normalMode();
    /*
    return ScreenAware(
      routeName: orderType.routeName,
      onActive: onActive,
      onInactive: onInactive,
      child: _normalMode(),
    );

     */
  }

  void calculateOrder({String caller = ''}) {
    print(orderType.routeName + '.calculateOrder  caller : $caller');

    String scrappedPrice = fieldPriceController.text.replaceAll(',', '');
    int price = Utils.safeInt(scrappedPrice);

    String scrappedLot = fieldLotController.text.replaceAll(',', '');
    int lot = Utils.safeInt(scrappedLot);

    int value = price * lot * 100;

    print(orderType.routeName +
        '.calculateOrder Price : ' +
        fieldPriceController.text +
        '   Lot : ' +
        fieldLotController.text +
        '  value : $value');

    // batasin lot kalo sell, cuma kalo Loop ga dibatasin.
    if(orderType.isSellOrAmendSell() ){
      final lotAverage = context.read(sellLotAvgChangeNotifier);
      int maxLot = lotAverage.lot + amendData.normalPriceLot.lot;
      if(lot > maxLot ){
        //fieldLotController.text = InvestrendTheme.formatComma(lotAverage.lot);
        fieldLotController.text = InvestrendTheme.formatComma(maxLot);
        fieldLotController.selection = TextSelection(baseOffset: fieldLotController.text.length, extentOffset: fieldLotController.text.length);
        //lot = lotAverage.lot;
        lot = maxLot;
        value = price * lot * 100 ;
      }
    }

    double feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
    Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
    if (activeAccount != null) {
      feeBuy = activeAccount.commission;
    }
    if (orderType.isBuyOrAmendBuy() && feeBuy > 0) {
      value = (value * (1.0 + (feeBuy / 100))).toInt();
    }

    valueOrderNotifier.value = value;

    BuySell data = context.read(amendChangeNotifier).getData(orderType);
    //data.setNormalPriceLot(price, lot);
    data.setNormalPriceLot(price, lot, totalValue: value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(amendChangeNotifier).mustNotifyListener();
    });

    // bool notifyParent = calculateNotifier.canNormalModeCalculate(orderType);
    // print('calculateOrder BUY notifyParent : $notifyParent  ' + calculateNotifier.toString());
    // if (notifyParent) {
    //   context.read(orderDataChangeNotifier).update(orderType: orderType, lot: lot, price: price, value: value);
    // }
  }


  SubscribeAndHGET subscribeSummary;
  SubscribeAndHGET subscribeOrderbook;
  SubscribeAndHGET subscribeTradebook;
  void unsubscribe(BuildContext context, String caller){
    if(subscribeSummary != null){
      print(orderType.routeName+' unsubscribe Summary : '+subscribeSummary.channel);
      context.read(managerDatafeedNotifier).unsubscribe(subscribeSummary, orderType.routeName+'.'+caller);
      subscribeSummary = null;
    }

    if(subscribeOrderbook != null){
      print(orderType.routeName+' unsubscribe Orderbook : '+subscribeOrderbook.channel);
      context.read(managerDatafeedNotifier).unsubscribe(subscribeOrderbook, orderType.routeName+'.'+caller);
      subscribeOrderbook = null;
    }

    if(subscribeTradebook != null){
      print(orderType.routeName+' unsubscribe Tradebook : '+subscribeTradebook.channel);
      context.read(managerDatafeedNotifier).unsubscribe(subscribeTradebook, orderType.routeName+'.'+caller);
      subscribeTradebook = null;
    }
  }
  void subscribe(BuildContext context, Stock stock, String caller){
    String codeBoard = stock.code+'.'+stock.defaultBoard;

    String channelSummary = DatafeedType.Summary.key+'.'+codeBoard;
    context.read(stockSummaryChangeNotifier).setStock(stock);
    subscribeSummary = SubscribeAndHGET(channelSummary, DatafeedType.Summary.collection, codeBoard,listener: (message){
      print(channelSummary+' got : '+message.elementAt(1));
      print(message);
      if(mounted){
        StockSummary stockSummary = StockSummary.fromStreaming(message);
        FundamentalCache cache = context.read(fundamentalCacheNotifier).getCache(stockSummary.code);
        stockSummary.updateCache(context, cache);
        context.read(stockSummaryChangeNotifier).setData(stockSummary, check: true);
      }

    }, validator: validatorSummary);
    print(orderType.routeName+' subscribe Summary : $codeBoard');
    context.read(managerDatafeedNotifier).subscribe(subscribeSummary, orderType.routeName+'.'+caller);


    String channelOrderbook = DatafeedType.Orderbook.key+'.'+codeBoard;
    context.read(orderBookChangeNotifier).setStock(stock);
    subscribeOrderbook = SubscribeAndHGET(channelOrderbook, DatafeedType.Orderbook.collection, codeBoard,listener: (message){
      print(orderType.routeName+' got : '+message.elementAt(1));
      DebugWriter.info(message);

      OrderBook orderbook = OrderBook.fromStreaming(message);
      if (mounted) {
        DebugWriter.info('got orderbook --> '+orderbook.toString());
        orderbook.generateDataForUI(10, context: context);

        context.read(orderBookChangeNotifier).setData(orderbook);
        StockSummary stockSummary = context.read(stockSummaryChangeNotifier).summary;
        OrderbookData orderbookData = OrderbookData();
        orderbookData.orderbook = orderbook;
        orderbookData.prev = stockSummary != null ? stockSummary.prev : 0;
        orderbookData.close = stockSummary != null ? stockSummary.close : 0;
        orderbookData.averagePrice = stockSummary != null ? stockSummary.averagePrice : 0;
        orderbookNotifier.setValue(orderbookData);
        print('got orderbook --> notify');
      }

    }, validator: validatorOrderbook);
    print(orderType.routeName+' subscribe Orderbook : $codeBoard');
    context.read(managerDatafeedNotifier).subscribe(subscribeOrderbook, orderType.routeName+'.'+caller);


    String channelTradebook = DatafeedType.Tradebook.key+'.'+codeBoard;
    context.read(tradeBookChangeNotifier).setStock(stock);
    subscribeTradebook = SubscribeAndHGET(channelTradebook, DatafeedType.Tradebook.collection, codeBoard,listener: (message){
      print(orderType.routeName+' got : '+message.elementAt(1));
      DebugWriter.info(message);

      TradeBook tradebook = TradeBook.fromStreaming(message);
      if (mounted) {
        DebugWriter.info('got tradebook --> '+tradebook.toString());
        // orderbook.generateDataForUI(10, context: context);
        //
        // context.read(orderBookChangeNotifier).setData(orderbook);
        // StockSummary stockSummary = context.read(stockSummaryChangeNotifier).summary;
        // OrderbookData orderbookData = OrderbookData();
        // orderbookData.orderbook = orderbook;
        // orderbookData.prev = stockSummary != null ? stockSummary.prev : 0;
        // orderbookData.close = stockSummary != null ? stockSummary.close : 0;
        // orderbookNotifier.setValue(orderbookData);
        context.read(tradeBookChangeNotifier).setData(tradebook);
        print('got tradebook --> notify');
      }

    }, validator: validatorTradebook);
    print(orderType.routeName+' subscribe Tradebook : $codeBoard');
    context.read(managerDatafeedNotifier).subscribe(subscribeTradebook, orderType.routeName+'.'+caller);
  }
  bool validatorOrderbook(List<String> data, String channel){
    //List<String> data = message.split('|');
    if(data != null && data.length > 5 /* && data.first == 'III' && data.elementAt(1) == 'Q'*/){
      final String HEADER       = data[0];
      final String type         = data[1];
      final String start 	      = data[2];
      final String end 		      = data[3];
      final String stockCode    = data[4];
      final String boardCode    = data[5];

      String codeBoard = stockCode+'.'+boardCode;
      String channelData = DatafeedType.Orderbook.key+'.'+codeBoard;
      if(HEADER == 'III' && type == DatafeedType.Orderbook.type && channel == channelData){
        return true;
      }
    }
    return false;
  }
  bool validatorTradebook(List<String> data, String channel){
    //List<String> data = message.split('|');
    if(data != null && data.length > 5 /* && data.first == 'III' && data.elementAt(1) == 'Q'*/){
      final String HEADER       = data[0];
      final String type         = data[1];
      final String start 	      = data[2];
      final String end 		      = data[3];
      final String stockCode    = data[4];
      final String boardCode    = data[5];


      String codeBoard = stockCode+'.'+boardCode;
      String channelData = DatafeedType.Tradebook.key+'.'+codeBoard;
      if(HEADER == 'III' && type == DatafeedType.Tradebook.type && channel == channelData){
        return true;
      }
    }
    return false;
  }
  bool validatorSummary(List<String> data, String channel){
    //List<String> data = message.split('|');
    if(data != null && data.length > 5 /* && data.first == 'III' && data.elementAt(1) == 'Q'*/){
      final String HEADER       = data[0];
      final String typeSummary = data[1];
      final String start 	      = data[2];
      final String end 		      = data[3];
      final String stockCode    = data[4];
      final String boardCode    = data[5];
      String codeBoard = stockCode+'.'+boardCode;
      String channelData = DatafeedType.Summary.key+'.'+codeBoard;
      if(HEADER == 'III' && typeSummary == DatafeedType.Summary.type && channel == channelData){
        return true;
      }
    }
    return false;
  }
}
//
// class ScreenTradeForm extends StatefulWidget {
//   final OrderType orderType;
//   final ValueNotifier<bool> _fastModeNotifier;
//   final TabController _tabController;
//
//   const ScreenTradeForm(this.orderType, this._fastModeNotifier, this._tabController, {Key key}) : super(key: key);
//
//   @override
//   _ScreenTradeFormState createState() => _ScreenTradeFormState(orderType,_fastModeNotifier,_tabController);
// }
//
//
// class _ScreenTradeFormState extends BaseTradeState<ScreenTradeForm> {
//
//   _ScreenTradeFormState(OrderType orderType, ValueNotifier<bool> fastModeNotifier, TabController tabController) : super(orderType, fastModeNotifier, tabController);
//   Key fastKey = UniqueKey();
//   Key normalKey = UniqueKey();
//   bool active = false;
//
//   void onActive() {
//
//   }
//   void onInactive() {
//
//   }
//
//   VoidCallback stockChangeListener;
//
//   @override
//   void initState() {
//     super.initState();
//     stockChangeListener = (){
//
//     };
//     final container = ProviderContainer();
//     container.read(primaryStockChangeNotifier).addListener(stockChangeListener);
//   }
//   @override
//   void dispose() {
//     final container = ProviderContainer();
//     container.read(primaryStockChangeNotifier).removeListener(stockChangeListener);
//
//     super.dispose();
//   }
//
//   Widget _normalMode(){
//
//   }
//   Widget _fastMode(){
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return ScreenAware(
//       routeName: orderType.routeName,
//       onActive: onActive,
//       onInactive: onInactive,
//       child: AnimatedCrossFade(
//         duration: const Duration(milliseconds: 800),
//         firstChild: _normalMode(),
//         secondChild: _fastMode(),
//         crossFadeState: fastModeNotifier.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//         firstCurve: Curves.easeOut,
//         secondCurve: Curves.easeIn,
//       ),
//     );
//   }
// }
