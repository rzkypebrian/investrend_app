import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:easy_localization/easy_localization.dart';

enum TagText {
  Paragraph,
  BoldItalic,
  Bold, /* BoldUnderline, Underline, Italic, Tab */
}

// New, Open, Partial, Withdraw, Match, Reject
extension TagTextExtension on TagText {
  String get tagStart {
    switch (this) {
      case TagText.Paragraph:
        return '<p>';
      case TagText.Bold:
        return '<b>';
      case TagText.BoldItalic:
        return '<b><i>';
      // case TagText.BoldUnderline:
      //   return '<BU>';
      // case TagText.Underline:
      //   return '<U>';
      // case TagText.Italic:
      //   return '<I>';
      // case TagText.Tab:
      //   return '<T>';
      default:
        return '#unknown_type';
    }
  }

  String get tagEnd {
    switch (this) {
      case TagText.Paragraph:
        return '</p>';
      case TagText.Bold:
        return '</b>';
      case TagText.BoldItalic:
        return '</i></b>';
      // case TagText.BoldUnderline:
      //   return '</BU>';
      // case TagText.Underline:
      //   return '</U>';
      // case TagText.Italic:
      //   return '</I>';
      // case TagText.Tab:
      //   return '';
      default:
        return '#unknown_type';
    }
  }
}

class ScreenContent extends StatelessWidget {
  final String title;
  final String content;

  const ScreenContent({this.title = '', this.content = '', Key key}) : super(key: key);

  final String TAG_BOLD_START = '<B>';
  final String TAG_BOLD_END = '</B>';

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
        title: AppBarTitleText(title),
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
  }

  List<String> parseText(String text) {
    List<String> list = List.empty(growable: true);
    if (StringUtils.isEmtpy(text)) {
      return list;
    }
    //text = text.replaceAll(from, replace)
    text = text.replaceAll('<br/>', '\n');

    int offset = 0;
    int index = content.indexOf(TagText.Paragraph.tagStart, offset);

    while (index != -1) {
      // String cutted = content.substring(offset, index);
      // if(!StringUtils.isEmtpy(cutted)){
      //   list.add(cutted);
      // }
      int indexBoldEnd = content.indexOf(TagText.Paragraph.tagEnd, index + TagText.Paragraph.tagStart.length);

      String paragraph = content.substring(index + TagText.Paragraph.tagStart.length, indexBoldEnd);
      if (!StringUtils.isEmtpy(paragraph)) {
        list.add(paragraph);
      }
      offset = indexBoldEnd + TagText.Paragraph.tagEnd.length;
      index = content.indexOf(TagText.Paragraph.tagStart, offset);
    }

    list.forEach((element) {});

    return list;
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    if (paddingBottom == 0) {
      paddingBottom = InvestrendTheme.cardPaddingVertical;
    }
    /*
    List<InlineSpan> list = List.empty(growable: true);
    int offset = 0;
    int indexBold = content.indexOf(TAG_BOLD_START, offset);

    while (indexBold != -1) {
      String cutted = content.substring(offset, indexBold);
      if (!StringUtils.isEmtpy(cutted)) {
        list.add(TextSpan(
          text: cutted,
          style: InvestrendTheme.of(context).small_w400_greyDarker,
        ));
      }

      int indexBoldEnd = content.indexOf(TAG_BOLD_END, indexBold + TAG_BOLD_START.length);
      String bold = content.substring(indexBold + TAG_BOLD_START.length, indexBoldEnd);
      if (!StringUtils.isEmtpy(bold)) {
        list.add(TextSpan(
          text: bold,
          style: InvestrendTheme.of(context).small_w600_greyDarker,
        ));
      }
      offset = indexBoldEnd + TAG_BOLD_END.length;
      indexBold = content.indexOf(TAG_BOLD_START, offset);
    }
    if (offset < content.length) {
      String cutted = content.substring(offset, content.length);
      if (!StringUtils.isEmtpy(cutted)) {
        list.add(TextSpan(
          text: cutted,
          style: InvestrendTheme.of(context).small_w400_greyDarker,
        ));
      }
    }
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral,
            top: InvestrendTheme.cardPaddingVertical,
            bottom: paddingBottom),
        //child: Text(content, style: InvestrendTheme.of(context).small_w400_greyDarker,),
        child: Text.rich(TextSpan(
          children: list,
        )),
      ),
    );
    */

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral,
            top: InvestrendTheme.cardPaddingVertical,
            bottom: paddingBottom),
        //child: Text(content, style: InvestrendTheme.of(context).small_w400_greyDarker,),
        child: Html(data: 'disclaimers_all_content'.tr(),),
      ),
    );


  }
}
