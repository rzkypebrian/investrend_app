import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:share_plus/share_plus.dart';

class ScreenStockDetailNews extends StatefulWidget {
  final TabController? tabController;
  final int tabIndex;
  final ValueNotifier<bool>? visibilityNotifier;
  ScreenStockDetailNews(this.tabIndex, this.tabController,
      {Key? key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenStockDetailNewsState createState() =>
      _ScreenStockDetailNewsState(tabIndex, tabController!,
          visibilityNotifier: visibilityNotifier!);
}

class _ScreenStockDetailNewsState
    extends BaseStateNoTabsWithParentTab<ScreenStockDetailNews> {
  //Future<List<HomeNews>> news;
  HomeNewsNotifier? _notifier = HomeNewsNotifier(ResultHomeNews());

  _ScreenStockDetailNewsState(int tabIndex, TabController tabController,
      {ValueNotifier<bool>? visibilityNotifier})
      : super('/stock_detail_news', tabIndex, tabController,
            notifyStockChange: true, visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;

  void onStockChanged(Stock? newStock) {
    super.onStockChanged(newStock);
    doUpdate(pullToRefresh: true);
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString());
    if (!active) {
      print(routeName + '.doUpdate aborted active : $active');
      return;
    }
    if (_notifier!.value!.isEmpty()! || pullToRefresh) {
      setNotifierLoading(_notifier);
    }
    try {
      String? code = context.read(primaryStockChangeNotifier).stock?.code;
      final List<HomeNews>? news = await HttpIII.fetchNewsPasarDana(code);
      if (news != null) {
        ResultHomeNews data = ResultHomeNews();
        data.datas?.addAll(news);
        _notifier?.setValue(data);
      } else {
        setNotifierNoData(_notifier);
      }
    } catch (error) {
      setNotifierError(_notifier, error);
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    if (!active) {
      active = true;
      //onActive();
      context
          .read(stockDetailScreenVisibilityChangeNotifier)
          .setActive(tabIndex, true);
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    // List<Widget> childs = [
    //
    // ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ValueListenableBuilder(
          valueListenable: _notifier!,
          builder: (context, ResultHomeNews? value, child) {
            List<Widget> list = List.empty(growable: true);
            Widget? noWidget = _notifier?.currentState
                .getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
            if (noWidget != null) {
              list.add(Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
                child: Center(
                  child: noWidget,
                ),
              ));
            } else {
              int? maxCount = value?.count();
              for (int i = 0; i < maxCount!; i++) {
                //list.add(tileNews(context, snapshot.data[i]));
                if (i > 0) {
                  list.add(SizedBox(
                    height: InvestrendTheme.cardMargin,
                  ));
                }
                list.add(ComponentCreator.tileNews(
                  context,
                  value?.datas?[i],
                  commentClick: () {
                    InvestrendTheme.of(context)
                        .showSnackBar(context, 'commentClick');
                  },
                  likeClick: () {
                    InvestrendTheme.of(context)
                        .showSnackBar(context, 'likeClick');
                  },
                  shareClick: () {
                    //InvestrendTheme.of(context).showSnackBar(context, 'shareClick');
                    String shareTextAndLink = value!.datas![i].title +
                        '\n' +
                        value.datas![i].url_news;
                    Share.share(shareTextAndLink);
                  },
                ));
              }
              list.add(SizedBox(
                height: paddingBottom + 80,
              ));
            }
            return ListView.builder(
                controller: pScrollController,
                shrinkWrap: false,
                padding: EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral,
                    top: InvestrendTheme.cardPaddingVertical,
                    bottom: InvestrendTheme.cardPaddingVertical),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  return list.elementAt(index);
                });
          }),
      /*
      child: FutureBuilder<List<HomeNews>>(
        future: news,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //return Text(snapshot.data.length.toString(), style: Theme.of(context).textTheme.bodyText2,);
            if (snapshot.data.length > 0) {
              List<Widget> list = List.empty(growable: true);
              //int maxCount = snapshot.data.length > 3 ? 3 : snapshot.data.length;
              int maxCount =  snapshot.data.length;
              for (int i = 0; i < maxCount; i++) {
                //list.add(tileNews(context, snapshot.data[i]));
                list.add(ComponentCreator.tileNews(
                  context,
                  snapshot.data[i],
                  commentClick: () {
                    InvestrendTheme.of(context).showSnackBar(context, 'commentClick');
                  },
                  likeClick: () {
                    InvestrendTheme.of(context).showSnackBar(context, 'likeClick');
                  },
                  shareClick: () {
                    InvestrendTheme.of(context).showSnackBar(context, 'shareClick');
                  },
                ));
              }
              list.add(SizedBox(height: paddingBottom + 80,));

              return ListView.builder(
                  shrinkWrap: false,
                  padding: const EdgeInsets.all(8),
                  itemCount: list.length  ,
                  itemBuilder: (BuildContext context, int index) {
                    return list.elementAt(index);

                  });

              //return gridWorldIndices(context, snapshot.data);
            } else {
              return Center(
                  child: Text(
                    'No Data',
                    style: Theme.of(context).textTheme.bodyText2,
                  ));
            }
          } else if (snapshot.hasError) {
            return Center(
                child: Column(
                  children: [
                    Text("${snapshot.error}",
                        maxLines: 10, style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)),
                    OutlinedButton(
                        onPressed: () async{
                          setState(() {
                            doUpdate(pullToRefresh: true);
                          });

                        },
                        child: Text('button_retry'.tr())),
                  ],
                ));
            // return Center(
            //     child:
            //         Text("${snapshot.error}", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)));
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
      */
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: FutureBuilder<List<HomeNews>>(
        future: news,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //return Text(snapshot.data.length.toString(), style: Theme.of(context).textTheme.bodyText2,);
            if (snapshot.data.length > 0) {
              List<Widget> list = List.empty(growable: true);
              //int maxCount = snapshot.data.length > 3 ? 3 : snapshot.data.length;
              int maxCount =  snapshot.data.length;
              for (int i = 0; i < maxCount; i++) {
                //list.add(tileNews(context, snapshot.data[i]));
                list.add(ComponentCreator.tileNews(
                  context,
                  snapshot.data[i],
                  commentClick: () {
                    InvestrendTheme.of(context).showSnackBar(context, 'commentClick');
                  },
                  likeClick: () {
                    InvestrendTheme.of(context).showSnackBar(context, 'likeClick');
                  },
                  shareClick: () {
                    InvestrendTheme.of(context).showSnackBar(context, 'shareClick');
                  },
                ));
              }
              list.add(SizedBox(height: paddingBottom + 80,));
              return Padding(
                padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
                child: Column(
                  children: list,
                ),
              );
              //return gridWorldIndices(context, snapshot.data);
            } else {
              return Center(
                  child: Text(
                    'No Data',
                    style: Theme.of(context).textTheme.bodyText2,
                  ));
            }
          } else if (snapshot.hasError) {
            return Center(
                child: Column(
                  children: [
                    Text("${snapshot.error}",
                        maxLines: 10, style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)),
                    OutlinedButton(
                        onPressed: () async{
                          news = HttpSSI.fetchNews();
                        },
                        child: Text('button_retry'.tr())),
                  ],
                ));
            // return Center(
            //     child:
            //         Text("${snapshot.error}", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)));
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName+' onActive');
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, true);
    doUpdate();
  }

  @override
  void initState() {
    super.initState();

    //news = HttpSSI.fetchNews();
    /*
    Future.delayed(Duration(milliseconds: 500),(){

      LabelValueData dataHistory = new LabelValueData();
      dataHistory.datas.add(LabelValue('card_history_listing_date_label'.tr(), '28 Oct 2007'));
      dataHistory.datas.add(LabelValue('card_history_effective_date_label'.tr(), '11 Oct 2007'));
      dataHistory.datas.add(LabelValue('card_history_nominal_label'.tr(), '100'));
      dataHistory.datas.add(LabelValue('card_history_ipo_price_label'.tr(), '420'));
      dataHistory.datas.add(LabelValue('card_history_ipo_shares_label'.tr(), '1,85 B'));
      dataHistory.datas.add(LabelValue('card_history_ipo_amount_label'.tr(), '775,43 B'));
      dataHistory.datas.add(LabelValueDivider());
      dataHistory.datas.add(LabelValue('card_history_underwriter_label'.tr(), 'PT Bahana Securities'));
      dataHistory.datas.add(LabelValue(' ', 'PT CIMB-GK Securities Indonesia'));
      dataHistory.datas.add(LabelValue(' ', 'PT Indo Premier Securities'));
      dataHistory.datas.add(LabelValueDivider());
      dataHistory.datas.add(LabelValue('card_history_share_registrar_label'.tr(), 'PT Datindo Entrycom'));


      _historyNotifier.setValue(dataHistory);

      LabelValueData dataShareholders = new LabelValueData();
      dataShareholders.additionalInfo = '(Effective 31 Dec 2020)';
      dataShareholders.datas.add(LabelValuePercent('Negara Republik Indonesia (P)', '5.834.850.000','65,049%'));
      dataShareholders.datas.add(LabelValuePercent('Public', '3.134.001.372','34,939%'));
      dataShareholders.datas.add(LabelValuePercent('Saham Treasury', '1.100.000','0,012%'));
      dataShareholders.datas.add(LabelValueDivider());
      dataShareholders.datas.add(LabelValuePercent('Total', '8.969.951.372','100%'));
      dataShareholders.datas.add(LabelValuePercent('Shareholders Total', '46.105','(+9.423)',valuePercentColor: InvestrendTheme.greenText));
      dataShareholders.datas.add(LabelValueDivider());
      dataShareholders.datas.add(LabelValueSubtitle('Shareholders by BoC and BoD'));
      dataShareholders.datas.add(LabelValuePercent('Ade Wahyu', '457.435','0,0051%'));
      dataShareholders.datas.add(LabelValuePercent('Agung Budi Waskito', '34.200','0,0004%'));

      _shareHolderCompositionNotifier.setValue(dataShareholders);

      LabelValueData dataCommisioners = new LabelValueData();
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_commissioner_label'.tr(), 'Jarot Widyoko'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_commissioner_label'.tr(), 'Phil Foden'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_commissioner_label'.tr(), 'Edy Sudarmanto'));
      dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
      dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
      dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
      dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));
      dataCommisioners.datas.add(LabelValueDivider());
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_director_label'.tr(), 'Agung Budi Waskito'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_director_label'.tr(), 'Agung Budi Waskito'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_director_label'.tr(), 'Edy Sudarmanto'));
      dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
      dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
      dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
      dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));
      _boardOfCommisionersNotifier.setValue(dataCommisioners);





    });
     */
  }

  @override
  void dispose() {
    _notifier?.dispose();
    // _shareHolderCompositionNotifier.dispose();
    // _boardOfCommisionersNotifier.dispose();
    final container = ProviderContainer();
    container
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);

    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName+' onInactive');
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);
  }
}
