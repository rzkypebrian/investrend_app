import 'package:Investrend/objects/class_input_formatter.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class TradeComponentCreator {
  static Widget popupTitle(BuildContext context, String title, {Color color, TextAlign textAlign = TextAlign.left}) {
    if (color == null) {
      color = InvestrendTheme.of(context).blackAndWhiteText;
    }
    return Text(
      title,
      style: InvestrendTheme.of(context).regular_w600_compact.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget popupLabelText(BuildContext context, String label) {
    return Container(
      // color: Colors.yellow,
      child: Text(
        label,
        style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
      ),
    );
  }

  static Widget popupValueText(BuildContext context, String label, {TextStyle textStyle}) {
    if (textStyle == null) {
      textStyle = InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText);
    }
    return Container(
      // color: Colors.greenAccent,
      child: Text(
        label,
        style: textStyle,
        textAlign: TextAlign.right,
      ),
    );
  }

  static Widget popupRow(BuildContext context, String label, String value, {TextStyle textStyleValue}) {
    return Container(
      //color: Colors.purple,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          popupLabelText(context, label),
          Expanded(
            flex: 1,
            child: popupValueText(context, value, textStyle: textStyleValue),
          ),
        ],
      ),
    );
  }

  static Widget popupRowCustom(BuildContext context, Text label, Text value) {
    return Container(
      //color: Colors.purple,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          Expanded(
            flex: 1,
            child: value,
          ),
        ],
      ),
    );
  }

  static Widget minusButton(double iconSize, VoidCallback onPressed) {
    return IconButton(
        icon: Image.asset(
          'images/icons/minus.png',
          height: iconSize,
          width: iconSize,
        ),
        onPressed: onPressed);
  }

  static Widget plusButton(double iconSize, VoidCallback onPressed) {
    return IconButton(
      icon: Image.asset(
        'images/icons/plus.png',
        height: iconSize,
        width: iconSize,
      ),
      onPressed: onPressed,
    );
  }

  static Widget textField(BuildContext context, TextEditingController controller, Color colorForm, FocusNode focusNode, {String hint, FocusNode nextFocusNode}) {

    ValueChanged<String> onSubmitted;
    if(nextFocusNode != null){
      onSubmitted = (value){
        FocusScope.of(context).requestFocus(nextFocusNode);
      };
    }

    return TextField(
      focusNode: focusNode,
      controller: controller,
      inputFormatters: [
        PriceFormatter(),
      ],
      // onSubmitted: (){
      //
      // },
      maxLines: 1,
      style: InvestrendTheme.of(context).regular_w600.copyWith(height: null),
      textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      keyboardType: TextInputType.number,
      cursorColor: colorForm,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorForm, width: 1.0)),
        focusColor: colorForm,
        prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
        hintStyle: InvestrendTheme.of(context).inputHintStyle,
        helperStyle: InvestrendTheme.of(context).inputHelperStyle,
        errorStyle: InvestrendTheme.of(context).inputErrorStyle,
        fillColor: Colors.grey,
        contentPadding: EdgeInsets.all(0.0),
      ),
      textAlign: TextAlign.end,
    );
  }

  // static Widget predefineButton(BuildContext context, int percentValue, int selected) {
  //   Color color = InvestrendTheme.of(context).support_w400.color;
  //   if (percentValue == selected) {
  //     color = Theme.of(context).accentColor;
  //   }
  //   return TextButton(
  //       style: ButtonStyle(visualDensity: VisualDensity.compact),
  //       onPressed: () {
  //         predefineLot(percentValue);
  //       },
  //       child: Text(
  //         '$percentValue%',
  //         style: InvestrendTheme.of(context).support_w700.copyWith(color: color),
  //       ));
  // }
}
//
// class PercentButton extends StatelessWidget {
//   final int percentValue;
//   final int selected;
//   final VoidCallback onPressed;
//
//   const PercentButton(this.percentValue, this.selected, {Key key, this.onPressed}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Color color = InvestrendTheme.of(context).support_w400.color;
//     if (percentValue == selected) {
//       color = Theme.of(context).accentColor;
//     }
//     return TextButton(
//         style: ButtonStyle(visualDensity: VisualDensity.compact),
//         onPressed: onPressed,
//         // onPressed: () {
//         //   predefineLot(percentValue);
//         // },
//         child: Text(
//           '$percentValue%',
//           style: InvestrendTheme.of(context).support_w700.copyWith(color: color),
//         ));
//   }
// }
