// ignore_for_file: non_constant_identifier_names

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/string_utils.dart';

enum TransactionType { Normal, Loop, Split }

class BuySell {
  String? orderid = ''; // result orderid
  String? orderdate = ''; // result orderdate
  String? accountType = '';
  String? accountName = '';
  String? accountCode = '';
  String? brokerCode = '';
  String? stock_code = ''; //stock code
  String? stock_name = ''; // stock name
  final OrderType? orderType;
  int normalTotalValue = 0;
  int fastTotalValue = 0;
  bool? fastMode = false;
  int tradingLimitUsage = 0;
  PriceLot? normalPriceLot = PriceLot(0, 0);
  TransactionType? transactionType =
      TransactionType.Normal; // 0 = normal   1 = Loop   2 = SPLIT
  int transactionCounter = 1;
  List<PriceLot> _listFastPriceLot = List.empty(growable: true);

  List<PriceLot>? get listFastPriceLot => _listFastPriceLot;

  BuySell(this.orderType);

  String transactionTypeText() {
    if (transactionType == null) {
      return 'Null';
    } else if (transactionType == TransactionType.Normal) {
      return 'Normal';
    } else if (transactionType == TransactionType.Loop) {
      return 'Loop';
    } else if (transactionType == TransactionType.Split) {
      return 'Split';
    } else {
      return 'Unknown';
    }
  }

  bool isBuy() {
    return orderType == OrderType.Buy;
  }

  bool isSell() {
    return orderType == OrderType.Sell;
  }

  BuySell clone() {
    BuySell cloned = BuySell(this.orderType);
    cloned.orderid = this.orderid! + '';
    cloned.orderdate = this.orderdate! + '';
    cloned.accountType = this.accountType! + '';
    cloned.accountName = this.accountName! + '';
    cloned.accountCode = this.accountCode! + '';
    cloned.brokerCode = this.brokerCode! + '';
    cloned.stock_code = this.stock_code! + '';
    cloned.stock_name = this.stock_name! + '';
    cloned.normalTotalValue = this.normalTotalValue + 0;
    cloned.fastTotalValue = this.fastTotalValue + 0;
    cloned.fastMode = this.fastMode;
    cloned.tradingLimitUsage = this.tradingLimitUsage + 0;
    cloned.normalPriceLot = normalPriceLot?.copy();
    //List<PriceLot> _listFastPriceLot = List.empty(growable: true);
    cloned.transactionType = this.transactionType;
    cloned.transactionCounter = this.transactionCounter;
    _listFastPriceLot.forEach((pl) {
      cloned.addFastPriceLot(pl.price, pl.lot);
    });

    return cloned;
  }

  void copyFrom(BuySell newValue) {
    this.orderid = newValue.orderid! + '';
    this.orderdate = newValue.orderdate! + '';
    this.accountType = newValue.accountType! + '';
    this.accountName = newValue.accountName! + '';
    this.accountCode = newValue.accountCode! + '';
    this.brokerCode = newValue.brokerCode! + '';
    this.stock_code = newValue.stock_code! + '';
    this.stock_name = newValue.stock_name! + '';
    this.normalTotalValue = newValue.normalTotalValue + 0;
    this.fastTotalValue = newValue.fastTotalValue + 0;
    this.fastMode = newValue.fastMode;
    this.tradingLimitUsage = newValue.tradingLimitUsage + 0;
    this.normalPriceLot = newValue.normalPriceLot?.copy();
    this._listFastPriceLot.clear();
    newValue.listFastPriceLot?.forEach((pl) {
      this.addFastPriceLot(pl.price, pl.lot);
    });
    this.transactionType = newValue.transactionType;
    this.transactionCounter = newValue.transactionCounter;
  }

  BuySell cloneAsAmend() {
    OrderType? amendType;
    if (this.orderType == OrderType.Buy) {
      amendType = OrderType.AmendBuy;
    } else if (this.orderType == OrderType.Sell) {
      amendType = OrderType.AmendSell;
    }
    BuySell cloned = BuySell(amendType!);
    cloned.orderid = this.orderid! + '';
    cloned.orderdate = this.orderdate! + '';
    cloned.accountType = this.accountType! + '';
    cloned.accountName = this.accountName! + '';
    cloned.accountCode = this.accountCode! + '';
    cloned.brokerCode = this.brokerCode! + '';
    cloned.stock_code = this.stock_code! + '';
    cloned.stock_name = this.stock_name! + '';
    cloned.normalTotalValue = this.normalTotalValue + 0;
    cloned.fastTotalValue = this.fastTotalValue + 0;
    cloned.fastMode = false;
    cloned.tradingLimitUsage = this.tradingLimitUsage + 0;
    cloned.normalPriceLot = normalPriceLot?.copy();
    //List<PriceLot> _listFastPriceLot = List.empty(growable: true);

    _listFastPriceLot.forEach((pl) {
      cloned.addFastPriceLot(pl.price, pl.lot);
    });
    cloned.transactionType = this.transactionType;
    cloned.transactionCounter = this.transactionCounter;

    return cloned;
  }

  @override
  String toString() {
    String fastPriceLot = '';
    int index = 0;
    listFastPriceLot?.forEach((element) {
      if (StringUtils.isEmtpy(fastPriceLot)) {
        fastPriceLot = '  [' + index.toString() + '] ' + element.toString();
      } else {
        fastPriceLot = fastPriceLot +
            '\n  [' +
            index.toString() +
            '] ' +
            element.toString();
      }
      index++;
    });
    return 'BuySell : ' +
        orderType!.routeName +
        '\n  orderid : $orderid' +
        '\n  orderdate : $orderdate' +
        '\n  accountType : $accountType' +
        '\n  accountName : $accountName' +
        '\n  accountCode : $accountCode' +
        '\n  brokerCode : $brokerCode' +
        '\n  stock_code : $stock_code' +
        '\n  stock_name : $stock_name' +
        '\n  normalTotalValue : $normalTotalValue' +
        '\n  fastTotalValue : $fastTotalValue' +
        '\n  fastMode : $fastMode' +
        '\n  transactionType : ' +
        transactionType!.index.toString() +
        '\n  transactionCounter : $transactionCounter' +
        '\n  tradingLimitUsage : $tradingLimitUsage' +
        '\n  normalPriceLot : {' +
        normalPriceLot.toString() +
        '}  listFastPriceLot.size : ' +
        '\n  listFastPriceLot.length : ' +
        listFastPriceLot!.length.toString() +
        '\n  {$fastPriceLot}';
  }

  void setAccount(String? _accountName, String? _accountType,
      String? _accountCode, String? _brokerCode) {
    this.accountName = _accountName;
    this.accountType = _accountType;
    this.accountCode = _accountCode;
    this.brokerCode = _brokerCode;
  }

  void setOrderInformation(String? _orderid, String? _orderdate) {
    this.orderid = _orderid;
    this.orderdate = _orderdate;
  }

  void setStock(String? _code, String? _name) {
    bool changed = !StringUtils.equalsIgnoreCase(this.stock_code, _code);
    this.stock_code = _code;
    this.stock_name = _name!;
    if (changed) {
      normalTotalValue = 0;
      fastTotalValue = 0;
      //fastMode = false;
      tradingLimitUsage = 0;
      normalPriceLot?.clear();
      _listFastPriceLot.clear();
      transactionCounter = 1;
      transactionType = TransactionType.Normal;
      print('DATA ' + orderType!.routeName + ' cleared on stockChanged');
    }
  }

  void clear() {
    orderid = '';
    orderdate = '';
    accountType = '';
    accountName = '';
    accountCode = '';
    brokerCode = '';
    stock_code = ''; //stock code
    stock_name = ''; // stock name
    fastTotalValue = 0;
    normalTotalValue = 0;
    fastMode = false;
    tradingLimitUsage = 0;
    _listFastPriceLot.clear();
    transactionCounter = 1;
    transactionType = TransactionType.Normal;
  }

  void clearOrderOnly() {
    normalTotalValue = 0;
    fastTotalValue = 0;
    tradingLimitUsage = 0;
    normalPriceLot?.clear();
    _listFastPriceLot.clear();
    transactionCounter = 1;
    transactionType = TransactionType.Normal;
  }

  void setFastMode(bool _fastMode) {
    this.fastMode = _fastMode;
    print('DATA ' + orderType!.routeName + ' set fastMode : $fastMode');
  }

  void setNormalPriceLot(
    int price,
    int lot, {
    TransactionType? transactionType,
    int? transactionCounter,
    int totalValue = 0,
  }) {
    normalPriceLot?.update(price, lot);
    if (totalValue <= 0) {
      normalTotalValue = _calculateValue(price, lot);
      if (transactionType != null) {
        this.transactionType = transactionType;
        this.transactionCounter = transactionCounter!;
        if (transactionType == TransactionType.Loop) {
          normalTotalValue = normalTotalValue * transactionCounter;
        }
      }
    } else {
      normalTotalValue = totalValue;
      if (transactionType != null) {
        this.transactionType = transactionType;
        this.transactionCounter = transactionCounter!;
        // if(transactionType == TransactionType.Loop){
        //   normalTotalValue = normalTotalValue * transactionCounter;
        // }
      }
    }
  }

  bool addFastPriceLot(int price, int lot) {
    bool added = false;
    if (price > 0 && lot > 0) {
      _listFastPriceLot.add(PriceLot(price, lot));
      added = true;
      //fastTotalValue += _calculateValue(price, lot);
    }
    return added;
  }

  PriceLot? getFastPriceLot(int byPrice) {
    final PriceLot priceLot = _listFastPriceLot
        .firstWhere((element) => element.price == byPrice, orElse: () {
      // return null;

      return PriceLot(null, null);
    });
    return priceLot;
  }

  void removeFastPriceLot(int byPrice) {
    final index =
        _listFastPriceLot.indexWhere((element) => element.price == byPrice);
    if (index >= 0) {
      //print('Using indexWhere: ${people[index]}');
      // PriceLot pl = _listFastPriceLot.elementAt(index);
      // fastTotalValue -= _calculateValue(pl.price, pl.lot);
      _listFastPriceLot.removeAt(index);
    }
  }

  int _calculateValue(int price, int lot) {
    return price * lot * 100;
  }

  void clearFastPriceLot() {
    _listFastPriceLot.clear();
    fastTotalValue = 0;
  }
}

class Buy extends BuySell {
  Buy() : super(OrderType.Buy);
}

class Sell extends BuySell {
  Sell() : super(OrderType.Sell);
}
