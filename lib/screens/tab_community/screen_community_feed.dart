// ignore_for_file: unused_local_variable

import 'package:Investrend/component/cards/card_profiles.dart';
import 'package:Investrend/component/cards/card_social_media.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/sosmed_object.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/tab_community/screen_create_post.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_community/screen_detail_post.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenCommunityFeed extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  ScreenCommunityFeed(this.tabIndex, this.tabController, {Key? key})
      : super(key: key);

  @override
  _ScreenCommunityFeedState createState() =>
      _ScreenCommunityFeedState(tabIndex, tabController);
}

class _ScreenCommunityFeedState
    extends BaseStateNoTabsWithParentTab<ScreenCommunityFeed> {
  _ScreenCommunityFeedState(int tabIndex, TabController tabController)
      : super('/community_feed', tabIndex, tabController,
            parentTabIndex: Tabs.Community.index);
  ScrollController? _scrollController;

  void _scrollToTop() {
    _scrollController?.animateTo(0,
        duration: Duration(seconds: 2), curve: Curves.easeInOutQuint);
  }

  void scrollListener() {
    if (_scrollController!.offset >=
            _scrollController!.position.maxScrollExtent &&
        !_scrollController!.position.outOfRange) {
      // setState(() {
      //   message = "reach the bottom";
      // });
      if (mounted) {
        fetchNextPage();
      }
    }
    if (_scrollController!.offset <=
            _scrollController!.position.minScrollExtent &&
        !_scrollController!.position.outOfRange) {
      // setState(() {
      //   message = "reach the top";
      // });
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
  void initState() {
    super.initState();
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
    _scrollController = ScrollController();
    _scrollController?.addListener(scrollListener);

    //doUpdate();
    runPostFrame(doUpdate);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate();
    // });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    // _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget createFloatingActionButton(context) {
    return FloatingActionButton(
      onPressed: () {
        // Add your onPressed code here!
        //InvestrendTheme.of(context).showSnackBar(context, 'Show Posting page action');
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenCreatePost(routeName),
              settings: RouteSettings(name: '/create_post'),
            )).then((value) {
          if (value is String) {
            if (StringUtils.equalsIgnoreCase(value, 'REFRESH')) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                _scrollToTop();
                doUpdate();
              });
            }
          }
        });
      },
      //child: const Icon(Icons.edit, color: Colors.white,),
      child: Image.asset('images/icons/pencil.png'),
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  List<HomeProfiles> listProfiles = <HomeProfiles>[
    HomeProfiles(
        'Belvin Tannadi',
        'Owner @belvinvvip, komunitas saham retail terbesar di indonesia',
        'https://www.investrend.co.id/mobile/assets/profiles/profile_1.png'),
    HomeProfiles(
        'Lo Kheng Hong',
        'Lo Kheng Hong sebagai investor saham disebut sebut sebagai Warren Buffet-nya Indonesia.',
        'https://www.investrend.co.id/mobile/assets/profiles/profile_2.png'),
  ];
  /*
  Future<void> _fetchPage(int pageKey) async {
    print(routeName + '._fetchPage');
    String next_page_url = context.read(sosmedPostChangeNotifier).next_page_url;
    int current_page = context.read(sosmedPostChangeNotifier).current_page;
    int last_page = context.read(sosmedPostChangeNotifier).last_page;
    // if(StringUtils.isEmtpy(next_page_url)){
    //   _pagingController.error = Exception('Next Page is Empty');
    //   return;
    // }
    // if(current_page == last_page){
    //   _pagingController.error = Exception('current_page($current_page) is last_page($last_page)');
    //   return;
    // }
    // int next_page = current_page + 1;
    // try{
    //   final fetchPost = await SosMedHttp.fetch_post('123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, page: next_page);
    //   if(fetchPost.result != null ){
    //     print('fetchPost = '+fetchPost.status.toString() +' --> '+fetchPost.message);
    //     _pageSize = fetchPost.result.per_page;
    //     context.read(sosmedPostChangeNotifier).setResult(fetchPost.result);
    //     bool isLastPage = fetchPost.result.current_page == fetchPost.result.last_page;
    //     if (isLastPage) {
    //       _pagingController.appendLastPage(fetchPost.result.posts.cast());
    //     } else {
    //       //final nextPageKey = pageKey + newItems.length;
    //       final nextPageKey = fetchPost.result.current_page + 1;
    //       _pagingController.appendPage(fetchPost.result.posts.cast(), nextPageKey);
    //     }
    //   }
    // }catch(error){
    //   print(routeName + '._fetchPage Exception fetch_post : '+error.toString());
    //   _pagingController.error = error;
    // }
    /*
    try {
      final newItems = await RemoteApi.getCharacterList(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
     */
  }
  */
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
          language: EasyLocalization.of(context)!.locale.languageCode);
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
        // });
        handleNetworkError(context, error);
        return;
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
      }

      // _pagingController.error = error;
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');

    return true;
  }

  Future onRefresh() {
    if (!active) {
      active = true;
    }
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

  /*
  void likeClicked(BuildContext context, Post post) async{
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {

          String action = post.liked ? 'sosmed_label_undo_like'.tr() : 'sosmed_label_like'.tr();
          return LoadingBottomSheetSimple(action + 'sosmed_label_for'.tr() + post?.text.substring(0, min(post.text.length, 50)),);
        });
    try{
      SubmitLike submitResult = await SosMedHttp.like(!post.liked ,'123',post.id, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, language: EasyLocalization.of(context).locale.languageCode);
      if(submitResult != null ){
        print('submitResult = '+submitResult.toString());
        bool success = submitResult.status == 200;// && submitResult?.result?.id >= 0;
        if(mounted) {
          InvestrendTheme.of(context).showSnackBar(context, submitResult.message);
        }
        if(success){
          if(StringUtils.equalsIgnoreCase(submitResult.message, 'Like deleted!')){
            post.likedUndoed();
          }else if(StringUtils.equalsIgnoreCase(submitResult.message, 'Like created!')){
            post.likedSuccess();
          }
          if(mounted){
            context.read(sosmedFeedChangeNotifier).mustNotifyListener();
          }
        }
      }
    }catch(error){
      print(routeName + '.likeClicked Exception like : '+error.toString());
      print(error);
    }finally {
      // Future.delayed(Duration(seconds: 2),(){
      Navigator.of(context).pop();
      //
    }
  }
  */
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
        )).then((value) {
      if (value is String) {
        if (StringUtils.equalsIgnoreCase(value, 'REFRESH')) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _scrollToTop();
            doUpdate();
          });
        }
      }
    });
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> preChilds = [
      CardProfiles('card_featured_profile_title'.tr(), listProfiles),
      SizedBox(
        height: 20.0,
      ),
      ComponentCreator.divider(context),
      SizedBox(
        height: 20.0,
      ),
    ];
    List<Widget> preChildsLoading = List.from(preChilds);
    preChildsLoading.add(Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
          child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      )),
    ));
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: Consumer(builder: (context, watch, child) {
        final notifier = watch(sosmedFeedChangeNotifier);
        if (notifier.countData() == 0) {
          return ListView(
            //padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
            //children: pre_childs,
            children: showLoadingFirstTime ? preChildsLoading : preChilds,
          );
        }

        int totalCount = notifier.countData()! + preChilds.length;
        if (notifier.loadingBottom || notifier.retryBottom) {
          totalCount = totalCount + 1;
        }
        return ListView.builder(
            controller: _scrollController,
            shrinkWrap: false,
            padding: const EdgeInsets.only(
                /*left: InvestrendTheme.cardMargin, right: InvestrendTheme.cardMargin,*/ top:
                    InvestrendTheme.cardMargin,
                bottom: (InvestrendTheme.cardMargin + 100.0)),
            //itemCount: notifier.countPost() + pre_childs.length ,
            itemCount: totalCount,
            itemBuilder: (BuildContext context, int index) {
              if (index < preChilds.length) {
                return preChilds.elementAt(index);
              } else if (index < (preChilds.length + notifier.countData()!)) {
                int indexPost = index - preChilds.length;
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
      /*
      child: ListView(
        padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
        shrinkWrap: false,
        children: childs,
      ),
      */
    );
  }

  Votes votes = Votes('12 jam 22 menit lagi', 990)
    ..addVote(Vote('BBCA', 31))
    ..addVote(Vote('ASII', 21))
    ..addVote(Vote('ANTM', 11));
  // votes.addVote(Vote('BBCA', 31));
  // votes.addVote(Vote('ASII', 21));
  // votes.addVote(Vote('ANTM', 11));

  Prediction prediction = Prediction('ASII', 'Astra Internasional TBK', 238,
      1760, 8.5, '30 hari', 31, 12, 43, '12 hours 22 minutes left');

  List<CommentOld> comments = [
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
        'Mikasa',
        '@mikasa',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
        'Andrea',
        '@andrea',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
        'Noone',
        '@noone',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
        'Noone',
        '@noone',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
        'Noone',
        '@noone',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
  ];
  List<CommentOld> comments_1 = [
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
        'Mikasa',
        '@mikasa',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    // Comment('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU', 'Andrea', '@andrea', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    // Comment('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU', 'Noone', '@noone', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    // Comment('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU', 'Noone', '@noone', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    // Comment('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU', 'Noone', '@noone', 'Featured', '10:15', 'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
  ];
  List<CommentOld> comments_2 = [
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
        'Mikasa',
        '@mikasa',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
    CommentOld(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
        'Andrea',
        '@andrea',
        'Featured',
        '10:15',
        'Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.'),
  ];
  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {


    return ListView(
      shrinkWrap: true,
      children: [
        CardProfiles('Featured Profiles', listProfiles),
        SizedBox(height: 20.0,),
        ComponentCreator.divider(context),
        SizedBox(height: 20.0,),

        CardSocialTextPrediction(prediction, 'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100, comments_1,commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),

        CardSocialTextImage('https://www.crushpixel.com/static19/preview2/young-woman-shopping-city-street-3386338.jpg', 'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70', 'Ackerman', '@ackerman', 'Featured', '02/4/20', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id ultrices sed enim nulla aliquam euismod porttitor ante. Ornare a tempus sed justo ipsum, in molestie rhoncus.Massa a adipiscing fusce elit in tellus libero. Amet id eget sed non quis ipsum donec. Viverra etiam ullamcorper.', 3, 100,comments_2,commentClick: (){}, likeClick: (){}, shareClick: (){}, onTap: (){},),
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
  }
  */

  @override
  void onActive() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate();
    // });
    if (context.read(sosmedActiveActionNotifier).index ==
        ActiveActionType.DoUpdate.index) {
      doUpdate();
    }
  }

  @override
  void onInactive() {}
}
