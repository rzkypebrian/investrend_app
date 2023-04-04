import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

class MarketColors {
  static Color _volume = Color(0xFFFFCC99);
  static Color _up = Color(0xFF39E38B);//Color(0xFF00CC00);
  static Color _down = Color(0xFFED8E80);//Color(0xFFF3A2A2);
  static Color _noChange = Color(0xFFE3B959);

  static Color _upBracket = Color(0xFF96E3BB); //Color(0xFFB5E7CD);
  static Color _downBracket = Color(0xFFED968A); //Color(0xFFED8E80);
  static Color _noChangeBracket = Color(0xFFFADE9F);



  static Color _volumeDark = Color(0xFFFFCC99);
  static Color _upDark = Color(0xFF5fa07e);
  static Color _downDark = Color(0xFFCC0000);
  static Color _noChangeDark = Color(0xFFe3a519);



  static Color _upBracketDark = Color(0xFF5fa07e);
  static Color _downBracketDark = Color(0xFF983527);
  static Color _noChangeBracketDark = Color(0xFFe3a519);

  static Color get down => _down;
  static Color get volume => _volume;
  static Color get noChange => _noChange;
  static Color get up => _up;

  static Color priceColor(num change) => change == 0 ? _noChange : (change < 0 ? _down : _up);

  static Color priceColorTheme(bool dark,num change) => change == 0 ? (dark ? _noChangeDark: _noChange) : (change < 0 ? (dark ? _downDark : _down) : (dark ? _upDark : _up));

  //MediaQuery.of(context).platformBrightness == Brightness.light
  static Color bracketColor(num change) => change == 0 ? _noChangeBracket : (change < 0 ? _downBracket : _upBracket);
  static Color bracketColorTheme(bool dark,num change) => change == 0 ? (dark ? _noChangeBracketDark : _noChangeBracket) : (change < 0 ? (dark ? _downBracketDark : _downBracket) : (dark ? _upBracketDark : _upBracket));

  static Color toColor(String hexString, {Color defaultColor}) {
    if(StringUtils.isEmtpy(hexString)){
      return defaultColor != null ? defaultColor : Colors.white;
    }
    var hexColor = hexString.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }else{
      return defaultColor != null ? defaultColor : Colors.white;
    }
  }

}
