import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/screens/screen_coming_soon.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_estatement.dart';

//import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CardMutationHistorical extends StatelessWidget {
  final GroupedNotifier notifier;
  final VoidCallback onRetry;
  CardMutationHistorical(this.notifier,{this.onRetry, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool coming_soon = true;
    Widget title;
    if(coming_soon){
      title = ComponentCreator.subtitleNoButtonMore(context, 'card_cash_mutation_historical_title'.tr(), );
    }else{
      title = ComponentCreator.subtitleButtonMore(context, 'card_cash_mutation_historical_title'.tr(), (){

          Navigator.push(context, CupertinoPageRoute(
            builder: (_) => ScreenESatement(), settings: RouteSettings(name: '/e-statement'),));


      },
          image: '', textButton: 'card_cash_mutation_other_month_button'.tr());
    }
    return Container(
      //color: Colors.lightBlueAccent,
      //margin: EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //ComponentCreator.subtitle(context, 'card_cash_mutation_historical_title'.tr()),

          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral),
            child: title,
            /*
            child: ComponentCreator.subtitleButtonMore(context, 'card_cash_mutation_historical_title'.tr(), (){
              if(coming_soon){
                InvestrendTheme.of(context).showSnackBar(context, 'coming_soon_label'.tr());
              }else{
                Navigator.push(context, CupertinoPageRoute(
                  builder: (_) => ScreenESatement(), settings: RouteSettings(name: '/e-statement'),));
              }

            },
                image: '', textButton: 'card_cash_mutation_other_month_button'.tr()),
            */
          ),
          SizedBox(
            height: InvestrendTheme.cardPadding,
          ),

          Padding(
            padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
            child: ValueListenableBuilder(
                valueListenable: notifier,
                builder: (context, GroupedData value, child) {
                  Widget noWidget = notifier.currentState.getNoWidget(onRetry: onRetry);

                  if (noWidget != null) {
                    return Center(
                      child: noWidget,
                    );
                  }

                  List list = List<Widget>.generate(
                      value.datasSize(),
                          (int index) {

                        StringIndex holder = value.elementAt(index);
                        print('index : $index  '+holder.toString());
                        if(holder.number < 0){
                          String group = holder.text;
                          print('group : $group');

                          return Padding(
                            padding: const EdgeInsets.only(bottom: InvestrendTheme.cardPaddingVertical),
                            child: Text(
                              group,
                              style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                            ),
                          );
                        }else{
                          Mutasi mutasi = value.map[holder.text].elementAt(holder.number) as Mutasi;
                          return createRowMutasi(context, mutasi);
                        }
                      }
                  );
                  return Container(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: list,
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  AutoSizeGroup groupDate = AutoSizeGroup();
  Widget createRowMutasi(BuildContext context, Mutasi mutasi) {
    TextStyle styleDate = InvestrendTheme.of(context).small_w600_compact_greyDarker;
    TextStyle styleNominal = InvestrendTheme.of(context).small_w600_compact;
    TextStyle styleContent = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: AutoSizeText(mutasi.dateMonth ?? '-', style: styleDate, maxLines: 1, minFontSize: 6.0, group: groupDate,)),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(InvestrendTheme.formatMoneyDouble(mutasi.amount, decimal: false) ?? '-', style: styleNominal),
                    SizedBox(height: 4.0,),
                    Text(mutasi.info_trx() ?? '-', style: styleContent), // info_trx
                    SizedBox(height: 4.0,),
                    //Text(mutasi.accountcode ?? '-', style: styleContent), // name
                    //SizedBox(height: 4.0,),
                    Text(mutasi.bank ?? '-', style: styleContent),
                  ],
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
          child: ComponentCreator.divider(context),
        ),
      ],
    );
  }
}




class CardCashMutationHistorical extends StatelessWidget {
  final MutasiNotifier notifier;
  final VoidCallback onRetry;

   CardCashMutationHistorical(this.notifier, {this.onRetry, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool coming_soon = false;
    return Container(
      //color: Colors.lightBlueAccent,
      //margin: EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //ComponentCreator.subtitle(context, 'card_cash_mutation_historical_title'.tr()),
          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral),

            child: ComponentCreator.subtitleButtonMore(context, 'card_cash_mutation_historical_title'.tr(), (){
              if(coming_soon){
                InvestrendTheme.of(context).showSnackBar(context, 'coming_soon_label'.tr());
              }else{
                Navigator.push(context, CupertinoPageRoute(
                  builder: (_) => ScreenESatement(), settings: RouteSettings(name: '/e-statement'),));
              }

            },
                image: '', textButton: 'card_cash_mutation_other_month_button'.tr()),
          ),
          SizedBox(
            height: InvestrendTheme.cardPadding,
          ),
          Padding(
            padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
            child: ValueListenableBuilder(
                valueListenable: notifier,
                builder: (context, ResultMutasi data, child) {
                  return Text(
                    coming_soon ? ' - ' : (data.month ?? '-'),
                    style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                  );
                }),
          ),
          Padding(
            padding: EdgeInsets.all(InvestrendTheme.cardPaddingVertical),
            child: ComponentCreator.divider(context),
          ),
          // coming_soon ? Container( color: Colors.orange,
          //     child: ScreenComingSoon(scrollable: false,)):
          Padding(
            padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
            child: ValueListenableBuilder(
                valueListenable: notifier,
                builder: (context, ResultMutasi data, child) {

                  // if(coming_soon){
                  //   return ConstrainedBox(constraints:BoxConstraints(
                  //     maxHeight: MediaQuery.of(context).size.width
                  //   ),child: ScreenComingSoon(scrollable: false,));
                  // }


                  Widget noWidget = notifier.currentState.getNoWidget(onRetry: onRetry);

                  if (noWidget != null) {
                    return Center(
                      child: noWidget,
                    );
                  }
                  List list = List<Widget>.generate(
                      data.count(),
                          (int index) {
                        return createRowMutasi(context, data.datas.elementAt(index));
                      }
                  );
                  return Container(
                    width: double.maxFinite,
                    child: Column(
                      children: list,
                    ),
                  );
                }),

          ),

        ],
      ),
    );
  }

  AutoSizeGroup groupDate = AutoSizeGroup();
  Widget createRowMutasi(BuildContext context, Mutasi mutasi) {
    TextStyle styleDate = InvestrendTheme.of(context).small_w600_compact_greyDarker;
    TextStyle styleNominal = InvestrendTheme.of(context).small_w600_compact;
    TextStyle styleContent = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: AutoSizeText(mutasi.date ?? '-', style: styleDate, maxLines: 1, minFontSize: 6.0, group: groupDate,)),
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(InvestrendTheme.formatMoneyDouble(mutasi.amount, decimal: false) ?? '-', style: styleNominal),
                    SizedBox(height: 4.0,),
                    Text(mutasi.info_trx() ?? '-', style: styleContent), // info_trx
                    SizedBox(height: 4.0,),
                    Text(mutasi.accountcode ?? '-', style: styleContent), // name
                    SizedBox(height: 4.0,),
                    Text(mutasi.bank ?? '-', style: styleContent),
                  ],
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
          child: ComponentCreator.divider(context),
        ),
      ],
    );
  }

  Widget historicalRDN(BuildContext context, ActivityRDNData data) {
    TextStyle small600 = InvestrendTheme.of(context).small_w600;
    TextStyle small400 = InvestrendTheme.of(context).small_w400;
    TextStyle smallLighter400 = small400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    TextStyle smallDarker400 = small400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle reguler600 = InvestrendTheme.of(context).regular_w600;

    const double paddingTopBottom = 15.0;
    const double paddingHeaderTopBottom = 10.0;
    List<TableRow> list = List.empty(growable: true);
    list.add(TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        child: Text('date_label'.tr(), style: small600),
      ),
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        child: Text('transaction_label'.tr(), style: small600),
      ),
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        child: Text(
          'value_label'.tr(),
          style: small600,
          textAlign: TextAlign.center,
        ),
      ),
    ]));

    list.add(TableRow(children: [
      ComponentCreator.divider(context, thickness: 1.0),
      ComponentCreator.divider(context, thickness: 1.0),
      ComponentCreator.divider(context, thickness: 1.0),
    ]));
    // list.add(TableRow(children: [
    //   SizedBox(height: paddingTopBottom,),
    //   SizedBox(height: paddingTopBottom,),
    //   SizedBox(height: paddingTopBottom,),
    // ]));

    if (data.count() > 0) {
      bool first = true;
      data.datas.forEach((rdn) {
        if (!first) {
          list.add(TableRow(children: [
            ComponentCreator.divider(context),
            ComponentCreator.divider(context),
            ComponentCreator.divider(context),
          ]));
        }
        first = false;
        list.add(TableRow(children: [
          Padding(
            padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
            child: Text(rdn.date, style: smallDarker400),
          ),
          Padding(
            padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
            child: Text(rdn.transaction, style: smallLighter400),
          ),
          Padding(
            padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  InvestrendTheme.formatMoney(rdn.value, prefixRp: true),
                  style: reguler600,
                  textAlign: TextAlign.right,
                )),
          ),
        ]));
      });
    }

    return Table(
      columnWidths: {
        0: FractionColumnWidth(.30),
        1: FractionColumnWidth(.25),
        2: FractionColumnWidth(.45),
      },
      children: list,
    );
  }
}
