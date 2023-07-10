import 'dart:async';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/text_button_retry.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/serializeable.dart';
import 'package:Investrend/objects/sosmed_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/redis/RedisConnectionListener.dart';
import 'package:Investrend/redis/RedisConnector.dart';
import 'package:Investrend/redis/RedisStreamerConnector.dart';
import 'package:Investrend/redis/RedisStreamerReceiver.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/screen_settings.dart';
import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

//import 'package:dartis/dartis.dart';
enum NotifierState { Loading, NoData, Error, Finished }

enum StockInformationStatus { SpecialNotation, UnderWatchlist, Suspended }

extension StockInformationStateExtension on StockInformationStatus {
  String get image {
    switch (this) {
      case StockInformationStatus.SpecialNotation:
        return 'images/icons/special_notation.png';
      case StockInformationStatus.UnderWatchlist:
        return 'images/icons/under_watchlist.png';
      case StockInformationStatus.Suspended:
        return 'images/icons/suspended.png';
      default:
        return '';
    }
  }
  Color get colorBackground {
    switch (this) {
      case StockInformationStatus.SpecialNotation:
        return InvestrendTheme.attentionColor;
      case StockInformationStatus.UnderWatchlist:
        return InvestrendTheme.attentionColor;
      case StockInformationStatus.Suspended:
        return InvestrendTheme.attentionColor;
      default:
        return Colors.transparent;
    }
  }
  Color get colorBorder {
    switch (this) {
      case StockInformationStatus.SpecialNotation:
        return InvestrendTheme.attentionColor;
      case StockInformationStatus.UnderWatchlist:
        return InvestrendTheme.redText;
      case StockInformationStatus.Suspended:
        return InvestrendTheme.redText;
      default:
        return Colors.transparent;
    }
  }
  bool get strip{
    switch (this) {
      case StockInformationStatus.SpecialNotation:
        return false;
      case StockInformationStatus.UnderWatchlist:
        return false;
      case StockInformationStatus.Suspended:
        return true;
      default:
        return false;
    }
  }
}

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

  Widget getNoWidget({VoidCallback onRetry}) {
    Widget noWidget;
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

class PrimaryStockChangeNotifier extends ChangeNotifier {
  Stock stock = Stock('', '');

  bool isValid() {
    return stock != null && stock.isValid();
  }

  bool invalid() {
    return !isValid();
  }

  void setStock(Stock newValue) {
    bool changedCode = stock.copyValueFrom(newValue);
    if (changedCode) {
      notifyListeners();
    }
  }
// @override
// void addListener(listener) {
//   // TODO: implement addListener
//   super.addListener(listener);
// }

}

final primaryStockChangeNotifier = ChangeNotifierProvider<PrimaryStockChangeNotifier>((ref) {
  return PrimaryStockChangeNotifier();
});

class StockDetailRefreshNotifier extends ChangeNotifier {
  String triggerByRoute = '';

  void setRoute(String trigger) {
    this.triggerByRoute = trigger;
    notifyListeners();
  }
}

final stockDetailRefreshChangeNotifier = ChangeNotifierProvider<StockDetailRefreshNotifier>((ref) {
  return StockDetailRefreshNotifier();
});

class StockDetailScreenVisibilityChangeNotifier extends ChangeNotifier {
  bool main = false;
  List<bool> tabs = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  void setActiveMain(bool active) {
    bool current = isStockDetailActive();
    main = active;

    bool after = isStockDetailActive();
    if (current != after) {
      notifyListeners();
    }
  }

  void setActive(int indexTab, bool active) {
    bool current = isStockDetailActive();
    tabs[indexTab] = active;
    bool after = isStockDetailActive();
    if (current != after) {
      notifyListeners();
    }
  }

  bool isStockDetailActive() {
    bool result = false;
    if (main) {
      result = true;
      return result;
    }
    for (var active in tabs) {
      if (active) {
        result = true;
        break;
      }
    }
    return result;
  }
}

final stockDetailScreenVisibilityChangeNotifier = ChangeNotifierProvider<StockDetailScreenVisibilityChangeNotifier>((ref) {
  return StockDetailScreenVisibilityChangeNotifier();
});

class IndexChangeNotifier extends ChangeNotifier {
  int index = 0;

  void setIndex(int _index) {
    this.index = _index;
    notifyListeners();
  }
}

class TransactionFilterIntradayChangeNotifier extends ChangeNotifier {
  int index_transaction = 0;
  int index_status = 0;

  void setIndex(int IndexTransaction, int IndexStatus) {
    this.index_transaction = IndexTransaction;
    this.index_status = IndexStatus;
    notifyListeners();
  }

  void setIndexTransaction(int _index) {
    this.index_transaction = _index;
    notifyListeners();
  }

  void setIndexStatus(int _index) {
    this.index_status = _index;
    notifyListeners();
  }
}

final transactionIntradayFilterChangeNotifier = ChangeNotifierProvider<TransactionFilterIntradayChangeNotifier>((ref) {
  return TransactionFilterIntradayChangeNotifier();
});

class TransactionFilterHistoricalChangeNotifier extends ChangeNotifier {
  int index_transaction = 0;
  int index_period = 0;

  void setIndex(int IndexTransaction, int IndexPeriod) {
    this.index_transaction = IndexTransaction;
    this.index_period = IndexPeriod;
    notifyListeners();
  }

  void setIndexTransaction(int _index) {
    this.index_transaction = _index;
    notifyListeners();
  }

  void setIndexStatus(int _index) {
    this.index_period = _index;
    notifyListeners();
  }
}

final transactionHistoricalFilterChangeNotifier = ChangeNotifierProvider<TransactionFilterHistoricalChangeNotifier>((ref) {
  return TransactionFilterHistoricalChangeNotifier();
});

class AvatarChangeNotifier extends ChangeNotifier {
  String _urlProfile = '';

  bool invalid() {
    return StringUtils.isEmtpy(_urlProfile);
  }

  String get url => _urlProfile;

  void setUrl(String url) {
    this._urlProfile = url;
    notifyListeners();
  }
}

final avatarChangeNotifier = ChangeNotifierProvider<AvatarChangeNotifier>((ref) {
  return AvatarChangeNotifier();
});
final marketChangeNotifier = ChangeNotifierProvider<IndexChangeNotifier>((ref) {
  return IndexChangeNotifier();
});

final mainTabNotifier = ChangeNotifierProvider<IndexChangeNotifier>((ref) {
  return IndexChangeNotifier();
});

final themeModeNotifier = ChangeNotifierProvider<IndexChangeNotifier>((ref) {
  return IndexChangeNotifier();
});
enum ActiveActionType { DoUpdate, ScrollUp, Unknown }

final sosmedActiveActionNotifier = ChangeNotifierProvider<IndexChangeNotifier>((ref) {
  return IndexChangeNotifier();
});

final streamerStatusNotifier = ChangeNotifierProvider<IndexChangeNotifier>((ref) {
  return IndexChangeNotifier();
});

class AccountChangeNotifier extends ChangeNotifier {
  int index = 0;

  void setIndex(int _index) {
    this.index = _index;
    notifyListeners();
  }
}

final accountChangeNotifier = ChangeNotifierProvider<AccountChangeNotifier>((ref) {
  return AccountChangeNotifier();
});

class IndexSummaryChangeNotifier extends ChangeNotifier {
  Index index = Index('', '', '', '', '', false, false);
  IndexSummary summary = IndexSummary('');

  bool isValid() {
    return index != null && index.isValid() && summary != null && summary.isValid();
  }

  bool invalid() {
    return !isValid();
  }

  void setStock(Index newValue) {
    if (newValue == null || !StringUtils.equalsIgnoreCase(newValue.code, index.code)) {
      this.summary.copyValueFrom(null);
    }
    index.copyValueFrom(newValue);
    notifyListeners();
  }

  void setData(IndexSummary newValue) {
    // if (this.value == null) {
    //   this.value = newValue;
    // } else {
    this.summary.copyValueFrom(newValue);
    notifyListeners();
    // }
  }
}

final indexSummaryChangeNotifier = ChangeNotifierProvider<IndexSummaryChangeNotifier>((ref) {
  return IndexSummaryChangeNotifier();
});

class StockSummaryChangeNotifier extends ChangeNotifier {
  Stock stock = Stock('', '');
  StockSummary summary = StockSummary('', '');

  bool isValid() {
    return stock != null && stock.isValid() && summary != null && summary.isValid();
  }

  bool invalid() {
    return !isValid();
  }

  void setStock(Stock newValue) {
    if (newValue == null || !StringUtils.equalsIgnoreCase(newValue.code, stock.code)) {
      this.summary.copyValueFrom(null);
    }
    if (newValue != null) {
      this.summary.code = newValue.code;
      this.summary.board = newValue.defaultBoard;
    }
    stock.copyValueFrom(newValue);
    notifyListeners();
  }

  void setData(StockSummary newValue,{bool check = false}) {
    // if (this.value == null) {
    //   this.value = newValue;
    // } else {

    if(check){ // check untuk sama tidak nya dengan yg active sekarang
      if(newValue != null
          && StringUtils.equalsIgnoreCase(this.summary.code, newValue.code)
          && StringUtils.equalsIgnoreCase(this.summary.board, newValue.board)
      ){
        this.summary.copyValueFrom(newValue);
      }
    }else{
      this.summary.copyValueFrom(newValue);
    }
    // ASLI 2022-06-08
    //this.summary.copyValueFrom(newValue);
    notifyListeners();
    // }
  }
}

final stockSummaryChangeNotifier = ChangeNotifierProvider<StockSummaryChangeNotifier>((ref) {
  return StockSummaryChangeNotifier();
});

class BaseChangeNotifier extends ChangeNotifier {
  NotifierState currentState = NotifierState.Loading;
  String currentMessage = '';

  void setState(NotifierState newState, {String message}) {
    this.currentState = newState;
    if (message != null) {
      this.currentMessage = message;
    }
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

  void setError({String message}) {
    setState(NotifierState.Error, message: message);
  }
}

class OrderBookChangeNotifier extends BaseChangeNotifier {
  Stock stock = new Stock('', '');
  OrderBook orderbook = OrderBook.createBasic();

  bool isValid() {
    return stock != null && stock.isValid() && orderbook != null && orderbook.isValid();
  }

  bool invalid() {
    return !isValid();
  }

  void setStock(Stock newValue) {
    if (newValue == null || !StringUtils.equalsIgnoreCase(newValue.code, stock.code)) {
      this.orderbook.copyValueFrom(null);
    }

    if (newValue != null) {
      this.orderbook.code = newValue.code;
      this.orderbook.board = newValue.defaultBoard;
    }

    stock.copyValueFrom(newValue);
    notifyListeners();
  }

  void setData(OrderBook newValue) {
    // if (this.value == null) {
    //   this.value = newValue;
    // } else {
    this.orderbook.copyValueFrom(newValue);
    notifyListeners();
    // }
  }
}

final orderBookChangeNotifier = ChangeNotifierProvider<OrderBookChangeNotifier>((ref) {
  return OrderBookChangeNotifier();
});

class TradeBookChangeNotifier extends ChangeNotifier {
  Stock stock = Stock('', '');
  TradeBook tradebook = TradeBook.createBasic();

  bool isValid() {
    return stock != null && stock.isValid() && tradebook != null && tradebook.isValid();
  }

  bool invalid() {
    return !isValid();
  }

  bool isLoaded() {
    return (tradebook != null ? tradebook.loaded : false);
  }

  void setStock(Stock newValue) {
    if (newValue == null || !StringUtils.equalsIgnoreCase(newValue.code, stock.code)) {
      this.tradebook.copyValueFrom(null);
    }
    if (newValue != null) {
      this.tradebook.code = newValue.code;
      this.tradebook.board = newValue.defaultBoard;
    }
    stock.copyValueFrom(newValue);
    notifyListeners();
  }

  void setData(TradeBook newValue) {
    // if (this.value == null) {
    //   this.value = newValue;
    // } else {
    this.tradebook.copyValueFrom(newValue);
    notifyListeners();
    // }
  }
}

final tradeBookChangeNotifier = ChangeNotifierProvider<TradeBookChangeNotifier>((ref) {
  return TradeBookChangeNotifier();
});

class ClearOrderChangeNotifier extends ChangeNotifier {
  void mustNotifyListener() {
    notifyListeners();
  }
}

final clearOrderChangeNotifier = ChangeNotifierProvider<ClearOrderChangeNotifier>((ref) {
  return ClearOrderChangeNotifier();
});
class StatusRefreshNotifier extends ChangeNotifier {
  String time = '';
  String refresh_type     = '';
  String account_code     = '';
  String parent_order_id  = '';
  String child_order_id   = '';
  String trade_no         = '';
  void setData(
    String time,
    String refreshType,
    String accountCode,
    String parentOrderId,
    String childOrderId,
    String tradeNo

      ){
    this.time = time;
    this.refresh_type     = refreshType;
    this.account_code     = accountCode;
    this.parent_order_id  = parentOrderId;
    this.child_order_id   = childOrderId;
    this.trade_no         = tradeNo;
    notifyListeners();
  }
}
final statusRefreshNotifier = ChangeNotifierProvider<StatusRefreshNotifier>((ref) {
  return StatusRefreshNotifier();
});
class BuySellChangeNotifier extends ChangeNotifier {
  Buy buyData = Buy();
  Sell sellData = Sell();

  BuySell getData(OrderType type) {
    //if(type == buyData.orderType){
    if (type.isBuyOrAmendBuy()) {
      return buyData;
      //}else if(type == sellData.orderType){
    } else if (type.isSellOrAmendSell()) {
      return sellData;
    }
  }

  void setData(BuySell buySell) {
    if (buySell.orderType.isBuyOrAmendBuy()) {
      buyData.copyFrom(buySell);
    } else {
      sellData.copyFrom(buySell);
    }
  }

  void setFastMode(bool _fastMode) {
    buyData.setFastMode(_fastMode);
    sellData.setFastMode(_fastMode);
  }

  void setStock(String code, String name) {
    buyData.setStock(code, name);
    sellData.setStock(code, name);
  }

  void clearOnStockChanged() {
    buyData.clearFastPriceLot();
    sellData.clearFastPriceLot();
  }

  void mustNotifyListener() {
    notifyListeners();
  }
}

final buySellChangeNotifier = ChangeNotifierProvider<BuySellChangeNotifier>((ref) {
  return BuySellChangeNotifier();
});

final amendChangeNotifier = ChangeNotifierProvider<BuySellChangeNotifier>((ref) {
  return BuySellChangeNotifier();
});

class OrderDataChangeNotifier extends ChangeNotifier {
  String accountType = '';
  String accountName = '';
  String stock_code = ''; //stock code
  String stock_name = ''; // stock name
  OrderType orderType = OrderType.Buy;
  int value = 0;
  bool fastMode = false;
  int tradingLimitUsage = 0;
  List<PriceLot> _listPriceLot = List.empty(growable: true);

  List<PriceLot> get listPriceLot => _listPriceLot;

  bool addPriceLot(int price, int lot) {
    bool added = false;
    if (price > 0 && lot > 0) {
      listPriceLot.add(PriceLot(price, lot));
      added = true;
    }
    return added;
  }

  void clearPriceLot() {
    listPriceLot.clear();
  }

  bool isValid() {
    return !StringUtils.isEmtpy(stock_code);
  }

  bool invalid() {
    return !isValid();
  }

  void update(
      {String accountType,
      String accountName,
      String stock_code,
      String stock_name,
      OrderType orderType,
      int price,
      int lot,
      int value,
      int tradingLimitUsage,
      bool fastMode}) {
    if (accountType != null) {
      this.accountType = accountType;
    }
    if (accountName != null) {
      this.accountName = accountName;
    }
    if (stock_code != null) {
      this.stock_code = stock_code;
    }
    if (stock_name != null) {
      this.stock_name = stock_name;
    }
    if (orderType != null) {
      this.orderType = orderType;
    }
    if (price != null && lot != null) {
      this.clearPriceLot();
      this.addPriceLot(price, lot);
    }

    if (value != null) {
      this.value = value;
    }
    if (tradingLimitUsage != null) {
      this.tradingLimitUsage = tradingLimitUsage;
    }
    if (fastMode != null) {
      this.fastMode = fastMode;
    }
    notifyListeners();
  }
}

final orderDataChangeNotifier = ChangeNotifierProvider<OrderDataChangeNotifier>((ref) {
  return OrderDataChangeNotifier();
});

// "IDX.ORDER";
final managerDatafeedNotifier = ChangeNotifierProvider<ManagerDatafeed>((ref) {
  return ManagerDatafeed();
});

final managerEventNotifier = ChangeNotifierProvider<ManagerDatafeed>((ref) {
  return ManagerDatafeed();
});

class Subscription {
  final bool psubscribe;
  final String channel;
  final ListStringCallback listener;
  final Function validator;
  final bool receiveUnknownMessage;
  Subscription(this.channel, this.listener, this.validator, {this.receiveUnknownMessage = true, this.psubscribe = false});

  String asCommand() {
    return '';
  }
  bool matchPattern(String key){
    return false;
  }
}

class PsubscribeAndHGET extends Subscription {
  final String key;
  final String field;

  String asCommand() {
    return 'HGET $key $field';
  }

  bool matchPattern(String channel){
    List<String> patterns = key.split('*');
    Utils.printList(patterns, caller: 'matchPattern $key : $channel');
    int count = patterns == null ? 0 : patterns.length;
    List<bool> result = List.empty(growable: true);
    if(patterns != null && patterns.isNotEmpty){
      for (int i = 0; i<count; i++){
        if(i == 0){
          String pattern = patterns.first;
          bool ok =  channel.startsWith(pattern);
          result.add(ok);
        }else{
          String pattern = patterns.elementAt(i);
          bool ok =  channel.contains(pattern);
          result.add(ok);
        }
      }
      int countResult = result == null ? 0 : result.length;
      bool ok = true;
      for (int i = 0; i<countResult; i++){
        if(!result.elementAt(i)){
          ok = false;
          break;
        }
      }
      return ok;
    }
    return false;
  }
  PsubscribeAndHGET(String channel, this.key, this.field, {ListStringCallback listener, Function validator,bool receiveUnknownMessage=true})
      : super(channel, listener, validator, receiveUnknownMessage: receiveUnknownMessage, psubscribe: true);
}


class SubscribeAndHGET extends Subscription {
  final String key;
  final String field;

  String asCommand() {
    return 'HGET $key $field';
  }

  SubscribeAndHGET(String channel, this.key, this.field, {ListStringCallback listener, Function validator,bool receiveUnknownMessage=true})
      : super(channel, listener, validator, receiveUnknownMessage: receiveUnknownMessage);
}

class SubscribeAndGET extends Subscription {
  final String key;

  String asCommand() {
    return 'GET $key';
  }

  SubscribeAndGET(
    String channel,
    this.key, {
    ListStringCallback listener,
    Function validator,
  }) : super(channel, listener, validator);
}

//                                        collection                            |
enum DatafeedType {
  Summary,
  Indices,
  Orderbook,
  Tradebook,
  StockForeignDomestic,
  SingleSignON,
  Status,

  // no channel
  CompositeForeignDomestic,

}

extension DatafeedTypeExtension on DatafeedType {
  String get type {
    switch (this) {
      case DatafeedType.Status:
        return 'C';
      case DatafeedType.Summary:
        return 'Q';
      case DatafeedType.Indices:
        return 'Z';
      case DatafeedType.Orderbook:
        return 'N';
      case DatafeedType.Tradebook:
        return 'M';
      case DatafeedType.StockForeignDomestic:
        return 'T';
      case DatafeedType.CompositeForeignDomestic:
        return 'Y';
      case DatafeedType.SingleSignON:
        return 'L';
      default:
        return '#unknown_type';
    }
  }

  // final String COLLECTION = 'C';
  // final String HASH 		  = 'H';
  // final String KEY	 	    = 'K';
  // final String SORTED_SET	= 'SS';
  String get key {
    return 'K' + this.type;
    /*
    switch (this) {
      case DatafeedType.Status:
        return 'KC';
      case DatafeedType.Summary:
        return 'KQ';
      case DatafeedType.Indices:
        return 'KZ';
      case DatafeedType.Orderbook:
        return 'KN';
      case DatafeedType.Tradebook:
        return 'KM';
      case DatafeedType.StockForeignDomestic:
        return 'KT';
      default:
        return '#unknown_type';
    }
    */
  }

  String get collection {
    if (this.index < DatafeedType.Status.index) {
      return 'C' + this.type;
    } else {
      return '#unknown_collection';
    }
    /*
    switch (this) {
      case DatafeedType.Summary:
        return 'CQ';
      case DatafeedType.Indices:
        return 'CZ';
      case DatafeedType.Orderbook:
        return 'CN';
      case DatafeedType.Tradebook:
        return 'CM';
      default:
        return '#unknown_collection';
    }
    */
  }
}
// //final String TYPE_SUMMARY 				  = 'Q'; // 'SUMMARY';
// final String TYPE_SUMMARY_LIST 			= 'W'; // 'SUMMARY_LIST';
// final String TYPE_SUMMARY_SHORT			= 'E'; // 'SUMMARY_SHORT';
// final String TYPE_STOCK 				    = 'R'; // 'STOCK';
// //final String TYPE_STOCK_FD				  = 'T'; // 'STOCK_FD';
// //final String TYPE_COMPOSITE_FD			= 'Y'; // 'COMPOSITE_FD';
// final String TYPE_STOCK_SHORT			  = 'U'; // 'STOCK_SHORT';
// final String TYPE_BROKER 				    = 'I'; // 'BROKER';
// final String TYPE_TRADE 				    = 'O'; // 'TRADE';
// //final String TYPE_INDICES 				  = 'Z'; // 'INDICES';
// final String TYPE_INDICES_STOCK			= 'X'; // 'INDICES_STOCK';
// //final String TYPE_STATUS 				    = 'C'; // 'STATUS';
// final String TYPE_NEWS	 				    = 'V'; // 'NEWS';
// final String TYPE_INFO	 				    = 'B'; // 'INFO';
// //final String TYPE_ORDERBOOK 			  = 'N'; // 'ORDERBOOK';
// //final String TYPE_TRADEBOOK 			  = 'M'; // 'TRADEBOOK';
// final String TYPE_ORDER					    = 'A'; // 'ORDER';
// final String TYPE_ORDERBOOK_QUEUE		= 'S'; // 'ORDER_QUEUE';
// final String TYPE_ORDERBOOK_QUEUE_DETAIL= 'D'; // 'ORDERBOOK_QUEUE_DETAIL';
//
// // final String COLLECTION = 'C';
// // final String HASH 		  = 'H';
// // final String KEY	 	    = 'K';
// // final String SORTED_SET	= 'SS';
//
// // String COLLECTION_SUMMARY; // 	= COLLECTION + TYPE_SUMMARY; 			// "IDX.SUMMARY";
// // String COLLECTION_INDICES; // 	= COLLECTION + TYPE_INDICES; 			// "IDX.INDICES";
// // String COLLECTION_ORDERBOOK; // 	= COLLECTION + TYPE_ORDERBOOK; 		// "IDX.ORDERBOOK";
// // String COLLECTION_STOCK_FD; //	= COLLECTION + TYPE_STOCK_FD; 		// "IDX.STOCK_FD";
// // String COLLECTION_TRADEBOOK; // 	= COLLECTION + TYPE_TRADEBOOK; 		// "IDX.TRADEBOOK";
enum RedisSubscriptionType {
  Subscribe,
  Unsubscribe,
  Psubscribe,
  Punsubscribe,
}
extension RedisSubscriptionTypeExtension on RedisSubscriptionType {
  String get commandType {
    switch (this) {
      case RedisSubscriptionType.Subscribe:
        return 'SUBSCRIBE';
      case RedisSubscriptionType.Unsubscribe:
        return 'UNSUBSCRIBE';
      case RedisSubscriptionType.Psubscribe:
        return 'PUNSUBSCRIBE';
      case RedisSubscriptionType.Punsubscribe:
        return 'PUNSUBSCRIBE';
      default:
        return '#unknown_type';
    }
  }
}
class WrapperSubscription {
  Subscription subscription;
  // bool subscribe = false;
  // bool psubscribe = false;
  RedisSubscriptionType type;
  String caller = '';

  WrapperSubscription(this.subscription, this.type, {/*this.subscribe = false, this.psubscribe = false,*/ this.caller = ''});
}

class ManagerDatafeed extends ChangeNotifier implements RedisConnectionListener, RedisStreamerReceiver {
  //bool _maintainConnection = false;
  RedisStreamerConnector redisConnector;

  Color statusColor = Colors.white;

  Timer timer;

  bool isInitialized() {
    return redisConnector != null;
  }

  List<String> _subscribeValid = List.empty(growable: true);
  List<String> _psubscribeValid = List.empty(growable: true);

  List<WrapperSubscription> _queue = List.empty(growable: true);
  Map<String, List<Subscription>> subscriptions = Map();

  //Map<String, StringIndex> gets = Map();

  void _sendGetSubcribe(RedisConnector connector) async {
    String gets;
    String subs;


    subscriptions.forEach((key, value) {
      DebugWriter.info('_sendGetSubcribe Key = $key : listeners = ' + value.length.toString());

      if (value.length > 0) {
        /*
        if (StringUtils.isEmtpy(gets)) {
          gets = value.first.asCommand();
          subs = 'SUBSCRIBE $key';
        } else {
          gets += '\r\n' + value.first.asCommand();
          subs += '\r\nSUBSCRIBE $key';
        }
        */
        bool psubscribe = value.first is PsubscribeAndHGET;
        if (StringUtils.isEmtpy(gets)) {
          gets = value.first.asCommand();
          //subs = 'SUBSCRIBE $key';

          if(psubscribe){
            subs = 'PSUBSCRIBE $key';
          }else{
            subs = 'SUBSCRIBE $key';
          }
          //unsubs = 'UNSUBSCRIBE $key';
        } else {
          gets += '\r\n' + value.first.asCommand();
          //subs += '\r\nSUBSCRIBE $key';

          if(psubscribe){
            subs += '\r\nPSUBSCRIBE $key';
          }else{
            subs += '\r\nSUBSCRIBE $key';
          }
          //unsubs += '\r\nUNSUBSCRIBE $key';
        }

      }



    });
    if (!StringUtils.isEmtpy(gets)) {
      String getsSubs = '$gets\r\n$subs';
      connector.writeToServer(getsSubs);
    }
  }

  void _resendGetSubcribe(RedisConnector connector, {String skipUnsubscribeChannel}) async {
    String gets;
    String subs;
    String unsubs;
    Utils.printList(_subscribeValid, caller: '_resendGetSubcribe._subscribeValid');
    _subscribeValid.forEach((channel) {
      if (StringUtils.isEmtpy(unsubs)) {
        unsubs = 'UNSUBSCRIBE $channel';
      } else {
        unsubs += '\r\nUNSUBSCRIBE $channel';
      }
    });

    Utils.printList(_psubscribeValid, caller: '_resendGetSubcribe._psubscribeValid');
    _psubscribeValid.forEach((channel) {
      if (StringUtils.isEmtpy(unsubs)) {
        unsubs = 'PUNSUBSCRIBE $channel';
      } else {
        unsubs += '\r\nPUNSUBSCRIBE $channel';
      }
    });

    subscriptions.forEach((key, value) {
      DebugWriter.info('_resendGetSubcribe Key = $key : listeners = ' + value.length.toString());

      if (value.length > 0) {

        bool psubscribe = value.first is PsubscribeAndHGET;
        if (StringUtils.isEmtpy(gets)) {
          gets = value.first.asCommand();
          //subs = 'SUBSCRIBE $key';

          if(psubscribe){
            subs = 'PSUBSCRIBE $key';
          }else{
            subs = 'SUBSCRIBE $key';
          }
          //unsubs = 'UNSUBSCRIBE $key';
        } else {
          gets += '\r\n' + value.first.asCommand();
          //subs += '\r\nSUBSCRIBE $key';

          if(psubscribe){
            subs += '\r\nPSUBSCRIBE $key';
          }else{
            subs += '\r\nSUBSCRIBE $key';
          }
          //unsubs += '\r\nUNSUBSCRIBE $key';
        }




        /*
        if(StringUtils.isEmtpy(unsubs)) {
          //gets = value.first.asCommand();
          //subs = 'SUBSCRIBE $key';
          if(!StringUtils.equalsIgnoreCase(skipUnsubscribeChannel, key)){
            unsubs = 'UNSUBSCRIBE $key';
          }

        }else{
          //gets += '\r\n' + value.first.asCommand();
          //subs += '\r\nSUBSCRIBE $key';
          if(!StringUtils.equalsIgnoreCase(skipUnsubscribeChannel, key)) {
            unsubs += '\r\nUNSUBSCRIBE $key';
          }
        }
         */

      }
    });
    if (!StringUtils.isEmtpy(gets)) {
      //String unsubsGetsSubs = '$unsubs\r\n$gets\r\n$subs';
      //await connector.writeToServer(unsubsGetsSubs);

      DebugWriter.info('unsubs : $unsubs');
      DebugWriter.info('gets : $gets');
      DebugWriter.info('subs : $subs');
      if(!StringUtils.isEmtpy(unsubs)){
        connector.writeToServer(unsubs);
      }
      connector.writeToServer(gets);
      connector.writeToServer(subs);
    }
  }

  void subscribe(Subscription subscription, String caller) {
    //_queue.add(WrapperSubscription(subscription, true, caller: caller));
    //_queue.add(WrapperSubscription(subscription, subscribe: true, caller: caller));
    _queue.add(WrapperSubscription(subscription, RedisSubscriptionType.Subscribe, caller: caller));
  }

  void psubscribe(Subscription subscription, String caller) {
    //_queue.add(WrapperSubscription(subscription, true, caller: caller));
    _queue.add(WrapperSubscription(subscription, RedisSubscriptionType.Psubscribe, caller: caller));
  }


  void _subscribe(Subscription subscription) {
    bool added = false;
    if (subscriptions.containsKey(subscription.channel)) {
      added = subscriptions[subscription.channel].length == 0;
      subscriptions[subscription.channel].add(subscription);
    } else {
      List<Subscription> listeners = List.empty(growable: true);
      listeners.add(subscription);
      subscriptions[subscription.channel] = listeners;
      added = true;
    }

    if (/*added && */ redisConnector != null && redisConnector.isReady()) {
      //redisConnector.subscribe(subscription.channel);
      if (added) {
        _resendGetSubcribe(redisConnector, skipUnsubscribeChannel: subscription.channel);
      } else {
        _resendGetSubcribe(redisConnector);
      }
    }
  }

  void unsubscribe(Subscription subscription, String caller) {
    //_queue.add(WrapperSubscription(subscription, false, caller: caller));
    _queue.add(WrapperSubscription(subscription, RedisSubscriptionType.Unsubscribe, caller: caller));
  }
  void punsubscribe(Subscription subscription, String caller) {
    //_queue.add(WrapperSubscription(subscription, false, caller: caller));
    _queue.add(WrapperSubscription(subscription, RedisSubscriptionType.Punsubscribe, caller: caller));
  }

  void _unsubscribe(Subscription subscription) {
    if (subscriptions.containsKey(subscription.channel)) {
      subscriptions[subscription.channel].remove(subscription);
      bool remove = subscriptions[subscription.channel].length == 0;
      if (remove && redisConnector != null && redisConnector.isReady()) {
        redisConnector.unsubscribe(subscription.channel);
      }
    }
  }

  void _punsubscribe(Subscription subscription) {
    if (subscriptions.containsKey(subscription.channel)) {
      subscriptions[subscription.channel].remove(subscription);
      bool remove = subscriptions[subscription.channel].length == 0;
      if (remove && redisConnector != null && redisConnector.isReady()) {
        redisConnector.punsubscribe(subscription.channel);
      }
    }
  }

  void debug(String text) {
    DebugWriter.info(DateTime.now().toString() + " $runtimeType " + text);
  }

  bool validatorStatus(List<String> data, String channel) {
    //List<String> data = message.split('|');
    if (data.length > 2 && data.first == 'III' && data.elementAt(1) == 'C') {
      return true;
    }
    return false;
  }

  bool validatorIndex(List<String> data, String channel) {
    //List<String> data = message.split('|');
    if (data.length > 2 && data.first == 'III' && data.elementAt(1) == 'Z') {
      return true;
    }
    return false;
  }

  bool validatorCompositeFD(List<String> data, String channel) {
    //List<String> data = message.split('|');
    if (data.length > 2 && data.first == 'III' && data.elementAt(1) == DatafeedType.CompositeForeignDomestic.type) {
      return true;
    }
    return false;
  }

  bool validatorSummary(List<String> data, String channel) {
    //List<String> data = message.split('|');
    if (data.length > 2 && data.first == 'III' && data.elementAt(1) == 'Q') {
      return true;
    }
    return false;
  }


  void initiate(
      {String ip = '', int port = 0, String password = '', String clientUsername = 'No-One', String platform = '-', String version = '-', bool presubscribe=true, String streamer_id='StreamerConnector'}) {

    if(presubscribe){
      SubscribeAndGET subscribeStatus = SubscribeAndGET(DatafeedType.Status.key, DatafeedType.Status.key, listener: (message) {
        //print('got : '+message.join('|'));
        DebugWriter.info('got : ' + message.elementAt(1));
        DebugWriter.info(message);
      }, validator: validatorStatus);

      String codeBoard = 'ASII.RG';
      SubscribeAndHGET subscribeSummary =
      SubscribeAndHGET(DatafeedType.Summary.key + '.' + codeBoard, DatafeedType.Summary.collection, codeBoard, listener: (message) {
        DebugWriter.info('got : ' + message.elementAt(1));
        DebugWriter.info(message);
      }, validator: validatorSummary);

      String indexCode = 'COMPOSITE';
      SubscribeAndHGET subscribeComposite =
      SubscribeAndHGET(DatafeedType.Indices.key + '.' + indexCode, DatafeedType.Indices.collection, indexCode, listener: (message) {
        DebugWriter.info('got : ' + message.elementAt(1));
        DebugWriter.info(message);
      }, validator: validatorIndex);

      SubscribeAndGET subscribeCompositeFD =
      SubscribeAndGET(DatafeedType.CompositeForeignDomestic.key, DatafeedType.CompositeForeignDomestic.key, listener: (message) {
        DebugWriter.info('got : ' + message.elementAt(1));
        DebugWriter.info(message);
      }, validator: validatorCompositeFD);

      subscribe(subscribeStatus, 'initiate');
      //subscribe(subscribeSummary);
      //subscribe(subscribeComposite);
      //subscribe(subscribeCompositeFD);
      //
      //
      // subscribe(SubscribeAndGET('KC', (message){
      //   print('got : $message');
      // },validatorStatus, 'KC'));
      //
      //
      // subscribe(SubscribeAndHGET('KQ.ASII.RG', (message) {
      //   print('got : $message');
      // }, validatorSummary, 'CQ', 'ASII.RG'));
      //
      // subscribe(SubscribeAndHGET('KZ.COMPOSITE', (message) {
      //   print('got : $message');
      // }, validatorIndex , 'CZ', 'COMPOSITE'));
    }


    redisConnector = new RedisStreamerConnector(ip, port, password, clientUsername, platform, version, this, streamerid: streamer_id);
    //redisConnector.connectRedis(connectionListener: this);
    redisConnector.setConnectionListener(this);
  }

  void disconnect({String info = '' /*, bool maintainConnection*/
      }) {
    // if(maintainConnection != null){
    //   _maintainConnection = maintainConnection;
    // }
    if (redisConnector != null) {
      redisConnector.disconnectRedis(info: info);
    }
  }

  void connect(/*{bool maintainConnection}*/) {
    // if(maintainConnection != null){
    //   _maintainConnection = maintainConnection;
    // }
    if (redisConnector != null) {
      redisConnector.connectRedis();
    }
  }

  @override
  void onUnknownMessage(String message) {
    debug('onUnknownMessage  : $message');
    List<String> data = message.split('|');
    // if(data.length > 2 && data.first == 'III' && data.elementAt(1) == 'C'){
    //
    // }
    subscriptions.values.forEach((list) {
      list.forEach((subscription) {
        if (subscription.validator(data, subscription.channel) && subscription.receiveUnknownMessage) {
          subscription.listener(data);
        }
      });
    });
  }

  @override
  void onStreamerMessage(String channel, String message) {
    debug('onStreamerMessage $channel  : $message');
    List<String> data = message.split('|');

    subscriptions[channel].forEach((subscription) {
      //if(subscription.validator(data, subscription.channel)){
      subscription.listener(data);
      //}
    });
  }
  @override
  void onStreamerPmessage(String channel, String message) {
    debug('onStreamerPmessage $channel  : $message');
    List<String> data = message.split('|');
    subscriptions[channel].forEach((subscription) {
      //if(subscription.validator(data, subscription.channel)){
      subscription.listener(data);
      //}
    });

    // subscriptions.forEach((key, value) {
    //
    //   if(value.first.psubscribe && value.first.matchPattern(channel)){
    //     subscriptions[channel].forEach((subscription) {
    //       subscription.listener(data);
    //     });
    //   }
    // });
  }
  @override
  void onStreamerSubscribe(String channel, String message) {
    // TODO: implement onStreamerSubscribe
    debug('onStreamerSubscribe $channel  : $message');
    if (!_subscribeValid.contains(channel)) {
      _subscribeValid.add(channel);
    }
  }

  @override
  void onStreamerUnsubscribe(String channel, String message) {
    // TODO: implement onStreamerUnsubscribe
    debug('onStreamerUnsubscribe $channel  : $message');
    if (_subscribeValid.contains(channel)) {
      _subscribeValid.remove(channel);
    }
  }

  @override
  void onStreamerPsubscribe(String channel, String message) {
    debug('onStreamerPsubscribe $channel  : $message');

    bool contains = StringUtils.contains(channel, _psubscribeValid);
    if (!contains) {
      _psubscribeValid.add(channel);
    }
    // if (!_psubscribeValid.contains(channel)) {
    //   _psubscribeValid.add(channel);
    // }
  }

  @override
  void onStreamerPunsubscribe(String channel, String message) {
    debug('onStreamerPunsubscribe $channel  : $message');
    bool contains = StringUtils.contains(channel, _psubscribeValid);
    if (contains) {
      _psubscribeValid.remove(channel);
    }

    // if (_psubscribeValid.contains(channel)) {
    //   _psubscribeValid.remove(channel);
    // }
  }


  @override
  void onAuthenticated(RedisConnector connector, String info, bool isReady) {
    // TODO: implement onAuthenticated
    debug(connector.connectorId + ' onAuthenticated : $info  isReady : $isReady');
    //connector.subcribe('KC');
    statusColor = Colors.green;

    _sendGetSubcribe(connector);
    startTimer();

    notifyListeners();
  }

  @override
  void onAuthenticationFailed(RedisConnector connector, String info) {
    // TODO: implement onAuthenticationFailed
    debug(connector.connectorId + ' onAuthenticationFailed : $info');
    statusColor = Colors.red;
    notifyListeners();
  }

  @override
  void onConnected(RedisConnector connector, String info, bool isReady) {
    // TODO: implement onConnected
    debug(connector.connectorId + ' onConnected : $info  isReady : $isReady');
    statusColor = Colors.blue;
    notifyListeners();
  }

  @override
  void onConnecting(RedisConnector connector, String info) {
    // TODO: implement onConnecting
    debug(connector.connectorId + ' onConnecting : $info');
    statusColor = Colors.yellowAccent;
    notifyListeners();
  }

  @override
  void onConnectionFailed(RedisConnector connector, String info) {
    // TODO: implement onConnectionFailed
    debug(connector.connectorId + ' onConnectionFailed : $info');
    statusColor = Colors.redAccent;
    notifyListeners();
  }

  @override
  void onErrorHandler(RedisConnector connector, String info) {
    // TODO: implement onErrorHandler
    debug(connector.connectorId + ' onErrorHandler : $info');
  }

  void onDisconnected(RedisConnector connector, String info) {
    debug(connector.connectorId + ' onDisconnected : $info');
    statusColor = Colors.redAccent;
    notifyListeners();
  }

  @override
  void onReConnecting(RedisConnector connector, String info) {
    // TODO: implement onReConnecting
    debug(connector.connectorId + ' onReConnecting : $info');
    statusColor = Colors.orangeAccent;
    stopTimer();
    notifyListeners();
  }

  static const Duration durationUpdate = Duration(milliseconds: 500);

  void startTimer() {
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(durationUpdate, (timer) {
        if (onProcess) {
          debug('timer _queue skip caused  onProcess : $onProcess ');
        } else {
          _executeQueue();
        }
      });
    }
  }

  bool onProcess = false;

  void _executeQueue() {
    onProcess = true;
    bool canProcess = redisConnector != null && redisConnector.isReady() && _queue.isNotEmpty;
    while (canProcess) {
      debug('_queue execute _queue.length : ' + _queue.length.toString());

      Utils.printList(_subscribeValid, caller: '_subscribeValid');
      Utils.printList(_psubscribeValid, caller: '_psubscribeValid');

      WrapperSubscription wrapper = _queue.first;
      _queue.removeAt(0);

      if (wrapper.type == RedisSubscriptionType.Subscribe || wrapper.type == RedisSubscriptionType.Psubscribe) {
        debug('_queue execute caller[' + wrapper.caller + '] subscribe/psubscribe  channel : ' + wrapper.subscription.channel);
        _subscribe(wrapper.subscription);
      } else if(wrapper.type == RedisSubscriptionType.Unsubscribe){
        debug('_queue execute caller[' + wrapper.caller + '] Unsubscribe  channel : ' + wrapper.subscription.channel);
        _unsubscribe(wrapper.subscription);
      } else if(wrapper.type == RedisSubscriptionType.Punsubscribe){
        debug('_queue execute caller[' + wrapper.caller + '] Punsubscribe  channel : ' + wrapper.subscription.channel);
        _punsubscribe(wrapper.subscription);
      }
      canProcess = redisConnector != null && redisConnector.isReady() && _queue.isNotEmpty;
    }
    onProcess = false;
  }

  void stopTimer() {
    if (timer == null || !timer.isActive) {
      return;
    }
    timer.cancel();
    timer = null;
  }




}

/*
class SubscriptionDatafeed extends ChangeNotifier{




  //dartis
  Client redisDatafeedClient;
  PubSub redisDatafeedPubSub;


  List<String> unusedChannels = List.empty(growable: true);
  Map<String, int> _channelsMap = Map<String, int>();

  bool subscribe(String channel){
    bool newChannel = false;
    if( _channelsMap.containsKey(channel) ){
      //_channels.add(channel);
      _channelsMap[channel] = _channelsMap[channel]++;
    }else{
      _channelsMap[channel] = 1;
      newChannel = true;
      notifyListeners();
    }
    return newChannel;
  }

  bool unsubscribe(String channel){
    bool unusedChannel = false;
    if( _channelsMap.containsKey(channel) && _channelsMap[channel] > 0){
      _channelsMap[channel] = _channelsMap[channel]--;
      if(_channelsMap[channel] == 0){
        unusedChannel = true;
        unusedChannels.add(channel);
        notifyListeners();
      }
    }

    return unusedChannel;
  }
  List<String> channels(){
    return _channelsMap.keys.toList();
  }

  void connnectRedis(BuildContext context, {String redis_ip, String redis_port, String redis_password}) async{
    print('connnectRedis');
    try{
      String ip = redis_ip ?? '36.89.110.91';
      String port = redis_port ?? '8811';
      String password = redis_password ?? '83bc008633616fa21c81054d5eaff1573';
      redisDatafeedClient = await Client.connect('redis://$ip:$port');
      final commands = redisDatafeedClient.asCommands<String, String>();
      await commands.auth(password);

      // Create the PubSub object using the client connection
      redisDatafeedPubSub = PubSub<String, String>(redisDatafeedClient.connection);
      redisDatafeedPubSub.stream.listen((PubSubEvent event){

        if(event is MessageEvent){
          print('channel '+event.channel+' --> '+event.message);
        }else if(event is SubscriptionEvent){
          print(event.command+' --> channel '+event.channel+' --> count '+event.channelCount.toString());
        }else{
          print('redisDatafeedPubSub Got Event');
          print(event);
        }
      }, onError: print);

      redisDatafeedPubSub.subscribe(channel: DatafeedType.KEY_STATUS);
      subcribeDatafeed();


      print('connnectRedis success');
    }catch(error){
      print('connnectRedis error');
      print(error);

    }
  }

  void subcribeDatafeed(){
    if(redisDatafeedPubSub == null){
      print('subcribeDatafeed aborted caused by redisDatafeedPubSub = NULL');
      return;
    }

    for(var channel in unusedChannels){
      if(!StringUtils.isEmtpy(channel)){
        redisDatafeedPubSub.unsubscribe(channel: channel);
      }
    }
    unusedChannels.clear();
    for(var channel in channels()){
      if(!StringUtils.isEmtpy(channel)){
        redisDatafeedPubSub.subscribe(channel: channel);
      }
    }
  }




  void disconnnectRedis() async{
    print('disconnnectRedis');
    try{
      //print('disconnnectRedis redisDatafeedPubSub');
      //redisDatafeedPubSub?.disconnect();
      print('disconnnectRedis redisDatafeedClient');
      redisDatafeedClient?.disconnect();
      print('disconnnectRedis success');

      redisDatafeedPubSub = null;
      redisDatafeedClient = null;
    }catch(error){
      print('disconnnectRedis error');
      print(error);
    }
  }
}

final subscriptionDatafeedChangeNotifier = ChangeNotifierProvider<SubscriptionDatafeed>((ref) {
  return SubscriptionDatafeed();
});
*/

class MainMenuChangeNotifier extends ChangeNotifier {
  Tabs _mainTab = Tabs.Home;
  int _subTabHome = 0;
  int _subTabSearch = 0;
  int _subTabPortfolio = 0;
  int _subTabTransaction = 0;
  int _subTabCommunity = 0;

  void setActive(Tabs mainTab, int subTab, {bool silently = false}) {
    this._mainTab = mainTab;
    if (_mainTab == Tabs.Home) {
      this._subTabHome = subTab;
    } else if (_mainTab == Tabs.Search) {
      this._subTabSearch = subTab;
    } else if (_mainTab == Tabs.Portfolio) {
      this._subTabPortfolio = subTab;
    } else if (_mainTab == Tabs.Transaction) {
      this._subTabTransaction = subTab;
    } else if (_mainTab == Tabs.Community) {
      this._subTabCommunity = subTab;
    }

    notifyListeners();
  }

  Tabs get mainTab => _mainTab;

  int get subTabCommunity => _subTabCommunity;

  int get subTabTransaction => _subTabTransaction;

  int get subTabPortfolio => _subTabPortfolio;

  int get subTabSearch => _subTabSearch;

  int get subTabHome => _subTabHome;

//int get subTab => _subTab;

// void mustNotifyListener(){
//   notifyListeners();
// }
}

final mainMenuChangeNotifier = ChangeNotifierProvider<MainMenuChangeNotifier>((ref) {
  return MainMenuChangeNotifier();
});

class AccountsInfosNotifier extends ChangeNotifier {
  List<AccountStockPosition> list = List.empty(growable: true);

  void updateList(List<AccountStockPosition> newList) {
    int newCount = newList != null ? newList.length : 0;
    if (newCount == 0) {
      list.clear();
    } else {
      newList.forEach((newInfo) {
        _addOrUpdate(newInfo);
      });
    }
    notifyListeners();
  }

  AccountStockPosition getInfo(String accountcode) {
    AccountStockPosition found;
    for (int i = 0; i < list.length; i++) {
      AccountStockPosition existing = list.elementAt(i);
      if (existing != null && StringUtils.equalsIgnoreCase(accountcode, existing.accountcode)) {
        found = existing;
        break;
      }
    }
    return found;
  }

  void _addOrUpdate(AccountStockPosition info) {
    if (info == null) {
      return;
    }
    bool exist = false;
    for (int i = 0; i < list.length; i++) {
      AccountStockPosition existing = list.elementAt(i);
      if (existing != null && StringUtils.equalsIgnoreCase(info.accountcode, existing.accountcode)) {
        exist = true;
        existing.copyValueFrom(info);
        break;
      }
    }
    if (!exist) {
      list.add(info);
    }
  }

  void mustNotifyListener() {
    notifyListeners();
  }
}

final accountsInfosNotifier = ChangeNotifierProvider<AccountsInfosNotifier>((ref) {
  return AccountsInfosNotifier();
});

class AppPropertiesNotifier extends ChangeNotifier {
  AppProperties properties = AppProperties();
  bool _needPinTrading = true;
  DateTime _last_activity = DateTime.now();

  bool isNeedPinTrading() {
    return _needPinTrading;
  }

  void setNeedPinTrading(bool flag) {
    // bool changed = _needPinTrading != flag;
    _needPinTrading = flag;
    updateUserActivity(caller: 'setNeedPinTrading [$flag]');
    // if(changed){
    if (flag) {
      stopTimer();
    } else {
      startTimer();
    }
    // }
  }

  void updateUserActivity({String caller = ''}) {
    if (!_needPinTrading) {
      _last_activity = DateTime.now();
      print('updateUserActivity $caller  at ' + _last_activity.toString());
    }
  }

  Timer timer;
  static const Duration durationCheck = Duration(seconds: 10);

  void startTimer() {
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(durationCheck, (timer) {
        print('Timer.PIN ' + timer.tick.toString() + '  _needPinTrading : $_needPinTrading');
        if (!_needPinTrading) {
          int pinTimeoutIndex = properties.getInt(ROUTE_SETTINGS, PROP_SELECTED_PIN_TIMEOUT, TradingTimeoutDuration.FifteenMinutes.index);
          TradingTimeoutDuration timeoutDuration = TradingTimeoutDuration.values.elementAt(pinTimeoutIndex);

          DateTime now = DateTime.now();

          int gapMinutes = now.difference(_last_activity).inMinutes;
          int gapSeconds = now.difference(_last_activity).inSeconds;
          print('PIN Timeout check gapMinutes : $gapMinutes  gapSeconds : $gapSeconds   now : ' +
              now.toString() +
              '  _last_activity : ' +
              _last_activity.toString());
          if (gapMinutes >= timeoutDuration.inMinutes) {
            print('PIN Timeout at : ' + now.toString());
            setNeedPinTrading(true);
            notifyListeners();
          }
        }
        // if(onProcess){
        //   debug('timer _queue skip caused  onProcess : $onProcess ');
        // }else{
        //   _executeQueue();
        // }
      });
    }
  }

  void stopTimer() {
    if (timer == null || !timer.isActive) {
      return;
    }
    timer.cancel();
    timer = null;
  }
}

final propertiesNotifier = ChangeNotifierProvider<AppPropertiesNotifier>((ref) {
  return AppPropertiesNotifier();
});

class ChangeNotifierBase extends ChangeNotifier {
  NotifierState currentState = NotifierState.Loading;
  String currentMessage = '';

  void setState(NotifierState newState, {String message}) {
    this.currentState = newState;
    if (message != null) {
      this.currentMessage = message;
    }
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

  void setError({String message}) {
    setState(NotifierState.Error, message: message);
  }
}

class EIPONotifier extends ChangeNotifierBase {
  List<ListEIPO> list = List.empty(growable: true);

  int count() {
    return list != null ? list.length : 0;
  }

  void setValue(List<ListEIPO> newList) {
    list.clear();
    int newCount = newList != null ? newList.length : 0;
    if (newCount == 0) {
      setNoData();
    } else {
      newList.forEach((newInfo) {
        list.add(newInfo);
      });
      setFinished();
    }
    //notifyListeners();
  }

  void mustNotifyListener() {
    notifyListeners();
  }
}

final eipoNotifier = ChangeNotifierProvider<EIPONotifier>((ref) {
  return EIPONotifier();
});

final helpNotifier = ChangeNotifierProvider<HelpNotifier>((ref) {
  return HelpNotifier();
});

class HelpNotifier extends ChangeNotifier {
  HelpData data = HelpData();

  // HelpNotifier(){
  //   data = HelpData();
  //   data.load();
  // }

  void setData(HelpData newValue) {
    this.data.copyValueFrom(newValue, dontClearExistingIfNull: true);
    notifyListeners();
    this.data.save();
  }

  List<HelpContent> getContent(HelpMenu menu) {
    List<HelpContent> contents = List.empty(growable: true);
    if (menu == null) {
      print('HelpNotifier getContent for menu (NULL)');
      return contents;
    }
    for (var content in this.data.contents) {
      if (content != null) {
        if (StringUtils.equalsIgnoreCase(menu.id, content.id_menu)) {
          contents.add(content);
        }
      }
    }
    return contents;
  }
}

class CorporateActionEventNotifier extends ChangeNotifier {
  List<CorporateActionEvent> list = List.empty(growable: true);

  void setData(List<CorporateActionEvent> newValue) {
    this.list.clear();
    if (newValue != null) {
      this.list.addAll(newValue);
    }
    notifyListeners();
  }

  List<CorporateActionEvent> getEvent(String code) {
    List<CorporateActionEvent> result = List.empty(growable: true);
    list.forEach((ca) {
      if (ca != null && StringUtils.equalsIgnoreCase(ca.code, code)) {
        result.add(ca);
      }
    });
    return result;
  }
}

final corporateActionEventNotifier = ChangeNotifierProvider<CorporateActionEventNotifier>((ref) {
  return CorporateActionEventNotifier();
});

class FundamentalCacheNotifier extends ChangeNotifier {
  Map<String, FundamentalCache> maps = Map();

  void setData(Map<String, FundamentalCache> newValue) {
    this.maps.clear();
    if (newValue != null) {
      this.maps.addAll(newValue);
    }
    notifyListeners();
  }

  FundamentalCache getCache(String code) {
    if (maps.containsKey(code)) {
      return maps[code];
    }
    return null;
  }
}

final fundamentalCacheNotifier = ChangeNotifierProvider<FundamentalCacheNotifier>((ref) {
  return FundamentalCacheNotifier();
});

final remark2Notifier = ChangeNotifierProvider<Remark2ChangeNotifier>((ref) {
  return Remark2ChangeNotifier();
});

final suspendedStockNotifier = ChangeNotifierProvider<SuspendedStockChangeNotifier>((ref) {
  return SuspendedStockChangeNotifier();
});

class SuspendedStockChangeNotifier extends ChangeNotifier {
  SuspendedStockData data = SuspendedStockData();
  void setData(SuspendedStockData newValue) {
    this.data.copyValueFrom(newValue, dontClearExistingIfNull: true);
    notifyListeners();
  }
  SuspendStock getSuspended(String code, String board) {
    SuspendStock result;
    String key = code+'_'+board;
    if (data.affected.containsKey(key)) {
      result = data.affected[key];
    }
    return result;
  }
}
class Remark2ChangeNotifier extends ChangeNotifier {
  Remark2Data data = Remark2Data();

  StockInformationStatus getSpecialNotationStatus(String code) {
    StockInformationStatus status;
    if (data.affected.containsKey(code)) {
      Remark2Stock s = data.affected[code];
      if (s != null) {

        List<String> keysSpecialNotation = [
          s.key_19,
          s.key_20,
          s.key_21,
          s.key_22,
          s.key_23,
          s.key_24,
          s.key_25,
          s.key_26,
          s.key_27,
          s.key_28,
          s.key_29
        ];

        for(int i = 0 ; i < keysSpecialNotation.length; i++){
          Remark2Mapping m = data.mapping[keysSpecialNotation[i]];
          if (m != null) {
            status = StockInformationStatus.SpecialNotation;
          }
        }
        Remark2Mapping m_30 = data.mapping[s.key_30]; // under watch list
        if (m_30 != null) {
          status = StockInformationStatus.UnderWatchlist;
        }
      }
    }
    return status;
  }

  String getSpecialNotationCodes(String code) {
    String textCodes = '';
    if (data.affected.containsKey(code)) {
      Remark2Stock s = data.affected[code];
      if (s != null) {

        List<String> keysSpecialNotation = [
          s.key_19,
          s.key_20,
          s.key_21,
          s.key_22,
          s.key_23,
          s.key_24,
          s.key_25,
          s.key_26,
          s.key_27,
          s.key_28,
          s.key_29
        ];

        Remark2Mapping m_30 = data.mapping[s.key_30]; // under watch list
        if (m_30 != null) {
          textCodes += m_30.code;
        }

        for(int i = 0 ; i < keysSpecialNotation.length; i++){
          Remark2Mapping m = data.mapping[keysSpecialNotation[i]];
          if (m != null) {
            textCodes += m.code;
          }
        }

      }
    }
    return textCodes;
  }

  List<Remark2Mapping> getSpecialNotation(String code) {
    List<Remark2Mapping> notation = List.empty(growable: true);
    if (data.affected.containsKey(code)) {
      Remark2Stock s = data.affected[code];
      if (s != null) {
        Remark2Mapping m_19 = data.mapping[s.key_19];
        Remark2Mapping m_20 = data.mapping[s.key_20];
        Remark2Mapping m_21 = data.mapping[s.key_21];
        Remark2Mapping m_22 = data.mapping[s.key_22];
        Remark2Mapping m_23 = data.mapping[s.key_23];
        Remark2Mapping m_24 = data.mapping[s.key_24];
        Remark2Mapping m_25 = data.mapping[s.key_25];
        Remark2Mapping m_26 = data.mapping[s.key_26];
        Remark2Mapping m_27 = data.mapping[s.key_27];

        Remark2Mapping m_28 = data.mapping[s.key_28];
        Remark2Mapping m_29 = data.mapping[s.key_29];
        Remark2Mapping m_30 = data.mapping[s.key_30];

        // under watch list paling pertama
        if (m_30 != null) {
          notation.add(m_30);
        }

        if (m_19 != null) {
          notation.add(m_19);
        }

        if (m_20 != null) {
          notation.add(m_20);
        }

        if (m_21 != null) {
          notation.add(m_21);
        }

        if (m_22 != null) {
          notation.add(m_22);
        }

        if (m_23 != null) {
          notation.add(m_23);
        }

        if (m_24 != null) {
          notation.add(m_24);
        }

        if (m_25 != null) {
          notation.add(m_25);
        }

        if (m_26 != null) {
          notation.add(m_26);
        }

        if (m_27 != null) {
          notation.add(m_27);
        }
        if (m_28 != null) {
          notation.add(m_28);
        }

        if (m_29 != null) {
          notation.add(m_29);
        }


      }
    }
    return notation;
  }

  String getSpecialNotationText(String code) {
    List<String> notation = List.empty(growable: true);
    if (data.affected.containsKey(code)) {
      Remark2Stock s = data.affected[code];
      if (s != null) {
        Remark2Mapping m_19 = data.mapping[s.key_19];
        Remark2Mapping m_20 = data.mapping[s.key_20];
        Remark2Mapping m_21 = data.mapping[s.key_21];
        Remark2Mapping m_22 = data.mapping[s.key_22];
        Remark2Mapping m_23 = data.mapping[s.key_23];
        Remark2Mapping m_24 = data.mapping[s.key_24];
        Remark2Mapping m_25 = data.mapping[s.key_25];
        Remark2Mapping m_26 = data.mapping[s.key_26];
        Remark2Mapping m_27 = data.mapping[s.key_27];

        Remark2Mapping m_28 = data.mapping[s.key_28];
        Remark2Mapping m_29 = data.mapping[s.key_29];
        Remark2Mapping m_30 = data.mapping[s.key_30];

        if (m_19 != null) {
          notation.add(/*m_19.code+" : "+*/ m_19.value);
        }

        if (m_20 != null) {
          notation.add(/*m_20.code+" : "+*/ m_20.value);
        }

        if (m_21 != null) {
          notation.add(/*m_21.code+" : "+*/ m_21.value);
        }

        if (m_22 != null) {
          notation.add(/*m_22.code+" : "+*/ m_22.value);
        }

        if (m_23 != null) {
          notation.add(/*m_23.code+" : "+*/ m_23.value);
        }

        if (m_24 != null) {
          notation.add(/*m_24.code+" : "+*/ m_24.value);
        }

        if (m_25 != null) {
          notation.add(/*m_25.code+" : "+*/ m_25.value);
        }

        if (m_26 != null) {
          notation.add(/*m_26.code+" : "+*/ m_26.value);
        }

        if (m_27 != null) {
          notation.add(/*m_27.code+" : "+*/ m_27.value);
        }

        if (m_28 != null) {
          notation.add(/*m_28.code+" : "+*/ m_28.value);
        }
        if (m_29 != null) {
          notation.add(/*m_29.code+" : "+*/ m_29.value);
        }
        if (m_30 != null) {
          notation.add(/*m_30.code+" : "+*/ m_30.value);
        }
      }
    }
    String result;
    for (int i = 0; i < notation.length; i++) {
      if (StringUtils.isEmtpy(result)) {
        result = notation.elementAt(i);
      } else {
        result = result + "\r\n" + notation.elementAt(i);
      }
    }
    return result;
  }

  void setData(Remark2Data newValue) {
    this.data.copyValueFrom(newValue, dontClearExistingIfNull: true);
    notifyListeners();
  }
}

class OpenOrderChangeNotifier extends ChangeNotifier {
  List<OpenOrder> list = List.empty(growable: true);

  void update(List<OpenOrder> _list) {
    this.list = _list;
    notifyListeners();
  }

  OpenOrder get(int price) {
    int count = list != null ? list.length : 0;
    OpenOrder found;
    for (int i = 0; i < count; i++) {
      OpenOrder existing = list.elementAt(i);
      if (existing != null && existing.price == price) {
        found = existing;
        break;
      }
    }
    return found;
  }
}

final openOrderChangeNotifier = ChangeNotifierProvider<OpenOrderChangeNotifier>((ref) {
  return OpenOrderChangeNotifier();
});

// final rdnBalanceStateProvider = StateProvider<double>((ref){
//     return 0.0;
// });

class SellLotAvgChangeNotifier extends ChangeNotifier {
  int lot = 0;
  double averagePrice = 0.0;

  void update(int _lot, double _avgPrice) {
    this.lot = _lot;
    this.averagePrice = _avgPrice;
    notifyListeners();
  }
}

final sellLotAvgChangeNotifier = ChangeNotifierProvider<SellLotAvgChangeNotifier>((ref) {
  return SellLotAvgChangeNotifier();
});

class BuyRdnBuyingPowerChangeNotifier extends ChangeNotifier {
  double buyingPower = 0.0;
  double cashAvailable = 0.0;
  double creditLimit = 0.0;

  void update(double _buyingPower, double _cashAvailable, double _creditLimit) {
    this.buyingPower = _buyingPower;
    this.cashAvailable = _cashAvailable;
    this.creditLimit = _creditLimit;
    notifyListeners();
  }
}

final buyRdnBuyingPowerChangeNotifier = ChangeNotifierProvider<BuyRdnBuyingPowerChangeNotifier>((ref) {
  return BuyRdnBuyingPowerChangeNotifier();
});

class DataHolderChangeNotifier extends ChangeNotifier {
  // double buyingPower = 0.0;
  // double rdnBalance = 0.0;
  // void update(double _buyingPower, double _rdnBalance){
  //   this.buyingPower = _buyingPower;
  //   this.rdnBalance = _rdnBalance;
  //   notifyListeners();
  // }
  bool isLogged = false;
  bool isForeground = false;
  User user = User('', '', 0.0, 1, null, null, null, null,null,null,null,0,null,null,0);

  void mustNotifyListener() {
    notifyListeners();
  }
}

final dataHolderChangeNotifier = ChangeNotifierProvider<DataHolderChangeNotifier>((ref) {
  return DataHolderChangeNotifier();
});

class WatchlistChangeNotifier extends ChangeNotifier {
  List<Watchlist> _listWatchlist = List.empty(growable: true);

  void clear() {
    _listWatchlist.clear();
    notifyListeners();
  }

  int count() {
    return _listWatchlist == null ? 0 : _listWatchlist.length;
  }

  void addWatchlist(Watchlist watchlist) {
    if (watchlist != null) {
      _listWatchlist.add(watchlist);
      notifyListeners();
    }
  }

  List<Watchlist> getAll() {
    return _listWatchlist;
  }

  bool isEmpty() {
    return _listWatchlist.isEmpty;
  }

  void replaceWatchlist(int index, Watchlist watchlist) {
    int count = _listWatchlist != null ? _listWatchlist.length : 0;
    if (index < count && index >= 0) {
      _listWatchlist.removeAt(index);
      _listWatchlist.insert(index, watchlist);
    }
  }

  Watchlist getWatchlist(int index) {
    int count = _listWatchlist != null ? _listWatchlist.length : 0;
    if (index < count && index >= 0) {
      return _listWatchlist.elementAt(index);
    }
    return null;
  }

  Watchlist getWatchlistByName(String name) {
    Watchlist result;
    int count = _listWatchlist != null ? _listWatchlist.length : 0;
    if (count > 0) {
      for (var watchlist in _listWatchlist) {
        if (watchlist != null && StringUtils.equalsIgnoreCase(watchlist.name, name)) {
          result = watchlist;
          break;
        }
      }
    }
    return result;
  }

  Watchlist removeWatchlist(int index) {
    return _listWatchlist.removeAt(index);
  }

  void mustNotifyListener() {
    notifyListeners();
  }
}

final watchlistChangeNotifier = ChangeNotifierProvider<WatchlistChangeNotifier>((ref) {
  return WatchlistChangeNotifier();
});

class PageChangeNotifier extends ChangeNotifier {
  final List<String> _list = List.empty(growable: true);

  void mustNotifyListener() {
    notifyListeners();
  }

  void onActive(String routeName) {
    if (_list.contains(routeName)) {
      _list.remove(routeName);
      print('PageNotifier [onActive]--> removing history $routeName');
    }
    _list.add(routeName);
    print('PageNotifier [onActive]--> adding $routeName  size : ' + _list.join('|'));
    mustNotifyListener();
  }

  void onInactive(String routeName) {
    if (_list.contains(routeName)) {
      _list.remove(routeName);
      print('PageNotifier [onInactive]--> removing $routeName');
    } else {
      print('PageNotifier [onInactive]--> not found $routeName = ' + _list.join('|'));
    }
    mustNotifyListener();
  }

  bool isCurrentActive(String routeName) {
    if (_list.isEmpty) {
      print('PageNotifier isCurrentActive $routeName -> false  : empty');
      return false;
    }

    bool isCurrentActive = StringUtils.equalsIgnoreCase(_list.last, routeName);
    print('PageNotifier isCurrentActive $routeName -> $isCurrentActive  : ' + _list.last);
    return isCurrentActive;
  }

  @override
  String toString() {
    return 'PageNotifier  ' + _list.join('\n');
  }
}

final pageChangeNotifier = ChangeNotifierProvider<PageChangeNotifier>((ref) {
  return PageChangeNotifier();
});

class InboxChangeNotifier extends ChangeNotifier {
  String _date_next = '';
  final List _listData = List.empty(growable: true);
  bool no_new_data = false;

  void mustNotifyListener() {
    notifyListeners();
  }

  void addNotification(var data) {
    if (data != null) {
      _listData.add(data);
      notifyListeners();
    }
  }

  List datas() {
    return _listData;
  }

  bool loadingBottom = false;

  void showLoadingBottom(bool loading) {
    loadingBottom = loading;
    print('loadingBottom : $loadingBottom');
    if (loadingBottom) {
      retryBottom = false;
    }
    mustNotifyListener();
  }

  bool retryBottom = false;

  void showRetryBottom(bool retry) {
    retryBottom = retry;
    if (retryBottom) {
      loadingBottom = false;
    }
    print('retryBottom : $retryBottom');
    mustNotifyListener();
  }

  String get date_next => _date_next;

  int countData() {
    return _listData != null ? _listData.length : 0;
  }

  void setResult(var result) {
    //loadingBottom = false;

    if (result == null) {
      print('InboxChangeNotifier.setResult is NULL');
      mustNotifyListener();
      return;
    }

    if (result is ResultInbox) {
      if (result.count() > 0) {
        no_new_data = false;
      } else {
        no_new_data = true;
      }
      //bool add = (_current_page + 1) == result.current_page;
      bool add = !StringUtils.isEmtpy(result.date_start);
      if (add) {
        if (result.datas != null) {
          _listData.addAll(result.datas);
        }
      } else {
        _listData.clear();
        if (result.datas != null) {
          _listData.addAll(result.datas);
        }
      }
      _date_next = result.date_next;

      /*
      result.message    = StringUtils.noNullString(parsedJson['message']);
      result.username   = StringUtils.noNullString(parsedJson['username']);
      result.date_start  = StringUtils.noNullString(parsedJson['date_start']);
      result.date_next  = StringUtils.noNullString(parsedJson['date_next']);
      result.more_data  = Utils.safeBool(parsedJson['more_data']);
      */
      // _first_page_url = result.first_page_url;
      // _from = result.from;
      // _last_page = result.last_page;
      // _last_page_url = result.last_page_url;
      // _next_page_url = result.next_page_url;
      // _path = result.path;
      // _per_page = result.per_page;
      // _prev_page_url = result.prev_page_url;
      // _to = result.to;
      // _total = result.total;

      notifyListeners();
    } else {
      print('InboxChangeNotifier.setResult isResultInbox : false  not kind of class that we needed. ');
      //mustNotifyListener();
      return;
    }
  }
}

final inboxChangeNotifier = ChangeNotifierProvider<InboxChangeNotifier>((ref) {
  return InboxChangeNotifier();
});

abstract class SosmedDataChangeNotifier extends ChangeNotifier {
  int _current_page = 1;
  String _first_page_url = '';
  int _from = 0;
  int _last_page = 0;
  String _last_page_url = '';
  String _next_page_url = '';
  String _path = '';
  int _per_page = 0;
  String _prev_page_url = '';
  int _to = 0;
  int _total = 0;
  bool no_new_data = false;

  //final List<Post> _listPost = List.empty(growable: true);
  final List _listData = List.empty(growable: true);

  //final String data; // array
  //final String links; // array
  void mustNotifyListener() {
    notifyListeners();
  }

  //UnmodifiableListView<Post> get posts => UnmodifiableListView(_listPost);
  //UnmodifiableListView get datas => UnmodifiableListView(_listData);

  // List datas(){
  //   return UnmodifiableListView(_listData);
  // }
  List datas() {
    return _listData;
  }

  void setResult(var result);

  int get current_page => _current_page;

  void addPost(var post) {
    if (post != null) {
      _listData.add(post);
      notifyListeners();
    }
  }

  bool loadingBottom = false;

  void showLoadingBottom(bool loading) {
    loadingBottom = loading;
    print('loadingBottom : $loadingBottom');
    if (loadingBottom) {
      retryBottom = false;
    }
    mustNotifyListener();
  }

  bool retryBottom = false;

  void showRetryBottom(bool retry) {
    retryBottom = retry;
    if (retryBottom) {
      loadingBottom = false;
    }
    print('retryBottom : $retryBottom');
    mustNotifyListener();
  }

  int countData() {
    return _listData != null ? _listData.length : 0;
  }

  String get first_page_url => _first_page_url;

  int get from => _from;

  int get last_page => _last_page;

  String get last_page_url => _last_page_url;

  String get next_page_url => _next_page_url;

  String get path => _path;

  int get per_page => _per_page;

  String get prev_page_url => _prev_page_url;

  int get to => _to;

  int get total => _total;
}

class SosmedFeedChangeNotifier extends SosmedDataChangeNotifier {
  //UnmodifiableListView get datas => UnmodifiableListView(_listData);
  @override
  void setResult(var result) {
    //loadingBottom = false;

    if (result == null) {
      print('SosmedFeedChangeNotifier.setResult is NULL');
      mustNotifyListener();
      return;
    }

    if (result is ResultPost) {
      if (result.countPost() > 0) {
        no_new_data = false;
      } else {
        no_new_data = true;
      }
      bool add = (_current_page + 1) == result.current_page;
      if (add) {
        if (result.posts != null) {
          _listData.addAll(result.posts);
        }
      } else {
        _listData.clear();
        if (result.posts != null) {
          _listData.addAll(result.posts);
        }
      }
      _current_page = result.current_page;
      _first_page_url = result.first_page_url;
      _from = result.from;
      _last_page = result.last_page;
      _last_page_url = result.last_page_url;
      _next_page_url = result.next_page_url;
      _path = result.path;
      _per_page = result.per_page;
      _prev_page_url = result.prev_page_url;
      _to = result.to;
      _total = result.total;

      notifyListeners();
    } else {
      print('SosmedFeedChangeNotifier.setResult isResultPost : false  not kind of class that we needed. ');
      //mustNotifyListener();
      return;
    }
  }
}

class SosmedCommentChangeNotifier extends SosmedDataChangeNotifier {
  //UnmodifiableListView get datas => UnmodifiableListView(_listData);
  @override
  void setResult(var result) {
    //loadingBottom = false;

    if (result == null) {
      print('SosmedCommentChangeNotifier.setResult is NULL');
      mustNotifyListener();
      return;
    }

    if (result is ResultComment) {
      if (result.countComments() > 0) {
        no_new_data = false;
      } else {
        no_new_data = true;
      }
      bool add = (_current_page + 1) == result.current_page;
      if (add) {
        if (result.comments != null) {
          _listData.addAll(result.comments);
        }
      } else {
        _listData.clear();
        if (result.comments != null) {
          _listData.addAll(result.comments);
        }
      }
      _current_page = result.current_page;
      _first_page_url = result.first_page_url;
      _from = result.from;
      _last_page = result.last_page;
      _last_page_url = result.last_page_url;
      _next_page_url = result.next_page_url;
      _path = result.path;
      _per_page = result.per_page;
      _prev_page_url = result.prev_page_url;
      _to = result.to;
      _total = result.total;

      notifyListeners();
    } else {
      print('SosmedCommentChangeNotifier.setResult isResultComment : false  not kind of class that we needed. ');
      //mustNotifyListener();
      return;
    }
  }
}

final sosmedFeedChangeNotifier = ChangeNotifierProvider<SosmedDataChangeNotifier>((ref) {
  return SosmedFeedChangeNotifier();
});

final sosmedCommentChangeNotifier = ChangeNotifierProvider<SosmedDataChangeNotifier>((ref) {
  return SosmedCommentChangeNotifier();
});

/*
class SosmedPostChangeNotifier extends ChangeNotifier {
  int _current_page = 1;
  String _first_page_url = '';
  int _from= 0;
  int _last_page= 0;
  String _last_page_url  = '';
  String _next_page_url = '';
  String _path = '';
  int _per_page= 0;
  String _prev_page_url = '';
  int _to = 0;
  int _total= 0;
  final List<Post> _listPost = List.empty(growable: true);

  //final String data; // array
  //final String links; // array
  void mustNotifyListener(){
    notifyListeners();
  }
  UnmodifiableListView<Post> get posts => UnmodifiableListView(_listPost);

  void setResult(ResultPost result){
    //loadingBottom = false;

    if(result == null){
      print('SosmedPostChangeNotifier.setResult is NULL');
      //mustNotifyListener();
      return;
    }

    bool add = (_current_page + 1) == result.current_page;
    if(add){
      _listPost.addAll(result.posts);

    }else{
      _listPost.clear();
      _listPost.addAll(result.posts);
    }
    _current_page = result.current_page;
    _first_page_url = result.first_page_url;
    _from = result.from;
    _last_page = result.last_page;
    _last_page_url = result.last_page_url;
    _next_page_url = result.next_page_url;
    _path = result.path;
    _per_page = result.per_page;
    _prev_page_url = result.prev_page_url;
    _to = result.to;
    _total = result.total;

    notifyListeners();
  }


  int get current_page => _current_page;

  void addPost(Post post){
    if(post != null){
      _listPost.add(post);
      notifyListeners();
    }
  }

  bool loadingBottom = false;
  void showLoadingBottom(bool loading){
    loadingBottom = loading;
    print('loadingBottom : $loadingBottom');
    if(loadingBottom){
      retryBottom = false;
    }
    mustNotifyListener();
  }
  bool retryBottom = false;
  void showRetryBottom(bool retry){
    retryBottom = retry;
    if(retryBottom){
      loadingBottom = false;
    }
    print('retryBottom : $retryBottom');
    mustNotifyListener();
  }

  int countPost (){
    return _listPost != null ? _listPost.length : 0;
  }

  String get first_page_url => _first_page_url;

  int get from => _from;

  int get last_page => _last_page;

  String get last_page_url => _last_page_url;

  String get next_page_url => _next_page_url;

  String get path => _path;

  int get per_page => _per_page;

  String get prev_page_url => _prev_page_url;

  int get to => _to;

  int get total => _total;
}
final sosmedPostChangeNotifier = ChangeNotifierProvider<SosmedPostChangeNotifier>((ref){
  return SosmedPostChangeNotifier();
});
*/
