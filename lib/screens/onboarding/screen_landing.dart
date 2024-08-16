// ignore_for_file: unused_local_variable

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/screens/onboarding/screen_register.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenLanding extends StatelessWidget {
  final _selectedCarouselNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: createBody(context));
  }

  Widget createBody(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double left = (width - 48) / 2;
    double top = height * 0.07;
    double imageSize = width * 0.7;
    double imagePadding = (width - imageSize) / 2;
    const carousel_images = [
      'images/landing_01.png',
      'images/landing_02.png',
      'images/landing_03.png'
    ];
    double dotSelectedWidth = 20;
    double dotWidth = 10;
    double dotHeight = 5;
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    // ignore: unnecessary_null_comparison
    bool accentColorIsNull = Theme.of(context).colorScheme.secondary == null;
    print('lightTheme : $lightTheme  accentColorIsNull : $accentColorIsNull');
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      //color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: top,
          ),
          //Center(child: Image.asset('images/icons/ic_launcher.png')),
          Center(
              child: Image.asset(
            InvestrendTheme.of(context).ic_launcher!,
          )),
          Spacer(
            flex: 1,
          ),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Image.asset('images/landing_01.png'),
          ),
          /*
          CarouselSlider(
            options: CarouselOptions(
              height: width,
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
            items: carousel_images.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      // decoration: BoxDecoration(
                      //     color: Colors.cyan
                      // ),
                      child: Padding(
                        padding: EdgeInsets.all(imagePadding),
                        child: FittedBox(
                          child: Image.asset(
                            '$i',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ));
                },
              );
            }).toList(),
          ),
          ComponentCreator.dotsIndicator(context, 3, 0, _selectedCarouselNotifier),
          */
          Spacer(
            flex: 1,
          ),

          SizedBox(
            height: 10.0,
          ),

          FractionallySizedBox(
            widthFactor: 0.8,
            child: ComponentCreator.roundedButton(
                context,
                'landing_button_register'.tr(),
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary, () {
              // on presss
              //EasyLocalization.of(context).setLocale(Locale('en'));
              showRegisterPage(context);
            }),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'landing_question_text'.tr(),
                //style: Theme.of(context).textTheme.bodyText2.copyWith(color: InvestrendCustomTheme.textfield_labelTextColor(lightTheme)),
                //style: Theme.of(context).textTheme.bodyText2,
                style: InvestrendTheme.of(context).small_w400_greyDarker,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: InvestrendTheme.of(context).hyperlink,
                    padding: EdgeInsets.all(0.0),
                    //visualDensity: VisualDensity.compact,
                    animationDuration: Duration(milliseconds: 500),
                    backgroundColor: Colors.transparent,
                    //textStyle: Theme.of(context).textTheme.bodyText2
                    textStyle:
                        InvestrendTheme.of(context).small_w400_greyDarker),
                child: Text('landing_button_enter'.tr()),
                onPressed: () {
                  print('pressed');
                  showLoginPage(context);
                },
              ),
            ],
          ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  void showLoginUsingGoogle(BuildContext context) {
    final snackBar = SnackBar(content: Text('Action Login Using Google'));

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    /*
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
        pageBuilder: (context, animation1, animation2) => ScreenLogin(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            ),
      ),
    );

     */
  }

  void showLoginPage(BuildContext context) {
    //Navigator.pushReplacementNamed(context, '/login');
    //Navigator.pushReplacementNamed(context, '/landing');

    InvestrendTheme.pushReplacement(
        context, ScreenLogin(), ScreenTransition.SlideLeft, '/login');

    // Navigator.pushReplacement(
    //   context,
    //   PageRouteBuilder(
    //       transitionDuration: Duration(milliseconds: 1000),
    //       //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
    //       /*
    //     pageBuilder: (context, animation1, animation2) => ScreenLogin(),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) =>
    //         FadeTransition(
    //       opacity: animation,
    //       child: child,
    //     ),
    //     */
    //       pageBuilder: (context, animation1, animation2) => ScreenLogin(),
    //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //         return AnimationCreator.transitionSlideLeft(context, animation, secondaryAnimation, child);
    //       }),
    // );
  }

  void showRegisterPage(BuildContext context) {
    //Navigator.pushReplacementNamed(context, '/login');
    //Navigator.pushReplacementNamed(context, '/landing');
    InvestrendTheme.push(
        context, ScreenRegister(), ScreenTransition.SlideUp, '/register');

    //    Navigator.push(
    //      context,
    //      PageRouteBuilder(
    //        transitionDuration: Duration(milliseconds: 1000),
    //        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
    //
    //        pageBuilder: (context, animation1, animation2) => ScreenRegister(),
    //        transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //          return AnimationCreator.transitionSlideUp(context, animation, secondaryAnimation, child);
    //        }
    //        /*
    //      transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //        var begin = Offset(0.0, 1.0);
    //        var end = Offset.zero;
    //        var curve = Curves.ease;
    //
    //        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    //
    //        return SlideTransition(
    //          position: animation.drive(tween),
    //          child: child,
    //        );
    //
    //
    //  }
    // */
    //        ,
    //
    //        /*
    //      transitionsBuilder:
    //          (context, animation, secondaryAnimation, child) =>
    //
    //          FadeTransition(
    //            opacity: animation,
    //            child: child,
    //          ),*/
    //      ),
    //    );

/*
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
        pageBuilder: (context, animation1, animation2) =>
            ScreenRegister(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            ),
      ),
    );

     */
  }

  void onPageChange(int index, CarouselPageChangedReason changeReason) {
    _selectedCarouselNotifier.value = index;
    print('selectedCarousel : $_selectedCarouselNotifier.value');
    //setState(() {});
  }
/*
  Widget getTextButton(BuildContext context, String text, Color color,
      Color textColor, Color borderColor, VoidCallback onPressed) {
    return Material(
        child: InkWell(
      child: MaterialButton(
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        //color: Theme.of(context).accentColor,
        color: color,
        //textColor: Theme.of(context).primaryColor,
        textColor: textColor,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        onPressed: onPressed,
      ),
    ));
  }

  Widget getRoundedButton(BuildContext context, String text, Color color,
      Color textColor, Color borderColor, VoidCallback onPressed) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          child: MaterialButton(
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            //color: Theme.of(context).accentColor,
            color: color,
            //textColor: Theme.of(context).primaryColor,
            textColor: textColor,
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: textColor)),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
              side: BorderSide(
                color: borderColor,
              ),
            ),
            onPressed: onPressed,
          ),
        ));
  }

  Widget getRoundedButtonIcon(
      BuildContext context,
      String text,
      Color color,
      Color textColor,
      Color borderColor,
      String imageAsset,
      VoidCallback onPressed) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          child: MaterialButton(
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            //color: Theme.of(context).accentColor,
            color: color,
            //textColor: Theme.of(context).primaryColor,
            textColor: textColor,
            child: Row(
              children: [
                Image.asset(imageAsset),
                Spacer(
                  flex: 1,
                ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.button,
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
              side: BorderSide(
                color: borderColor,
              ),
            ),
            onPressed: onPressed,
          ),
        ));
  }

  Widget dotsIndicator(BuildContext context, int size,
      int defaultSelectedIndex, ValueNotifier<int> notifier) {
    double dot_selected_width = 20;
    double dot_width = 10;
    double dot_height = 5;
    double dot_space_between = 5;
    List<Widget> dots = List.empty(growable: true);
    for (int i = 0; i < size; i++) {
      if (i > 0) {
        // space between dots
        dots.add(SizedBox(
          width: dot_space_between,
        ));
      }
      Widget dot = ValueListenableBuilder<int>(
          valueListenable: notifier,
          builder: (context, value, child) {
            bool selected = notifier.value == i;
            return AnimatedContainer(
                width: selected ? dot_selected_width : dot_width,
                height: dot_height,
                //color: selected ? Colors.cyan : Colors.grey,
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).accentColor
                      : Colors.grey[300],
                  border: Border.all(
                      color: selected
                          ? Theme.of(context).accentColor
                          : Colors.grey[300],
                      width: selected ? dot_selected_width : dot_width),
                  // added
                  borderRadius: BorderRadius.circular(2.0),
                ),
                duration: Duration(milliseconds: (selected ? 500 : 500)));
          });
      dots.add(dot);
    }
    int lenght = dots.length;
    print('dots size : $lenght.');
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
  }
  */
}
