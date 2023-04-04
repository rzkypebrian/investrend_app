import 'dart:math';

import 'package:Investrend/component/buttons_attention.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RowWatchlist extends StatelessWidget {
  final WatchlistPrice data;
  AutoSizeGroup groupBest;

  // final String code;
  // final String name;
  // final double price;
  // final double change;
  // final double percentChange;
  // final Color priceColor;
  final bool firstRow;
  final VoidCallback onTap;
  final double paddingLeftRight;
  VoidCallback onPressedButtonSpecialNotation;
  VoidCallback onPressedButtonCorporateAction;
  final bool showBidOffer;
  final double widthRight;
  final StockInformationStatus stockInformationStatus;

  // RowWatchlist(this.code, this.price, this.change, this.percentChange, this.priceColor,
  //     {this.name, this.firstRow = false, this.onTap, this.paddingLeftRight = 0}); //const RowPrice({Key key}) : super(key: key);

  RowWatchlist(this.data,
      {this.firstRow = false,
      this.onTap,
      this.paddingLeftRight = 0,
      this.groupBest,
      this.onPressedButtonSpecialNotation,
      this.onPressedButtonCorporateAction,
      this.showBidOffer = true,
      this.widthRight = 0.0,
      this.stockInformationStatus}); //const RowPrice({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget row = showBidOffer ? rowWithBidOffer(context) : rowWithName(context);

    if (onTap == null) {
      // if(showBidOffer){
      //   return rowWithName(context);
      // }
      // return rowWithName(context);
      return row;
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          //enableFeedback: true,
          onTap: onTap,
          child: data == null
              ? SizedBox(
                  width: 1.0,
                )
              : row, //rowWithName(context),
        ),
      );
    }
  }

  Widget bestPriceLot(BuildContext context, String label, int price, int lot) {
    if (price == 0 || lot == 0) {
      return AutoSizeText.rich(
        TextSpan(
          text: label + ' : ',
          style: InvestrendTheme.of(context).more_support_w400_compact_greyDarker,
          children: [
            TextSpan(
              text: '-',
              style: InvestrendTheme.of(context).support_w400_compact_greyLighter,
            ),
          ],
        ),
        group: groupBest,
        maxLines: 1,
        minFontSize: 6.0,
        textAlign: TextAlign.left,
      );
    }
    return AutoSizeText.rich(
      TextSpan(
        text: label + ' : ',
        style: InvestrendTheme.of(context).more_support_w400_compact_greyDarker,
        children: [
          TextSpan(
            text: InvestrendTheme.formatComma(price),
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.priceTextColor(price, prev: data.prevPrice)),
          ),
          TextSpan(
            text: ' x ',
            style: InvestrendTheme.of(context).support_w400_compact_greyLighter,
          ),
          TextSpan(
            text: InvestrendTheme.formatCompact(context, lot),
            style: InvestrendTheme.of(context).support_w400_compact_greyDarker,
          ),
        ],
      ),
      group: groupBest,
      maxLines: 1,
      minFontSize: 6.0,
      textAlign: TextAlign.left,
    );
  }

  static double calculateWidthRight(BuildContext context, double price, double change, double percentChange) {
    String priceText = InvestrendTheme.formatPriceDouble(price, showDecimal: false);
    String changeText = InvestrendTheme.formatNewChange(change);
    String percentChangeText = InvestrendTheme.formatNewPercentChange(percentChange);
    String changePercentChangeText = changeText + ' (' + percentChangeText + ')';
    TextStyle priceStyle = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle changeStyle = InvestrendTheme.of(context).support_w400_compact;
    Size priceSize = UIHelper.textSize(priceText, priceStyle);
    Size changeSize = UIHelper.textSize(changePercentChangeText, changeStyle);

    return max(priceSize.width, changeSize.width);
  }

  Widget rowWithName(BuildContext context) {
    String changeText = InvestrendTheme.formatNewChange(data.change);
    String percentChangeText = InvestrendTheme.formatNewPercentChange(data.percent);

    List<Widget> firstLineLeft = List.empty(growable: true);
    //double heightIcon = InvestrendTheme.of(context).regular_w600_compact.height;
    Size textSize = UIHelper.textSize('ABCD', InvestrendTheme.of(context).regular_w600_compact);
    double heightIcon = textSize.height;
    //double heightIcon = 25;
    firstLineLeft.add(Text(
      data.code,
      style: InvestrendTheme.of(context).regular_w600_compact,
    ));
    if (data.notation != null && (data.notation.isNotEmpty || data.status == StockInformationStatus.Suspended)) {
      // firstLineLeft.add(SizedBox(
      //   width: InvestrendTheme.cardPadding,
      // ));
      // firstLineLeft.add(SizedBox(
      //     width: heightIcon,
      //     child: ButtonSpecialNotation(
      //       heightIcon,
      //       onPressedButtonSpecialNotation,
      //       data.status,
      //       padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
      //     )));

      // firstLineLeft.add(
      //   SizedBox(
      //     width: heightIcon,
      //     child: ButtonTextAttentionMozaic(
      //       data.attentionCodes,
      //       heightIcon,
      //       data.status,
      //       onPressedButtonSpecialNotation,
      //     ),
      //   ),
      // );

      firstLineLeft.add(ButtonTextAttentionMozaic(
        data.attentionCodes,
        heightIcon,
        data.status,
        onPressedButtonSpecialNotation,
      ),);
    }

    if (data.corporateAction != null && data.corporateAction.isNotEmpty) {
      // firstLineLeft.add(SizedBox(
      //   width: InvestrendTheme.cardPadding,
      // ));
      firstLineLeft.add(ButtonCorporateAction(
        heightIcon,
        data.corporateActionColor,
        onPressedButtonCorporateAction,
        style: InvestrendTheme.of(context).more_support_w600_compact.copyWith(color: InvestrendTheme.of(context).textWhite),
        padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
      ),);

      // firstLineLeft.add(SizedBox(
      //   width: heightIcon,
      //   child: ButtonCorporateAction(
      //     heightIcon,
      //     data.corporateActionColor,
      //     onPressedButtonCorporateAction,
      //     style: InvestrendTheme.of(context).more_support_w600_compact.copyWith(color: InvestrendTheme.of(context).textWhite),
      //     padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
      //   ),
      // ));
    }

    List<Widget> columnList = [
      firstRow
          ? SizedBox(
              width: 1.0,
            )
          : ComponentCreator.divider(context),
      SizedBox(
        height: 14.0,
      ),
      Row(
        children: [
          Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: firstLineLeft,
                /*
                    children: [
                      Text(
                        data.code,
                        style: InvestrendTheme.of(context).regular_w600_compact,
                      ),
                    ],
                     */
              )),
          Text(
            InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
            style: InvestrendTheme.of(context).regular_w600_compact.copyWith(color: data.priceColor),
          ),
        ],
      ),
      SizedBox(
        height: 5.0,
      ),
      Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(
                data.name,
                style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          Text(
            //'$change ($percentChange)',
            //InvestrendTheme.formatChange(change, threeDecimal: threeDecimal)+' ('+InvestrendTheme.formatPercentChange(percentChange, threeDecimal: threeDecimal)+')',
            changeText + ' (' + percentChangeText + ')',
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: data.priceColor),
          ),
        ],
      ),
    ];

    if (showBidOffer) {
      columnList.add(SizedBox(
        height: 6.5,
      ));
      columnList.add(Row(
        children: [
          Expanded(
              flex: 1,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: bestPriceLot(context, 'Bid', data?.bestBidPrice, data?.bestBidLot()),
                  ),
                  Expanded(
                    flex: 1,
                    child: bestPriceLot(context, 'Ask', data?.bestOfferPrice, data?.bestOfferLot()),
                  ),
                ],
              )),
          Text(
            //'$change ($percentChange)',
            //InvestrendTheme.formatChange(change, threeDecimal: threeDecimal)+' ('+InvestrendTheme.formatPercentChange(percentChange, threeDecimal: threeDecimal)+')',
            changeText + ' (' + percentChangeText + ')',
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: Colors.transparent),
          ),
        ],
      ));
    }
    columnList.add(SizedBox(
      height: 14.0,
    ));

    return Container(
      // color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight),
      child: Column(
        children: columnList,
      ),
    );
  }

  Widget rowWithBidOffer(BuildContext context) {
    String changeText = InvestrendTheme.formatNewChange(data.change);
    String percentChangeText = InvestrendTheme.formatNewPercentChange(data.percent);

    String changePercentChangeText = changeText + ' (' + percentChangeText + ')';

    List<Widget> firstLineLeft = List.empty(growable: true);
    //double heightIcon = InvestrendTheme.of(context).regular_w600_compact.height;
    Size textSize = UIHelper.textSize('ABCD', InvestrendTheme.of(context).regular_w600_compact);
    double heightIcon = textSize.height;
    //double heightIcon = 25;
    firstLineLeft.add(Text(
      data.code,
      style: InvestrendTheme.of(context).regular_w600_compact,
    ));
    if (data.notation != null && (data.notation.isNotEmpty || data.status == StockInformationStatus.Suspended)) {
      // firstLineLeft.add(SizedBox(
      //   width: InvestrendTheme.cardPadding,
      // ));
      // firstLineLeft.add(
      //   SizedBox(
      //     width: heightIcon,
      //     child: ButtonSpecialNotation(
      //       heightIcon,
      //       onPressedButtonSpecialNotation,
      //       data.status,
      //       padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
      //     ),
      //   ),
      // );
      firstLineLeft.add(ButtonTextAttentionMozaic(
        data.attentionCodes,
        heightIcon,
        data.status,
        onPressedButtonSpecialNotation,
      ),);

      // firstLineLeft.add(
      //   SizedBox(
      //     width: heightIcon,
      //     height: heightIcon,
      //     child: ButtonTextAttentionMozaic(
      //       data.attentionCodes,
      //       heightIcon,
      //       data.status,
      //       onPressedButtonSpecialNotation,
      //     ),
      //
      //     // child: ButtonTextAttentionMozaic(
      //     //     heightIcon,
      //     //     onPressedButtonSpecialNotation,
      //     //     data.status,
      //     //     padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
      //     //   )
      //   ),
      // );
    }

    if (data.corporateAction != null && data.corporateAction.isNotEmpty) {
      // firstLineLeft.add(SizedBox(
      //   width: InvestrendTheme.cardPadding,
      // ));
      firstLineLeft.add(ButtonCorporateAction(
        heightIcon,
        data.corporateActionColor,
        onPressedButtonCorporateAction,
        style: InvestrendTheme.of(context).more_support_w600_compact.copyWith(color: InvestrendTheme.of(context).textWhite),
        padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
      ),);

      // firstLineLeft.add(SizedBox(
      //   width: heightIcon,
      //   child: ButtonCorporateAction(
      //     heightIcon,
      //     data.corporateActionColor,
      //     onPressedButtonCorporateAction,
      //     style: InvestrendTheme.of(context).more_support_w600_compact.copyWith(color: InvestrendTheme.of(context).textWhite),
      //     padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
      //   ),
      // ));
    }
    /*
    List<Widget> columnList = [
      firstRow
          ? SizedBox(
        width: 1.0,
      )
          : ComponentCreator.divider(context),
      SizedBox(
        height: 14.0,
      ),
      Row(
        children: [
          Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: firstLineLeft,
                /*
                    children: [
                      Text(
                        data.code,
                        style: InvestrendTheme.of(context).regular_w600_compact,
                      ),
                    ],
                     */
              )),
          Text(
            InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
            style: InvestrendTheme.of(context).regular_w600_compact.copyWith(color: data.priceColor),
          ),
        ],
      ),
      SizedBox(
        height: 5.0,
      ),
      Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(
                data.name,
                style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          Text(
            //'$change ($percentChange)',
            //InvestrendTheme.formatChange(change, threeDecimal: threeDecimal)+' ('+InvestrendTheme.formatPercentChange(percentChange, threeDecimal: threeDecimal)+')',
            changeText + ' (' + percentChangeText + ')',
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: data.priceColor),
          ),
        ],
      ),

      SizedBox(
        height: 6.5,
      ),

      Row(
        children: [
          Expanded(
              flex: 1,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: bestPriceLot(context, 'Bid', data?.bestBidPrice, data?.bestBidLot()),
                  ),
                  Expanded(
                    flex: 1,
                    child: bestPriceLot(context, 'Ask', data?.bestOfferPrice, data?.bestOfferLot()),
                  ),
                ],
              )),
          Text(
            //'$change ($percentChange)',
            //InvestrendTheme.formatChange(change, threeDecimal: threeDecimal)+' ('+InvestrendTheme.formatPercentChange(percentChange, threeDecimal: threeDecimal)+')',
            changeText + ' (' + percentChangeText + ')',
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: Colors.transparent),
          ),
        ],
      ),
      SizedBox(
        height: 14.0,
      )
    ];
    */

    Widget rightWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
          style: InvestrendTheme.of(context).regular_w600_compact.copyWith(color: data.priceColor),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          //'$change ($percentChange)',
          //InvestrendTheme.formatChange(change, threeDecimal: threeDecimal)+' ('+InvestrendTheme.formatPercentChange(percentChange, threeDecimal: threeDecimal)+')',
          //changeText + ' (' + percentChangeText + ')',
          changePercentChangeText,
          style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: data.priceColor),
        ),
      ],
    );

    if (widthRight > 0.0) {
      rightWidget = Container(
        //color: Colors.grey,
        width: widthRight,
        child: rightWidget,
      );
    }
    return Container(
      // color: Theme.of(context).backgroundColor,
      //color: Colors.blue,
      padding: EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight),
      child: Column(
        children: [
          firstRow
              ? SizedBox(
                  width: 1.0,
                )
              : ComponentCreator.divider(context),
          SizedBox(
            height: 14.0,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: firstLineLeft,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      data.name,
                      style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 6.5,
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: bestPriceLot(context, 'Bid', data?.bestBidPrice, data?.bestBidLot()),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: bestPriceLot(context, 'Ask', data?.bestOfferPrice, data?.bestOfferLot()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                //color: Colors.grey,
                //height: 50,
                width: 5.0,
              ),
              rightWidget,
            ],
          ),
          SizedBox(
            height: 14.0,
          )
        ],
      ),
    );
  }
}
