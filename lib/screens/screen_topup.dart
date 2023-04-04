import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/screens/screen_topup_how_to.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenTopUp extends StatelessWidget {
  const ScreenTopUp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(

        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        leading: AppBarActionIcon('images/icons/action_clear.png', (){
          Navigator.pop(context);
        }),

        //icon: Image.asset('images/icons/action_clear.png', color: InvestrendTheme.greenText, width: 12.0, height: 12.0),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 1,),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.7,
                child: Image.asset('images/topup_image.png')),
          ),
          Spacer(flex: 2,),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Text('top_up_info'.tr(), style: InvestrendTheme.of(context).regular_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor), textAlign: TextAlign.center,),
          ),
          Spacer(flex: 2,),
          FractionallySizedBox(
            widthFactor: 0.4,
              child: ComponentCreator.roundedButton(context, 'button_top_up'.tr(), Theme.of(context).accentColor, Theme.of(context).primaryColor, Theme.of(context).accentColor, () {
                Navigator.push(context, CupertinoPageRoute(
                  builder: (_) => ScreenTopUpHowTo(), settings: RouteSettings(name: '/topup_how_to'),));
              })),
          //SizedBox(height: 8.0,),
          TextButton(
              onPressed: (){}, child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('button_learn_more'.tr(), style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
              )),
          Spacer(flex: 2,),
        ],
      ),
    );
  }
}
