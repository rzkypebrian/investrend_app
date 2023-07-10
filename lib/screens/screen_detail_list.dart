import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/bottom_sheet/bottom_sheet_alert.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rows/row_watchlist.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_detail.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenListDetail extends StatefulWidget {
  //final StockThemes themes;
  final List<Stock> list;
  final String title;
  final String icon;
  final Color color;
  final Index indexSector;

  const ScreenListDetail(this.list,
      {this.icon, this.title, this.color, this.indexSector, Key key})
      : super(key: key);

  @override
  _ScreenListDetailState createState() => _ScreenListDetailState();
}

class _ScreenListDetailState extends VisibilityAwareState<ScreenListDetail> {
  final String routeName = '/list_detail';
  final GeneralPriceNotifier _watchlistDataNotifier =
      GeneralPriceNotifier(new GeneralPriceData());
  final SlidableController slidableController = SlidableController();
  bool active = false;
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

  @override
  void initState() {
    super.initState();
    _sortNotifier.addListener(sort);
    _indexNotifier = IndexSummaryNotifier(null, widget.indexSector);
    GeneralPriceData members = GeneralPriceData();
    widget.list.forEach((stock) {
      //members.datas.add(GeneralPrice(stock.code, 0, 0.0, 0.0, name: stock.name));
      members.datas.add(WatchlistPrice(stock.code, 0, 0.0, 0.0, stock.name));
    });
    _watchlistDataNotifier.setValue(members);

    runPostFrame(() {
      // #1 get properties
      int selectedSort = context
          .read(propertiesNotifier)
          .properties
          .getInt(routeName, PROP_SELECTED_SORT, 0);

      // #2 use properties
      _sortNotifier.value = min(selectedSort, _sort_by_option.length - 1);

      // #3 check properties if changed, then save again
      if (selectedSort != _sortNotifier.value) {
        context
            .read(propertiesNotifier)
            .properties
            .saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
      }

      onRefresh();
    });
  }

  @override
  void dispose() {
    _watchlistDataNotifier.dispose();
    _sortNotifier.dispose();
    super.dispose();
  }

  void sort() {
    switch (_sortNotifier.value) {
      case 0: //a_to_z
        {
          _watchlistDataNotifier.value.datas
              .sort((a, b) => a.code.compareTo(b.code));
        }
        break;
      case 1: // z_to_a
        {
          _watchlistDataNotifier.value.datas
              .sort((a, b) => b.code.compareTo(a.code));
        }
        break;
      case 2: // movers_highest
        {
          _watchlistDataNotifier.value.datas
              .sort((a, b) => b.percent.compareTo(a.percent));
        }
        break;
      case 3: // movers_lowest
        {
          _watchlistDataNotifier.value.datas
              .sort((a, b) => a.percent.compareTo(b.percent));
        }
        break;
      case 4: // price_highest
        {
          _watchlistDataNotifier.value.datas
              .sort((a, b) => b.price.compareTo(a.price));
        }
        break;
      case 5: // price_lowest
        {
          _watchlistDataNotifier.value.datas
              .sort((a, b) => a.price.compareTo(b.price));
        }
        break;

        break;
    }
    _watchlistDataNotifier.notifyListeners();
    context
        .read(propertiesNotifier)
        .properties
        .saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
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
    canTapRow = true;
    doUpdate();
  }

  void onInactive() {
    slidableController.activeState = null;
    canTapRow = true;
  }

  bool onProgress = false;
  Future doUpdate({bool pullToRefresh = false}) async {
    if (!active) {
      print(routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  active : $active  pullToRefresh : $pullToRefresh");
      return false;
    }
    onProgress = true;
    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  active : $active  pullToRefresh : $pullToRefresh");
    //Watchlist activeWatchlist = context.read(watchlistChangeNotifier).getWatchlist(_watchlistNotifier.value);

    if (widget.indexSector != null) {
      try {
        final indexSummarys = await InvestrendTheme.datafeedHttp
            .fetchIndices([widget.indexSector.code]);
        if (indexSummarys.length > 0) {
          print('Future DATA : ' + indexSummarys.length.toString());
          indexSummarys.forEach((indexSummary) {
            if (indexSummary != null) {
              //print(indexSummary.toString());

              if (StringUtils.equalsIgnoreCase(
                  indexSummary.code, widget.indexSector.code)) {
                if (mounted) {
                  _indexNotifier.setData(indexSummary);
                }
              }
            }
          });
        } else {
          print('Future NO DATA');
        }
      } catch (error) {}
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

        final stockSummarys = await InvestrendTheme.datafeedHttp
            .fetchStockSummaryMultiple(codes, 'RG');
        if (stockSummarys != null && stockSummarys.isNotEmpty) {
          //print(routeName + ' Future Summary DATA : ' + stockSummary.code + '  prev : ' + stockSummary.prev.toString());
          //_summaryNotifier.setData(stockSummary);
          //context.read(stockSummaryChangeNotifier).setData(stockSummary);
          _watchlistDataNotifier.updateBySummarys(stockSummarys,
              context: context);
          sort();
        } else {
          print(routeName + ' Future Summarys NO DATA');
        }
      } catch (e) {
        DebugWriter.information(
            routeName + ' Summarys Exception : ' + e.toString());
        print(e);
      }
    } else {
      print(routeName + ' Aborted due to Active Watchlist is EMPTY');
    }
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
        print(
            '*** ScreenVisibility.GONE: ${this.routeName}   mounted : $mounted');
        _onInactiveBase(caller: 'onVisibilityChanged.GONE');
        break;
    }

    super.onVisibilityChanged(visibility);
  }

  List<String> owners_avatar = <String>[
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
    'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiJinli8IBVIpd5Un3l2uUuMb9iIXihrGobg&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
    'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiJinli8IBVIpd5Un3l2uUuMb9iIXihrGobg&usqp=CAU',
  ];
  List<String> owners_name = <String>[
    'Putri',
    'Philmon',
    'Richy',
    'Stella',
    'Watson',
    'Auri',
    'Putri',
    'Philmon',
    'Richy',
    'Stella',
    'Watson',
    'Auri',
  ];

  void _startTimer() {
    print(routeName + '._startTimer');
    if (_timer == null || !_timer.isActive) {
      _timer = Timer.periodic(_durationUpdate, (timer) {
        print('_timer.tick : ' + _timer.tick.toString());
        if (active) {
          if (onProgress) {
            print(routeName +
                ' timer aborted caused by onProgress : $onProgress');
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
      backgroundColor: widget.color,
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      //floatingActionButton: createFloatingActionButton(context),
      appBar: AppBar(
        backgroundColor: widget.color,
        centerTitle: true,
        shadowColor: shadowColor,
        elevation: elevation,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StringUtils.isEmtpy(widget.icon)
                ? SizedBox(
                    height: 1.0,
                  )
                : Image.asset(
                    widget.icon,
                    color: Theme.of(context).primaryColor,
                  ),
            SizedBox(
              width: InvestrendTheme.cardPadding,
            ),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headline4.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        // actions: [
        //   Image.asset(widget.icon, color: Theme.of(context).primaryColor,),
        // ],
        leading: AppBarActionIcon(
          'images/icons/action_back.png',
          () {
            Navigator.of(context).pop();
          },
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: createBody(context, paddingBottom),
      bottomSheet: widget.indexSector != null
          ? createBottomSheet(context, paddingBottom)
          : null,
    );
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;
    Size size = UIHelper.textSize('Lg|', valueStyle);
    double contentHeight = (10 + 10 + size.height) * 3;
    double paddingHeight =
        8.0 + (paddingBottom > 0 ? paddingBottom : 8.0) + 50.0;
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0,
          bottom: paddingBottom > 0 ? paddingBottom : 8.0,
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Wrap(
        // color: Colors.cyan,
        // width: double.maxFinite,
        // height: contentHeight + paddingHeight,
        // padding: EdgeInsets.only(top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
        children: [getTableDataNew(context)],
      ),
    );
  }

  Widget getTableDataNew(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _indexNotifier,
      builder: (context, value, child) {
        if (_indexNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(builder: (context, constraints) {
          double marginSection = 25.0;

          //double maxWidthSection = ((constraints.maxWidth - marginSection) / 2);// - marginContent;
          double availableWidth = (constraints.maxWidth - marginSection);
          double widthLeftSection = availableWidth * 0.4;
          double widthRightSection = availableWidth - widthLeftSection;

          TextStyle labelStyle = InvestrendTheme.of(context).textLabelStyle;
          TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;

          List<LabelValueColor> listLeft = List.empty(growable: true);
          List<LabelValueColor> listRight = List.empty(growable: true);

          listLeft.add(LabelValueColor(
              'Open',
              InvestrendTheme.formatPriceDouble(_indexNotifier.value.open,
                  showDecimal: false),
              color: _indexNotifier.value.openColor()));
          listRight.add(LabelValueColor(
            'Value',
            InvestrendTheme.formatValue(context, _indexNotifier.value.value),
          ));

          listLeft.add(LabelValueColor(
              'Low',
              InvestrendTheme.formatPriceDouble(_indexNotifier.value.low,
                  showDecimal: false),
              color: _indexNotifier.value.lowColor()));
          listRight.add(LabelValueColor(
              'Vol (Shares)',
              InvestrendTheme.formatValue(
                  context, _indexNotifier.value.volume)));

          listLeft.add(LabelValueColor(
              'High',
              InvestrendTheme.formatPriceDouble(_indexNotifier.value.hi,
                  showDecimal: false),
              color: _indexNotifier.value.hiColor()));
          listRight.add(LabelValueColor('Frequency (x)',
              InvestrendTheme.formatComma(_indexNotifier.value.freq)));

          int count = listLeft.length;

          List<TextStyle> styles = [labelStyle, valueStyle];
          for (int i = 0; i < count; i++) {
            LabelValueColor leftLVC = listLeft.elementAt(i);
            LabelValueColor rightLVC = listRight.elementAt(i);
            styles = UIHelper.calculateFontSizes(context, styles,
                widthLeftSection, [leftLVC.label, leftLVC.value]);
            styles = UIHelper.calculateFontSizes(context, styles,
                widthRightSection, [rightLVC.label, rightLVC.value]);
          }
          labelStyle = styles.elementAt(0);
          valueStyle = styles.elementAt(1);

          List<Widget> childs = List.empty(growable: true);
          for (int i = 0; i < count; i++) {
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
                        Spacer(
                          flex: 1,
                        ),
                        Text(
                          leftLVC.value,
                          maxLines: 1,
                          style: leftLVC.color == null
                              ? valueStyle
                              : valueStyle.copyWith(color: leftLVC.color),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: marginSection,
                  ),
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
                        Spacer(
                          flex: 1,
                        ),
                        Text(
                          rightLVC.value,
                          maxLines: 1,
                          style: rightLVC.color == null
                              ? valueStyle
                              : valueStyle.copyWith(color: rightLVC.color),
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

  Future onRefresh() {
    if (!active) {
      active = true;
      canTapRow = true;
    }
    return doUpdate(pullToRefresh: true);
    //return Future.delayed(Duration(seconds: 3));
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
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ValueListenableBuilder(
          valueListenable: _watchlistDataNotifier,
          builder: (context, GeneralPriceData data, child) {
            // if(data.count() == 0){
            //   return ListView(
            //     children: [
            //       _options(context),
            //       Container(
            //         //color: Colors.orange,
            //           height: MediaQuery.of(context).size.width,child: EmptyLabel()),
            //     ],
            //   );
            // }
            int dataCount = data != null ? data.count() : 0;
            dataCount += 1; // tambahan button sort
            return ListView.separated(
                shrinkWrap: false,
                //padding: const EdgeInsets.all(8),
                itemCount: dataCount,
                separatorBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return SizedBox(
                      width: 1.0,
                    );
                  }
                  return Container(
                      padding: EdgeInsets.only(
                          left: InvestrendTheme.cardPaddingGeneral,
                          right: InvestrendTheme.cardPaddingGeneral),
                      color: Theme.of(context).colorScheme.background,
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
                  if (index == 0) {
                    return Container(
                      color: Theme.of(context).colorScheme.background,
                      padding: EdgeInsets.only(
                        left: InvestrendTheme.cardPaddingGeneral,
                        right: InvestrendTheme.cardPaddingGeneral,
                        top: InvestrendTheme.cardPaddingGeneral,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ButtonDropdown(
                            _sortNotifier,
                            _sort_by_option,
                            clickAndClose: true,
                          ),
                        ],
                      ),
                    );
                  }

                  int indexData = index - 1;
                  //GeneralPrice gp = data.datas.elementAt(indexData );

                  GeneralPrice generalPrice = data.datas.elementAt(indexData);
                  WatchlistPrice gp;
                  if (generalPrice is WatchlistPrice) {
                    gp = generalPrice;
                  }

                  return Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Slidable(
                        controller: slidableController,
                        closeOnScroll: true,
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.22,
                        secondaryActions: <Widget>[
                          TradeSlideAction(
                            'button_buy'.tr(),
                            InvestrendTheme.buyColor,
                            () {
                              print('buy clicked code : ' + gp.code);
                              Stock stock =
                                  InvestrendTheme.storedData.findStock(gp.code);
                              if (stock == null) {
                                print('buy clicked code : ' +
                                    gp.code +
                                    ' aborted, not find stock on StockStorer');
                                return;
                              }

                              context
                                  .read(primaryStockChangeNotifier)
                                  .setStock(stock);

                              //InvestrendTheme.push(context, ScreenTrade(OrderType.Buy), ScreenTransition.SlideLeft, '/trade');

                              bool hasAccount = context
                                      .read(dataHolderChangeNotifier)
                                      .user
                                      .accountSize() >
                                  0;
                              InvestrendTheme.pushScreenTrade(
                                context,
                                hasAccount,
                                type: OrderType.Buy,
                              );
                              /*
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => ScreenTrade(OrderType.Buy),
                                    settings: RouteSettings(name: '/trade'),
                                  ));

                               */
                            },
                            tag: 'button_buy',
                          ),
                          TradeSlideAction(
                            'button_sell'.tr(),
                            InvestrendTheme.sellColor,
                            () {
                              print('sell clicked code : ' + gp.code);
                              Stock stock =
                                  InvestrendTheme.storedData.findStock(gp.code);
                              if (stock == null) {
                                print('sell clicked code : ' +
                                    gp.code +
                                    ' aborted, not find stock on StockStorer');
                                return;
                              }

                              context
                                  .read(primaryStockChangeNotifier)
                                  .setStock(stock);
                              //InvestrendTheme.push(context, ScreenTrade(OrderType.Sell), ScreenTransition.SlideLeft, '/trade');

                              bool hasAccount = context
                                      .read(dataHolderChangeNotifier)
                                      .user
                                      .accountSize() >
                                  0;
                              InvestrendTheme.pushScreenTrade(
                                context,
                                hasAccount,
                                type: OrderType.Sell,
                              );
                              /*
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => ScreenTrade(OrderType.Sell),
                                    settings: RouteSettings(name: '/trade'),
                                  ));
                              */
                            },
                            tag: 'button_sell',
                          ),
                          /*
                          CancelSlideAction('button_cancel'.tr(), Theme.of(context).backgroundColor, () {
                            InvestrendTheme.of(context).showSnackBar(context, 'cancel');
                          }),
                          */
                        ],
                        child: RowWatchlist(
                          gp,
                          firstRow: true,
                          onTap: () {
                            print('clicked code : ' +
                                gp.code +
                                '  canTapRow : $canTapRow');
                            if (canTapRow) {
                              canTapRow = false;

                              Stock stock =
                                  InvestrendTheme.storedData.findStock(gp.code);
                              if (stock == null) {
                                print('clicked code : ' +
                                    gp.code +
                                    ' aborted, not find stock on StockStorer');
                                canTapRow = true;
                                return;
                              }
                              context
                                  .read(primaryStockChangeNotifier)
                                  .setStock(stock);

                              Future.delayed(Duration(milliseconds: 200), () {
                                canTapRow = true;
                                InvestrendTheme.of(context)
                                    .showStockDetail(context);
                              });
                            }
                          },
                          paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
                          showBidOffer: false,
                          onPressedButtonCorporateAction: () =>
                              onPressedButtonCorporateAction(
                                  context, gp.corporateAction),
                          //onPressedButtonSpecialNotation: ()=> onPressedButtonSpecialNotation(context, gp.notation),
                          onPressedButtonSpecialNotation: () =>
                              onPressedButtonImportantInformation(
                                  context, gp.notation, gp.suspendStock),
                        )),
                  );
                });
          }),
    );
  }

  /*
  void onPressedButtonSpecialNotation(BuildContext context, List<Remark2Mapping> notation) {
    List<Widget> childs = List.empty(growable: true);
    if (notation != null && notation.isNotEmpty) {
      notation.forEach((remark2) {
        if (remark2 != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      });

      showAlert(context, childs, childsHeight: (childs.length * 40).toDouble());
    }
  }
  */
  void onPressedButtonImportantInformation(BuildContext context,
      List<Remark2Mapping> notation, SuspendStock suspendStock) {
    int count = notation == null ? 0 : notation.length;
    if (count == 0 && suspendStock == null) {
      print(routeName +
          '.onPressedButtonImportantInformation not showing anything');
      return;
    }
    print(routeName + '.onPressedButtonImportantInformation');
    List<Widget> childs = List.empty(growable: true);

    double height = 0;
    if (suspendStock != null) {
      String infoSuspend = 'suspended_time_info'.tr();

      DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
      DateFormat dateParser = DateFormat('yyyy-MM-dd');
      DateTime dateTime = dateParser.parseUtc(suspendStock.date);
      print('dateTime : ' + dateTime.toString());
      //print('indexSummary.date : '+data.date+' '+data.time);
      String formatedDate = dateFormatter.format(dateTime);
      //String formatedTime = timeFormatter.format(dateTime);
      //infoSuspend = infoSuspend.replaceAll('#BOARD#', suspendStock.board);
      infoSuspend = infoSuspend.replaceAll('#DATE#', formatedDate);
      infoSuspend = infoSuspend.replaceAll('#TIME#', suspendStock.time);
      //displayTime = infoTime;
      height += 25.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          'Suspended ' + suspendStock.board,
          style: InvestrendTheme.of(context).small_w600,
        ),
      ));

      height += 50.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: RichText(
          text: TextSpan(
              text: '•  ',
              style: InvestrendTheme.of(context).small_w600,
              children: [
                TextSpan(
                  text: infoSuspend,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
        ),
      ));
    }
    bool titleSpecialNotation = true;
    for (int i = 0; i < count; i++) {
      /*
      Remark2Mapping remark2 = notation.elementAt(i);
      if(remark2 != null){
        if(remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(remark2.value, style: InvestrendTheme.of(context).small_w600,),
          ));

        }else {
          if(titleSpecialNotation){
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('bottom_sheet_alert_title'.tr(), style: InvestrendTheme.of(context).small_w600,),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      }
      */
      Remark2Mapping remark2 = notation.elementAt(i);
      if (remark2 != null) {
        if (remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              remark2.code + ' : ' + remark2.value,
              style: InvestrendTheme.of(context).small_w600,
            ),
          ));
        } else {
          if (titleSpecialNotation) {
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                'bottom_sheet_alert_title'.tr(),
                style: InvestrendTheme.of(context).small_w600,
              ),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(
                  text: /*remark2.code + " : "*/ '•  ',
                  style: InvestrendTheme.of(context).small_w600,
                  children: [
                    TextSpan(
                      text: remark2.code,
                      style: InvestrendTheme.of(context).small_w600,
                    ),
                    TextSpan(
                      text: ' : ' + remark2.value,
                      style: InvestrendTheme.of(context).small_w400,
                    )
                  ]),
            ),
          ));
        }
      }
    }
    if (childs.isNotEmpty) {
      showAlert(context, childs, childsHeight: height, title: ' ');
    }
  }

  void onPressedButtonCorporateAction(
      BuildContext context, List<CorporateActionEvent> corporateAction) {
    print('onPressedButtonCorporateAction : ' + corporateAction.toString());

    List<Widget> childs = List.empty(growable: true);
    if (corporateAction != null && corporateAction.isNotEmpty) {
      corporateAction.forEach((ca) {
        if (ca != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ca.getInformationWidget(context),
          ));
        }
      });

      showAlert(context, childs,
          childsHeight: (childs.length * 50).toDouble(),
          title: 'Corporate Action');
    }
  }

  void showAlert(BuildContext context, List<Widget> childs,
      {String title, double childsHeight = 0}) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return BottomSheetAlert(
            childs,
            title: title,
            childsHeight: childsHeight,
          );
        });
  }

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
}
