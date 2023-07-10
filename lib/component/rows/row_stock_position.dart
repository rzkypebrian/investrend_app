import 'package:Investrend/component/buttons_attention.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RowStockPositions extends StatefulWidget {
  StockPositionDetail portfolio;

  final bool firstRow;
  final VoidCallback onTap;
  final double paddingLeftRight;
  final StockSummary summary;
  final bool modeProfile;
  final Function callbackChecked;
  final bool showToPublic;
  final VoidCallback onPressedButtonSpecialNotation;
  final VoidCallback onPressedButtonCorporateAction;

  RowStockPositions(this.portfolio,
      {this.onPressedButtonSpecialNotation,
      this.onPressedButtonCorporateAction,
      this.showToPublic = false,
      this.callbackChecked,
      this.modeProfile = false,
      this.firstRow = false,
      this.onTap,
      this.paddingLeftRight = 0.0,
      this.summary});

  @override
  _RowStockPositionsState createState() => _RowStockPositionsState();
}

class _RowStockPositionsState extends State<RowStockPositions> {
  ValueNotifier<bool> _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier(widget.showToPublic);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return row(context);
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          //enableFeedback: true,
          onTap: widget.onTap,
          child: widget.modeProfile ? rowProfile(context) : row(context),
        ),
      );
    }
  }

  Widget row(BuildContext context) {
    TextStyle regular700 = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle moreSupport400 = InvestrendTheme.of(context).more_support_w400_compact;

    Color gainLossColor = InvestrendTheme.changeTextColor(widget.portfolio.stockGL);
    String gainLossText = InvestrendTheme.formatMoneyDouble(widget.portfolio.stockGL, prefixPlus: true, prefixRp: true);
    gainLossText = gainLossText + ' (' + InvestrendTheme.formatPercent(widget.portfolio.stockGLPct, prefixPlus: true) + ')';

    int price = 0;
    double change = 0;
    double percentChange = 0;
    if (widget.summary != null) {
      price = widget.summary.close;
      change = widget.summary.change;
      percentChange = widget.summary.percentChange;
    }

    Color marketColor = InvestrendTheme.changeTextColor(change);
    String changeText = InvestrendTheme.formatMoneyDouble(change, prefixPlus: true, prefixRp: false);
    changeText = changeText + ' (' + InvestrendTheme.formatPercent(percentChange, prefixPlus: true) + ')';

    String lotAverage = InvestrendTheme.formatPrice(widget.portfolio.netBalance.toInt()) + ' Lot | Avg ';
    lotAverage = lotAverage + InvestrendTheme.formatPrice(widget.portfolio.avgPrice.toInt());

    List<Widget> firstColumn = List.empty(growable: true);
    List<Widget> listAttention = List.empty(growable: true);
    firstColumn.add(Text(widget.portfolio.stockCode, style: regular700));

    String attentionCodes;
    List<Remark2Mapping> notation = List.empty(growable: true);
    StockInformationStatus status;
    SuspendStock suspendStock;
    List<CorporateActionEvent> corporateAction = List.empty(growable: true);
    Color corporateActionColor = Colors.black;
    try {
      attentionCodes = context.read(remark2Notifier).getSpecialNotationCodes(widget.portfolio.stockCode);
      notation = context.read(remark2Notifier).getSpecialNotation(widget.portfolio.stockCode);
      status = context.read(remark2Notifier).getSpecialNotationStatus(widget.portfolio.stockCode);
      suspendStock = context.read(suspendedStockNotifier).getSuspended(widget.portfolio.stockCode, Stock.defaultBoardByCode(widget.portfolio.stockCode));
      if(suspendStock != null){
        status = StockInformationStatus.Suspended;
      }
      corporateAction = context.read(corporateActionEventNotifier).getEvent(widget.portfolio.stockCode);
      corporateActionColor = CorporateActionEvent.getColor(corporateAction);
    } catch (e) {
      print(e);
    }

    Size textSize = UIHelper.textSize('ABCD', regular700);
    double heightIcon = textSize.height;
    if (notation != null && notation.isNotEmpty) {
      listAttention.add(Container(
          width: heightIcon,
          child: ButtonSpecialNotation(
            heightIcon,
            widget.onPressedButtonSpecialNotation,
            status,
            padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
          )));
      listAttention.add(SizedBox(
        width: InvestrendTheme.cardPadding,
      ));
    }

    if (corporateAction != null && corporateAction.isNotEmpty) {
      listAttention.add(SizedBox(
          width: heightIcon,
          child: ButtonCorporateAction(
            heightIcon,
            corporateActionColor,
            widget.onPressedButtonCorporateAction,
            style: InvestrendTheme.of(context).more_support_w600_compact.copyWith(color: InvestrendTheme.of(context).textWhite),
            padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
          )));
      listAttention.add(SizedBox(
        width: InvestrendTheme.cardPadding,
      ));
    }
    if (listAttention.isNotEmpty) {
      firstColumn.add(SizedBox(height: 5.0,));
      firstColumn.add(Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: listAttention,
      ));
    }
    if(!StringUtils.isEmtpy(attentionCodes)){
      firstColumn.add(SizedBox(height: 5.0,));
      firstColumn.add(ButtonTextAttention(attentionCodes, textSize.height, widget.onPressedButtonSpecialNotation,));
    }
    return Container(
      // color: Colors.lightBlueAccent,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: widget.paddingLeftRight, right: widget.paddingLeftRight),
      child: Column(
        children: [
          widget.firstRow
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: firstColumn,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // asli 2021-09-29
                          //Text(InvestrendTheme.formatMoneyDouble(portfolio.stockVal, prefixRp: true), style: regular700),
                          // philmond minta diganti marketVal
                          Text(InvestrendTheme.formatMoneyDouble(widget.portfolio.marketVal, prefixRp: true), style: regular700),
                          SizedBox(
                            height: 5.0,
                          ),
                          AutoSizeText(gainLossText, style: moreSupport400.copyWith(color: gainLossColor)),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(lotAverage, style: moreSupport400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),
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
                    /*
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InvestrendTheme.getChangeImage(change, size: 8.0),
                        Text(InvestrendTheme.formatPrice(price), style: regular700.copyWith(color: marketColor)),
                      ],
                    ),*/
                    Text(InvestrendTheme.formatPrice(price), style: regular700.copyWith(color: marketColor)),
                    SizedBox(
                      height: 5.0,
                    ),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          changeText,
                          style: moreSupport400.copyWith(color: marketColor),
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

  Widget rowProfile(BuildContext context) {
    TextStyle regular700 = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle moreSupport400 = InvestrendTheme.of(context).more_support_w400_compact;

    Color gainLossColor = InvestrendTheme.changeTextColor(widget.portfolio.stockGL);
    String gainLossText = InvestrendTheme.formatMoneyDouble(widget.portfolio.stockGL, prefixPlus: true, prefixRp: true);
    gainLossText = gainLossText + ' (' + InvestrendTheme.formatPercent(widget.portfolio.stockGLPct, prefixPlus: true) + ')';

    int price = 0;
    double change = 0;
    double percentChange = 0;
    if (widget.summary != null) {
      price = widget.summary.close;
      change = widget.summary.change;
      percentChange = widget.summary.percentChange;
    }

    Color marketColor = InvestrendTheme.changeTextColor(change);
    String changeText = InvestrendTheme.formatMoneyDouble(change, prefixPlus: true, prefixRp: false);
    changeText = changeText + ' (' + InvestrendTheme.formatPercent(percentChange, prefixPlus: true) + ')';

    String lotAverage = InvestrendTheme.formatPrice(widget.portfolio.netBalance.toInt()) + ' Lot | Avg ';
    lotAverage = lotAverage + InvestrendTheme.formatPrice(widget.portfolio.avgPrice.toInt());

    return Container(
      // color: Colors.lightBlueAccent,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: widget.paddingLeftRight, right: widget.paddingLeftRight),
      child: Column(
        children: [
          widget.firstRow
              ? SizedBox(
                  width: 1.0,
                )
              : ComponentCreator.divider(context),
          SizedBox(
            height: 14.0,
          ),
          Row(
            children: [
              Text(widget.portfolio.stockCode, style: regular700),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InvestrendTheme.getChangeImage(change, size: 8.0),
                        Text(InvestrendTheme.formatPrice(price), style: regular700.copyWith(color: marketColor)),
                      ],
                    ),
                    */
                    Text(InvestrendTheme.formatPrice(price), style: regular700.copyWith(color: marketColor)),
                    SizedBox(
                      height: 5.0,
                    ),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          changeText,
                          style: moreSupport400.copyWith(color: marketColor),
                          maxLines: 1,
                        )),
                  ],
                ),
              ),
              /*
              SizedBox(
                width: 15.0,
              ),

              Container(
                height: 36.0,
                decoration: BoxDecoration(
                    color: InvestrendTheme.of(context).tileBackground,
                    borderRadius: BorderRadius.circular(2.0),
                    border: Border.all(
                      color: InvestrendTheme.of(context).tileBorder,
                      width: 1.0,
                    )
                ),
                child: ValueListenableBuilder(
                  valueListenable: _notifier,
                  builder: (context, value, child) {

                    Color colorText = value ? InvestrendTheme.greenText : InvestrendTheme.of(context).greyLighterTextColor;
                    return Row(
                      children: [
                        Checkbox(value: value, visualDensity: VisualDensity.compact, activeColor: InvestrendTheme.greenText,onChanged: (value){
                          if(widget.callbackChecked != null){
                            widget.callbackChecked(widget.portfolio,value);
                            _notifier.value = value;
                          }
                        }, ),
                        Text('show_label'.tr(), style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: colorText),),
                        SizedBox(width: 12.0 ,),
                      ],
                    );
                  },
                ),
              )
              */
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
