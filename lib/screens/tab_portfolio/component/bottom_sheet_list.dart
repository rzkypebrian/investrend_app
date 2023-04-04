import 'dart:math';

import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

const String TAG_DESC = '#DESC#';
const String TAG_ASC = '#ASC#';
class ListBottomSheet extends StatelessWidget {
  final ValueNotifier rangeNotifier;
  final List<String> range_options;
  final bool clickAndClose;
  final bool showEmojiDescendingAscending;
  final String information;
  final String title;
  const ListBottomSheet(this.rangeNotifier, this.range_options, {this.title, this.information, this.clickAndClose = false, this.showEmojiDescendingAscending = false, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + (44.0 * range_options.length) + padding;

    if(information != null){
      contentHeight += 30 * 2; // max 2 lines
    }

    //if (contentHeight > minHeight) {
    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);
    //}

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          //mainAxisSize: MainAxisSize.max,
          children: [

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  //icon: Icon(Icons.clear),
                  icon: Image.asset(
                    'images/icons/action_clear.png',
                    color: InvestrendTheme.of(context).greyLighterTextColor,
                    width: 12.0,
                    height: 12.0,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
            Expanded(
              flex: 1,
              child: ValueListenableBuilder(
                valueListenable: rangeNotifier,
                builder: (context, selectedIndex, child) {
                  List<Widget> list = List.empty(growable: true);

                  int count = range_options.length;
                  for (int i = 0; i < count; i++) {
                    String ca = range_options.elementAt(i);
                    list.add(createRow(context, ca, selectedIndex == i, i));
                  }
                  if(information != null){
                    list.add(Padding(
                      padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding),
                      child: AutoSizeText(information, maxLines: 3, softWrap: true,style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),textAlign: TextAlign.center,),
                    ));
                  }

                  return ListView(
                    children: list,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      /*
      child: Container(
        padding: EdgeInsets.all(padding),
        // color: Colors.yellow,
        width: double.maxFinite,
        child: ValueListenableBuilder(
          valueListenable: rangeNotifier,
          builder: (context, selectedIndex, child) {
            List<Widget> list = List.empty(growable: true);
            list.add(Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(Icons.clear),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ));
            int count = range_options.length;
            for (int i = 0; i < count; i++) {
              String ca = range_options.elementAt(i);
              list.add(createRow(context, ca, selectedIndex == i, i));
            }
            return ListView(
              children: list,
            );
          },
        ),
      ),
      */
    );
  }



  Widget createRow(BuildContext context, String label, bool selected, int index) {
    TextStyle style = InvestrendTheme.of(context).regular_w400_compact;
    //Color colorText = style.color;
    Color colorIcon = Colors.transparent;

    if (selected) {
      style = InvestrendTheme.of(context).regular_w600_compact.copyWith(color: Theme.of(context).accentColor);
      //colorText = Theme.of(context).accentColor;
      colorIcon = Theme.of(context).accentColor;
    }

    Widget textWidget;
    if (showEmojiDescendingAscending) {
      if (label.endsWith(TAG_DESC)) {
        textWidget = Text.rich(TextSpan(text: label.replaceFirst(TAG_DESC, ''), style: style, children: [
          TextSpan(text: '▼', style: style.copyWith(color: InvestrendTheme.greenText)),
        ]), textAlign: TextAlign.center,);
      } else if (label.endsWith(TAG_ASC)) {
        textWidget = Text.rich(TextSpan(text: label.replaceFirst(TAG_ASC, ''), style: style, children: [
          TextSpan(text: '▲', style: style.copyWith(color: InvestrendTheme.redText)),
        ]), textAlign: TextAlign.center);
      } else {
        textWidget = Text(
          label,
          style: style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
          textAlign: TextAlign.center,
        );
      }
    } else {
      textWidget = Text(
        label,
        style: style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
        textAlign: TextAlign.center,
      );
    }

    return SizedBox(
      height: 44.0,
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.0,
              height: 20.0,
            ),
            Expanded(flex: 1, child: textWidget),
            (selected
                ? Image.asset(
                    'images/icons/check.png',
                    color: colorIcon,
                    width: 20.0,
                    height: 20.0,
                  )
                : SizedBox(
                    width: 20.0,
                    height: 20.0,
                  )),
          ],
        ),
        onPressed: () {
          // setState(() {
          //   selectedIndex = index;
          // });
          //context.read(marketChangeNotifier).setIndex(index);
          rangeNotifier.value = index;
          if (clickAndClose) {
            // Future.delayed(Duration(milliseconds: 300),(){
            //Navigator.pop(context);
            Navigator.pop(context,index);
            // });

          }
        },
      ),
    );
  }
}
