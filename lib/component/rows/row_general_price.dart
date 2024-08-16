import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

class RowGeneralPrice extends StatelessWidget {
  final String? code;
  final String? name;
  final double? price;
  final double? change;
  final double? percentChange;
  final Color? priceColor;
  final bool? firstRow;
  final VoidCallback? onTap;
  final double paddingLeftRight;
  final bool? priceDecimal;
  final bool? isIndex; // index mean change .00
  final bool? threeDecimal;
  RowGeneralPrice(
      this.code, this.price, this.change, this.percentChange, this.priceColor,
      {this.isIndex = true,
      this.name,
      this.firstRow = false,
      this.onTap,
      this.paddingLeftRight = 0,
      this.priceDecimal = true,
      this.threeDecimal =
          false}); //const RowPrice({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      if (StringUtils.isEmtpy(this.name!)) {
        return rowWithoutName(context);
      } else {
        return rowWithName(context);
      }
    } else {
      if (StringUtils.isEmtpy(this.name!)) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            //enableFeedback: true,
            onTap: onTap,
            child: rowWithoutName(context),
          ),
        );
      } else {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            //enableFeedback: true,
            onTap: onTap,
            child: rowWithName(context),
          ),
        );
      }
    }
  }

  Widget rowWithName(BuildContext context) {
    //String changeText = changeDecimal ? InvestrendTheme.formatChange(change, threeDecimal: threeDecimal) : InvestrendTheme.formatComma(change.toInt());
    String changeText;
    if (isIndex!) {
      changeText =
          InvestrendTheme.formatChange(change, threeDecimal: threeDecimal);
    } else {
      changeText = InvestrendTheme.formatNewChange(change);
    }

    return Container(
      // color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight),
      child: Column(
        children: [
          firstRow!
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
                  child: Text(
                    code!,
                    style: InvestrendTheme.of(context).regular_w600_compact,
                  )),
              Text(
                InvestrendTheme.formatPriceDouble(price,
                    showDecimal: priceDecimal, threeDecimal: threeDecimal),
                style: InvestrendTheme.of(context)
                    .regular_w600_compact
                    ?.copyWith(color: priceColor),
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
                    name!,
                    style: InvestrendTheme.of(context)
                        .support_w400_compact
                        ?.copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
              Text(
                //'$change ($percentChange)',
                //InvestrendTheme.formatChange(change, threeDecimal: threeDecimal)+' ('+InvestrendTheme.formatPercentChange(percentChange, threeDecimal: threeDecimal)+')',
                changeText +
                    ' (' +
                    InvestrendTheme.formatPercentChange(percentChange,
                        threeDecimal: threeDecimal) +
                    ')',
                style: InvestrendTheme.of(context)
                    .support_w400_compact
                    ?.copyWith(color: priceColor),
              ),
            ],
          ),
          SizedBox(
            height: 14.0,
          ),
        ],
      ),
    );
  }

  Widget rowWithoutName(BuildContext context) {
    return Container(
      // color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight),
      child: Column(
        children: [
          // firstRow
          //     ? SizedBox(
          //         width: 1.0,
          //       )
          //     : ComponentCreator.divider(context),
          SizedBox(
            height: 14.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                code!,
                style: InvestrendTheme.of(context).regular_w600_compact,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  // color: Colors.lightBlueAccent,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        InvestrendTheme.formatPriceDouble(price,
                            showDecimal: priceDecimal,
                            threeDecimal: threeDecimal),
                        style: InvestrendTheme.of(context)
                            .regular_w600_compact
                            ?.copyWith(color: priceColor),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        InvestrendTheme.formatChange(change,
                                threeDecimal: threeDecimal) +
                            ' (' +
                            InvestrendTheme.formatPercentChange(percentChange,
                                threeDecimal: threeDecimal) +
                            ')',
                        style: InvestrendTheme.of(context)
                            .support_w400_compact
                            ?.copyWith(color: priceColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 14.0,
          ),
        ],
      ),
    );
  }
}
