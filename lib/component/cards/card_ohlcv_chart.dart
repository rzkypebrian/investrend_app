import 'package:Investrend/component/chart_candlestick.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CardOhlcvChart extends StatefulWidget {
  final ChartOhlcvNotifier ohlcvDataNotifier;
  final ValueNotifier<int> rangesNotifier;
  NumberFormat numberFormatRight;
  final RangeCallback rangeCallback;
  final VoidCallback onRetry;
  List<bool> listRangeEnabled;

  CardOhlcvChart(
    this.ohlcvDataNotifier,
    this.rangesNotifier, {
    Key key,
    this.rangeCallback,
    this.numberFormatRight,
    this.onRetry,
    this.listRangeEnabled,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CardOhlcvChartState();
}

class _CardOhlcvChartState extends State<CardOhlcvChart> {
  List<Ohlcv> ohlcvData = [];
  List<String> _listChipRange = <String>[
    '1D',
    '1W',
    '1M',
    '3M',
    '6M',
    '1Y',
    '5Y',
    'All'
  ];
  List<bool> _listRangeEnabled = <bool>[
    false,
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];

  Key keyRange = UniqueKey();

  @override
  void initState() {
    super.initState();
    if (widget.listRangeEnabled != null &&
        widget.listRangeEnabled.length <= _listRangeEnabled.length) {
      for (int i = 0; i < widget.listRangeEnabled.length; i++) {
        _listRangeEnabled[i] = widget.listRangeEnabled.elementAt(i);
      }
    }
  }

  bool enableButton(int index) {
    if (_listRangeEnabled == null ||
        _listRangeEnabled.isEmpty ||
        index < 0 ||
        index >= _listRangeEnabled.length) {
      return true;
    }
    return _listRangeEnabled.elementAt(index);
  }

  final DateFormat _dateFormat = DateFormat('yy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chipsRange(context),
          ValueListenableBuilder(
              valueListenable: widget.ohlcvDataNotifier,
              builder: (context, ChartOhlcvData data, child) {
                Widget noWidget = widget.ohlcvDataNotifier.currentState
                    .getNoWidget(onRetry: widget.onRetry);
                if (noWidget != null) {
                  return Container(
                    width: double.maxFinite,
                    height: 220,
                    child: Center(
                      child: noWidget,
                    ),
                  );
                }
                return Container(
                  padding: EdgeInsets.zero,
                  height: 220,
                  margin: EdgeInsets.only(
                    left: 13,
                    right: 12,
                  ),
                  width: double.maxFinite,
                  child: CandlestickChart(
                    chartData: data.datas,
                    minimumData: data.minValue,
                    maximumData: data.maxValue,
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget _chipsRange(BuildContext context) {
    double marginpadding =
        InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return Container(
      margin: EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPadding,
        bottom: marginpadding,
      ),
      width: double.maxFinite,
      height: 30.0,
      decoration: BoxDecoration(
        color: InvestrendTheme.of(context).tileBackground,
        border: Border.all(
          color: InvestrendTheme.of(context).chipBorder,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: ValueListenableBuilder<int>(
          valueListenable: widget.rangesNotifier,
          builder: (context, value, child) {
            return Row(
              children:
                  List<Widget>.generate(_listChipRange.length, (int index) {
                bool selected = value == index;
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
                    colorText =
                        InvestrendTheme.of(context).greyLighterTextColor;
                  }
                }
                return Expanded(
                  flex: 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled
                          ? () {
                              widget.rangesNotifier.value = index;
                              executesCallback(index);
                            }
                          : null,
                      child: Container(
                        color: color,
                        child: Center(
                          child: Text(
                            _listChipRange[index],
                            style: InvestrendTheme.of(context)
                                .more_support_w400_compact
                                .copyWith(color: colorText),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
    );
  }

  void executesCallback(int index) {
    if (widget.rangeCallback != null) {
      DateTime from;
      DateTime to;
      //widget.callbackRange(_listChipRange[_selectedRange]);
      //  0      1    2     3      4     5    6      7
      //['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];

      switch (index) {
        case 0:
          {}
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
            from = new DateTime(1945, 8, 17); // all
          }
          break;
      }

      String fromText = from == null ? '' : _dateFormat.format(from);
      String toText = to == null ? '' : _dateFormat.format(to);

      //fromText = _dateFormat.format(from);
      //toText = _dateFormat.format(to);

      widget.rangeCallback(widget.rangesNotifier.value, fromText, toText);
    }
  }
}
