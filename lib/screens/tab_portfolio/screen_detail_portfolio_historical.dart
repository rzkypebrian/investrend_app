// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:Investrend/component/bottom_sheet/bottom_sheet_portfolio_detail_filter.dart';
import 'package:Investrend/component/bottom_sheet/bottom_sheet_transaction_filter.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

class ScreenDetailPortfolioHistorical extends StatefulWidget {
  final String? init_stock_code;
  final String? init_stock_name;
  final String? init_account;
  final String? init_user;
  final String? init_broker;

  const ScreenDetailPortfolioHistorical(this.init_stock_code,
      this.init_stock_name, this.init_account, this.init_user, this.init_broker,
      {Key? key})
      : super(key: key);

  @override
  _ScreenDetailPortfolioHistoricalState createState() =>
      _ScreenDetailPortfolioHistoricalState();
}

class _ScreenDetailPortfolioHistoricalState
    extends VisibilityAwareState<ScreenDetailPortfolioHistorical> {
  final String routeName = '/detail_portfolio_historical';
  bool onProgress = false;
  bool active = false;
  ReportStockHistNotifier? _reportStockHistNotifier =
      ReportStockHistNotifier(ReportStockHistData());

  // String code ='-';
  // String name ='-';
  // String account='-';

  String? stock_code = '-';
  String? stock_name = '-';
  String? account = '-';
  String? user = '-';
  String? broker = '-';

  int index_transaction = 0;
  String from = '';
  String to = '';

  //
  // String data_by; // belum tentu kepakai
  // String type; // belum tentu kepakai

  void onVisibilityChanged(WidgetVisibility visibility) {
    switch (visibility) {
      case WidgetVisibility.VISIBLE:
        // Like Android's Activity.onResume()
        print('*** ScreenVisibility.VISIBLE: ${this.routeName}');
        _onActiveBase(caller: 'onVisibilityChanged.VISIBLE');
        break;
      case WidgetVisibility.INVISIBLE:
        // Like Android's Activity.onPause()
        print('*** ScreenVisibility.INVISIBLE: ${this.routeName}');
        _onInactiveBase(caller: 'onVisibilityChanged.INVISIBLE');
        break;
      case WidgetVisibility.GONE:
        // Like Android's Activity.onDestroy()
        print(
            '*** ScreenVisibility.GONE: ${this.routeName}   mounted : $mounted');
        //_onInactiveBase(caller: 'onVisibilityChanged.GONE');
        break;
    }

    super.onVisibilityChanged(visibility);
  }

  void _onActiveBase({String caller = ''}) {
    active = true;
    print(routeName + ' onActive  $caller');
    runPostFrame(onActive);
  }

  void runPostFrame(Function function) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        print(routeName + ' runPostFrame executed');
        function();
      } else {
        print(routeName + ' runPostFrame aborted due mounted : $mounted');
      }
    });
  }

  void _onInactiveBase({String caller = ''}) {
    active = false;
    print(routeName + ' onInactive  $caller');
    onInactive();
  }

  void onActive() {
    //canTapRow = true;
    // unsubscribe(context, 'onActive');
    //
    // Stock stock = InvestrendTheme.storedData.findStock(code);
    // if (!StringUtils.equalsIgnoreCase(stock.code, context.read(stockSummaryChangeNotifier).summary.code)) {
    //   context.read(stockSummaryChangeNotifier).setStock(stock);
    // }
    // subscribe(context, stock, 'onActive');
    doUpdate();
  }

  void onInactive() {
    //slidableController.activeState = null;
    //canTapRow = true;
    // if(mounted){
    // unsubscribe(null, 'onInactive');
    // }
  }

  @override
  void dispose() {
    _reportStockHistNotifier?.dispose();

    super.dispose();
  } // belum tentu kepakai

  @override
  void initState() {
    super.initState();

    this.stock_code = widget.init_stock_code;
    this.stock_name = widget.init_stock_name;
    this.account = widget.init_account;
    this.user = widget.init_user;
    this.broker = widget.init_broker;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdate();
    });
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    if (!mounted) {
      print(routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  mounted : $mounted  pullToRefresh : $pullToRefresh");
      return false;
    }
    onProgress = true;
    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  pullToRefresh : $pullToRefresh");

    /*
    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (hasAccount) {
      int selected = context.read(accountChangeNotifier).index;
      Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
      if (account == null) {
        //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
        String text = routeName + ' No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
        InvestrendTheme.of(context).showSnackBar(context, text);
        onProgress = false;
        return;
      } else {
        if (_portfolioNotifier.value.isEmpty()) {
          if (mounted) {
            _portfolioNotifier.setLoading();
          }
        }
        try {
          print(routeName + ' try stockPosition');
          final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
              account.brokercode,
              account.accountcode,
              context.read(dataHolderChangeNotifier).user.username,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion,
              stock: this.code);
          //DebugWriter.info(routeName + ' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
          DebugWriter.information(routeName + ' Got stockPosition ' + stockPosition.toString());
          if (stockPosition != null) {
            if (mounted) {
              StockPositionDetail detail = stockPosition.getStockPositionDetailByCode(this.code);
              _portfolioNotifier.setValue(detail);
            }
          } else {
            if (mounted) {
              _portfolioNotifier.setNoData();
            }
          }
        } catch (e) {
          DebugWriter.information(routeName + ' stockPosition Exception : ' + e.toString());
          if (mounted) {
            _portfolioNotifier.setError(message: e.toString());
          }
          //_stockPositionNotifier?.setError(message: e.toString());
          //setNotifierError(_stockPositionNotifier, e);
          handleNetworkError(context, e);
        }


        try {
          print(routeName + ' try orderStatus');
          final orderStatus = await InvestrendTheme.tradingHttp.orderStatus(account.brokercode /*''*/, account.accountcode /*''*/, context.read(dataHolderChangeNotifier).user.username,
              InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, stock: this.code);
          int orderStatusCount = orderStatus != null ? orderStatus.length : 0;
          print('Got orderStatus : ' + orderStatusCount.toString());

          if (orderStatus != null) {

            if(mounted){
              OrderStatusData result = OrderStatusData();
              orderStatus.forEach((status) {
                if (
                StringUtils.equalsIgnoreCase(status.stockCode, this.code)
                    && (status.isFilterValid(FilterTransaction.All.index, FilterStatus.Open.index)
                    || status.isFilterValid(FilterTransaction.All.index, FilterStatus.New.index))
                ) {
                  result.datas.add(status);
                }
              });
              _orderStatusNotifier.setValue(result);
            }

          }else{
            if (mounted) {
              _orderStatusNotifier.setNoData();
            }
          }

        } catch (e) {
          DebugWriter.information(routeName + ' orderStatus Exception : ' + e.toString());
          if (mounted) {
            _orderStatusNotifier.setError(message: e.toString());
          }
          handleNetworkError(context, e);
        }


      }
    }
    */
    try {
      String bs = '';
      if (index_transaction == 1) {
        bs = 'B';
      } else if (index_transaction == 2) {
        bs = 'S';
      }

      print(routeName + ' try report stock hist');
      final ReportStockHistData? reportStockHist =
          await InvestrendTheme.tradingHttp.report_stock_hist(
              broker,
              account,
              user,
              stock_code,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion,
              bs: bs,
              from: from,
              to: to);
      //DebugWriter.info(routeName + ' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
      // DebugWriter.information(routeName +
      //     ' Got report_stock_hist : ' +
      //     reportStockHist.size().toString());
      if (reportStockHist != null && !reportStockHist.isEmpty()) {
        if (mounted) {
          _reportStockHistNotifier?.setValue(reportStockHist);
        }
      } else {
        if (mounted) {
          _reportStockHistNotifier?.setNoData();
        }
      }
    } catch (e) {
      DebugWriter.information(
          routeName + ' stockPosition Exception : ' + e.toString());
      if (mounted) {
        _reportStockHistNotifier?.setError(message: e.toString());
      }
      handleNetworkError(context, e);
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    onProgress = false;
    return true;
  }

  void handleNetworkError(BuildContext context, error) {
    print(routeName + ' handleNetworkError : ' + error.toString());
    print(error);
    if (mounted) {
      if (error is TradingHttpException) {
        if (error.isUnauthorized()) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
          // InvestrendTheme.of(context).showDialogInvalidSession(context, onClosePressed: (){
          //   Navigator.pop(context);
          // });
        } else if (error.isErrorTrading()) {
          InvestrendTheme.of(context).showSnackBar(context, error.message());
        } else {
          String networkErrorLabel = 'network_error_label'.tr();
          networkErrorLabel =
              networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
        }
      } else {
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        String errorText = Utils.removeServerAddress(error.toString());
        InvestrendTheme.of(context).showSnackBar(context, errorText);
      }
    }
  }

  Future onRefresh() {
    // context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    // if (!active) {
    //   active = true;
    //   //onActive();
    //   context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    // }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return RefreshIndicator(
          color: InvestrendTheme.of(context).textWhite,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral),
                child: Text(
                  stock_code!,
                  style: InvestrendTheme.of(context).regular_w600,
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral),
                child: Text(stock_name!,
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact_greyDarker),
              ),
              SizedBox(
                height: InvestrendTheme.cardPadding,
              ),
              _options(context),
              Padding(
                padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral,
                ),
                child: createHeaderMatched(context),
              ),
              Expanded(
                flex: 1,
                child: ValueListenableBuilder(
                    valueListenable: _reportStockHistNotifier!,
                    builder: (context, ReportStockHistData? value, child) {
                      List<Widget> childs = List.empty(growable: true);

                      Widget? noWidget = _reportStockHistNotifier?.currentState
                          .getNoWidget(onRetry: () {
                        doUpdate(pullToRefresh: true);
                      });

                      if (noWidget != null) {
                        if (_reportStockHistNotifier!.currentState.isNoData()) {
                          String emptyDescription =
                              'portfolio_detail_historical_empty_description'
                                  .tr();
                          //"portfolio_detail_historical_empty_description": "You haven't made any transactions yet, start ordering.",

                          if (index_transaction != 0 &&
                              (!StringUtils.isEmtpy(from) ||
                                  !StringUtils.isEmtpy(to))) {
                            // "portfolio_detail_historical_filter_description": "Filter applied for transaction \"#TRX#\" and period \"#FRM#\" - \"#TO#\"",
                            emptyDescription =
                                'portfolio_detail_historical_filter_description'
                                    .tr();
                          } else if (index_transaction != 0) {
                            //"portfolio_detail_historical_filter_transaction_description": "Filter applied for transaction \"#TRX#\"",
                            emptyDescription =
                                'portfolio_detail_historical_filter_transaction_description'
                                    .tr();
                          } else if (!StringUtils.isEmtpy(from) ||
                              !StringUtils.isEmtpy(to)) {
                            //"portfolio_detail_historical_filter_periode_description": "Filter applied for period \"#FRM#\" - \"#TO#\"",
                            emptyDescription =
                                'portfolio_detail_historical_filter_periode_description'
                                    .tr();
                          }

                          emptyDescription = emptyDescription.replaceFirst(
                              '#TRX#',
                              FilterTransaction.values
                                  .elementAt(index_transaction)
                                  .text);
                          emptyDescription =
                              emptyDescription.replaceFirst('#FRM#', from);
                          emptyDescription =
                              emptyDescription.replaceFirst('#TO#', to);

                          childs.add(SizedBox(
                            height: MediaQuery.of(context).size.width / 4,
                          ));
                          childs.add(EmptyTitleLabel(
                              text: 'portfolio_detail_historical_empty_title'
                                  .tr()));
                          childs.add(SizedBox(
                            height: InvestrendTheme.cardPaddingGeneral,
                          ));
                          childs.add(EmptyLabel(text: emptyDescription));
                        } else {
                          childs.add(Padding(
                            padding: EdgeInsets.only(
                                top: InvestrendTheme.cardPaddingVertical,
                                bottom: InvestrendTheme.cardPaddingVertical),
                            child: Center(child: noWidget),
                          ));
                        }

                        return ListView(
                          padding: const EdgeInsets.only(
                            left: InvestrendTheme.cardPaddingGeneral,
                            right: InvestrendTheme.cardPaddingGeneral,
                          ),
                          children: childs,
                        );
                      } else {
                        //int loop = min(max_showed, value.size());
                        int? count = value?.size();
                        // for (int i = 0; i < count; i++) {
                        //   if (i > 0) {
                        //     childs.add(ComponentCreator.divider(context, thickness: 0.5));
                        //   }
                        //   childs.add(createRowMatched(context, value.datas.elementAt(i)));
                        // }

                        return ListView.separated(
                          shrinkWrap: false,
                          padding: const EdgeInsets.only(
                              left: InvestrendTheme.cardPaddingGeneral,
                              right: InvestrendTheme.cardPaddingGeneral),
                          itemCount: count! + 1,
                          // di + 1 supaya muncul divider di paling bawah
                          itemBuilder: (BuildContext context, int index) {
                            if (index < count) {
                              return createRowMatched(
                                  context, value!.datas!.elementAt(index));
                            } else {
                              return SizedBox(
                                height: 80.0 + paddingBottom,
                              );
                            }

                            //return tileTransaction(context, listDisplay.elementAt(index - 1), statusWidth);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            if (index < count) {
                              return ComponentCreator.divider(context,
                                  thickness: 0.5);
                            } else {
                              return SizedBox(
                                width: 1.0,
                              );
                            }
                          },
                        );
                      }
                    }),
              ),
              /*
              Expanded(
                flex: 1,
                child: ListView(
                  padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [



                    SizedBox(
                      height: 80.0 + paddingBottom,
                    ),
                  ],
                ),
              ),
               */
            ],
          ),
        );
      },
    );
  }

  String translateBuySell(String bs) {
    if (StringUtils.equalsIgnoreCase(bs, 'S')) {
      return 'sell_text'.tr();
    } else if (StringUtils.equalsIgnoreCase(bs, 'B')) {
      return 'buy_text'.tr();
    }
    return bs;
  }

  Color? colorBuySell(BuildContext context, String bs) {
    if (StringUtils.equalsIgnoreCase(bs, 'S')) {
      return InvestrendTheme.sellTextColor;
    } else if (StringUtils.equalsIgnoreCase(bs, 'B')) {
      return InvestrendTheme.buyTextColor;
    }
    return InvestrendTheme.of(context).greyDarkerTextColor;
  }

  AutoSizeGroup groupMatchedTop = AutoSizeGroup();
  AutoSizeGroup groupMatchedBottom = AutoSizeGroup();
  AutoSizeGroup groupMatchedHeader = AutoSizeGroup();

  Widget createRowMatched(BuildContext context, ReportStockHist data) {
    TextStyle? styleTop = InvestrendTheme.of(context).regular_w500_compact;
    TextStyle? styleBottom =
        InvestrendTheme.of(context).small_w400_compact_greyDarker;
    return Padding(
      padding: EdgeInsets.only(
          top: InvestrendTheme.cardPadding,
          bottom: InvestrendTheme.cardPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    data.date!,
                    style: styleTop,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedTop,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    translateBuySell(data.bs!),
                    style: styleTop?.copyWith(
                        color: colorBuySell(context, data.bs!)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedTop,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    InvestrendTheme.formatPrice(data.price!),
                    style: styleTop,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedTop,
                  )),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    ' ',
                    style: styleBottom,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedBottom,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    InvestrendTheme.formatPrice(data.lot!),
                    style: styleBottom,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedBottom,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    InvestrendTheme.formatMoney(data.value!, prefixRp: true),
                    style: styleBottom,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedBottom,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget createHeaderMatched(BuildContext context) {
    TextStyle? styleHeader = InvestrendTheme.of(context).small_w500_compact;
    return Padding(
      padding: EdgeInsets.only(
          top: InvestrendTheme.cardPadding,
          bottom: InvestrendTheme.cardPadding),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'date_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.left,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupMatchedHeader,
              )),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'order_lot_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupMatchedHeader,
              )),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'price_total_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.right,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupMatchedHeader,
              )),
        ],
      ),
    );
  }

  Widget _options(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          /*bottom: 8.0 ,*/ left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        children: [
          OutlinedButton(
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
                      //final notifier = context.read(transactionIntradayFilterChangeNotifier);
                      return BottomSheetPortfolioDetailFilter(
                        index_transaction,
                        from,
                        to,
                        callbackRange: (newIndexTransaction, newFrom, newTo) {
                          bool isChanged =
                              !StringUtils.equalsIgnoreCase(from, newFrom) ||
                                  !StringUtils.equalsIgnoreCase(to, newTo) ||
                                  index_transaction != newIndexTransaction;
                          print(routeName +
                              ' filter callbackRange new_index_transaction : $newIndexTransaction   $newFrom , $newTo  isChanged : $isChanged');

                          if (isChanged) {
                            this.index_transaction = newIndexTransaction;
                            this.from = newFrom;
                            this.to = newTo;
                            doUpdate();
                          }
                        },
                      );
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
                    style:
                        InvestrendTheme.of(context).more_support_w400_compact,
                  ),
                ],
              )),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    double paddingTop = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      //floatingActionButton: createFloatingActionButton(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        shadowColor: shadowColor,
        elevation: elevation,
        //title: AppBarTitleText('portfolio_detail_historical_title'.tr() + ' - ' + stock_code),
        title: AppBarTitleText('portfolio_detail_historical_title'.tr()),
        actions: [
          AppBarConnectionStatus(
            child: Container(
              width: 20.0,
              height: 20.0,
              color: Colors.transparent,
            ),
          ),
        ],
        leading: AppBarActionIcon(
          'images/icons/action_back.png',
          () {
            Navigator.of(context).pop();
          },
          //color: Theme.of(context).accentColor,
        ),
      ),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  Widget? createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }
}
