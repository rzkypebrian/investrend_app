// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
//import 'package:Investrend/objects/riverpod_change_notifier.dart';
//import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/string_utils.dart';

import 'package:flutter/material.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:easy_localization/easy_localization.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardLocalForeign extends StatefulWidget {
  final LocalForeignNotifier? notifier;
  //final StringCallback callbackRange;
  //final IntCallback callbackMarket;
  //final RangeCallback callbackRange;
  final ValueNotifier<int> marketNotifier;
  //final ValueNotifier<int> rangeNotifier;

  final RangeNotifier rangeNotifier;
  const CardLocalForeign(this.notifier, this.marketNotifier, this.rangeNotifier,
      {/*this.callbackRange, this.callbackMarket,*/ Key? key})
      : super(key: key);

  @override
  _CardLocalForeignState createState() => _CardLocalForeignState();
}

class _CardLocalForeignState extends State<CardLocalForeign> {
  // List<String> _listChipRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'CR'];
  // List<bool> _listChipRangeEnabled = <bool>[true, true, true, true, false, false, false, false];
  List<String> _market_options = [
    'card_local_foreign_button_all_market'.tr(),
    'card_local_foreign_button_rg_market'.tr(),
  ];

  //RangeNotifier rangeNotifier = RangeNotifier(Range.createBasic());

  // final ValueNotifier<String> _customFromNotifier = ValueNotifier<String>('From');
  // final ValueNotifier<String> _customToNotifier = ValueNotifier<String>('To');

  //int _selectedRange = 0;
  //int _selectedMarket = 0;
  //ValueNotifier<int> _marketNotifier = ValueNotifier<int>(0);

  // @override
  // void dispose() {
  //   _marketNotifier.dispose();
  //   super.dispose();
  // }
  @override
  void initState() {
    super.initState();

    // if(widget.rangeNotifier != null ){
    //   widget.rangeNotifier.addListener(() {
    //     print('CardLocalForeign '+widget.rangeNotifier.value.toString());
    //   });
    // }

    //widget.rangeNotifier.addListener(() {
    //_selectedRange = widget.rangeNotifier.value;
    // if (widget.callbackRange != null) {
    //   widget.callbackRange(_listChipRange[_selectedRange]);
    // }
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.only(
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(context),
          //SizedBox(height: InvestrendTheme.cardPaddingVertical),
          //_chipsRange(context),
          //ChipsRange(_listChipRange, widget.rangeNotifier, paddingLeftRight: InvestrendTheme.cardPaddingGeneral, enable: _listChipRangeEnabled,),
          ChipsRangeCustom(
            widget.rangeNotifier,
            paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
            paddingBottom: InvestrendTheme.cardPaddingGeneral,
          ),
          ValueListenableBuilder(
            valueListenable: widget.notifier!,
            builder: (context, ForeignDomestic? data, child) {
              Widget? noWidget = widget.notifier?.currentState.getNoWidget();
              // if (widget.notifier.invalid()) {
              //   return Center(child: CircularProgressIndicator());
              // }
              if (noWidget != null) {
                return Container(
                    width: double.maxFinite,
                    height: 100,
                    child: Center(child: noWidget));
              }

              String? displayTime = data?.time;
              if (!StringUtils.isEmtpy(data?.time) &&
                  !StringUtils.isEmtpy(data?.date)) {
                String infoTime = 'card_local_foreign_time_info'.tr();

                DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
                DateFormat timeFormatter = DateFormat('HH:mm:ss');
                DateFormat dateParser = DateFormat('yyyy-MM-dd hh:mm:ss');
                DateTime dateTime =
                    dateParser.parseUtc(data!.date! + ' ' + data.time!);
                print('dateTime : ' + dateTime.toString());
                print('indexSummary.date : ' + data.date! + ' ' + data.time!);
                String formatedDate = dateFormatter.format(dateTime);
                String formatedTime = timeFormatter.format(dateTime);
                infoTime = infoTime.replaceAll('#DATE#', formatedDate);
                infoTime = infoTime.replaceAll('#TIME#', formatedTime);
                displayTime = infoTime;
              }

              return Column(
                children: [
                  _table(context, data),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: InvestrendTheme.cardPaddingGeneral,
                        right: InvestrendTheme.cardPaddingGeneral,
                        top: InvestrendTheme.cardPaddingGeneral),
                    child: Text(
                      displayTime!,
                      style: InvestrendTheme.of(context)
                          .more_support_w400_compact
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                InvestrendTheme.of(context).greyDarkerTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
          /*
          ValueListenableBuilder(
            valueListenable: widget.notifier,
            builder: (context, ForeignDomestic data, child) {
              if (widget.notifier.invalid()) {
                return Center(child: CircularProgressIndicator());
              }
              if(StringUtils.isEmtpy(data.time)){
                return SizedBox(width: 1,);
              }else{
                String displayTime = data.time;
                if( !StringUtils.isEmtpy(data.time) && !StringUtils.isEmtpy(data.date)){
                  String infoTime = 'card_local_foreign_time_info'.tr();

                  DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
                  DateFormat timeFormatter = DateFormat('HH:mm:ss');
                  DateFormat dateParser = DateFormat('yyyy-MM-dd hh:mm:ss');
                  DateTime dateTime = dateParser.parseUtc(data.date+' '+data.time);
                  print('dateTime : '+dateTime.toString());
                  print('indexSummary.date : '+data.date+' '+data.time);
                  String formatedDate = dateFormatter.format(dateTime);
                  String formatedTime = timeFormatter.format(dateTime);
                  infoTime = infoTime.replaceAll('#DATE#', formatedDate);
                  infoTime = infoTime.replaceAll('#TIME#', formatedTime);
                  displayTime = infoTime;
                }

                return Padding(
                  padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: InvestrendTheme.cardPaddingGeneral),
                  child: Text(
                    displayTime,
                    style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
                      fontWeight: FontWeight.w500,
                      color: InvestrendTheme.of(context).greyDarkerTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
            },

          ),*/
        ],
      ),
    );
  }

  Widget _table(BuildContext context, ForeignDomestic? data) {
    Color? defaultColor = InvestrendTheme.of(context).small_w400?.color;
    //double padding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;

    return Table(
      columnWidths: {
        0: FractionColumnWidth(.34),
        1: FractionColumnWidth(.33),
        2: FractionColumnWidth(.33),
      },
      children: [
        TableRow(
          children: [
            _label(context, ''),
            _label(context, 'card_local_foreign_local'.tr(),
                align: TextAlign.center),
            _label(context, 'card_local_foreign_foreign'.tr(),
                align: TextAlign.center,
                rightPadding: InvestrendTheme.cardPaddingGeneral),
          ],
        ),
        _tableRow(
          context,
          'card_local_foreign_buy'.tr(),
          InvestrendTheme.formatValue(context, data?.domesticBuyerValue),
          InvestrendTheme.formatValue(context, data?.foreignBuyerValue),
        ),
        _tableRow(
            context,
            'card_local_foreign_sell'.tr(),
            InvestrendTheme.formatValue(context, data?.domesticSellerValue),
            InvestrendTheme.formatValue(context, data?.foreignSellerValue),
            odd: true),
        _tableRow(
            context,
            'card_local_foreign_net'.tr(),
            InvestrendTheme.formatValue(context, data?.domesticNetValue),
            InvestrendTheme.formatValue(context, data?.foreignNetValue),
            localColor: InvestrendTheme.changeTextColor(
                data?.domesticNetValue.toDouble()),
            foreignColor: InvestrendTheme.changeTextColor(
                data?.foreignNetValue.toDouble())),
        _tableRow(
            context,
            'card_local_foreign_percent_turnover'.tr(),
            InvestrendTheme.formatPercent(data?.domesticTotalValueRatio,
                prefixPlus: false),
            InvestrendTheme.formatPercent(data?.foreignTotalValueRatio,
                prefixPlus: false),
            odd: true),
      ],
    );
  }

  TableRow _tableRow(BuildContext context, String label, String localValue,
      String foreignValue,
      {Color? localColor, Color? foreignColor, bool odd = false}) {
    //double padding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return TableRow(
        decoration: BoxDecoration(
          color:
              odd ? InvestrendTheme.of(context).oddColor : Colors.transparent,
        ),
        children: [
          _label(context, label,
              leftPadding: InvestrendTheme.cardPaddingGeneral),
          _value(context, localValue, color: localColor),
          _value(context, foreignValue,
              color: foreignColor,
              rightPadding: InvestrendTheme.cardPaddingGeneral),
        ]);
  }

  Widget _label(BuildContext context, String label,
      {TextAlign? align, double leftPadding = 0.0, double rightPadding = 0.0}) {
    Alignment alignment = Alignment.center;

    if (align == null) {
      align = TextAlign.start;
      alignment = Alignment.centerLeft;
    }
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
      height: 38.0,
      child: Text(
        label,
        style: InvestrendTheme.of(context).small_w600_compact,
        textAlign: align,
      ),
    );
  }

  Widget _value(BuildContext context, String value,
      {TextAlign? align, Color? color, double rightPadding = 0.0}) {
    if (align == null) {
      align = TextAlign.center;
    }
    if (color == null) {
      color = InvestrendTheme.of(context).small_w400?.color!;
    }
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: rightPadding),
      height: 38.0,
      child: Text(
        value,
        style: InvestrendTheme.of(context)
            .small_w400_compact
            ?.copyWith(color: color),
        textAlign: align,
      ),
    );
  }

  Widget _title(BuildContext context) {
    //double paddingMargin = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return Padding(
      padding: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ComponentCreator.subtitle(
              context,
              'card_local_foreign_title'.tr(),
            ),
          ),
          ButtonDropdown(widget.marketNotifier, _market_options),
        ],
      ),
    );
  }

  /*
  Widget _chipsRange(BuildContext context) {
    //double marginPadding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return Container(
      //color: Colors.green,
      margin: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
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
        // mainAxisAlignment: MainAxisAlignment.center,
        ///crossAxisAlignment: CrossAxisAlignment.center,
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
                      /*
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 12.0, color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText),

                       */
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
  */
/*
  Widget createCardLocalForeign(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ComponentCreator.subtitle(
                    context,
                    'card_local_foreign_title'.tr(),
                  ),
                ),
                MaterialButton(
                    elevation: 0.0,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: InvestrendTheme
                        .of(context)
                        .tileBackground,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'card_local_foreign_button_all_market'.tr(),
                          style: InvestrendTheme
                              .of(context)
                              .support_w400_compact,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onPressed: () {
                      InvestrendTheme.of(context).showSnackBar(context, 'Action choose Market');
                    }),
              ],
            ),
            SizedBox(
              height: InvestrendTheme.cardMargin,
            ),
            domesticForeignRangeChips(context),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        '',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'card_local_foreign_local'.tr(),
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'card_local_foreign_foreign'.tr(),
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'card_local_foreign_buy'.tr(),
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: widget.notifier,
                      builder: (context, LocalForeignData value, child) {
                        if (widget.notifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(value.domesticBuy),
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: widget.notifier,
                      builder: (context, value, child) {
                        if (_compositeNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(value.foreignBuy),
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              color: InvestrendTheme
                  .of(context)
                  .tileBackground,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'card_local_foreign_sell'.tr(),
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _compositeNotifier,
                      builder: (context, value, child) {
                        if (_compositeNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_compositeNotifier.value.domesticSellerValue),
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _compositeNotifier,
                      builder: (context, value, child) {
                        if (_compositeNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_compositeNotifier.value.foreignSellerValue),
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'card_local_foreign_net'.tr(),
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: widget.notifier,
                      builder: (context, LocalForeignData value, child) {
                        if (widget.notifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        //int netDomestic = _compositeNotifier.value.domesticBuyerValue - _compositeNotifier.value.domesticSellerValue;
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(value.domescticNet),
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(
                            fontWeight: FontWeight.normal,
                            color: InvestrendTheme.changeTextColor(value.domescticNet.toDouble()),
                          ),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: widget.notifier,
                      builder: (context, LocalForeignData value, child) {
                        if (widget.notifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        //int netForeign = _compositeNotifier.value.foreignBuyerValue - _compositeNotifier.value.foreignSellerValue;
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(value.foreignNet),
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(
                            fontWeight: FontWeight.normal,
                            color: InvestrendTheme.changeTextColor(value.foreignNet.toDouble()),
                          ),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              color: InvestrendTheme
                  .of(context)
                  .tileBackground,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'card_local_foreign_percent_turnover'.tr(),
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: ComponentCreator.textFit(
                        context,
                        '83%',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        alignment: Alignment.centerRight,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: ComponentCreator.textFit(
                        context,
                        '17%',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                        alignment: Alignment.centerRight,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget domesticForeignRangeChips(BuildContext context) {
    return Container(
      //color: Colors.green,
      width: double.maxFinite,
      //margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      //margin: EdgeInsets.all(10.0),
      //padding: EdgeInsets.only(left: 10.0, right: 10.0),
      height: 30.0,

      decoration: BoxDecoration(
        //color: Colors.green,
        color: InvestrendTheme
            .of(context)
            .tileBackground,
        border: Border.all(
          color: InvestrendTheme
              .of(context)
              .chipBorder,
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
            bool selected = _selectedDomesticForeign == index;
            return Expanded(
              flex: 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDomesticForeign = index;
                    });
                  },
                  child: Container(
                    color: selected ? Theme
                        .of(context)
                        .accentColor : Colors.transparent,
                    child: Center(
                        child: Text(
                          _listChipRange[index],
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(fontSize: 12.0, color: selected ? Colors.white : InvestrendTheme
                              .of(context)
                              .blackAndWhiteText),
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

   */
}
/*
class MarketBottomSheet extends ConsumerWidget {
  const MarketBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final selected = watch(marketChangeNotifier);
    print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    double contentHeight = padding + 44.0 + 44.0 + 44.0 + padding;

    //if (contentHeight > minHeight) {
    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);
    //}

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        padding: EdgeInsets.all(padding),
        // color: Colors.yellow,
        width: double.maxFinite,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(Icons.clear),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
            createRow(context, 'card_local_foreign_button_all_market'.tr(), selected.index == 0, 0),
            createRow(context, 'card_local_foreign_button_rg_market'.tr(), selected.index == 1, 1),
          ],
        ),
      ),
    );
  }

  Widget createRow(BuildContext context, String label, bool selected, int index) {
    TextStyle style = InvestrendTheme.of(context).regular_w400_compact;
    //Color colorText = style.color;
    Color colorIcon = Colors.transparent;

    if (selected) {
      style = InvestrendTheme.of(context).regular_w700_compact.copyWith(color: Theme.of(context).accentColor);
      //colorText = Theme.of(context).accentColor;
      colorIcon = Theme.of(context).accentColor;
    }

    return SizedBox(
      height: 44.0,
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.0,
              height: 20.0,
            ),
            Expanded(
                flex: 1,
                child: Text(
                  label,
                  style: style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
                  textAlign: TextAlign.center,
                )),
            (selected
                ? Image.asset(
                    'images/icons/check.png',
                    color: colorIcon,
                    width: 20.0,
                    height: 20.0,
                  )
                : SizedBox(
                    width: 20.0,
                    height: 20.0,
                  )),
          ],
        ),
        onPressed: () {
          // setState(() {
          //   selectedIndex = index;
          // });
          context.read(marketChangeNotifier).setIndex(index);
        },
      ),
    );
  }
}
*/
//
// class MarketBottomSheet extends StatefulWidget {
//   int index;
//   MarketBottomSheet(this.index,{Key key}) : super(key: key);
//
//   @override
//   _MarketBottomSheetState createState() => _MarketBottomSheetState();
// }
//
// class _MarketBottomSheetState extends State<MarketBottomSheet> {
//   int selectedIndex;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     selectedIndex = widget.index;
//   }
//   @override
//   Widget build(BuildContext context) {
//
//   }
// }
