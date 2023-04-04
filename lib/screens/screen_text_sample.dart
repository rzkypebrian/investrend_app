import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class ScreenTextSample extends StatelessWidget {

   ScreenTextSample({Key key}) : super(key: key);


  List<String> texts = <String>['abcABC', 'ABCabc', '123'];
  List<double> size = List<double>.empty(growable: true);




  @override
  Widget build(BuildContext context) {
    size.clear();
    List<Widget> list = List<Widget>.empty(growable: true);

    List<TextStyle> listStyle = [
      InvestrendTheme.of(context).headline3,
      InvestrendTheme.of(context).medium_w600,
      InvestrendTheme.of(context).medium_w600_compact,
      InvestrendTheme.of(context).medium_w500,
      InvestrendTheme.of(context).medium_w500_compact,
      InvestrendTheme.of(context).medium_w400,
      InvestrendTheme.of(context).medium_w400_compact,


      InvestrendTheme.of(context).regular_w600,
      InvestrendTheme.of(context).regular_w600_compact,
      InvestrendTheme.of(context).regular_w500,
      InvestrendTheme.of(context).regular_w500_compact,
      InvestrendTheme.of(context).regular_w400,
      InvestrendTheme.of(context).regular_w400_compact,

      InvestrendTheme.of(context).small_w600,
      InvestrendTheme.of(context).small_w600_compact,
      InvestrendTheme.of(context).small_w500,
      InvestrendTheme.of(context).small_w500_compact,
      InvestrendTheme.of(context).small_w400,
      InvestrendTheme.of(context).small_w400_compact,
      InvestrendTheme.of(context).more_support_w600,
      InvestrendTheme.of(context).more_support_w600_compact,
      InvestrendTheme.of(context).more_support_w500,
      InvestrendTheme.of(context).more_support_w500_compact,
      InvestrendTheme.of(context).more_support_w400,
      InvestrendTheme.of(context).more_support_w400_compact,

    ];

    List<String> listText = [
      'headline3',
      'medium_w600',
      'medium_w600_compact',
      'medium_w500',
      'medium_w500_compact',
      'medium_w400',
      'medium_w400_compact',


      'regular_w600',
      'regular_w600_compact',
      'regular_w500',
      'regular_w500_compact',
      'regular_w400',
      'regular_w400_compact',

      'small_w600',
      'small_w600_compact',
      'small_w500',
      'small_w500_compact',
      'small_w400',
      'small_w400_compact',
      'more_support_w600',
      'more_support_w600_compact',
      'more_support_w500',
      'more_support_w500_compact',
      'more_support_w400',
      'more_support_w400_compact',

    ];


    List<Color> listColor = [
      Colors.yellow,
      Colors.purpleAccent,
      Colors.indigoAccent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,


      Colors.purpleAccent,
      Colors.indigoAccent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,

      Colors.purpleAccent,
      Colors.indigoAccent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,

      Colors.purpleAccent,
      Colors.indigoAccent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,

    ];


    for(int i = 0; i < listStyle.length ; i++ ){
      TextStyle style = listStyle.elementAt(i);
      String text = listText.elementAt(i);
      Color color = listColor.elementAt(i);
      list.add(Container(
        color: color,
        child: Row(
          children: [
            Text(text + ' : '+style.fontSize.toString(), style: style,),

          ],
        ),
      ));
      /*
      TextStyle normal = ThemeData.light().textTheme.bodyText1.copyWith(fontSize: i, fontWeight: FontWeight.normal);
      TextStyle bold = ThemeData.light().textTheme.bodyText1.copyWith(fontSize: i, fontWeight: FontWeight.bold);
      list.add(Row(
        children: [




          Text(i.toString()+' '+texts[0], style: normal,),
          Text(' '+texts[1], style: bold,),
          Text(' '+texts[2], style: normal,),
        ],
      ));
      */
    }
    return Scaffold(
      body: ListView(
        children: list,
      ),
    );
  }
}
