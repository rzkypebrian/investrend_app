// ignore_for_file: must_be_immutable

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RowPortfolio extends StatelessWidget {
  Portfolio portfolio;

  final bool firstRow;
  final VoidCallback? onTap;
  final double paddingLeftRight;

  RowPortfolio(
    this.portfolio, {
    this.firstRow = false,
    this.onTap,
    this.paddingLeftRight = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return rowPortfolio(context);
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          //enableFeedback: true,
          onTap: onTap,
          child: rowPortfolio(context),
        ),
      );
    }
  }

  Widget rowPortfolio(BuildContext context) {
    TextStyle? regular700 = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle? moreSupport400 =
        InvestrendTheme.of(context).more_support_w400_compact;

    Color? gainLossColor = InvestrendTheme.priceTextColor(portfolio.gainLoss);
    String gainLossText = InvestrendTheme.formatMoney(portfolio.gainLoss,
        prefixPlus: true, prefixRp: true);
    gainLossText = gainLossText +
        ' (' +
        InvestrendTheme.formatPercent(portfolio.gainLossPercent,
            prefixPlus: true) +
        ')';

    Color? marketColor = InvestrendTheme.priceTextColor(portfolio.change);
    String changeText = InvestrendTheme.formatMoney(portfolio.change,
        prefixPlus: true, prefixRp: false);
    changeText = changeText +
        ' (' +
        InvestrendTheme.formatPercent(portfolio.percentChange,
            prefixPlus: true) +
        ')';

    String lotAverage =
        InvestrendTheme.formatComma(portfolio.lot) + ' Lot | Avg ';
    lotAverage = lotAverage + InvestrendTheme.formatPrice(portfolio.average);

    return Container(
      // color: Colors.lightBlueAccent,
      width: double.maxFinite,
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
                flex: 7,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(portfolio.code, style: regular700),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              InvestrendTheme.formatMoney(portfolio.value,
                                  prefixRp: true),
                              style: regular700),
                          SizedBox(
                            height: 5.0,
                          ),
                          AutoSizeText(gainLossText,
                              style: moreSupport400?.copyWith(
                                  color: gainLossColor)),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(lotAverage,
                              style: moreSupport400?.copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InvestrendTheme.getChangeImageInt(portfolio.change,
                            size: 8.0),
                        Text(InvestrendTheme.formatPrice(portfolio.close),
                            style: regular700?.copyWith(color: marketColor)),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          changeText,
                          style: moreSupport400?.copyWith(color: marketColor),
                          maxLines: 1,
                        )),
                  ],
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
