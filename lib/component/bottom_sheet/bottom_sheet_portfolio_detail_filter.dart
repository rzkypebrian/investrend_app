import 'dart:math';

import 'package:Investrend/component/bottom_sheet/bottom_sheet_transaction_filter.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

/*****************************************
 *
 * Portfolio Detail Historical Matched Order FILTER
 *
 ******************************************/
class BottomSheetPortfolioDetailFilter extends StatefulWidget {
  final int index_transaction;
  final String from;
  final String to;
  final RangeCallback callbackRange;
  const BottomSheetPortfolioDetailFilter(this.index_transaction, this.from, this.to , {this.callbackRange,Key key}) : super(key: key);

  @override
  _BottomSheetPortfolioDetailFilterState createState() => _BottomSheetPortfolioDetailFilterState();
}

class _BottomSheetPortfolioDetailFilterState extends State<BottomSheetPortfolioDetailFilter> {
  int index_transaction;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  ValueNotifier<String> _customFromNotifier;
  ValueNotifier<String> _customToNotifier;
  ValueNotifier<String> _errorNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    index_transaction = widget.index_transaction;
    if (StringUtils.isEmtpy(widget.from)) {
      _customFromNotifier = ValueNotifier<String>('');
    } else {
      _customFromNotifier = ValueNotifier<String>(widget.from);
    }
    if (StringUtils.isEmtpy(widget.to)) {
      _customToNotifier = ValueNotifier<String>('');
    } else {
      _customToNotifier = ValueNotifier<String>(widget.to);
    }

    _customFromNotifier.addListener(() {
      _errorNotifier.value = '';
    });
    _customToNotifier.addListener(() {
      _errorNotifier.value = '';
    });
  }

  @override
  void dispose() {
    _customFromNotifier.dispose();
    _customToNotifier.dispose();
    super.dispose();
  }

  void selectFrom(BuildContext context) {
    DateTime initDate; // =  _dateFormat.parse(_customFromNotifier.value, false);
    try {
      initDate = _dateFormat.parse(_customFromNotifier.value, false);
    } catch (e) {
      initDate = DateTime.now();
      print(e);
    }
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2021, 1, 1), maxTime: DateTime.now().add(Duration(days: -1)), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      _customFromNotifier.value = _dateFormat.format(date);
      // if(widget.rangeNotifier != null){
      //   widget.rangeNotifier.setFrom(_customFromNotifier.value);
      // }
    }, currentTime: initDate); // DateTime.now()
  }

  void selectTo(BuildContext context) {
    DateTime initDate; // =  _dateFormat.parse(_customFromNotifier.value, false);
    try {
      initDate = _dateFormat.parse(_customToNotifier.value, false);
    } catch (e) {
      initDate = DateTime.now();
      print(e);
    }
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2021, 1, 1), maxTime: DateTime.now().add(Duration(days: -1)), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      _customToNotifier.value = _dateFormat.format(date);
      // if(widget.rangeNotifier != null){
      //   widget.rangeNotifier.setTo(_customToNotifier.value);
      // }
    }, currentTime: initDate); //DateTime.now()
  }

  Widget createText(BuildContext context, String text,){
    TextStyle style = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    return Text(text, style: style,);
  }
  Widget createTextField(BuildContext context, String text, TextEditingController controller){
    TextStyle style = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    return ComponentCreator.textFieldForm(context, lightTheme, '', text, 'choose_date_label'.tr(), null, null, false, TextInputType.text, TextInputAction.done, null, controller, () { }, null, null);


  }
  Widget createButton(BuildContext context, String text, String label,String hint, VoidCallback onPressed) {
    TextStyle styleLabel = InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    TextStyle styleValue = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    TextStyle styleValueHint = InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    return TapableWidget(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: styleLabel,),
          Padding(
            padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
            child: Text(StringUtils.isEmtpy(text) ? hint : text, style: StringUtils.isEmtpy(text) ? styleValueHint : styleValue,),
          ),
          ComponentCreator.divider(context),
        ],
      ),
    );
    /*
    const colorSoft = Color(0xFFF5F0FF);
    TextStyle style = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    Color colorBackground = Colors.transparent;
    Color colorBorder = Theme.of(context).accentColor;
    Color colorText = Theme.of(context).accentColor;




    return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBackground //Colors.transparent
                : colorBackground; //Colors.transparent;
            return colors;
          }),
          padding: MaterialStateProperty.all(EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: BorderSide(color: Colors.red)
          )),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBorder //Theme.of(context).accentColor
                : colorBorder; //Theme.of(context).accentColor;
            return BorderSide(color: colors, width: 1.0);
          }),
        ),
        child: Text(
          text,
          style: style.copyWith(color: colorText),
        ),
        onPressed: onPressed);
    */
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + 20.0 + ((44.0 * 3) + ((16.0 + 8.0) * 2) + (16.0 * 2) + 8.0 + (20.0 * 2)) + padding;

    if (contentHeight > minHeight) {
      maxHeight = min(contentHeight, maxHeight);
      minHeight = min(minHeight, maxHeight);
    }

    List<Widget> transactionList = List.empty(growable: true);
    FilterTransaction.values.forEach((transaction) {
      transactionList.add(Expanded(
        flex: 1,
        child: ButtonSelectionFilter(transaction.text, index_transaction == transaction.index, () {
          //context.read(transactionIntradayFilterChangeNotifier).setIndexTransaction(transaction.index);
          setState(() {
            this.index_transaction = transaction.index;
          });
        }),
      ));
    });

    // List<Widget> statusList = List.empty(growable: true);
    // FilterStatus.values.forEach((status) {
    //   statusList.add(
    //     ButtonSelectionFilter( status.text, index_status == status.index, () {
    //       //context.read(transactionIntradayFilterChangeNotifier).setIndexStatus(status.index);
    //       setState(() {
    //         this.index_status = status.index;
    //       });
    //     }),
    //   );
    // });

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          //mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'filter_title'.tr(),
                      style: InvestrendTheme.of(context).regular_w600_compact,
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      //icon: Icon(Icons.clear),
                      icon: Image.asset(
                        'images/icons/action_clear.png',
                        color: InvestrendTheme.of(context).greyLighterTextColor,
                        width: 12.0,
                        height: 12.0,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'filter_transaction_label'.tr(),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 44.0,
              child: Row(
                children: transactionList,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'filter_period_label'.tr(),
                style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 46.0,
              child: Row(
                //scrollDirection: Axis.horizontal,
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // createText(context, 'from_label'.tr()),
                  // SizedBox(width: InvestrendTheme.cardPadding,),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                        valueListenable: _customFromNotifier,
                        builder: (context, value, child) {
                          return createButton(context, value, 'from_label'.tr(), 'choose_date_label'.tr() ,() {
                            selectFrom(context);
                          });



                          //return createTextField(context, value, null);
                          // return TextButton(
                          //     onPressed: () {
                          //       selectFrom(context);
                          //     },
                          //     child: Text(value));

                        }),
                  ),
                  /*
                  Text(
                    ' - ',
                    style: InvestrendTheme.of(context).small_w500_compact_greyDarker,
                  ),
                  */
                  SizedBox(width: 25.0,),
                  // Spacer(flex: 1,),
                  // createText(context, 'to_label'.tr()),
                  // SizedBox(width: InvestrendTheme.cardPadding,),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                        valueListenable: _customToNotifier,
                        builder: (context, value, child) {
                          return createButton(context, value, 'to_label'.tr(), 'choose_date_label'.tr(),() {
                            selectTo(context);
                          });
                          //return createTextField(context, value, null);
                          // return TextButton(
                          //     onPressed: () {
                          //       selectTo(context);
                          //     },
                          //     child: Text(value));

                        }),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            //   child: ComponentCreator.divider(context, thickness: 1.0),
            // ),
            SizedBox(height: 16.0,),
            ValueListenableBuilder(
                valueListenable: _errorNotifier,
                builder: (context, value, child) {
                  if(StringUtils.isEmtpy(value)){
                    return SizedBox(width: 1.0,);
                  }
                  return Center(child: Text(value, style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.redText),));
                }),
            SizedBox(height: 16.0,),
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              width: double.maxFinite,
              child: ComponentCreator.roundedButton(context, 'filter_apply_button'.tr(), Theme.of(context).accentColor,
                  Theme.of(context).primaryColor, Theme.of(context).accentColor, () {

                String from = _customFromNotifier.value;
                String to = _customToNotifier.value;


                if(!StringUtils.isEmtpy(from) || !StringUtils.isEmtpy(to)){
                  if( StringUtils.isEmtpy(from) ){
                    //InvestrendTheme.of(context).showSnackBar(context, 'error_from_label'.tr());
                    _errorNotifier.value = 'error_from_label'.tr();
                    return;
                  }

                  if( StringUtils.isEmtpy(to) ){
                    //InvestrendTheme.of(context).showSnackBar(context, 'error_to_label'.tr());
                    _errorNotifier.value = 'error_to_label'.tr();
                    return;
                  }
                }

                _errorNotifier.value = '';
                if(widget.callbackRange != null){
                  widget.callbackRange(index_transaction, from, to);
                }

                    // context.read(transactionIntradayFilterChangeNotifier).setIndex(index_transaction, index_status);
                Navigator.pop(context);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
