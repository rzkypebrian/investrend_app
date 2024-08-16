// ignore_for_file: unused_local_variable

import 'package:Investrend/component/cards/card_social_media.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/sosmed_object.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_community/screen_detail_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenProfilePost extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  ScreenProfilePost(this.tabIndex, this.tabController, {Key? key})
      : super(key: key);

  @override
  _ScreenProfilePostState createState() =>
      _ScreenProfilePostState(tabIndex, tabController);
}

class _ScreenProfilePostState
    extends BaseStateNoTabsWithParentTab<ScreenProfilePost> {
  _ScreenProfilePostState(int tabIndex, TabController tabController)
      : super('/profile_post', tabIndex, tabController,
            parentTabIndex: Tabs.Portfolio.index);
  ScrollController? _scrollController;

  void _scrollToTop() {
    _scrollController?.animateTo(0,
        duration: Duration(seconds: 2), curve: Curves.easeInOutQuint);
  }

  void scrollListener() {
    if (_scrollController!.offset >=
            _scrollController!.position.maxScrollExtent &&
        !_scrollController!.position.outOfRange) {
      //"reach the bottom";

      if (mounted) {
        fetchNextPage();
      }
    }
    if (_scrollController!.offset <=
            _scrollController!.position.minScrollExtent &&
        !_scrollController!.position.outOfRange) {
      //"reach the top";
    }
  }

  bool showedLastPageInfo = false;
  void fetchNextPage() {
    if (context.read(sosmedFeedChangeNotifier).loadingBottom) {
      print('scrollListener nextPage onProgress : ' +
          context.read(sosmedFeedChangeNotifier).loadingBottom.toString());
      return;
    }
    print('reach the bottom');

    String nextPageUrl = context.read(sosmedFeedChangeNotifier).next_page_url;
    int currentPage = context.read(sosmedFeedChangeNotifier).current_page;
    int lastPage = context.read(sosmedFeedChangeNotifier).last_page;
    if (currentPage == lastPage) {
      if (showedLastPageInfo) {
        return;
      }
      showedLastPageInfo = true;
      InvestrendTheme.of(context).showSnackBar(
          context, 'sosmed_label_all_post_viewed'.tr(),
          buttonOnPress: _scrollToTop,
          buttonLabel: 'button_latest_feed'.tr(),
          buttonColor: Colors.orange,
          seconds: 5);
      Future.delayed(Duration(seconds: 1), () {
        context.read(sosmedFeedChangeNotifier).showLoadingBottom(false);
      });
      return;
    }
    context.read(sosmedFeedChangeNotifier).showLoadingBottom(true);
    int nextPage = currentPage + 1;
    final result = doUpdate(nextPage: nextPage);
  }

  bool showLoadingFirstTime = true;

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false, int? nextPage}) async {
    print(routeName + '.doUpdate');
    showedLastPageInfo = false;
    try {
      context.read(sosmedFeedChangeNotifier).showLoadingBottom(true);
      //final fetchPost = await SosMedHttp.sosmedFetchPost('123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, page: nextPage, language: EasyLocalization.of(context).locale.languageCode);
      final fetchPost = await InvestrendTheme.tradingHttp.sosmedFetchPost(
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion,
          page: nextPage,
          language: EasyLocalization.of(context)!.locale.languageCode,
          mine: true);
      if (fetchPost.result != null) {
        print('fetchPost = ' +
            fetchPost.status.toString() +
            ' --> ' +
            fetchPost.message);
        //_pageSize = fetchPost.result.per_page;
        showLoadingFirstTime = false;
        context.read(sosmedFeedChangeNotifier).setResult(fetchPost.result);
        // Future.delayed(Duration(seconds: 2),(){
        context.read(sosmedFeedChangeNotifier).showLoadingBottom(false);
        // });
      }
    } catch (error) {
      print(routeName + '.doUpdate Exception fetch_post : ' + error.toString());
      //context.read(sosmedPostChangeNotifier).showLoadingBottom(false);
      showLoadingFirstTime = false;
      if (mounted) {
        //InvestrendTheme.of(context).showSnackBar(context, 'Error : '+error.toString());
        // Future.delayed(Duration(seconds: 2),(){
        //context.read(sosmedPostChangeNotifier).showLoadingBottom(false);
        context.read(sosmedFeedChangeNotifier).showRetryBottom(true);
        handleNetworkError(context, error);
        /*
        if(error is TradingHttpException){
          if(error.isUnauthorized()){
            InvestrendTheme.of(super.context).showDialogInvalidSession(super.context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }

         */
        // });
      }

      // _pagingController.error = error;
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');

    return true;
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  void commentClicked(BuildContext context, Post post) {
    showDetailPost(context, post, showKeyboard: true);
  }

  void likeClicked(BuildContext context, Post post) {
    if (mounted) {
      context.read(sosmedFeedChangeNotifier).mustNotifyListener();
    }
  }

  void showDetailPost(BuildContext context, Post post,
      {bool showKeyboard = false}) {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ScreenDetailPost(
            post,
            showKeyboard: showKeyboard,
          ),
          settings: RouteSettings(name: '/detail_post'),
        ));
    /*
    .then((value) {
      if(value is String){
        if(StringUtils.equalsIgnoreCase(value, 'REFRESH')){
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _scrollToTop();
            doUpdate();
          });
        }
      }
    });
     */
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: Consumer(builder: (context, watch, child) {
        final notifier = watch(sosmedFeedChangeNotifier);
        if (notifier.countData() == 0) {
          /*
          return ListView(
            padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
            //children: pre_childs,
            children: showLoadingFirstTime ? pre_childs_loading : pre_childs,
          );
          */
          if (showLoadingFirstTime) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ));
          } else {
            return Center(
                child: EmptyLabel(
              text: 'infinity_label️'.tr(),
            ));
          }
        }

        int? totalCount = notifier.countData(); //+ pre_childs.length;
        if (notifier.loadingBottom || notifier.retryBottom) {
          totalCount = totalCount! + 1;
        }
        return ListView.builder(
            controller: _scrollController,
            shrinkWrap: false,
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardMargin,
                right: InvestrendTheme.cardMargin,
                top: InvestrendTheme.cardMargin,
                bottom: (InvestrendTheme.cardMargin + 100.0)),
            //itemCount: notifier.countPost() + pre_childs.length ,
            itemCount: totalCount,
            itemBuilder: (BuildContext context, int index) {
              /*if(index < pre_childs.length){
                return pre_childs.elementAt(index);
              }else  if(index < (pre_childs.length + notifier.countData())){*/
              if (index < notifier.countData()!) {
                //int indexPost = index - pre_childs.length;
                int indexPost = index; // - pre_childs.length;
                Post? post = notifier.datas()?.elementAt(indexPost);

                if (post != null) {
                  switch (post.postType) {
                    case PostType.POLL:
                      {
                        //return CardSocialTextVote(votes, avatarUrl, name, username, label, datetime, text, commentCount, likedCount, comments);
                        return NewCardSocialTextPoll(
                          post,
                          shareClick: () {},
                          commentClick: () => commentClicked(context, post),
                          likeClick: () => likeClicked(context, post),
                          onTap: () => showDetailPost(context, post),
                          key: Key(post.keyString!),
                        );
                      }
                    case PostType.PREDICTION:
                      {
                        //return CardSocialTextPrediction(prediction, avatarUrl, name, username, label, datetime, text, commentCount, likedCount, comments);
                        return NewCardSocialTextPrediction(post,
                            shareClick: () {},
                            commentClick: () => commentClicked(context, post),
                            likeClick: () => likeClicked(context, post),
                            onTap: () => showDetailPost(context, post),
                            key: Key(post.keyString!));
                      }
                    case PostType.TRANSACTION:
                      {
                        //return CardSocialTextActivity(activityType, activityCode, avatarUrl, name, username, label, datetime, text, commentCount, likedCount, comments);
                        return NewCardSocialTextActivity(post,
                            shareClick: () {},
                            commentClick: () => commentClicked(context, post),
                            likeClick: () => likeClicked(context, post),
                            onTap: () => showDetailPost(context, post),
                            key: Key(post.keyString!));
                      }
                    case PostType.TEXT:
                      {
                        if (post.attachmentsCount()! > 0) {
                          return NewCardSocialTextImages(post,
                              shareClick: () {},
                              commentClick: () => commentClicked(context, post),
                              likeClick: () => likeClicked(context, post),
                              onTap: () => showDetailPost(context, post),
                              key: Key(post.keyString!));
                        } else {
                          return NewCardSocialText(post,
                              shareClick: () {},
                              commentClick: () => commentClicked(context, post),
                              likeClick: () => likeClicked(context, post),
                              onTap: () => showDetailPost(context, post),
                              key: Key(post.keyString!));
                        }
                      }
                    case PostType.Unknown:
                      {
                        return Text(
                            '[$indexPost] --> ' + post.type! + ' is Unknown');
                      }
                    default:
                      {
                        return Text('[$indexPost] --> ' +
                            post.type! +
                            ' is Unknown[default]');
                      }
                  }
                  //return Text('[$indexPost] --> '+post.type);
                } else {
                  return EmptyLabel(
                    text: 'post index $index is null',
                  );
                }
              } else {
                if (notifier.loadingBottom) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                  ));
                } else if (notifier.retryBottom) {
                  return Center(
                      child: TextButton(
                    child: Text(
                      'button_retry'.tr(),
                      style: InvestrendTheme.of(context)
                          .small_w400_compact
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary),
                    ),
                    onPressed: () {
                      fetchNextPage();
                    },
                  ));
                } else {
                  return Center(
                      child: EmptyLabel(
                    text: 'infinity_label️'.tr(),
                  ));
                }
              }
            });
      }),
    );
    /*
    Votes votes = Votes('12 jam 22 menit lagi', 990);
    votes.addVote(Vote('BBCA', 31));
    votes.addVote(Vote('ASII', 21));
    votes.addVote(Vote('ANTM', 11));

    Prediction prediction = Prediction('ASII', 'Astra Internasional TBK', 238, 1760, 8.5, '30 hari', 31, 12, 43, '12 hours 22 minutes left');

    List<CommentOld> comments = [
      CommentOld('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU', 'Mikasa', '@mikasa', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
      CommentOld('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU', 'Andrea', '@andrea', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
      CommentOld('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU', 'Noone', '@noone', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
      CommentOld('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU', 'Noone', '@noone', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
      CommentOld('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU', 'Noone', '@noone', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    ];

    return ListView(
      children: [
        CardSocialTextPrediction(prediction, 'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100, comments,commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),

        CardSocialTextImage('https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg', 'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,comments,commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),
        CardSocialTextImages([
          'https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg',
          'https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg',
        ], 'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,comments,commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),

        CardSocialTextImages([
          'https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg',
          'https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg',
          'https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg',
          'https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg',
        ], 'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100, null,commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),

        CardSocialTextVote(votes, 'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,comments, commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),
        CardSocialTextActivity(ActivityType.Invested, 'BBCA','https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100, comments, commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),
        CardSocialTextActivity(ActivityType.Gain, 'BBCA','https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,null,commentClick: (){}, likeClick: (){}, shareClick: (){},activityPercent: '5%', onTap: (){},),
        CardSocialTextActivity(ActivityType.Loss, 'BBCA','https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,comments,commentClick: (){}, likeClick: (){}, shareClick: (){},activityPercent: '10%', onTap: (){},),

        CardSocialText('https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,comments, commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),
        CardSocialText('https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,null, commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),
      ],
    );
    */
  }

  @override
  void onActive() {
    //print(routeName + ' onActive');
    // canTapRow = true;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController?.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdate();
    });

    // Future.delayed(Duration(milliseconds: 500), () {
    //   PortfolioData dataUs = PortfolioData();
    //   dataUs.datas.add(Portfolio('ASII', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('BBCA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('BSDE', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('ANTM', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('BOLA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('BFIN', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('EMTK', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('GGRM', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('ASRI', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('BNBR', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('ELTY', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('ENRG', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('DOID', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   dataUs.datas.add(Portfolio('AISA', 90000000, 14000000, 14.58, 1000, 6000, 5150, 200, 14.58));
    //   _portfolioNotifier.setValue(dataUs);
    //
    //
    //
    // });
  }

  @override
  void dispose() {
    // _portfolioNotifier.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
    // slidableController.activeState = null;
    // canTapRow = true;
  }
}
