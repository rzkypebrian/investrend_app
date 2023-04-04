import 'dart:math';

import 'package:Investrend/component/bottom_sheet/bottom_sheet_transaction_filter.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/trade/screen_order_detail.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenTransactionHistorical extends StatefulWidget {
  /*
  final int tabIndex;
  final TabController tabController;
  @override
  _ScreenTransactionHistoricalState createState() => _ScreenTransactionHistoricalState();
  ScreenTransactionHistorical(this.tabIndex,this.tabController, {Key key}):super(key: key);
  */

  final TabController tabController;
  final int tabIndex;

  ScreenTransactionHistorical(this.tabIndex, this.tabController, {Key key}) : super(key: key);

  @override
  _ScreenTransactionHistoricalState createState() => _ScreenTransactionHistoricalState(tabIndex, tabController);
}

class _ScreenTransactionHistoricalState extends BaseStateNoTabsWithParentTab<ScreenTransactionHistorical> {
  _ScreenTransactionHistoricalState(int tabIndex, TabController tabController)
      : super('/transaction_historical', tabIndex, tabController, parentTabIndex: Tabs.Transaction.index);

  // bool isCurrentTab(){
  //   print('TransactionHistorical.isCurrentTab widget.tabIndex : '+widget.tabIndex.toString()+'   tabController : '+widget.tabController.index.toString());
  //   return widget.tabIndex == widget.tabController.index;
  // }
  final ValueNotifier _sortByNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> _valueNotifier = ValueNotifier<int>(0);
  List<OrderStatus> listDisplay = List.empty(growable: true);
  List<OrderStatus> list = List.empty(growable: true);

  Widget _options(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0,/* left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral*/),
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
                      final notifier = context.read(transactionHistoricalFilterChangeNotifier);
                      return BottomSheetTransactionHistoricalFilter(notifier.index_transaction, notifier.index_period);
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
          ValueListenableBuilder(
            valueListenable: _sortByNotifier,
            builder: (context, index, child) {
              String activeCA = _sort_by_option.elementAt(index);
              String text = 'transaction_sort_by_label'.tr()+ activeCA;
              return MaterialButton(
                  elevation: 0.0,
                  //visualDensity: VisualDensity.comfortable,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: InvestrendTheme.of(context).tileBackground,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onPressed: () {
                    //InvestrendTheme.of(context).showSnackBar(context, 'Action choose Market');

                    showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                        ),
                        //backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return SortByBottomSheet(_sortByNotifier, _sort_by_option);
                        });
                  });
            },
          ),
          */
        ],
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 15,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.0,),
                Text(
                  'button_filter'.tr(),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),

          Expanded(
            flex: 1,
            child: ListView.builder(
                shrinkWrap: false,
                padding: const EdgeInsets.all(8),
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return tileHistorical(context);
                  // return Container(
                  //   height: 50,
                  //   color: Colors.amber[colorCodes[index]],
                  //   child: Center(child: Text('Entry ${entries[index]}')),
                  // );
                }),
          ),
        ],
      ),
    );
  }
  */
  Widget tileTransaction(BuildContext context, OrderStatus os, double statusWidth, double dateTimeWidth) {
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
          Navigator.push(context,
              CupertinoPageRoute(builder: (_) => ScreenOrderDetail(data, os, historicalMode: true,), settings: RouteSettings(name: '/order_detail_historical')));
        } else {
          String error = 'validation_account_not_related_to_user'.tr();
          error = error.replaceAll('#account#', os.accountcode);
          error = error.replaceAll('#user#', context.read(dataHolderChangeNotifier).user.username);
          InvestrendTheme.of(context).showSnackBar(context, error);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, /*left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral*/),
        // color: Colors.cyan,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: dateTimeWidth,
                  padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, top: 4.0, bottom: 4.0),
                  margin:  EdgeInsets.only(right: InvestrendTheme.cardPadding,),
                  decoration: BoxDecoration(
                    color: InvestrendTheme.of(context).tileBackground,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Column(
                    children: [
                      AutoSizeText(
                        os.getTimeFormatted(),

                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 8.0,
                        group: groupStatus,
                        style:
                        InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                      ),
                      SizedBox(height: 4.0,),
                      AutoSizeText(
                        os.getDateFormatted(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 8.0,
                        group: groupStatus,
                        style:
                        InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                      ),
                    ],
                  ),
                ),
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
                          minFontSize: 8.0,
                          group: groupStatus,
                          style:
                          InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
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



  Widget tileHistorical(BuildContext context) {
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
                  Text(
                    'ELSA',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    'Jual',
                    style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.w300, color: InvestrendTheme.redText),
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
                      '10 Lot',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Text(
                      'Rp 900',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Text(
                      'Rp 900.000',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Container(
                padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, top: 4.0, bottom: 4.0),
                decoration: BoxDecoration(
                  color: InvestrendTheme.of(context).tileBackground,
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Text(
                  '14:28\n23/08/21',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          ComponentCreator.divider(context),
        ],
      ),
    );
  }

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  // Future doUpdate({bool pullToRefresh = false}) async {
  //   print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
  //   return true;
  // }

  bool onProgress = false;

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + ' doUpdate : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");

    if (!active) {
      print(routeName + ' doUpdate Aborted : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");
      return;
    }
    onProgress = true;

    try{
      final notifier = context.read(transactionHistoricalFilterChangeNotifier);

      User user = context.read(dataHolderChangeNotifier).user;
      int selected = context.read(accountChangeNotifier).index;
      Account account = user.getAccount(selected);
      if(account == null){
        InvestrendTheme.of(context).showSnackBar(context, 'error_no_account_selected'.tr());
        onProgress = false;
        return false;
      }

      final orderStatus = await InvestrendTheme.tradingHttp.orderStatus(
          account.brokercode /*''*/,
          account.accountcode /*''*/,
          user.username,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion,
          historical: true,
          historicalFilterTransaction: FilterTransaction.values.elementAt(notifier.index_transaction).filter,
          historicalFilterPeriod: FilterPeriod.values.elementAt(notifier.index_period).filter
      );

      int orderStatusCount = orderStatus != null ? orderStatus.length : 0;
      print('Got orderStatus historical : ' + orderStatusCount.toString());

      listDisplay.clear();
      list.clear();
      if (orderStatus != null) {
        final notifier = context.read(transactionHistoricalFilterChangeNotifier);

        listDisplay.addAll(orderStatus);

        list.addAll(orderStatus);
      }
      if(mounted){
        if (_valueNotifier.value == orderStatusCount) {
          _valueNotifier.value = Random().nextInt(1000).toInt();
        } else {
          _valueNotifier.value = orderStatusCount;
        }
      }

    }catch(error){
      print(routeName + ' doUpdate Exception : '+error.toString());
      print(error);
      handleNetworkError(context, error);
    }


    onProgress = false;
    print(routeName + ' doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    if (!active) {
      active = true;
      context.read(buySellChangeNotifier).mustNotifyListener(); // dari intraday, ga tau kepake ga nya
      //onActive();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Column(
        children: [
          _options(context),
          SizedBox(
            height: MediaQuery.of(context).size.width / 4,
          ),
          EmptyTitleLabel(text: 'transaction_historical_empty_title'.tr()),
          SizedBox(
            height: InvestrendTheme.cardPaddingGeneral,
          ),
          EmptyLabel(text: 'transaction_historical_empty_description'.tr()),
        ],
      ),
    );
  }
  */

  AutoSizeGroup groupStatus;
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    double statusWidth = UIHelper.textSize('Withdraw-P', InvestrendTheme.of(context).more_support_w400_compact).width +
        InvestrendTheme.cardPadding +
        InvestrendTheme.cardPadding;

    double dateTimeWidth = UIHelper.textSize(' 2020/00/00 ', InvestrendTheme.of(context).more_support_w400_compact).width ;

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ValueListenableBuilder<int>(
          valueListenable: _valueNotifier,
          builder: (context, value, child) {

            final filter = context.read(transactionHistoricalFilterChangeNotifier);
            bool filterTransaction = filter.index_transaction != FilterTransaction.All.index;
            //bool filterPeriod = filter.index_period != FilterPeriod.All.index;
            bool filterPeriod = filter.index_period != FilterPeriod.ThisWeek.index;

            if (listDisplay.isEmpty) {
              String emptyDescription  = 'transaction_historical_empty_description'.tr();
              if(list.isNotEmpty || filterTransaction || filterPeriod){
                if( filterTransaction && filterPeriod ){
                  emptyDescription  = 'transaction_historical_filter_description'.tr();
                }else if(filterTransaction){
                  emptyDescription  = 'transaction_historical_filter_transaction_description'.tr();
                }else if(filterPeriod){
                  emptyDescription  = 'transaction_historical_filter_period_description'.tr();
                }

                emptyDescription = emptyDescription.replaceFirst('#TRX#', FilterTransaction.values.elementAt(filter.index_transaction).text);
                emptyDescription = emptyDescription.replaceFirst('#PRD#', FilterPeriod.values.elementAt(filter.index_period).text);
                //Filter diterapkan untuk Transaksi #TRX# dan Status #STS#
              }else{
                emptyDescription  = 'transaction_historical_empty_description'.tr();
              }
              return ListView(
                padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                children: [
                  _options(context),
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 4,
                  ),
                  EmptyTitleLabel(text: 'transaction_historical_empty_title'.tr()),
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
            if(filterTransaction || filterPeriod ){
              //count = count + 1;
              //filtered  = 'transaction_today_filter_description'.tr();
              if( filterTransaction && filterPeriod ){
                filtered  = 'transaction_historical_filter_description'.tr();
              }else if(filterTransaction){
                filtered  = 'transaction_historical_filter_transaction_description'.tr();
              }else if(filterPeriod){
                filtered  = 'transaction_historical_filter_period_description'.tr();
              }
              filtered = filtered.replaceFirst('#TRX#', FilterTransaction.values.elementAt(filter.index_transaction).text);
              filtered = filtered.replaceFirst('#PRD#', FilterPeriod.values.elementAt(filter.index_period).text);
            }

            return ListView.separated(
                shrinkWrap: false,
                //padding: const EdgeInsets.all(8),
                //padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
                padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                itemCount: count + 1, // di + 1 supaya muncul divider di paling bawah
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _options(context);
                  }
                  int indexDisplay = index - 1;
                  if(indexDisplay < listDisplay.length){
                    return tileTransaction(context, listDisplay.elementAt(indexDisplay), statusWidth,dateTimeWidth);
                  }else{
                    //return EmptyLabel(text: filtered);
                    if(StringUtils.isEmtpy(filtered)){
                      return SizedBox(width: 1.0,);
                    }else{
                      return EmptyLabel(text: filtered);
                    }
                  }
                  //return tileTransaction(context, listDisplay.elementAt(index - 1), statusWidth);
                }, separatorBuilder: (BuildContext context, int index) {
                  if(index > 0){
                    return ComponentCreator.divider(context);
                  }else{
                    return SizedBox(width: 1.0,);
                  }
            },);
          }),
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    // TODO: implement createBody
    return Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OutlinedButton(
          //   onPressed: () {},
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(
          //         Icons.filter_alt,
          //         size: 15,
          //         color: Colors.grey,
          //       ),
          //       SizedBox(width: 4.0,),
          //       Text(
          //         'button_filter'.tr(),
          //         style: Theme.of(context).textTheme.bodyText2,
          //       ),
          //     ],
          //   ),
          // ),
          _options(context),

          Expanded(
            flex: 1,
            child: ListView.builder(
                shrinkWrap: false,
                padding: const EdgeInsets.all(8),
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return tileHistorical(context);
                  // return Container(
                  //   height: 50,
                  //   color: Colors.amber[colorCodes[index]],
                  //   child: Center(child: Text('Entry ${entries[index]}')),
                  // );
                }),
          ),
        ],
      ),
    );
  }
  */

  final String PROP_SELECTED_FILTER_TRANSACTION       = 'filterTransaction';
  final String PROP_SELECTED_FILTER_PERIOD            = 'filterPeriod';
  @override
  void initState() {
    super.initState();

    print(routeName+' initState');
    groupStatus = AutoSizeGroup();


    runPostFrame((){
      // #1 get properties
      int filterTransaction = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_FILTER_TRANSACTION, 0);
      int filterPeriod = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_FILTER_PERIOD, 0);


      // #2 use properties
      int usedTransaction = min(filterTransaction, FilterTransaction.values.length - 1);
      int usedPeriod      = min(filterPeriod, FilterPeriod.values.length - 1);
      context.read(transactionHistoricalFilterChangeNotifier).setIndex(usedTransaction, usedPeriod);

      // #3 check properties if changed, then save again
      if(filterTransaction != usedTransaction){
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_FILTER_TRANSACTION, usedTransaction);
      }
      if(filterPeriod != usedPeriod){
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_FILTER_PERIOD, usedPeriod);
      }
    });
  }

  VoidCallback filterApplied;
  VoidCallback onAccountChanged;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final notifier = context.read(transactionHistoricalFilterChangeNotifier);
    if(filterApplied != null){
      notifier.removeListener(filterApplied);
    }else{
      filterApplied = (){
        if(mounted){
          context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_FILTER_TRANSACTION, context.read(transactionHistoricalFilterChangeNotifier).index_transaction);
          context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_FILTER_PERIOD, context.read(transactionHistoricalFilterChangeNotifier).index_period);
          doUpdate(pullToRefresh: true);
        }
      };
    }
    notifier.addListener(filterApplied);

    final notifierAccount = context.read(accountChangeNotifier);
    if(onAccountChanged != null){
      notifierAccount.removeListener(onAccountChanged);
    }else{
      onAccountChanged = (){
        if(mounted){
          doUpdate(pullToRefresh: true);
        }
      };
    }
    notifierAccount.addListener(onAccountChanged);
  }
  @override
  void dispose() {
    print(routeName + ' dispose start');


    final container = ProviderContainer();
    if(filterApplied != null){
      container.read(transactionIntradayFilterChangeNotifier).removeListener(filterApplied);
    }
    filterApplied = null;
    //_stopTimer();

    if(onAccountChanged != null){
      container.read(accountChangeNotifier).removeListener(onAccountChanged);
    }
    onAccountChanged = null;

    _sortByNotifier.dispose();
    _valueNotifier.dispose();

    print(routeName + ' dispose end');
    super.dispose();
  }

  @override
  void onActive() {
    context.read(buySellChangeNotifier).mustNotifyListener(); // dari intraday, ga tau kepake ga nya
    doUpdate();
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}
