import 'package:Investrend/component/broker_trade_summary_value.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:search_choices/search_choices.dart';

class BrokerTradeSummary extends StatefulWidget {
  final TextStyle styleBroker;
  final AutoSizeGroup groupValue;
  final String selectValue;

  BrokerTradeSummary({
    Key key,
    this.styleBroker,
    this.groupValue,
    this.selectValue,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => BrokerTradeSummaryState();
}

class BrokerTradeSummaryState extends State<BrokerTradeSummary> {
  bool isError = false;

  FocusNode focusNode = new FocusNode();
  final String routeName = '/brokerTradeSummary';
  bool onProgress = false;
  List<BrokerTradeSummaryValue> brokerTradeData = [];
  List<BrokerData> brokerCodeData = [];
  AutoSizeGroup groupValue = AutoSizeGroup();
  AutoSizeGroup groupHeader = AutoSizeGroup();
  final RangeNotifier _rangeTopBrokerNotifier =
      RangeNotifier(Range.createBasic());
  final ValueNotifier<int> marketNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> dataByNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> filterByNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> brokerFilterNotifier = ValueNotifier<int>(0);
  String brokerName = '';

  List<String> brokerNameValue = [
    'RF',
    'YU',
    'BK',
    'ZP',
    'YP',
    'AK',
    'CC',
    'RX',
    'PD',
    'KZ',
    'AI',
    'DH',
    'MG',
    'NI',
    'DX',
    'LG',
    'GR',
    'OD',
    'EP',
    'XA',
    'AG',
  ];

  List<Color> colorStock = [
    Colors.white,
    Color(0xff2D0589),
    InvestrendTheme.yellowText,
    InvestrendTheme.greenText,
    Color(0xff0000FF),
    Color(0xffE1951A),
    InvestrendTheme.redText,
    Color(0xff10CFD8),
    Color(0xffFF69B4),
    Color(0xff000000),
    Color(0xff08831E),
    Color(0xffF0E68C),
  ];
  List<String> marketOptions = [
    'card_local_foreign_button_all_market'.tr(),
    'card_local_foreign_button_rg_market'.tr(),
    'TUNAI',
    'TUTUP SENDIRI',
    'NEGO',
  ];

  List<String> dataByOptions = [
    'data_by_value_label'.tr(),
    'data_by_net_label'.tr(),
  ];

  List<String> filterOptions = [
    'filter_by_all_label'.tr(),
    'filter_by_domestic_label'.tr(),
    'filter_by_foreign_label'.tr()
  ];

  @override
  void initState() {
    super.initState();
    brokerTradeData = BrokerTradeSummaryValue.listDummy;
    brokerCodeData = BrokerData.dummy;
  }

  @override
  void dispose() {
    marketNotifier.dispose();
    dataByNotifier.dispose();
    filterByNotifier.dispose();
    _rangeTopBrokerNotifier.dispose();
    super.dispose();
  } // belu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(),
      bottomSheet:
          createBottomSheet(context, MediaQuery.of(context).padding.bottom),
    );
  }

  PreferredSizeWidget appBar() {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    return AppBar(
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      title: Text('Broker Trade Summary'),
      titleTextStyle: InvestrendTheme.of(context).regular_w600.copyWith(
            color: InvestrendTheme.of(context).investrendPurple,
            fontWeight: FontWeight.bold,
          ),
      leading: AppBarActionIcon(
        'images/icons/action_back.png',
        () {
          Navigator.of(context).pop();
        },
        //color: Theme.of(context).accentColor,
      ),
    );
  }

  Widget body() {
    String tanggalSekarang = "2023-06-19";
    String waktuSekarang = '15:00:00';

    String dateInfo = 'card_local_foreign_time_info'.tr();
    DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
    DateFormat dateParser = DateFormat('yyyy-MM-dd');
    DateTime dateTime = dateParser.parseUtc(tanggalSekarang);
    print('dateTime : ' + dateTime.toString());
    String formatedDate = dateFormatter.format(dateTime);

    dateInfo = dateInfo.replaceAll('#DATE#', formatedDate);
    dateInfo = dateInfo.replaceAll('#TIME#', waktuSekarang);

    String selectedValue = widget.selectValue;

    TextStyle textStyle =
        InvestrendTheme.of(context).small_w500_compact.copyWith(fontSize: 14);
    List<BrokerTradeSummaryValue> data = BrokerTradeSummaryValue.listDummy;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      TextStyle styleNo =
          InvestrendTheme.of(context).small_w400_compact_greyDarker;

      TextStyle styleDarker =
          InvestrendTheme.of(context).small_w400_compact_greyDarker;

      TextStyle style = InvestrendTheme.of(context).small_w400_compact;
      double centerWidth = UIHelper.textSize(' 000 ', styleDarker).width;
      double availableWidth = constraints.maxWidth -
          (InvestrendTheme.cardPaddingGeneral * 2) -
          (InvestrendTheme.cardPadding * 2);
      double leftWidth = (availableWidth - centerWidth) / 2;
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: DropdownButton<String>(
                isExpanded: true,
                borderRadius: BorderRadius.circular(10),
                underline: Container(
                  alignment: Alignment.bottomCenter,
                  width: double.infinity,
                  height: 10,
                  color: Colors.transparent,
                  child: Container(
                    height: 1,
                    width: double.infinity,
                    color: isError == true
                        ? Colors.red.shade700
                        : Color(0xFFBDBDBD),
                  ),
                ),
                focusNode: focusNode,
                value: selectedValue,
                items: brokerNameValue
                    .map(
                      (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: InvestrendTheme.of(context)
                                .regular_w400_compact_greyDarker,
                          )),
                    )
                    .toList(),
                icon: Icon(Icons.arrow_drop_down_sharp),
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue;
                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: Text(
                selectedValue,
                style: InvestrendTheme.of(context)
                    .more_support_w400_compact_greyDarker,
              ),
            ),
            SizedBox(
              height: 4.0,
            ),
            SizedBox(
              height: InvestrendTheme.cardPaddingVertical,
            ),
            _filterTopBrokerTransaction(context),
            ChipsRangeCustom(
              _rangeTopBrokerNotifier,
              paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
              paddingBottom: InvestrendTheme.cardPadding,
            ),
            createHeader(leftWidth, centerWidth, leftWidth),
            Expanded(
              flex: 1,
              child: ListView.separated(
                shrinkWrap: false,
                itemCount: brokerTradeData.length,
                separatorBuilder: (context, index) {
                  return Container(
                    color: Theme.of(context).colorScheme.background,
                    height: 1.0,
                  );
                },
                itemBuilder: (context, index) {
                  int line = index + 1;
                  bool odd = (line - 1) % 2 != 0;
                  return Container(
                    color: odd
                        ? InvestrendTheme.of(context).oddColor
                        : Theme.of(context).colorScheme.background,
                    padding: EdgeInsets.only(
                      left: InvestrendTheme.cardPaddingGeneral,
                      right: InvestrendTheme.cardPaddingGeneral,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: leftWidth * 0.3,
                          child: Text(
                            data[index].buyStock,
                            style: textStyle.copyWith(
                                color: colorStock[data[index].buyStockSector],
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: leftWidth * 0.35,
                          child: AutoSizeText(
                            data[index].bAverage,
                            style: textStyle,
                            textAlign: TextAlign.right,
                            group: widget.groupValue,
                            minFontSize: 5,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          width: leftWidth * 0.35,
                          child: AutoSizeText(
                            data[index].bValue,
                            style: textStyle,
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
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor,
                          child: AutoSizeText(
                            InvestrendTheme.formatNewComma(line.toDouble()),
                            style: textStyle.copyWith(
                                color: InvestrendTheme.of(context).textWhite),
                            textAlign: TextAlign.center,
                            group: widget.groupValue,
                            minFontSize: 5,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          width: InvestrendTheme.cardPadding,
                        ),
                        SizedBox(
                          width: leftWidth * 0.3,
                          child: Text(
                            data[index].sellStock,
                            style: textStyle.copyWith(
                                color: colorStock[data[index].sellStockSector],
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: leftWidth * 0.35,
                          child: AutoSizeText(
                            data[index].sAverage,
                            style: textStyle,
                            textAlign: TextAlign.right,
                            group: widget.groupValue,
                            minFontSize: 5,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          width: leftWidth * 0.35,
                          child: AutoSizeText(
                            data[index].sValue,
                            style: textStyle,
                            textAlign: TextAlign.right,
                            group: widget.groupValue,
                            minFontSize: 5,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  dateInfo,
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: InvestrendTheme.of(context).greyDarkerTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget createHeader(
    double leftWidth,
    double centerWidth,
    double rightWidth,
  ) {
    TextStyle styleBold = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle styleHeader = InvestrendTheme.of(context).small_w500_compact;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral,
            top: InvestrendTheme.cardPadding,
            bottom: InvestrendTheme.cardPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Buyer',
                  textAlign: TextAlign.center,
                  style: styleBold.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                flex: 1,
              ),
              //Text(' # ', textAlign: TextAlign.center, style: styleHeader,),
              Expanded(
                child: Text(
                  'Seller',
                  textAlign: TextAlign.center,
                  style:
                      styleBold.copyWith(color: InvestrendTheme.sellTextColor),
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              bottom: InvestrendTheme.cardPadding),
          child: Row(
            children: [
              SizedBox(
                width: leftWidth * 0.3,
                child: Text('Stock',
                    style: styleHeader, textAlign: TextAlign.left),
              ),
              SizedBox(
                width: leftWidth * 0.35,
                child: AutoSizeText(
                  'Avg',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: leftWidth * 0.35,
                child: AutoSizeText(
                  'Value',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: InvestrendTheme.cardPadding,
              ),
              Container(
                  width: centerWidth,
                  alignment: Alignment.center,
                  //padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  //color: Colors.grey,
                  child: Text('#', style: styleHeader)),
              SizedBox(
                width: InvestrendTheme.cardPadding,
              ),
              SizedBox(
                width: rightWidth * 0.3,
                child: Text(
                  'Code',
                  style: styleHeader,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                width: rightWidth * 0.35,
                child: AutoSizeText(
                  'Avg',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: rightWidth * 0.35,
                child: AutoSizeText(
                  'Value',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterTopBrokerTransaction(BuildContext context) {
    //double paddingMargin = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return Padding(
      padding: EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPadding,
        //top: InvestrendTheme.cardPaddingVertical
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text('Filter', style: InvestrendTheme
          //     .of(context)
          //     .small_w500_compact,),
          // Spacer(flex: 1,),
          ButtonDropdown(marketNotifier, marketOptions),
          ButtonDropdown(dataByNotifier, dataByOptions),
          ButtonDropdown(filterByNotifier, filterOptions),
        ],
      ),
    );
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }
}
