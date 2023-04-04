import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
//import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';



class CardEarningPerShare extends StatelessWidget {
  final EarningPerShareNotifier notifier;
  final VoidCallback onRetry;
  const CardEarningPerShare(this.notifier,{this.onRetry, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.only(top: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingVertical),
            child: ComponentCreator.subtitle(context, 'card_earning_per_share_title'.tr()),
          ),
          //SizedBox(height: InvestrendTheme.cardPaddingPlusMargin,),
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, EarningPerShareData data, child) {

              Widget noWidget = notifier.currentState.getNoWidget(onRetry: onRetry);
              if(noWidget != null){
                return Container(
                  width: double.maxFinite,
                    height: 8 * 30.0,
                    child: Center(child: noWidget));
              }
              // if (notifier.invalid()) {
              //   return Center(child: CircularProgressIndicator());
              // }
              // return Placeholder(
              //   fallbackWidth: double.maxFinite,
              //   fallbackHeight: 220.0,
              // );

              return Padding(
                padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                child: createTable(context, data),
              );
            },
          ),
          SizedBox(height: 12.0,),
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, EarningPerShareData data, child) {
              // if (notifier.invalid()) {
              //   return Center(child: CircularProgressIndicator());
              // }
              // return Placeholder(
              //   fallbackWidth: double.maxFinite,
              //   fallbackHeight: 220.0,
              // );
              Widget noWidget = notifier.currentState.getNoWidget(onRetry: onRetry);
              if(noWidget != null){
                return SizedBox(height: 1.0,);
              }

              String info = 'card_earning_per_share_info'.tr()+' '+ data.recentQuarter;
              return Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: 15.0, bottom: 15.0),
                color: InvestrendTheme.of(context).oddColor,
                child: Text(info, style: InvestrendTheme.of(context).small_w400_compact,),
              );
            },
          ),
        ],
      ),
    );
  }


  TableRow createHeader(BuildContext context, String label, List<String> datas){
    TextStyle style = InvestrendTheme.of(context).small_w600_compact;

    int count = datas != null ? datas.length : 0;

    return TableRow(
        children: [
          createTextLeft(context, label, style,),
          createTextCenter(context,(count > 0 ? datas.elementAt(0) : ' ') ,  style),
          createTextCenter(context,(count > 1 ? datas.elementAt(1) : ' ') ,  style),
          createTextCenter(context,(count > 2 ? datas.elementAt(2) : ' ') ,  style),
          createTextCenter(context,(count > 3 ? datas.elementAt(3) : ' ') ,  style),
        ]
    );
  }
  
  TableRow createRow(BuildContext context, String label, List<double> datas){
    TextStyle style = InvestrendTheme.of(context).small_w400_compact;

    int count = datas != null ? datas.length : 0;

    Color color = InvestrendTheme.of(context).greyDarkerTextColor;

    return TableRow(
        children: [
          createTextLeft(context, label, style.copyWith(color: color),),
          createTextCenter(context,(count > 0 && datas.elementAt(0) != 0 ? datas.elementAt(0).toString() : ' ') , style.copyWith(color: datas.elementAt(0) < 0 ? InvestrendTheme.redText : color)),
          createTextCenter(context,(count > 1 && datas.elementAt(1) != 0 ? datas.elementAt(1).toString() : ' ') , style.copyWith(color: datas.elementAt(1) < 0 ? InvestrendTheme.redText : color)),
          createTextCenter(context,(count > 2 && datas.elementAt(2) != 0 ? datas.elementAt(2).toString() : ' ') , style.copyWith(color: datas.elementAt(2) < 0 ? InvestrendTheme.redText : color)),
          createTextCenter(context,(count > 3 && datas.elementAt(3) != 0 ? datas.elementAt(3).toString() : ' ') , style.copyWith(color: datas.elementAt(3) < 0 ? InvestrendTheme.redText : color)),
        ]
    );

    // return TableRow(
    //     children: [
    //       Text(label, style: style,),
    //       Text((count > 0 ? datas.elementAt(0).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 1 ? datas.elementAt(1).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 2 ? datas.elementAt(2).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 3 ? datas.elementAt(3).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //     ]
    // );
  }
  
  
  
  
  TableRow createRowDouble(BuildContext context, String label, List<double> datas){
    TextStyle style = InvestrendTheme.of(context).small_w400_compact;

    int count = datas != null ? datas.length : 0;

    Color color = InvestrendTheme.of(context).greyDarkerTextColor;

    return TableRow(
        children: [
          createTextLeft(context,label, style.copyWith(color: color),),
          createTextCenter(context, (count > 0 && datas.elementAt(0) != 0 ? datas.elementAt(0).toString() : ' ') , style.copyWith(color: datas.elementAt(0) < 0 ? InvestrendTheme.redText : color),),
          createTextCenter(context, (count > 1 && datas.elementAt(1) != 0 ? datas.elementAt(1).toString() : ' ') , style.copyWith(color: datas.elementAt(1) < 0 ? InvestrendTheme.redText : color),),
          createTextCenter(context, (count > 2 && datas.elementAt(2) != 0 ? datas.elementAt(2).toString() : ' ') , style.copyWith(color: datas.elementAt(2) < 0 ? InvestrendTheme.redText : color),),
          createTextCenter(context, (count > 3 && datas.elementAt(3) != 0 ? datas.elementAt(3).toString() : ' ') , style.copyWith(color: datas.elementAt(3) < 0 ? InvestrendTheme.redText : color),),
        ]
    );

    // return TableRow(
    //     children: [
    //       Text(label, style: style,),
    //       Text((count > 0 ? datas.elementAt(0).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 1 ? datas.elementAt(1).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 2 ? datas.elementAt(2).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 3 ? datas.elementAt(3).toString() : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //     ]
    // );
  }
  TableRow createRowPercent(BuildContext context, String label, List<double> datas){
    TextStyle style = InvestrendTheme.of(context).small_w400_compact;

    int count = datas != null ? datas.length : 0;

    Color color = InvestrendTheme.of(context).greyDarkerTextColor;

    return TableRow(
        children: [
          createTextLeft(context,label, style.copyWith(color: color),),
          createTextCenter(context, (count > 0 && datas.elementAt(0) != 0 ? InvestrendTheme.formatPercent(datas.elementAt(0)) : ' ') , style.copyWith(color: datas.elementAt(0) < 0 ? InvestrendTheme.redText : color), ),
          createTextCenter(context, (count > 1 && datas.elementAt(1) != 0 ? InvestrendTheme.formatPercent(datas.elementAt(1)) : ' ') ,  style.copyWith(color: datas.elementAt(1) < 0 ? InvestrendTheme.redText : color), ),
          createTextCenter(context, (count > 2 && datas.elementAt(2) != 0 ? InvestrendTheme.formatPercent(datas.elementAt(2)) : ' ') , style.copyWith(color: datas.elementAt(2) < 0 ? InvestrendTheme.redText : color), ),
          createTextCenter(context, (count > 3 && datas.elementAt(3) != 0 ? InvestrendTheme.formatPercent(datas.elementAt(3)) : ' ') , style.copyWith(color: datas.elementAt(3) < 0 ? InvestrendTheme.redText : color), ),
        ]
    );


    // return TableRow(
    //     children: [
    //       Text(label, style: style,),
    //       Text((count > 0 ? InvestrendTheme.formatPercentChange(datas.elementAt(0)) : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 1 ? InvestrendTheme.formatPercentChange(datas.elementAt(1)) : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 2 ? InvestrendTheme.formatPercentChange(datas.elementAt(2)) : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //       Text((count > 3 ? InvestrendTheme.formatPercentChange(datas.elementAt(3)) : ' ') , style: style.copyWith(color: count < 0 ? InvestrendTheme.redText : color), textAlign: TextAlign.center,),
    //     ]
    // );
  }


  Widget createTextLeft(BuildContext context, String label, TextStyle style){
    return Padding(
      padding: const EdgeInsets.only(top:  12.0, bottom: 12.0),
      child: AutoSizeText(label , style: style, textAlign: TextAlign.left,),
    );
  }
  Widget createTextCenter(BuildContext context, String label, TextStyle style){
    return Padding(
      padding: const EdgeInsets.only( left: 5.0,  top:  12.0, bottom: 12.0),
      child: AutoSizeText(label , style: style, textAlign: TextAlign.center,),
    );
  }

  Widget createTable(BuildContext context, EarningPerShareData data){
    return Table(
      columnWidths: {
        0: FractionColumnWidth(.2),
        1: FractionColumnWidth(.2),
        2: FractionColumnWidth(.2),
        3: FractionColumnWidth(.2),
        4: FractionColumnWidth(.2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        createHeader(context, 'card_earning_per_share_period'.tr(), data.years),
        createRow(context, 'card_earning_per_share_q1'.tr(), data.quarter1),
        createRow(context, 'card_earning_per_share_q2'.tr(), data.quarter2),
        createRow(context, 'card_earning_per_share_q3'.tr(), data.quarter3),
        createRow(context, 'card_earning_per_share_q4'.tr(), data.quarter4),
        divider(context),
        createRow(context, 'card_earning_per_share_eps'.tr(), data.eps),
        divider(context),
        createRowDouble(context, 'card_earning_per_share_dps'.tr(), data.dps),
        divider(context),
        createRowPercent(context, 'card_earning_per_share_dpr'.tr(), data.dpr),
      ],
    );
  }

  TableRow divider(BuildContext context){
    return TableRow(children: [
      Container(
        color: Theme.of(context).dividerColor,
        width: double.maxFinite,
        height: 1.0,
      ),
      Container(
        color: Theme.of(context).dividerColor,
        width: double.maxFinite,
        height: 1.0,
      ),
      Container(
        color: Theme.of(context).dividerColor,
        width: double.maxFinite,
        height: 1.0,
      ),
      Container(
        color: Theme.of(context).dividerColor,
        width: double.maxFinite,
        height: 1.0,
      ),
      Container(
        color: Theme.of(context).dividerColor,
        width: double.maxFinite,
        height: 1.0,
      ),
    ]);
  }
  
  
  




}

/*
class CardEarningPerShareFulFul extends StatefulWidget {
  final ChartNotifier notifier;
  final StringCallback callbackRange;
  

  const CardEarningPerShareFul(this.notifier, {this.callbackRange, Key key}) : super(key: key);

  @override
  _CardEarningPerShareFulState createState() => _CardEarningPerShareFulState();
}

class _CardEarningPerShareFulState extends State<CardEarningPerShareFul> {
  

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_chipsRange(context),
          ValueListenableBuilder(
            valueListenable: widget.notifier,
            builder: (context, ChartData data, child) {
              // if (widget.notifier.invalid()) {
              //   return Center(child: CircularProgressIndicator());
              // }
              return Placeholder(
                fallbackWidth: double.maxFinite,
                fallbackHeight: 220.0,
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _chipsRange(BuildContext context) {
  //   double marginPadding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
  //   // double marginPadding = 0;
  //   return Container(
  //     //color: Colors.green,
  //     margin: EdgeInsets.only( bottom: marginPadding),
  //     width: double.maxFinite,
  //     height: 30.0,
  //
  //     decoration: BoxDecoration(
  //       //color: Colors.green,
  //       color: InvestrendTheme.of(context).tileBackground,
  //       border: Border.all(
  //         color: InvestrendTheme.of(context).chipBorder,
  //         width: 1.0,
  //       ),
  //       borderRadius: BorderRadius.circular(2.0),
  //
  //       //color: Colors.green,
  //     ),
  //
  //     child: Row( 
  //       children: List<Widget>.generate(
  //         _listChipRange.length,
  //             (int index) {
  //           //print(_listChipRange[index]);
  //           bool selected = _selectedRange == index;
  //           return Expanded(
  //             flex: 1,
  //             child: Material(
  //               color: Colors.transparent,
  //               child: InkWell(
  //                 onTap: () {
  //                   setState(() {
  //                     _selectedRange = index;
  //                     if (widget.callbackRange != null) {
  //                       widget.callbackRange(_listChipRange[_selectedRange]);
  //                     }
  //                   });
  //                 },
  //                 child: Container(
  //                   color: selected ? Theme.of(context).accentColor : Colors.transparent,
  //                   child: Center(
  //                       child: Text(
  //                         _listChipRange[index],
  //                       
  //                         style: InvestrendTheme.of(context)
  //                             .more_support_w400_compact
  //                             .copyWith(color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText),
  //                       )),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

}

*/
