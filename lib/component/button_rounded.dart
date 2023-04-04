import 'package:Investrend/component/bottom_sheet/bottom_sheet_select_stocks.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';

import 'package:Investrend/screens/tab_portfolio/component/bottom_sheet_list.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ButtonRounded extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonRounded(this.text, this.onPressed, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        elevation: 0.0,
        //padding: EdgeInsets.only(left: 5.0, right: 5.0),
        //visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: InvestrendTheme.of(context).tileBackground,
        child: Text(
          text,
          style: InvestrendTheme.of(context)
              .more_support_w400_compact
              .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
        ),
        onPressed: onPressed);
  }
}

class ButtonDateRounded extends StatelessWidget {
  final ValueNotifier<String> notifier;
  DateFormat dateFormat;

  ButtonDateRounded(this.notifier, {Key key, this.dateFormat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        elevation: 0.0,
        //padding: EdgeInsets.only(left: 5.0, right: 5.0),
        //visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: InvestrendTheme.of(context).tileBackground,
        child: ValueListenableBuilder(
          valueListenable: notifier,
          builder: (context, value, child) {
            return Text(
              value,
              style: InvestrendTheme.of(context)
                  .more_support_w400_compact
                  .copyWith(
                      color: InvestrendTheme.of(context).greyDarkerTextColor),
            );
          },
        ),
        onPressed: () {
          showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().add(Duration(days: -365)),
                  lastDate: DateTime.now())
              .then((value) {
            if (dateFormat == null) {
              dateFormat = DateFormat('dd/MM/yyyy');
            }
            notifier.value = dateFormat.format(value);
          });
        });
  }
}

class TextButtonDropdown extends StatelessWidget {
  final ValueNotifier<int> notifier;
  final List<String> list;
  final bool clickAndClose;
  final TextStyle style;
  const TextButtonDropdown(this.notifier, this.list,
      {this.style, this.clickAndClose = false, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, index, child) {
        String activeCA = list.elementAt(index);

        double paddingVertical = 8.0;

        return TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral,
                    top: paddingVertical,
                    bottom: paddingVertical),
                //minimumSize: Size(50, 30),
                alignment: Alignment.centerLeft),
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0)),
                  ),
                  //backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return ListBottomSheet(
                      notifier,
                      list,
                      clickAndClose: clickAndClose,
                    );
                  });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  activeCA,
                  style: this.style ?? Theme.of(context).textTheme.button,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Image.asset(
                  'images/icons/arrow_down.png',
                  width: 6.0,
                  height: 6.0,
                ),
              ],
            ));
      },
    );
  }
}

class ButtonDropdown extends StatelessWidget {
  final ValueNotifier<int> notifier;
  final List<String> list;
  final String staticText;
  final bool clickAndClose;
  final bool showEmojiDescendingAscending;

  const ButtonDropdown(
    this.notifier,
    this.list, {
    this.staticText,
    this.clickAndClose = false,
    this.showEmojiDescendingAscending = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (staticText != null) {
      return _createButton(context, staticText);
    }
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, index, child) {
        String activeCA = list.elementAt(index);

        return _createButton(context, activeCA);
      },
    );
  }

  Widget _createButton(BuildContext context, String label) {
    Widget textWidget;
    TextStyle style = InvestrendTheme.of(context)
        .more_support_w400_compact
        .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    if (showEmojiDescendingAscending) {
      if (label.endsWith(TAG_DESC)) {
        textWidget = Text.rich(
          TextSpan(
              text: label.replaceFirst(TAG_DESC, ''),
              style: style,
              children: [
                TextSpan(
                    text: '▼',
                    style: style.copyWith(color: InvestrendTheme.greenText)),
              ]),
          textAlign: TextAlign.center,
        );
      } else if (label.endsWith(TAG_ASC)) {
        textWidget = Text.rich(
            TextSpan(
                text: label.replaceFirst(TAG_ASC, ''),
                style: style,
                children: [
                  TextSpan(
                      text: '▲',
                      style: style.copyWith(color: InvestrendTheme.redText)),
                ]),
            textAlign: TextAlign.center);
      } else {
        textWidget = Text(
          label,
          style:
              style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
          textAlign: TextAlign.center,
        );
      }
    } else {
      textWidget = Text(
        label,
        style:
            style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
        textAlign: TextAlign.center,
      );
    }

    return MaterialButton(
        elevation: 0.0,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //height: 40.0,
        //padding: EdgeInsets.all(0.0),
        //visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: InvestrendTheme.of(context).tileBackground,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textWidget,
            /*
            Text(text,
                style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor)),
            */
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Image.asset(
                'images/icons/arrow_down.png',
                width: 10.0,
                height: 10.0,
              ),
            ),
            // Icon(
            //   Icons.arrow_drop_down,
            //   size: 15.0,
            //   color: Colors.grey,
            // ),
          ],
        ),
        onPressed: () {
          //InvestrendTheme.of(context).showSnackBar(context, 'Action choose Market');

          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              //backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return ListBottomSheet(
                  notifier,
                  list,
                  clickAndClose: clickAndClose,
                  showEmojiDescendingAscending: showEmojiDescendingAscending,
                );
              });
        });
  }
}

class ButtonSelectionFilter extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onPressed;

  const ButtonSelectionFilter(this.text, this.selected, this.onPressed,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //const colorSoft = Color(0xFFF5F0FF);
    TextStyle style = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    //Color colorBackground = selected ? colorSoft : Colors.transparent;
    Color colorBackground =
        selected ? InvestrendTheme.of(context).colorSoft : Colors.transparent;
    Color colorBorder =
        selected ? Theme.of(context).colorScheme.secondary : Colors.transparent;
    Color colorText =
        selected ? Theme.of(context).colorScheme.secondary : style.color;
    return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBackground //Colors.transparent
                : colorBackground; //Colors.transparent;
            return colors;
          }),
          padding: MaterialStateProperty.all(
              EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: BorderSide(color: Colors.red)
          )),
          side: MaterialStateProperty.resolveWith<BorderSide>(
              (Set<MaterialState> states) {
            final Color colors = states.contains(MaterialState.pressed)
                ? colorBorder //Theme.of(context).accentColor
                : colorBorder; //Theme.of(context).accentColor;
            return BorderSide(color: colors, width: 1.0);
          }),
        ),
        child: Text(
          text,
          style: style.copyWith(color: colorText),
        ),
        onPressed: onPressed);
  }
}

/*
class ButtonDropdownHelp extends StatelessWidget {
  final ValueNotifier <int> notifier;
  final List<HelpMenu> list;

  const ButtonDropdownHelp(this.notifier, this.list, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, index, child) {
        HelpMenu menu = list.elementAt(index);
        String active = menu.getMenu(language: EasyLocalization.of(context).locale.languageCode);
        return MaterialButton(
            elevation: 0.0,
            //padding: EdgeInsets.only(left: 5.0, right: 5.0),
            //visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            color: InvestrendTheme.of(context).tileBackground,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  active,
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Image.asset('images/icons/arrow_down.png',width: 10.0, height: 10.0,),
                ),
                // Icon(
                //   Icons.arrow_drop_down,
                //   size: 15.0,
                //   color: Colors.grey,
                // ),
              ],
            ),
            onPressed: () {
              //InvestrendTheme.of(context).showSnackBar(context, 'Action choose Market');

              showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                  ),
                  //backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return ListBottomSheet(notifier, list);
                  });
            });
      },
    );
  }
}
*/
class ButtonDropdownStock extends ConsumerWidget {
  //final ValueNotifier <int> notifier;

  const ButtonDropdownStock(/*this.notifier,*/ {Key key}) : super(key: key);

  Widget build(BuildContext context, ScopedReader watch) {
    final notifier = watch(primaryStockChangeNotifier);
    String code;
    if (notifier.stock != null) {
      code = notifier.stock.code;
    } else {
      code = 'select_label'.tr();
    }
    return MaterialButton(
        elevation: 0.0,
        //padding: EdgeInsets.only(left: 5.0, right: 5.0),
        //visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: InvestrendTheme.of(context).tileBackground,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              code,
              style: InvestrendTheme.of(context).small_w600_compact.copyWith(
                  color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Image.asset(
                'images/icons/arrow_down.png',
                width: 10.0,
                height: 10.0,
              ),
            ),
            // Icon(
            //   Icons.arrow_drop_down,
            //   size: 15.0,
            //   color: Colors.grey,
            // ),
          ],
        ),
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              //backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return BottomSheetSelectStock();
              });
        });
  }
}
