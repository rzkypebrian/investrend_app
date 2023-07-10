import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_analysis.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';



class ChipsRangeCustom extends StatefulWidget {
  //final RangeCallback callbackRange;
  final RangeNotifier rangeNotifier;
  final double paddingLeftRight;
  final double paddingBottom;
  const ChipsRangeCustom(this.rangeNotifier, {this.paddingLeftRight = 0, this.paddingBottom = 0/*,this.callbackRange*/, Key key}) : super(key: key);

  @override
  _ChipsRangeCustomState createState() => _ChipsRangeCustomState();
}

class _ChipsRangeCustomState extends State<ChipsRangeCustom> {
  List<String> _listRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'CR'];
  List<bool> _listRangeEnabled = <bool>[true, true, true, true, true, false, false, true];

  ValueNotifier<String> _customFromNotifier;
  ValueNotifier<String> _customToNotifier;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');


  @override
  void initState() {
    super.initState();
    if(widget.rangeNotifier != null){
      _customFromNotifier = ValueNotifier<String>(widget.rangeNotifier.value.from);
      _customToNotifier = ValueNotifier<String>(widget.rangeNotifier.value.to);
    }
  }

  @override
  void dispose() {
    _customFromNotifier.dispose();
    _customToNotifier.dispose();

    super.dispose();
  }

  // bool customRangeIsValid() {
  //   return !StringUtils.equalsIgnoreCase(_customFromNotifier.value, 'From') && !StringUtils.equalsIgnoreCase(_customToNotifier.value, 'To');
  // }
  void selectFrom(BuildContext context) {
    DateTime initDate;// =  _dateFormat.parse(_customFromNotifier.value, false);
    try{
      initDate =  _dateFormat.parse(_customFromNotifier.value, false);
    }catch(e){
      initDate = DateTime.now();
      print(e);
    }
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2021, 9, 1), maxTime: DateTime.now(), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      _customFromNotifier.value = _dateFormat.format(date);
      if(widget.rangeNotifier != null){
        widget.rangeNotifier.setFrom(_customFromNotifier.value);
      }

      // if (customRangeIsValid()) {
      //   //doUpdate();
      //
      // }
    }, currentTime: initDate); // DateTime.now()
  }

  void selectTo(BuildContext context) {
    DateTime initDate;// =  _dateFormat.parse(_customFromNotifier.value, false);
    try{
      initDate =  _dateFormat.parse(_customToNotifier.value, false);
    }catch(e){
      initDate = DateTime.now();
      print(e);
    }
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2021, 9, 1), maxTime: DateTime.now(), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      _customToNotifier.value = _dateFormat.format(date);
      if(widget.rangeNotifier != null){
        widget.rangeNotifier.setTo(_customToNotifier.value);
      }
      // if (customRangeIsValid()) {
      //   // doUpdate();
      // }
    }, currentTime: initDate); //DateTime.now()
  }
  MyRange getRange() {
    DateTime from;
    DateTime to;
    //widget.callbackRange(_listChipRange[_selectedRange]);
    //  0      1    2     3      4     5    6      7
    //['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'CR'];
    if (widget.rangeNotifier.value.index == 0) {
      MyRange range = MyRange();
      range.from = 'LD';
      range.to = 'LD';
      return range;
    } else if (widget.rangeNotifier.value.index == 7) {
      MyRange range = MyRange();
      range.from = StringUtils.equalsIgnoreCase(_customFromNotifier.value, 'from_label'.tr()) ? '' : _customFromNotifier.value;
      range.to = StringUtils.equalsIgnoreCase(_customToNotifier.value, 'to_label'.tr()) ? '' : _customToNotifier.value;
      return range;
    }
    switch (widget.rangeNotifier.value.index) {
      case 0:
        {
          to = DateTime.now();
          from = DateTime.now();
        }
        break;
      case 1:
        {
          to = DateTime.now();
          from = DateTime.now().add(Duration(days: -7)); // - week
        }
        break;
      case 2:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 1, to.day); // - 1 month
        }
        break;
      case 3:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 3, to.day); // - 3 month
        }
        break;
      case 4:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 6, to.day); // - 6 month
        }
        break;
      case 5:
        {
          to = DateTime.now();
          from = new DateTime(to.year - 1, to.month, to.day); // - 1 year
        }
        break;
      case 6:
        {
          to = DateTime.now();
          from = new DateTime(to.year - 5, to.month, to.day); // - 5 year
        }
        break;
      case 7:
        {
          to = DateTime.now();
          from = new DateTime(1945, 8, 17); // Custom Range - di atas
        }
        break;
    }
    MyRange range = MyRange();
    range.from = from == null ? '' : _dateFormat.format(from);
    range.to = to == null ? '' : _dateFormat.format(to);
    return range;
  }
  bool enableButton(int index) {
    if (_listRangeEnabled == null || _listRangeEnabled.isEmpty || index < 0 || index >= _listRangeEnabled.length) {
      return true;
    }
    return _listRangeEnabled.elementAt(index);
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.rangeNotifier,
      builder: (context, Range range, child) {
        //double marginPadding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
        double marginPadding = range.index == 7 ? 0 : widget.paddingBottom;

        int count = _listRange == null ? 0 : _listRange.length;

        Widget rangeWidget = Container(
          //color: Colors.green,
          margin: EdgeInsets.only(left: widget.paddingLeftRight, right: widget.paddingLeftRight, bottom: marginPadding),
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
              count,
                  (int index) {
                //print(_listChipRange[index]);
                bool selected = range.index == index;
                bool enabled = enableButton(index);
                Color color;
                Color colorText;
                if (selected) {
                  color = Theme.of(context).colorScheme.secondary;
                  colorText = Colors.white;
                } else {
                  if (enabled) {
                    color = Colors.transparent;
                    colorText = InvestrendTheme.of(context).blackAndWhiteText;
                  } else {
                    color = Theme.of(context).colorScheme.background;
                    colorText = InvestrendTheme.of(context).greyLighterTextColor;
                  }
                }
                return Expanded(
                  flex: 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled
                          ? () {
                        // setState(() {
                        //   _selectedRange = index;
                        //   if (widget.callbackRange != null) {
                        //     widget.callbackRange(_listChipRange[_selectedRange]);
                        //   }
                        // });
                        widget.rangeNotifier.setIndex(index);
                      }
                          : null,
                      child: Container(
                        //color: selected ? Theme.of(context).accentColor : Colors.transparent,
                        color: color,
                        child: Center(
                            child: Text(
                              _listRange[index],
                              style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
                                color: colorText,
                                //color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText,
                              ),
                            )),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );


        if(range.index == 7){ // CR
          rangeWidget = Column(
            children: [
              rangeWidget,
              customRangeWidget(context),
            ],
          );
        }

        return rangeWidget;
      },
    );
  }

  Widget customRangeWidget(BuildContext context){


    return Container(
      // color: Colors.grey,
      //margin: EdgeInsets.only(bottom: InvestrendTheme.cardPaddingVertical),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder(
              valueListenable: _customFromNotifier,
              builder: (context, value, child) {
                return TextButton(
                    onPressed: () {
                      selectFrom(context);
                    },
                    child: Text(value));
              }),
          Text(
            ' - ',
            style: InvestrendTheme.of(context).small_w500_compact_greyDarker,
          ),
          ValueListenableBuilder(
              valueListenable: _customToNotifier,
              builder: (context, value, child) {
                return TextButton(
                    onPressed: () {
                      selectTo(context);
                    },
                    child: Text(value));
              }),
        ],
      ),
    );
    /*
    return ValueListenableBuilder(
        valueListenable: widget.rangeNotifier,
        builder: (context, value, child) {
          if (value) {
            return Container(
              //color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                      valueListenable: _customFromNotifier,
                      builder: (context, value, child) {
                        return TextButton(
                            onPressed: () {
                              selectFrom(context);
                            },
                            child: Text(value));
                      }),
                  Text(
                    ' - ',
                    style: InvestrendTheme.of(context).small_w500_compact_greyDarker,
                  ),
                  ValueListenableBuilder(
                      valueListenable: _customToNotifier,
                      builder: (context, value, child) {
                        return TextButton(
                            onPressed: () {
                              selectTo(context);
                            },
                            child: Text(value));
                      }),
                ],
              ),
            );
          } else {
            return SizedBox(
              width: 1.0,
              height: InvestrendTheme.cardPaddingVertical,
            );
          }
        });

     */
  }


}


class ChipsRange extends StatelessWidget {
  final ValueNotifier<int> notifier;
  final double paddingLeftRight;

  //List<String> _listChipRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];
  final List<String> range; // = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];
  final List<bool> enable;

  const ChipsRange(this.range, this.notifier, {Key key, this.paddingLeftRight = 0, this.enable}) : super(key: key);

  bool enableButton(int index) {
    if (enable == null || enable.isEmpty || index < 0 || index >= enable.length) {
      return true;
    }
    return enable.elementAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: this.notifier,
      builder: (context, data, child) {
        //double marginPadding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
        double marginPadding = 0;

        int count = range == null ? 0 : range.length;

        return Container(
          //color: Colors.green,
          margin: EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight, bottom: marginPadding),
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
              count,
              (int index) {
                //print(_listChipRange[index]);
                bool selected = notifier.value == index;
                bool enabled = enableButton(index);
                Color color;
                Color colorText;
                if (selected) {
                  color = Theme.of(context).colorScheme.secondary;
                  //colorText = Colors.white;
                  colorText = InvestrendTheme.of(context).textWhite;
                } else {
                  if (enabled) {
                    color = Colors.transparent;
                    colorText = InvestrendTheme.of(context).blackAndWhiteText;
                  } else {
                    color = Theme.of(context).colorScheme.background;
                    colorText = InvestrendTheme.of(context).greyLighterTextColor;
                  }
                }
                return Expanded(
                  flex: 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled
                          ? () {
                              // setState(() {
                              //   _selectedRange = index;
                              //   if (widget.callbackRange != null) {
                              //     widget.callbackRange(_listChipRange[_selectedRange]);
                              //   }
                              // });
                              notifier.value = index;
                            }
                          : null,
                      child: Container(
                        //color: selected ? Theme.of(context).accentColor : Colors.transparent,
                        color: color,
                        child: Center(
                            child: Text(
                          range[index],
                          style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
                                color: colorText,
                                //color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText,
                              ),
                        )),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }



/*
  Widget _chipsRange(BuildContext context) {
    double marginPadding = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;

    int count = range == null ? 0 : range.length;

    return Container(
      //color: Colors.green,
      margin: EdgeInsets.only(left: marginPadding, right: marginPadding, bottom: marginPadding),
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
          count,
              (int index) {
            //print(_listChipRange[index]);
            bool selected = notifier.value == index;
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
}
