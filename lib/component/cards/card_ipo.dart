//import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_object.dart';

//import 'package:Investrend/objects/class_value_notifier.dart';
//import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/help/screen_help.dart';
import 'package:Investrend/screens/screen_eipo.dart';

//import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardEIPO extends StatelessWidget {
  //final List<HomeEIPO> listEIPO;
  final String? title;
  final VoidCallback? onRetry;

  const CardEIPO(this.title, /*this.listEIPO,*/ {this.onRetry, Key? key})
      : super(key: key);

  void showHelpEIPO(BuildContext context) {
    int defaultMenuIndex = 0;
    if (context.read(helpNotifier).data!.loaded) {
      int? count = context.read(helpNotifier).data?.countMenus();
      for (int i = 0; i < count!; i++) {
        HelpMenu? menu = context.read(helpNotifier).data?.menus?.elementAt(i);
        if (menu != null) {
          if (StringUtils.equalsIgnoreCase(menu.id!, '6')) {
            // id 6 --> E-IPO
            defaultMenuIndex = i;
            break;
          }
        }
      }
    }
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ScreenHelp(
            defaultMenuIndex: defaultMenuIndex,
          ),
          settings: RouteSettings(name: '/help'),
        ));
  }

  @override
  Widget build(BuildContext context) {
    ///double width = MediaQuery.of(context).size.width;
    //double tileWidth = width * 0.7;

    return Consumer(builder: (context, watch, child) {
      final EIPONotifier? notifier = watch(eipoNotifier);

      Widget? noWidget = notifier?.currentState.getNoWidget(onRetry: onRetry!);
      if (noWidget != null) {
        if (notifier!.currentState.isNoData()) {
          return SizedBox(
            width: 1,
          );
        }
        return Center(
          child: noWidget,
        );
      }

      return Container(
        margin:
            const EdgeInsets.only(bottom: InvestrendTheme.cardPaddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  /*right: InvestrendTheme.cardPaddingGeneral,*/ bottom:
                      InvestrendTheme.cardPadding),
              child: ComponentCreator.subtitleButtonMore(
                  context, title!, () => showHelpEIPO(context),
                  image: '', textButton: 'eipo_learn_button'.tr()),
            ),
            LayoutBuilder(builder: (context, constrains) {
              print('constrains ' + constrains.maxWidth.toString());
              double tileWidth = constrains.maxWidth * 0.7;
              //double height = 180.0;
              double height = tileWidth * 0.5;

              return SizedBox(
                  height: height,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: notifier?.count(),
                    itemBuilder: (BuildContext context, int index) {
                      //double left = index == 0 ? InvestrendTheme.cardPaddingPlusMargin : 0.0;
                      bool isFirst = index == 0;
                      bool isLast = index == notifier!.list!.length - 1;
                      return tileEIPO(context, notifier.list!.elementAt(index),
                          isFirst, isLast, tileWidth, height);
                    },
                  ));
            }),
          ],
        ),
      );
    });
    /*
    return Container(
      margin:
          const EdgeInsets.only(bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                /*right: InvestrendTheme.cardPaddingGeneral,*/ bottom:
                    InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitleButtonMore(
                context, title!, () => showHelpEIPO(context),
                image: '', textButton: 'eipo_learn_button'.tr()),
          ),
          LayoutBuilder(builder: (context, constrains) {
            print('constrains ' + constrains.maxWidth.toString());
            double tileWidth = constrains.maxWidth * 0.7;
            //double height = 180.0;
            double height = tileWidth * 0.5;

            return SizedBox(
                height: height,
                child: Consumer(builder: (context, watch, child) {
                  final notifier = watch(eipoNotifier);

                  Widget noWidget =
                      notifier.currentState.getNoWidget(onRetry: onRetry!);
                  if (noWidget != null) {
                    return Center(
                      child: noWidget,
                    );
                  }

                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: notifier.count(),
                    itemBuilder: (BuildContext context, int index) {
                      //double left = index == 0 ? InvestrendTheme.cardPaddingPlusMargin : 0.0;
                      bool isFirst = index == 0;
                      bool isLast = index == notifier.list!.length - 1;
                      return tileEIPO(context, notifier.list!.elementAt(index),
                          isFirst, isLast, tileWidth, height);
                    },
                  );
                }));
          }),
        ],
      ),
    );
  */
  }

  Widget buildOld(BuildContext context) {
    ///double width = MediaQuery.of(context).size.width;
    //double tileWidth = width * 0.7;

    return Container(
      margin:
          const EdgeInsets.only(bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ComponentCreator.subtitleButtonMore(context, title, () {
          //   InvestrendTheme.of(context).showSnackBar(context, "Action Competition More");
          // }),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                /*right: InvestrendTheme.cardPaddingGeneral,*/ bottom:
                    InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitleButtonMore(
                context, title!, () => showHelpEIPO(context),
                image: '', textButton: 'eipo_learn_button'.tr()),
            /*
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ComponentCreator.subtitle(context, title),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'eipo_learn_button'.tr(),
                    //style: TextStyle(fontSize: 13.0, color: textColor, fontWeight: FontWeight.bold),
                    style: InvestrendTheme.of(context).small_w700_compact.copyWith(color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
            */
          ),
          // SizedBox(
          //   height: InvestrendTheme.cardPadding,
          // ),
          LayoutBuilder(builder: (context, constrains) {
            print('constrains ' + constrains.maxWidth.toString());
            double tileWidth = constrains.maxWidth * 0.7;
            //double height = 180.0;
            double height = tileWidth * 0.5;

            return SizedBox(
                height: height,
                child: Consumer(builder: (context, watch, child) {
                  final EIPONotifier? notifier = watch(eipoNotifier);

                  Widget? noWidget =
                      notifier?.currentState.getNoWidget(onRetry: onRetry!);
                  if (noWidget != null) {
                    return Center(
                      child: noWidget,
                    );
                  }
                  // if (notifier.stock.invalid()) {
                  //   return Center(child: CircularProgressIndicator());
                  // }
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: notifier?.count(),
                    itemBuilder: (BuildContext context, int index) {
                      //double left = index == 0 ? InvestrendTheme.cardPaddingPlusMargin : 0.0;
                      bool isFirst = index == 0;
                      bool isLast = index == notifier!.list!.length - 1;
                      return tileEIPO(context, notifier.list!.elementAt(index),
                          isFirst, isLast, tileWidth, height);
                    },
                  );
                }));
          }),
        ],
      ),
    );
  }

  Widget tileEIPO(BuildContext context, ListEIPO ipo, bool isFirst, bool isLast,
      double width, double height) {
    double left;
    double right;
    if (isFirst) {
      left = InvestrendTheme.cardPaddingGeneral;
    } else {
      left = InvestrendTheme.cardMargin;
    }
    if (isLast) {
      right = InvestrendTheme.cardPaddingGeneral;
    } else {
      right = 0.0;
    }

    //double right = isLast ? InvestrendTheme.cardPaddingPlusMargin : InvestrendTheme.cardMargin;

    return Container(
      width: width,
      margin: EdgeInsets.only(left: left, right: right),
      child: MaterialButton(
        //clipBehavior: Clip.antiAlias,
        elevation: 0.0,
        minWidth: 50.0,
        highlightElevation: 0.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        //padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 12.0),
        padding: EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StringUtils.isEmtpy(ipo.company_icon!)
                ? SizedBox(
                    width: 24.0,
                    height: 24.0,
                  )
                : ComponentCreator.imageNetworkCached(ipo.company_icon!,
                    width: 24.0,
                    height: 24.0,
                    errorWidget: SizedBox(
                      width: 24.0,
                      height: 24.0,
                    )),
            SizedBox(
              //width: 12.0,
              width: InvestrendTheme.cardPaddingGeneral,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(
                  //   height: 5.0,
                  // ),
                  Flexible(
                    child: AutoSizeText(
                      ipo.name!,
                      minFontSize: 8.0,
                      style: InvestrendTheme.of(context)
                          .small_w500
                          ?.copyWith(height: 1.27),
                      maxLines: 2,
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  AutoSizeText(
                    'card_eipo_offering_ends'.tr(),
                    minFontSize: 8.0,
                    style: InvestrendTheme.of(context)
                        .more_support_w400
                        ?.copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor),
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  AutoSizeText(
                    ipo.offering_date_end!,
                    minFontSize: 8.0,
                    style: InvestrendTheme.of(context).more_support_w400,
                    maxLines: 1,
                  ),
                  // Spacer(
                  //   flex: 1,
                  // ),
                ],
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ScreenEIPO(ipo),
                settings: RouteSettings(name: '/e-ipo'),
              ));
        },
      ),
    );
  }
}
