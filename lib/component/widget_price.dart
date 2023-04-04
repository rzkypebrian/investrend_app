import 'package:Investrend/component/bottom_sheet/bottom_sheet_alert.dart';
import 'package:Investrend/component/buttons_attention.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';


class WidgetPrice extends StatelessWidget {
  String code;
  String name;
  double close;
  double change;
  double percentChange;
  VoidCallback onPressedButtonBoard;
  VoidCallback onPressedButtonImportantInformation;
  VoidCallback onPressedButtonCorporateAction;
  Color corporateActionColor;
  StockInformationStatus stockInformationStatus;
  String attentionCodes;
  ValueNotifier<bool> animateSpecialNotationNotifier;
  final String heroTag;
  bool isIndex;
  WidgetPrice(this.code, this.name, this.close, this.change, this.percentChange, this.isIndex,
      {Key key, this.onPressedButtonBoard, this.onPressedButtonCorporateAction, this.onPressedButtonImportantInformation, this.heroTag, this.corporateActionColor, this.stockInformationStatus, this.attentionCodes, this.animateSpecialNotationNotifier})
      : super(key: key);

  Widget butttonCorporateAction(BuildContext context, double height) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: MaterialButton(
        minWidth: height,
        padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 1.0, bottom: 1.0),
        shape: CircleBorder(
          //borderRadius: BorderRadius.circular(8.0),
        ),
        visualDensity: VisualDensity.compact,
        child: Text(
          'CA',
          style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: InvestrendTheme.of(context).whiteColor),
        ),
        color: corporateActionColor ?? Color(0xFFAD5E0C),
        onPressed: this.onPressedButtonCorporateAction,
      ),
    );
  }

  Widget butttonBoard(BuildContext context, double height) {

    return SizedBox(
      width: height,
      height: height,
      child: IconButton(onPressed: this.onPressedButtonBoard, icon: Image.asset(
        'images/icons/arrow_down.png',
        color: InvestrendTheme.of(context).greyDarkerTextColor,
        width: 15.0,
        height: 15.0,
      ),),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: MaterialButton(
        padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 1.0, bottom: 1.0),
        minWidth: 40,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        visualDensity: VisualDensity.compact,
        //color: Theme.of(context).backgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*
            Text(
              'board_rg'.tr(),
              style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
            ),
            SizedBox(
              width: 4.0,
            ),
             */
            Image.asset(
              'images/icons/arrow_down.png',
              width: 10.0,
              height: 10.0,
            ),
          ],
        ),
        onPressed: this.onPressedButtonBoard,
      ),
    );
  }

  /*
  Widget buttonSpecialNotation2(BuildContext context, double size) {
    return IconButton(
      constraints: BoxConstraints(maxHeight: size, maxWidth: size),
      padding: EdgeInsets.all(1.0),
      tooltip: 'special_notation'.tr(),
      //splashRadius: 40.0,
      visualDensity: VisualDensity.compact,
      icon: Image.asset(
        'images/icons/special_notation.png',
        width: 13.0,
        height: 13.0,
      ),
      onPressed: () {},
    );
  }
  */
  Widget buttonSpecialNotation(BuildContext context, double height) {


    String image = this.stockInformationStatus != null ? this.stockInformationStatus.image : 'images/icons/special_notation.png';
    if(StringUtils.isEmtpy(image)){
      image = 'images/icons/special_notation.png';
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height, minWidth: height),
      child: MaterialButton(
        minWidth: height,
        padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 1.0, bottom: 1.0),
        shape: CircleBorder(),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(8.0),
        // ),
        visualDensity: VisualDensity.compact,
        child: Image.asset(
           //'images/icons/special_notation.png',
          image,
          width: height,
          height: height,
        ),
        //color: Color(0xFFAD5E0C),
        onPressed: this.onPressedButtonImportantInformation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size textSize = UIHelper.textSize('ABCD', InvestrendTheme.of(context).headline3);

    List<Widget> rowFirstLine = List.empty(growable: true);

    /* ASLI 2021-10-01
    rowFirstLine.add(Container(
      // color: Colors.greenAccent,
      child: Text(
        code,
        style: InvestrendTheme.of(context).headline3,
      ),
    ));
     */

    if(StringUtils.isEmtpy(heroTag)){
      rowFirstLine.add(Text(
        code,
        style: InvestrendTheme.of(context).headline3,
      ));
    }else{
      rowFirstLine.add(Hero(
        tag: heroTag,
        child: Text(
          code,
          style: InvestrendTheme.of(context).headline3,
        ),
      ));
    }

    if (this.onPressedButtonBoard != null) {
      rowFirstLine.add(butttonBoard(context, textSize.height));
    }
    /*
    if (this.onPressedButtonImportantInformation != null) {
      // rowFirstLine.add(
      //   buttonSpecialNotation(context, textSize.height),
      // );
      rowFirstLine.add(
        //ButtonSpecialNotation(textSize.height, onPressedButtonImportantInformation, stockInformationStatus,animateSpecialNotationNotifier:animateSpecialNotationNotifier),
        ButtonSpecialNotationAnimation(textSize.height, onPressedButtonImportantInformation, stockInformationStatus,animateSpecialNotationNotifier:animateSpecialNotationNotifier),
      );
    }
    */
    if (this.onPressedButtonCorporateAction != null) {
      rowFirstLine.add(
        ButtonCorporateAction(textSize.height,  corporateActionColor, onPressedButtonCorporateAction)
      );
    }


    if (this.onPressedButtonImportantInformation != null && (!StringUtils.isEmtpy(attentionCodes) || stockInformationStatus.strip)) {
      // rowFirstLine.add(
      //   ButtonTextAttention(attentionCodes, textSize.height, onPressedButtonImportantInformation,)
      // );
      // rowFirstLine.add(SizedBox(width: 8.0,));
      rowFirstLine.add(
          ButtonTextAttentionMozaic(attentionCodes, textSize.height -3, stockInformationStatus, onPressedButtonImportantInformation, animateSpecialNotationNotifier:animateSpecialNotationNotifier)
          // ButtonTextAttentionMozaic('ABCDEGHJKQRP', textSize.height-3, onPressedButtonImportantInformation,)
        //ButtonTextAttentionMozaic('ABCDE', textSize.height -3, stockInformationStatus,onPressedButtonImportantInformation,)

          // ButtonTextAttentionMozaic('ABCDEGHJK', textSize.height - 3, stockInformationStatus,onPressedButtonImportantInformation,)
      );

      // rowFirstLine.add(
      //     ButtonTextAttentionMozaic('ABCD', textSize.height -3, StockInformationStatus.Suspended, (){},)
      // );
    }
    rowFirstLine.add(Spacer(flex: 1));
    rowFirstLine.add(Container(
      // color: Colors.yellow,
      child: Text(
        ' ' + InvestrendTheme.formatPriceDouble(close, showDecimal: isIndex),
        style: InvestrendTheme.of(context).headline3.copyWith(color: InvestrendTheme.changeTextColor(change), height: 1.0),
      ),
      /*
      child: Row(
        children: [
          change != 0 ? InvestrendTheme.getChangeImage(change) : SizedBox(height: 1.0,),
          Text(
            ' ' + InvestrendTheme.formatPriceDouble(close, showDecimal: isIndex),
            style: InvestrendTheme.of(context).headline3.copyWith(color: InvestrendTheme.changeTextColor(change), height: 1.0),
          ),
        ],
      ),
       */
    ));


    String changeText;
    if(isIndex){
      changeText = InvestrendTheme.formatNewChange(change, decimalValue: 2);
    }else{
      changeText = InvestrendTheme.formatNewChange(change);
    }

    return Container(
      // color: Colors.purple,
      child: Column(
        children: [
          Container(
            // color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: rowFirstLine,
              /*
              children: [
                Container(
                  // color: Colors.greenAccent,
                  child: Text(
                    code,
                    style: InvestrendTheme.of(context).headline3,
                  ),
                ),
                butttonBoard(context, textSize.height),
                buttonSpecialNotation(context, textSize.height),
                butttonCorporateAction(context, textSize.height),
                Spacer(
                  flex: 1,
                ),
                Container(
                  // color: Colors.yellow,
                  child: Row(
                    children: [
                      InvestrendTheme.getChangeImage(change),
                      Text(
                        ' ' + InvestrendTheme.formatPriceDouble(close, showDecimal: false),
                        style: InvestrendTheme.of(context).headline3.copyWith(color: InvestrendTheme.changeTextColor(change)),
                      ),
                    ],
                  ),
                ),
              ],
              */
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Container(
            //color: Colors.orange,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    //color: Colors.green,
                    child: Text(
                      //'nama yang sangat panjang sekali bisa bisa kepanjangan',
                      name,
                      maxLines: 1,
                      style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                    ),
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                Container(
                  //color: Colors.yellow,
                  child: Text(
                    '  ' + changeText + ' (' + InvestrendTheme.formatPercentChange(percentChange) + ')',
                    style: InvestrendTheme.of(context).regular_w400.copyWith(
                      color: InvestrendTheme.changeTextColor(change),
                      height: 1.0,
                    ),

                    /*
                  child: Text(
                    '  ' + InvestrendTheme.formatChange(change) + ' (' + InvestrendTheme.formatPercentChange(percentChange) + ')',
                    style: InvestrendTheme.of(context).regular_w400.copyWith(
                          color: InvestrendTheme.changeTextColor(change),
                          height: 1.0,
                        ),
                    */
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
