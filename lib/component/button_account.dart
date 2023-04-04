import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_account.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class ButtonAccount extends StatelessWidget {
  //final ValueNotifier<String> notifier;
  //final VoidCallback onTap;

  final bool shortDisplay;
  const ButtonAccount(/*this.notifier,this.onTap,*/{this.shortDisplay = false, Key key}) : super(key: key);
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

      print('ButtonAccount try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp.accountStockPosition('' /*account.brokercode*/, listAccountCode, context.read(dataHolderChangeNotifier).user.username, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((value) {
        DebugWriter.information('ButtonAccount Got accountStockPosition  accountStockPosition.size : ' + value.length.toString());

        AccountStockPosition first = (value != null && value.length > 0) ?  value.first : null;
        if(first != null && first.ignoreThis()){
          // ignore in aja
          print('ButtonAccount accountStockPosition ignored.  message : '+first.message);
        }else {
          context.read(accountsInfosNotifier).updateList(value);
          Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
          if(activeAccount != null){
            AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
            if(accountInfo != null){
              //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.rdnBalance);
              //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.cashBalance);
              context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.availableCash, accountInfo.creditLimit);
            }
          }
        }

      }).onError((error, stackTrace) {
        DebugWriter.information('ButtonAccount accountStockPosition Exception : ' + error.toString());
        try{
          if(error is TradingHttpException){
            if(error.isUnauthorized()){
              InvestrendTheme.of(context).showDialogInvalidSession(context);
              return;
            }else{
              String network_error_label = 'network_error_label'.tr();
              network_error_label  = network_error_label.replaceFirst("#CODE#", error.code.toString());
              InvestrendTheme.of(context).showSnackBar(context, network_error_label);
              return;
            }
          }
        }catch(errorAfter){
          DebugWriter.information('ButtonAccount accountStockPosition Exception errorAfter : ' + error.toString());
        }

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    double paddingVertical = 8.0;

    return TextButton(
        style: TextButton.styleFrom(
          visualDensity: shortDisplay ? VisualDensity.compact : null,
            padding: EdgeInsets.only(left: shortDisplay ? 0.0 : InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: paddingVertical, bottom: paddingVertical),
            //minimumSize: Size(50, 30),
            alignment: Alignment.centerLeft),
        onPressed: () {
          updateAccountCashPosition(context);
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            shortDisplay ? SizedBox(width: InvestrendTheme.cardPaddingGeneral,) : SizedBox(height: 1.0,),
            /*
            ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, data, child) {
                return Text(
                  StringUtils.noNullString(data),
                  style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                );
              },
            ),
            */
            Consumer(builder: (context, watch, child) {
              final notifier = watch(accountChangeNotifier);

              User user = context
                  .read(dataHolderChangeNotifier)
                  .user;
              Account active = user.getAccount(notifier.index);
              String nameAndAccount;
              if(active != null){
                if(shortDisplay){
                  nameAndAccount = active.typeShortString();
                }else{
                  nameAndAccount = user.realname + ' - ' + active.typeString() + ' ' + active.accountcode;
                }
              }else{
                  nameAndAccount = ' - ' ;
              }

              return AutoSizeText(
                StringUtils.noNullString(nameAndAccount),
                style: InvestrendTheme
                    .of(context)
                    .regular_w400_compact
                    .copyWith(color: InvestrendTheme
                    .of(context)
                    .greyDarkerTextColor),
                maxLines: 1,
              );
            }),
            SizedBox(
              width: 5.0,
            ),
            Image.asset(
              'images/icons/arrow_down.png',
              width: 6.0,
              height: 6.0,
            ),
          ],
        ));
  }
}
