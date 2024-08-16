import 'dart:math';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/rows/row_watchlist.dart';
import 'package:Investrend/component/text_button_retry.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_analysis.dart';
import 'package:Investrend/utils/string_utils.dart';
//import 'package:dartis/dartis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalForeignNotifier extends BaseValueNotifier<ForeignDomestic?> {
  LocalForeignNotifier(ForeignDomestic value) : super(value);

  void setValue(ForeignDomestic? newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value == null || this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

/*
class ForeignDomesticNotifier extends ValueNotifier<ForeignDomestic>{
  ForeignDomesticNotifier(ForeignDomestic value) : super(value);

  void setValue(ForeignDomestic newValue){
    this.value?.copyValueFrom(newValue);
    notifyListeners();
  }

  bool valid() {
    return value != null && value.loaded;
  }

  bool invalid() {
    return !valid();
  }
}
*/
class PerformanceNotifier extends BaseValueNotifier<PerformanceData?> {
  PerformanceNotifier(PerformanceData value) : super(value);

  void setValue(PerformanceData newValue) {
    this.value?.copyValueFrom(newValue);
    //notifyListeners();
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }

  bool valid() {
    return value != null && value!.loaded!;
  }

  bool invalid() {
    return !valid();
  }
}

class ChartOhlcvNotifier extends BaseValueNotifier<ChartOhlcvData?> {
  ChartOhlcvNotifier(ChartOhlcvData value) : super(value);

  void setValue(ChartOhlcvData? newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class ChartNotifier extends BaseValueNotifier<ChartLineData?> {
  ChartNotifier(ChartLineData value) : super(value);

  void setValue(ChartLineData? newValue) {
    this.value?.copyValueFrom(newValue!);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class GroupedNotifier extends BaseValueNotifier<GroupedData?> {
  GroupedNotifier(GroupedData value) : super(value);

  void setValue(GroupedData newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class YourPositionNotifer extends BaseValueNotifier<YourPosition?> {
  YourPositionNotifer(YourPosition value) : super(value);

  void setValue(YourPosition? newValue) {
    this.value?.copyValueFrom(newValue!);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    notifyListeners();
  }
}

class GeneralPriceNotifier extends BaseValueNotifier<GeneralPriceData?> {
  GeneralPriceNotifier(GeneralPriceData value) : super(value);

  void setValue(GeneralPriceData newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    notifyListeners();
  }

  double widthRight = 0;
  void updateBySummarys(List<StockSummary>? summarys, {BuildContext? context}) {
    int countSummarys = summarys != null ? summarys.length : 0;
    int? countData = value?.datas != null ? value?.datas?.length : 0;
    bool changed = false;

    if (countSummarys > 0 && countData! > 0) {
      summarys?.forEach((summary) {
        for (int i = 0; i < countData; i++) {
          GeneralPrice? gp = value?.datas?.elementAt(i);
          if (StringUtils.equalsIgnoreCase(gp?.code, summary.code!)) {
            gp?.price = summary.close?.toDouble();
            gp?.change = summary.change;
            gp?.percent = summary.percentChange;

            if (gp is WatchlistPrice) {
              double? widthRightData = RowWatchlist.calculateWidthRight(
                  context, gp.price, gp.change, gp.percent);
              widthRight = max(widthRight, widthRightData);
              gp.prevPrice = summary.prev;

              gp.bestBidPrice = summary.bestBidPrice;
              gp.bestBidVolume = summary.bestBidVolume;

              gp.bestOfferPrice = summary.bestOfferPrice;
              gp.bestOfferVolume = summary.bestOfferVolume;
              gp.value = summary.value;

              if (context != null) {
                try {
                  gp.notation =
                      context.read(remark2Notifier).getSpecialNotation(gp.code);
                  gp.status = context
                      .read(remark2Notifier)
                      .getSpecialNotationStatus(gp.code);
                  gp.suspendStock = context
                      .read(suspendedStockNotifier)
                      .getSuspended(gp.code, Stock.defaultBoardByCode(gp.code));
                  if (gp.suspendStock != null) {
                    gp.status = StockInformationStatus.Suspended;
                  }
                  gp.corporateAction = context
                      .read(corporateActionEventNotifier)
                      .getEvent(gp.code);
                  gp.corporateActionColor =
                      CorporateActionEvent.getColor(gp.corporateAction!);
                  String attentionCodes = context
                      .read(remark2Notifier)
                      .getSpecialNotationCodes(gp.code);
                  gp.attentionCodes = attentionCodes;
                } catch (e) {
                  print(e);
                }
              }
            }

            // gp.price = InvestrendTheme.formatPrice(summary.close);
            // gp.change = InvestrendTheme.formatPriceDouble(summary.change);
            // gp.percent = InvestrendTheme.formatPercentChange(summary.percentChange);
            //gp.priceColor = InvestrendTheme.changeTextColor(summary.change);
            changed = true;
            break;
          }
        }
      });
    }
    if (changed) {
      notifyListeners();
    }
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class WatclistPriceNotifier extends BaseValueNotifier<WatchlistPriceData?> {
  WatclistPriceNotifier(WatchlistPriceData value) : super(value);

  void setValue(WatchlistPriceData? newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    notifyListeners();
  }

  double widthRight = 0;
  void updateBySummarys(List<StockSummary>? summarys, {BuildContext? context}) {
    int countSummarys = summarys != null ? summarys.length : 0;
    int? countData = value?.datas != null ? value?.datas?.length : 0;
    bool changed = false;

    if (countSummarys > 0 && countData! > 0) {
      summarys?.forEach((summary) {
        for (int i = 0; i < countData; i++) {
          WatchlistPrice? gp = value?.datas?.elementAt(i);
          if (StringUtils.equalsIgnoreCase(gp?.code, summary.code!)) {
            gp?.price = summary.close?.toDouble();
            gp?.change = summary.change;
            gp?.percent = summary.percentChange;

            // if(gp is WatchlistPrice){

            double widthRightData = RowWatchlist.calculateWidthRight(
                context, gp?.price, gp?.change, gp?.percent);
            widthRight = max(widthRight, widthRightData);
            gp?.prevPrice = summary.prev;

            gp?.bestBidPrice = summary.bestBidPrice;
            gp?.bestBidVolume = summary.bestBidVolume;

            gp?.bestOfferPrice = summary.bestOfferPrice;
            gp?.bestOfferVolume = summary.bestOfferVolume;
            gp?.value = summary.value;

            if (context != null) {
              try {
                gp?.notation =
                    context.read(remark2Notifier).getSpecialNotation(gp.code);
                gp?.status = context
                    .read(remark2Notifier)
                    .getSpecialNotationStatus(gp.code);
                gp?.suspendStock = context
                    .read(suspendedStockNotifier)
                    .getSuspended(gp.code, Stock.defaultBoardByCode(gp.code));
                if (gp?.suspendStock != null) {
                  gp?.status = StockInformationStatus.Suspended;
                }
                gp?.corporateAction = context
                    .read(corporateActionEventNotifier)
                    .getEvent(gp.code);
                gp?.corporateActionColor =
                    CorporateActionEvent.getColor(gp.corporateAction!);
                String attentionCodes = context
                    .read(remark2Notifier)
                    .getSpecialNotationCodes(gp?.code);
                gp?.attentionCodes = attentionCodes;
              } catch (e) {
                print(e);
              }
            }
            // }

            // gp.price = InvestrendTheme.formatPrice(summary.close);
            // gp.change = InvestrendTheme.formatPriceDouble(summary.change);
            // gp.percent = InvestrendTheme.formatPercentChange(summary.percentChange);
            //gp.priceColor = InvestrendTheme.changeTextColor(summary.change);
            changed = true;
            break;
          }
        }
      });
    }
    if (changed) {
      notifyListeners();
    }
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class OrderbookNotifier extends BaseValueNotifier<OrderbookData?> {
  OrderbookNotifier(OrderbookData value) : super(value);

  void setValue(OrderbookData? newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      print('OrderbookNotifier isEmpty');
      setNoData();
    } else {
      print('OrderbookNotifier setFinished');
      setFinished();
    }
    //notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class OrderQueueNotifier extends BaseValueNotifier<OrderQueueData?> {
  OrderQueueNotifier(OrderQueueData value) : super(value);

  void setValue(OrderQueueData? newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()!) {
      print('OrderQueueNotifier isEmpty');
      setNoData();
    } else {
      print('OrderQueueNotifier setFinished');
      setFinished();
    }
    //notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class ActivityRDNNotifier extends ValueNotifier<ActivityRDNData?> {
  ActivityRDNNotifier(ActivityRDNData? value) : super(value);

  void setValue(ActivityRDNData newValue) {
    this.value?.copyValueFrom(newValue);
    notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class ReturnNotifier extends ValueNotifier<ReturnData?> {
  ReturnNotifier(ReturnData? value) : super(value);

  void setValue(ReturnData newValue) {
    this.value?.copyValueFrom(newValue);
    notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class RealizedNotifier extends BaseValueNotifier<RealizedStockData?> {
  RealizedNotifier(RealizedStockData value) : super(value);

  void setValue(RealizedStockData newValue) {
    this.value?.copyValueFrom(newValue);
    //notifyListeners();
    if (this.value!.isEmpty()) {
      print('OrderQueueNotifier isEmpty');
      setNoData();
    } else {
      print('OrderQueueNotifier setFinished');
      setFinished();
    }
  }

  void mustNotifyListeners() {
    notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class PortfolioNotifier extends ValueNotifier<PortfolioData?> {
  PortfolioNotifier(PortfolioData? value) : super(value);

  void setValue(PortfolioData newValue) {
    this.value?.copyValueFrom(newValue);
    notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class StockPositionNotifier extends BaseValueNotifier<StockPosition?> {
  StockPositionNotifier(StockPosition value) : super(value);

  void setValue(StockPosition? newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  String? joinCode(String delimiter) {
    String? joined = this.value != null ? this.value?.joinCode(delimiter) : '';
    return joined;
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class PortfolioSummaryNotifier
    extends BaseValueNotifier<PortfolioSummaryData?> {
  PortfolioSummaryNotifier(PortfolioSummaryData value) : super(value);

  void setValue(PortfolioSummaryData newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class ContentEIPONotifier extends BaseValueNotifier<ContentEIPO?> {
  ContentEIPONotifier(ContentEIPO value) : super(value);

  void setValue(ContentEIPO newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class ProfileNotifier extends BaseValueNotifier<Profile?> {
  ProfileNotifier(Profile value) : super(value);

  void setValue(Profile newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class StockThemeNotifier extends BaseValueNotifier<StockThemesData?> {
  StockThemeNotifier(StockThemesData value) : super(value);

  void setValue(StockThemesData newValue) {
    //this.error = '';
    this.value!.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  // bool valid() {
  //   return value != null && value.loaded;
  // }
  //
  // bool invalid() {
  //   return !valid();
  // }
  //
  // String error = '';
  // void setError(String error){
  //   this.error = error;
  //   notifyListeners();
  // }
  // bool isError(){
  //   return !StringUtils.isEmtpy(error);
  // }
}

class HomeCurrenciesNotifier extends BaseValueNotifier<HomeCurrenciesData?> {
  HomeCurrenciesNotifier(HomeCurrenciesData value) : super(value);

  void setValue(HomeCurrenciesData newValue) {
    //this.error = '';
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  // bool valid() {
  //   return value != null && value.loaded;
  // }
  //
  // bool invalid() {
  //   return !valid();
  // }
  //
  // String error = '';
  // void setError(String error){
  //   this.error = error;
  //   notifyListeners();
  // }
  // bool isError(){
  //   return !StringUtils.isEmtpy(error);
  // }
}

class HomeCryptoNotifier extends BaseValueNotifier<HomeCryptoData?> {
  HomeCryptoNotifier(HomeCryptoData value) : super(value);

  void setValue(HomeCryptoData newValue) {
    // this.error = '';
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    // notifyListeners();
  }

  // bool valid() {
  //   return value != null && value.loaded;
  // }
  //
  // bool invalid() {
  //   return !valid();
  // }
  // String error = '';
  // void setError(String error){
  //   this.error = error;
  //   notifyListeners();
  // }
  // bool isError(){
  //   return !StringUtils.isEmtpy(error);
  // }
}

class HomeCommoditiesNotifier extends BaseValueNotifier<HomeCommoditiesData?> {
  HomeCommoditiesNotifier(HomeCommoditiesData value) : super(value);

  void setValue(HomeCommoditiesData newValue) {
    // this.error = '';
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    // notifyListeners();
  }

  // bool valid() {
  //   return value != null && value.loaded;
  // }
  //
  // bool invalid() {
  //   return !valid();
  // }
  //
  // String error = '';
  // void setError(String error){
  //   this.error = error;
  //   notifyListeners();
  // }
  // bool isError(){
  //   return !StringUtils.isEmtpy(error);
  // }
}

enum NotifierState { Loading, NoData, Error, Finished }

extension NotifierStateExtension on NotifierState {
  String get stateText {
    switch (this) {
      case NotifierState.Loading:
        return 'Loading';
      case NotifierState.Error:
        return 'Error';
      case NotifierState.NoData:
        return 'No Data';
      case NotifierState.Finished:
        return 'Finished';
      default:
        return '#unknown_routeName';
    }
  }

  Widget? getNoWidget({VoidCallback? onRetry}) {
    Widget? noWidget;
    if (this.notFinished()) {
      if (this.isError()) {
        noWidget = TextButtonRetry(
          onPressed: onRetry,
        );
      } else if (this.isLoading()) {
        noWidget = CircularProgressIndicator();
      } else if (this.isNoData()) {
        noWidget = EmptyLabel();
      }
    }
    return noWidget;
  }

  bool isError() {
    return this == NotifierState.Error;
  }

  bool isLoading() {
    return this == NotifierState.Loading;
  }

  bool isNoData() {
    return this == NotifierState.NoData;
  }

  bool isFinished() {
    return this == NotifierState.Finished;
  }

  bool notFinished() {
    return this != NotifierState.Finished;
  }
}

class BaseValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T?> {
  /// Creates a [ChangeNotifier] that wraps this value.
  BaseValueNotifier(this._value);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  T? get value => _value;
  T? _value;
  set value(T? newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  bool _diposed = false;

  bool get isDiposed => _diposed;

  @override
  void dispose() {
    _diposed = true;
    super.dispose();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  NotifierState currentState = NotifierState.Loading;
  String currentMessage = '';
  void setState(NotifierState newState, {String? message}) {
    this.currentState = newState;
    if (message != null) {
      this.currentMessage = message;
    }
    notifyListeners();
  }

  void mustNotifyListeners() {
    notifyListeners();
  }

  void setNoData() {
    setState(NotifierState.NoData, message: 'empty_label'.tr());
  }

  void setLoading() {
    setState(NotifierState.Loading, message: '');
  }

  void setFinished() {
    setState(NotifierState.Finished, message: '');
  }

  void setError({String? message}) {
    setState(NotifierState.Error, message: message);
  }
}

class HomeIndicesNotifier extends BaseValueNotifier<HomeIndicesData> {
  HomeIndicesNotifier(HomeIndicesData value) : super(value);

  void setValue(HomeIndicesData newValue) {
    // this.error = '';
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    // notifyListeners();
  }

  // bool valid() {
  //   return value != null && value.loaded;
  // }
  //
  // bool invalid() {
  //   return !valid();
  // }

  // String error = '';
  // void setError(String error){
  //   this.error = error;
  //   notifyListeners();
  // }
  // bool isError(){
  //   return !StringUtils.isEmtpy(error);
  // }
}

class BriefingNotifier extends BaseValueNotifier<Briefing> {
  BriefingNotifier(Briefing value) : super(value);

  void setValue(Briefing newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }

  // bool valid() {
  //   return value != null && value.loaded;
  // }
  //
  // bool invalid() {
  //   return !valid();
  // }
}

class ReportStockHistNotifier extends BaseValueNotifier<ReportStockHistData> {
  ReportStockHistNotifier(ReportStockHistData value) : super(value);

  void setValue(ReportStockHistData newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class OrderStatusNotifier extends BaseValueNotifier<OrderStatusData> {
  OrderStatusNotifier(OrderStatusData value) : super(value);

  void setValue(OrderStatusData newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class SinglePortfolioNotifier extends BaseValueNotifier<StockPositionDetail> {
  SinglePortfolioNotifier(StockPositionDetail value) : super(value);

  void setValue(StockPositionDetail? newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class SingleWatchlistPriceNotifier extends BaseValueNotifier<WatchlistPrice> {
  SingleWatchlistPriceNotifier(WatchlistPrice value) : super(value);
  double widthRight = 0;
  void setValue(WatchlistPrice newValue, BuildContext context) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      double widthRightData = RowWatchlist.calculateWidthRight(
          context, this.value?.price, this.value?.change, this.value?.percent);
      widthRight = widthRightData; //max(widthRight, widthRightData);
      setFinished();
    }
  }

  void updateFromSummary(StockSummary summary, BuildContext? context) {
    if (StringUtils.equalsIgnoreCase(value?.code, summary.code)) {
      value?.price = summary.close!.toDouble();
      value?.change = summary.change!;
      value?.percent = summary.percentChange!;

      // if(gp is WatchlistPrice){

      double widthRightData = RowWatchlist.calculateWidthRight(
          context, value?.price, value?.change, value?.percent);
      widthRight = max(widthRight, widthRightData);
      value?.prevPrice = summary.prev;

      value?.bestBidPrice = summary.bestBidPrice;
      value?.bestBidVolume = summary.bestBidVolume;

      value?.bestOfferPrice = summary.bestOfferPrice;
      value?.bestOfferVolume = summary.bestOfferVolume;
      value?.value = summary.value;

      if (context != null) {
        try {
          value?.notation =
              context.read(remark2Notifier).getSpecialNotation(value?.code);
          value?.status = context
              .read(remark2Notifier)
              .getSpecialNotationStatus(value?.code);
          value?.suspendStock = context
              .read(suspendedStockNotifier)
              .getSuspended(value?.code, Stock.defaultBoardByCode(value?.code));
          if (value?.suspendStock != null) {
            value?.status = StockInformationStatus.Suspended;
          }
          value?.corporateAction =
              context.read(corporateActionEventNotifier).getEvent(value?.code);
          value?.corporateActionColor =
              CorporateActionEvent.getColor(value?.corporateAction);
          String attentionCodes = context
              .read(remark2Notifier)
              .getSpecialNotationCodes(value?.code);
          value?.attentionCodes = attentionCodes;
        } catch (e) {
          print(e);
        }
      }
    }
    setFinished();
  }
}

class ResearchRankNotifier extends BaseValueNotifier<ResearchRank> {
  ResearchRankNotifier(ResearchRank value) : super(value);

  void setValue(ResearchRank? newValue) {
    this.value?.copyValueFrom(newValue!);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class NetBuySellSummaryNotifier
    extends BaseValueNotifier<NetBuySellSummaryData> {
  NetBuySellSummaryNotifier(NetBuySellSummaryData value) : super(value);

  void setValue(NetBuySellSummaryData newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class ChartTopBrokerNotifier extends BaseValueNotifier<DataChartTopBroker> {
  ChartTopBrokerNotifier(DataChartTopBroker value) : super(value);

  void setValue(DataChartTopBroker newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()!) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class ChartTopBrokerNetNotifier
    extends BaseValueNotifier<DataChartTopBrokerNet> {
  ChartTopBrokerNetNotifier(DataChartTopBrokerNet value) : super(value);

  void setValue(DataChartTopBrokerNet newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()!) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class ChartIncomeStatementNotifier
    extends BaseValueNotifier<DataChartIncomeStatement> {
  ChartIncomeStatementNotifier(DataChartIncomeStatement value) : super(value);

  void setValue(DataChartIncomeStatement newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class ChartBalanceSheetNotifier
    extends BaseValueNotifier<DataChartBalanceSheet> {
  ChartBalanceSheetNotifier(DataChartBalanceSheet value) : super(value);

  void setValue(DataChartBalanceSheet newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class ChartCashFlowNotifier extends BaseValueNotifier<DataChartCashFlow> {
  ChartCashFlowNotifier(DataChartCashFlow value) : super(value);

  void setValue(DataChartCashFlow newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class CompanyProfileNotifier extends BaseValueNotifier<DataCompanyProfile> {
  CompanyProfileNotifier(DataCompanyProfile value) : super(value);

  void setValue(DataCompanyProfile newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()!) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class ResultHomeNews {
  List<HomeNews>? datas = List.empty(growable: true);
  bool loaded = false;
  void copyValueFrom(ResultHomeNews? newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas?.clear();
      if (newValue.datas != null) {
        this.datas?.addAll(newValue.datas!);
      }
    } else {
      this.datas?.clear();
    }
  }

  bool? isEmpty() {
    return this.datas != null ? this.datas?.isEmpty : true;
  }

  int? count() {
    return this.datas != null ? this.datas?.length : 0;
  }
}

class HomeNewsNotifier extends BaseValueNotifier<ResultHomeNews> {
  HomeNewsNotifier(ResultHomeNews value) : super(value);

  void setValue(ResultHomeNews newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()!) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class TopUpBanksNotifier extends BaseValueNotifier<ResultTopUpBank> {
  TopUpBanksNotifier(ResultTopUpBank value) : super(value);

  void setValue(ResultTopUpBank newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()!) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class MutasiNotifier extends BaseValueNotifier<ResultMutasi> {
  MutasiNotifier(ResultMutasi value) : super(value);

  void setValue(ResultMutasi newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class BankRDNNotifier extends BaseValueNotifier<BankRDN> {
  BankRDNNotifier(BankRDN value) : super(value);

  void setValue(BankRDN newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class CashPositionNotifier extends BaseValueNotifier<CashPosition> {
  CashPositionNotifier(CashPosition value) : super(value);

  void setValue(CashPosition newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class FundOutTermNotifier extends BaseValueNotifier<ResultFundOutTerm> {
  FundOutTermNotifier(ResultFundOutTerm value) : super(value);

  void setValue(ResultFundOutTerm newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class BankAccountNotifier extends BaseValueNotifier<BankAccount> {
  BankAccountNotifier(BankAccount value) : super(value);

  void setValue(BankAccount newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

class ChartEarningPerShareNotifier
    extends BaseValueNotifier<DataChartEarningPerShare> {
  ChartEarningPerShareNotifier(DataChartEarningPerShare value) : super(value);

  void setValue(DataChartEarningPerShare newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }
}

// class OfferingEIPONotifier extends BaseValueNotifier<OfferingEIPOData>{
//   OfferingEIPONotifier(OfferingEIPOData value) : super(value);
//
//   void setValue(OfferingEIPOData newValue){
//
//     this.value?.copyValueFrom(newValue);
//     if(this.value!.isEmpty()){
//       setNoData();
//     }else{
//       setFinished();
//     }
//   }
// }

class NewsNotifier extends BaseValueNotifier<NewsData> {
  NewsNotifier(NewsData value) : super(value);

  void setValue(NewsData newValue) {
    //this.error = '';
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()!) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  // bool valid() {
  //   return value != null && value.loaded;
  // }
  //
  // bool invalid() {
  //   return !valid();
  // }
  // String error = '';
  // void setError(String error){
  //   this.error = error;
  //   notifyListeners();
  // }
  // bool isError(){
  //   return !StringUtils.isEmtpy(error);
  // }
}

class LoadingNotifier extends ValueNotifier<LoadingData?> {
  LoadingNotifier(LoadingData? value) : super(value);

  void setValue(bool showLoading, String textLoading) {
    this.value?.showLoading = showLoading;
    this.value?.textLoading = textLoading;
    notifyListeners();
  }

  void closeLoading() {
    if (this.value!.showLoading) {
      this.value?.showLoading = false;
      //this.value.textLoading = textLoading;
      notifyListeners();
    }
  }

  bool valid() {
    return value != null;
  }

  bool invalid() {
    return !valid();
  }
}

class StringColorFontNotifier extends ValueNotifier<StringColorFont?> {
  StringColorFontNotifier(StringColorFont? value) : super(value);

  void setValue(String newValue, {Color? newColor, double? fontSize = 0.0}) {
    this.value?.value = newValue;
    if (newColor != null) {
      this.value?.color = newColor;
    }
    if (fontSize! > 0.0) {
      this.value?.fontSize = fontSize;
    }
    notifyListeners();
  }

  bool valid() {
    return value != null;
  }

  bool invalid() {
    return !valid();
  }
}

class StringColorFontBoolNotifier extends ValueNotifier<StringColorFontBool?> {
  StringColorFontBoolNotifier(StringColorFontBool? value) : super(value);

  void setValue(String newValue,
      {Color? newColor, double? fontSize = 0.0, bool? boolFlag}) {
    this.value?.value = newValue;
    if (newColor != null) {
      this.value?.color = newColor;
    }
    if (fontSize! > 0.0) {
      this.value?.fontSize = fontSize;
    }
    if (boolFlag != null) {
      this.value?.flag = boolFlag;
    }
    notifyListeners();
  }

  bool valid() {
    return value != null;
  }

  bool invalid() {
    return !valid();
  }

  void setFlag(bool? flag) {
    if (flag != null && flag != this.value?.flag) {
      this.value?.flag = flag;
      notifyListeners();
    }
  }
}

class IntColorFontNotifier extends ValueNotifier<IntColorFont?> {
  IntColorFontNotifier(IntColorFont? value) : super(value);

  void setValue(int newValue, {Color? newColor, double fontSize = 0.0}) {
    this.value?.value = newValue;
    if (newColor != null) {
      this.value?.color = newColor;
    }
    if (fontSize > 0.0) {
      this.value?.fontSize = fontSize;
    }
    notifyListeners();
  }

  bool valid() {
    return value != null;
  }

  bool invalid() {
    return !valid();
  }
}

class CorporateActionNotifier extends BaseValueNotifier<CorporateActionData> {
  CorporateActionNotifier(CorporateActionData value) : super(value);

  void setValue(CorporateActionData? newValue) {
    this.value?.copyValueFrom(newValue!);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class LabelValueNotifier extends BaseValueNotifier<LabelValueData> {
  LabelValueNotifier(LabelValueData value) : super(value);

  void setValue(LabelValueData newValue) {
    this.value?.copyValueFrom(newValue);
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
    //notifyListeners();
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class EarningPerShareNotifier extends BaseValueNotifier<EarningPerShareData> {
  EarningPerShareNotifier(EarningPerShareData value) : super(value);

  void setValue(EarningPerShareData newValue) {
    this.value?.copyValueFrom(newValue);
    //notifyListeners();
    if (this.value!.isEmpty()) {
      setNoData();
    } else {
      setFinished();
    }
  }

  bool valid() {
    return value != null && value!.loaded;
  }

  bool invalid() {
    return !valid();
  }
}

class IndexSummaryNotifier extends ValueNotifier<IndexSummary?> {
  Index? index;

  IndexSummaryNotifier(IndexSummary? value, this.index) : super(value);

  void setIndex(Index newIndex) {
    if (this.index == null) {
      this.index = newIndex;
    } else {
      this.index!.copyValueFrom(newIndex);
    }

    notifyListeners();
  }

  bool valid() {
    return index != null && value != null;
  }

  bool invalid() {
    return index == null || value == null;
  }

  @override
  void dispose() {
    this.index = null;
    super.dispose();
  }

  void setData(IndexSummary newValue) {
    if (this.value == null) {
      this.value = newValue;
    } else {
      this.value?.copyValueFrom(newValue);
    }

    notifyListeners();
  }
}

class StockSummaryNotifier extends ValueNotifier<StockSummary?> {
  Stock? stock;

  StockSummaryNotifier(StockSummary value, this.stock) : super(value);

  void setStock(Stock newStock) {
    // if (this.stock == null) {
    this.stock = newStock;
    // } else {
    //   this.stock.copyValueFrom(newStock);
    // }

    notifyListeners();
  }

  bool valid() {
    return stock != null && value != null;
  }

  bool invalid() {
    return stock == null || value == null;
  }

  @override
  void dispose() {
    this.stock = null;
    super.dispose();
  }

  void setData(StockSummary newValue) {
    if (this.value == null) {
      this.value = newValue;
    } else {
      this.value?.copyValueFrom(newValue);
    }

    notifyListeners();
  }
}

class OrderBookNotifier extends ValueNotifier<OrderBook?> {
  Stock? stock;

  OrderBookNotifier(OrderBook value, this.stock) : super(value);

  void setStock(Stock newStock) {
    //if (this.stock == null) {
    this.stock = newStock;
    //} else {
    //this.stock.copyValueFrom(newStock);
    //}

    notifyListeners();
  }

  bool valid() {
    return stock != null && value != null;
  }

  bool invalid() {
    return stock == null || value == null;
  }

  @override
  void dispose() {
    this.stock = null;
    super.dispose();
  }

  void setData(OrderBook newValue) {
    if (this.value == null) {
      this.value = newValue;
    } else {
      this.value?.copyValueFrom(newValue);
    }

    notifyListeners();
  }
}

class RangeNotifier extends ValueNotifier<Range?> {
  RangeNotifier(Range value) : super(value);

  void setRange(Range newRange) {
    //if (this.value == null) {
    print('RangeNotifier setRange = ' + newRange.index.toString());
    this.value = newRange;
    // } else {
    //   this.value?.copyValueFrom(newStock);
    // }

    notifyListeners();
  }

  void setIndex(int index) {
    if (this.value == null) {
      this.value = Range.createBasic();
    }
    this.value?.index = index;
    notifyListeners();
  }

  void setFrom(String from) {
    if (this.value == null) {
      this.value = Range.createBasic();
    }
    this.value?.from = from;
    if (customRangeIsValid()) {
      notifyListeners();
    }
  }

  void setTo(String to) {
    if (this.value == null) {
      this.value = Range.createBasic();
    }
    this.value?.to = to;
    if (customRangeIsValid()) {
      notifyListeners();
    }
  }

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  MyRange getRange() {
    DateTime? from;
    DateTime? to;
    //widget.callbackRange(_listChipRange[_selectedRange]);
    //  0      1    2     3      4     5    6      7
    //['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];
    if (value?.index == 0) {
      MyRange range = MyRange();
      range.from = 'LD';
      range.to = 'LD';
      range.index = value?.index;
      return range;
    } else if (value?.index == 7) {
      MyRange? range = MyRange();
      range.from = StringUtils.equalsIgnoreCase(value?.from, 'from_label'.tr())
          ? ''
          : value?.from;
      range.to = StringUtils.equalsIgnoreCase(value?.to, 'to_label'.tr())
          ? ''
          : value?.to;
      range.index = value!.index;
      return range;
    }
    switch (value?.index) {
      case 0:
        {
          to = DateTime.now();
          from = DateTime.now();
        }
        break;
      case 1:
        {
          to = DateTime.now();
          from = DateTime.now().add(Duration(days: -7)); // - week
        }
        break;
      case 2:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 1, to.day); // - 1 month
        }
        break;
      case 3:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 3, to.day); // - 3 month
        }
        break;
      case 4:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 6, to.day); // - 6 month
        }
        break;
      case 5:
        {
          to = DateTime.now();
          from = new DateTime(to.year - 1, to.month, to.day); // - 1 year
        }
        break;
      case 6:
        {
          to = DateTime.now();
          from = new DateTime(to.year - 5, to.month, to.day); // - 5 year
        }
        break;
      case 7:
        {
          to = DateTime.now();
          from = new DateTime(1945, 8, 17); // Custom Range - di atas
        }
        break;
    }
    MyRange range = MyRange();
    range.from = from == null ? '' : _dateFormat.format(from);
    range.to = to == null ? '' : _dateFormat.format(to);
    range.index = value?.index;
    return range;
  }

  bool valid() {
    return value != null;
  }

  bool customRangeIsValid() {
    return !StringUtils.equalsIgnoreCase(this.value?.from, 'from_label'.tr()) &&
        !StringUtils.equalsIgnoreCase(this.value?.to, 'to_label'.tr());
  }

  bool invalid() {
    return value == null;
  }
}

class StockNotifier extends ValueNotifier<Stock?> {
  StockNotifier(Stock? value) : super(value);

  void setStock(Stock newStock) {
    //if (this.value == null) {
    print('StockNotifier setStock = ' + newStock.code!);
    this.value = newStock;
    // } else {
    //   this.value?.copyValueFrom(newStock);
    // }

    notifyListeners();
  }

  bool valid() {
    return value != null;
  }

  bool invalid() {
    return value == null;
  }
}

/*
class OrderDataNotifier extends ValueNotifier<OrderData> {
  OrderDataNotifier(OrderData value) : super(value);


  void setData(OrderData newValue) {
    //if (this.value == null) {
    this.value = newValue;
    // } else {
    //   this.value?.copyValueFrom(newStock);
    // }

    notifyListeners();
  }

  void update({String account, String stock_code, String stock_name, String orderType, int price, int lot, int value, int tradingLimitUsage}){
    if(account != null){
      this.value.account = account;
    }
    if(stock_code != null){
      this.value.stock_code = stock_code;
    }
    if(stock_name != null){
      this.value.stock_name = stock_name;
    }
    if(orderType != null){
      this.value.orderType = orderType;
    }
    // if(price != null){
    //   this.value.price = price;
    // }
    // if(lot != null){
    //   this.value.lot = lot;
    // }
    if(price != null && lot != null){
      this.value.clearPriceLot();
      this.value.addPriceLot(price, lot);
    }

    if(value != null){
      this.value.value = value;
    }
    if(tradingLimitUsage != null){
      this.value.tradingLimitUsage = tradingLimitUsage;
    }
    notifyListeners();
  }
}
*/
class TradeBookNotifier extends ValueNotifier<TradeBook?> {
  Stock? stock;

  TradeBookNotifier(TradeBook value, this.stock) : super(value);

  void setStock(Stock newStock) {
    //if (this.stock == null) {
    this.stock = newStock;
    //} else {
    //this.stock.copyValueFrom(newStock);
    //}

    notifyListeners();
  }

  bool valid() {
    return stock != null && value != null;
  }

  bool invalid() {
    return stock == null || value == null;
  }

  @override
  void dispose() {
    this.stock = null;
    super.dispose();
  }

  void setData(TradeBook newValue) {
    if (this.value == null) {
      this.value = newValue;
    } else {
      this.value?.copyValueFrom(newValue);
    }

    notifyListeners();
  }
}

class TradeCalculateNotifier extends ChangeNotifier {
  final OrderType _orderType;
  bool fastMode = false;
  bool active = false;
  TradeCalculateNotifier(this._orderType);

  void updateMode(bool _fastMode) {
    this.fastMode = _fastMode;
    notifyListeners();
  }

  void updateActive(bool _active) {
    this.active = _active;
    notifyListeners();
  }

  String toString() {
    return 'OrderType : ' +
        _orderType.index.toString() +
        '  fastMode : $fastMode  active : $active';
  }

  bool canNormalModeCalculate(OrderType orderType) {
    return !fastMode && this._orderType == orderType && active;
  }

  bool canFastModeCalculate(OrderType orderType) {
    return fastMode && this._orderType == orderType && active;
  }
}
