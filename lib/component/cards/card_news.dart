import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
class CardNews extends StatefulWidget {
  final String title;
  final bool showAllNews;
  const CardNews(this.title,{this.showAllNews = true, Key key}) : super(key: key);

  @override
  _CardNewsState createState() => _CardNewsState();
}

class _CardNewsState extends State<CardNews> {
  // ValueNotifier <bool> _newsNotifier = ValueNotifier<bool>(false);
  //Future<List<HomeNews>> news;

  Key keyNews = UniqueKey();
  HomeNewsNotifier _notifier = HomeNewsNotifier(ResultHomeNews());

  @override
  void initState() {
    super.initState();
    //news = HttpSSI.fetchNews();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdate();
    });
  }
  Future doUpdate({bool pullToRefresh = false}) async {
    if(_notifier.value.isEmpty() || pullToRefresh){
      setNotifierLoading(_notifier);
    }
    try{
      String code = '';
      int lenght = 20;
      if(!widget.showAllNews){
        code = this.context.read(primaryStockChangeNotifier).stock.code;
        lenght = 3;
      }
      final news = await HttpIII.fetchNewsPasarDana(code, lenght: lenght);
      if(news != null){
        ResultHomeNews data = ResultHomeNews();
        data.datas.addAll(news);
        _notifier.setValue(data);
      }else{
        setNotifierNoData(_notifier);
      }
    }catch(error){
      setNotifierError(_notifier, error);
    }

    print(widget.title + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }
  void setNotifierError(BaseValueNotifier notifier, var error){
    if(mounted && notifier != null){
      notifier.setError(message: error.toString());
    }
  }
  void setNotifierNoData(BaseValueNotifier notifier){
    if(mounted && notifier != null){
      notifier.setNoData();
    }
  }
  void setNotifierLoading(BaseValueNotifier notifier){
    if(mounted && notifier != null){
      notifier.setLoading();
    }
  }
  VoidCallback _stockChangeListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if(_stockChangeListener != null){
      context.read(primaryStockChangeNotifier).removeListener(_stockChangeListener);
    }else{
      _stockChangeListener = (){
        if(mounted){
          doUpdate(pullToRefresh: true);
        }
      };
    }
    context.read(primaryStockChangeNotifier).addListener(_stockChangeListener);
  }

  @override
  void dispose() {
    // _newsNotifier.dispose();

    final container = ProviderContainer();
    if(_stockChangeListener != null){
      container.read(primaryStockChangeNotifier).removeListener(_stockChangeListener);
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      key: keyNews,
      margin: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, /*top: InvestrendTheme.cardPaddingGeneral,*/ bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentCreator.subtitleNoButtonMore(context, widget.title),
          /*
          ComponentCreator.subtitleButtonMore(
            context,
            widget.title,
                () {
              InvestrendTheme.of(context).showSnackBar(context, "Action News More");
            },
          ),

           */
          Padding(
            padding: const EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
            child: ValueListenableBuilder(
                valueListenable: _notifier,
                builder: (context, ResultHomeNews value, child) {
                  List<Widget> list = List.empty(growable: true);
                  Widget noWidget = _notifier.currentState.getNoWidget(onRetry: ()=>doUpdate(pullToRefresh: true));
                  if(noWidget != null){
                    double paddingEmpty = MediaQuery.of(context).size.width / 4;
                    list.add(Padding(
                      padding:  EdgeInsets.only(top: paddingEmpty, bottom: paddingEmpty),
                      child: Center(child: noWidget,),
                    ));
                  }else{
                    int maxCount =  value.count();
                    for (int i = 0; i < maxCount; i++) {
                      //list.add(tileNews(context, snapshot.data[i]));
                      if(list.isNotEmpty){
                        list.add(SizedBox(height: InvestrendTheme.cardMargin,));
                      }
                      list.add(ComponentCreator.tileNews(
                        context,
                        value.datas[i],
                        commentClick: () {
                          //InvestrendTheme.of(context).showSnackBar(context, 'commentClick');
                        },
                        likeClick: () {
                          //InvestrendTheme.of(context).showSnackBar(context, 'likeClick');
                        },
                        shareClick: () {
                          //InvestrendTheme.of(context).showSnackBar(context, 'shareClick');
                          String shareTextAndLink = value.datas[i].title+'\n'+value.datas[i].url_news;
                          Share.share(shareTextAndLink);
                          //Share.share('check out my website https://example.com');
                        },
                      ));
                    }
                    //list.add(SizedBox(height: paddingBottom + 80,));
                  }
                  return Column(
                    children: list,
                  );
                }),
          ),
          /*
          Padding(
            padding: const EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
            child: FutureBuilder<List<HomeNews>>(
              future: news,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //return Text(snapshot.data.length.toString(), style: Theme.of(context).textTheme.bodyText2,);
                  if (snapshot.data.length > 0) {
                    List<Widget> list = List.empty(growable: true);
                    int maxCount = snapshot.data.length > 3 ? 3 : snapshot.data.length;
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

                    return Column(
                      children: list,
                    );
                    //return gridWorldIndices(context, snapshot.data);
                  } else {
                    return Center(child: EmptyLabel(),);
                    // return Center(
                    //     child: Text(
                    //       'No Data',
                    //       style: Theme.of(context).textTheme.bodyText2,
                    //     ));
                  }
                } else if (snapshot.hasError) {
                  return Center(
                      child: Column(
                        children: [
                          Text("${snapshot.error}",
                              maxLines: 10, style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: Theme.of(context).errorColor)),
                          TextButtonRetry(onPressed: (){
                            setState(() {
                              news = HttpSSI.fetchNews();
                            });
                          },),
                          // OutlinedButton(
                          //     onPressed: () {
                          //       news = HttpSSI.fetchNews();
                          //     },
                          //     child: Text('button_retry'.tr())),
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
          ),
          */
        ],
      ),
    );
  }
}

