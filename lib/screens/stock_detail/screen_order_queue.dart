import 'dart:async';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

class ScreenOrderQueue extends StatefulWidget {
  //final StockThemes themes;
  //final List<Stock> list;
  final String code;
  final String board;
  final String type;
  final int price;

  // final Color color;
  // final Index indexSector;

  //code=BUMI&board=RG&price=66&type=BID

  const ScreenOrderQueue(this.code, this.board, this.type, this.price, {Key key}) : super(key: key);

  @override
  _ScreenOrderQueueState createState() => _ScreenOrderQueueState(code, board, type, price);
}

class _ScreenOrderQueueState extends VisibilityAwareState<ScreenOrderQueue> {
  final String routeName = '/order_queue';

  String code = '';
  String board = '';
  String type = '';
  int price = 0;

  _ScreenOrderQueueState(this.code, this.board, this.type,
      this.price); //final GeneralPriceNotifier _watchlistDataNotifier = GeneralPriceNotifier(new GeneralPriceData());
  //final SlidableController slidableController = SlidableController();

  final OrderQueueNotifier _notifier = OrderQueueNotifier(OrderQueueData());
  bool active = false;

  /*

  bool canTapRow = true;
  IndexSummaryNotifier _indexNotifier;
  Timer _timer;
  static const Duration _durationUpdate = Duration(milliseconds: 2500);
  final ValueNotifier<int> _sortNotifier = ValueNotifier<int>(0);
  final String PROP_SELECTED_SORT = 'selectedSort';

  List<String> _sort_by_option = [
    'watchlist_sort_by_a_to_z'.tr(),
    'watchlist_sort_by_z_to_a'.tr(),
    'watchlist_sort_by_movers_highest'.tr(),
    'watchlist_sort_by_movers_lowest'.tr(),
    'watchlist_sort_by_price_highest'.tr(),
    'watchlist_sort_by_price_lowest'.tr()
  ];
  */

  @override
  void initState() {
    super.initState();
    /*
    _sortNotifier.addListener(sort);
    _indexNotifier = IndexSummaryNotifier(null, widget.indexSector);
    GeneralPriceData members = GeneralPriceData();
    widget.list.forEach((stock) {
      members.datas.add(GeneralPrice(stock.code, 0, 0.0, 0.0, name: stock.name));
    });
    _watchlistDataNotifier.setValue(members);

    runPostFrame(() {
      // #1 get properties
      int selectedSort = context.read(propertiesNotifier).properties.getInt(routeName, PROP_SELECTED_SORT, 0);

      // #2 use properties
      _sortNotifier.value = min(selectedSort, _sort_by_option.length - 1);

      // #3 check properties if changed, then save again
      if (selectedSort != _sortNotifier.value) {
        context.read(propertiesNotifier).properties.saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
      }

      onRefresh();
    });
    */
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  void _onActiveBase({String caller = ''}) {
    active = true;
    print(routeName + ' onActive  $caller');
    runPostFrame(onActive);
  }

  void runPostFrame(Function function) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        print(routeName + ' runPostFrame executed');
        function();
      } else {
        print(routeName + ' runPostFrame aborted due mounted : $mounted');
      }
    });
  }

  void _onInactiveBase({String caller = ''}) {
    active = false;
    print(routeName + ' onInactive  $caller');
    onInactive();
  }

  void onActive() {
    //canTapRow = true;
    doUpdate();
  }

  void onInactive() {
    //slidableController.activeState = null;
    //canTapRow = true;
  }

  bool onProgress = false;

  Future doUpdate({bool pullToRefresh = false}) async {
    if (!active) {
      print(routeName + '.doUpdate Aborted : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");
      return false;
    }
    onProgress = true;
    print(routeName + '.doUpdate : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");

    try {
      final orderQueue = await InvestrendTheme.datafeedHttp.fetchOrderQueue(code, board, price, type);
      if (orderQueue != null) {
        print('Future DATA : ' + orderQueue.type);
        if (mounted) {
          _notifier.setValue(orderQueue);
          if (orderQueue.hasMessage()) {
            InvestrendTheme.of(context).showSnackBar(context, orderQueue.message);
          }
        }
      } else {
        print('Future NO DATA');
      }
    } catch (error,trace) {
      print(error);
      print(trace);
    }

    //Watchlist activeWatchlist = context.read(watchlistChangeNotifier).getWatchlist(_watchlistNotifier.value);
    /*
    if(widget.indexSector != null){
      try {
        final indexSummarys = await HttpIII.fetchIndices([widget.indexSector.code]);
        if (indexSummarys.length > 0) {
          print('Future DATA : ' + indexSummarys.length.toString());
          indexSummarys.forEach((indexSummary) {
            if (indexSummary != null) {
              //print(indexSummary.toString());


              if (StringUtils.equalsIgnoreCase(indexSummary.code, widget.indexSector.code)) {
                if(mounted){
                  _indexNotifier.setData(indexSummary);
                }
              }
            }
          });
        } else {
          print('Future NO DATA');
        }
      } catch (error) {

      }
    }

    if (widget.list != null && widget.list.isNotEmpty) {
      try {
        print(routeName + ' try Summarys');
        String codes;
        widget.list.forEach((stock) {
          if (StringUtils.isEmtpy(codes)) {
            codes = stock.code;
          } else {
            codes = codes + '_' + stock.code;
          }
        });

        final stockSummarys = await HttpIII.fetchStockSummaryMultiple(codes, 'RG');
        if (stockSummarys != null && stockSummarys.isNotEmpty) {
          //print(routeName + ' Future Summary DATA : ' + stockSummary.code + '  prev : ' + stockSummary.prev.toString());
          //_summaryNotifier.setData(stockSummary);
          //context.read(stockSummaryChangeNotifier).setData(stockSummary);
          _watchlistDataNotifier.updateBySummarys(stockSummarys);
          sort();
        } else {
          print(routeName + ' Future Summarys NO DATA');
        }
      } catch (e) {
        DebugWriter.info(routeName + ' Summarys Exception : ' + e.toString());
        print(e);
      }
    } else {
      print(routeName + ' Aborted due to Active Watchlist is EMPTY');
    }
    */
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    onProgress = false;
    return true;
  }

  void onVisibilityChanged(WidgetVisibility visibility) {
    // TODO: Use visibility
    switch (visibility) {
      case WidgetVisibility.VISIBLE:
        // Like Android's Activity.onResume()
        print('*** ScreenVisibility.VISIBLE: ${this.routeName}');
        _onActiveBase(caller: 'onVisibilityChanged.VISIBLE');
        break;
      case WidgetVisibility.INVISIBLE:
        // Like Android's Activity.onPause()
        print('*** ScreenVisibility.INVISIBLE: ${this.routeName}');
        _onInactiveBase(caller: 'onVisibilityChanged.INVISIBLE');
        break;
      case WidgetVisibility.GONE:
        // Like Android's Activity.onDestroy()
        print('*** ScreenVisibility.GONE: ${this.routeName}   mounted : $mounted');
        _onInactiveBase(caller: 'onVisibilityChanged.GONE');
        break;
    }

    super.onVisibilityChanged(visibility);
  }

  /*
  void _startTimer() {
    print(routeName + '._startTimer');
    if (_timer == null || !_timer.isActive) {
      _timer = Timer.periodic(_durationUpdate, (timer) {
        print('_timer.tick : ' + _timer.tick.toString());
        if (active) {
          if (onProgress) {
            print(routeName + ' timer aborted caused by onProgress : $onProgress');
          } else {
            doUpdate();
          }
        }
      });
    }
  }

  void _stopTimer() {
    print(routeName + '._stopTimer');
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
  }
  */

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
      backgroundColor: Theme.of(context).backgroundColor,
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      //floatingActionButton: createFloatingActionButton(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
        shadowColor: shadowColor,
        elevation: elevation,
        title: AppBarTitleText('Price Queue'),
        // actions: [
        //   Image.asset(widget.icon, color: Theme.of(context).primaryColor,),
        // ],
        leading: AppBarActionIcon(
          'images/icons/action_back.png',
          () {
            Navigator.of(context).pop();
          },
          color: Theme.of(context).accentColor,
        ),
      ),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return null;

    TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;
    Size size = UIHelper.textSize('Lg|', valueStyle);
    double contentHeight = (10 + 10 + size.height) * 3;
    double paddingHeight = 8.0 + (paddingBottom > 0 ? paddingBottom : 8.0) + 50.0;
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0,
          bottom: paddingBottom > 0 ? paddingBottom : 8.0,
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Container(
        color: Colors.orangeAccent,
        width: double.maxFinite,
        height: 150.0,
      ),
    );
  }

  /*
  Widget getTableDataNew(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _indexNotifier,
      builder: (context, value, child) {
        if (_indexNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }



        return LayoutBuilder(
            builder: (context, constraints) {
              double marginSection = 25.0;

              //double maxWidthSection = ((constraints.maxWidth - marginSection) / 2);// - marginContent;
              double availableWidth = (constraints.maxWidth - marginSection);
              double widthLeftSection = availableWidth * 0.4;
              double widthRightSection = availableWidth - widthLeftSection;


              TextStyle labelStyle = InvestrendTheme.of(context).textLabelStyle;
              TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;

              List<LabelValueColor> listLeft = List.empty(growable: true);
              List<LabelValueColor> listRight = List.empty(growable: true);


              listLeft.add(LabelValueColor('Open', InvestrendTheme.formatPriceDouble(_indexNotifier.value.open, showDecimal: false), color: _indexNotifier.value.openColor()));
              listRight.add(LabelValueColor('Value', InvestrendTheme.formatValue(context, _indexNotifier.value.value),));

              listLeft.add(LabelValueColor('Low', InvestrendTheme.formatPriceDouble(_indexNotifier.value.low, showDecimal: false), color: _indexNotifier.value.lowColor()));
              listRight.add(LabelValueColor('Vol (Shares)', InvestrendTheme.formatValue(context, _indexNotifier.value.volume)));

              listLeft.add(LabelValueColor('High', InvestrendTheme.formatPriceDouble(_indexNotifier.value.hi, showDecimal: false), color: _indexNotifier.value.hiColor()));
              listRight.add(LabelValueColor('Frequency (x)', InvestrendTheme.formatComma(_indexNotifier.value.freq)));

              int count = listLeft.length;

              List<TextStyle> styles = [labelStyle, valueStyle];
              for( int i = 0; i < count ; i++){
                LabelValueColor leftLVC = listLeft.elementAt(i);
                LabelValueColor rightLVC = listRight.elementAt(i);
                styles = UIHelper.calculateFontSizes(context, styles, widthLeftSection, [leftLVC.label, leftLVC.value]);
                styles = UIHelper.calculateFontSizes(context, styles, widthRightSection, [rightLVC.label, rightLVC.value]);
              }
              labelStyle = styles.elementAt(0);
              valueStyle = styles.elementAt(1);

              List<Widget> childs = List.empty(growable: true);
              for( int i = 0; i < count ; i++) {
                LabelValueColor leftLVC = listLeft.elementAt(i);
                LabelValueColor rightLVC = listRight.elementAt(i);
                childs.add(Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // color: Colors.yellow,
                        width: widthLeftSection,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              leftLVC.label,
                              maxLines: 1,
                              style: labelStyle,
                              textAlign: TextAlign.left,
                            ),
                            Spacer(flex: 1,),
                            Text(
                              leftLVC.value,
                              maxLines: 1,
                              style: leftLVC.color == null ? valueStyle : valueStyle.copyWith(color: leftLVC.color),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: marginSection,),
                      Container(
                        // color: Colors.orange,
                        width: widthRightSection,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              rightLVC.label,
                              maxLines: 1,
                              style: labelStyle,
                              textAlign: TextAlign.left,
                            ),
                            Spacer(flex: 1,),
                            Text(
                              rightLVC.value,
                              maxLines: 1,
                              style: rightLVC.color == null ? valueStyle : valueStyle.copyWith(color: rightLVC.color),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ));
              }
              return Column(
                children: childs,
              );
            });
      },
    );
  }
  */
  Future onRefresh() {
    if (!active) {
      active = true;
      //canTapRow = true;
    }
    return doUpdate(pullToRefresh: true);
    //return Future.delayed(Duration(seconds: 3));
  }

  AutoSizeGroup groupNo = AutoSizeGroup();
  AutoSizeGroup groupOrderNo = AutoSizeGroup();
  AutoSizeGroup groupRemLot = AutoSizeGroup();
  AutoSizeGroup groupBroker = AutoSizeGroup();
  AutoSizeGroup groupDF = AutoSizeGroup();
  AutoSizeGroup groupStatus = AutoSizeGroup();

  AutoSizeGroup groupHeader = AutoSizeGroup();

  double ratioWidthNo = 0.15;
  double ratioWidthOrderNo = 0.225;
  double ratioWidthRemLot = 0.225;
  double ratioWidthBroker = 0.15;
  double ratioWidthDF = 0.1;
  double ratioWidthStatus = 0.15;

  Widget createTopInfo(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPadding),
      child: ValueListenableBuilder(
          valueListenable: _notifier,
          builder: (context, OrderQueueData data, child) {
            Widget noWidget = _notifier.currentState.getNoWidget(onRetry: (){
              doUpdate(pullToRefresh: true);
            });
            if(noWidget != null){

              return SizedBox(width: 1.0,);
            }

            Stock stock = InvestrendTheme.storedData.findStock(data.code);
            String name = stock == null ? '-' : stock.name;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.code, style: InvestrendTheme.of(context).regular_w600,),
                SizedBox(
                  height: 4.0,
                ),
                Text(name, style: InvestrendTheme.of(context).more_support_w400_compact_greyDarker),
                SizedBox(
                  height: InvestrendTheme.cardPadding,
                ),
                Table(defaultVerticalAlignment: TableCellVerticalAlignment.middle, columnWidths: {
                  0: FractionColumnWidth(.5),
                  1: FractionColumnWidth(.5)
                }, children: [
                  TableRow(children: [
                    Text(data.translateType().toCapitalized(), style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
                    Text('Queue', style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
                  ]),
                  TableRow(children: [
                    Text(InvestrendTheme.formatComma(data.price), style: InvestrendTheme.of(context).regular_w600,),
                    Text(InvestrendTheme.formatComma(data.datas_count), style: InvestrendTheme.of(context).regular_w600,),
                  ]),
                  TableRow(children: [
                    Text('Total Balance Lot', style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
                    Text('Total Lot', style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
                  ]),
                  TableRow(children: [
                    Text(InvestrendTheme.formatComma(data.total_remaining_lot()), style: InvestrendTheme.of(context).regular_w600,),
                    Text(InvestrendTheme.formatComma(data.total_lot()), style: InvestrendTheme.of(context).regular_w600,),

                    // Text(data.total_remaining_volume.toString(), style: InvestrendTheme.of(context).regular_w600,),
                    // Text(data.total_volume.toString(), style: InvestrendTheme.of(context).regular_w600,),
                  ]),
                ]),
              ],
            );
          }),
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    // List<Widget> pre_childs = List.empty(growable: true);
    //
    // pre_childs.add(Padding(
    //   padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: 24.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         widget.title,
    //         style: Theme.of(context).textTheme.headline4.copyWith(color: InvestrendTheme.textWhite, fontWeight: FontWeight.w600),
    //       ),
    //     ],
    //   ),
    // ));
    // pre_childs.add(value);
    // pre_childs.add(value);
    // pre_childs.add(value);

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          TextStyle styleHeader = InvestrendTheme.of(context).small_w500_compact;
          final double widthAvailable = constraints.maxWidth - InvestrendTheme.cardPaddingGeneral - InvestrendTheme.cardPaddingGeneral;
          return Column(
            children: [
              createTopInfo(context),
              //createHeader(context, styleHeader, widthAvailable),
              createHeaderWithoutBroker(context, styleHeader, widthAvailable),
              Expanded(
                flex: 1,
                child: ValueListenableBuilder(
                    valueListenable: _notifier,
                    builder: (context, OrderQueueData data, child) {
                      Widget noWidget = _notifier.currentState.getNoWidget(onRetry: (){
                        doUpdate(pullToRefresh: true);
                      });

                      if(_notifier.currentState.isNoData() && !StringUtils.isEmtpy(data.message)){
                        noWidget = EmptyLabel(text: data.message,);
                      }
                      if(noWidget != null){
                        return ListView(
                          children: [

                            Padding(
                              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width / 4, left: 20.0, right: 20.0),
                              child: Center(child: noWidget,),
                            ),
                          ],
                        );
                      }

                      int dataCount = data != null ? data.count() : 0;
                      TextStyle styleNo = InvestrendTheme.of(context).small_w400_compact_greyDarker;

                      TextStyle styleDarker = InvestrendTheme.of(context).small_w400_compact_greyDarker;
                      TextStyle styleLighter =
                          InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
                      TextStyle style = InvestrendTheme.of(context).small_w400;
                      TextStyle styleSupport = InvestrendTheme.of(context).more_support_w400;

                      return ListView.separated(
                          shrinkWrap: false,
                          //padding: const EdgeInsets.all(8),
                          itemCount: dataCount,
                          separatorBuilder: (BuildContext context, int index) {
                            // if(index == 0){
                            //   return SizedBox(width: 1.0,);
                            // }
                            return Container(
                                padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                                color: Theme.of(context).backgroundColor,
                                child: ComponentCreator.divider(context));
                          },
                          itemBuilder: (BuildContext context, int index) {
                            // if (index >=  data.datas.length) {
                            //   return Container(
                            //     color: Theme.of(context).backgroundColor,
                            //     width: double.maxFinite,
                            //     height: paddingBottom,
                            //   );
                            // }

                            // if(index == 0){
                            //   return createHeader(context, styleHeader, widthAvailable);
                            // }
                            int indexData = index;
                            OrderQueue gp = data.datas.elementAt(indexData);
                            Color colorDivider = Theme.of(context).dividerColor;
                            String status = 'Open';
                            if (gp.volume != gp.remaining) {
                              colorDivider = Theme.of(context).accentColor;
                              status = 'Partial';
                            }

                            //return createRow(context, gp, styleDarker, styleLighter, widthAvailable);
                            return createRowWithoutBroker(context, gp, styleDarker, styleLighter, widthAvailable);
                            /*
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: InvestrendTheme.cardPaddingGeneral,
                                  right: InvestrendTheme.cardPaddingGeneral,
                                  top: InvestrendTheme.cardPadding,
                                  bottom: InvestrendTheme.cardPadding),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    InvestrendTheme.formatComma(gp.no) + '.',
                                    style: styleNo,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Text(
                                    gp.order,
                                    style: styleDarker,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        InvestrendTheme.formatComma(gp.remaining_lot()),
                                        style: styleDarker,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 1.5, bottom: 1.5),
                                        child: Container(
                                          width: 55.0,
                                          height: 0.5,
                                          color: colorDivider,
                                        ),
                                      ),
                                      Text(
                                        InvestrendTheme.formatComma(gp.lot()),
                                        style: styleLighter,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Text(
                                    gp.broker,
                                    style: styleDarker,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Text(
                                    gp.type,
                                    style: styleDarker,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        gp.status(),
                                        style: styleDarker,
                                      ),
                                      Text(
                                        gp.time,
                                        style: styleSupport,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                            */
                            // return Text(gp.order);
                          });
                    }),
              ),
            ],
          );
        },
      ),
    );

    /*
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ValueListenableBuilder(
          valueListenable: _notifier,
          builder: (context, OrderQueueData data, child) {
            int dataCount = data != null ? data.count() : 0;
            TextStyle styleNo = InvestrendTheme.of(context).small_w500_compact;
            TextStyle styleDarker = InvestrendTheme.of(context).small_w400_compact_greyDarker;
            TextStyle styleLighter =
                InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
            TextStyle style = InvestrendTheme.of(context).small_w400;
            TextStyle styleSupport = InvestrendTheme.of(context).more_support_w400;

            return ListView.separated(
                shrinkWrap: false,
                //padding: const EdgeInsets.all(8),
                itemCount: dataCount,
                separatorBuilder: (BuildContext context, int index) {
                  // if(index == 0){
                  //   return SizedBox(width: 1.0,);
                  // }
                  return Container(
                      padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                      color: Theme.of(context).backgroundColor,
                      child: ComponentCreator.divider(context));
                },
                itemBuilder: (BuildContext context, int index) {
                  // if (index >=  data.datas.length) {
                  //   return Container(
                  //     color: Theme.of(context).backgroundColor,
                  //     width: double.maxFinite,
                  //     height: paddingBottom,
                  //   );
                  // }

                  //int indexData = index - 1;
                  OrderQueue gp = data.datas.elementAt(index);
                  Color colorDivider = Theme.of(context).dividerColor;
                  String status = 'Open';
                  if (gp.volume != gp.remaining) {
                    colorDivider = Theme.of(context).accentColor;
                    status = 'Partial';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: InvestrendTheme.cardPaddingGeneral,
                        right: InvestrendTheme.cardPaddingGeneral,
                        top: InvestrendTheme.cardPadding,
                        bottom: InvestrendTheme.cardPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          InvestrendTheme.formatComma(gp.no) + '.',
                          style: styleNo,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          gp.order,
                          style: styleDarker,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        /*
                        RichText(text: TextSpan(
                          text: InvestrendTheme.formatComma(gp.remaining_lot())+' ',
                          style: styleDarker,
                          children: [
                            TextSpan(
                              text: '/',
                              style: styleLighter,
                            ),
                            TextSpan(
                                text: ' '+InvestrendTheme.formatComma(gp.lot()),
                                style: styleDarker
                            ),
                          ]
                        )),
                        */
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              InvestrendTheme.formatComma(gp.remaining_lot()),
                              style: styleDarker,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 1.5, bottom: 1.5),
                              child: Container(
                                width: 55.0,
                                height: 0.5,
                                color: colorDivider,
                              ),
                            ),
                            Text(
                              InvestrendTheme.formatComma(gp.lot()),
                              style: styleLighter,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          gp.broker,
                          style: styleDarker,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          gp.type,
                          style: styleDarker,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Column(
                          children: [
                            Text(
                              gp.status(),
                              style: styleDarker,
                            ),
                            Text(
                              gp.time,
                              style: styleSupport,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                  // return Text(gp.order);
                });
          }),
    );
    */
  }

  Widget createRow(BuildContext context, OrderQueue gp, TextStyle darker, TextStyle lighter, double widthAvailable) {
    return Container(
      width: double.maxFinite,
      // color: Colors.orangeAccent,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      //height: 40.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.green,
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              InvestrendTheme.formatComma(gp.no),
              style: darker,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupNo,
            ),
          ),
          Container(
            // color: Colors.white,
            width: 0.225 * widthAvailable,
            child: Column(
              children: [
                AutoSizeText(
                  gp.order,
                  style: darker,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupOrderNo,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  gp.time,
                  style: lighter,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupOrderNo,
                ),
              ],
            ),
          ),
          Container(
            width: 0.225 * widthAvailable,
            child: Column(
              children: [
                AutoSizeText(
                  InvestrendTheme.formatComma(gp.remaining_lot()),
                  style: darker,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupRemLot,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  '/' + InvestrendTheme.formatComma(gp.lot()),
                  style: lighter,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupRemLot,
                ),
              ],
            ),
          ),
          Container(
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              gp.broker,
              style: gp.brokerIsEmpty() ? darker : InvestrendTheme.of(context).small_w600_compact.copyWith(color: Theme.of(context).accentColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupBroker,
            ),
          ),
          Container(
            width: 0.1 * widthAvailable,
            child: AutoSizeText(
              gp.type,
              style: darker,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupDF,
            ),
          ),
          Container(
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              gp.status(),
              style: darker,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget createHeader(BuildContext context, TextStyle header, double widthAvailable) {
    return Container(
      // color: Colors.blue,
      width: double.maxFinite,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      //height: 40.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.green,
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              '#',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
          Container(
            // color: Colors.white,
            width: 0.225 * widthAvailable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  'Order',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  ' ',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
              ],
            ),
          ),
          Container(
            width: 0.225 * widthAvailable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  'Balance',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  '/Lot',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
              ],
            ),
          ),
          Container(
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              'Broker',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
          Container(
            width: 0.1 * widthAvailable,
            child: AutoSizeText(
              'F/D',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
          Container(
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              'Status',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
        ],
      ),
    );
  }

/*
  Widget createFloatingActionButton(BuildContext context) {
    return SizedBox(
      width: 35.0,
      height: 35.0,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        elevation: 1.0,
        focusElevation: 0.1,
        backgroundColor: InvestrendTheme.darkenColor(widget.color, 0.2),
        splashColor: InvestrendTheme.lightenColor(widget.color, 0.2),
        child: Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Image.asset(
            'images/icons/action_back.png',
            color: Theme.of(context).primaryColor,
            width: 18.0,
            height: 18.0,
          ),
        ),
        // child: Center(child: Icon(Icons.arrow_back_ios, color: InvestrendTheme.textWhite ,)),
      ),
    );
  }
  */


  Widget createRowWithoutBroker(BuildContext context, OrderQueue gp, TextStyle darker, TextStyle lighter, double widthAvailable) {
    return Container(
      width: double.maxFinite,
      // color: Colors.orangeAccent,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      //height: 40.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.green,
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              InvestrendTheme.formatComma(gp.no),
              style: darker,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupNo,
            ),
          ),
          Container(
            // color: Colors.white,
            //width: 0.225 * widthAvailable,
            width: 0.275 * widthAvailable,
            child: Column(
              children: [
                AutoSizeText(
                  gp.order,
                  style: darker,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupOrderNo,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  gp.time,
                  style: lighter,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupOrderNo,
                ),
              ],
            ),
          ),
          Container(
            //width: 0.225 * widthAvailable,
            width: 0.275 * widthAvailable,
            child: Column(
              children: [
                AutoSizeText(
                  InvestrendTheme.formatComma(gp.remaining_lot()),
                  style: darker,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupRemLot,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  '/' + InvestrendTheme.formatComma(gp.lot()),
                  style: lighter,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupRemLot,
                ),
              ],
            ),
          ),
          /*
          Container(
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              gp.broker,
              style: gp.brokerIsEmpty() ? darker : InvestrendTheme.of(context).small_w600_compact.copyWith(color: Theme.of(context).accentColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupBroker,
            ),
          ),
          */
          Container(
            width: 0.12 * widthAvailable,
            child: AutoSizeText(
              gp.type,
              style: darker,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupDF,
            ),
          ),
          Container(
            width: 0.17 * widthAvailable,
            child: AutoSizeText(
              gp.status(),
              style: darker,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget createHeaderWithoutBroker(BuildContext context, TextStyle header, double widthAvailable) {
    return Container(
      // color: Colors.blue,
      width: double.maxFinite,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      //height: 40.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.green,
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              '#',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
          Container(
            // color: Colors.white,
            //width: 0.225 * widthAvailable,
            width: 0.275 * widthAvailable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  'Order',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  ' ',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
              ],
            ),
          ),
          Container(
            //width: 0.225 * widthAvailable,
            width: 0.275 * widthAvailable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  'Balance',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
                SizedBox(
                  height: 4.0,
                ),
                AutoSizeText(
                  '/Lot',
                  style: header,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 6.0,
                  group: groupHeader,
                ),
              ],
            ),
          ),
          /*
          Container(
            width: 0.15 * widthAvailable,
            child: AutoSizeText(
              'Broker',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
           */
          Container(
            //width: 0.1 * widthAvailable,
            width: 0.12 * widthAvailable,
            child: AutoSizeText(
              'F/D',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
          Container(
            //width: 0.15 * widthAvailable,
            width: 0.17 * widthAvailable,
            child: AutoSizeText(
              'Status',
              style: header,
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 6.0,
              group: groupHeader,
            ),
          ),
        ],
      ),
    );
  }


}
