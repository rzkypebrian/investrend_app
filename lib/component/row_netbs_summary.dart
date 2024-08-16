import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RowNetBSSummary extends StatefulWidget {
  // final Widget text;
  // final int maxLines;
  final ValueNotifier<int>? selectedLineNotifier;
  final double leftWidth;
  final double centerWidth;
  final double rightWidth;
  final int line;
  final NetBuySellSummary? buyer;
  final NetBuySellSummary? seller;
  final TextStyle? style;
  final TextStyle? styleBroker;
  final TextStyle? styleValue;
  final AutoSizeGroup? groupValue;

  const RowNetBSSummary(
    this.leftWidth,
    this.centerWidth,
    this.rightWidth,
    this.styleBroker,
    this.style, {
    this.groupValue,
    this.line = 0,
    this.buyer,
    this.seller,
    this.selectedLineNotifier,
    this.styleValue,
    Key? key,
  }) : super(key: key);

  @override
  _RowNetBSSummaryState createState() => _RowNetBSSummaryState();
}

class _RowNetBSSummaryState extends State<RowNetBSSummary> {
  ValueNotifier<bool> colapseNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    if (widget.selectedLineNotifier != null) {
      widget.selectedLineNotifier!.addListener(() {
        if (widget.line != widget.selectedLineNotifier!.value &&
            !colapseNotifier.value) {
          colapseNotifier.value = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final Color background = Theme.of(context).backgroundColor;
    // final Color fill = InvestrendTheme.of(context).blackAndWhite;
    // final List<Color> gradient = [
    //   background,
    //   background,
    //   fill,
    //   fill,
    // ];
    // final double fillPercent = 20.0; // fills 56.23% for container from bottom
    // final double fillStop = (100 - fillPercent) / 100;
    // final List<double> stops = [0.0, fillStop, fillStop, 1.0];

    return ValueListenableBuilder(
        valueListenable: colapseNotifier,
        builder: (context, bool showMore, child) {
          if (showMore) {
            return TapableWidget(
              child: createRow(
                  context,
                  widget.leftWidth,
                  widget.centerWidth,
                  widget.rightWidth,
                  widget.line,
                  widget.buyer!,
                  widget.seller!,
                  widget.style,
                  widget.styleBroker,
                  widget.styleValue),
              onTap: () {
                colapseNotifier.value = !showMore;

                if (!colapseNotifier.value &&
                    widget.selectedLineNotifier != null) {
                  widget.selectedLineNotifier!.value = widget.line;
                }
              },
            );
            /*
            return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.text,
                  maxLines: showMore ? 10 : null,
                  style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      colapseNotifier.value = !showMore;
                      // setState(() {
                      //   showMore = !showMore;
                      // });
                    },
                    child: Text(
                      showMore ? "button_show_more".tr() : "button_show_less".tr(),
                      textAlign: TextAlign.end,
                      style: InvestrendTheme.of(context)
                          .small_w600
                          .copyWith(color: InvestrendTheme.of(context).investrendPurple/*, fontWeight: FontWeight.bold*/),
                    ),
                  ),
                ),
              ],
            );
             */
          } else {
            return TapableWidget(
              child: createRowWithName(
                  context,
                  widget.leftWidth,
                  widget.centerWidth,
                  widget.rightWidth,
                  widget.line,
                  widget.buyer!,
                  widget.seller!,
                  widget.style,
                  widget.styleBroker,
                  widget.styleValue),
              onTap: () {
                colapseNotifier.value = !showMore;
                if (!colapseNotifier.value &&
                    widget.selectedLineNotifier != null) {
                  widget.selectedLineNotifier!.value = widget.line;
                }
              },
            );
            /*
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.text,
                  maxLines: showMore ? 10 : null,
                  style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      colapseNotifier.value = !showMore;
                      // setState(() {
                      //   showMore = !showMore;
                      // });
                    },
                    child: Text(
                      showMore ? "button_show_more".tr() : "button_show_less".tr(),
                      textAlign: TextAlign.end,
                      style: InvestrendTheme.of(context)
                          .small_w600
                          .copyWith(color: InvestrendTheme.of(context).investrendPurple /*, fontWeight: FontWeight.bold*/),
                    ),
                  ),
                ),
              ],
            );
             */
          }
        });
  }

  Widget createRow(
      BuildContext context,
      double leftWidth,
      double centerWidth,
      double rightWidth,
      int line,
      NetBuySellSummary? buyer,
      NetBuySellSummary? seller,
      TextStyle? styleBroker,
      TextStyle? style,
      TextStyle? styleValue) {
    //TextStyle style = InvestrendTheme.of(context).small_w400_compact;

    String buyerCode = '';
    String buyerValue = '';
    String buyerAverage = '';
    Color? buyerColor;
    if (buyer != null) {
      buyerCode = buyer.Broker!;
      buyerValue = InvestrendTheme.formatValue(context, buyer.Value!);
      buyerAverage = InvestrendTheme.formatComma(buyer.Average!.truncate());
      Broker? buyerBroker = InvestrendTheme.storedData?.findBroker(buyerCode);
      if (buyerBroker != null) {
        buyerColor = buyerBroker.color(context);
      }
    }

    String sellerCode = '';
    String sellerValue = '';
    String sellerAverage = '';
    Color? sellerColor;
    if (seller != null) {
      sellerCode = seller.Broker!;
      sellerValue = InvestrendTheme.formatValue(context, seller.Value!);
      sellerAverage = InvestrendTheme.formatComma(seller.Average!.truncate());
      Broker? sellerBroker = InvestrendTheme.storedData?.findBroker(sellerCode);
      if (sellerBroker != null) {
        sellerColor = sellerBroker.color(context);
      }
    }

    bool odd = (line - 1) % 2 != 0;
    return Container(
      color: odd
          ? InvestrendTheme.of(context).oddColor
          : Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: leftWidth * 0.2,
            child: Text(buyerCode,
                style: styleBroker?.copyWith(
                    color: buyerColor ?? styleBroker.color,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.left),
          ),
          SizedBox(
            width: leftWidth * 0.4,
            child: AutoSizeText(
              buyerAverage,
              style: style,
              textAlign: TextAlign.right,
              group: widget.groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: leftWidth * 0.4,
            child: AutoSizeText(
              buyerValue,
              style: style,
              textAlign: TextAlign.right,
              group: widget.groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: InvestrendTheme.cardPadding,
          ),
          Container(
              width: centerWidth,
              //alignment: Alignment.center,
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              color: InvestrendTheme.of(context).greyLighterTextColor,
              child: AutoSizeText(
                InvestrendTheme.formatNewComma(line.toDouble()),
                style: style?.copyWith(
                    color: InvestrendTheme.of(context).textWhite),
                textAlign: TextAlign.center,
                group: widget.groupValue,
                minFontSize: 5,
                maxLines: 1,
              )),
          SizedBox(
            width: InvestrendTheme.cardPadding,
          ),
          SizedBox(
            width: rightWidth * 0.2,
            child: Text(sellerCode,
                style: styleBroker?.copyWith(
                    color: sellerColor ?? styleBroker.color,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.left),
          ),
          SizedBox(
            width: rightWidth * 0.4,
            child: AutoSizeText(
              sellerAverage,
              style: style,
              textAlign: TextAlign.right,
              group: widget.groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: rightWidth * 0.4,
            child: AutoSizeText(
              sellerValue,
              style: style,
              textAlign: TextAlign.right,
              group: widget.groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget createRowWithName(
      BuildContext context,
      double leftWidth,
      double centerWidth,
      double rightWidth,
      int line,
      NetBuySellSummary? buyer,
      NetBuySellSummary? seller,
      TextStyle? styleBroker,
      TextStyle? style,
      TextStyle? styleValue) {
    //TextStyle style = InvestrendTheme.of(context).small_w400_compact;

    String? buyerName = '';
    String buyerCode = '';
    String buyerValue = '';
    String buyerAverage = '';
    Color? buyerColor;
    if (buyer != null) {
      buyerCode = buyer.Broker!;
      buyerValue = InvestrendTheme.formatValue(context, buyer.Value!);
      buyerAverage = InvestrendTheme.formatComma(buyer.Average!.truncate());
      Broker? buyerBroker = InvestrendTheme.storedData?.findBroker(buyerCode);
      if (buyerBroker != null) {
        buyerName = buyerBroker.name;
        buyerColor = buyerBroker.color(context);
      } else {
        buyerName = '-';
      }
    }
    String? sellerName = '';
    String sellerCode = '';
    String sellerValue = '';
    String sellerAverage = '';
    Color? sellerColor;
    if (seller != null) {
      sellerCode = seller.Broker!;
      sellerValue = InvestrendTheme.formatValue(context, seller.Value!);
      sellerAverage = InvestrendTheme.formatComma(seller.Average!.truncate());
      Broker? sellerBroker = InvestrendTheme.storedData?.findBroker(sellerCode);
      if (sellerBroker != null) {
        sellerName = sellerBroker.name;
        sellerColor = sellerBroker.color(context);
      } else {
        sellerName = '-';
      }
    }

    bool odd = (line - 1) % 2 != 0;
    return Container(
      color: odd
          ? InvestrendTheme.of(context).oddColor
          : Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: leftWidth * 0.2,
                    child: Text(buyerCode,
                        style: styleBroker?.copyWith(
                            color: buyerColor ?? styleBroker.color,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left),
                  ),
                  SizedBox(
                    width: leftWidth * 0.4,
                    child: AutoSizeText(
                      buyerAverage,
                      style: style,
                      textAlign: TextAlign.right,
                      group: widget.groupValue,
                      minFontSize: 5,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    width: leftWidth * 0.4,
                    child: AutoSizeText(
                      buyerValue,
                      style: styleValue ?? style,
                      textAlign: TextAlign.right,
                      group: widget.groupValue,
                      minFontSize: 5,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              SizedBox(
                width: leftWidth,
                child: Text(
                  buyerName!,
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      ?.copyWith(
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
          SizedBox(
            width: InvestrendTheme.cardPadding,
          ),
          Container(
              width: centerWidth,
              //alignment: Alignment.center,
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              color: InvestrendTheme.of(context).greyLighterTextColor,
              child: AutoSizeText(
                InvestrendTheme.formatNewComma(line.toDouble()),
                style: style?.copyWith(
                    color: InvestrendTheme.of(context).textWhite),
                textAlign: TextAlign.center,
                group: widget.groupValue,
                minFontSize: 5,
                maxLines: 1,
              )),
          SizedBox(
            width: InvestrendTheme.cardPadding,
          ),
          Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: rightWidth * 0.2,
                    child: Text(sellerCode,
                        style: styleBroker?.copyWith(
                            color: sellerColor ?? styleBroker.color,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.left),
                  ),
                  SizedBox(
                    width: rightWidth * 0.4,
                    child: AutoSizeText(
                      sellerAverage,
                      style: style,
                      textAlign: TextAlign.right,
                      group: widget.groupValue,
                      minFontSize: 5,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    width: rightWidth * 0.4,
                    child: AutoSizeText(
                      sellerValue,
                      style: styleValue ?? style,
                      textAlign: TextAlign.right,
                      group: widget.groupValue,
                      minFontSize: 5,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              SizedBox(
                width: leftWidth,
                child: Text(
                  sellerName!,
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      ?.copyWith(
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
