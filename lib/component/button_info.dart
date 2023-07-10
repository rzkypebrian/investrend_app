import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class ButtonInfo extends StatelessWidget {
  final String text;
  final StringColorFontBool data;
  final VoidCallback onPressed;
  final CrossAxisAlignment crossAxisAlignment;

  const ButtonInfo(this.text, this.data, this.onPressed,  {this.crossAxisAlignment = CrossAxisAlignment.start, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*
    return TapableWidget(
      onTap: onPressed,
      child: Container(

        color: data.flag ? InvestrendTheme.of(context).tileBackground : Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Image.asset(
                  'images/icons/information.png',
                  height: 12.0,
                  width: 12.0,
                ),
              ],
            ),
            Text(data.value, style: InvestrendTheme.of(context).regular_w600.copyWith(fontSize: data.fontSize)),
          ],
        ),
      ),
    );
    */

    return TapableWidget(
      onTap: onPressed,
      child: Row(
        children: [
          data.flag && crossAxisAlignment == CrossAxisAlignment.start ?
          Container(
            margin: EdgeInsets.only(right: 5.0),
            color: InvestrendTheme.of(context).investrendPurple,
            width: 5.0,
            height: 50.0,
          ) : SizedBox(height: 2.0,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                  ),
                  Image.asset(
                    'images/icons/information.png',
                    height: 12.0,
                    width: 12.0,
                  ),
                ],
              ),
              Text(data.value, style: InvestrendTheme.of(context).regular_w600.copyWith(fontSize: data.fontSize)),
            ],
          ),
          data.flag && crossAxisAlignment == CrossAxisAlignment.end ?
          Container(
            margin: EdgeInsets.only(left: 5.0),
            color: InvestrendTheme.of(context).investrendPurple,
            width: 5.0,
            height: 50.0,
          ) : SizedBox(height: 2.0,),
        ],
      ),
    );

  }
}
