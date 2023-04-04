import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenComingSoon extends StatelessWidget {
  final bool scrollable;
  const ScreenComingSoon({this.scrollable=false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      //color: Colors.indigoAccent,
      padding: EdgeInsets.only(left: 40.0, right: 40.0),
      child: scrollable ? createScrollableContent(context) : createFixContent(context),
    );
  }
  
  Widget createScrollableContent(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FractionallySizedBox(
              widthFactor: 0.7,
              child: Image.asset('images/shoutout.png', )),
          Text('coming_soon_label'.tr(), style: InvestrendTheme.of(context).headline3,textAlign: TextAlign.center,),
          SizedBox(height: 8.0,),
          Text('coming_soon_info_label'.tr(), style: InvestrendTheme.of(context).small_w400_greyDarker,textAlign: TextAlign.center,)
        ],
      ),
    );
  }

  Widget createFixContent(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FractionallySizedBox(
            widthFactor: 0.7,
            child: Image.asset('images/shoutout.png', )),
        Text('coming_soon_label'.tr(), style: InvestrendTheme.of(context).headline3,textAlign: TextAlign.center,),
        SizedBox(height: 8.0,),
        Text('coming_soon_info_label'.tr(), style: InvestrendTheme.of(context).small_w400_greyDarker,textAlign: TextAlign.center,)
      ],
    );
  }
}