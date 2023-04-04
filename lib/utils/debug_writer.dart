import 'package:Investrend/utils/investrend_theme.dart';

class DebugWriter{
  static void information(String text) {
    if (!InvestrendTheme.tradingHttp.is_production) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
    }
  }
  static void info(var object) {
    if (!InvestrendTheme.tradingHttp.is_production) {
      print(object);
    }
  }
}