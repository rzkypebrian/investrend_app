import 'dart:async';

import 'package:Investrend/component/button_info.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/trade/screen_trade_form.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenTradeBuy extends StatefulWidget {
  final ValueNotifier<bool> _fastModeNotifier;
  final TabController _tabController;
  final OrderbookNotifier _orderbookNotifier;
  final ValueNotifier<bool> _updateDataNotifier;
  final bool _onlyFastOrder;

  final PriceLot initialPriceLot;
  final ValueNotifier<bool> keyboardNotifier;
  const ScreenTradeBuy(this._fastModeNotifier, this._tabController,
      this._orderbookNotifier, this._updateDataNotifier, this._onlyFastOrder,
      {Key key, this.initialPriceLot, this.keyboardNotifier})
      : super(key: key);

  @override
  _ScreenTradeBuyState createState() => _ScreenTradeBuyState(_fastModeNotifier,
      _tabController, _orderbookNotifier, _updateDataNotifier, _onlyFastOrder,
      initialPriceLot: initialPriceLot, keyboardNotifier: keyboardNotifier);
}

class _ScreenTradeBuyState extends BaseTradeState<
    ScreenTradeBuy> //with AutomaticKeepAliveClientMixin<ScreenTradeBuy>
{
  _ScreenTradeBuyState(
      ValueNotifier<bool> fastModeNotifier,
      TabController tabController,
      OrderbookNotifier orderbookNotifier,
      ValueNotifier<bool> updateDataNotifier,
      bool onlyFastOrder,
      {PriceLot initialPriceLot,
      ValueNotifier<bool> keyboardNotifier})
      : super(OrderType.Buy, fastModeNotifier, tabController, orderbookNotifier,
            updateDataNotifier, onlyFastOrder,
            initialPriceLot: initialPriceLot,
            keyboardNotifier: keyboardNotifier);

  StringColorFontBoolNotifier notifierCashAvailable =
      StringColorFontBoolNotifier(StringColorFontBool());
  StringColorFontBoolNotifier notifierBuyingPowerNew =
      StringColorFontBoolNotifier(StringColorFontBool());

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    //notifierBuyingPower.dispose();
    notifierCashAvailable.dispose();
    notifierBuyingPowerNew.dispose();

    final container = ProviderContainer();
    if (onEventBuyingPowerCashAvailable != null) {
      container
          .read(buyRdnBuyingPowerChangeNotifier)
          .removeListener(onEventBuyingPowerCashAvailable);
    }
    if (keyboardNotifier != null) {
      keyboardNotifier.removeListener(keyboardEvent);
    }
    super.dispose();
  }

  VoidCallback onEventBuyingPowerCashAvailable;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (onEventBuyingPowerCashAvailable != null) {
          onEventBuyingPowerCashAvailable();
        }
      });
    });
  }

  Future doUpdateAccount({bool pullToRefresh = false}) async {
    if (!isActiveAndMounted()) {
      print(orderType.routeName +
          '.doUpdateAccount Aborted : ' +
          DateTime.now().toString() +
          "  _active : $active  mounted : $mounted pullToRefresh : $pullToRefresh");
      return false;
    }
    print(orderType.routeName +
        '.doUpdateAccount : ' +
        DateTime.now().toString() +
        "  _active : $active  mounted : $mounted  pullToRefresh : $pullToRefresh");
    onProgressAccount = true;

    int selected = context.read(accountChangeNotifier).index;
    Account account =
        context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      String errorNoAccount = 'error_no_account_selected'.tr();
      String text = '$errorNoAccount. accountSize : ' +
          context.read(dataHolderChangeNotifier).user.accountSize().toString();
      InvestrendTheme.of(context).showSnackBar(context, text);
      onProgressAccount = false;
      return false;
    } else {
      List<String> listAccountCode = List.empty(growable: true);

      context.read(dataHolderChangeNotifier).user.accounts.forEach((account) {
        listAccountCode.add(account.accountcode);
      });

      print(orderType.routeName + ' try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp
          .accountStockPosition(
              '' /*account.brokercode*/,
              listAccountCode,
              context.read(dataHolderChangeNotifier).user.username,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((value) {
        DebugWriter.information(orderType.routeName +
            ' Got accountStockPosition  accountStockPosition.size : ' +
            value.length.toString());
        if (!mounted) {
          print(orderType.routeName +
              ' accountStockPosition ignored.  mounted : $mounted');
          onProgressAccount = false;
          return false;
        }
        AccountStockPosition first =
            (value != null && value.length > 0) ? value.first : null;
        if (first != null && first.ignoreThis()) {
          // ignore in aja
          print(orderType.routeName +
              ' accountStockPosition ignored.  message : ' +
              first.message);
        } else {
          context.read(accountsInfosNotifier).updateList(value);
          Account activeAccount = context
              .read(dataHolderChangeNotifier)
              .user
              .getAccount(context.read(accountChangeNotifier).index);
          if (activeAccount != null) {
            AccountStockPosition accountInfo = context
                .read(accountsInfosNotifier)
                .getInfo(activeAccount.accountcode);
            if (accountInfo != null) {
              context.read(buyRdnBuyingPowerChangeNotifier).update(
                  accountInfo.outstandingLimit,
                  accountInfo.availableCash,
                  accountInfo.creditLimit);
            }
          }
        }
      }).onError((e, stackTrace) {
        DebugWriter.information(orderType.routeName +
            ' accountStockPosition Exception : ' +
            e.toString());
        if (!mounted) {
          onProgressAccount = false;
          return false;
        }
        if (e is TradingHttpException) {
          if (e.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            onProgressAccount = false;
            return false;
          } else if (e.isErrorTrading()) {
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            onProgressAccount = false;
            return false;
          } else {
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel =
                networkErrorLabel.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context)
                .showSnackBar(context, networkErrorLabel);
            onProgressAccount = false;
            return false;
          }
        } else {
          InvestrendTheme.of(context).showSnackBar(context, e.toString());
        }
      });
    }
    onProgressAccount = false;
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (onEventBuyingPowerCashAvailable != null) {
      context
          .read(buyRdnBuyingPowerChangeNotifier)
          .removeListener(onEventBuyingPowerCashAvailable);
    } else {
      onEventBuyingPowerCashAvailable = () {
        if (mounted) {
          double widthAvailable = MediaQuery.of(context).size.width -
              InvestrendTheme.cardPaddingGeneral -
              InvestrendTheme.cardPaddingGeneral -
              10.0 -
              10.0;
          print(orderType.routeName +
              ' onEventBuyingPowerCashBalance .widthAvailable : $widthAvailable');
          double widthValue = (widthAvailable - 10.0) * 0.47;

          double buyingPower =
              context.read(buyRdnBuyingPowerChangeNotifier).buyingPower;
          double cashBalance =
              context.read(buyRdnBuyingPowerChangeNotifier).cashAvailable;
          double creditLimit =
              context.read(buyRdnBuyingPowerChangeNotifier).creditLimit;

          String buyingPowerText =
              InvestrendTheme.formatMoneyDouble(buyingPower, prefixRp: true);
          String cashBalanceText =
              InvestrendTheme.formatMoneyDouble(cashBalance, prefixRp: true);

          TextStyle style = InvestrendTheme.of(context).regular_w600;
          style =
              UIHelper.useFontSize(context, style, widthValue, buyingPowerText);
          style =
              UIHelper.useFontSize(context, style, widthValue, cashBalanceText);

          bool show = creditLimit > 0;

          bool activeBuyingPower = false;
          bool activeCashAvailable = false;
          if (StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value,
              'trade_buy_label_buying_power'.tr())) {
            activeBuyingPower = true;
          } else {
            activeCashAvailable = true;
          }
          notifierBuyingPowerNew.setValue(buyingPowerText,
              fontSize: style.fontSize,
              newColor: style.color,
              boolFlag: activeBuyingPower);
          notifierCashAvailable.setValue(cashBalanceText,
              fontSize: style.fontSize,
              newColor: style.color,
              boolFlag: activeCashAvailable);
        }
      };
    }
    context
        .read(buyRdnBuyingPowerChangeNotifier)
        .addListener(onEventBuyingPowerCashAvailable);
  }

  @override
  Widget createTopInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder(
            valueListenable: notifierBuyingPowerNew,
            builder: (context, StringColorFontBool value, child) {
              return ButtonInfo(
                'trade_buy_label_buying_power'.tr(),
                value,
                () {
                  notifierBuyingPowerNew.setFlag(true);
                  notifierCashAvailable.setFlag(false);
                  predefineLotSourceNotifier.value =
                      'trade_buy_label_buying_power'.tr();
                },
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: notifierCashAvailable,
            builder: (context, StringColorFontBool value, child) {
              return ButtonInfo(
                'cash_available_label'.tr(),
                value,
                () {
                  notifierBuyingPowerNew.setFlag(false);
                  notifierCashAvailable.setFlag(true);
                  predefineLotSourceNotifier.value =
                      'cash_available_label'.tr();
                },
                crossAxisAlignment: CrossAxisAlignment.end,
              );
            },
          ),
        ],
      ),
    );
  }
}

class DragAndDrop extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {}
}
