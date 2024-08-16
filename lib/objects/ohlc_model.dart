import 'package:Investrend/utils/string_utils.dart';

class OhlcModel {
  String? open;
  String? high;
  String? close;
  String? low;
  dynamic dateTrade;

  OhlcModel({
    this.open,
    this.high,
    this.close,
    this.low,
    this.dateTrade,
  });

  static OhlcModel? fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return OhlcModel(
      open: StringUtils.noNullString(parsedJson["open"]),
      high: StringUtils.noNullString(parsedJson["high"]),
      close: StringUtils.noNullString(parsedJson["close"]),
      low: StringUtils.noNullString(parsedJson["low"]),
      dateTrade:
          parsedJson["dateTrade"] == null || parsedJson["dateTrade"] == ""
              ? null
              : DateTime.parse(parsedJson["dateTrade"]),
    );
  }
}
