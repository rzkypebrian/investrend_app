import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/row_netbs_summary.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_analysis.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenNetBuySellSummary extends StatefulWidget {
  final String init_code;
  final int init_board;
  final String init_data_by; // belum tentu kepakai
  final String init_type; // belum tentu kepakai
  final MyRange init_range;

  //final init_from;  // belum tentu kepakai
  //final init_to;  // belum tentu kepakai

  const ScreenNetBuySellSummary(this.init_code, this.init_board,
      {this.init_type, this.init_data_by, this.init_range, Key key})
      : super(key: key);

  @override
  _ScreenNetBuySellSummaryState createState() =>
      _ScreenNetBuySellSummaryState();
}

class _ScreenNetBuySellSummaryState extends State<ScreenNetBuySellSummary> {
  final String routeName = '/netbs_summary';
  bool onProgress = false;
  ScrollController pScrollController = ScrollController();
  NetBuySellSummaryNotifier _netbsSummaryNotifier =
      NetBuySellSummaryNotifier(NetBuySellSummaryData.createBasic());
  final RangeNotifier _rangeTopBrokerNotifier =
      RangeNotifier(Range.createBasic());
  final ValueNotifier<int> marketNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> dataByNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> filterByNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> _lastDataDateNotifier = ValueNotifier<String>('');
  final ValueNotifier<int> selectedLineNotifier = ValueNotifier<int>(0);
  List<String> _market_options = [
    'card_local_foreign_button_all_market'.tr(),
    'card_local_foreign_button_rg_market'.tr(),
  ];

  List<String> _data_by_options = [
    'data_by_value_label'.tr(),
    'data_by_net_label'.tr(),
  ];

  List<String> _filter_options = [
    'filter_by_all_label'.tr(),
    'filter_by_domestic_label'.tr(),
    'filter_by_foreign_label'.tr()
  ];

  String code;

  //String board;
  String data_by; // belum tentu kepakai
  String type; // belum tentu kepakai
  //String from; // belum tentu kepakai
  //String to;

  @override
  void dispose() {
    pScrollController.dispose();
    _netbsSummaryNotifier.dispose();
    marketNotifier.dispose();
    dataByNotifier.dispose();
    filterByNotifier.dispose();
    _rangeTopBrokerNotifier.dispose();
    _lastDataDateNotifier.dispose();
    selectedLineNotifier.dispose();
    super.dispose();
  } // belum tentu kepakai

  Widget _infoTopBrokerTransaction(BuildContext context, double bottomPading) {
    if (bottomPading == 0) {
      bottomPading = InvestrendTheme.cardPaddingGeneral;
    }
    return ValueListenableBuilder(
      valueListenable: _lastDataDateNotifier,
      builder: (context, String date, child) {
        if (StringUtils.isEmtpy(date)) {
          return SizedBox(
            width: 1.0,
            height: bottomPading,
          );
        }

        //String info = 'last_data_date_info_label'.tr();
        //info = info.replaceAll('#DATE#', date);

        String displayTime = date;
        if (!StringUtils.isEmtpy(date)) {
          String infoTime = 'last_data_date_info_label'.tr();

          DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
          //DateFormat timeFormatter = DateFormat('HH:mm:ss');
          DateFormat dateParser = DateFormat('yyyy-MM-dd');
          DateTime dateTime = dateParser.parseUtc(date);
          print('dateTime : ' + dateTime.toString());
          print('stock_top_broker.last_date : ' + date);
          String formatedDate = dateFormatter.format(dateTime);
          //String formatedTime = timeFormatter.format(dateTime);
          infoTime = infoTime.replaceAll('#DATE#', formatedDate);
          //infoTime = infoTime.replaceAll('#TIME#', formatedTime);
          displayTime = infoTime;
        }
        return Center(
          child: Padding(
            padding: EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingGeneral,
                bottom: bottomPading),
            child: Text(
              displayTime,
              style: InvestrendTheme.of(context)
                  .more_support_w400_compact
                  .copyWith(
                    fontWeight: FontWeight.w500,
                    color: InvestrendTheme.of(context).greyDarkerTextColor,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        );
      },
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
          ButtonDropdown(marketNotifier, _market_options),
          ButtonDropdown(dataByNotifier, _data_by_options),
          ButtonDropdown(filterByNotifier, _filter_options),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    this.code = widget.init_code;
    //this.board = widget.init_board;
    this.data_by = widget.init_data_by;
    this.type = widget.init_type;
    //this.from = widget.init_from;
    //this.to = widget.init_to;
    marketNotifier.value = widget.init_board;

    String from = 'from_label'.tr();
    String to = 'to_label'.tr();
    if (!StringUtils.equalsIgnoreCase(widget.init_range.from, 'LD')) {
      from = widget.init_range.from;
    }
    if (!StringUtils.equalsIgnoreCase(widget.init_range.to, 'LD')) {
      to = widget.init_range.to;
    }
    _rangeTopBrokerNotifier.value.index = widget.init_range.index;
    _rangeTopBrokerNotifier.value.from = from;
    _rangeTopBrokerNotifier.value.to = to;

    _rangeTopBrokerNotifier.addListener(() {
      if (_rangeTopBrokerNotifier.value == 7) {
        // Custom Range
        //_customRangeNotifier.value = true;
      } else {
        //_customRangeNotifier.value = false;
        doUpdate();
      }
    });
    marketNotifier.addListener(() {
      doUpdate();
    });

    dataByNotifier.addListener(() {
      doUpdate();
    });

    filterByNotifier.addListener(() {
      doUpdate();
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdate();
    });
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    // if (!active) {
    //   print(routeName + '.doUpdate Aborted : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");
    //   return false;
    // }
    onProgress = true;
    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  pullToRefresh : $pullToRefresh");
    String lastDate = '';
    try {
      String board = marketNotifier.value == 0 ? '*' : 'RG';
      String dataBy =
          _data_by_options.elementAt(dataByNotifier.value).toLowerCase();
      String type = filterByNotifier.value == 0
          ? '*'
          : _filter_options
              .elementAt(filterByNotifier.value)
              .toString()
              .toLowerCase();
      //MyRange range = getRange();
      MyRange range = _rangeTopBrokerNotifier.getRange();
      // String from = '2021-12-09';
      // String to = '2021-12-09';
      //final stockTopBroker = await HttpIII.fetchStockTopBroker(stock.code, board, range.from, range.to);
      final netbsSummary = await InvestrendTheme.datafeedHttp
          .fetchStockTopBrokerSummary(
              code, board, range.from, range.to, type, dataBy);

      if (mounted) {
        if (netbsSummary != null) {
          lastDate = netbsSummary.last_date;
          print('Future DATA : ' + netbsSummary.type);

          _netbsSummaryNotifier.setValue(netbsSummary);
        } else {
          _netbsSummaryNotifier.setNoData();
          print('Future NO DATA');
        }
      }
    } catch (error, trace) {
      print(error);
      print(trace);
      if (mounted) {
        _netbsSummaryNotifier.setError(message: error.toString());
      }
    }
    if (mounted) {
      _lastDataDateNotifier.value = lastDate;
    }
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    onProgress = false;
    return true;
  }

  Future onRefresh() {
    // context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    // if (!active) {
    //   active = true;
    //   //onActive();
    //   context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    // }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  AutoSizeGroup groupValue = AutoSizeGroup();
  AutoSizeGroup groupHeader = AutoSizeGroup();

  Widget createHeader(
    BuildContext context,
    double leftWidth,
    double centerWidth,
    double rightWidth,
  ) {
    TextStyle styleBold = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle styleHeader = InvestrendTheme.of(context).small_w500_compact;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              top: InvestrendTheme.cardPadding,
              bottom: InvestrendTheme.cardPadding),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Buyer',
                  textAlign: TextAlign.center,
                  style:
                      styleBold.copyWith(color: Theme.of(context).colorScheme.secondary),
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
                child:
                    Text('Code', style: styleHeader, textAlign: TextAlign.left),
              ),
              SizedBox(
                width: leftWidth * 0.3,
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
                width: leftWidth * 0.4,
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
                child:
                    Text('Code', style: styleHeader, textAlign: TextAlign.left),
              ),
              SizedBox(
                width: rightWidth * 0.3,
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
                width: rightWidth * 0.4,
                child: AutoSizeText(
                  'Value',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),

              /*
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Code', style: styleHeader),
                    Text('Value', style: styleHeader),
                    Text('Avg', style: styleHeader),
                  ],
                ),
              ),

              Text(' # ', style: styleHeader.copyWith(color: Colors.transparent)),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Code', style: styleHeader),
                    Text('Value', style: styleHeader),
                    Text('Avg', style: styleHeader),
                  ],
                ),
              ),
               */
            ],
          ),
        ),
      ],
    );
  }

  Widget createRow(
      BuildContext context,
      double leftWidth,
      double centerWidth,
      double rightWidth,
      int line,
      NetBuySellSummary buyer,
      NetBuySellSummary seller,
      TextStyle style,
      TextStyle styleBroker) {
    //TextStyle style = InvestrendTheme.of(context).small_w400_compact;

    String buyerCode = '';
    String buyerValue = '';
    String buyerAverage = '';
    Color buyerColor;
    if (buyer != null) {
      buyerCode = buyer.Broker;
      buyerValue = InvestrendTheme.formatValue(context, buyer.Value);
      buyerAverage = InvestrendTheme.formatComma(buyer.Average.truncate());
      //buyerColor = buyer.color;
    } else {
      buyerColor = styleBroker.color;
    }

    String sellerCode = '';
    String sellerValue = '';
    String sellerAverage = '';
    Color sellerColor;
    if (seller != null) {
      sellerCode = seller.Broker;
      sellerValue = InvestrendTheme.formatValue(context, seller.Value);
      sellerAverage = InvestrendTheme.formatComma(seller.Average.truncate());
      //sellerColor = buyer.color;
    } else {
      sellerColor = styleBroker.color;
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
                style: styleBroker.copyWith(color: buyerColor),
                textAlign: TextAlign.left),
          ),
          SizedBox(
            width: leftWidth * 0.4,
            child: AutoSizeText(
              buyerAverage,
              style: style,
              textAlign: TextAlign.right,
              group: groupValue,
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
              group: groupValue,
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
                style: style.copyWith(
                    color: InvestrendTheme.of(context).textWhite),
                textAlign: TextAlign.center,
                group: groupValue,
                minFontSize: 5,
                maxLines: 1,
              )),
          SizedBox(
            width: InvestrendTheme.cardPadding,
          ),
          SizedBox(
            width: rightWidth * 0.2,
            child: Text(sellerCode,
                style: styleBroker.copyWith(color: sellerColor),
                textAlign: TextAlign.left),
          ),
          SizedBox(
            width: rightWidth * 0.4,
            child: AutoSizeText(
              sellerAverage,
              style: style,
              textAlign: TextAlign.right,
              group: groupValue,
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
              group: groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    //List<Widget> childs = List.empty(growable: true);
    //childs.add(Text('Test'));
    //childs.add(_titleTopBrokerTransaction(context));
    //childs.add(ChipsRangeCustom(_rangeTopBrokerNotifier, paddingLeftRight: InvestrendTheme.cardPaddingGeneral, paddingBottom: InvestrendTheme.cardPaddingVertical,));
    Stock stock = InvestrendTheme.storedData.findStock(code);
    String name = stock == null ? '-' : stock.name;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return RefreshIndicator(
          color: InvestrendTheme.of(context).textWhite,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral),
                child: Text(
                  code,
                  style: InvestrendTheme.of(context).regular_w600,
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral),
                child: Text(name,
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact_greyDarker),
              ),
              SizedBox(
                height: InvestrendTheme.cardPaddingVertical,
              ),
              //_titleTopBrokerTransaction(context),
              _filterTopBrokerTransaction(context),
              ChipsRangeCustom(
                _rangeTopBrokerNotifier,
                paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
                paddingBottom: InvestrendTheme.cardPadding,
              ),
              ValueListenableBuilder(
                valueListenable: _netbsSummaryNotifier,
                builder: (context, NetBuySellSummaryData data, child) {
                  int dataCount = data != null ? data.count() : 0;
                  TextStyle styleNo =
                      InvestrendTheme.of(context).small_w400_compact_greyDarker;

                  TextStyle styleDarker =
                      InvestrendTheme.of(context).small_w400_compact_greyDarker;

                  TextStyle style =
                      InvestrendTheme.of(context).small_w400_compact;

                  //double centerWidth = UIHelper.textSize('  ' + InvestrendTheme.formatNewComma(dataCount.toDouble()), style).width;
                  double centerWidth =
                      UIHelper.textSize(' 000 ', styleDarker).width;
                  double availableWidth = constraints.maxWidth -
                      (InvestrendTheme.cardPaddingGeneral * 2) -
                      (InvestrendTheme.cardPadding * 2);
                  double leftWidth = (availableWidth - centerWidth) / 2;
                  return createHeader(
                      context, leftWidth, centerWidth, leftWidth);
                },
              ),

              Expanded(
                flex: 1,
                child: ValueListenableBuilder(
                    valueListenable: _netbsSummaryNotifier,
                    builder: (context, NetBuySellSummaryData data, child) {
                      Widget noWidget = _netbsSummaryNotifier.currentState
                          .getNoWidget(onRetry: () {
                        doUpdate(pullToRefresh: true);
                      });

                      if (_netbsSummaryNotifier.currentState.isNoData() &&
                          !StringUtils.isEmtpy(data.message)) {
                        noWidget = EmptyLabel(
                          text: data.message,
                        );
                      }
                      if (noWidget != null) {
                        return ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width / 4,
                                  left: 20.0,
                                  right: 20.0),
                              child: Center(
                                child: noWidget,
                              ),
                            ),
                          ],
                        );
                      }

                      int dataCount = data != null ? data.count() : 0;
                      TextStyle styleNo = InvestrendTheme.of(context)
                          .small_w400_compact_greyDarker;

                      TextStyle styleDarker = InvestrendTheme.of(context)
                          .small_w400_compact_greyDarker;
                      TextStyle styleValue =
                          InvestrendTheme.of(context).small_w400_compact;

                      TextStyle style =
                          InvestrendTheme.of(context).small_w500_compact;

                      double centerWidth =
                          UIHelper.textSize(' 000 ', styleDarker).width;
                      double availableWidth = constraints.maxWidth -
                          (InvestrendTheme.cardPaddingGeneral * 2) -
                          (InvestrendTheme.cardPadding * 2);
                      double leftWidth = (availableWidth - centerWidth) / 2;

                      return ListView.separated(
                          shrinkWrap: false,
                          //padding: const EdgeInsets.all(8),
                          itemCount: dataCount,
                          separatorBuilder: (BuildContext context, int index) {
                            // if(index == 0){
                            //   return SizedBox(width: 1.0,);
                            // }
                            return Container(
                              //padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                              color: Theme.of(context).colorScheme.background,
                              height: 1.0,
                              //child: ComponentCreator.divider(context)
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {
                            //int indexData = index;
                            NetBuySellSummary buyer = data.getBuyer(index);
                            NetBuySellSummary seller = data.getSeller(index);

                            int line = index + 1;
                            //return createRow(context, leftWidth, centerWidth, leftWidth, line, buyer, seller, styleDarker, style);
                            return RowNetBSSummary(leftWidth, centerWidth,
                                leftWidth, styleDarker, style,
                                line: line,
                                buyer: buyer,
                                seller: seller,
                                selectedLineNotifier: selectedLineNotifier,
                                styleValue: styleValue);
                          });
                    }),
              ),
              _infoTopBrokerTransaction(context, paddingBottom),
              //SizedBox(height: paddingBottom, width: 1.0,), // sudah ada di _infoTopBrokerTransaction
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    double paddingTop = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      //floatingActionButton: createFloatingActionButton(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        shadowColor: shadowColor,
        elevation: elevation,
        title: AppBarTitleText('top_broker_transaction_title'.tr()),
        // actions: [
        //   Image.asset(widget.icon, color: Theme.of(context).primaryColor,),
        // ],
        leading: AppBarActionIcon(
          'images/icons/action_back.png',
          () {
            Navigator.of(context).pop();
          },
          //color: Theme.of(context).accentColor,
        ),
      ),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }
}
