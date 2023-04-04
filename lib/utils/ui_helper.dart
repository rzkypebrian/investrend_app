import 'package:flutter/material.dart';

class UIHelper {
  static void showSnackBarInfo(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr, )
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
  static TextStyle useFontSize(BuildContext context, TextStyle style, double width, String text,{ int tried = 1,double font_step = 1.5}){
    //print('GridPriceThree.useFontSize  try fontSize  : '+style.fontSize.toString()+'  width : $width  text : $text  ');
    //const double font_step = 1.5;


    double widthText = UIHelper.textSize(text, style).width;
    bool reduceFont = widthText > width;
    if(reduceFont){
      style = style.copyWith(fontSize: style.fontSize - font_step);
      return useFontSize(context, style, width, text, tried: tried++);
    }else{
      //print('GridPriceThree.useFontSize Final fontSize  : '+style.fontSize.toString()+'  text : $text  tried : $tried');
      return style;
    }
  }

  static List<TextStyle> calculateFontSizes(BuildContext context, List<TextStyle> styles, double width, List<String> texts, {int tried = 1}) {
    print('UiHelper.calculateFontSize  try  : $tried  ');
    const double font_step = 1.5;

    double widthText = 0;
    for (int i = 0; i < styles.length; i++) {
      TextStyle style = styles.elementAt(i);
      String text = texts.elementAt(i);
      print('UiHelper.calculateFontSize   style[$i] : '+style.fontSize.toString());
      widthText += UIHelper.textSize(text, style).width;
    }
    bool reduceFont = widthText > width;
    print('UiHelper.calculateFontSize  reduceFont  : $reduceFont  widthText[$widthText] > width[$width]  ');
    if (reduceFont) {
      List<TextStyle> stylesNew = List.empty(growable: true);
      for (int i = 0; i < styles.length; i++) {
        TextStyle style = styles.elementAt(i);
        style = style.copyWith(fontSize: style.fontSize - font_step);
        stylesNew.add(style);
      }

      return calculateFontSizes(context, stylesNew, width, texts, tried: tried++);
    } else {
      print('UiHelper.calculateFontSizes Final  tried : $tried');
      return styles;
    }
  }
}

