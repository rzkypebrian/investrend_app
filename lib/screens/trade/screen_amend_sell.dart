import 'dart:async';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/trade/screen_amend_form.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenAmendSell extends StatefulWidget {

  final BuySell amendData;
  final ValueNotifier<bool> updateDataNotifier;
  final ValueNotifier<bool> keyboardNotifier;
  const ScreenAmendSell( this.amendData, this.updateDataNotifier, {Key key, this.keyboardNotifier}) : super(key: key);

  @override
  _ScreenAmendSellState createState() => _ScreenAmendSellState(amendData.orderType,amendData, updateDataNotifier, keyboardNotifier: keyboardNotifier);
}

class _ScreenAmendSellState extends BaseAmendState<ScreenAmendSell>
    //with AutomaticKeepAliveClientMixin<ScreenAmendSell>
{
  _ScreenAmendSellState(OrderType orderType, BuySell amendData,ValueNotifier<bool> updateDataNotifier, {ValueNotifier<bool> keyboardNotifier}) : super(orderType , amendData, updateDataNotifier, keyboardNotifier: keyboardNotifier);

  @override
  Widget createTopInfo(BuildContext context) {
    int jumlahLot = 2500;
    double averagePrice = 1000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        columnWidths: {0: FractionColumnWidth(.3)},
        children: [
          TableRow(children: [
            Text(
              'trade_sell_label_total_lot'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
            Text(
              'trade_sell_label_average_price'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
          ]),
          TableRow(children: [
            Consumer(builder: (context, watch, child) {
              final lotAverage = watch(sellLotAvgChangeNotifier);
              return Text(
                  InvestrendTheme.formatComma(
                    lotAverage.lot,
                  ),
                  style: InvestrendTheme.of(context).regular_w600);
            }),
            // Text(
            //     InvestrendTheme.formatComma(
            //       jumlahLot,
            //     ),
            //     style: InvestrendTheme.of(context).regular_w700),

            Consumer(builder: (context, watch, child) {
              final lotAverage = watch(sellLotAvgChangeNotifier);
              return Text(
                InvestrendTheme.formatMoneyDouble(
                  lotAverage.averagePrice,
                  prefixRp: true,
                ),
                style: InvestrendTheme.of(context).regular_w600,
                //textAlign: TextAlign.end,
              );
            }),

            // Text(
            //   InvestrendTheme.formatMoneyDouble(
            //     averagePrice,
            //     prefixRp: true,
            //   ),
            //   style: InvestrendTheme.of(context).regular_w700,
            //   //textAlign: TextAlign.end,
            // ),


          ])
        ],
      ),
    );
  }
  Future doUpdateAccount({bool pullToRefresh = false}) async {
    if (!isActiveAndMounted()) {
      print(orderType.routeName + '.doUpdateAccount Aborted : ' + DateTime.now().toString() + "  active : $active  mounted : $mounted pullToRefresh : $pullToRefresh");
      return false;
    }
    print(orderType.routeName + '.doUpdateAccount : ' + DateTime.now().toString() + "  active : $active  mounted : $mounted  pullToRefresh : $pullToRefresh");
    onProgressAccount = true;

    Stock stock = context.read(primaryStockChangeNotifier).stock;
    int selected = context.read(accountChangeNotifier).index;
    //Account account = InvestrendTheme.of(context).user.getAccount(selected);
    Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
      //String text = 'No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      String errorNoAccount = 'error_no_account_selected'.tr();
      String text = '$errorNoAccount. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      InvestrendTheme.of(context).showSnackBar(context, text);
      onProgressAccount = false;
      return false;
    } else {

      try {
        print(orderType.routeName+' try stockPosition');
        final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
            account.brokercode,
            account.accountcode,
            //InvestrendTheme.of(context).user.username,
            context.read(dataHolderChangeNotifier).user.username,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        DebugWriter.information(orderType.routeName+' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
        if(!mounted){
          onProgressAccount = false;
          return false;
        }
        StockPositionDetail detail = stockPosition.getStockPositionDetailByCode(stock?.code);
        if (detail != null) {
          context.read(sellLotAvgChangeNotifier).update(detail.netBalance.toInt(), detail.avgPrice);
        } else {
          context.read(sellLotAvgChangeNotifier).update(0, 0.0);
        }
      } catch (e) {
        DebugWriter.information(orderType.routeName+' stockPosition Exception : ' + e.toString());
        if(!mounted){
          onProgressAccount = false;
          return false;
        }
        if(e is TradingHttpException){
          if(e.isUnauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            onProgressAccount = false;
            return false;
          }else if(e.isErrorTrading()){
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            onProgressAccount = false;
            return false;
          }else{
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel = networkErrorLabel.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
            onProgressAccount = false;
            return false;
          }
        }else{
          InvestrendTheme.of(context).showSnackBar(context, e.toString());
        }
      }
    }
    onProgressAccount = false;
    return true;
  }
  /*
  @override
  Widget createTopInfo(BuildContext context) {
    int jumlahLot = 2500;
    double averagePrice = 1000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        columnWidths: {0: FractionColumnWidth(.3)},
        children: [
          TableRow(children: [
            Text(
              'trade_sell_label_total_lot'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
            Text(
              'trade_sell_label_average_price'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
          ]),
          TableRow(children: [
            Text(
                InvestrendTheme.formatComma(
                  jumlahLot,
                ),
                style: InvestrendTheme.of(context).regular_w700),
            Text(
              InvestrendTheme.formatMoneyDouble(
                averagePrice,
                prefixRp: true,
              ),
              style: InvestrendTheme.of(context).regular_w700,
              //textAlign: TextAlign.end,
            ),
          ])
        ],
      ),
    );
  }
  */

}
