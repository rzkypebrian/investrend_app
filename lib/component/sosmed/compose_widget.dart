// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:Investrend/component/button_tab_switch.dart';
import 'package:Investrend/component/cards/card_social_media.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/tab_community/screen_create_post.dart';
import 'package:Investrend/screens/tab_portfolio/component/bottom_sheet_list.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComposeActivityBuyWidget extends StatelessWidget {
  final VoidCallback? onDelete;
  final BuySell? orderData;

  const ComposeActivityBuyWidget(this.orderData, {this.onDelete, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onDelete,
          icon: Image.asset('images/icons/delete_circle.png'),
          visualDensity: VisualDensity.compact,
          padding:
              EdgeInsets.only(left: 1.0, bottom: 1.0, top: 1.0, right: 1.0),
        ),
        ActivityWidget(
            orderData!.isBuy() ? ActivityType.Invested : ActivityType.Unknown,
            orderData?.stock_code,
            ''),
        SizedBox(
          height: 30.0,
        ),
        Text(
          'sosmed_activity_information'.tr(),
          textAlign: TextAlign.end,
          style: InvestrendTheme.of(context).more_support_w400?.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
      ],
    );
  }
}

class ComposeActivitySellWidget extends StatefulWidget {
  final VoidCallback? onDelete;
  final BuySell? orderData;

  StateActivityTransaction stateTransaction;
  ComposeActivitySellWidget(this.stateTransaction, this.orderData,
      {this.onDelete, Key? key})
      : super(key: key);

  @override
  _ComposeActivitySellWidgetState createState() =>
      _ComposeActivitySellWidgetState();
}

class _ComposeActivitySellWidgetState extends State<ComposeActivitySellWidget> {
  //final int startPrice;
  double activityPercent = 0.0;
  ActivityType? activityType;
  ValueNotifier<int> _averagePriceNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _averagePriceNotifier.addListener(() {
      widget.stateTransaction.averagePrice = _averagePriceNotifier.value;
      if (_averagePriceNotifier.value != IntFlag.error_value ||
          _averagePriceNotifier.value != IntFlag.loading_value) {
        updateParameter();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      retrieveCostFromPortfolio();
    });
  }

  void updateParameter({int? cost}) {
    int buyPrice = cost ?? widget.stateTransaction.averagePrice;
    int? sellPrice = widget.orderData?.normalPriceLot?.price;
    int change = sellPrice! - buyPrice;
    activityPercent = Utils.calculatePercent(buyPrice, sellPrice);

    if (widget.orderData!.isSell()) {
      if (change > 0) {
        activityType = ActivityType.Gain;
      } else if (change < 0) {
        activityType = ActivityType.Loss;
      } else {
        activityType = ActivityType.NoChange;
      }
    } else {
      activityType = ActivityType.Unknown;
    }
  }

  void retrieveCostFromPortfolio() async {
    try {
      _averagePriceNotifier.value = IntFlag.loading_value;
      print('ComposeActivityWidget try retrieveCostFromPortfolio');
      final StockPosition? stockPosition = await InvestrendTheme.tradingHttp
          .stock_position(
              widget.orderData?.brokerCode,
              widget.orderData?.accountCode,
              context.read(dataHolderChangeNotifier).user.username!,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
      // DebugWriter.information('ComposeActivityWidget  Got stockPosition ' +
      //     stockPosition.accountcode! +
      //     '   stockList.size : ' +
      //     stockPosition.stockListSize().toString());
      if (stockPosition == null) {
        _averagePriceNotifier.value = IntFlag.error_value;
      } else {
        int averagePrice = 0;
        for (int i = 0; i < stockPosition.stockListSize(); i++) {
          StockPositionDetail? detail = stockPosition.stocksList?.elementAt(i);
          if (detail != null &&
              StringUtils.equalsIgnoreCase(
                  detail.stockCode, widget.orderData?.stock_code)) {
            averagePrice = detail.avgPrice.toInt();
            break;
          }
        }
        updateParameter(cost: averagePrice);
        _averagePriceNotifier.value = averagePrice;
      }
      //_stockPositionNotifier.setValue(stockPosition);
    } catch (e) {
      DebugWriter.information(
          'ComposeActivityWidget stockPosition Exception : ' + e.toString());
      _averagePriceNotifier.value = IntFlag.error_value;
      /*
      if(e is TradingHttpException){
        if(e.isUnauthorized()){
          InvestrendTheme.of(context).showDialogInvalidSession(context);
          return;
        }else{
          String network_error_label = 'network_error_label'.tr();
          network_error_label  = network_error_label.replaceFirst("#CODE#", e.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, network_error_label);
          return;
        }
      }
      */
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
          InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
          return;
        }
      } else {
        InvestrendTheme.of(context).showSnackBar(context, e.toString());
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          onPressed: widget.onDelete,
          icon: Image.asset('images/icons/delete_circle.png'),
          visualDensity: VisualDensity.compact,
          padding:
              EdgeInsets.only(left: 1.0, bottom: 1.0, top: 1.0, right: 1.0),
        ),
        ValueListenableBuilder<int>(
            valueListenable: _averagePriceNotifier,
            builder: (context, avgPrice, child) {
              if (avgPrice == IntFlag.error_value) {
                return TextButton(
                    onPressed: () {
                      retrieveCostFromPortfolio();
                    },
                    child: Text(
                      'button_retry'.tr(),
                      style: InvestrendTheme.of(context)
                          .more_support_w600_compact
                          ?.copyWith(color: Colors.red),
                    ));
              } else if (avgPrice == IntFlag.loading_value) {
                return CircularProgressIndicator();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ActivityWidget(activityType!, widget.orderData?.stock_code,
                      InvestrendTheme.formatPercent(activityPercent)),
                  SizedBox(
                    height: 12.0,
                  ),
                  RichText(
                      text: TextSpan(
                          text: 'sosmed_label_average_price'.tr(),
                          style: InvestrendTheme.of(context)
                              .more_support_w400
                              ?.copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyLighterTextColor),
                          children: [
                        TextSpan(
                          text: '   ' +
                              InvestrendTheme.formatMoney(avgPrice,
                                  prefixRp: true),
                          style: InvestrendTheme.of(context)
                              .more_support_w400
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ])),
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    'sosmed_activity_information'.tr(),
                    textAlign: TextAlign.end,
                    style: InvestrendTheme.of(context)
                        .more_support_w400
                        ?.copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor),
                  ),
                ],
              );
            }),
      ],
    );
  }
}

class ComposePredictionWidget extends StatefulWidget {
  final VoidCallback? onDelete;
  final StateComposePrediction state_prediction;

  const ComposePredictionWidget(this.state_prediction,
      {this.onDelete, Key? key})
      : super(key: key);

  @override
  _ComposePredictionWidgetState createState() =>
      _ComposePredictionWidgetState();
}

class _ComposePredictionWidgetState extends State<ComposePredictionWidget> {
  TextEditingController controllerCode = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  FocusNode priceFocusNode = FocusNode();
  FocusNode codeFocusNode = FocusNode();
  ValueNotifier<int>? _buttonOrdersNotifier; // = ValueNotifier<int>(0);
  ValueNotifier<int> _marketPriceNotifier = ValueNotifier<int>(0);
  final Key keyCode = UniqueKey();
  final Key keyPrice = UniqueKey();
  final List<String> button_orders = [
    'button_buy'.tr(),
    'button_sell'.tr(),
  ];
  List<String> timingOptions = [
    'sosmed_label_polling_1_week'.tr(),
    'sosmed_label_polling_1_month'.tr(),
    'sosmed_label_polling_3_month'.tr(),
    'sosmed_label_polling_6_month'.tr(),
    'sosmed_label_polling_1_year'.tr(),
  ];
  ValueNotifier<int>? timingNotifier; // = ValueNotifier<int>(1);
  final double padding = 12.0;

  @override
  void dispose() {
    _marketPriceNotifier.dispose();
    _buttonOrdersNotifier?.dispose();
    priceFocusNode.dispose();
    codeFocusNode.dispose();
    timingNotifier?.dispose();
    controllerCode.dispose();
    controllerPrice.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    codeFocusNode.addListener(() {
      if (!codeFocusNode.hasFocus
          //&& priceFocusNode.hasFocus
          ) {
        validateStockCode();
      }
    });
    timingNotifier = ValueNotifier<int>(1);
    updateExpireAt();
    _buttonOrdersNotifier = ValueNotifier<int>(0);
    updateTransactionType();
    controllerCode.addListener(() {
      bool changed = !StringUtils.equalsIgnoreCase(
          widget.state_prediction.code, controllerCode.text);
      widget.state_prediction.code = controllerCode.text;
      if (changed) {
        _marketPriceNotifier.value = 0;
      }
    });
    controllerPrice.addListener(() {
      widget.state_prediction.target_price =
          Utils.safeInt(controllerPrice.text);
    });
    _buttonOrdersNotifier?.addListener(() {
      updateTransactionType();
    });

    timingNotifier?.addListener(() {
      updateExpireAt();
    });
    _marketPriceNotifier.addListener(({int startPrice = 0}) {
      if (_marketPriceNotifier.value == IntFlag.loading_value ||
          _marketPriceNotifier.value == IntFlag.error_value) {
        startPrice = 0;
      } else {
        startPrice = _marketPriceNotifier.value;
      }
      widget.state_prediction.start_price = _marketPriceNotifier.value;
    });
  }

  void updateTransactionType() {
    if (_buttonOrdersNotifier?.value == 0) {
      widget.state_prediction.transaction_type = 'BUY';
    } else if (_buttonOrdersNotifier?.value == 1) {
      widget.state_prediction.transaction_type = 'SELL';
    } else {
      widget.state_prediction.transaction_type = '?';
    }
  }

  void updateExpireAt() {
    //String expire_at = '';
    // 'sosmed_label_polling_1_week'.tr(),  0
    // 'sosmed_label_polling_1_month'.tr(), 1
    // 'sosmed_label_polling_3_month'.tr(), 2
    // 'sosmed_label_polling_6_month'.tr(), 3
    // 'sosmed_label_polling_1_year'.tr(),  4
    DateTime now = DateTime.now().toUtc();
    DateTime expiredAt;
    int? index = timingNotifier?.value;
    if (index == 0) {
      expiredAt = new DateTime.utc(now.year, now.month, now.day + 7, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 1) {
      expiredAt = new DateTime.utc(now.year, now.month + 1, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 2) {
      expiredAt = new DateTime.utc(now.year, now.month + 3, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 3) {
      expiredAt = new DateTime.utc(now.year, now.month + 6, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 4) {
      expiredAt = new DateTime.utc(now.year + 1, now.month, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else {
      expiredAt = new DateTime.utc(now.year, now.month + 1, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    }
    print('now : ' + now.toString());
    print('expired_at : ' + expiredAt.toString());
    widget.state_prediction.expire_at = Utils.formatDate(expiredAt);
    print('state_prediction.expired_at : ' + widget.state_prediction.expire_at);
  }

  void validateStockCode() {
    String code = controllerCode.text.trim();
    Stock? stock = InvestrendTheme.storedData?.findStock(code);
    if (stock != null) {
      controllerCode.text = stock.code!;
      _marketPriceNotifier.value = IntFlag.loading_value;
      final stockSummary = InvestrendTheme.datafeedHttp
          .fetchStockSummary(stock.code, stock.defaultBoard);
      stockSummary.then((summary) {
        if (summary != null) {
          print('Result Summary DATA : ' + stockSummary.toString());
          //_summaryNotifier.setData(stockSummary);
          //context.read(stockSummaryChangeNotifier).setData(stockSummary);
          if (StringUtils.equalsIgnoreCase(
              controllerCode.text, summary.code!)) {
            _marketPriceNotifier.value = summary.close!;
          } else {
            print(
                'Result Summary no longer valid for code: $controllerCode.text --> receive : ' +
                    summary.code!);
            //_marketPriceNotifier.value = 0;
          }
        } else {
          print('Result Summary NO DATA for : $code');
          _marketPriceNotifier.value = IntFlag.error_value;
        }
      }).onError((error, stackTrace) {
        _marketPriceNotifier.value = IntFlag.error_value;
      });
    } else {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'sosmed_label_invalid_stock'.tr());
      _marketPriceNotifier.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controllerCode.text = '';
        codeFocusNode.requestFocus();
      });
    }
  }

  // final int error_value = 9999999;
  // final int loading_value = 8888888;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(top: padding, bottom: 8.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFFBDBDBD),
            width: 0.5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 8.0,
              ),
              Expanded(
                  child: ButtonTabSwitch(
                button_orders,
                _buttonOrdersNotifier,
                paddingButton: EdgeInsets.all(1.0),
                minWidthButton: 65.0,
              )),
              IconButton(
                onPressed: widget.onDelete,
                icon: Image.asset('images/icons/delete_circle.png'),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.only(
                    left: 1.0, bottom: 1.0, top: 1.0, right: 1.0),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: padding, right: padding),
            child: TextFieldCounter(
              controllerCode,
              hint: 'sosmed_label_stock_code'.tr(),
              key: keyCode,
              showCounter: false,
              nextFocusNode: priceFocusNode,
              focusNode: codeFocusNode,
              onEditingComplete: validateStockCode,
              /*
              onEditingComplete: (){
                print('onEditingComplete : '+controllerCode.text);
                String code = controllerCode.text.trim();
                Stock stock = InvestrendTheme.storedData.findStock(code);
                if(stock != null){
                  controllerCode.text = stock?.code;
                }else{
                 InvestrendTheme.of(context).showSnackBar(context, 'sosmed_label_invalid_stock'.tr());
                 WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                   controllerCode.text = '';
                   codeFocusNode.requestFocus();
                 });
                }
              },
              */
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: padding, right: padding),
            child: TextFieldCounter(
              controllerPrice,
              hint: 'sosmed_label_price'.tr(),
              key: keyPrice,
              prefix: 'Rp  ',
              showCounter: false,
              keyboardType: TextInputType.number,
              focusNode: priceFocusNode,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 1.0, bottom: 4.0),
            child: ComponentCreator.divider(context),
          ),
          Padding(
            padding: EdgeInsets.only(left: 21.0, right: 21.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  TextButton(
                      // style: ButtonStyle(
                      //   visualDensity: VisualDensity.compact,
                      // ),
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
                              return ListBottomSheet(
                                  timingNotifier!, timingOptions);
                            });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('sosmed_label_prediction_time'.tr(),
                              style: InvestrendTheme.of(context)
                                  .more_support_w400_compact
                                  ?.copyWith(
                                      color: InvestrendTheme.of(context)
                                          .greyDarkerTextColor /*, fontSize: 10.0*/)),
                          SizedBox(
                            height: 5.0,
                          ),
                          ValueListenableBuilder<int>(
                              valueListenable: timingNotifier!,
                              builder: (context, index, child) {
                                return Text(
                                  timingOptions.elementAt(index),
                                  style: InvestrendTheme.of(context)
                                      .more_support_w400_compact
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                );
                              }),
                        ],
                      )),
                  Spacer(
                    flex: 1,
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _marketPriceNotifier,
                    builder: (context, closePrice, child) {
                      if (closePrice == IntFlag.error_value) {
                        return TextButton(
                            onPressed: () {
                              validateStockCode();
                            },
                            child: Text(
                              'button_retry'.tr(),
                              style: InvestrendTheme.of(context)
                                  .more_support_w600_compact
                                  ?.copyWith(color: Colors.red),
                            ));
                      } else if (closePrice == IntFlag.loading_value) {
                        return CircularProgressIndicator();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('sosmed_label_market_price'.tr(),
                              style: InvestrendTheme.of(context)
                                  .more_support_w400_compact
                                  ?.copyWith(
                                      color: InvestrendTheme.of(context)
                                          .greyDarkerTextColor /*, fontSize: 10.0*/)),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            closePrice > 0
                                ? InvestrendTheme.formatPrice(closePrice)
                                : '-',
                            style: InvestrendTheme.of(context)
                                .more_support_w400_compact
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComposePollWidget extends StatefulWidget {
  final VoidCallback? onDelete;
  final StateComposePoll state_polls;

  const ComposePollWidget(this.state_polls, {this.onDelete, Key? key})
      : super(key: key);

  @override
  _ComposePollWidgetState createState() => _ComposePollWidgetState();
}

class _ComposePollWidgetState extends State<ComposePollWidget> {
  List<String> timingOptions = [
    'sosmed_label_polling_1_week'.tr(),
    'sosmed_label_polling_1_month'.tr(),
    'sosmed_label_polling_3_month'.tr(),
    'sosmed_label_polling_6_month'.tr(),
    'sosmed_label_polling_1_year'.tr(),
  ];
  ValueNotifier<int>? timingNotifier; // = ValueNotifier<int>(1);
  final int maxOption = 5;

  //TextEditingController controller = new TextEditingController();
  List<TextEditingController> controllers = List.empty(growable: true);
  List<FocusNode> focusNodes = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    addOption();
    addOption();
    timingNotifier = ValueNotifier<int>(1);
    updateExpireAt();

    timingNotifier?.addListener(() {
      updateExpireAt();
    });
  }

  void updateExpireAt() {
    //String expire_at = '';
    // 'sosmed_label_polling_1_week'.tr(),  0
    // 'sosmed_label_polling_1_month'.tr(), 1
    // 'sosmed_label_polling_3_month'.tr(), 2
    // 'sosmed_label_polling_6_month'.tr(), 3
    // 'sosmed_label_polling_1_year'.tr(),  4
    DateTime now = DateTime.now().toUtc();
    DateTime expiredAt;
    int? index = timingNotifier?.value;
    if (index == 0) {
      expiredAt = new DateTime.utc(now.year, now.month, now.day + 7, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 1) {
      expiredAt = new DateTime.utc(now.year, now.month + 1, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 2) {
      expiredAt = new DateTime.utc(now.year, now.month + 3, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 3) {
      expiredAt = new DateTime.utc(now.year, now.month + 6, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else if (index == 4) {
      expiredAt = new DateTime.utc(now.year + 1, now.month, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else {
      expiredAt = new DateTime.utc(now.year, now.month + 1, now.day, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    }
    print('now : ' + now.toString());
    print('expired_at : ' + expiredAt.toString());
    widget.state_polls.expire_at = Utils.formatDate(expiredAt);
    print('state_polls.expired_at : ' + widget.state_polls.expire_at);
  }

  @override
  void dispose() {
    timingNotifier?.dispose();
    //controller.dispose();
    controllers.forEach((controller) {
      controller.dispose();
    });
    focusNodes.forEach((focusNode) {
      focusNode.dispose();
    });
    controllers.clear();
    super.dispose();
  }

  void addOption() {
    //widget.state_polls.add('');
    TextEditingController controller = TextEditingController();
    controllers.add(controller);
    focusNodes.add(FocusNode());
    controller.addListener(() {
      widget.state_polls.options.clear();
      for (int i = 0; i < controllers.length; i++) {
        //widget.state_polls[i] = controllers.elementAt(i).text;
        widget.state_polls.set(controllers.elementAt(i).text, i);
      }
    });
    setState(() {});
  }

  final double padding = 12.0;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    list.add(IconButton(
      onPressed: widget.onDelete,
      icon: Image.asset('images/icons/delete_circle.png'),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.only(left: 1.0, bottom: 1.0, top: 1.0, right: 1.0),
    ));

    for (int i = 0; i < controllers.length; i++) {
      int nextIndex = i + 1;
      TextEditingController controller = controllers.elementAt(i);
      FocusNode focusNode = focusNodes.elementAt(i);
      FocusNode? nextFocusNode = nextIndex < controllers.length
          ? focusNodes.elementAt(nextIndex)
          : null;
      String hint = 'sosmed_label_option'.tr() + ' $nextIndex';
      list.add(Padding(
        padding: EdgeInsets.only(left: padding, right: padding),
        child: TextFieldCounter(
          controller,
          hint: hint,
          key: Key('polls_' + nextIndex.toString()),
          focusNode: focusNode,
          nextFocusNode: nextFocusNode!,
        ),
      ));
    }
    /*
    controllers.forEach((controller) {
      String hint = 'sosmed_label_option'.tr() + ' $line';
      list.add(Padding(
        padding: EdgeInsets.only(left: padding, right: padding),
        child: TextFieldCounter(
          controller,
          hint: hint,
          key: Key('polls_'+line.toString()),
          focusNode: focusNodes.,
        ),
      ));
      line++;
    });
    */
    if (controllers.length < maxOption) {
      list.add(Padding(
        padding: EdgeInsets.only(top: 0.0, left: 21.0, right: 21.0),
        child: TextButton(
            // style: ButtonStyle(
            //   visualDensity: VisualDensity.comfortable,
            // ),
            onPressed: addOption,
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Image.asset(
                  'images/icons/plus.png',
                  color: Theme.of(context).colorScheme.secondary,
                  width: 16.0,
                  height: 16.0,
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  'sosmed_label_add_option'.tr(),
                  style: InvestrendTheme.of(context)
                      .small_w400_compact
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            )),
      ));
    } else {
      list.add(SizedBox(
        height: 11.0,
      ));
    }
    list.add(Padding(
      padding: EdgeInsets.only(top: 1.0, bottom: 4.0),
      child: ComponentCreator.divider(context),
    ));
    list.add(Padding(
      padding: EdgeInsets.only(left: 21.0, right: 21.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
            // style: ButtonStyle(
            //   visualDensity: VisualDensity.compact,
            // ),
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
                    return ListBottomSheet(timingNotifier!, timingOptions);
                  });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('sosmed_label_polling_time'.tr(),
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact
                        ?.copyWith(
                            color: InvestrendTheme.of(context)
                                .greyDarkerTextColor /*, fontSize: 10.0*/)),
                SizedBox(
                  height: 5.0,
                ),
                ValueListenableBuilder<int>(
                    valueListenable: timingNotifier!,
                    builder: (context, index, child) {
                      return Text(
                        timingOptions.elementAt(index),
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary),
                      );
                    }),
              ],
            )),
      ),
    ));
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(top: padding, bottom: 8.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFFBDBDBD),
            width: 0.5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: list,
        /*
        children: [
          IconButton(
            onPressed: () {},
            icon: Image.asset('images/icons/delete_circle.png'),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.only(left: 1.0, bottom: 1.0, top: 1.0, right: 1.0),
          ),
          TextFieldCounter(controller, maxLength: 25,),
          createTextField(context, key: Key('0')),
          createTextField(context, key: Key('1')),
          createTextField(context, key: Key('2')),
        ],
        */
      ),
    );
  }
/*
  Widget createTextField(BuildContext context, {Key key, TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextField(
        controller: controller,
        key: key,
        maxLines: 1,
        maxLength: 25,
        // buildCounter: (_, {currentLength, maxLength, isFocused}) => Container(
        //     alignment: Alignment.centerRight,
        //     child: Text(currentLength.toString() + "/" + maxLength.toString())),
        style: InvestrendTheme.of(context).small_w400_compact,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: BorderSide(color: Color(0xFFBDBDBD), width: 0.5,),
            ),
            //counterText: '',
            filled: true,
            suffixText: '25',
            suffixStyle: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
            hintStyle: TextStyle(color: Colors.grey[800]),
            hintText: "Type in your text",
            fillColor: Colors.white70
        ),
        onChanged: (value){

        },
      ),
    );
  }

   */
}

class TextFieldCounter extends StatefulWidget {
  final TextEditingController controller;
  final int? maxLength;
  final String? hint;
  final bool showCounter;
  final String? prefix;

  //final TextInputAction textInputAction;
  final FocusNode? nextFocusNode;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final VoidCallback? onEditingComplete;

  const TextFieldCounter(this.controller,
      {this.onEditingComplete,
      this.hint,
      this.focusNode,
      this.keyboardType = TextInputType.text,
      this.nextFocusNode,
      this.prefix,
      this.maxLength = 25,
      this.showCounter = true,
      /*this.textInputAction,*/ Key? key})
      : super(key: key);

  @override
  _TextFieldCounterState createState() => _TextFieldCounterState();
}

class _TextFieldCounterState extends State<TextFieldCounter> {
  TextEditingController controllerInvisible = TextEditingController(text: '  ');

  @override
  void dispose() {
    controllerInvisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int characterLeft = widget.maxLength! - widget.controller.text.length;
    //TextInputAction textInputAction = widget.textInputAction ?? TextInputAction.done ;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Stack(
        children: [
          createTextFieldCounterInvisible(context, characterLeft),
          createTextFieldCounter(context, characterLeft),
        ],
      ),

      /*
      child: TextField(
        controller: widget.controller,
        //key: key,

        maxLines: 1,
        maxLength: widget.maxLength,
        style: InvestrendTheme.of(context).small_w400_compact.copyWith(height: 1.0),
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: BorderSide(
                color: InvestrendTheme.of(context).greyLighterTextColor,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: BorderSide(
                color: Theme.of(context).accentColor,
                width: 0.5,
              ),
            ),
            counterText: '',
            filled: true,
            suffixText: widget.showCounter ? characterLeft.toString() : null,
            suffixStyle:
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, height: 1.0),
            hintStyle:
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, height: 1.0),
            hintText: widget.hint,
            prefixStyle:
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, height: 1.0),
            helperStyle:
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, height: 1.0),
            labelStyle:
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, height: 1.0),
            counterStyle:
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, height: 1.0),
            errorStyle:
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, height: 1.0),
            fillColor: Colors.transparent),

        cursorHeight: 24.0,

        onChanged: (value) {
          if(widget.showCounter){
            setState(() {});
          }
        },
      ),
      */
    );
  }

  Widget createTextFieldCounter(BuildContext context, int characterLeft) {
    return TextField(
      controller: widget.controller,
      maxLines: 1,
      //textCapitalization: TextCapitalization.characters,
      maxLength: widget.maxLength,
      focusNode: widget.focusNode,
      textInputAction: widget.nextFocusNode != null
          ? TextInputAction.next
          : TextInputAction.done,
      keyboardType: widget.keyboardType,
      style:
          InvestrendTheme.of(context).small_w400_compact?.copyWith(height: 1.0),
      onEditingComplete: () {
        if (widget.nextFocusNode != null) {
          widget.nextFocusNode?.requestFocus();
        } else {
          FocusScope.of(context).unfocus();
        }
        if (widget.onEditingComplete != null) {
          widget.onEditingComplete!();
        }
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(
              color: InvestrendTheme.of(context).greyLighterTextColor!,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 0.5,
            ),
          ),
          counterText: '',
          filled: true,
          suffixText: widget.showCounter ? characterLeft.toString() : null,
          suffixStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(color: Colors.transparent, height: 1.0),
          hintStyle: InvestrendTheme.of(context).small_w400_compact?.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor,
              height: 1.0),
          hintText: widget.hint,
          prefixText: widget.prefix,
          prefixStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(color: Colors.transparent, height: 1.0),
          helperStyle: InvestrendTheme.of(context).small_w400_compact?.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor,
              height: 1.0),
          labelStyle: InvestrendTheme.of(context).small_w400_compact?.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor,
              height: 1.0),
          counterStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(
                  color: InvestrendTheme.of(context).greyLighterTextColor,
                  height: 1.0),
          errorStyle: InvestrendTheme.of(context).small_w400_compact?.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor,
              height: 1.0),
          fillColor: Colors.transparent),

      cursorHeight: 24.0,

      onChanged: (value) {
        if (widget.showCounter) {
          setState(() {});
        }
      },
    );
  }

  Widget createTextFieldCounterInvisible(
      BuildContext context, int characterLeft) {
    return TextField(
      controller: controllerInvisible,
      maxLines: 1,
      maxLength: widget.maxLength,
      //textInputAction: widget.textInputAction ?? TextInputAction.done ,
      style: InvestrendTheme.of(context)
          .small_w400_compact
          ?.copyWith(height: 1.0, color: Colors.transparent),
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 0.5,
            ),
          ),
          counterText: '',
          filled: true,
          suffixText: widget.showCounter ? characterLeft.toString() : null,
          suffixStyle: InvestrendTheme.of(context).small_w400_compact?.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor,
              height: 1.0),
          hintStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(color: Colors.transparent, height: 1.0),
          hintText: widget.hint,
          prefixText: widget.prefix,
          prefixStyle: InvestrendTheme.of(context).small_w400_compact?.copyWith(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
              height: 1.0),
          helperStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(color: Colors.transparent, height: 1.0),
          labelStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(color: Colors.transparent, height: 1.0),
          counterStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(color: Colors.transparent, height: 1.0),
          errorStyle: InvestrendTheme.of(context)
              .small_w400_compact
              ?.copyWith(color: Colors.transparent, height: 1.0),
          fillColor: Colors.transparent),

      cursorHeight: 24.0,

      // onChanged: (value) {
      //   if(widget.showCounter){
      //     setState(() {});
      //   }
      // },
    );
  }
}
