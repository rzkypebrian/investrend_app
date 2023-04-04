import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class ButtonTabSwitch extends StatelessWidget {
  final List<String> labels;
  final ValueNotifier<int> buttonNotifier;
  final EdgeInsets paddingButton;
  final double minWidthButton;
  const ButtonTabSwitch(this.labels, this.buttonNotifier, { this.minWidthButton, this.paddingButton, Key key}) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    /*
    List<Widget> buttons = List<Widget>.generate(
      labels.length,
          (int index) {
        String text = labels.elementAt(index);
        return TextButton(child: Text(text),);
      },
    );
    */



    int count = labels != null ? labels.length : 0;
    if(count > 0){

      return ValueListenableBuilder(
        valueListenable: buttonNotifier,
        builder: (context, int selectedIndex, child) {

          // TextStyle selectedStyle = Theme.of(context).tabBarTheme.labelStyle.copyWith(height: null, color: Theme.of(context).tabBarTheme.labelColor);
          // TextStyle unselectedStyle = Theme.of(context).tabBarTheme.unselectedLabelStyle.copyWith(height: null, color: Theme.of(context).tabBarTheme.unselectedLabelColor);

          TextStyle selectedStyle = InvestrendTheme.of(context).regular_w600_compact.copyWith(color: Theme.of(context).tabBarTheme.labelColor);
          TextStyle unselectedStyle = InvestrendTheme.of(context).regular_w600_compact.copyWith(color: Theme.of(context).tabBarTheme.unselectedLabelColor);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(
              labels.length,
                  (int index) {
                String text = labels.elementAt(index);
                bool selected = selectedIndex == index;
                if(minWidthButton == null){
                  return MaterialButton(
                    //visualDensity: paddingButton != null ? VisualDensity.compact : VisualDensity.comfortable,
                    padding: paddingButton ?? EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),

                    child: Text(text, style: selected ? selectedStyle : unselectedStyle,),
                    onPressed: (){
                      buttonNotifier.value = index;
                    },);
                }else{
                  return MaterialButton(
                    //visualDensity: paddingButton != null ? VisualDensity.compact : VisualDensity.comfortable,
                    padding: paddingButton ?? EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
                    minWidth: minWidthButton,
                    child: Text(text, style: selected ? selectedStyle : unselectedStyle,),
                    onPressed: (){
                      buttonNotifier.value = index;
                    },);
                }
              },
            ),
          );
        },
      );
      /*
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(
          labels.length,
              (int index) {
            String text = labels.elementAt(index);
            return TextButton(child: Text(text),);
          },
        ),
      );
      */
    }else{
      return Text('No Button', style: InvestrendTheme.of(context).more_support_w400_compact,);
    }
  }
}
