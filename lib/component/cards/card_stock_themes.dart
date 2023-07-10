import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/screens/screen_themes_detail.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CardStockThemes extends StatelessWidget {
  final String title;
  final StockThemeNotifier notifier;
  final List<int> pattern = [0, 1, 1, 1, 0];
  final VoidCallback onRetry;
  CardStockThemes(this.title, this.notifier, {Key key, this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    if (!StringUtils.isEmtpy(title)) {
      //list.add(SizedBox(height: InvestrendTheme.cardPaddingGeneral));
      list.add(ComponentCreator.subtitleNoButtonMore(
        context,
        title,
      ));
      // list.add(SizedBox(height: InvestrendTheme.cardPadding));
    }
    list.add(ValueListenableBuilder(
      valueListenable: this.notifier,
      builder: (context, StockThemesData data, child) {
        /*
        if(this.notifier.currentState.notFinished()){
          if (this.notifier.currentState.isError()) {
            return Center(child: TextButtonRetry(
              onPressed: onRetry,
            ));
          } else if (this.notifier.currentState.isLoading()) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (this.notifier.currentState.isNoData()) {
            return Center(
              child: EmptyLabel(),
            );
          }
        }
        */
        Widget noWidget =
            this.notifier.currentState.getNoWidget(onRetry: onRetry);
        if (noWidget != null) {
          return Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
            child: Center(
              child: noWidget,
            ),
          );
        }

        // if (notifier.invalid()) {
        //   return Center(child: CircularProgressIndicator());
        // }

        return gridThemes(context, data);
        /*
        return Column(
          children: List<Widget>.generate(
            data.count(),
                (int index) {
              GeneralPrice gp = data.datas.elementAt(index);
              return RowGeneralPrice(gp.code, gp.price, gp.change, gp.percent, gp.priceColor, name: gp.name, firstRow: (index == 0),);

            },
          ),
        );
        */
      },
    ));

    return Container(
      margin: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
        /*
        children: [
          ComponentCreator.subtitleButtonMore(
            context,
            'home_card_themes_title'.tr(),
            () {
              InvestrendTheme.of(context).showSnackBar(context, "Action Themes More");
            },
          ),
          gridThemes(context),
        ],
        */
      ),
    );
  }

  Widget gridThemes(BuildContext context, StockThemesData data) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 2;
      double availableWidth = constrains.maxWidth - InvestrendTheme.cardMargin;
      double tileWidth = availableWidth / gridCount;
      double height1 = tileWidth * 1.28;
      double height2 = tileWidth * 1.5;

      if (data.count() == 0) {
        return Text('No Data');
      }

      List<Widget> leftContent = List.empty(growable: true);
      List<Widget> rightContent = List.empty(growable: true);

      int indexPattern = 0;
      for (int i = 0; i < data.count(); i++) {
        bool left = (i % 2) == 0;
        if (indexPattern >= pattern.length) {
          indexPattern = 0;
        }
        double height =
            pattern.elementAt(indexPattern) == 0 ? height1 : height2;
        if (left) {
          if (leftContent.isNotEmpty) {
            leftContent.add(SizedBox(height: InvestrendTheme.cardMargin));
          }
          leftContent.add(
            tileThemesNew(
                context, data.datas.elementAt(i), tileWidth, height, 0),
          );
        } else {
          if (rightContent.isNotEmpty) {
            rightContent.add(SizedBox(height: InvestrendTheme.cardMargin));
          }
          rightContent.add(
            tileThemesNew(
                context, data.datas.elementAt(i), tileWidth, height, 0),
          );
        }
        indexPattern++;
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: leftContent,
          ),
          SizedBox(
            width: InvestrendTheme.cardMargin,
          ),
          Column(
            children: rightContent,
          ),
        ],
      );
      /*
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              tileThemes(listThemes[0], tileWidth, height1, 0),
              SizedBox(
                height: InvestrendTheme.cardMargin,
              ),
              tileThemes(listThemes[2], tileWidth, height2, 0),
              SizedBox(
                height: InvestrendTheme.cardMargin,
              ),
              tileThemes(listThemes[4], tileWidth, height1, 0),
            ],
          ),
          Column(
            children: [
              tileThemes(listThemes[1], tileWidth, height2, cardPadding),
              SizedBox(
                height: InvestrendTheme.cardMargin,
              ),
              tileThemes(listThemes[3], tileWidth, height2, cardPadding),
              SizedBox(
                height: InvestrendTheme.cardMargin,
              ),
              tileThemes(listThemes[5], tileWidth, height1, cardPadding),
            ],
          ),
        ],
      );
      */
    });
  }

  void onTap(BuildContext context, StockThemes theme) {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ScreenThemesDetail(theme),
          settings: RouteSettings(name: '/themes_detail'),
        ));
  }

  Widget tileThemesNew(BuildContext context, StockThemes themes,
      double tileWidth, double tileHeight, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            InvestrendTheme.of(context).tileRoundedRadius),
        child: SizedBox(
          width: tileWidth,
          height: tileHeight,
          child: MaterialButton(
            elevation: 0.0,
            minWidth: tileWidth,
            //height: tileHeight,
            color: themes.background_color,
            splashColor: InvestrendTheme.of(context).tileSplashColor,
            padding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
              side: BorderSide(
                color: InvestrendTheme.of(context).tileBackground,
                width: 0.0,
              ),
            ),
            onPressed: () {
              //InvestrendTheme.of(context).showSnackBar(context, 'Action Theme detail');
              onTap(context, themes);
            },
            child: Stack(
              //fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ComponentCreator.imageNetwork(
                    themes.background_image_url,
                    width: tileWidth,
                    height: tileHeight,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  padding: EdgeInsets.all(
                      InvestrendTheme.of(context).tileRoundedRadius),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black54,
                      Colors.black12,
                    ],
                  )),
                ),
                Padding(
                  padding: EdgeInsets.all(
                      InvestrendTheme.of(context).tileRoundedRadius),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        themes.getName(
                            language: EasyLocalization.of(context)
                                .locale
                                .languageCode),
                        style: InvestrendTheme.of(context)
                            .regular_w600
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .textWhite /*Colors.white*/,
                                height: 1.231),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        themes.getDescription(
                            language: EasyLocalization.of(context)
                                .locale
                                .languageCode),
                        style: InvestrendTheme.of(context).small_w400.copyWith(
                            color: InvestrendTheme.of(context)
                                .textWhite /*Colors.white*/,
                            height: 1.235),
                      ),
                      SizedBox(
                        height: InvestrendTheme.cardPadding,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tileThemes(BuildContext context, StockThemes themes, double tileWidth,
      double tileHeight, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            InvestrendTheme.of(context).tileRoundedRadius),
        //clipper: ClipRect(clipper: ,),
        child: SizedBox(
          width: tileWidth,
          height: tileHeight,
          child: Stack(
            //fit: StackFit.expand,
            children: [
              Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: themes.background_color,
              ),
              ComponentCreator.imageNetwork(
                themes.background_image_url,
                width: tileWidth,
                height: tileHeight,
                fit: BoxFit.fill,
              ),
              Container(
                width: double.maxFinite,
                height: double.maxFinite,
                padding: EdgeInsets.all(
                    InvestrendTheme.of(context).tileRoundedRadius),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black54,
                    Colors.black12,
                  ],
                )),
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Theme.of(context).colorScheme.secondary,
                        onTap: () {
                          InvestrendTheme.of(context)
                              .showSnackBar(context, 'Action Theme detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.all(
                      InvestrendTheme.of(context).tileRoundedRadius),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        themes.getName(
                            language: EasyLocalization.of(context)
                                .locale
                                .languageCode),
                        style: InvestrendTheme.of(context)
                            .regular_w600
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .textWhite /*Colors.white*/,
                                height: 1.231),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        themes.getDescription(
                            language: EasyLocalization.of(context)
                                .locale
                                .languageCode),
                        style: InvestrendTheme.of(context).small_w400.copyWith(
                            color: InvestrendTheme.of(context)
                                .textWhite /*Colors.white*/,
                            height: 1.235),
                      ),
                      SizedBox(
                        height: InvestrendTheme.cardPadding,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
