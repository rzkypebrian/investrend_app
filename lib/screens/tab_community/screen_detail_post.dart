import 'dart:math';

import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/cards/card_social_media.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/sosmed_object.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenDetailPost extends StatefulWidget {
  final Post post;
  final bool showKeyboard;
  const ScreenDetailPost(this.post, {this.showKeyboard = false, Key key}) : super(key: key);

  @override
  _ScreenDetailPostState createState() => _ScreenDetailPostState(this.post, this.showKeyboard);
}

class _ScreenDetailPostState extends BaseStateNoTabs<ScreenDetailPost> {
  final Post post;
  final bool showKeyboard;
  final ValueNotifier<int> _selectedCarouselNotifier = ValueNotifier<int>(0);
  TextEditingController fieldTextController;
  FocusNode fieldCommentNode = FocusNode();
  bool commentAdded = false;
  _ScreenDetailPostState(this.post, this.showKeyboard) : super('/detail_post');

  // only for Activity / Transaction
  String activityCode    = '';
  String activityPercent    = '';
  ActivityType activityType = ActivityType.Unknown;

  ScrollController _scrollController;

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 2), curve: Curves.easeInOutQuint);
  }
  void scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // "reach the bottom";
      if(mounted){
        fetchNextPage();
      }
    }
    if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      // "reach the top";
    }
  }
  bool showedLastPageInfo = false;
  void fetchNextPage(){
    if(context.read(sosmedCommentChangeNotifier).loadingBottom){
      print('scrollListener nextPage onProgress : '+context.read(sosmedCommentChangeNotifier).loadingBottom.toString());
      return;
    }
    print('reach the bottom');

    String next_page_url = context.read(sosmedCommentChangeNotifier).next_page_url;
    int current_page = context.read(sosmedCommentChangeNotifier).current_page;
    int last_page = context.read(sosmedCommentChangeNotifier).last_page;
    if(current_page >= last_page){
      if(showedLastPageInfo){
        return;
      }
      showedLastPageInfo = true;
      InvestrendTheme.of(context).showSnackBar(context, 'sosmed_label_all_comment_viewed'.tr(), buttonOnPress: _scrollToTop, buttonLabel: 'button_latest_comment'.tr(), buttonColor: Colors.orange, seconds: 5);
      // Future.delayed(Duration(seconds: 1),(){
      //   context.read(sosmedCommentChangeNotifier).showLoadingBottom(false);
      // });
      return;
    }
    context.read(sosmedCommentChangeNotifier).showLoadingBottom(true);
    int next_page = current_page + 1;
    final result = doUpdate(nextPage: next_page);
  }
  
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    double paddingBottomFake = 0;
    return Container(
      //color: Colors.red,
      color: Theme.of(context).backgroundColor,
      height: double.maxFinite,
      width: double.maxFinite,
      child: Stack(
        children: [
          SafeArea(
            child: ComponentCreator.keyboardHider(context, Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: createAppBar(context),
              body: createBody(context, paddingBottomFake),
              bottomSheet: createBottomSheet(context, paddingBottomFake),
              bottomNavigationBar: createBottomNavigationBar(context),
            )),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              width: double.maxFinite,
              height: paddingBottom,
            ),
          )
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    fieldTextController.dispose();
    _selectedCarouselNotifier.dispose();
    fieldCommentNode.dispose();
    super.dispose();
  }

  bool showLoadingFirstTime = true;
  @override
  void initState() {
    super.initState();
    fieldTextController = TextEditingController();

    _scrollController = ScrollController();
    _scrollController.addListener(scrollListener);

    if(post.postType == PostType.TRANSACTION){
      activityCode = post?.code;
      if(StringUtils.equalsIgnoreCase(post.transaction_type, 'BUY')){
        activityType = ActivityType.Invested;
      }else if(StringUtils.equalsIgnoreCase(post.transaction_type, 'SELL')){
        int change = post.sell_price - post.start_price;
        double percentChange = Utils.calculatePercent(post.start_price, post.sell_price);
        activityPercent = InvestrendTheme.formatPercentChange(percentChange);
        if(change > 0 ){
          activityType = ActivityType.Gain;
        }else if(change < 0 ){
          activityType = ActivityType.Loss;
        }else{
          activityType = ActivityType.NoChange;
        }
      }else{
        activityType = ActivityType.Unknown;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(showKeyboard){
        fieldCommentNode.requestFocus();
      }

      doUpdate();
    });
    


  }
  @override
  Widget createAppBar(BuildContext context) {
    // return null;

    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).backgroundColor,
      title: AppBarTitleText('sosmed_detail_post_title'.tr()),
      leading: AppBarActionIcon(
        'images/icons/action_back.png',
            () {

          hideKeyboard();
          if(commentAdded){
            Navigator.of(context).pop('REFRESH');
          }else{
            Navigator.of(context).pop();
          }

        },
      ),
      actions: [
        AppBarActionIcon(
          'images/icons/menu_vertical_dots.png',
              () {
            hideKeyboard();
            //Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget topWidget(BuildContext context){

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 16.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarProfileButton(
            fullname: post?.user?.name,
            url: post?.user?.featured_attachment,
            size: 40.0,
          ),
          SizedBox(
            width: 15.0,
          ),
          Container(
            height: 40.0,
            //color: Colors.red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Text(post?.user.name, style: InvestrendTheme.of(context).small_w400_compact,),
                Text(Utils.displayPostDateDetail(post?.created_at), style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(fontSize:10.0, color: InvestrendTheme.of(context).greyLighterTextColor),),
              ],
            ),
          )
        ],
      ),
    );
  }
  void onPageChange(int index, CarouselPageChangedReason changeReason) {
    _selectedCarouselNotifier.value = index;
    print('selectedCarousel : $_selectedCarouselNotifier.value');
  }

  Widget imagesWidget(BuildContext context){
    double size = MediaQuery.of(context).size.width;
    if(post.attachmentsCount() <= 0){
      return SizedBox(width: 1.0,);
    }else if(post.attachmentsCount() == 1){
      //return Image.network(post.attachments.first.attachment, fit: BoxFit.contain, width: size, height: size,);
      return SizedBox
        (
        width: size,
        height: size,
        child: ComponentCreator.imageNetwork(
          post.attachments.first.attachment,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.width,
            //aspectRatio: 16/9,
            viewportFraction: 1.0,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 500),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: onPageChange,
            scrollDirection: Axis.horizontal,
          ),
          items: post.attachments.map((attachment) {
            //return Image.network(attachment.attachment);
            return ComponentCreator.imageNetwork(
              attachment.attachment,
              width: size,
              height: size,
              fit: BoxFit.contain,
            );
            /*
            return Image.network(attachment.attachment, fit: BoxFit.contain, width: size, height: size,);
            */
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ComponentCreator.dotsIndicator(context, post.attachmentsCount(), 0, _selectedCarouselNotifier),
        ),
      ],
    );
  }
  Widget commentWidget(BuildContext context){
    int topCommentsCount = post?.top_comments != null ? post.top_comments.length : 0;
    return (topCommentsCount > 0
        ? TopCommentsWidget(post.top_comments, post.comment_count ,onTap: onShowMoreComment,)
        : SizedBox(
      width: 1.0,
    ));
  }
  void onShowMoreComment(){

  }

  Widget postWidget(BuildContext context){
    switch(post.postType){
      case PostType.POLL:
        {
          //return NewCardSocialTextPoll(post, shareClick: (){}, commentClick: (){},likeClick:()=> likeClicked(context, post), onTap: ()=>showDetailPost(context, post), key: Key(post.keyString),);
          final String infoVotes = post.voter_count.toString() + ' votes • ' + Utils.displayExpireDate(post.expired_at);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post?.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
              SizedBox(height: 16.0,),
              PollWidget(post),
              SizedBox(height: 12.0,),
              Text(infoVotes,
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      .copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, fontSize: 11.0)),
            ],
          );
        }
        break;
      case PostType.PREDICTION:
        {
          //return NewCardSocialTextPrediction(post, shareClick: (){}, commentClick: (){},likeClick: ()=> likeClicked(context, post), onTap: ()=>showDetailPost(context, post), key: Key(post.keyString));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post?.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
              SizedBox(height: 16.0,),
              NewPredictionWidget(post),
            ],
          );
        }
        break;
      case PostType.TRANSACTION:
        {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ActivityWidget(activityType, activityCode, activityPercent),
              SizedBox(height: 16.0,),
              Text(post?.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
            ],
          );
        }
        break;
      case PostType.TEXT:
        {
          if(post.attachmentsCount() > 0 ){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post?.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
                SizedBox(height: 16.0,),
                imagesWidget(context),
              ],
            );
          }else{
            return Text(post?.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),);
          }
        }
        break;
      case PostType.Unknown:
        {
          return Text(post.type+' -->  is Unknown');
        }
        break;
      default:
        {
          return Text(post.type+' -->  is Unknown[default]');
        }
        break;
    }
  }

  Widget textWidget(BuildContext context, bool abovePostWidget){

    if(abovePostWidget){
      if(post.postType == PostType.TRANSACTION){
        return SizedBox(width: 1.0,);
      }
      return Padding(
        padding: const EdgeInsets.only(left: 12.0,right: 12.0, bottom: 16.0),
        child: Text(post?.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
      );
    }else{
      if(post.postType != PostType.TRANSACTION){
        return SizedBox(width: 1.0,);
      }
      return Padding(
        padding: const EdgeInsets.only(left: 12.0,right: 12.0, bottom: 16.0),
        child: Text(post?.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
      );
    }


  }
  @override
  Widget createBody(BuildContext context, double paddingBottom) {

    List<Widget> pre_childs = [
      topWidget(context),
      Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 16.0),
        child: postWidget(context),
      ),
      LikeCommentShareWidget(
        post?.like_count,
        post?.comment_count,
        post?.liked,
        likeClick: ()=> likeClicked(context),
        //likeClick: ()=> likeClicked(context, post),
        //likeClick: onLikeButtonTapped(context, post),
        commentClick: ()=> fieldCommentNode.requestFocus(),
        shareClick: (){},
        post: post,
      ),
      ComponentCreator.divider(context),
      //commentWidget(context),
    ];
    List<Widget> pre_childs_loading = List.from(pre_childs);
    pre_childs_loading.add(Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(child: CircularProgressIndicator(color: Theme.of(context).accentColor, backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),)),
    ));

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: Consumer(builder: (context, watch, child) {
        final notifier = watch(sosmedCommentChangeNotifier);
        if(notifier.countData() == 0){

          return ListView(
            padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
            children: showLoadingFirstTime ? pre_childs_loading : pre_childs,
          );
        }

        int totalCount = notifier.countData() + pre_childs.length;
        if(notifier.loadingBottom || notifier.retryBottom){
          totalCount  = totalCount + 1;
        }
        return ListView.builder(
            controller: _scrollController,
            shrinkWrap: false,
            padding: const EdgeInsets.only(left: InvestrendTheme.cardMargin, right: InvestrendTheme.cardMargin, top: InvestrendTheme.cardMargin, bottom: (InvestrendTheme.cardMargin + 100.0)),
            //itemCount: notifier.countPost() + pre_childs.length ,
            itemCount:totalCount,
            itemBuilder: (BuildContext context, int index) {
              if(index < pre_childs.length){
                return pre_childs.elementAt(index);
              }else if(index < (pre_childs.length + notifier.countData())){

                int indexPost = index - pre_childs.length;
                PostComment comment = notifier.datas().elementAt(indexPost);

                if(comment != null){
                  return CommentWidget(comment,key: Key(comment.keyString),);
                }else{
                  return EmptyLabel(text: 'comment index $index is null',);
                }

              }else{
                if(notifier.loadingBottom){
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).accentColor, backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),));
                }else if(notifier.retryBottom){
                  return Center(child: TextButton(child: Text('button_retry'.tr(), style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: Theme.of(context).accentColor),), onPressed: (){
                    fetchNextPage();
                  },));
                }else{
                  return Center(child: EmptyLabel(text: 'infinity_label️'.tr(),));
                }
              }


            });
      }),
    );
    /*
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          topWidget(context),

          //textWidget(context, true),
          //imagesWidget(context),
          //NewPredictionWidget(post),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 16.0),
            child: postWidget(context),
          ),
          //textWidget(context, false),
          LikeCommentShareWidget(
            post?.like_count,
            post?.comment_count,
            post?.liked,
            likeClick: ()=> likeClicked(context, post),
            commentClick: (){},
            shareClick: (){},
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ComponentCreator.divider(context),
          ),

          commentWidget(context),
        ],
      ),
    );
    */
  }
  @override
  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    double height = 50.0 + paddingBottom;

    double newPaddingBottom = paddingBottom > 0 ? paddingBottom : 8.0;

    return Container(
      //color: Colors.red,
      //width: 200,
      //height: height,
      //padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: newPaddingBottom),
      //padding: EdgeInsets.only(left: 4.0, right: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 8.0, top: 12.0, bottom: 12.0),
            child: Consumer(builder: (context, watch, child) {
              final notifier = watch(avatarChangeNotifier);
              String url = notifier.url;
              if (notifier.invalid()) {
                url = 'https://' +
                    InvestrendTheme.tradingHttp.tradingBaseUrl +
                    '/getpic?username=' +
                    context.read(dataHolderChangeNotifier).user.username +
                    '&url=&nocache=';
              }
              return AvatarProfileButton(
                fullname: context.read(dataHolderChangeNotifier).user.realname,
                url: url,
                size: 32.0,
              );
            }),
          ),
          /*
          Padding(
            //padding: const EdgeInsets.only(top : 0.0),
            padding: Theme.of(context).buttonTheme.padding,
            child: Consumer(builder: (context, watch, child) {
              final notifier = watch(avatarChangeNotifier);
              String url = notifier.url;
              if (notifier.invalid()) {
                url = 'http://' +
                    InvestrendTheme.tradingHttp.tradingBaseUrl +
                    '/getpic?username=' +
                    context.read(dataHolderChangeNotifier).user.username +
                    '&url=&nocache=';
              }
              return AvatarProfileButton(
                fullname: context.read(dataHolderChangeNotifier).user.realname,
                url: url,
                size: 32.0,
              );
            }),
          ),
          */
          //SizedBox(width: 8.0,),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: TextField(
                controller: fieldTextController,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                maxLength: 255,
                minLines: 1,
                focusNode: fieldCommentNode,
                //textInputAction: TextInputAction.done,
                // onEditingComplete: () {
                //     FocusScope.of(context).unfocus();
                // },
                style: InvestrendTheme.of(context).more_support_w400,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'create_comment_information'.tr(),
                  hintStyle: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      .copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                  counterStyle: InvestrendTheme.of(context)
                      .more_support_w400_compact.copyWith(fontSize: 10.0)
                      .copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                  focusColor: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
          //SizedBox(width: 8.0,),
          TapableWidget(
            onTap: ()=>submitComment(context),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset('images/icons/send.png', width: 32, height: 32,),
            ),
          ),
          // IconButton(onPressed: (){},
          //   padding: EdgeInsets.all(1.0),
          //
          // visualDensity: VisualDensity.compact,
          //   icon: Image.asset('images/icons/send.png', width: 32, height: 32,),),
        ],
      ),
    );
  }
  void submitComment(BuildContext context) async {
    String text = fieldTextController.text;
    if(StringUtils.isEmtpy(text)){
      InvestrendTheme.of(context).showSnackBar(context, 'sosmed_comment_error_empty'.tr());
      return;
    }
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


          return LoadingBottomSheetSimple('sosmed_comment_submit_loading_text'.tr());
        });

    try{
      //SubmitCreateComment submitResult = await SosMedHttp.sosmedCreateComment('123',post.id, fieldTextController.text, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, language: EasyLocalization.of(context).locale.languageCode);

      SubmitCreateComment submitResult = await InvestrendTheme.tradingHttp.sosmedCreateComment(post.id, fieldTextController.text, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, language: EasyLocalization.of(context).locale.languageCode);

      if(submitResult != null ){
        print('submitResult = '+submitResult.toString());
        bool success = submitResult.status == 200;// && submitResult?.result?.id >= 0;
        if(mounted) {
          InvestrendTheme.of(context).showSnackBar(context, submitResult.message);
        }
        if(success){
          commentAdded = true;
          if(mounted){
            fieldTextController.text = '';
            hideKeyboard();
            doUpdate();
          }

          // if(StringUtils.equalsIgnoreCase(submitResult.message, 'Like deleted!')){
          //   post.likedUndoed();
          // }else if(StringUtils.equalsIgnoreCase(submitResult.message, 'Like created!')){
          //   post.likedSuccess();
          // }
          // if(mounted){
          //   context.read(sosmedPostChangeNotifier).mustNotifyListener();
          // }
        }
      }
      Navigator.of(context).pop();
    }catch(error){
      print(routeName + '.submitComment Exception like : '+error.toString());
      print(error);
      Navigator.of(context).pop();
      //DebugWriter.info(routeName+' stockPosition Exception : ' + e.toString());
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

    }finally {
      // Future.delayed(Duration(seconds: 2),(){
      //Navigator.of(context).pop();
      //
    }
  }

  Future<bool> onLikeButtonTapped(BuildContext context, Post post) async{
    try{
      //SubmitLike submitResult = await SosMedHttp.sosmedLike(!post.liked ,'123',post.id, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, language: EasyLocalization.of(context).locale.languageCode);
      SubmitLike submitResult = await InvestrendTheme.tradingHttp.sosmedLike(!post.liked, post.id, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, language: EasyLocalization.of(context).locale.languageCode);

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
            context.read(sosmedCommentChangeNotifier).mustNotifyListener();
            setState(() {

            });
          }
        }
      }
    }catch(error){
      print(routeName + '.likeClicked Exception like : '+error.toString());
      print(error);
      InvestrendTheme.of(context).showSnackBar(context, 'general_error_information'.tr());
    }finally {
      // Future.delayed(Duration(seconds: 2),(){
      //Navigator.of(context).pop();
      //
    }
    return post.liked;
  }

  void likeClicked(BuildContext context){
    if(mounted){
      context.read(sosmedCommentChangeNotifier).mustNotifyListener();
      setState(() {

      });
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
            context.read(sosmedCommentChangeNotifier).mustNotifyListener();
            setState(() {

            });
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
  @override
  void onActive() {

  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  Future onRefresh() {

    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }
  Future doUpdate({bool pullToRefresh = false, int nextPage}) async {
    print(routeName + '.doUpdate');
    showedLastPageInfo = false;
    try{
      context.read(sosmedCommentChangeNotifier).showLoadingBottom(true);
      //final fetchComment = await SosMedHttp.sosmedFetchComment(post?.id?.toString(), '123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, page: nextPage, language: EasyLocalization.of(context).locale.languageCode);
      final fetchComment = await InvestrendTheme.tradingHttp.sosmedFetchComment(post?.id?.toString(),  InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, page: nextPage, language: EasyLocalization.of(context).locale.languageCode);
      if(fetchComment.result != null ){
        print('fetchComment = '+fetchComment.status.toString() +' --> '+fetchComment.message);
        //_pageSize = fetchPost.result.per_page;
        showLoadingFirstTime = false;
        context.read(sosmedCommentChangeNotifier).setResult(fetchComment.result);
        // Future.delayed(Duration(seconds: 2),(){
        context.read(sosmedCommentChangeNotifier).showLoadingBottom(false);
        // });

      }
    }catch(error){
      print(routeName + '.doUpdate Exception fetch_post : '+error.toString());
      //context.read(sosmedPostChangeNotifier).showLoadingBottom(false);
      if(mounted){
        //InvestrendTheme.of(context).showSnackBar(context, 'Error : '+error.toString());
        // Future.delayed(Duration(seconds: 2),(){
        //context.read(sosmedPostChangeNotifier).showLoadingBottom(false);
        showLoadingFirstTime = false;
        context.read(sosmedCommentChangeNotifier).showRetryBottom(true);
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

  
}
