import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CardLabelValue extends StatefulWidget {
  final String title;
  final LabelValueData datas;
  final double paddingTop;

  CardLabelValue(this.title, this.datas, {Key key, this.paddingTop = InvestrendTheme.cardPaddingVertical}) : super(key: key);

  @override
  _CardLabelValueState createState() => _CardLabelValueState();
}

class _CardLabelValueState extends State<CardLabelValue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: widget.paddingTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //SizedBox(height: InvestrendTheme.cardPaddingPlusMargin,),
          ComponentCreator.subtitle(context, widget.title),
          SizedBox(
            height: InvestrendTheme.cardPaddingGeneral,
          ),
          createContent(context, widget.datas),
          //SizedBox(height: 10.0,),
        ],
      ),
    );
  }

  Widget row(BuildContext context, LabelValue labelValue) {
    //TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;
    if (labelValue.valueColor != null) {
      valueStyle = valueStyle.copyWith(color: labelValue.valueColor);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            labelValue.label,
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          Expanded(
            flex: 1,
            child: Text(
              labelValue.value,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget rowContentPlace(BuildContext context, ContentPlaceInfo labelValue) {
    //TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle typeStyle = InvestrendTheme.of(context).small_w400_compact;
    TextStyle infoStyle = InvestrendTheme.of(context).more_support_w400_compact.copyWith(height: 1.25);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labelValue.type,
                style: typeStyle,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  labelValue.place1,
                  style: infoStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelValue.time,
                style: infoStyle,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  labelValue.place2,
                  style: infoStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget createContent(BuildContext context, LabelValueData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(
        data.count(),
        (int index) {
          //print(_listChipRange[index]);
          LabelValueDivider labelValueDivider = data.datas.elementAt(index);
          if (labelValueDivider is LabelValue) {
            return row(context, labelValueDivider);
          } else if (labelValueDivider is ContentPlaceInfo) {
            return rowContentPlace(context, labelValueDivider);
          } else {
            //return ComponentCreator.divider(context);
            return Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: ComponentCreator.divider(context),
            );
          }
        },
      ),
    );
  }
}

class CardLabelValueNotifier extends StatelessWidget {
  final LabelValueNotifier notifier;
  final String title;
  final String additionalTitleInfo;
  final VoidCallback onRetry;

  const CardLabelValueNotifier(this.title, this.notifier, {this.onRetry, this.additionalTitleInfo, Key key}) : super(key: key);

  Widget createAdditionalTitleInfo(BuildContext context, String _titleInfo) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Text(
        _titleInfo,
        style: InvestrendTheme.of(context).support_w400_compact,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget titleInfo;
    if (!StringUtils.isEmtpy(additionalTitleInfo)) {
      titleInfo = createAdditionalTitleInfo(context, additionalTitleInfo);
    } else {
      titleInfo = ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, LabelValueData data, child) {
          Widget noWidget = notifier.currentState.getNoWidget(onRetry: onRetry);

          //if (notifier.invalid() || StringUtils.isEmtpy(data.additionalInfo)) {
          if (noWidget != null || StringUtils.isEmtpy(data.additionalInfo)) {
            return SizedBox(
              width: 1.0,
            );
          }
          return createAdditionalTitleInfo(context, data.additionalInfo);
        },
      );
    }

    return Container(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   height: InvestrendTheme.cardPaddingGeneral,
          // ),
          ComponentCreator.subtitle(context, title),
          //(StringUtils.isEmtpy(additionalTitleInfo) ? SizedBox(width: 1,) : createAdditionalTitleInfo(context)),
          titleInfo,
          SizedBox(
            height: InvestrendTheme.cardPaddingGeneral,
          ),
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, LabelValueData data, child) {
              /*
              if (notifier.invalid()) {
                return Center(child: CircularProgressIndicator());
              }
              */
              Widget noWidget = notifier.currentState.getNoWidget(onRetry: onRetry);
              if (noWidget != null) {
                return Container(width: double.maxFinite, height: MediaQuery.of(context).size.width / 3, child: Center(child: noWidget));
              }
              return createContent(context, data);
            },
          ),
        ],
      ),
    );
  }

  Widget createContent(BuildContext context, LabelValueData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(
        data.count(),
        (int index) {
          //print(_listChipRange[index]);
          //double paddingTop = index == 0 ? 0 : 10.0;
          LabelValueDivider labelValueDivider = data.datas.elementAt(index);
          if (labelValueDivider is LabelValuePercent) {
            return rowPercent(context, labelValueDivider);
          } else if (labelValueDivider is LabelValue) {
            return row(context, labelValueDivider);
          } else if (labelValueDivider is LabelValueSubtitle) {
            return subtitle(context, labelValueDivider);
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
              //padding: EdgeInsets.only(top: paddingTop,),
              child: ComponentCreator.divider(context),
            );
            return Padding(
              padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingVertical),
              child: ComponentCreator.divider(context),
            );
          }
        },
      ),
    );
  }

  Widget subtitle(BuildContext context, LabelValueSubtitle labelValue) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 10.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            labelValue.label,
            style: InvestrendTheme.of(context).small_w400_compact,
          )),
    );
  }

  Widget row(BuildContext context, LabelValue labelValue) {
    //TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;
    if (labelValue.valueColor != null) {
      valueStyle = valueStyle.copyWith(color: labelValue.valueColor);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double availableWidth = constraints.maxWidth - 10.0;

          TextStyle labelStyle = InvestrendTheme.of(context).support_w400.copyWith(
            color: InvestrendTheme.of(context).greyDarkerTextColor,
          );
          double widthLabel = UIHelper.textSize(labelValue.label, labelStyle).width;
          double widthValue = UIHelper.textSize(labelValue.value, valueStyle).width;

          double totalContentWidth = widthLabel + widthValue;
          if(totalContentWidth > availableWidth){
            if(widthLabel > widthValue){
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      labelValue.label,
                      maxLines: 5,
                      softWrap: true,
                      style: labelStyle,
                      textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Text(
                    labelValue.value,
                    style: valueStyle,
                    textAlign: TextAlign.right,
                  ),
                ],
              );
            }else{
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelValue.label,
                    style: labelStyle,
                    textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                  ),
                  SizedBox(width: 10.0,),
                  Expanded(
                    flex: 1,
                    child: Text(
                      labelValue.value,
                      style: valueStyle,
                      textAlign: TextAlign.right,
                      maxLines: 5,
                      softWrap: true,
                    ),
                  ),
                ],
              );
            }
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  labelValue.label,
                  style: labelStyle,
                  textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                ),
              ),
              SizedBox(width: 10.0,),
              Text(
                labelValue.value,
                style: valueStyle,
                textAlign: TextAlign.right,
              ),
            ],
          );
        },
      ),
      /*
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              labelValue.label,
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor, ),textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
            ),
          ),
          Text(
            labelValue.value,
            style: valueStyle,
            textAlign: TextAlign.right,
          ),
        ],
      ),
      */
    );
    /*
    return Padding(
      padding: const EdgeInsets.only(top: 9.0, bottom: 9.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            labelValue.label,
            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          Expanded(
            flex: 1,
            child: Text(
              labelValue.value,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
     */
  }

  Widget rowPercent(BuildContext context, LabelValuePercent labelValue) {
    TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;
    TextStyle valuePercentStyle =
        InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    if (labelValue.valueColor != null) {
      valueStyle = valueStyle.copyWith(color: labelValue.valueColor);
    }
    if (labelValue.valuePercentColor != null) {
      valuePercentStyle = valuePercentStyle.copyWith(color: labelValue.valuePercentColor);
    }
    /*
    return Padding(
      padding: const EdgeInsets.only(top: 9.0, bottom: 9.0),
      child: Container(
        color: Colors.orange,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.yellow,
                  child: Text(
                    labelValue.label,
                    style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                  ),
                )),
            RichText(
              text: TextSpan(text: labelValue.value, style: valueStyle, children: [
                TextSpan(
                  text: '\n' + labelValue.valuePercent,
                  style: valuePercentStyle,
                ),
              ]),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
    */

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 1,
              child: Text(
                labelValue.label,
                style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
              )),
          SizedBox(
            width: InvestrendTheme.cardMargin,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                labelValue.value,
                style: valueStyle,
                textAlign: TextAlign.right,
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                labelValue.valuePercent,
                style: valuePercentStyle,
                textAlign: TextAlign.right,
              )
            ],
          ),
        ],
      ),
    );

    /*
    return Padding(
      padding: const EdgeInsets.only(top: 9.0, bottom: 9.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 1, child: Text(labelValue.label, style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),)),
              Text(labelValue.value, style: valueStyle, textAlign: TextAlign.right,),
            ],
          ),
          SizedBox(height: 5.0,),
          Align(
              alignment: Alignment.centerRight,
              child: Text(labelValue.valuePercent, style: valuePercentStyle, textAlign: TextAlign.right,)),
        ],
      ),
    );*/
  }
}

/*
class CardChart extends StatefulWidget {
  final ChartNotifier notifier;
  final StringCallback callbackRange;


  const CardChart(this.notifier, {this.callbackRange, Key key}) : super(key: key);

  @override
  _CardChartState createState() => _CardChartState();
}

class _CardChartState extends State<CardChart> {
  List<String> _listChipRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];
  int _selectedRange = 0;
  //int _selectedMarket = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chipsRange(context),
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

  Widget _chipsRange(BuildContext context) {
    double marginPadding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    // double marginPadding = 0;
    return Container(
      //color: Colors.green,
      margin: EdgeInsets.only( bottom: marginPadding),
      width: double.maxFinite,
      height: 30.0,

      decoration: BoxDecoration(
        //color: Colors.green,
        color: InvestrendTheme.of(context).tileBackground,
        border: Border.all(
          color: InvestrendTheme.of(context).chipBorder,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(2.0),

        //color: Colors.green,
      ),

      child: Row(
        children: List<Widget>.generate(
          _listChipRange.length,
              (int index) {
            //print(_listChipRange[index]);
            bool selected = _selectedRange == index;
            return Expanded(
              flex: 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRange = index;
                      if (widget.callbackRange != null) {
                        widget.callbackRange(_listChipRange[_selectedRange]);
                      }
                    });
                  },
                  child: Container(
                    color: selected ? Theme.of(context).accentColor : Colors.transparent,
                    child: Center(
                        child: Text(
                          _listChipRange[index],

                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText),
                        )),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}


*/
