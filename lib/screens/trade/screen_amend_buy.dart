// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:Investrend/component/button_info.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/trade/screen_amend_form.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenAmendBuy extends StatefulWidget {
  final BuySell? amendData;
  final ValueNotifier<bool> updateDataNotifier;
  final ValueNotifier<bool>? keyboardNotifier;
  const ScreenAmendBuy(this.amendData, this.updateDataNotifier,
      {Key? key, this.keyboardNotifier})
      : super(key: key);

  @override
  _ScreenAmendBuyState createState() =>
      _ScreenAmendBuyState(amendData?.orderType, amendData, updateDataNotifier,
          keyboardNotifier: keyboardNotifier);
}

class _ScreenAmendBuyState extends BaseAmendState<ScreenAmendBuy>
//with AutomaticKeepAliveClientMixin<ScreenAmendBuy>
{
  _ScreenAmendBuyState(OrderType? orderType, BuySell? amendData,
      ValueNotifier<bool> updateDataNotifier,
      {ValueNotifier<bool>? keyboardNotifier})
      : super(orderType, amendData, updateDataNotifier,
            keyboardNotifier: keyboardNotifier);

  StringColorFontNotifier notifierBuyingPower =
      StringColorFontNotifier(StringColorFont());
  StringColorFontBoolNotifier notifierCashAvailable =
      StringColorFontBoolNotifier(StringColorFontBool());
  //StringColorFontBoolNotifier notifierCashBalance = StringColorFontBoolNotifier(StringColorFontBool());
  StringColorFontBoolNotifier notifierBuyingPowerNew =
      StringColorFontBoolNotifier(StringColorFontBool());

  @override
  void dispose() {
    notifierBuyingPower.dispose();
    notifierCashAvailable.dispose();
    notifierBuyingPowerNew.dispose();
    final container = ProviderContainer();
    if (onEventBuyingPowerCashAvailable != null) {
      container
          .read(buyRdnBuyingPowerChangeNotifier)
          .removeListener(onEventBuyingPowerCashAvailable!);
    }

    super.dispose();
  }

  VoidCallback? onEventBuyingPowerCashAvailable;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (onEventBuyingPowerCashAvailable != null) {
          onEventBuyingPowerCashAvailable!();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (onEventBuyingPowerCashAvailable != null) {
      context
          .read(buyRdnBuyingPowerChangeNotifier)
          .removeListener(onEventBuyingPowerCashAvailable!);
    } else {
      onEventBuyingPowerCashAvailable = () {
        if (mounted) {
          double widthAvailable = MediaQuery.of(context).size.width -
              InvestrendTheme.cardPaddingGeneral -
              InvestrendTheme.cardPaddingGeneral -
              10.0 -
              10.0;
          print(orderType!.routeName +
              ' onEventBuyingPowerCashBalance .widthAvailable : $widthAvailable');
          double widthValue = widthAvailable * 0.47;

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

          TextStyle? style = InvestrendTheme.of(context).regular_w600;
          style =
              UIHelper.useFontSize(context, style, widthValue, buyingPowerText);
          style =
              UIHelper.useFontSize(context, style, widthValue, cashBalanceText);
          /*
          notifierBuyingPower.setValue(buyingPowerText, fontSize: style.fontSize, newColor: style.color);
          bool show = creditLimit > 0;
          notifierCashAvailable.setValue(cashBalanceText, fontSize: style.fontSize, newColor: style.color, boolFlag: show);
          */

          bool activeBuyingPower = false;
          bool activeCashAvailable = false;
          if (StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value,
              'trade_buy_label_buying_power'.tr())) {
            activeBuyingPower = true;
          } else {
            activeCashAvailable = true;
          }
          notifierBuyingPowerNew.setValue(buyingPowerText,
              fontSize: style?.fontSize,
              newColor: style?.color,
              boolFlag: activeBuyingPower);
          notifierCashAvailable.setValue(cashBalanceText,
              fontSize: style?.fontSize,
              newColor: style?.color,
              boolFlag: activeCashAvailable);
        }
      };
    }
    context
        .read(buyRdnBuyingPowerChangeNotifier)
        .addListener(onEventBuyingPowerCashAvailable!);
  }

  @override
  Widget createTopInfo(BuildContext context) {
    // int buyingPower = 250000000;
    // int rdnBalance = 200000000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder(
            valueListenable: notifierBuyingPowerNew,
            builder: (context, StringColorFontBool? value, child) {
              return ButtonInfo('trade_buy_label_buying_power'.tr(), value, () {
                notifierBuyingPowerNew.setFlag(true);
                notifierCashAvailable.setFlag(false);
                predefineLotSourceNotifier.value =
                    'trade_buy_label_buying_power'.tr();
              });
            },
          ),
          ValueListenableBuilder(
            valueListenable: notifierCashAvailable,
            builder: (context, StringColorFontBool? value, child) {
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
    /*
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        columnWidths: {0: FractionColumnWidth(.47), 1: FractionColumnWidth(.47)},
        children: [
          TableRow(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'trade_buy_label_buying_power'.tr(),
                  style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Image.asset(
                  'images/icons/information.png',
                  height: 12.0,
                  width: 12.0,
                ),
              ],
            ),
            ValueListenableBuilder(
              valueListenable: notifierCashAvailable,
              builder: (context, StringColorFontBool value, child) {
                if(value.flag){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'cash_available_label'.tr(),
                        style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                      ),
                      Image.asset(
                        'images/icons/information.png',
                        height: 12.0,
                        width: 12.0,
                      ),
                    ],
                  );
                }else{
                  return SizedBox(width: 1.0,);
                }
              },
            ),

          ]),
          TableRow(children: [

            ValueListenableBuilder(
              valueListenable: notifierBuyingPower,
              builder: (context, StringColorFont value, child) {
                return Text(
                    value.value,
                    style: InvestrendTheme.of(context).regular_w600.copyWith(fontSize: value.fontSize));
              },
            ),
            ValueListenableBuilder(
              valueListenable: notifierCashAvailable,
              builder: (context, StringColorFontBool value, child) {
                return Text(
                    value.flag ? value.value : '',
                    textAlign: TextAlign.end,
                    style: InvestrendTheme.of(context).regular_w600.copyWith(fontSize: value.fontSize));
              },
            ),

          ])
        ],
      ),
    );
     */
  }

  Widget createTopInfoOld(BuildContext context) {
    // int buyingPower = 250000000;
    // int rdnBalance = 200000000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        children: [
          TableRow(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'trade_buy_label_buying_power'.tr(),
                  style: InvestrendTheme.of(context).support_w400?.copyWith(
                      color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Image.asset(
                  'images/icons/information.png',
                  height: 12.0,
                  width: 12.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'trade_buy_label_rdn_balance'.tr(),
                  style: InvestrendTheme.of(context).support_w400?.copyWith(
                      color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Image.asset(
                  'images/icons/information.png',
                  height: 12.0,
                  width: 12.0,
                ),
              ],
            ),
          ]),
          TableRow(children: [
            /*
            Text(
                InvestrendTheme.formatMoney(
                  buyingPower,
                  prefixRp: true,
                ),
                style: InvestrendTheme.of(context).regular_w700),
            */
            Consumer(builder: (context, watch, child) {
              //final rdnBalance = watch(rdnBalanceStateProvider);
              final value = watch(buyRdnBuyingPowerChangeNotifier);

              return Text(
                  InvestrendTheme.formatMoneyDouble(
                    value.buyingPower,
                    prefixRp: true,
                  ),
                  style: InvestrendTheme.of(context).regular_w600);
            }),

            Consumer(builder: (context, watch, child) {
              //final rdnBalance = watch(rdnBalanceStateProvider);
              final value = watch(buyRdnBuyingPowerChangeNotifier);

              return Text(
                InvestrendTheme.formatMoneyDouble(
                  //rdnBalance.state,
                  value.cashAvailable,
                  prefixRp: true,
                ),
                style: InvestrendTheme.of(context).regular_w600,
                textAlign: TextAlign.end,
              );
            }),
            /*
            ValueListenableBuilder(
              valueListenable: rdnBalanceNotifier,
              builder: (context, double rdnBalance, child) {
                //String totalValueText = InvestrendTheme.formatMoney(value, prefixRp: true);
                return Text(
                  InvestrendTheme.formatMoneyDouble(
                    rdnBalance,
                    prefixRp: true,
                  ),
                  style: InvestrendTheme.of(context).regular_w700,
                  textAlign: TextAlign.end,
                );
              },
            ),
             */
            // Text(
            //   InvestrendTheme.formatMoney(
            //     rdnBalance,
            //     prefixRp: true,
            //   ),
            //   style: InvestrendTheme.of(context).regular_w700,
            //   textAlign: TextAlign.end,
            // ),
          ])
        ],
      ),
    );
  }

  Future doUpdateAccount({bool pullToRefresh = false}) async {
    if (!isActiveAndMounted()) {
      print(orderType!.routeName +
          '.doUpdateAccount Aborted : ' +
          DateTime.now().toString() +
          "  _active : $active  mounted : $mounted pullToRefresh : $pullToRefresh");
      return false;
    }
    print(orderType!.routeName +
        '.doUpdateAccount : ' +
        DateTime.now().toString() +
        "  _active : $active  mounted : $mounted  pullToRefresh : $pullToRefresh");
    onProgressAccount = true;

    int selected = context.read(accountChangeNotifier).index;
    //Account account = InvestrendTheme.of(context).user.getAccount(selected);
    Account? account =
        context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
      //String text = 'No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      String errorNoAccount = 'error_no_account_selected'.tr();
      String text = '$errorNoAccount. accountSize : ' +
          context.read(dataHolderChangeNotifier).user.accountSize().toString();
      InvestrendTheme.of(context).showSnackBar(context, text);
      onProgressAccount = false;
      return false;
    } else {
      List<String> listAccountCode = List.empty(growable: true);
      // InvestrendTheme.of(context).user.accounts.forEach((account) {
      //   listAccountCode.add(account.accountcode);
      // });
      context.read(dataHolderChangeNotifier).user.accounts?.forEach((account) {
        listAccountCode.add(account.accountcode);
      });

      print(orderType!.routeName + ' try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp
          .accountStockPosition(
              '' /*account.brokercode*/,
              listAccountCode,
              context.read(dataHolderChangeNotifier).user.username,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((List<AccountStockPosition>? value) {
        // DebugWriter.information(orderType!.routeName +
        //     ' Got accountStockPosition  accountStockPosition.size : ' +
        //     value!.length.toString());
        if (!mounted) {
          print(orderType!.routeName +
              ' accountStockPosition ignored.  mounted : $mounted');
          onProgressAccount = false;
          return false;
        }
        AccountStockPosition? first =
            (value != null && value.length > 0) ? value.first : null;
        if (first != null && first.ignoreThis()) {
          // ignore in aja
          print(orderType!.routeName +
              ' accountStockPosition ignored.  message : ' +
              first.message);
        } else {
          context.read(accountsInfosNotifier).updateList(value);
          Account? activeAccount = context
              .read(dataHolderChangeNotifier)
              .user
              .getAccount(context.read(accountChangeNotifier).index);
          if (activeAccount != null) {
            AccountStockPosition? accountInfo = context
                .read(accountsInfosNotifier)
                .getInfo(activeAccount.accountcode);
            if (accountInfo != null) {
              //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.rdnBalance);
              //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.cashBalance);
              context.read(buyRdnBuyingPowerChangeNotifier).update(
                  accountInfo.outstandingLimit,
                  accountInfo.availableCash,
                  accountInfo.creditLimit);
            }
          }
        }
      }).onError((e, stackTrace) {
        DebugWriter.information(orderType!.routeName +
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
        return null;
      });
    }
    onProgressAccount = false;
    return true;
  }
  /*
  @override
  Widget createTopInfo(BuildContext context) {
    int buyingPower = 250000000;
    int rdnBalance = 200000000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        children: [
          TableRow(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'trade_buy_label_buying_power'.tr(),
                  style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Image.asset(
                  'images/icons/information.png',
                  height: 12.0,
                  width: 12.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'trade_buy_label_rdn_balance'.tr(),
                  style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Image.asset(
                  'images/icons/information.png',
                  height: 12.0,
                  width: 12.0,
                ),
              ],
            ),
          ]),
          TableRow(children: [
            Text(
                InvestrendTheme.formatMoney(
                  buyingPower,
                  prefixRp: true,
                ),
                style: InvestrendTheme.of(context).regular_w700),
            Text(
              InvestrendTheme.formatMoney(
                rdnBalance,
                prefixRp: true,
              ),
              style: InvestrendTheme.of(context).regular_w700,
              textAlign: TextAlign.end,
            ),
          ])
        ],
      ),
    );
  }
  */
}
