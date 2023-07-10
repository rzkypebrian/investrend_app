
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class ScreenEIPOHelpDetails extends StatelessWidget {
  final String subtitle;
  final String content;
  const ScreenEIPOHelpDetails(this.subtitle,this.content , {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: createAppBar(context),
      body: createBody(context, paddingBottom),
    );
  }
  Widget createAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).colorScheme.background,
      title: AppBarTitleText('eipo_help_title'.tr()),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        Navigator.pop(context);
      }),

    );
  }
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return ListView(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(12.0),
          height: 72.0,
          child:Text(subtitle, style: InvestrendTheme.of(context).regular_w600_compact,),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: ComponentCreator.divider(context),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(content, style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
        ),
      ],
    );
  }
}
