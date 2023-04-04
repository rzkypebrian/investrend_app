import 'dart:math';

import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/sosmed_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:like_button/like_button.dart';

class NewCardSocialText extends StatelessWidget {
  /*
  final String avatarUrl;
  final String name;
  final String username;
  final String label;
  final String datetime;
  final String text;
  final int commentCount;
  final int likedCount;
  final List<Comment> comments;
  */
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;

  final Post post;

  NewCardSocialText(this.post,
      {Key key, this.commentClick, this.likeClick, this.shareClick, this.onTap})
      : super(key: key);

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0

  final VoidCallback onShowMoreComment = () {};

  @override
  Widget build(BuildContext context) {
    int topCommentsCount =
        post.top_comments != null ? post.top_comments.length : 0;
    Color verticalDividerColor = topCommentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    //Color verticalDividerColor =  Colors.transparent;

    //String avatarUrl = post.user.featured_attachment;
    String avatarUrl = post.user.thumbnail;
    final String name = post.user.name;
    final String username = post.user.username;
    //final String label = post.is_featured == 1 ? 'Featured' : (post.is_trending == 1 ? 'Trending' : 'not featured/trending');
    final String label = post?.is_featured == 1
        ? 'sosmed_label_featured'.tr()
        : (post.is_trending == 1
            ? 'sosmed_label_trending'.tr()
            : 'sosmed_label_not_freatured_not_trending'.tr());
    //final String datetime = post.created_at;
    final String datetime =
        Utils.displayPostDate(post?.created_at); //post?.created_at;
    final String text = post.text;

    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  //width: 1.0,
                  //height: double.maxFinite,
                  //color: Colors.deepOrange,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    fullname: name,
                    url: avatarUrl,
                    size: 48.0,
                  ),

                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        NameUsernameCreated(name, username, datetime),
                        /*
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: '@'+username + ' ',
                                style:
                                InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w700,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style:
                                InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        */
                        SizedBox(
                          height: 20.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Container(
                            width: double.maxFinite,
                            child: Text(text,
                                // softWrap: true,
                                //maxLines: 10,
                                style: InvestrendTheme.of(context)
                                    .small_w400
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyDarkerTextColor)),
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          post.like_count,
                          post.comment_count,
                          post.liked,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                          post: post,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (topCommentsCount > 0
              ? TopCommentsWidget(
                  post.top_comments,
                  post.comment_count,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class CardSocialText extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String username;
  final String label;
  final String datetime;
  final String text;
  final int commentCount;
  final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;
  final List<CommentOld> comments;

  CardSocialText(
      this.avatarUrl,
      this.name,
      this.username,
      this.label,
      this.datetime,
      this.text,
      this.commentCount,
      this.likedCount,
      this.comments,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0

  final VoidCallback onShowMoreComment = () {};

  @override
  Widget build(BuildContext context) {
    int commentsCount = comments != null ? comments.length : 0;
    Color verticalDividerColor = commentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    //Color verticalDividerColor =  Colors.transparent;
    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  //width: 1.0,
                  //height: double.maxFinite,
                  //color: Colors.deepOrange,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: username + ' ',
                                style: InvestrendTheme.of(context)
                                    .small_w400
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w600,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context)
                                    .more_support_w400_compact
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Text(text,
                              style: InvestrendTheme.of(context)
                                  .small_w400
                                  .copyWith(
                                      color: InvestrendTheme.of(context)
                                          .greyDarkerTextColor)),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          likedCount,
                          commentCount,
                          false,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (commentsCount > 0
              ? CommentsWidgetOld(
                  comments,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class NameUsernameCreated extends StatelessWidget {
  final String name;
  final String username;
  final String created;

  const NameUsernameCreated(this.name, this.username, this.created, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      //textAlign: TextAlign.center,
      text: TextSpan(
        text: name + ' ',
        style: InvestrendTheme.of(context).small_w400,
        children: [
          TextSpan(
            text: '@' + username + ' ',
            style: InvestrendTheme.of(context).small_w400_compact.copyWith(
                color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          TextSpan(
            text: '•',
            style: InvestrendTheme.of(context)
                .more_support_w400_compact, //.copyWith(fontSize: 8.0),
          ),
          TextSpan(
            text: ' ' + created,
            style: InvestrendTheme.of(context)
                .more_support_w400_compact
                .copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
          ),
        ],
      ),
    );
  }
}

class TopCommentsWidget extends StatelessWidget {
  final List<PostComment> top_comments;
  final VoidCallback onTap;
  final int comment_count;

  const TopCommentsWidget(this.top_comments, this.comment_count,
      {this.onTap, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    int count = top_comments != null ? top_comments.length : 0;
    //int loop = min(count, 2);
    int loop = count;
    for (int i = 0; i < loop; i++) {
      PostComment comment = top_comments.elementAt(i);
      list.add(
          createComment(context, comment, showLine: (i + 1) < comment_count));
    }
    //"view_all_comments_label": "View All <COUNT> Comments",
    //if (count > loop) {
    //  int gap = count - loop;
    if (comment_count > loop) {
      //int gap = comment_count - loop;
      String more = 'view_all_comments_label'.tr();
      //more = more.replaceFirst('<COUNT>', gap.toString());
      more = more.replaceFirst('<COUNT>', comment_count.toString());
      list.add(TapableWidget(
        onTap: onTap,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 9.0, right: 9.0),
              child: Image.asset(
                'images/sosmed/comments_more.png',
                height: 30.0,
                width: 30.0,
              ),
            ),
            SizedBox(
              width: 12.0,
            ),
            Text(
              more,
              style: InvestrendTheme.of(context)
                  .more_support_w600_compact
                  .copyWith(
                      color: Theme.of(context).accentColor, fontSize: 12.0),
            )
          ],
        ),
      ));
    }

    return Column(
      children: list,
    );
  }

  Widget createComment(BuildContext context, PostComment comment,
      {bool showLine = false}) {
    //List<Widget> list = List.empty(growable: true);

    Color verticalDividerColor =
        !showLine ? Colors.transparent : Theme.of(context).dividerColor;
    //final String label = comment.user.is_featured == 1 ? 'Featured' : 'not featured';
    final String label = comment.user.is_featured == 1
        ? 'sosmed_label_featured'.tr()
        : 'sosmed_label_not_freatured_not_trending'.tr();

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.only(left: 16.0),
            //width: 1.0,
            //height: double.maxFinite,
            // color: Colors.deepOrange,
            child: Align(
                alignment: Alignment.topLeft,
                child: VerticalDivider(
                  thickness: 0.5,
                  color: verticalDividerColor,
                )),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: AvatarProfileButton(
                fullname: comment.user.name,
                //url: comment.user.featured_attachment,
                url: comment.user.thumbnail,
                size: 32.0,
              ),
              // child: AvatarIcon(
              //   imageUrl: comment.user.featured_attachment,
              //   size: 32.0,
              // ),
            ),
            SizedBox(
              width: 12.0,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact
                        .copyWith(
                            color:
                                InvestrendTheme.of(context).greyDarkerTextColor,
                            fontSize: 10.0),
                  ),
                  NameUsernameCreated(comment.user.name, comment.user.username,
                      Utils.displayPostDate(comment?.created_at)),
                  /*
                  RichText(
                    text: TextSpan(
                      text: comment.user.name + ' ',
                      style: InvestrendTheme.of(context).small_w400,
                      children: [
                        TextSpan(
                          text: '@'+comment.user.username + ' ',
                          style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                        ),
                        TextSpan(
                          text: '•',
                          style: InvestrendTheme.of(context).more_support_w400_compact,
                        ),
                        TextSpan(
                          text: ' ' + Utils.displayPostDate(comment?.created_at),
                          style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                        ),
                      ],
                    ),
                  ),
                  */
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(comment.text,
                      style: InvestrendTheme.of(context).small_w400.copyWith(
                          color:
                              InvestrendTheme.of(context).greyDarkerTextColor)),
                  SizedBox(
                    height: 12.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CommentWidget extends StatelessWidget {
  final PostComment comment;

  const CommentWidget(this.comment, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //List<Widget> list = List.empty(growable: true);

    //Color verticalDividerColor = !showLine ? Colors.transparent : Theme.of(context).dividerColor;
    //final String label = comment.user.is_featured == 1 ? 'Featured' : 'not featured';
    // final String label = comment.user.is_featured == 1 ? 'sosmed_label_featured'.tr() : 'sosmed_label_not_freatured_not_trending'.tr();
    return Padding(
      padding: const EdgeInsets.only(
          left: 12.0, right: 12.0, top: 16.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarProfileButton(
                fullname: comment?.user?.name,
                //url: comment?.user?.featured_attachment,
                url: comment?.user?.thumbnail,
                size: 40.0,
              ),
              // SizedBox(
              //   width: 15.0,
              // ),
              Container(
                height: 40.0,
                //color: Colors.red,
                padding: EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      comment?.user?.name,
                      style: InvestrendTheme.of(context).small_w400_compact,
                    ),
                    Text(
                      Utils.displayPostDateDetail(comment?.created_at),
                      style: InvestrendTheme.of(context)
                          .more_support_w400_compact
                          .copyWith(
                              fontSize: 10.0,
                              color: InvestrendTheme.of(context)
                                  .greyLighterTextColor),
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 55.0,
            ),
            child: Text(comment.text,
                style: InvestrendTheme.of(context).small_w400.copyWith(
                    color: InvestrendTheme.of(context).greyDarkerTextColor)),
          ),
        ],
      ),
    );

    /*
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: AvatarProfileButton(
            fullname: comment?.user?.name,
            url: comment?.user?.featured_attachment,
            size: 32.0,

          ),
        ),
        SizedBox(
          width: 12.0,
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: InvestrendTheme.of(context)
                    .more_support_w400_compact
                    .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor, fontSize: 10.0),
              ),
              NameUsernameCreated(comment.user.name, comment.user.username, Utils.displayPostDate(comment?.created_at)),
              SizedBox(
                height: 20.0,
              ),
              Text(comment.text, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),
              SizedBox(
                height: 12.0,
              ),
            ],
          ),
        ),
      ],
    );
    */
  }
}

class CommentsWidgetOld extends StatelessWidget {
  final List<CommentOld> comments;
  final VoidCallback onTap;

  const CommentsWidgetOld(this.comments, {this.onTap, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    int count = comments != null ? comments.length : 0;
    int loop = min(count, 2);
    for (int i = 0; i < loop; i++) {
      CommentOld comment = comments.elementAt(i);
      list.add(createComment(context, comment, showLine: (i + 1) < count));
    }
    //"view_all_comments_label": "View All <COUNT> Comments",
    if (count > loop) {
      int gap = count - loop;
      String more = 'view_all_comments_label'.tr();
      more = more.replaceFirst('<COUNT>', gap.toString());
      list.add(TapableWidget(
        onTap: onTap,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 9.0, right: 9.0),
              child: Image.asset(
                'images/sosmed/comments_more.png',
                height: 30.0,
                width: 30.0,
              ),
            ),
            SizedBox(
              width: 12.0,
            ),
            Text(
              more,
              style: InvestrendTheme.of(context)
                  .more_support_w600_compact
                  .copyWith(
                      color: Theme.of(context).accentColor, fontSize: 12.0),
            )
          ],
        ),
      ));
    }

    return Column(
      children: list,
    );
  }

  Widget createComment(BuildContext context, CommentOld comment,
      {bool showLine = false}) {
    //List<Widget> list = List.empty(growable: true);

    Color verticalDividerColor =
        !showLine ? Colors.transparent : Theme.of(context).dividerColor;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.only(left: 16.0),
            //width: 1.0,
            //height: double.maxFinite,
            // color: Colors.deepOrange,
            child: Align(
                alignment: Alignment.topLeft,
                child: VerticalDivider(
                  thickness: 0.5,
                  color: verticalDividerColor,
                )),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              // child: AvatarIcon(
              //   imageUrl: comment.avatarUrl,
              //   size: 32.0,
              // ),
              child: AvatarProfileButton(
                url: comment.avatarUrl,
                fullname: comment.name,
                size: 32.0,
              ),
            ),
            SizedBox(
              width: 12.0,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.label,
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact
                        .copyWith(
                            color:
                                InvestrendTheme.of(context).greyDarkerTextColor,
                            fontSize: 10.0),
                  ),
                  RichText(
                    text: TextSpan(
                      text: comment.name + ' ',
                      style: InvestrendTheme.of(context).small_w400,
                      children: [
                        TextSpan(
                          text: comment.username + ' ',
                          style: InvestrendTheme.of(context)
                              .small_w400
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyLighterTextColor),
                        ),
                        TextSpan(
                          text: '•',
                          style: InvestrendTheme.of(context).small_w600,
                        ),
                        TextSpan(
                          text: ' ' + comment.datetime,
                          style: InvestrendTheme.of(context)
                              .small_w400
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyLighterTextColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(comment.text,
                      style: InvestrendTheme.of(context).small_w400.copyWith(
                          color:
                              InvestrendTheme.of(context).greyDarkerTextColor)),
                  SizedBox(
                    height: 12.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CardSocialTextPrediction extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String username;
  final String label;
  final String datetime;
  final String text;
  final int commentCount;
  final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;
  final Prediction prediction;
  final List<CommentOld> comments;

  const CardSocialTextPrediction(
      this.prediction,
      this.avatarUrl,
      this.name,
      this.username,
      this.label,
      this.datetime,
      this.text,
      this.commentCount,
      this.likedCount,
      this.comments,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  @override
  Widget build(BuildContext context) {
    int commentsCount = comments != null ? comments.length : 0;
    Color verticalDividerColor = commentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  //width: 1.0,
                  //height: double.maxFinite,
                  //color: Colors.deepOrange,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: '@' + username + ' ',
                                style: InvestrendTheme.of(context)
                                    .small_w400
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w600,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context)
                                    .more_support_w400_compact
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Column(
                            children: [
                              Text(text,
                                  style: InvestrendTheme.of(context)
                                      .small_w400
                                      .copyWith(
                                          color: InvestrendTheme.of(context)
                                              .greyDarkerTextColor)),
                              SizedBox(
                                height: 12.0,
                              ),
                              PredictionWidget(prediction),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          likedCount,
                          commentCount,
                          false,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (commentsCount > 0
              ? CommentsWidgetOld(comments)
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class NewCardSocialTextPrediction extends StatelessWidget {
  final Post post;

  // final String avatarUrl;
  // final String name;
  // final String username;
  // final String label;
  // final String datetime;
  // final String text;
  // final int commentCount;
  // final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;

  // final Prediction prediction;
  // final List<Comment> comments;
  NewCardSocialTextPrediction(this.post,
      //this.prediction, this.avatarUrl, this.name, this.username, this.label, this.datetime, this.text, this.commentCount, this.likedCount,this.comments,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0

  @override
  Widget build(BuildContext context) {
    int topCommentsCount =
        post.top_comments != null ? post.top_comments.length : 0;
    Color verticalDividerColor = topCommentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;

    //final String avatarUrl = post?.user?.featured_attachment;
    final String avatarUrl = post?.user?.thumbnail;
    final String name = post?.user?.name;
    final String username = post?.user?.username;
    final String label = post?.is_featured == 1
        ? 'sosmed_label_featured'.tr()
        : (post.is_trending == 1
            ? 'sosmed_label_trending'.tr()
            : 'sosmed_label_not_freatured_not_trending'.tr());
    final String datetime = Utils.displayPostDate(post?.created_at);
    final String text = post?.text;

    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  //width: 1.0,
                  //height: double.maxFinite,
                  //color: Colors.deepOrange,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        NameUsernameCreated(name, username, datetime),
                        /*
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: '@'+username + ' ',
                                style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w700,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        */
                        SizedBox(
                          height: 20.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text,
                                  style: InvestrendTheme.of(context)
                                      .small_w400
                                      .copyWith(
                                          color: InvestrendTheme.of(context)
                                              .greyDarkerTextColor)),
                              SizedBox(
                                height: 12.0,
                              ),
                              NewPredictionWidget(post),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          post.like_count,
                          post.comment_count,
                          post.liked,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                          post: post,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (topCommentsCount > 0
              ? TopCommentsWidget(
                  post.top_comments,
                  post.comment_count,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }

  final VoidCallback onShowMoreComment = () {};
}

enum ActivityType { Invested, Gain, Loss, NoChange, Unknown }

extension ActivityTypeExtension on ActivityType {
  String get text {
    switch (this) {
      case ActivityType.Invested:
        return 'Invested';
      case ActivityType.Gain:
        return 'Gain';
      case ActivityType.Loss:
        return 'Loss';
      case ActivityType.NoChange:
        return 'NoChange';
      default:
        return '#unkown_activity';
    }
  }

  /*
  Color get colorBackground {
    switch (this) {
      case ActivityType.Invested:
        return Color(0xFFE4DFF4);
      case ActivityType.Gain:
        return Color(0xFFD5F8EE);
      case ActivityType.Loss:
        return Color(0xFFE1B7C4);
      default:
        return Color(0xFFE4DFF4);
    }
  }
  */
  Color get colorBackground {
    switch (this) {
      case ActivityType.Invested:
        return Color(0x405414DB);
      case ActivityType.Gain:
        return Color(0x4025B792);
      case ActivityType.Loss:
        return Color(0x40E50449);
      case ActivityType.NoChange:
        return Color(0x40FAA043);
      default:
        return Color(0x405414DB);
    }
  }

  Color get colorText {
    switch (this) {
      case ActivityType.Invested:
        return Color(0xFF5414DB);
      case ActivityType.Gain:
        return Color(0xFF25B792);
      case ActivityType.Loss:
        return Color(0xFFE50449);
      case ActivityType.NoChange:
        return Color(0xFFFAA043);
      default:
        return Color(0xFF5414DB);
    }
  }

  String get imagePath {
    switch (this) {
      case ActivityType.Invested:
        return 'images/sosmed/activity_chart.png';
      case ActivityType.Gain:
        return 'images/sosmed/activity_gain.png';
      case ActivityType.Loss:
        return 'images/sosmed/activity_loss.png';
      case ActivityType.NoChange:
        return 'images/sosmed/activity_no_change.png';
      default:
        return 'images/sosmed/activity_chart.png';
    }
  }
}

class CardSocialTextActivity extends StatelessWidget {
  final String avatarUrl;
  final String name;

  final String username;
  final String label;
  final String datetime;
  final String text;
  final int commentCount;
  final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;
  final ActivityType activityType;
  final String activityCode;
  final String activityPercent;
  final List<CommentOld> comments;

  CardSocialTextActivity(
    this.activityType,
    this.activityCode,
    this.avatarUrl,
    this.name,
    this.username,
    this.label,
    this.datetime,
    this.text,
    this.commentCount,
    this.likedCount,
    this.comments, {
    Key key,
    this.commentClick,
    this.likeClick,
    this.shareClick,
    this.activityPercent = '',
    this.onTap,
  }) : super(key: key);

  final VoidCallback onShowMoreComment = () {};

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  @override
  Widget build(BuildContext context) {
    int commentsCount = comments != null ? comments.length : 0;
    Color verticalDividerColor = commentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    TextStyle stylePlain = InvestrendTheme.of(context)
        .more_support_w400_compact
        .copyWith(fontSize: 12.0, color: activityType.colorText);
    TextStyle styleBold = InvestrendTheme.of(context)
        .more_support_w600_compact
        .copyWith(fontSize: 12.0, color: activityType.colorText);
    String activityText = '';
    if (activityType == ActivityType.Invested) {
      activityText = 'sosmed_label_invested_in'.tr() + ' ';
    } else if (activityType == ActivityType.Gain) {
      activityText = 'sosmed_label_gained'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.Loss) {
      activityText = 'sosmed_label_loss'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.NoChange) {
      activityText = 'sosmed_label_no_change'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.Unknown) {
      activityText = 'sosmed_label_unknown'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: username + ' ',
                                style: InvestrendTheme.of(context)
                                    .small_w400
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w600,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context)
                                    .more_support_w400_compact
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Column(
                            children: [
                              Container(
                                height: 36.0,
                                padding: EdgeInsets.only(
                                    left: 14.0,
                                    right: 14.0,
                                    top: 4.0,
                                    bottom: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: activityType.colorBackground,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      activityText,
                                      style: stylePlain,
                                    ),
                                    Text(
                                      activityCode,
                                      style: styleBold,
                                    ),
                                    Spacer(
                                      flex: 1,
                                    ),
                                    Image.asset(
                                      'images/sosmed/activity_chart.png',
                                      width: 14.0,
                                      height: 14.0,
                                      color: activityType.colorText,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(text,
                                  style: InvestrendTheme.of(context)
                                      .small_w400
                                      .copyWith(
                                          color: InvestrendTheme.of(context)
                                              .greyDarkerTextColor)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          likedCount,
                          commentCount,
                          false,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (commentsCount > 0
              ? CommentsWidgetOld(
                  comments,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class ActivityWidget extends StatelessWidget {
  final ActivityType activityType;
  final String activityPercent;
  final String activityCode;

  const ActivityWidget(
      this.activityType, this.activityCode, this.activityPercent,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String activityText = '';
    if (activityType == ActivityType.Invested) {
      activityText = 'sosmed_label_invested_in'.tr() + ' ';
    } else if (activityType == ActivityType.Gain) {
      activityText = 'sosmed_label_gained'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.Loss) {
      activityText = 'sosmed_label_loss'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.NoChange) {
      activityText = 'sosmed_label_no_change'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.Unknown) {
      activityText = 'sosmed_label_unknown'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    }
    TextStyle stylePlain = InvestrendTheme.of(context)
        .more_support_w400_compact
        .copyWith(fontSize: 12.0, color: activityType.colorText);
    TextStyle styleBold = InvestrendTheme.of(context)
        .more_support_w600_compact
        .copyWith(fontSize: 12.0, color: activityType.colorText);
    return Container(
      //height: 46.0,
      padding:
          EdgeInsets.only(left: 14.0, right: 14.0, top: 14.0, bottom: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: activityType.colorBackground,
      ),
      child: Row(
        children: [
          Text(
            activityText,
            style: stylePlain,
          ),
          Text(
            activityCode,
            style: styleBold,
          ),
          Spacer(
            flex: 1,
          ),
          Image.asset(
            //'images/sosmed/activity_chart.png',
            activityType.imagePath,
            width: 14.0,
            height: 14.0,
            color: activityType.colorText,
          ),
        ],
      ),
    );
  }
}

class NewCardSocialTextActivity extends StatelessWidget {
  // final String avatarUrl;
  // final String name;
  //
  // final String username;
  // final String label;
  // final String datetime;
  // final String text;
  // final int commentCount;
  // final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;

  // final ActivityType activityType;
  // final String activityCode;
  // final String activityPercent;
  // final List<Comment> comments;
  final Post post;

  NewCardSocialTextActivity(
    this.post,
    // this.activityType,
    // this.activityCode,
    // this.avatarUrl,
    // this.name,
    // this.username,
    // this.label,
    // this.datetime,
    // this.text,
    // this.commentCount,
    // this.likedCount,
    //   this.comments,
    {
    Key key,
    this.commentClick,
    this.likeClick,
    this.shareClick,
    //this.activityPercent = '',
    this.onTap,
  }) : super(key: key);

  final VoidCallback onShowMoreComment = () {};

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  @override
  Widget build(BuildContext context) {
    int topCommentsCount =
        post.top_comments != null ? post.top_comments.length : 0;
    Color verticalDividerColor = topCommentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;

    //String avatarUrl = post?.user?.featured_attachment;
    String avatarUrl = post?.user?.thumbnail;
    final String name = post?.user?.name;
    final String username = post?.user?.username;
    //final String label = post?.is_featured == 1 ? 'Featured' : (post.is_trending == 1 ? 'Trending' : 'not featured/trending');
    final String label = post?.is_featured == 1
        ? 'sosmed_label_featured'.tr()
        : (post.is_trending == 1
            ? 'sosmed_label_trending'.tr()
            : 'sosmed_label_not_freatured_not_trending'.tr());
    final String datetime =
        Utils.displayPostDate(post?.created_at); //post?.created_at;
    final String text = post?.text;
    final String activityCode = post?.code;

    String activityPercent = '';
    ActivityType activityType;
    if (StringUtils.equalsIgnoreCase(post.transaction_type, 'BUY')) {
      activityType = ActivityType.Invested;
    } else if (StringUtils.equalsIgnoreCase(post.transaction_type, 'SELL')) {
      // int start_price = post.start_price;
      // int sell_price = post.sell_price;
      int change = post.sell_price - post.start_price;
      // double percentChange = ((change / start_price) * 100).toDouble();

      double percentChange =
          Utils.calculatePercent(post.start_price, post.sell_price);

      activityPercent = InvestrendTheme.formatPercentChange(percentChange);
      if (change > 0) {
        activityType = ActivityType.Gain;
      } else if (change < 0) {
        activityType = ActivityType.Loss;
      } else {
        activityType = ActivityType.NoChange;
      }
    } else {
      activityType = ActivityType.Unknown;
    }

    TextStyle stylePlain = InvestrendTheme.of(context)
        .more_support_w400_compact
        .copyWith(fontSize: 12.0, color: activityType.colorText);
    TextStyle styleBold = InvestrendTheme.of(context)
        .more_support_w600_compact
        .copyWith(fontSize: 12.0, color: activityType.colorText);
    String activityText = '';
    // if (activityType == ActivityType.Invested) {
    //   activityText = 'Invested in ';
    // } else if (activityType == ActivityType.Gain) {
    //   activityText = 'Gained $activityPercent from ';
    // } else if (activityType == ActivityType.Loss) {
    //   activityText = 'Loss $activityPercent from ';
    // } else if (activityType == ActivityType.NoChange) {
    //   activityText = 'No Change $activityPercent from ';
    // }
    if (activityType == ActivityType.Invested) {
      activityText = 'sosmed_label_invested_in'.tr() + ' ';
    } else if (activityType == ActivityType.Gain) {
      activityText = 'sosmed_label_gained'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.Loss) {
      activityText = 'sosmed_label_loss'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.NoChange) {
      activityText = 'sosmed_label_no_change'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    } else if (activityType == ActivityType.Unknown) {
      activityText = 'sosmed_label_unknown'.tr() +
          ' $activityPercent ' +
          'sosmed_label_from'.tr() +
          ' ';
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  SizedBox(
                    width: 12.0,
                  ),

                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        NameUsernameCreated(name, username, datetime),
                        /*
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: '@'+username + ' ',
                                style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w700,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                         */
                        SizedBox(
                          height: 15.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ActivityWidget(
                                  activityType, activityCode, activityPercent),
                              /*
                              Container(
                                height: 36.0,
                                padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 4.0, bottom: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: activityType.colorBackground,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      activityText,
                                      style: stylePlain,
                                    ),
                                    Text(
                                      activityCode,
                                      style: styleBold,
                                    ),
                                    Spacer(
                                      flex: 1,
                                    ),
                                    Image.asset(
                                      'images/sosmed/activity_chart.png',
                                      width: 14.0,
                                      height: 14.0,
                                      color: activityType.colorText,
                                    ),
                                  ],
                                ),
                              ),
                              */
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(text,
                                  style: InvestrendTheme.of(context)
                                      .small_w400
                                      .copyWith(
                                          color: InvestrendTheme.of(context)
                                              .greyDarkerTextColor)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          post?.like_count,
                          post?.comment_count,
                          post?.liked,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                          post: post,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (topCommentsCount > 0
              ? TopCommentsWidget(
                  post.top_comments,
                  post.comment_count,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class NewCardSocialTextPoll extends StatelessWidget {
  // final String avatarUrl;
  // final String name;
  // final String username;
  // final String label;
  // final String datetime;
  // final String text;
  // final int commentCount;
  // final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;

  // final Votes votes;
  // final List<Comment> comments;
  final Post post;

  NewCardSocialTextPoll(this.post,
      //this.votes, this.avatarUrl, this.name, this.username, this.label, this.datetime, this.text, this.commentCount, this.likedCount,this.comments,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  final VoidCallback onShowMoreComment = () {};

  @override
  Widget build(BuildContext context) {
    //String infoVotes = votes.totalVotes.toString() + ' votes • ' + votes.expires;
    print(post.toString());
    final String infoVotes = post.voter_count.toString() +
        ' votes • ' +
        Utils.displayExpireDate(post.expired_at);

    //final String avatarUrl = post.user.featured_attachment;
    final String avatarUrl = post.user.thumbnail;
    final String name = post.user.name;
    final String username = post.user.username;
    //final String label = post.is_featured == 1 ? 'Featured' : 'not featured';
    //final String label = post.is_featured == 1 ? 'Featured' : (post.is_trending == 1 ? 'Trending' : 'not featured/trending');
    final String label = post?.is_featured == 1
        ? 'sosmed_label_featured'.tr()
        : (post.is_trending == 1
            ? 'sosmed_label_trending'.tr()
            : 'sosmed_label_not_freatured_not_trending'.tr());
    //final String datetime = post.created_at;
    final String datetime =
        Utils.displayPostDate(post?.created_at); //post?.created_at;
    final String text = post.text;

    List<Widget> list = List.empty(growable: true);
    list.add(Text(
      label,
      style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
          color: InvestrendTheme.of(context).greyDarkerTextColor,
          fontSize: 10.0),
    ));
    list.add(NameUsernameCreated(name, username, datetime));
    /*
    list.add(RichText(
      text: TextSpan(
        text: name + ' ',
        style: InvestrendTheme.of(context).small_w400,
        children: [
          TextSpan(
            text: '@'+username + ' ',
            style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
          TextSpan(
            text: '•',
            style: InvestrendTheme.of(context).small_w700,
          ),
          TextSpan(
            text: ' ' + datetime,
            style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
          ),
        ],
      ),
    ));
     */
    list.add(SizedBox(
      height: 20.0,
    ));

    list.add(TapableWidget(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: InvestrendTheme.of(context).small_w400.copyWith(
                  color: InvestrendTheme.of(context).greyDarkerTextColor)),
          SizedBox(
            height: 12.0,
          ),
          //VoteWidget(votes, false),
          PollWidget(post /*.voter_count, post.polls, post.voted*/),
        ],
      ),
    ));

    list.add(SizedBox(
      height: 12.0,
    ));
    list.add(Text(infoVotes,
        style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
            color: InvestrendTheme.of(context).greyLighterTextColor,
            fontSize: 11.0)));
    list.add(LikeCommentShareWidget(
      post.like_count,
      post.comment_count,
      post.liked,
      likeClick: likeClick,
      commentClick: commentClick,
      shareClick: shareClick,
      post: post,
    ));
    int topCommentsCount =
        post.top_comments != null ? post.top_comments.length : 0;
    Color verticalDividerColor = topCommentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: list,
                    ),
                  ),
                ],
              ),
            ],
          ),
          (topCommentsCount > 0
              ? TopCommentsWidget(
                  post.top_comments,
                  post.comment_count,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class PollWidget extends StatefulWidget {
  // final int voter_count;
  // final List<Poll> votes;
  final Post post;

  // final bool voted;
  const PollWidget(this.post,
      /*this.voter_count, this.votes, this.voted,*/ {Key key})
      : super(key: key);

  @override
  _PollWidgetState createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  ValueNotifier<bool> votedNotifier;

  @override
  void initState() {
    super.initState();
    votedNotifier = ValueNotifier(widget.post.voted);
  }

  @override
  void dispose() {
    votedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: votedNotifier,
        builder: (context, voted, child) {
          List<Widget> list = List.empty(growable: true);

          for (int i = 0; i < widget.post.pollsCount(); i++) {
            Poll vote = widget.post.polls.elementAt(i);
            if (voted) {
              list.add(Padding(
                padding: const EdgeInsets.only(
                    top: InvestrendTheme.cardPaddingGeneral),
                child: polledWidget(context, vote, widget.post),
              ));
            } else {
              list.add(pollWidget(context, vote, widget.post));
            }
          }
          return Column(
            children: list,
          );
        });
  }

  void submitVote(BuildContext context, Poll poll, Post post) async {
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return LoadingBottomSheetSimple(
            'Voting for ' + poll.text,
          );
        });
    try {
      //SubmitVote submitResult = await SosMedHttp.sosmedVote('123',poll.id, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, language: EasyLocalization.of(context).locale.languageCode);
      SubmitVote submitResult = await InvestrendTheme.tradingHttp.sosmedVote(
          poll.id,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion,
          language: EasyLocalization.of(context).locale.languageCode);
      if (submitResult != null) {
        print('submitResult = ' + submitResult.toString());
        bool success =
            submitResult.status == 200 && submitResult?.result?.id >= 0;

        if (success) {
          poll.voteSuccess();
          //post.voter_count++;
          //post.generateKeyString();
          post.voteSuccess();
          votedNotifier.value = true;
          if (mounted) {
            context.read(sosmedFeedChangeNotifier).mustNotifyListener();
          }
        }
        if (mounted) {
          InvestrendTheme.of(context)
              .showSnackBar(context, submitResult.message);
        }
      }
    } catch (error) {
      print('voteClicked Exception like : ' + error.toString());
      print(error);
      if (mounted) {
        InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
    } finally {
      // Future.delayed(Duration(seconds: 2),(){
      Navigator.of(context).pop();
      // });
    }
  }

  Widget pollWidget(BuildContext context, Poll vote, Post post) {
    return Container(
      width: double.maxFinite,
      height: 37.0,
      margin: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          //visualDensity: VisualDensity.comfortable,
          //padding: EdgeInsets.all(0.0),
          primary: Theme.of(context).accentColor,
          minimumSize: Size(50.0, 40.0),
          side: BorderSide(color: Theme.of(context).accentColor, width: 1.0),
          backgroundColor: Theme.of(context).backgroundColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
        ),
        onPressed: () {
          submitVote(context, vote, post);
        },
        child: Text(
          vote.text,
          style: InvestrendTheme.of(context)
              .small_w400_compact
              .copyWith(color: Theme.of(context).accentColor),
        ),
      ),
    );
  }

  Widget polledWidget(BuildContext context, Poll vote, Post post) {
    // A value of 0.0 means no progress and 1.0 means that progress is complete.
    double progress = 0.0;
    if (vote.count > 0 && post.voter_count > 0) {
      progress = vote.count.toDouble() / post.voter_count.toDouble();
    }
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        color: Theme.of(context).accentColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            child: TweenAnimationBuilder<double>(
              curve: Curves.easeInOutQuint,
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(seconds: 1),
              builder: (BuildContext context, double size, Widget child) {
                //print('animation size : $size');
                return LinearProgressIndicator(
                  minHeight: 35.0,
                  value:
                      size, // A value of 0.0 means no progress and 1.0 means that progress is complete.
                  //valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFE4DFF4)),
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      InvestrendTheme.of(context).pollProgress),
                  //color: InvestrendTheme.of(context).tileBackground,
                  backgroundColor: InvestrendTheme.of(context).pollBackground,
                  //backgroundColor: Theme.of(context).backgroundColor,
                );
                /*
                return IconButton(
                  iconSize: size,
                  color: Colors.blue,
                  icon: child!,
                  onPressed: () {
                    setState(() {
                      targetValue = targetValue == 24.0 ? 48.0 : 24.0;
                    });
                  },
                );
                 */
              },
              //child: const Icon(Icons.aspect_ratio),
            ),
            /*
            child: LinearProgressIndicator(
              minHeight: 35.0,
              value: progress,  // A value of 0.0 means no progress and 1.0 means that progress is complete.
              //valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFE4DFF4)),
              valueColor: new AlwaysStoppedAnimation<Color>(InvestrendTheme.of(context).pollProgress),
              //color: InvestrendTheme.of(context).tileBackground,
              backgroundColor: InvestrendTheme.of(context).pollBackground,
              //backgroundColor: Theme.of(context).backgroundColor,
            ),
            */
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      vote.text,
                      style: InvestrendTheme.of(context)
                          .small_w400_compact
                          .copyWith(color: Theme.of(context).accentColor),
                    )),
                Text(vote.count.toString(),
                    style: InvestrendTheme.of(context)
                        .small_w400_compact
                        .copyWith(color: Theme.of(context).accentColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardSocialTextVote extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String username;
  final String label;
  final String datetime;
  final String text;
  final int commentCount;
  final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;
  final Votes votes;
  final List<CommentOld> comments;

  CardSocialTextVote(
      this.votes,
      this.avatarUrl,
      this.name,
      this.username,
      this.label,
      this.datetime,
      this.text,
      this.commentCount,
      this.likedCount,
      this.comments,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  final VoidCallback onShowMoreComment = () {};

  @override
  Widget build(BuildContext context) {
    String infoVotes =
        votes.totalVotes.toString() + ' votes • ' + votes.expires;

    List<Widget> list = List.empty(growable: true);
    list.add(Text(
      label,
      style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
          color: InvestrendTheme.of(context).greyDarkerTextColor,
          fontSize: 10.0),
    ));
    list.add(RichText(
      text: TextSpan(
        text: name + ' ',
        style: InvestrendTheme.of(context).small_w400,
        children: [
          TextSpan(
            text: username + ' ',
            style: InvestrendTheme.of(context).small_w400.copyWith(
                color: InvestrendTheme.of(context).greyLighterTextColor),
          ),
          TextSpan(
            text: '•',
            style: InvestrendTheme.of(context).small_w600,
          ),
          TextSpan(
            text: ' ' + datetime,
            style: InvestrendTheme.of(context)
                .more_support_w400_compact
                .copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
          ),
        ],
      ),
    ));
    list.add(SizedBox(
      height: 20.0,
    ));

    list.add(TapableWidget(
      onTap: onTap,
      child: Column(
        children: [
          Text(text,
              style: InvestrendTheme.of(context).small_w400.copyWith(
                  color: InvestrendTheme.of(context).greyDarkerTextColor)),
          SizedBox(
            height: 12.0,
          ),
          VoteWidget(votes, false)
        ],
      ),
    ));

    list.add(SizedBox(
      height: 12.0,
    ));
    list.add(Text(infoVotes,
        style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
            color: InvestrendTheme.of(context).greyLighterTextColor,
            fontSize: 11.0)));
    list.add(LikeCommentShareWidget(
      likedCount,
      commentCount,
      false,
      likeClick: likeClick,
      commentClick: commentClick,
      shareClick: shareClick,
    ));
    int commentsCount = comments != null ? comments.length : 0;
    Color verticalDividerColor = commentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: list,
                    ),
                  ),
                ],
              ),
            ],
          ),
          (commentsCount > 0
              ? CommentsWidgetOld(
                  comments,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class VoteWidget extends StatefulWidget {
  final Votes votes;
  final bool voted;

  const VoteWidget(this.votes, this.voted, {Key key}) : super(key: key);

  @override
  _VoteWidgetState createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  ValueNotifier<bool> votedNotifier;

  @override
  void initState() {
    super.initState();
    votedNotifier = ValueNotifier(widget.voted);
  }

  @override
  void dispose() {
    votedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: votedNotifier,
        builder: (context, voted, child) {
          List<Widget> list = List.empty(growable: true);

          for (int i = 0; i < widget.votes.voteMemberCount(); i++) {
            Vote vote = widget.votes.getVote(i);
            if (voted) {
              list.add(Padding(
                padding: const EdgeInsets.only(
                    top: InvestrendTheme.cardPaddingGeneral),
                child: votedWidget(context, vote),
              ));
            } else {
              list.add(voteWidget(context, vote));
            }
          }
          return Column(
            children: list,
          );
        });
  }

  Widget voteWidget(BuildContext context, Vote vote) {
    return Container(
      width: double.maxFinite,
      height: 37.0,
      margin: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          //visualDensity: VisualDensity.comfortable,
          //padding: EdgeInsets.all(0.0),
          primary: Theme.of(context).accentColor,
          minimumSize: Size(50.0, 40.0),
          side: BorderSide(color: Theme.of(context).accentColor, width: 1.0),
          backgroundColor: Theme.of(context).backgroundColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
        ),
        onPressed: () {
          votedNotifier.value = true;
        },
        child: Text(
          vote.code,
          style: InvestrendTheme.of(context)
              .small_w400_compact
              .copyWith(color: Theme.of(context).accentColor),
        ),
      ),
    );
  }

  Widget votedWidget(BuildContext context, Vote vote) {
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        color: Theme.of(context).accentColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            child: LinearProgressIndicator(
              minHeight: 35.0,
              value: vote.count.toDouble() / 100,
              valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFE4DFF4)),
              //color: InvestrendTheme.of(context).tileBackground,
              backgroundColor: InvestrendTheme.of(context).tileBackground,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      vote.code,
                      style: InvestrendTheme.of(context)
                          .small_w400_compact
                          .copyWith(color: Theme.of(context).accentColor),
                    )),
                Text(vote.count.toString(),
                    style: InvestrendTheme.of(context)
                        .small_w400_compact
                        .copyWith(color: Theme.of(context).accentColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardSocialTextImage extends StatelessWidget {
  final String imageUrl;
  final String avatarUrl;
  final String name;
  final String username;
  final String label;
  final String datetime;
  final String text;
  final int commentCount;
  final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;
  final List<CommentOld> comments;

  CardSocialTextImage(
      this.imageUrl,
      this.avatarUrl,
      this.name,
      this.username,
      this.label,
      this.datetime,
      this.text,
      this.commentCount,
      this.likedCount,
      this.comments,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  final VoidCallback onShowMoreComment = () {};

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  @override
  Widget build(BuildContext context) {
    int commentsCount = comments != null ? comments.length : 0;
    Color verticalDividerColor = commentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: username + ' ',
                                style: InvestrendTheme.of(context)
                                    .small_w400
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w600,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context)
                                    .more_support_w400_compact
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Column(
                            children: [
                              Text(text,
                                  style: InvestrendTheme.of(context)
                                      .small_w400
                                      .copyWith(
                                          color: InvestrendTheme.of(context)
                                              .greyDarkerTextColor)),
                              SizedBox(
                                height: 12.0,
                              ),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: AspectRatio(
                                      aspectRatio: 2 / 1,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.fitWidth,
                                      ))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          likedCount,
                          commentCount,
                          false,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (commentsCount > 0
              ? CommentsWidgetOld(
                  comments,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class CardSocialTextImages extends StatelessWidget {
  final List<String> imageUrls;
  final String avatarUrl;
  final String name;
  final String username;
  final String label;
  final String datetime;
  final String text;
  final int commentCount;
  final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;
  final List<CommentOld> comments;

  CardSocialTextImages(
      this.imageUrls,
      this.avatarUrl,
      this.name,
      this.username,
      this.label,
      this.datetime,
      this.text,
      this.commentCount,
      this.likedCount,
      this.comments,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  final VoidCallback onShowMoreComment = () {};

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imageUrls.length == 0) {
      imageWidget = SizedBox(
        width: 1.0,
      );
    } else if (imageUrls.length == 1) {
      imageWidget = AspectRatio(
        aspectRatio: 2 / 1,
        child:
            ComponentCreator.imageNetwork(imageUrls.first, fit: BoxFit.cover),
        // child: Image.network(
        //   imageUrls.first,
        //   fit: BoxFit.cover,
        // ),
      );
    } else if (imageUrls.length == 2) {
      imageWidget = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double widthTile = (constraints.maxWidth - 4.0) / 2;
          double height = width / 2;

          return Row(
            children: [
              SizedBox(
                width: widthTile,
                height: height,
                child: ComponentCreator.imageNetwork(imageUrls.first,
                    fit: BoxFit.cover),
                // child: Image.network(
                //   imageUrls.first,
                //   fit: BoxFit.cover,
                // ),
              ),
              SizedBox(
                width: 4.0,
              ),
              SizedBox(
                width: widthTile,
                height: height,
                child: ComponentCreator.imageNetwork(imageUrls.last,
                    fit: BoxFit.cover),
                // child: Image.network(
                //   imageUrls.last,
                //   fit: BoxFit.cover,
                // ),
              ),
            ],
          );
        },
      );
    } else {
      imageWidget = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double widthTile = (constraints.maxWidth - 4.0) / 2;
          double height = width / 2;
          double heightHalf = (height - 4.0) / 2;
          int more = imageUrls.length - 3;

          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: widthTile,
                    height: height,
                    child: ComponentCreator.imageNetwork(imageUrls.first,
                        fit: BoxFit.cover),
                    // child: Image.network(
                    //   imageUrls.first,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: widthTile,
                        height: heightHalf,
                        child: Image.network(
                          imageUrls.last,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      SizedBox(
                        width: widthTile,
                        height: heightHalf,
                        child: Image.network(
                          imageUrls.last,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              more > 0
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(14.0)),
                        color: Colors.white70,
                      ),
                      padding: EdgeInsets.all(14.0),
                      child: Text(
                        '+' + more.toString(),
                        style: InvestrendTheme.of(context)
                            .small_w600_compact
                            .copyWith(color: Theme.of(context).accentColor),
                      ))
                  : SizedBox(
                      width: 1.0,
                    ),
            ],
          );
        },
      );
    }
    int commentsCount = comments != null ? comments.length : 0;
    Color verticalDividerColor = commentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: username + ' ',
                                style: InvestrendTheme.of(context)
                                    .small_w400
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w600,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context)
                                    .more_support_w400_compact
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Column(
                            children: [
                              Text(text,
                                  style: InvestrendTheme.of(context)
                                      .small_w400
                                      .copyWith(
                                          color: InvestrendTheme.of(context)
                                              .greyDarkerTextColor)),
                              SizedBox(
                                height: 12.0,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
                                child: imageWidget,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          likedCount,
                          commentCount,
                          false,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (commentsCount > 0
              ? CommentsWidgetOld(
                  comments,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class NewCardSocialTextImages extends StatelessWidget {
  // final List<String> imageUrls;
  // final String avatarUrl;
  // final String name;
  // final String username;
  // final String label;
  // final String datetime;
  // final String text;
  // final int commentCount;
  // final int likedCount;
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final VoidCallback onTap;

  //final List<Comment> comments;
  final Post post;

  NewCardSocialTextImages(
      //this.imageUrls, this.avatarUrl, this.name, this.username, this.label, this.datetime, this.text, this.commentCount, this.likedCount,this.comments,
      this.post,
      {Key key,
      this.commentClick,
      this.likeClick,
      this.shareClick,
      this.onTap})
      : super(key: key);

  final VoidCallback onShowMoreComment = () {};

  // 48
  // more_support_w400_compact
  // small_w700_compact
  // 20.0
  // small_w400 * lines
  // 12.0
  // 14.0
  @override
  Widget build(BuildContext context) {
    //String avatarUrl = post.user.featured_attachment;
    String avatarUrl = post.user.thumbnail;
    final String name = post.user.name;
    final String username = post.user.username;
    //final String label = post.is_featured == 1 ? 'Featured' : (post.is_trending == 1 ? 'Trending' : 'not featured/trending');
    final String label = post?.is_featured == 1
        ? 'sosmed_label_featured'.tr()
        : (post.is_trending == 1
            ? 'sosmed_label_trending'.tr()
            : 'sosmed_label_not_freatured_not_trending'.tr());
    //final String datetime = post.created_at;
    final String datetime =
        Utils.displayPostDate(post?.created_at); //post?.created_at;
    final String text = post.text;

    Widget imageWidget;
    if (post.attachments.length == 0) {
      imageWidget = SizedBox(
        width: 1.0,
      );
    } else if (post.attachments.length == 1) {
      String url_image = post.attachments.first.attachment_list;
      imageWidget = AspectRatio(
        aspectRatio: 2 / 1,
        child: !StringUtils.isEmtpy(url_image)
            ? ComponentCreator.imageNetwork(url_image, fit: BoxFit.cover)
            : Container(
                child: EmptyLabel(text: 'no_image_label'.tr()),
              ),
        // child: Image.network(
        //   post.attachments.first.attachment_list,
        //   // post.attachments.first.attachment,
        //   fit: BoxFit.cover,
        // ),
      );
    } else if (post.attachments.length == 2) {
      imageWidget = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double widthTile = (constraints.maxWidth - 4.0) / 2;
          double height = width / 2;

          return Row(
            children: [
              SizedBox(
                width: widthTile,
                height: height,
                child: ComponentCreator.imageNetwork(
                    post.attachments.first.attachment_list,
                    fit: BoxFit.cover),
                // child: Image.network(
                //   post.attachments.first.attachment_list,
                //   // post.attachments.first.attachment,
                //   fit: BoxFit.cover,
                // ),
              ),
              SizedBox(
                width: 4.0,
              ),
              SizedBox(
                width: widthTile,
                height: height,
                child: ComponentCreator.imageNetwork(
                    post.attachments.last.attachment_list,
                    fit: BoxFit.cover),
                // child: Image.network(
                //   post.attachments.last.attachment_list,
                //   // post.attachments.last.attachment,
                //   fit: BoxFit.cover,
                // ),
              ),
            ],
          );
        },
      );
    } else {
      imageWidget = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth;
          double widthTile = (constraints.maxWidth - 4.0) / 2;
          double height = width / 2;
          double heightHalf = (height - 4.0) / 2;
          int more = post.attachments.length - 3;

          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: widthTile,
                    height: height,
                    child: ComponentCreator.imageNetwork(
                        post.attachments.first.attachment_list,
                        fit: BoxFit.cover),
                    // child: Image.network(
                    //   post.attachments.first.attachment_list,
                    //   // post.attachments.first.attachment,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: widthTile,
                        height: heightHalf,
                        child: ComponentCreator.imageNetwork(
                            post.attachments.elementAt(1).attachment_small,
                            fit: BoxFit.cover),
                        // child: Image.network(
                        //   post.attachments.elementAt(1).attachment_small,
                        //   // post.attachments.elementAt(1).attachment,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      SizedBox(
                        width: widthTile,
                        height: heightHalf,
                        child: ComponentCreator.imageNetwork(
                            post.attachments.elementAt(2).attachment_small,
                            fit: BoxFit.cover),
                        // child: Image.network(
                        //   post.attachments.elementAt(2).attachment_small,
                        //   // post.attachments.elementAt(2).attachment,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                    ],
                  )
                ],
              ),
              more > 0
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(14.0)),
                        color: Colors.white70,
                      ),
                      padding: EdgeInsets.all(14.0),
                      child: Text(
                        '+' + more.toString(),
                        style: InvestrendTheme.of(context)
                            .small_w600_compact
                            .copyWith(color: Theme.of(context).accentColor),
                      ))
                  : SizedBox(
                      width: 1.0,
                    ),
            ],
          );
        },
      );
    }
    int topCommentsCount =
        post.top_comments != null ? post.top_comments.length : 0;
    Color verticalDividerColor = topCommentsCount <= 0
        ? Colors.transparent
        : Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        top: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: VerticalDivider(
                        thickness: 0.5,
                        color: verticalDividerColor,
                      )),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AvatarIcon(
                  //   imageUrl: avatarUrl,
                  //   size: 48.0,
                  // ),
                  AvatarProfileButton(
                    url: avatarUrl,
                    fullname: name,
                    size: 48.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: 10.0),
                        ),
                        RichText(
                          text: TextSpan(
                            text: name + ' ',
                            style: InvestrendTheme.of(context).small_w400,
                            children: [
                              TextSpan(
                                text: username + ' ',
                                style: InvestrendTheme.of(context)
                                    .small_w400
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                              TextSpan(
                                text: '•',
                                style: InvestrendTheme.of(context).small_w600,
                              ),
                              TextSpan(
                                text: ' ' + datetime,
                                style: InvestrendTheme.of(context)
                                    .more_support_w400_compact
                                    .copyWith(
                                        color: InvestrendTheme.of(context)
                                            .greyLighterTextColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TapableWidget(
                          onTap: onTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text,
                                  style: InvestrendTheme.of(context)
                                      .small_w400
                                      .copyWith(
                                          color: InvestrendTheme.of(context)
                                              .greyDarkerTextColor)),
                              SizedBox(
                                height: 12.0,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
                                child: imageWidget,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        LikeCommentShareWidget(
                          post.like_count,
                          post.comment_count,
                          post.liked,
                          likeClick: likeClick,
                          commentClick: commentClick,
                          shareClick: shareClick,
                          post: post,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          (topCommentsCount > 0
              ? TopCommentsWidget(
                  post.top_comments,
                  post.comment_count,
                  onTap: onShowMoreComment,
                )
              : SizedBox(
                  width: 1.0,
                )),
        ],
      ),
    );
  }
}

class LikeCommentShareWidget extends StatelessWidget {
  final VoidCallback commentClick;
  final VoidCallback likeClick;
  final VoidCallback shareClick;
  final int likedCount;
  final int commentCount;
  final bool liked;
  final Post post;
  final PostComment comment;

  LikeCommentShareWidget(this.likedCount, this.commentCount, this.liked,
      {this.commentClick,
      this.likeClick,
      this.shareClick,
      Key key,
      this.post,
      this.comment})
      : super(key: key);

  BuildContext currentContext;

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return Row(
      children: [
        IconButton(
          icon: Image.asset(
            'images/icons/comment.png',
            height: 24.0,
            width: 24.0,
          ),
          onPressed: commentClick,
        ),
        Text(
          commentCount.toString(),
          style: InvestrendTheme.of(context).small_w400_compact.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
        /*
        IconButton(
          icon: Image.asset(
            'images/icons/like.png',
            height: 24.0,
            width: 24.0,
            color: liked ? Theme.of(context).accentColor : InvestrendTheme.of(context).greyLighterTextColor,
          ),
          onPressed: likeClick,
        ),
        Text(
          likedCount.toString(),
          style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
        */

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LikeButton(
            size: 24.0,
            isLiked: liked,
            likeCount: likedCount,
            onTap: onLikeButtonTapped,
            circleColor:
                //CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
                CircleColor(
                    start: Theme.of(context).accentColor.withOpacity(0.2),
                    end: Theme.of(context).accentColor.withOpacity(0.4)),
            bubblesColor: BubblesColor(
              dotPrimaryColor: Theme.of(context).accentColor.withOpacity(0.3),
              dotSecondaryColor: Theme.of(context).accentColor.withOpacity(0.6),
            ),
            likeBuilder: (bool isLiked) {
              return Image.asset(
                'images/icons/like.png',
                height: 24.0,
                width: 24.0,
                color: isLiked
                    ? Theme.of(context).accentColor
                    : InvestrendTheme.of(context).greyLighterTextColor,
              );
            },
            countBuilder: (int count, bool isLiked, String text) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  count.toString(),
                  style: InvestrendTheme.of(context)
                      .small_w400_compact
                      .copyWith(
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor),
                ),
              );
            },
          ),
        ),
        Spacer(
          flex: 1,
        ),
        IconButton(
          icon: Image.asset(
            'images/icons/share.png',
            height: 24.0,
            width: 24.0,
          ),
          onPressed: shareClick,
        ),
      ],
    );
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;
    //await Future.delayed(Duration(seconds: 1));

    //bool resultLiked = post.liked;
    try {
      String applicationPlatform = currentContext != null
          ? InvestrendTheme.of(currentContext).applicationPlatform
          : '-';
      String applicationVersion = currentContext != null
          ? InvestrendTheme.of(currentContext).applicationVersion
          : '-';
      String languageCode = currentContext != null
          ? EasyLocalization.of(currentContext).locale.languageCode
          : 'id';

      //SubmitLike submitResult = await SosMedHttp.sosmedLike(!post.liked ,'123',post.id, applicationPlatform, applicationVersion, language: languageCode);
      SubmitLike submitResult = await InvestrendTheme.tradingHttp.sosmedLike(
          !post.liked, post.id, applicationPlatform, applicationVersion,
          language: languageCode);
      if (submitResult != null) {
        print('submitResult = ' + submitResult.toString());
        bool success =
            submitResult.status == 200; // && submitResult?.result?.id >= 0;
        // if(mounted) {
        //   InvestrendTheme.of(context).showSnackBar(context, submitResult.message);
        // }
        if (success) {
          if (StringUtils.equalsIgnoreCase(
              submitResult.message, 'Like deleted!')) {
            post.likedUndoed();
          } else if (StringUtils.equalsIgnoreCase(
              submitResult.message, 'Like created!')) {
            post.likedSuccess();
          }
          //success? !isLiked:isLiked;
          //resultLiked = post.liked;

          // if(mounted){
          //   context.read(sosmedCommentChangeNotifier).mustNotifyListener();
          //   setState(() {
          //
          //   });
          // }
        }
        Future.delayed(Duration(milliseconds: 500), () {
          if (likeClick != null) {
            try {
              likeClick();
            } catch (e) {}
          }
        });
      }
    } catch (error) {
      print('likeClicked Exception like : ' + error.toString());
      print(error);
    } finally {
      // Future.delayed(Duration(seconds: 2),(){
      //Navigator.of(context).pop();
      //
    }
    return post.liked;
  }
}

class NewPredictionWidget extends StatelessWidget {
  final Post post;

  const NewPredictionWidget(this.post, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String infoVotes = post.voter_count.toString() +
        ' votes • ' +
        Utils.displayExpireDate(post.expired_at);
    //double upsidePercentage = ((post.target_price - post.start_price) / post.start_price) * 100;
    double upsidePercentage =
        Utils.calculatePercent(post.start_price, post.target_price);

    String timing = Utils.displayTimingDays(post.created_at, post.expired_at);
    // Votes votes = Votes(post.expires, prediction.totalVotes);
    // votes.addVote(Vote('agree_label'.tr(), prediction.countAgree));
    // votes.addVote(Vote('disagree_label'.tr(), prediction.countDisagree));
    TextStyle small400 = InvestrendTheme.of(context)
        .small_w400
        .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle reguler700 = InvestrendTheme.of(context)
        .regular_w600
        .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: InvestrendTheme.of(context).greyLighterTextColor,
            width: 0.5),
        borderRadius: BorderRadius.circular(14.0),
        //color: InvestrendTheme.of(context).greyLighterTextColor,
      ),
      padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0),
            child: Text(
              'emiten_label'.tr(),
              style: InvestrendTheme.of(context)
                  .more_support_w400_compact
                  .copyWith(
                      color: InvestrendTheme.of(context).greyLighterTextColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0),
            child: RichText(
                text: TextSpan(
                    text: post?.code + ' ',
                    style: reguler700,
                    children: [
                  TextSpan(
                    text: post?.stock_name,
                    style: small400,
                  ),
                ])),
          ),
          Container(
            color: Color(0xFFE6DEF6),
            margin: EdgeInsets.only(top: 8.0),
            padding:
                EdgeInsets.only(top: 8.0, bottom: 8.0, left: 14.0, right: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'target_price_label'.tr(),
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .greyLighterTextColor),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        InvestrendTheme.formatPrice(post?.target_price),
                        style: Theme.of(context).textTheme.headline4.copyWith(
                            fontWeight: FontWeight.w600,
                            color: InvestrendTheme.of(context)
                                .greyDarkerTextColor),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    minimumSize: Size(50.0, 36.0),
                    side: BorderSide(
                        color: Theme.of(context).accentColor, width: 1.0),
                    backgroundColor: Theme.of(context).accentColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  ),
                  onPressed: () {
                    Stock stock =
                        InvestrendTheme.storedData.findStock(post.code);
                    if (stock == null) {
                      print('buy clicked code : ' +
                          post.code +
                          ' aborted, not find stock on StockStorer');
                      return;
                    }

                    context.read(primaryStockChangeNotifier).setStock(stock);

                    bool hasAccount = context
                            .read(dataHolderChangeNotifier)
                            .user
                            .accountSize() >
                        0;
                    InvestrendTheme.pushScreenTrade(context, hasAccount,
                        type: OrderType.Buy,
                        initialPriceLot:
                            PriceLot(post?.target_price.toInt(), 0));
                    /*
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ScreenTrade(OrderType.Buy,initialPriceLot: PriceLot(post?.target_price.toInt(), 0),),
                          settings: RouteSettings(name: '/trade'),
                        ));
                    */
                  },
                  child: Text(
                    'button_buy'.tr(),
                    style: InvestrendTheme.of(context)
                        .small_w600_compact
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          labelValue(context, 'start_price_label'.tr(),
              InvestrendTheme.formatPrice(post?.start_price)),
          labelValue(
              context,
              'upside_label'.tr(),
              InvestrendTheme.formatPercent(upsidePercentage,
                  prefixPlus: true, sufixPercent: true)),
          labelValue(context, 'timing_label'.tr(), timing),
          Padding(
            padding: EdgeInsets.only(
                left: 14.0, right: 14.0, top: 12.0, bottom: 8.0),
            child: ComponentCreator.divider(context),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 14.0,
              right: 14.0,
            ),
            child: PollWidget(post /*.voter_count, post.polls, post.voted*/),
          ),
          Padding(
            padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 8.0),
            child: Text(infoVotes,
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor,
                    fontSize: 11.0)),
          )
        ],
      ),
    );
  }

  // "start_price_label": "Start Price",
  // "upside_label": "Upside",
  // "timing_label": "Timing",
  Widget labelValue(BuildContext context, String label, String value) {
    return Container(
      margin: EdgeInsets.only(top: 4.0),
      padding: EdgeInsets.only(left: 14.0, right: 14.0),
      height: 24.0,
      child: Row(
        children: [
          Text(
            label,
            style: InvestrendTheme.of(context).small_w400_compact.copyWith(
                color: InvestrendTheme.of(context).greyLighterTextColor),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: InvestrendTheme.of(context).small_w400_compact,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class PredictionWidget extends StatelessWidget {
  final Prediction prediction;

  const PredictionWidget(this.prediction, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String infoVotes =
        prediction.totalVotes.toString() + ' votes • ' + prediction.expires;
    Votes votes = Votes(prediction.expires, prediction.totalVotes);
    votes.addVote(Vote('agree_label'.tr(), prediction.countAgree));
    votes.addVote(Vote('disagree_label'.tr(), prediction.countDisagree));
    TextStyle small400 = InvestrendTheme.of(context)
        .small_w400
        .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle reguler700 = InvestrendTheme.of(context)
        .regular_w600
        .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: InvestrendTheme.of(context).greyLighterTextColor,
            width: 0.5),
        borderRadius: BorderRadius.circular(14.0),
        //color: InvestrendTheme.of(context).greyLighterTextColor,
      ),
      padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0),
            child: Text(
              'emiten_label'.tr(),
              style: InvestrendTheme.of(context)
                  .more_support_w400_compact
                  .copyWith(
                      color: InvestrendTheme.of(context).greyLighterTextColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0),
            child: RichText(
                text: TextSpan(
                    text: prediction.code + ' ',
                    style: reguler700,
                    children: [
                  TextSpan(
                    text: prediction.name,
                    style: small400,
                  ),
                ])),
          ),
          Container(
            color: Color(0xFFE6DEF6),
            margin: EdgeInsets.only(top: 8.0),
            padding:
                EdgeInsets.only(top: 8.0, bottom: 8.0, left: 14.0, right: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'target_price_label'.tr(),
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .greyLighterTextColor),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        InvestrendTheme.formatPrice(prediction.targetPrice),
                        style: Theme.of(context).textTheme.headline4.copyWith(
                            fontWeight: FontWeight.w600,
                            color: InvestrendTheme.of(context)
                                .greyDarkerTextColor),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    primary: Theme.of(context).accentColor,
                    minimumSize: Size(50.0, 36.0),
                    side: BorderSide(
                        color: Theme.of(context).accentColor, width: 1.0),
                    backgroundColor: Theme.of(context).accentColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  ),
                  onPressed: () {},
                  child: Text(
                    'button_buy'.tr(),
                    style: InvestrendTheme.of(context)
                        .small_w600_compact
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          labelValue(context, 'start_price_label'.tr(),
              InvestrendTheme.formatPrice(prediction.startPrice)),
          labelValue(
              context,
              'upside_label'.tr(),
              InvestrendTheme.formatPercent(prediction.upsidePercentage,
                  prefixPlus: true, sufixPercent: true)),
          labelValue(context, 'timing_label'.tr(), prediction.timing),
          Padding(
            padding:
                EdgeInsets.only(left: 14.0, right: 14.0, top: 4.0, bottom: 8.0),
            child: ComponentCreator.divider(context),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 14.0,
              right: 14.0,
            ),
            child: VoteWidget(votes, false),
          ),
          Padding(
            padding: EdgeInsets.only(left: 14.0, right: 14.0, top: 8.0),
            child: Text(infoVotes,
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor,
                    fontSize: 11.0)),
          )
        ],
      ),
    );
  }

  // "start_price_label": "Start Price",
  // "upside_label": "Upside",
  // "timing_label": "Timing",
  Widget labelValue(BuildContext context, String label, String value) {
    return Container(
      margin: EdgeInsets.only(top: 4.0),
      padding: EdgeInsets.only(left: 14.0, right: 14.0),
      height: 24.0,
      child: Row(
        children: [
          Text(
            label,
            style: InvestrendTheme.of(context).small_w400_compact.copyWith(
                color: InvestrendTheme.of(context).greyLighterTextColor),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: InvestrendTheme.of(context).small_w400_compact,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
