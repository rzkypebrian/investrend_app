import 'package:Investrend/component/bottom_sheet/bottom_sheet_alert.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/circle_button.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rows/row_watchlist.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenThemesDetail extends StatefulWidget {
  final StockThemes themes;

  const ScreenThemesDetail(this.themes, {Key key}) : super(key: key);

  @override
  _ScreenThemesDetailState createState() => _ScreenThemesDetailState();
}

class _ScreenThemesDetailState
    extends VisibilityAwareState<ScreenThemesDetail> {
  final String routeName = '/themes_detail';
  final GeneralPriceNotifier _watchlistDataNotifier =
      GeneralPriceNotifier(new GeneralPriceData());
  final SlidableController slidableController = SlidableController();
  bool active = false;
  bool canTapRow = true;

  @override
  void initState() {
    super.initState();
    GeneralPriceData members = GeneralPriceData();
    widget.themes.member_stocks.forEach((stock) {
      //members.datas.add(GeneralPrice(stock.code, 0, 0.0, 0.0, name: stock.name));
      members.datas.add(WatchlistPrice(stock.code, 0, 0.0, 0.0, stock.name));
    });
    _watchlistDataNotifier.setValue(members);
  }

  @override
  void dispose() {
    _watchlistDataNotifier.dispose();

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
    canTapRow = true;
    doUpdate();
  }

  void onInactive() {
    slidableController.activeState = null;
    canTapRow = true;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    if (!active) {
      print(routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  active : $active  pullToRefresh : $pullToRefresh");
      return false;
    }

    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  active : $active  pullToRefresh : $pullToRefresh");
    //Watchlist activeWatchlist = context.read(watchlistChangeNotifier).getWatchlist(_watchlistNotifier.value);

    if (widget.themes != null && widget.themes.member_stocks.isNotEmpty) {
      try {
        print(routeName + ' try Summarys');
        String codes;
        widget.themes.member_stocks.forEach((stock) {
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
    return true;
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
        //_onInactiveBase(caller: 'onVisibilityChanged.GONE');
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

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    double paddingTop = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: widget.themes.background_color,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: createFloatingActionButton(context),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: Theme.of(context).colorScheme.background,
            width: width,
            height: height * 0.7,
          ),
          createBody(context, paddingBottom),
        ],
      ),
    );
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    //return Future.delayed(Duration(seconds: 3));
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> preChilds = List.empty(growable: true);

    preChilds.add(Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          color: widget.themes.background_color,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          //padding: EdgeInsets.all(InvestrendTheme.of(context).tileRoundedRadius),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black54,
              Colors.black26,
              Colors.transparent,
            ],
          )),
          //color: widget.themes.background_color,
        ),
        AspectRatio(
          aspectRatio: 1 / 1,
          child: ComponentCreator.imageNetworkCached(
              widget.themes.background_image_url,
              fit: BoxFit.fitHeight),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.themes.getName(
                    language: EasyLocalization.of(context).locale.languageCode),
                style: Theme.of(context).textTheme.headline4.copyWith(
                    color: InvestrendTheme.of(context).textWhite,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                widget.themes.getDescription(
                    language: EasyLocalization.of(context).locale.languageCode),
                style: InvestrendTheme.of(context)
                    .small_w400
                    .copyWith(color: InvestrendTheme.of(context).textWhite),
              ),
              SizedBox(
                height: 24.0,
              ),
              Row(
                children: [
                  /* di HIDE dulu, ga munculin sosmed untuk Test Launch
                  AvatarListCompetition(
                    size: 25,
                    participants_avatar: owners_avatar,
                    total_participant: owners_avatar.length,
                    showCountingNumber: true,
                  ),

                   */
                  Spacer(
                    flex: 1,
                  ),
                  IconButton(
                      padding: EdgeInsets.all(1.0),
                      visualDensity: VisualDensity.compact,
                      splashColor: InvestrendTheme.of(context).tileSplashColor,
                      onPressed: () {},
                      iconSize: 30.0,
                      icon: Image.asset(
                        'images/icons/share.png',
                        color: InvestrendTheme.of(context).textWhite,
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
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
            return ListView.separated(
                shrinkWrap: false,
                //padding: const EdgeInsets.all(8),
                itemCount: data.count() + preChilds.length,
                separatorBuilder: (BuildContext context, int index) {
                  // if(index == 0){
                  //   return SizedBox(width: 1.0,);
                  // }
                  return Container(
                      padding: EdgeInsets.only(
                          left: InvestrendTheme.cardPaddingGeneral,
                          right: InvestrendTheme.cardPaddingGeneral),
                      color: Theme.of(context).colorScheme.background,
                      child: ComponentCreator.divider(context));
                },
                itemBuilder: (BuildContext context, int index) {
                  if (index < preChilds.length) {
                    return preChilds.elementAt(index);
                  }
                  //GeneralPrice gp = data.datas.elementAt(index - pre_childs.length);

                  GeneralPrice generalPrice =
                      data.datas.elementAt(index - preChilds.length);
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
                          firstRow: true, //(index == 0),
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
        backgroundColor:
            InvestrendTheme.darkenColor(widget.themes.background_color, 0.2),
        splashColor:
            InvestrendTheme.lightenColor(widget.themes.background_color, 0.2),
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

  Widget createBodyNoScroll(BuildContext context) {
    int membersCount = (widget.themes.member_stocks != null
        ? widget.themes.member_stocks.length
        : 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleButton(
            'images/icons/action_back.png',
            backgroundColor: InvestrendTheme.darkenColor(
                widget.themes.background_color, 0.2),
            // Button color
            splashColor: InvestrendTheme.lightenColor(
                widget.themes.background_color, 0.2),
            imageColor: Theme.of(context).primaryColor,
            buttonSize: 40.0,
            imageSize: 20.0,
            imagePadding: const EdgeInsets.only(
                left: 4.0, right: 8.0, bottom: 4.0, top: 4.0),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              //padding: EdgeInsets.all(InvestrendTheme.of(context).tileRoundedRadius),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black54,
                  Colors.black26,
                  Colors.transparent,
                ],
              )),
            ),
            AspectRatio(
              aspectRatio: 1 / 1,
              child: ComponentCreator.imageNetworkCached(
                  widget.themes.background_image_url,
                  fit: BoxFit.fitHeight),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.themes.getName(
                        language:
                            EasyLocalization.of(context).locale.languageCode),
                    style: Theme.of(context).textTheme.headline4.copyWith(
                        color: InvestrendTheme.of(context).textWhite,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    widget.themes.getDescription(
                        language:
                            EasyLocalization.of(context).locale.languageCode),
                    style: InvestrendTheme.of(context)
                        .small_w400
                        .copyWith(color: InvestrendTheme.of(context).textWhite),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Row(
                    children: [
                      /* di HIDE dulu, ga munculin sosmed untuk Test Launch
                      AvatarListCompetition(
                        size: 25,
                        participants_avatar: owners_avatar,
                        total_participant: owners_avatar.length,
                        showCountingNumber: true,
                      ),
                      */
                      Spacer(
                        flex: 1,
                      ),
                      IconButton(
                          padding: EdgeInsets.all(1.0),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {},
                          iconSize: 30.0,
                          icon: Image.asset(
                            'images/icons/share.png',
                            color: InvestrendTheme.of(context).textWhite,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: ListView.separated(
              shrinkWrap: false,
              padding: const EdgeInsets.all(8),
              itemCount: membersCount,
              separatorBuilder: (BuildContext context, int index) {
                //return ComponentCreator.divider(context);
                return Divider(
                  color: Colors.red,
                  thickness: 2.0,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                Stock stock = widget.themes.member_stocks.elementAt(index);
                StockSummary summary;

                int price = 0;
                double change = 0.0;
                double percentChange = 0.0;
                if (summary != null) {
                  price = summary.close;
                  change = summary.change;
                  percentChange = summary.percentChange;
                }
                Color priceColor = InvestrendTheme.changeTextColor(change);
                return ListTile(
                  contentPadding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  //leading: Image.network(cp.icon_url, width: 40.0, height: 40.0,),
                  //leading: ComponentCreator.imageNetworkCached(cp.icon_url, width: 35.0, height: 35.0,),
                  title: Row(
                    children: [
                      Text(
                        stock.code,
                        style: InvestrendTheme.of(context).regular_w600_compact,
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        InvestrendTheme.formatPrice(price),
                        style: InvestrendTheme.of(context)
                            .regular_w600_compact
                            .copyWith(color: priceColor),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        stock.name,
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .greyLighterTextColor),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        InvestrendTheme.formatChange(change) +
                            ' (' +
                            InvestrendTheme.formatPercentChange(percentChange) +
                            ')',
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            .copyWith(color: priceColor),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
