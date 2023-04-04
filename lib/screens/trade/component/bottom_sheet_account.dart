import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

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
    bool isSelected = index == context
        .read(accountChangeNotifier)
        .index;
    print('index : $index  current : ' + context
        .read(accountChangeNotifier)
        .index
        .toString() + '  isSelected : $isSelected');

    Color color = isSelected ? Theme
        .of(context)
        .accentColor : InvestrendTheme
        .of(context)
        .blackAndWhiteText;

    // String type = StringUtils.equalsIgnoreCase(account.type, 'R')
    //     ? 'Regular'
    //     : (StringUtils.equalsIgnoreCase(account.type, 'M') ? 'Margin' : 'Don\'t Know : ' + account.type);



    // int portfolio_value = 200005965;
    // int buying_power = 200005789;
    // int gain_loss_idr = 30000000;
    // double gain_loss_percentage = 14.56;

    int portfolio_value = 0;
    double buying_power = 0;
    int gain_loss_idr = 0;
    double gain_loss_percentage = 0;
    //double rdnBalance = 0;
    double cashBalance = 0;
    double creditLimit = 0;
    if (info != null) {
      portfolio_value = info.totalMarket;
      buying_power = info.outstandingLimit; // harus diisi
      gain_loss_idr = info.totalGL;
      gain_loss_percentage = info.totalGLPct;
      //rdnBalance = info.rdnBalance;
      //cashBalance = info.cashBalance;
      cashBalance = info.availableCash;
      creditLimit = info.creditLimit;
    }

    Color colorGain = InvestrendTheme.priceTextColor(gain_loss_idr);

    List<Widget> list = List.empty(growable: true);


    if (isSelected) {

      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
      //   Expanded(flex: 1, child: RichText(text: TextSpan(
      //     children: [
      //       TextSpan(
      //         text: type, style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: color),
      //       ),
      //       TextSpan(
      //           text: ' - ' + account.accountcode, style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: color),
      //       ),
      //     ]
      // ),),),

        Expanded(flex: 1, child: Text(account.typeString() + ' - ' + account.accountcode, style: InvestrendTheme.of(context).regular_w600_compact.copyWith(color: color),),),

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
            account.typeString() + ' - ' + account.accountcode,
            style: InvestrendTheme
                .of(context)
                .regular_w600_compact
                .copyWith(color: color),
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
                style: InvestrendTheme
                    .of(context)
                    .support_w400_compact
                    .copyWith(color: InvestrendTheme
                    .of(context)
                    .greyLighterTextColor))),
        Expanded(
            flex: 1,
            child: Text(
              'trade_account_buyer_power_label'.tr(),
              style: InvestrendTheme
                  .of(context)
                  .support_w400_compact
                  .copyWith(color: InvestrendTheme
                  .of(context)
                  .greyLighterTextColor),
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
                style: InvestrendTheme
                    .of(context)
                    .small_w400_compact
                    .copyWith(color: InvestrendTheme
                    .of(context)
                    .blackAndWhiteText))),
        Expanded(
            flex: 1,
            child: Text(
              InvestrendTheme.formatMoneyDouble(buying_power, prefixRp: true),
              style: InvestrendTheme
                  .of(context)
                  .small_w400_compact
                  .copyWith(color: InvestrendTheme
                  .of(context)
                  .blackAndWhiteText),
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
            style: InvestrendTheme
                .of(context)
                .support_w400_compact
                .copyWith(color: colorGain)),
        SizedBox(
          width: 4.0,
        ),
        Text(
          '(' + InvestrendTheme.formatPercentChange(gain_loss_percentage, sufixPercent: true) + ')',
          style: InvestrendTheme
              .of(context)
              .support_w400_compact
              .copyWith(color: colorGain),
          textAlign: TextAlign.end,
        ),
      ],
    ));

    return InkWell(
      onTap: () {
        context.read(accountChangeNotifier).setIndex(index);
        //context.read(rdnBalanceStateProvider).state = 0;
        //context.read(buyRdnBuyingPowerChangeNotifier).update(info.outstandingLimit, info.rdnBalance);


        //context.read(buyRdnBuyingPowerChangeNotifier).update(buying_power, rdnBalance);
        context.read(buyRdnBuyingPowerChangeNotifier).update(buying_power, cashBalance, creditLimit);
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

    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    // double heightRowReguler = UIHelper.textSize('WgjLl', InvestrendTheme.of(context).regular_w700_compact).height;
    //
    // double contentHeight = 0.0;
    // contentHeight += 30.0 + 24.0 + 30;

    List<Widget> list = List.empty(growable: true);
    //list.add(getIndicator());
    //int count = InvestrendTheme.of(context).user.accountSize();
    int count = context
        .read(dataHolderChangeNotifier)
        .user
        .accountSize();

    print('accountSize : ' + count.toString());
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        //Account account = InvestrendTheme.of(context).user.getAccount(i);
        Account account = context
            .read(dataHolderChangeNotifier)
            .user
            .getAccount(i);

        if(account != null){
          AccountStockPosition info = infos.getInfo(account.accountcode);
          if (i != 0) {
            list.add(Divider());
          }
          list.add(createRow(context, account, i, info));
        }

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
