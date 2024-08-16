import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';

class CardProfiles extends StatelessWidget {
  final List<HomeProfiles> listProfiles;
  final String title;
  CardProfiles(this.title, this.listProfiles, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //double width = MediaQuery.of(context).size.width;
    //double tileWidth = width * 0.8;

    return Card(
      margin: const EdgeInsets.only(
          top: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitleNoButtonMore(
              context,
              title,
            ),
          ),
          // SizedBox(
          //   height: InvestrendTheme.cardPaddingGeneral,
          // ),
          LayoutBuilder(builder: (context, constrains) {
            print('constrains ' + constrains.maxWidth.toString());
            double tileWidth = constrains.maxWidth * 0.8;
            //double height = 200.0;
            double height = tileWidth * 0.687;
            return SizedBox(
              height: height,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: listProfiles.length,
                itemBuilder: (BuildContext context, int index) {
                  //double left = index == 0 ? 0 : 10.0;
                  //double left = index == 0 ? InvestrendTheme.cardPaddingGeneral : 0;
                  bool isFirst = index == 0;
                  bool isLast = index == listProfiles.length - 1;
                  return tileProfile(context, listProfiles[index], isFirst,
                      isLast, tileWidth, height);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // List<Color> gradientColors = [
  //   Color(0xFF000000),//0
  //   Color(0xFF25222B),//27
  //   // Color(0xFF25222B) // 100
  // ];

  Widget tileProfile(BuildContext context, HomeProfiles profile, bool isFirst,
      bool isLast, double widthTile, double heightTile) {
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
    return Padding(
      padding: EdgeInsets.only(left: left, right: right),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            InvestrendTheme.of(context).tileRoundedRadius),
        child: SizedBox(
          width: widthTile,
          height: heightTile,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ComponentCreator.imageNetwork(
                profile.url_background,
                fit: BoxFit.fill,
                width: widthTile,
                height: heightTile,
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.center,
                  // colors: gradientColors
                  colors: [
                    Colors.black87,
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
                              .showSnackBar(context, 'Action Profile detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  //padding: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(
                        flex: 2,
                      ),
                      SizedBox(
                        width: widthTile / 2,
                        child: Text(
                          profile.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  color: InvestrendTheme.of(context).textWhite,
                                  fontWeight: FontWeight.w600,
                                  height: 1.23),
                        ),
                      ),
                      // SizedBox(
                      //   height: InvestrendTheme.cardPadding,
                      // ),
                      Spacer(
                        flex: 1,
                      ),
                      SizedBox(
                        width: widthTile / 2,
                        child: Text(
                          profile.description,
                          maxLines: 5,
                          //overflow: TextOverflow.ellipsis,
                          //style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white),
                          style: InvestrendTheme.of(context)
                              .more_support_w400
                              ?.copyWith(
                                  color: InvestrendTheme.of(context).textWhite,
                                  height: 1.272),
                        ),
                      ),
                      Spacer(
                        flex: 2,
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

    /*
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Image.network(
                profile.url_background,
                fit: BoxFit.fill,
                width: widthTile,
                height: heightTile,
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Theme.of(context).accentColor,
                        onTap: () {
                          showSnackBar(context, 'Action Competition detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          profile.name,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      FittedBox(
                        child: Text(
                          profile.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Colors.white),
                        ),
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

     */
  }
}
