import 'dart:math';

import 'package:Investrend/component/bottom_sheet/bottom_sheet_transaction_filter.dart';
import 'package:Investrend/component/charts/year_value.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/serializeable.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/MarketColors.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class SectorObject {
  String code;
  int member_count;
  String icon;
  double percentChange;

  SectorObject(this.code, this.member_count, this.icon, this.percentChange);

  Widget getIcon(BuildContext context, {double size = 20.0}) {
    String path = getIconAssetPath(context);
    if (!StringUtils.isEmtpy(path)) {
      return Image.asset(
        path,
        width: size,
        height: size,
      );
    } else {
      return Icon(
        Icons.help_outline,
        size: size,
      );
    }
  }

  String getAlias(BuildContext context) {
    if (StringUtils.equalsIgnoreCase(code, 'IDXENERGY')) {
      return 'Energy';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXBASIC')) {
      return 'Basic'; // Basic Materials
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXINDUST')) {
      return 'Industrials';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXNONCYC')) {
      return 'Non-Cyclicals'; // Consumer Non-Cyclicals
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXCYCLIC')) {
      return 'Cyclicals'; // Consumer Cyclicals
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXHEALTH')) {
      return 'Healthcare';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXFINANCE')) {
      return 'Financials';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXPROPERT')) {
      return 'Properties'; // Properties & Real Estate
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXTECHNO')) {
      return 'Technology';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXINFRA')) {
      return 'Infrastructures';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXTRANS')) {
      return 'Transportation'; // Transportation & Logistics
    }
    return code;
  }

  String getIconAssetPath(BuildContext context) {
    if (!StringUtils.isEmtpy(icon)) {
      return icon;
    }
    if (StringUtils.equalsIgnoreCase(code, 'IDXENERGY')) {
      icon = 'images/icons/sector_energy.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXBASIC')) {
      icon = 'images/icons/sector_basic.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXINDUST')) {
      icon = 'images/icons/sector_industrial.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXNONCYC')) {
      icon = 'images/icons/sector_non_cyclic.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXCYCLIC')) {
      icon = 'images/icons/sector_cyclic.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXHEALTH')) {
      icon = 'images/icons/sector_healthcare.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXFINANCE')) {
      icon = 'images/icons/sector_financials.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXPROPERT')) {
      icon = 'images/icons/sector_property.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXTECHNO')) {
      icon = 'images/icons/sector_technology.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXINFRA')) {
      icon = 'images/icons/sector_infrastructure.png';
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXTRANS')) {
      icon = 'images/icons/sector_transportation.png';
    }
    return icon;
  }

  Color getColor(BuildContext context) {
    if (StringUtils.equalsIgnoreCase(code, 'IDXENERGY')) {
      return Color(0xFFFF7692);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXBASIC')) {
      return Color(0xFFEA5970);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXINDUST')) {
      return Color(0xFFFF932E);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXNONCYC')) {
      return Color(0xFFA36199);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXCYCLIC')) {
      return Color(0xFFBC9900);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXHEALTH')) {
      return Color(0xFFE75A5A);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXFINANCE')) {
      return Color(0xFF2C9CDC);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXPROPERT')) {
      return Color(0xFF61C6D4);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXTECHNO')) {
      return Color(0xFF2261A2);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXINFRA')) {
      return Color(0xFF9BD73A);
    } else if (StringUtils.equalsIgnoreCase(code, 'IDXTRANS')) {
      return Color(0xFFE7B030);
    }
    return Theme.of(context).colorScheme.secondary;
  }
// factory SectorObject.fromXml(XmlElement element) {
//   return SectorObject(element.getAttribute('last'), element.getAttribute('code'), double.parse(element.getAttribute('change')), double.parse(element.getAttribute('percentChange')));
// }
}

/*
class OrderData {
  String account;
  String stock_code; // stock code
  String stock_name; // stock name
  String orderType;
  //int price;
  //int lot;
  int value;
  int tradingLimitUsage;

  List<PriceLot> _listPriceLot = List.empty(growable: true);
  OrderData({this.account :'', this.stock_code:'', this.stock_name:'', this.orderType:'', this.value:0,this.tradingLimitUsage:0});

  List<PriceLot> get listPriceLot => _listPriceLot;

  bool addPriceLot(int price, int lot){
    bool added = false;
    if(price > 0 && lot > 0){
      listPriceLot.add(PriceLot(price, lot));
      added = true;
    }
    return added;
  }
  void clearPriceLot(){
    listPriceLot.clear();
  }

  OrderData copy(){
    return OrderData(
        account: account+'',
      orderType: orderType,
      tradingLimitUsage: tradingLimitUsage,
      stock_name: stock_name+'',
      stock_code: stock_code+'',
      value:
    )
  }
}
*/
class PriceLot {
  int _price;
  int _lot;

  PriceLot(this._price, this._lot);

  void update(int price, int lot) {
    _price = price;
    _lot = lot;
  }

  int get price => _price;

  int get lot => _lot;

  void clear() {
    _price = 0;
    _lot = 0;
  }

  @override
  String toString() {
    return 'price : $price  lot : $lot';
  }

  PriceLot copy() {
    return PriceLot(_price, _lot);
  }

  // without fee
  int calculateValue() {
    return price * lot * 100;
  }
}

class PriceLotQueue extends PriceLot {
  int _queue;

  PriceLotQueue(int price, int lot, this._queue) : super(price, lot);

  void clear() {
    super.clear();
    _queue = 0;
  }

  int get queue => _queue;

  @override
  String toString() {
    return super.toString() + '  queue : $_queue';
  }
}

class RegisterReply {
  String message;
  String username;
  String email;

  RegisterReply(this.message, this.username, this.email);

  bool isSuccess() {
    return StringUtils.equalsIgnoreCase(message, 'success');
  }
}

class User {
  String username;
  String realname;
  List<Account> accounts;
  Token token;
  double feepct;
  int lotsize;
  String message;
  String email;

  String b_ip;
  String b_multi;
  String b_pass;
  int b_port;
  String r_ip;
  String r_multi;
  int r_port;

  //User(this.username, this.realname, this.accounts, this.token, this.feepct, this.lotsize, this.message, this.email;

  /*
  "b_ip": "36.89.110.91",
  "b_multi": "8811|5811|3911",
  "b_pass": "83bc008633616fa21c81054d5eaff1573",
  "b_port": "8811",
  "r_ip": "36.89.110.91",
  "r_multi": "80",
  "r_port": "80",
  */
  //"feepct":"0.0015","lotsize":"100"

  User(
      this.username,
      this.realname,
      this.feepct,
      this.lotsize,
      this.accounts,
      this.token,
      this.message,
      this.email,
      this.b_ip,
      this.b_multi,
      this.b_pass,
      this.b_port,
      this.r_ip,
      this.r_multi,
      this.r_port);

  int accountSize() {
    return accounts == null ? 0 : accounts.length;
  }

  Account getAccount(int index) {
    if (accounts != null && accounts.length > index) {
      return accounts.elementAt(index);
    }
    return null;
  }

  Account getAccountByCode(String brokerCode, String accountCode) {
    Account found;
    for (int i = 0; i < accountSize(); i++) {
      Account account = accounts.elementAt(i);
      if (StringUtils.equalsIgnoreCase(brokerCode, account.brokercode) &&
          StringUtils.equalsIgnoreCase(accountCode, account.accountcode)) {
        found = account;
        break;
      }
    }
    return found;
  }

  int getIndexAccountByCode(String brokerCode, String accountCode) {
    int found = -1;
    for (int i = 0; i < accountSize(); i++) {
      Account account = accounts.elementAt(i);
      if (StringUtils.equalsIgnoreCase(brokerCode, account.brokercode) &&
          StringUtils.equalsIgnoreCase(accountCode, account.accountcode)) {
        found = i;
        break;
      }
    }
    return found;
  }

  void update(
      String username,
      String realname,
      double feepct,
      int lotsize,
      List<Account> accounts,
      Token token,
      String message,
      String email,
      String bIp,
      String bMulti,
      String bPass,
      int bPort,
      String rIp,
      String rMulti,
      int rPort) {
    this.username = username;
    this.realname = realname;
    this.feepct = feepct;
    this.lotsize = lotsize;
    this.message = message;
    if (this.accounts == null) {
      this.accounts = List.empty(growable: true);
    } else {
      this.accounts.clear();
    }
    if (accounts != null) {
      this.accounts.addAll(accounts);
    }

    this.token = token;
    this.email = email;

    this.b_ip = bIp;
    this.b_multi = bMulti;
    this.b_pass = bPass;
    this.b_port = bPort;
    this.r_ip = rIp;
    this.r_multi = rMulti;
    this.r_port = rPort;

    DebugWriter.info(
        'update  username : $username  realname : $realname  feepct : $feepct  email : $email  lotsize : $lotsize  message : $message  accounts.size : ' +
            accountSize().toString() +
            '  token : ' +
            token.toString());
  }

  String toString() {
    return 'User  [username : $username]  [realname : $realname]  [email : $email]  [feepct : $feepct]  [lotsize : $lotsize]  [message : $message]  [accounts.size : ' +
        accountSize().toString() +
        ']  [token : ' +
        token.toString() +
        ']';
  }

  bool needRegisterPin() {
    //"message": "pin-empty",
    return StringUtils.equalsIgnoreCase(message, 'pin-empty');
  }

  bool isValid() {
    return !StringUtils.isEmtpy(username) &&
        accounts != null &&
        accounts.length > 0;
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['accounts'] as List;
    print(list.runtimeType); //returns List<dynamic>
    List<Account> accountList = list.map((i) => Account.fromJson(i)).toList();

    String bMultiText = parsedJson['b_multi'];
    String bIp = parsedJson['b_ip'];
    //List<int> b_multi = Utils.parseMultiPort(b_multi_text);
    String bPass = parsedJson['b_pass'];
    int bPort = Utils.safeInt(parsedJson['b_port']);
    String rIp = parsedJson['r_ip'];
    String rMultiText = parsedJson['r_multi'];
    //List<int> r_multi = Utils.parseMultiPort(r_multi_text);
    int rPort = Utils.safeInt(parsedJson['r_port']);

    return User(
        parsedJson['username'],
        parsedJson['realname'],
        Utils.safeDouble(parsedJson['feepct']),
        Utils.safeInt(parsedJson['lotsize']),
        accountList,
        Token.fromJson(parsedJson['token']),
        parsedJson['message'],
        parsedJson['email'],
        bIp,
        bMultiText,
        bPass,
        bPort,
        rIp,
        rMultiText,
        rPort);
  }
}

class Account {
  final String accountcode;
  final String accountname;
  final String branchcode;
  final String brokercode;
  final String type;
  final double commission;

  final String sid;
  final String bank;
  final String acc_no;
  final String acc_name;
  final String subrek;
  final String email;

  String typeString() {
    String typeString = StringUtils.equalsIgnoreCase(this.type, 'R')
        ? 'Regular'
        : (StringUtils.equalsIgnoreCase(this.type, 'M') ? 'Margin' : this.type);
    return typeString;
  }

  String typeShortString() {
    String typeString = StringUtils.equalsIgnoreCase(this.type, 'R')
        ? 'Reg'
        : (StringUtils.equalsIgnoreCase(this.type, 'M') ? 'Mar' : this.type);
    return typeString;
  }

  Account(
      this.accountcode,
      this.accountname,
      this.branchcode,
      this.brokercode,
      this.type,
      this.commission,
      this.sid,
      this.bank,
      this.acc_no,
      this.acc_name,
      this.subrek,
      this.email);

  factory Account.fromJson(Map<String, dynamic> parsedJson) {
    return Account(
      parsedJson['accountcode'],
      parsedJson['accountname'],
      parsedJson['branchcode'],
      parsedJson['brokercode'],
      parsedJson['type'],
      Utils.safeDouble(parsedJson['commission']),
      parsedJson['sid'],
      parsedJson['bank'],
      parsedJson['acc_no'],
      parsedJson['acc_name'],
      parsedJson['subrek'],
      parsedJson['email'],
    );
  }

  @override
  String toString() {
    return 'Account {accountcode: $accountcode, accountname: $accountname, branchcode: $branchcode, brokercode: $brokercode, type: $type, commission: $commission}';
  }
}

class LoginConfig {
  bool rememberMe;
  String username;
  String email;
  bool useBiometrics;

  LoginConfig({
    this.rememberMe = false,
    this.username = '',
    this.email = '',
    this.useBiometrics = false,
  });

  void update(
    bool _rememberMe,
    String _username,
    String _email,
  ) {
    this.rememberMe = _rememberMe;
    this.username = _username;
    this.email = _email;
    this.useBiometrics = _rememberMe;
  }

  Future<bool> load() async {
    final pref = await SharedPreferences.getInstance();

    String updated = pref.getString('login_config_updated') ?? '-';
    this.rememberMe = pref.getBool('remember_me') ?? false;
    this.username = pref.getString('username') ?? '';
    this.email = pref.getString('email') ?? '';
    this.useBiometrics = pref.getBool('use_biometrics') ?? false;

    DebugWriter.info(
        'LoginConfig.load updated : $updated   username : $username   email : $email   rememberMe : $rememberMe');
    return true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    bool savedUpdated = await prefs.setString('login_config_updated', updated);
    bool savedRememberMe = await prefs.setBool('remember_me', rememberMe);
    bool savedUsername = await prefs.setString('username', username);
    bool savedEmail = await prefs.setString('email', email);
    bool savedBiometrics = await prefs.setBool('use_biometrics', useBiometrics);

    bool saved = savedUpdated &&
        savedUsername &&
        savedRememberMe &&
        savedEmail &&
        savedBiometrics;
    print(
        'LoginConfig.save $saved updated : $updated   rememberMe : $rememberMe   username : $username   email : $email');
    return saved;
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'LoginConfig  rememberMe : $rememberMe  username : $username  email : $email';
  }
}

class AppProperties {
  Map<String, int> mapInt = Map<String, int>();
  Map<String, String> mapString = Map<String, String>();
  Map<String, bool> mapBool = Map<String, bool>();

  String _device_id = 'Not Used, use MyDevice';

  AppProperties() {
    load();
  }

  //String get device_id => _device_id;

  bool loaded = false;

  String getString(String routeName, String key, String defaultValue) {
    String keyMap = routeName + '_' + key;
    if (mapString.containsKey(keyMap)) {
      return mapString[keyMap] ?? defaultValue;
    }
    return defaultValue;
  }

  int getInt(String routeName, String key, int defaultValue) {
    String keyMap = routeName + '_' + key;
    if (mapInt.containsKey(keyMap)) {
      return mapInt[keyMap] ?? defaultValue;
    }
    return defaultValue;
  }

  bool getBool(String routeName, String key, bool defaultValue) {
    String keyMap = routeName + '_' + key;
    if (mapBool.containsKey(keyMap)) {
      return mapBool[keyMap] ?? defaultValue;
    }
    return defaultValue;
  }

  void saveString(String routeName, String key, String value) {
    String keyMap = routeName + '_' + key;
    mapString.update(
      keyMap,
      // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
      (existingValue) => value,
      ifAbsent: () => value,
    );
    save();
  }

  void saveInt(String routeName, String key, int value) {
    String keyMap = routeName + '_' + key;
    mapInt.update(
      keyMap,
      // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
      (existingValue) => value,
      ifAbsent: () => value,
    );
    save();
  }

  void saveBool(String routeName, String key, bool value) {
    String keyMap = routeName + '_' + key;
    mapBool.update(
      keyMap,
      // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
      (existingValue) => value,
      ifAbsent: () => value,
    );
    save();
  }

  Future<bool> load({String caller = ''}) async {
    bool needReSave = false;
    final pref = await SharedPreferences.getInstance();

    mapString.clear();
    mapInt.clear();
    mapBool.clear();

    String updated = pref.getString('properties_updated') ?? '-';
    _device_id = pref.getString('device_id') ?? '';
    /*
    if (StringUtils.isEmtpy(_device_id)) {
      this.device_id = getRandomString(5) + '' + DateTime.now().toString().replaceAll(' ', '_');
      print('AppProperties $caller richy_20220708 new device_id : ' + this._device_id);
      needReSave = true;
    }
     */
    List<String> keysString =
        pref.getStringList('keysString') ?? List.empty(growable: true);
    List<String> keysInt =
        pref.getStringList('keysInt') ?? List.empty(growable: true);
    List<String> keysBool =
        pref.getStringList('keysBool') ?? List.empty(growable: true);

    for (String key in keysString) {
      String value = pref.getString(key) ?? '';
      print('AppProperties $caller String --> key : $key  value : $value');
      mapString.update(
        key,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
        (existingValue) => value,
        ifAbsent: () => value,
      );
    }

    for (String key in keysInt) {
      int value = pref.getInt(key) ?? 0;
      print('AppProperties $caller Int --> key : $key  value : $value');
      mapInt.update(
        key,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
        (existingValue) => value,
        ifAbsent: () => value,
      );
    }

    for (String key in keysBool) {
      bool value = pref.getBool(key) ?? false;
      print('AppProperties $caller Bool --> key : $key  value : $value');
      mapBool.update(
        key,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
        (existingValue) => value,
        ifAbsent: () => value,
      );
    }

    //this.refresh_token = pref.getString('refresh_token') ?? '';
    loaded = true;
    print(
        'AppProperties.load $caller #0 richy_20220708 device_id : $_device_id');
    print('AppProperties.load $caller #1 updated : $updated   keysString : ' +
        keysString.length.toString() +
        '   mapString : ' +
        mapString.length.toString());
    print('AppProperties.load $caller #2 updated : $updated   keysInt : ' +
        keysInt.length.toString() +
        '   mapInt : ' +
        mapInt.length.toString());
    print('AppProperties.load $caller #3 updated : $updated   keysBool : ' +
        keysBool.length.toString() +
        '   mapBool : ' +
        mapBool.length.toString());
    return needReSave;
  }

  Future<bool> save({String caller = ''}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    bool savedUpdated = await prefs.setString('properties_updated', updated);
    bool savedDeviceID = await prefs.setString('device_id', _device_id);

    // mapString.forEach((k, v) async{
    //   bool saved = await prefs.setString(k, v);
    // });
    int stringCount = mapString.length;
    int stringSavedCount = 0;
    List<String> keysString = List.empty(growable: true);
    for (MapEntry e in mapString.entries) {
      keysString.add(e.key);
      bool saved = await prefs.setString(e.key, e.value);
      if (saved) {
        stringSavedCount++;
      }
    }
    bool savedKeysString = await prefs.setStringList('keysString', keysString);
    bool savedString = stringCount == stringSavedCount;

    int intCount = mapInt.length;
    int intSavedCount = 0;
    List<String> keysInt = List.empty(growable: true);
    for (MapEntry e in mapInt.entries) {
      keysInt.add(e.key);
      bool saved = await prefs.setInt(e.key, e.value);
      if (saved) {
        intSavedCount++;
      }
    }
    bool savedKeysInt = await prefs.setStringList('keysInt', keysInt);
    bool savedInt = intCount == intSavedCount;

    int boolCount = mapBool.length;
    int boolSavedCount = 0;
    List<String> keysBool = List.empty(growable: true);
    for (MapEntry e in mapBool.entries) {
      keysBool.add(e.key);
      bool saved = await prefs.setBool(e.key, e.value);
      if (saved) {
        boolSavedCount++;
      }
    }
    bool savedKeysBool = await prefs.setStringList('keysBool', keysBool);
    bool savedBool = boolCount == boolSavedCount;
    //bool savedAccessToken = await prefs.setString('access_token', access_token);
    //bool savedRefreshToken = await prefs.setString('refresh_token', refresh_token);

    bool saved = savedDeviceID &&
        savedUpdated &&
        savedString &&
        savedInt &&
        savedBool &&
        savedKeysBool &&
        savedKeysInt &&
        savedKeysString;
    if (saved) {
      print(
          'AppProperties.save $saved $caller richy_20220708 updated : $updated   savedDeviceID : $savedDeviceID   device_id : $_device_id');

      print(
          'AppProperties.save $saved $caller updated : $updated   savedString : $savedString   savedInt : $savedInt   savedBool : $savedBool');
      print(
          'AppProperties.save $saved $caller updated : $updated   savedKeysString : $savedKeysString   savedKeysInt : $savedKeysInt   savedKeysBool : $savedKeysBool');
    } else {
      print(
          'AppProperties.save #0 $saved $caller richy_20220708 updated : $updated   savedDeviceID : $savedDeviceID  device_id : $_device_id');
      print(
          'AppProperties.save #1 $saved $caller updated : $updated   savedKeysString : $savedKeysString  savedString : $savedString  stringCount : $stringCount  stringSavedCount : $stringSavedCount');
      print(
          'AppProperties.save #2 $saved $caller updated : $updated   savedKeysInt : $savedKeysInt  savedInt : $savedInt  intCount : $intCount  intSavedCount : $intSavedCount');
      print(
          'AppProperties.save #3 $saved $caller updated : $updated   savedKeysBool : $savedKeysBool  savedBool : $savedBool  boolCount : $boolCount  boolSavedCount : $boolSavedCount');
    }

    return saved;
  }

  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  /*
  Future<void> createUniqueIDIfPossible({SharedPreferences sharedPreferences}) async {
    if (StringUtils.isEmtpy(_device_id)) {
      this.device_id = getRandomString(5) + '' + DateTime.now().toString().replaceAll(' ', '_');
      print('createUniqueIDIfPossible new unique_id : ' + this._device_id);
      await save(sharedPreferences: sharedPreferences);
    } else {
      //print('random : '+getRandomString(5));
    }
  }
  */
}

class ServerAddress {
  String b_ip;
  List<int> b_multi;
  String b_multi_text;
  String b_pass;
  int b_port;
  String r_ip;
  List<int> r_multi;
  String r_multi_text;
  int r_port;

  String urlPortRequester() {
    return '$r_ip:$r_port';
  }

  ServerAddress(
      this.b_ip,
      this.b_multi_text,
      this.b_pass,
      this.b_port,
      this.r_ip,
      this.r_multi_text,
      this.r_port); //ServerAddress(this.access_token, this.refresh_token);

  void update(String bIp, String bMultiText, String bPass, int bPort,
      String rIp, String rMultiText, int rPort) {
    this.b_ip = bIp;
    this.b_multi_text = bMultiText;
    this.b_pass = bPass;
    this.b_port = bPort;
    this.r_ip = rIp;
    this.r_multi_text = rMultiText;
    this.r_port = rPort;
    this.b_multi = Utils.parseMultiPort(bMultiText);
    this.r_multi = Utils.parseMultiPort(rMultiText);
  }

  Future<bool> load() async {
    final pref = await SharedPreferences.getInstance();

    String updated = pref.getString('server_updated') ?? '-';
    this.b_ip = pref.getString('b_ip') ?? '';
    this.b_multi_text = pref.getString('b_multi_text') ?? '';
    this.b_multi = Utils.parseMultiPort(b_multi_text);
    this.b_pass = pref.getString('b_pass') ?? '';
    this.b_port = pref.getInt('b_port') ?? 0;
    this.r_ip = pref.getString('r_ip') ?? '';
    this.r_multi_text = pref.getString('r_multi_text') ?? '';
    this.r_multi = Utils.parseMultiPort(r_multi_text);
    this.r_port = pref.getInt('r_port') ?? 0;

    print(
        'ServerAddress.load updated : $updated   b_ip : $b_ip   b_port : $b_port   r_ip : $r_ip   r_port : $r_port');
    return true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    bool savedUpdated = await prefs.setString('server_updated', updated);

    bool savedBIp = await prefs.setString('b_ip', b_ip);
    bool savedBMultiText = await prefs.setString('b_multi_text', b_multi_text);
    bool savedBPass = await prefs.setString('b_pass', b_pass);
    bool savedBPort = await prefs.setInt('b_port', b_port);

    bool savedRIp = await prefs.setString('r_ip', r_ip);
    bool savedRMultiText = await prefs.setString('r_multi_text', r_multi_text);
    bool savedRPort = await prefs.setInt('r_port', r_port);

    bool saved = savedUpdated &&
        savedBIp &&
        savedBMultiText &&
        savedBPass &&
        savedBPort &&
        savedRIp &&
        savedRMultiText &&
        savedRPort;
    print('ServerAddress.save $saved updated : $updated' +
        '   saved_b_ip : $savedBIp   saved_b_multi_text : $savedBMultiText' +
        '   saved_b_pass : $savedBPass   saved_b_port : $savedBPort' +
        '   saved_r_ip : $savedRIp   saved_r_multi_text : $savedRMultiText   saved_r_port : $savedRPort');
    return saved;
  }

  @override
  String toString() {
    return 'ServerAddress {b_ip: $b_ip, b_multi_text: $b_multi_text, b_pass: $b_pass, b_port: $b_port, r_ip: $r_ip, r_multi_text: $r_multi_text, r_port: $r_port}';
  }

// factory ServerAddress.fromJson(Map<String, dynamic> parsedJson) {
  //   return ServerAddress(parsedJson['access_token'], parsedJson['refresh_token']);
  // }

}

//TODO : access token dan refresh token
class Token {
  String access_token;
  String refresh_token;

  Token(this.access_token, this.refresh_token);

  void update(String AccessToken, String RefreshToken) {
    this.access_token = AccessToken;
    this.refresh_token = RefreshToken;
  }

  Future<bool> load() async {
    final pref = await SharedPreferences.getInstance();

    String updated = pref.getString('token_updated') ?? '-';
    this.access_token = pref.getString('access_token') ?? '';
    this.refresh_token = pref.getString('refresh_token') ?? '';

    DebugWriter.info(
        'Token.load updated : $updated   access_token : $access_token   refresh_token : $refresh_token');
    return true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    bool savedUpdated = await prefs.setString('token_updated', updated);
    bool savedAccessToken = await prefs.setString('access_token', access_token);
    bool savedRefreshToken =
        await prefs.setString('refresh_token', refresh_token);

    bool saved = savedUpdated && savedAccessToken && savedRefreshToken;
    DebugWriter.info(
        'Token.save $saved updated : $updated   access_token : $access_token   refresh_token : $refresh_token');
    return saved;
  }

  factory Token.fromJson(Map<String, dynamic> parsedJson) {
    return Token(parsedJson['access_token'], parsedJson['refresh_token']);
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Token  access_token : $access_token  refresh_token : $refresh_token';
  }
}

abstract class BaseMessage extends Serializeable {
  String id();

  String type();

  String recipient();

  String created_at = '';
  String sent_at = '';
  String fcm_title = '';
  String fcm_body = '';
  String fcm_image_url = '';
  String fcm_android_color = '';
  String fcm_android_channel_id = '';
  String fcm_data_keys = '';
  String fcm_data_values = '';
  String fcm_message_id = '';
  int read_count = -1;

  BaseMessage(
      this.created_at,
      this.sent_at,
      this.fcm_title,
      this.fcm_body,
      this.fcm_image_url,
      this.fcm_android_color,
      this.fcm_android_channel_id,
      this.fcm_data_keys,
      this.fcm_data_values,
      this.fcm_message_id,
      this.read_count);

  @override
  String toString() {
    return type() +
        ' {id: ' +
        id() +
        ', recipient: ' +
        recipient() +
        ',created_at: $created_at, sent_at: $sent_at, fcm_title: $fcm_title, fcm_body: $fcm_body, fcm_image_url: $fcm_image_url, fcm_android_color: $fcm_android_color, fcm_android_channel_id: $fcm_android_channel_id, fcm_data_keys: $fcm_data_keys, fcm_data_values: $fcm_data_values, fcm_message_id: $fcm_message_id, read_count: $read_count}';
  }

  String toStringContent() {
    return ' {created_at: $created_at, sent_at: $sent_at, fcm_title: $fcm_title, fcm_body: $fcm_body, fcm_image_url: $fcm_image_url, fcm_android_color: $fcm_android_color, fcm_android_channel_id: $fcm_android_channel_id, fcm_data_keys: $fcm_data_keys, fcm_data_values: $fcm_data_values, fcm_message_id: $fcm_message_id, read_count: $read_count}';
  }
}

class InboxMessage extends BaseMessage {
  String ib_id = '';
  String username = '';

  @override
  String toString() {
    return 'InboxMessage{ib_id: $ib_id, username: $username} ' +
        super.toStringContent();
  }

  InboxMessage(
      this.ib_id,
      this.username,
      String createdAt,
      String sentAt,
      String fcmTitle,
      String fcmBody,
      String fcmImageUrl,
      String fcmAndroidColor,
      String fcmAndroidChannelId,
      String fcmDataKeys,
      String fcmDataValues,
      String fcmMessageId,
      int readCount)
      : super(
            createdAt,
            sentAt,
            fcmTitle,
            fcmBody,
            fcmImageUrl,
            fcmAndroidColor,
            fcmAndroidChannelId,
            fcmDataKeys,
            fcmDataValues,
            fcmMessageId,
            readCount);

  @override
  String id() {
    return ib_id;
  }

  @override
  String type() {
    return 'INBOX';
  }

  @override
  String recipient() {
    return username;
  }

  factory InboxMessage.fromJson(
      Map<String, dynamic> parsedJson, String username) {
    /*
    "#": 1,
    "ib_id": "21",
    "created_at": "2021-11-02 22:13:02",
    "sent_at": null,
    "fcm_title": "fcm_title",
    "fcm_body": "fcm_body",
    "fcm_image_url": "fcm_image_url",
    "fcm_android_color": "color",
    "fcm_android_channel_id": "fcm_android_channel_id",
    "fcm_data_keys": "fcm_data_keys",
    "fcm_data_values": "fcm_data_values",
    "fcm_message_id": "fcm_message_id",
    "read_count": "0"
    */
    String ibId = StringUtils.noNullString(parsedJson['ib_id']);
    String createdAt = StringUtils.noNullString(parsedJson['created_at']);
    String sentAt = StringUtils.noNullString(parsedJson['sent_at']);
    String fcmTitle = StringUtils.noNullString(parsedJson['fcm_title']);
    String fcmBody = StringUtils.noNullString(parsedJson['fcm_body']);
    String fcmImageUrl = StringUtils.noNullString(parsedJson['fcm_image_url']);
    String fcmAndroidColor =
        StringUtils.noNullString(parsedJson['fcm_android_color']);
    String fcmAndroidChannelId =
        StringUtils.noNullString(parsedJson['fcm_android_channel_id']);
    String fcmDataKeys = StringUtils.noNullString(parsedJson['fcm_data_keys']);
    String fcmDataValues =
        StringUtils.noNullString(parsedJson['fcm_data_values']);
    String fcmMessageId =
        StringUtils.noNullString(parsedJson['fcm_message_id']);
    int readCount = Utils.safeInt(parsedJson['read_count']);
    return InboxMessage(
        ibId,
        username,
        createdAt,
        sentAt,
        fcmTitle,
        fcmBody,
        fcmImageUrl,
        fcmAndroidColor,
        fcmAndroidChannelId,
        fcmDataKeys,
        fcmDataValues,
        fcmMessageId,
        readCount);
  }

  @override
  String asPlain() {
    String plain = Serializeable.safePlain(id());
    plain += '|' + Serializeable.safePlain(username);
    plain += '|' + Serializeable.safePlain(created_at);
    plain += '|' + Serializeable.safePlain(sent_at);
    plain += '|' + Serializeable.safePlain(fcm_title);
    plain += '|' + Serializeable.safePlain(fcm_body);
    plain += '|' + Serializeable.safePlain(fcm_image_url);
    plain += '|' + Serializeable.safePlain(fcm_android_color);
    plain += '|' + Serializeable.safePlain(fcm_android_channel_id);
    plain += '|' + Serializeable.safePlain(fcm_data_keys);
    plain += '|' + Serializeable.safePlain(fcm_data_values);
    plain += '|' + Serializeable.safePlain(fcm_message_id);
    plain += '|' + Serializeable.safePlain(read_count.toString());
    return plain;
  }

  factory InboxMessage.fromPlain(String data) {
    List<String> datas = data.split('|');
    if (datas != null && datas.isNotEmpty && datas.length >= 13) {
      String ibId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(0)));
      String username = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(1)));
      String createdAt = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(2)));
      String sentAt = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(3)));
      String fcmTitle = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(4)));
      String fcmBody = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(5)));
      String fcmImageUrl = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(6)));
      String fcmAndroidColor = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(7)));
      String fcmAndroidChannelId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(8)));
      String fcmDataKeys = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(9)));
      String fcmDataValues = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(10)));
      String fcmMessageId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(11)));
      int readCount = Utils.safeInt(Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(12))));

      return InboxMessage(
          ibId,
          username,
          createdAt,
          sentAt,
          fcmTitle,
          fcmBody,
          fcmImageUrl,
          fcmAndroidColor,
          fcmAndroidChannelId,
          fcmDataKeys,
          fcmDataValues,
          fcmMessageId,
          readCount);
    }
    return null;
  }

  @override
  String identity() {
    return type();
  }
}

class BroadcastMessage extends BaseMessage {
  String bc_id = '';
  String topic = '';

  BroadcastMessage(
      this.bc_id,
      this.topic,
      String createdAt,
      String sentAt,
      String fcmTitle,
      String fcmBody,
      String fcmImageUrl,
      String fcmAndroidColor,
      String fcmAndroidChannelId,
      String fcmDataKeys,
      String fcmDataValues,
      String fcmMessageId,
      int readCount)
      : super(
            createdAt,
            sentAt,
            fcmTitle,
            fcmBody,
            fcmImageUrl,
            fcmAndroidColor,
            fcmAndroidChannelId,
            fcmDataKeys,
            fcmDataValues,
            fcmMessageId,
            readCount);

  @override
  String id() {
    return bc_id;
  }

  @override
  String type() {
    return 'BROADCAST';
  }

  @override
  String toString() {
    return 'BroadcastMessage{bc_id: $bc_id, topic: $topic} ' +
        super.toStringContent();
  }

  @override
  String recipient() {
    return topic;
  }

  factory BroadcastMessage.fromJson(
      Map<String, dynamic> parsedJson, String topic) {
    String bcId = StringUtils.noNullString(parsedJson['bc_id']);
    String createdAt = StringUtils.noNullString(parsedJson['created_at']);
    String sentAt = StringUtils.noNullString(parsedJson['sent_at']);
    String fcmTitle = StringUtils.noNullString(parsedJson['fcm_title']);
    String fcmBody = StringUtils.noNullString(parsedJson['fcm_body']);
    String fcmImageUrl = StringUtils.noNullString(parsedJson['fcm_image_url']);
    String fcmAndroidColor =
        StringUtils.noNullString(parsedJson['fcm_android_color']);
    String fcmAndroidChannelId =
        StringUtils.noNullString(parsedJson['fcm_android_channel_id']);
    String fcmDataKeys = StringUtils.noNullString(parsedJson['fcm_data_keys']);
    String fcmDataValues =
        StringUtils.noNullString(parsedJson['fcm_data_values']);
    String fcmMessageId =
        StringUtils.noNullString(parsedJson['fcm_message_id']);
    int readCount = Utils.safeInt(parsedJson['read_count']);
    return BroadcastMessage(
        bcId,
        topic,
        createdAt,
        sentAt,
        fcmTitle,
        fcmBody,
        fcmImageUrl,
        fcmAndroidColor,
        fcmAndroidChannelId,
        fcmDataKeys,
        fcmDataValues,
        fcmMessageId,
        readCount);
  }

  @override
  String asPlain() {
    String plain = Serializeable.safePlain(id());
    plain += '|' + Serializeable.safePlain(topic);
    plain += '|' + Serializeable.safePlain(created_at);
    plain += '|' + Serializeable.safePlain(sent_at);
    plain += '|' + Serializeable.safePlain(fcm_title);
    plain += '|' + Serializeable.safePlain(fcm_body);
    plain += '|' + Serializeable.safePlain(fcm_image_url);
    plain += '|' + Serializeable.safePlain(fcm_android_color);
    plain += '|' + Serializeable.safePlain(fcm_android_channel_id);
    plain += '|' + Serializeable.safePlain(fcm_data_keys);
    plain += '|' + Serializeable.safePlain(fcm_data_values);
    plain += '|' + Serializeable.safePlain(fcm_message_id);
    plain += '|' + Serializeable.safePlain(read_count.toString());
    return plain;
  }

  factory BroadcastMessage.fromPlain(String data) {
    List<String> datas = data.split('|');
    if (datas != null && datas.isNotEmpty && datas.length >= 13) {
      String bcId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(0)));
      String topic = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(1)));
      String createdAt = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(2)));
      String sentAt = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(3)));
      String fcmTitle = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(4)));
      String fcmBody = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(5)));
      String fcmImageUrl = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(6)));
      String fcmAndroidColor = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(7)));
      String fcmAndroidChannelId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(8)));
      String fcmDataKeys = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(9)));
      String fcmDataValues = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(10)));
      String fcmMessageId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(11)));
      int readCount = Utils.safeInt(Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(12))));

      return BroadcastMessage(
          bcId,
          topic,
          createdAt,
          sentAt,
          fcmTitle,
          fcmBody,
          fcmImageUrl,
          fcmAndroidColor,
          fcmAndroidChannelId,
          fcmDataKeys,
          fcmDataValues,
          fcmMessageId,
          readCount);
    }
    return null;
  }

  @override
  String identity() {
    return type();
  }
}

class MyDevice {
  String unique_id;

  MyDevice();

  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  // Future<void> createUniqueIDIfPossible() async {
  //   if (StringUtils.isEmtpy(unique_id)) {
  //     this.unique_id = getRandomString(5) +
  //         '_' +
  //         DateTime.now().toString().replaceAll(' ', '_');
  //     print('createUniqueIDIfPossible new unique_id : ' + getRandomString(5));
  //     await save();
  //   } else {
  //     //print('random : '+getRandomString(5));
  //   }
  // }
  Future<void> createUniqueIDIfPossible() async {
    if (StringUtils.isEmtpy(unique_id)) {
      this.unique_id = getRandomString(5) +
          '' +
          DateTime.now().toString().replaceAll(' ', '');
      print('createUniqueIDIfPossible new unique_id : ' + this.unique_id);
      await save();
    } else {
      //print('random : '+getRandomString(5));
    }
  }

  Future<bool> load() async {
    final pref = await SharedPreferences.getInstance();

    String updated = pref.getString('device_updated') ?? '-';
    this.unique_id = pref.getString('unique_id') ?? '';
    print('MyDevice.load updated : $updated   unique_id : $unique_id ');
    return true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    bool savedUpdated = await prefs.setString('device_updated', updated);
    bool savedUniqueID = await prefs.setString('unique_id', unique_id);

    bool saved = savedUpdated && savedUniqueID;
    print(
        'MyDevice.save $saved updated : $updated   savedUniqueID : $savedUniqueID');
    return saved;
  }

  @override
  String toString() {
    return 'MyDevice  unique_id : $unique_id';
  }

  Future<String> getUniqId() {
    return load().then(
      (v) {
        if (v == false) return "";
        if (this.unique_id == "") {
          return createUniqueIDIfPossible().then((value) {
            return this.unique_id;
          });
        }
      },
    );
  }
}

class Invitation {
  String invitation_code;
  bool invitation_status;

  Invitation(this.invitation_code, this.invitation_status);

  void update(String _code, bool _status) {
    this.invitation_code = _code;
    this.invitation_status = _status;
  }

  Future<bool> load() async {
    final pref = await SharedPreferences.getInstance();

    String updated = pref.getString('invitation_updated') ?? '-';
    this.invitation_code = pref.getString('invitation_code') ?? '';
    this.invitation_status = pref.getBool('invitation_status') ?? '';
    DebugWriter.info(
        'Invitation.load updated : $updated   invitation_code : $invitation_code  invitation_status : $invitation_status ');
    return true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    bool savedUpdated = await prefs.setString('invitation_updated', updated);
    bool savedCode = await prefs.setString('invitation_code', invitation_code);
    bool savedStatus =
        await prefs.setBool('invitation_status', invitation_status);
    bool saved = savedUpdated && savedCode && savedStatus;
    print(
        'Invitation.save $saved updated : $updated   invitation_code : $invitation_code   invitation_status : $invitation_status');
    return saved;
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Invitation  invitation_code : $invitation_code  invitation_status : $invitation_status';
  }
}

class CashPosition {
  String accountcode = '';
  String accountName = '';
  String accountType = '';
  double creditLimit = 0;
  double tradingLimit = 0;
  double cashMargin = 0;
  double stockMargin = 0;
  double marginRatio = 0;
  double currentRatio = 0;
  double cashBalance = 0;
  double openBuy = 0;
  double openSell = 0;
  double doneBuy = 0;
  double doneSell = 0;
  double outstandingLimit = 0;
  double overLimit = 0;
  double rdnBalance = 0;
  double availableCash = 0;

  static createBasic() {
    return CashPosition(
        '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  }

  CashPosition(
      this.accountcode,
      this.accountName,
      this.accountType,
      this.creditLimit,
      this.tradingLimit,
      this.cashMargin,
      this.stockMargin,
      this.marginRatio,
      this.currentRatio,
      this.cashBalance,
      this.openBuy,
      this.openSell,
      this.doneBuy,
      this.doneSell,
      this.outstandingLimit,
      this.overLimit,
      this.rdnBalance,
      this.availableCash);

  factory CashPosition.fromJson(Map<String, dynamic> parsedJson) {
    return CashPosition(
        parsedJson['accountcode'],
        parsedJson['accountName'],
        parsedJson['accountType'],
        Utils.safeDouble(parsedJson['creditLimit']),
        Utils.safeDouble(parsedJson['tradingLimit']),
        Utils.safeDouble(parsedJson['cashMargin']),
        Utils.safeDouble(parsedJson['stockMargin']),
        Utils.safeDouble(parsedJson['marginRatio']),
        Utils.safeDouble(parsedJson['currentRatio']),
        Utils.safeDouble(parsedJson['cashBalance']),
        Utils.safeDouble(parsedJson['openBuy']),
        Utils.safeDouble(parsedJson['openSell']),
        Utils.safeDouble(parsedJson['doneBuy']),
        Utils.safeDouble(parsedJson['doneSell']),
        Utils.safeDouble(parsedJson['outstandingLimit']),
        Utils.safeDouble(parsedJson['overLimit']),
        Utils.safeDouble(parsedJson['rdnBalance']),
        Utils.safeDouble(parsedJson['availableCash']));
  }

  String toString() {
    return 'CashPosition  [accountcode=$accountcode]  [accountName=$accountName]  [accountType=$accountType]  [creditLimit=$creditLimit]  [tradingLimit=$tradingLimit]  [cashMargin=$cashMargin]  '
        '[stockMargin=$stockMargin]  [marginRatio=$marginRatio]  [currentRatio=$currentRatio]  [cashBalance=$cashBalance]  [openBuy=$openBuy]  [openSell=$openSell]  [doneBuy=$doneBuy]  [doneSell=$doneSell]  '
        '[outstandingLimit=$outstandingLimit]  [overLimit=$overLimit]  [rdnBalance=$rdnBalance]  [availableCash=$availableCash]';
  }

  void copyValueFrom(CashPosition newValue) {
    if (newValue != null) {
      this.accountcode = newValue.accountcode;
      this.accountName = newValue.accountName;
      this.accountType = newValue.accountType;
      this.creditLimit = newValue.creditLimit;
      this.tradingLimit = newValue.tradingLimit;
      this.cashMargin = newValue.cashMargin;
      this.stockMargin = newValue.stockMargin;
      this.marginRatio = newValue.marginRatio;
      this.currentRatio = newValue.currentRatio;
      this.cashBalance = newValue.cashBalance;
      this.openBuy = newValue.openBuy;
      this.openSell = newValue.openSell;
      this.doneBuy = newValue.doneBuy;
      this.doneSell = newValue.doneSell;
      this.outstandingLimit = newValue.outstandingLimit;
      this.overLimit = newValue.overLimit;
      this.rdnBalance = newValue.rdnBalance;
      this.availableCash = newValue.availableCash;
    } else {
      this.accountcode = '';
      this.accountName = '';
      this.accountType = '';
      this.creditLimit = 0;
      this.tradingLimit = 0;
      this.cashMargin = 0;
      this.stockMargin = 0;
      this.marginRatio = 0;
      this.currentRatio = 0;
      this.cashBalance = 0;
      this.openBuy = 0;
      this.openSell = 0;
      this.doneBuy = 0;
      this.doneSell = 0;
      this.outstandingLimit = 0;
      this.overLimit = 0;
      this.rdnBalance = 0;
      this.availableCash = 0;
    }
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(accountcode);
  }
}

class StockPositionDetail {
  String stockCode;
  double beginBalance;
  double balance;
  double netBalance;
  double avgPrice;
  double stockVal;
  double marketPrice;
  double marketVal;
  double marketValHaircut;
  double cost;
  double stockGL;
  double stockGLPct;
  double todayGL;
  double todayGLPct;
  double portfolioPct;

  bool loaded = false;
  StockPositionDetail(
      this.stockCode,
      this.beginBalance,
      this.balance,
      this.netBalance,
      this.avgPrice,
      this.stockVal,
      this.marketPrice,
      this.marketVal,
      this.marketValHaircut,
      this.cost,
      this.stockGL,
      this.stockGLPct,
      this.todayGL,
      this.todayGLPct,
      this.portfolioPct);

  factory StockPositionDetail.fromJson(Map<String, dynamic> parsedJson) {
    return StockPositionDetail(
        parsedJson['stockCode'],
        Utils.safeDouble(parsedJson['beginBalance']),
        Utils.safeDouble(parsedJson['balance']),
        Utils.safeDouble(parsedJson['netBalance']),
        Utils.safeDouble(parsedJson['avgPrice']),
        Utils.safeDouble(parsedJson['stockVal']),
        Utils.safeDouble(parsedJson['marketPrice']),
        Utils.safeDouble(parsedJson['marketVal']),
        Utils.safeDouble(parsedJson['marketValHaircut']),
        Utils.safeDouble(parsedJson['cost']),
        Utils.safeDouble(parsedJson['stockGL']),
        Utils.safeDouble(parsedJson['stockGLPct']),
        Utils.safeDouble(parsedJson['todayGL']),
        Utils.safeDouble(parsedJson['todayGLPct']),
        Utils.safeDouble(parsedJson['portfolioPct']));
  }
  static StockPositionDetail createBasic() {
    return new StockPositionDetail('', 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
  }

  void copyValueFrom(StockPositionDetail newValue) {
    if (newValue != null) {
      this.loaded = true;

      this.stockCode = newValue.stockCode;
      this.beginBalance = newValue.beginBalance;
      this.balance = newValue.balance;
      this.netBalance = newValue.netBalance;
      this.avgPrice = newValue.avgPrice;
      this.stockVal = newValue.stockVal;
      this.marketPrice = newValue.marketPrice;
      this.marketVal = newValue.marketVal;
      this.marketValHaircut = newValue.marketValHaircut;
      this.cost = newValue.cost;
      this.stockGL = newValue.stockGL;
      this.stockGLPct = newValue.stockGLPct;
      this.todayGL = newValue.todayGL;
      this.todayGLPct = newValue.todayGLPct;
      this.portfolioPct = newValue.portfolioPct;
    } else {
      this.stockCode = '';
      this.beginBalance = 0.0;
      this.balance = 0.0;
      this.netBalance = 0.0;
      this.avgPrice = 0.0;
      this.stockVal = 0.0;
      this.marketPrice = 0.0;
      this.marketVal = 0.0;
      this.marketValHaircut = 0.0;
      this.cost = 0.0;
      this.stockGL = 0.0;
      this.stockGLPct = 0.0;
      this.todayGL = 0.0;
      this.todayGLPct = 0.0;
      this.portfolioPct = 0.0;
    }
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(stockCode);
  }
}

class StockPosition {
  String accountcode;
  double totalCost;
  double totalMarket;
  double totalGL;
  double totalGLPct;
  double totalTodayGL;
  double totalTodayGLPct;

  List<StockPositionDetail> stocksList;
  bool loaded = false;

  StockPosition(
      this.accountcode,
      this.totalCost,
      this.totalMarket,
      this.totalGL,
      this.totalGLPct,
      this.totalTodayGL,
      this.totalTodayGLPct,
      this.stocksList);

  @override
  String toString() {
    return 'StockPosition { accountcode: $accountcode, totalCost: $totalCost, totalMarket: $totalMarket, totalGL: $totalGL, totalGLPct: $totalGLPct, totalTodayGL: $totalTodayGL, totalTodayGLPct: $totalTodayGLPct, stocksList: ' +
        stockListSize().toString() +
        ', loaded: $loaded }';
  }

  int stockListSize() {
    return stocksList == null ? 0 : stocksList.length;
  }

  StockPositionDetail getStockPositionDetail(int index) {
    if (stocksList != null && stocksList.length > index) {
      return stocksList.elementAt(index);
    }
    return null;
  }

  int count() {
    return stocksList == null ? 0 : stocksList.length;
  }

  bool isEmpty() {
    return count() == 0;
  }

  String joinCode(String delimiter) {
    String joined = '';
    if (count() > 0) {
      for (int i = 0; i < count(); i++) {
        StockPositionDetail spd = stocksList.elementAt(i);
        if (spd != null) {
          if (StringUtils.isEmtpy(joined)) {
            joined = spd.stockCode;
          } else {
            joined = joined + delimiter + spd.stockCode;
          }
        }
      }
    }
    return joined;
  }

  void copyValueFrom(StockPosition newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.accountcode = newValue.accountcode;
      this.totalCost = newValue.totalCost;
      this.totalMarket = newValue.totalMarket;
      this.totalGL = newValue.totalGL;
      this.totalGLPct = newValue.totalGLPct;
      this.totalTodayGL = newValue.totalTodayGL;
      this.totalTodayGLPct = newValue.totalTodayGLPct;

      this.stocksList.clear();
      if (newValue.stocksList != null) {
        this.stocksList.addAll(newValue.stocksList);
      }
    } else {
      this.accountcode = '';
      this.totalCost = 0;
      this.totalMarket = 0;
      this.totalGL = 0;
      this.totalGLPct = 0;
      this.totalTodayGL = 0;
      this.totalTodayGLPct = 0;
      this.stocksList.clear();
    }
  }

  StockPositionDetail getStockPositionDetailByCode(String code) {
    int count = stocksList != null ? stocksList.length : 0;
    StockPositionDetail found;
    for (int i = 0; i < count; i++) {
      StockPositionDetail existing = stocksList.elementAt(i);
      if (existing != null &&
          StringUtils.equalsIgnoreCase(existing.stockCode, code)) {
        found = existing;
      }
    }
    return found;
  }

  // void update(String username, String realname, List<Account> accounts, Token token) {
  //   this.username = username;
  //   this.realname = realname;
  //   this.accounts = accounts;
  //   this.token = token;
  // }

  bool isValid() {
    return !StringUtils.isEmtpy(accountcode) &&
        stocksList != null &&
        stocksList.length > 0;
  }

  factory StockPosition.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['StockPositionDetail'] as List;
    List<StockPositionDetail> stocksList;
    if (list != null) {
      print(list.runtimeType); //returns List<dynamic>
      stocksList = list.map((i) => StockPositionDetail.fromJson(i)).toList();
    } else {
      print('StockPositionDetail list is null'); //returns List<dynamic>
    }

    return StockPosition(
        parsedJson['accountcode'],
        Utils.safeDouble(parsedJson['totalCost']),
        Utils.safeDouble(parsedJson['totalMarket']),
        Utils.safeDouble(parsedJson['totalGL']),
        Utils.safeDouble(parsedJson['totalGLPct']),
        Utils.safeDouble(parsedJson['totalTodayGL']),
        Utils.safeDouble(parsedJson['totalTodayGLPct']),
        stocksList);
  }
}

class YourPosition {
  String code = '';
  double jumlahLot = 0;
  double averagePrice = 0.0;
  double marketValue = 0;
  double percentPortfolio = 0.0;

  int todayReturnValue = 0;
  double todayReturnPercentage = 0.0;
  double totalReturnValue = 0;
  double totalReturnPercentage = 0.0;
  bool loaded;

  YourPosition(
      {this.code = '',
      this.jumlahLot = 0,
      this.averagePrice = 0.0,
      this.marketValue = 0,
      this.percentPortfolio = 0.0,
      this.todayReturnValue = 0,
      this.todayReturnPercentage = 0.0,
      this.totalReturnValue = 0,
      this.totalReturnPercentage = 0.0});

  void copyValueFrom(YourPosition newValue) {
    if (newValue != null) {
      loaded = true;
      this.code = newValue.code;
      this.jumlahLot = newValue.jumlahLot;
      this.averagePrice = newValue.averagePrice;
      this.marketValue = newValue.marketValue;
      this.percentPortfolio = newValue.percentPortfolio;
      this.todayReturnValue = newValue.todayReturnValue;
      this.todayReturnPercentage = newValue.todayReturnPercentage;
      this.totalReturnValue = newValue.totalReturnValue;
      this.totalReturnPercentage = newValue.totalReturnPercentage;
    } else {
      this.code = '';
      this.jumlahLot = 0;
      this.averagePrice = 0.0;
      this.marketValue = 0;
      this.percentPortfolio = 0.0;
      this.todayReturnValue = 0;
      this.todayReturnPercentage = 0.0;
      this.totalReturnValue = 0;
      this.totalReturnPercentage = 0.0;
    }
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }
}

class OrderStatus {
  String orderDate;
  String requestTime;
  String sendTime;
  String openTime;
  String orderid;
  String sasOrderNumber;
  String idxOrderNumber;
  String brokercode;
  String accountcode;
  String bs;
  String boardCode;
  String stockCode;
  int price;
  int amendPrice;
  int orderQty;
  int balanceQty;
  int rejectQty;
  int matchQty;
  int amendQty;
  String orderStatus;
  int actionType;
  String actionDesc;
  String salesCode;
  String executor;
  String executeDevice;
  String message;

  OrderStatus(
      this.orderDate,
      this.requestTime,
      this.sendTime,
      this.openTime,
      this.orderid,
      this.sasOrderNumber,
      this.idxOrderNumber,
      this.brokercode,
      this.accountcode,
      this.bs,
      this.boardCode,
      this.stockCode,
      this.price,
      this.amendPrice,
      this.orderQty,
      this.balanceQty,
      this.rejectQty,
      this.matchQty,
      this.amendQty,
      this.orderStatus,
      this.actionType,
      this.actionDesc,
      this.salesCode,
      this.executor,
      this.executeDevice,
      this.message);

  /*
            ORDER_STATUS_NEW = 0,
            ORDER_STATUS_OPEN = 1,
            ORDER_STATUS_CANCEL = 2,
            ORDER_STATUS_MATCH = 3,
            ORDER_STATUS_REJECT = 4

  switch result.OrderStatus {
  case "0":
    result.OrderStatus = "New"
  case "1":
    result.OrderStatus = "Open"
  case "2":
    result.OrderStatus = "Cancel"
  case "3":
    result.OrderStatus = "Match"
  case "4":
    result.OrderStatus = "Reject"
  }
*/

  bool isFilterHistoricalValid(int indexTransaction, int indexPeriod,
      {int start = 0, int end = 0}) {
    //enum FilterTransaction { All, Buy, Sell}
    //enum FilterStatus { All, Open, Match, Partial, Withdraw, Reject, New }

    if (indexTransaction == FilterTransaction.All.index &&
        indexPeriod == FilterPeriod.ThisWeek.index /*FilterPeriod.All.index*/) {
      return true;
    }

    if (indexTransaction == FilterTransaction.Buy.index &&
        !StringUtils.equalsIgnoreCase(this.bs, 'B')) {
      return false;
    }
    if (indexTransaction == FilterTransaction.Sell.index &&
        !StringUtils.equalsIgnoreCase(this.bs, 'S')) {
      return false;
    }
    if (indexPeriod ==
        FilterPeriod.ThisWeek.index /* FilterPeriod.All.index */) {
      return true;
    }
    if (indexPeriod == FilterPeriod.Today.index) {
      return true;
    }
    if (start == 0 || end == 0) {
      return false;
    }
    int dateInt = Utils.safeInt(orderDate);
    if (dateInt <= 0) {
      return false;
    }
    if (dateInt >= start && dateInt <= end) {
      return true;
    }
    return false;

    //return true; // sementara dibuka semua, karena belum tau filter period nya
  }

  bool isFilterValid(int indexTransaction, int indexStatus) {
    //enum FilterTransaction { All, Buy, Sell}
    //enum FilterStatus { All, Open, Match, Partial, Withdraw, Reject, New }

    if (indexTransaction == FilterTransaction.All.index &&
        indexStatus == FilterStatus.All.index) {
      return true;
    }

    if (indexTransaction == FilterTransaction.Buy.index &&
        !StringUtils.equalsIgnoreCase(this.bs, 'B')) {
      return false;
    }
    if (indexTransaction == FilterTransaction.Sell.index &&
        !StringUtils.equalsIgnoreCase(this.bs, 'S')) {
      return false;
    }
    if (indexStatus == FilterStatus.All.index) {
      return true;
    }
    if (indexStatus == FilterStatus.Open.index &&
        (StringUtils.equalsIgnoreCase(this.orderStatus, 'Open') ||
            StringUtils.equalsIgnoreCase(this.orderStatus, 'Partial'))) {
      return true;
    }
    if (indexStatus == FilterStatus.Match.index &&
        StringUtils.equalsIgnoreCase(this.orderStatus, 'Match')) {
      return true;
    }
    // if (index_status == FilterStatus.Partial.index &&
    //     (StringUtils.equalsIgnoreCase(this.orderStatus, 'Partial') || StringUtils.equalsIgnoreCase(this.orderStatus, 'Withdraw-P'))) {
    //   return true;
    // }
    if (indexStatus == FilterStatus.Withdraw.index &&
        (StringUtils.equalsIgnoreCase(this.orderStatus, 'Withdraw') ||
            StringUtils.equalsIgnoreCase(this.orderStatus, 'Cancel') ||
            StringUtils.equalsIgnoreCase(this.orderStatus, 'Withdraw-P'))) {
      return true;
    }
    if (indexStatus == FilterStatus.Reject.index &&
        StringUtils.equalsIgnoreCase(this.orderStatus, 'Reject')) {
      return true;
    }
    if (indexStatus == FilterStatus.New.index &&
        StringUtils.equalsIgnoreCase(this.orderStatus, 'New')) {
      return true;
    }

    return false;
  }

  bool gotMessage() {
    return !StringUtils.isEmtpy(message) &&
        !StringUtils.equalsIgnoreCase(
            message, '-'); // || !StringUtils.isEmtpy(actionDesc);
  }

  String getMessage() {
    if (!StringUtils.isEmtpy(message)) {
      return message;
    }

    // if(!StringUtils.isEmtpy(actionDesc)){
    //   return actionDesc;
    // }
  }

  bool canAmend() {
    return !StringUtils.isEmtpy(this.orderStatus) &&
        (StringUtils.equalsIgnoreCase(this.orderStatus, 'open') ||
            StringUtils.equalsIgnoreCase(this.orderStatus, 'partial'));
  }

  bool canWithdraw() {
    return !StringUtils.isEmtpy(this.orderStatus) &&
        !StringUtils.equalsIgnoreCase(this.orderStatus, 'reject') &&
        !StringUtils.equalsIgnoreCase(this.orderStatus, 'Match') &&
        !StringUtils.equalsIgnoreCase(this.orderStatus, 'Withdraw') &&
        !StringUtils.equalsIgnoreCase(this.orderStatus, 'Withdraw-P') &&
        !StringUtils.equalsIgnoreCase(this.orderStatus, 'Cancel');
  }

  static final Color colorMatch = Color(0xFFE5D8FF);
  static final Color colorReject = Color(0xFFFFDFDF);
  static final Color colorOpen = Color(0xFFF2F2F2);
  static final Color colorPartial = Color(0xFFFFEFC7);
  static final Color colorWithdraw = Color(0xFFD1D1D1);

  Color backgroundColor(BuildContext context) {
    // Match: E5D8FF
    // Reject: FFDFDF
    // Open: F2F2F2
    // Partial: FFEFC7
    // Withdraw: D1D1D1
    if (StringUtils.equalsIgnoreCase(this.orderStatus, 'reject')) {
      return colorReject;
    } else if (StringUtils.equalsIgnoreCase(this.orderStatus, 'Match')) {
      return colorMatch;
    } else if (StringUtils.equalsIgnoreCase(this.orderStatus, 'Withdraw') ||
        StringUtils.equalsIgnoreCase(this.orderStatus, 'Cancel') ||
        StringUtils.equalsIgnoreCase(this.orderStatus, 'Withdraw-P')) {
      return colorWithdraw;
    } else if (StringUtils.equalsIgnoreCase(this.orderStatus, 'Partial')) {
      return colorPartial;
    } else if (StringUtils.equalsIgnoreCase(this.orderStatus, 'Open')) {
      return colorOpen;
    }
    return InvestrendTheme.of(context).tileBackground;
  }

  void copyValueFrom(OrderStatus newValue) {
    if (newValue != null) {
      this.orderDate = newValue.orderDate;
      this.requestTime = newValue.requestTime;
      this.sendTime = newValue.sendTime;
      this.openTime = newValue.openTime;
      this.orderid = newValue.orderid;
      this.sasOrderNumber = newValue.sasOrderNumber;
      this.idxOrderNumber = newValue.idxOrderNumber;
      this.brokercode = newValue.brokercode;
      this.accountcode = newValue.accountcode;
      this.bs = newValue.bs;
      this.boardCode = newValue.boardCode;
      this.stockCode = newValue.stockCode;
      this.price = newValue.price;
      this.amendPrice = newValue.amendPrice;
      this.orderQty = newValue.orderQty;
      this.balanceQty = newValue.balanceQty;
      this.rejectQty = newValue.rejectQty;
      this.matchQty = newValue.matchQty;
      this.amendQty = newValue.amendQty;
      this.orderStatus = newValue.orderStatus;
      this.actionType = newValue.actionType;
      this.actionDesc = newValue.actionDesc;
      this.salesCode = newValue.salesCode;
      this.executor = newValue.executor;
      this.executeDevice = newValue.executeDevice;
      this.message = newValue.message;
    } else {
      this.orderDate = '';
      this.requestTime = '';
      this.sendTime = '';
      this.openTime = '';
      this.orderid = '';
      this.sasOrderNumber = '';
      this.idxOrderNumber = '';
      this.brokercode = '';
      this.accountcode = '';
      this.bs = '';
      this.boardCode = '';
      this.stockCode = '';
      this.price = 0;
      this.amendPrice = 0;
      this.orderQty = 0;
      this.balanceQty = 0;
      this.rejectQty = 0;
      this.matchQty = 0;
      this.amendQty = 0;
      this.orderStatus = '';
      this.actionType = 0;
      this.actionDesc = '';
      this.salesCode = '';
      this.executor = '';
      this.executeDevice = '';
      this.message = '';
    }
  }

  String getTime() {
    String time = '';
    if (!StringUtils.isEmtpy(this.openTime) &&
        Utils.safeInt(this.openTime) > 0) {
      time = openTime;
    } else if (!StringUtils.isEmtpy(this.sendTime)) {
      time = sendTime;
    } else {
      time = requestTime;
    }
    return time;
  }

  String getTimeFormatted() {
    String time = '';
    if (!StringUtils.isEmtpy(this.openTime) &&
        Utils.safeInt(this.openTime) > 0) {
      time = Utils.formatOrderTime(this.openTime);
    } else if (!StringUtils.isEmtpy(this.sendTime)) {
      time = Utils.formatOrderTime(this.sendTime);
    } else {
      time = Utils.formatOrderTime(this.requestTime);
    }
    return time;
  }

  String getDateFormatted() {
    return Utils.formatOrderDate(this.orderDate);
  }

  String toString() {
    return 'OrderStatus  [orderDate=$orderDate]  [requestTime=$requestTime]  [sendTime=$sendTime]  [openTime=$openTime]  [orderid=$orderid]  [sasOrderNumber=$sasOrderNumber]  '
        '[idxOrderNumber=$idxOrderNumber]  [brokercode=$brokercode]  [accountcode=$accountcode]  [bs=$bs]  [boardCode=$boardCode]  [stockCode=$stockCode]  [price=$price]  [amendPrice=$amendPrice]  '
        '[orderQty=$orderQty]  [balanceQty=$balanceQty]  [rejectQty=$rejectQty]  [matchQty=$matchQty]  [amendQty=$amendQty]  [orderStatus=$orderStatus]  [actionType=$actionType]  [actionDesc=$actionDesc]  '
        '[salesCode=$salesCode]  [executor=$executor]  [executeDevice=$executeDevice]  [message=$message]';
  }

  factory OrderStatus.fromJson(Map<String, dynamic> parsedJson) {
    OrderStatus os = OrderStatus(
        parsedJson['orderDate'],
        parsedJson['requestTime'],
        parsedJson['sendTime'],
        parsedJson['openTime'],
        parsedJson['orderid'],
        parsedJson['sasOrderNumber'],
        parsedJson['idxOrderNumber'],
        parsedJson['brokercode'],
        parsedJson['accountcode'],
        parsedJson['bs'],
        parsedJson['boardCode'],
        parsedJson['stockCode'],
        Utils.safeInt(parsedJson['price']),
        Utils.safeInt(parsedJson['amendPrice']),
        Utils.safeInt(parsedJson['orderQty']),
        Utils.safeInt(parsedJson['balanceQty']),
        Utils.safeInt(parsedJson['rejectQty']),
        Utils.safeInt(parsedJson['matchQty']),
        Utils.safeInt(parsedJson['amendQty']),
        parsedJson['orderStatus'],
        Utils.safeInt(parsedJson['actionType']),
        parsedJson['actionDesc'],
        parsedJson['salesCode'],
        parsedJson['executor'],
        parsedJson['executeDevice'],
        parsedJson['message']);
    print(os.toString());
    return os;
  }
}

class OpenOrder {
  final int price;
  final int share;
  final int lot;

  OpenOrder(this.price, this.share, this.lot);

  factory OpenOrder.fromJson(Map<String, dynamic> parsedJson) {
    return OpenOrder(Utils.safeInt(parsedJson['price']),
        Utils.safeInt(parsedJson['share']), Utils.safeInt(parsedJson['lot']));
  }
}

class TradeStatusSummary {
  /*
  {
  "tradePrice": 635,
  "matchQty": 100000,
  "idxTradeId": "000000300068, 000000300064, 000000300067, 000000300065, 000000300059, 000000300061, 000000300060, 000000300058, 000000300063, 000000300066, 000000300062"
  }
  */

  final int tradePrice;
  final int matchQty;
  final String idxTradeNumber;

  TradeStatusSummary(this.tradePrice, this.matchQty, this.idxTradeNumber);

  factory TradeStatusSummary.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return TradeStatusSummary(
        Utils.safeInt(parsedJson['tradePrice']),
        Utils.safeInt(parsedJson['matchQty']),
        StringUtils.noNullString(parsedJson['idxTradeNumber']));
  }
}

class TradeStatus {
  final String parentOrderId;
  final String internalOrderId;
  final String idxOrderId;
  final String sasOrderId;
  final String idxTradeId;
  final String accountcode;
  final String bs;
  final String boardCode;
  final String stockCode;
  final int tradePrice;
  final int matchQty;

  TradeStatus(
      this.parentOrderId,
      this.internalOrderId,
      this.idxOrderId,
      this.sasOrderId,
      this.idxTradeId,
      this.accountcode,
      this.bs,
      this.boardCode,
      this.stockCode,
      this.tradePrice,
      this.matchQty);

  factory TradeStatus.fromJson(Map<String, dynamic> parsedJson) {
    return TradeStatus(
        parsedJson['parentOrderId'],
        parsedJson['internalOrderId'],
        parsedJson['idxOrderId'],
        parsedJson['sasOrderId'],
        parsedJson['idxTradeId'],
        parsedJson['accountcode'],
        parsedJson['bs'],
        parsedJson['boardCode'],
        parsedJson['stockCode'],
        Utils.safeInt(parsedJson['tradePrice']),
        Utils.safeInt(parsedJson['matchQty']));
  }
}

class AccountStockPosition {
  String accountcode;
  int totalCost;
  int totalMarket;
  int totalGL;
  double totalGLPct;
  double outstandingLimit;
  double rdnBalance;
  double tradingLimit;
  String message;
  double cashBalance;
  double availableCash;
  double creditLimit;

  AccountStockPosition(
      this.accountcode,
      this.totalCost,
      this.totalMarket,
      this.totalGL,
      this.totalGLPct,
      this.outstandingLimit,
      this.rdnBalance,
      this.tradingLimit,
      this.message,
      this.cashBalance,
      this.availableCash,
      this.creditLimit);

  bool ignoreThis() {
    return StringUtils.equalsIgnoreCase(message, 'ignore');
  }

  factory AccountStockPosition.fromJson(Map<String, dynamic> parsedJson) {
    return AccountStockPosition(
        parsedJson['accountcode'],
        Utils.safeInt(parsedJson['totalCost']),
        Utils.safeInt(parsedJson['totalMarket']),
        Utils.safeInt(parsedJson['totalGL']),
        Utils.safeDouble(parsedJson['totalGLPct']),
        Utils.safeDouble(parsedJson['outstandingLimit']),
        Utils.safeDouble(parsedJson['rdnBalance']),
        Utils.safeDouble(parsedJson['tradingLimit']),
        parsedJson['message'],
        Utils.safeDouble(parsedJson['cashBalance']),
        Utils.safeDouble(parsedJson['availableCash']),
        Utils.safeDouble(parsedJson['creditLimit']));
  }

  void copyValueFrom(AccountStockPosition newValue) {
    if (newValue != null) {
      this.accountcode = newValue.accountcode;
      this.totalCost = newValue.totalCost;
      this.totalMarket = newValue.totalMarket;
      this.totalGL = newValue.totalGL;
      this.totalGLPct = newValue.totalGLPct;
      this.outstandingLimit = newValue.outstandingLimit;
      this.rdnBalance = newValue.rdnBalance;
      this.tradingLimit = newValue.tradingLimit;
      this.message = newValue.message;
      this.cashBalance = newValue.cashBalance;
      this.availableCash = newValue.availableCash;
      this.creditLimit = newValue.creditLimit;
    } else {
      this.accountcode = '';
      this.totalCost = 0;
      this.totalMarket = 0;
      this.totalGL = 0;
      this.totalGLPct = 0.0;
      this.outstandingLimit = 0.0;
      this.rdnBalance = 0.0;
      this.tradingLimit = 0.0;
      this.message = '';
      this.cashBalance = 0.0;
      this.availableCash = 0.0;
      this.creditLimit = 0.0;
    }
  }
}

class OrderReply {
  String brokercode;
  String result; // ok bad
  String command; // new amend withdraw
  String accountcode;
  String orderid;
  String message;
  String orderdate;

  OrderReply(this.brokercode, this.result, this.command, this.accountcode,
      this.orderid, this.message, this.orderdate);

  factory OrderReply.fromJson(Map<String, dynamic> parsedJson) {
    return OrderReply(
        parsedJson['brokercode'],
        parsedJson['result'],
        parsedJson['command'],
        parsedJson['accountcode'],
        parsedJson['orderid'],
        parsedJson['message'],
        parsedJson['orderdate']);
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'OrderReply  [brokercode : $brokercode]  [result : $result]  [command : $command]  [accountcode : $accountcode]  [orderid : $orderid]  [message : $message]  [orderdate : $orderdate]';
  }
}

class LocalForeignData {
  int domesticBuy = 0;
  int domesticSell = 0;
  int foreignBuy = 0;
  int foreignSell = 0;
  int domescticNet = 0;
  int foreignNet = 0;
  double domesticTurnover = 0.0;
  double foreignTurnover = 0.0;

  String time = '';
  bool loaded = false;

  void copyValueFrom(LocalForeignData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.domesticBuy = newValue.domesticBuy;
      this.domesticSell = newValue.domesticSell;
      this.foreignBuy = newValue.foreignBuy;
      this.foreignSell = newValue.foreignSell;
      this.domescticNet = newValue.domescticNet;
      this.foreignNet = newValue.foreignNet;
      this.domesticTurnover = newValue.domesticTurnover;
      this.foreignTurnover = newValue.foreignTurnover;
      this.time = newValue.time;
    } else {
      this.domesticBuy = 0;
      this.domesticSell = 0;
      this.foreignBuy = 0;
      this.foreignSell = 0;
      this.domescticNet = 0;
      this.foreignNet = 0;
      this.domesticTurnover = 0.0;
      this.foreignTurnover = 0.0;
      this.time = '';
    }
  }
}

class PortfolioSummary {
  String dateStart = '';
  int totalAsset = 0;
  int portfolioValue = 0;
  int cash = 0;
  int capitalFund = 0; // modal setor
  int cashIn = 0;
  int cashOut = 0;
  int totalProfit = 0;
  double totalProfitPercentage = 0.0;
  int realizedProfit = 0;
  int unrealizedProfit = 0;
  int interestProfit = 0;

  PortfolioSummary(
      this.dateStart,
      this.totalAsset,
      this.portfolioValue,
      this.cash,
      this.capitalFund,
      this.cashIn,
      this.cashOut,
      this.totalProfit,
      this.totalProfitPercentage,
      this.realizedProfit,
      this.unrealizedProfit,
      this.interestProfit);
}

class RealizedStock {
  String accountcode = '';
  String stockCode = '';
  double gl = 0.0;
  int lot = 0;
  double avgBuy = 0.0;
  double avgSell = 0.0;
  double yield = 0.0;
  String date = '';
  int valueSell = 0;

  RealizedStock(this.accountcode, this.stockCode, this.gl, this.lot,
      this.avgBuy, this.avgSell, this.yield, this.date, this.valueSell);

  //RealizedStock(this.accountcode, this.stockCode, this.gl, this.date);

/*
   "accountcode": "P148",
    "stockCode": "CENT",
    "gl": 256937128.83,
    "lot": 100000,
    "avgBuy": 270.27,
    "avgSell": 295.96,
    "yield": 10,
    "date": "23-11-2021"
  */

  //Realized(this.code, this.date, this.value, this.yield);

  factory RealizedStock.fromJson(Map<String, dynamic> parsedJson) {
    return RealizedStock(
      StringUtils.noNullString(parsedJson['accountcode']),
      StringUtils.noNullString(parsedJson['stockCode']),
      Utils.safeDouble(parsedJson['gl']),
      Utils.safeInt(parsedJson['lot']),
      Utils.safeDouble(parsedJson['avgBuy']),
      Utils.safeDouble(parsedJson['avgSell']),
      Utils.safeDouble(parsedJson['yield']),
      StringUtils.noNullString(parsedJson['date']),
      Utils.safeInt(parsedJson['valueSell']),
    );
  }
}

class PortfolioSummaryData {
  /*
  {
  "accountcode": "C35",
  "totalasset": 1602642788.47,
  "portfoliovalue": 1574121500,
  "cashvalue": 28521288.47,
  "modalsetor": 3456325280.94,
  "cashin": 6182747916.92,
  "cashout": 2726422635.98,
  "totalprofit": 414576661.18,
  "realizedprofit": 482680153.18,
  "unrealizedprofit": -68103492,
  "topgain1stock": "BOLA",
  "topgain1value": 523400000,
  "topgain2stock": "FREN",
  "topgain2value": 273000000,
  "topgain3stock": "BINA",
  "topgain3value": 81937000,
  "toploss1stock": "BRMS",
  "toploss1value": -230000000,
  "toploss2stock": "ANTM",
  "toploss2value": -128000000,
  "toploss3stock": "BBYB",
  "toploss3value": -121500000
  }
  */

  bool loaded = false;
  String accountcode; //": "C35",
  double totalasset; //": 1602642788.47,
  double portfoliovalue; //": 1574121500,
  double cashvalue; //": 28521288.47,
  double modalsetor; //": 3456325280.94,
  double cashin; //": 6182747916.92,
  double cashout; //": 2726422635.98,
  double totalprofit; //": 414576661.18,
  double realizedprofit; //": 482680153.18,
  double unrealizedprofit; //": -68103492,
  String topgain1stock; //": "BOLA",
  double topgain1value; //": 523400000,
  String topgain2stock; //": "FREN",
  double topgain2value; //": 273000000,
  String topgain3stock; //": "BINA",
  double topgain3value; //": 81937000,
  String toploss1stock; //": "BRMS",
  double toploss1value; //": -230000000,
  String toploss2stock; //": "ANTM",
  double toploss2value; //": -128000000,
  String toploss3stock; //": "BBYB",
  double toploss3value;
  String begindate;

  PortfolioSummaryData(
      this.accountcode,
      this.totalasset,
      this.portfoliovalue,
      this.cashvalue,
      this.modalsetor,
      this.cashin,
      this.cashout,
      this.totalprofit,
      this.realizedprofit,
      this.unrealizedprofit,
      this.topgain1stock,
      this.topgain1value,
      this.topgain2stock,
      this.topgain2value,
      this.topgain3stock,
      this.topgain3value,
      this.toploss1stock,
      this.toploss1value,
      this.toploss2stock,
      this.toploss2value,
      this.toploss3stock,
      this.toploss3value,
      this.begindate);

  factory PortfolioSummaryData.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    print('PortfolioSummaryData.fromJson 0');
    String accountcode = StringUtils.noNullString(parsedJson['accountcode']);
    print('PortfolioSummaryData.fromJson 1');
    double totalasset = Utils.safeDouble(parsedJson['totalasset']);
    print('PortfolioSummaryData.fromJson 2');
    double portfoliovalue = Utils.safeDouble(parsedJson['portfoliovalue']);
    print('PortfolioSummaryData.fromJson 3');
    double cashvalue = Utils.safeDouble(parsedJson['cashvalue']);
    print('PortfolioSummaryData.fromJson 4');
    double modalsetor = Utils.safeDouble(parsedJson['modalsetor']);
    print('PortfolioSummaryData.fromJson 5');
    double cashin = Utils.safeDouble(parsedJson['cashin']);
    print('PortfolioSummaryData.fromJson 6');
    double cashout = Utils.safeDouble(parsedJson['cashout']);
    print('PortfolioSummaryData.fromJson 7');
    double totalprofit = Utils.safeDouble(parsedJson['totalprofit']);
    print('PortfolioSummaryData.fromJson 8');
    double realizedprofit = Utils.safeDouble(parsedJson['realizedprofit']);
    print('PortfolioSummaryData.fromJson 9');
    double unrealizedprofit = Utils.safeDouble(parsedJson['unrealizedprofit']);
    print('PortfolioSummaryData.fromJson 10');
    String topgain1stock =
        StringUtils.noNullString(parsedJson['topgain1stock']);
    print('PortfolioSummaryData.fromJson 11');
    double topgain1value = Utils.safeDouble(parsedJson['topgain1value']);
    print('PortfolioSummaryData.fromJson 12');
    String topgain2stock =
        StringUtils.noNullString(parsedJson['topgain2stock']);
    print('PortfolioSummaryData.fromJson 13');
    double topgain2value = Utils.safeDouble(parsedJson['topgain2value']);
    print('PortfolioSummaryData.fromJson 14');
    String topgain3stock =
        StringUtils.noNullString(parsedJson['topgain3stock']);
    print('PortfolioSummaryData.fromJson 15');
    double topgain3value = Utils.safeDouble(parsedJson['topgain3value']);
    print('PortfolioSummaryData.fromJson 16');
    String toploss1stock =
        StringUtils.noNullString(parsedJson['toploss1stock']);
    print('PortfolioSummaryData.fromJson 17');
    double toploss1value = Utils.safeDouble(parsedJson['toploss1value']);
    print('PortfolioSummaryData.fromJson 18');
    String toploss2stock =
        StringUtils.noNullString(parsedJson['toploss2stock']);
    print('PortfolioSummaryData.fromJson 19');
    double toploss2value = Utils.safeDouble(parsedJson['toploss2value']);
    print('PortfolioSummaryData.fromJson 20');
    String toploss3stock =
        StringUtils.noNullString(parsedJson['toploss3stock']);
    print('PortfolioSummaryData.fromJson 21');
    double toploss3value = Utils.safeDouble(parsedJson['toploss3value']);
    print('PortfolioSummaryData.fromJson 22');
    String begindate = StringUtils.noNullString(parsedJson['begindate']);
    print('PortfolioSummaryData.fromJson 23');

    return PortfolioSummaryData(
        accountcode,
        totalasset,
        portfoliovalue,
        cashvalue,
        modalsetor,
        cashin,
        cashout,
        totalprofit,
        realizedprofit,
        unrealizedprofit,
        topgain1stock,
        topgain1value,
        topgain2stock,
        topgain2value,
        topgain3stock,
        topgain3value,
        toploss1stock,
        toploss1value,
        toploss2stock,
        toploss2value,
        toploss3stock,
        toploss3value,
        begindate);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(this.accountcode);
  }

  void copyValueFrom(PortfolioSummaryData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.accountcode = newValue.accountcode;
      this.totalasset = newValue.totalasset;
      this.portfoliovalue = newValue.portfoliovalue;
      this.cashvalue = newValue.cashvalue;
      this.modalsetor = newValue.modalsetor;
      this.cashin = newValue.cashin;
      this.cashout = newValue.cashout;
      this.totalprofit = newValue.totalprofit;
      this.realizedprofit = newValue.realizedprofit;
      this.unrealizedprofit = newValue.unrealizedprofit;
      this.topgain1stock = newValue.topgain1stock;
      this.topgain1value = newValue.topgain1value;
      this.topgain2stock = newValue.topgain2stock;
      this.topgain2value = newValue.topgain2value;
      this.topgain3stock = newValue.topgain3stock;
      this.topgain3value = newValue.topgain3value;
      this.toploss1stock = newValue.toploss1stock;
      this.toploss1value = newValue.toploss1value;
      this.toploss2stock = newValue.toploss2stock;
      this.toploss2value = newValue.toploss2value;
      this.toploss3stock = newValue.toploss3stock;
      this.toploss3value = newValue.toploss3value;
      this.begindate = newValue.begindate;
    } else {
      this.accountcode = '';
      this.totalasset = 0;
      this.portfoliovalue = 0;
      this.cashvalue = 0;
      this.modalsetor = 0;
      this.cashin = 0;
      this.cashout = 0;
      this.totalprofit = 0;
      this.realizedprofit = 0;
      this.unrealizedprofit = 0;
      this.topgain1stock = '';
      this.topgain1value = 0;
      this.topgain2stock = '';
      this.topgain2value = 0;
      this.topgain3stock = '';
      this.topgain3value = 0;
      this.toploss1stock = '';
      this.toploss1value = 0;
      this.toploss2stock = '';
      this.toploss2value = 0;
      this.toploss3stock = '';
      this.toploss3value = 0;
      this.begindate = '';
    }
  }

  static PortfolioSummaryData createBasic() {
    return new PortfolioSummaryData('', 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, '', 0,
        '', 0, '', 0, '', 0, '', 0, '');
  }
}

class RealizedStockData {
  bool loaded = false;
  double totalGL = 0.0;
  List<RealizedStock> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return count() == 0;
  }

  void copyValueFrom(RealizedStockData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.totalGL = newValue.totalGL;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.totalGL = 0.0;
      this.datas.clear();
    }
  }
}

class Return {
  String date = '';
  int value = 0;
  double yield = 0.0;

  Return(this.date, this.value, this.yield);
}

class ReturnData {
  bool loaded = false;
  List<Return> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  void copyValueFrom(ReturnData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class Briefing {
  /*
  <a start="1" end="1"
  id="2"
  type="MORNING"
  display_title_id="Morning Brief ️ ☕ "
  display_title_en="Morning Brief ️ ☕ "
  display_greet_id="Selamat Pagi,"
  display_greet_en="Good Morning,"
  display_body_id="Pada perdagangan kemarin indeks di bursa Wall Street kompak ditutup melemah seiring naiknya yield obligasi yang memicu aksi jual investor pada aset beresiko khususnya saham sektor teknologi mengingat sektor ini paling terdampak dengan adanya kenaikan yield tersebut. IHSG diprediksi akan bergerak bervariasi cenderung melemah dengan support di level 6,250 dan resistance di level 6,330. Seperti pa..."
  display_body_en="JAKARTA (TheInsiderStories) – Good Morning! United States (US) stock markets were muted ahead of the by the Federal Reserves decision today, even most of them believed no changes on the monetary policies. At the same time, President Joe Biden takes the road to sell his US$1.9 trillion stimulus to American and vaccines continue to roll out. While, the country’ retail sales fell 3 percent in the latest reading. And a third wave of COVID-19 infections is building in Europe, with Germany, France, Italy and the Benelux countries reporting rising infections. Then, a German decision to stop distributing the AstraZeneca-Oxford University vaccine on"
  valid_from="2021-08-07 10:52:20"
  valid_to="2022-08-07 10:52:20"
  action=""/>
 */
  int id = 0;
  String type = '';
  String display_title_id = '';
  String display_title_en = '';
  String display_greet_id = '';
  String display_greet_en = '';
  String display_body_id = '';
  String display_body_en = '';
  String valid_from = '';
  String valid_to = '';
  String action = '';

  bool loaded = false;

  bool isEmpty() {
    return StringUtils.isEmtpy(display_body_id) &&
        StringUtils.isEmtpy(display_body_en);
  }

  String getTitle({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return display_title_id;
    } else {
      return display_title_en;
    }
  }

  String getGreeting({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return display_greet_id;
    } else {
      return display_greet_en;
    }
  }

  String getDescription({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return display_body_id;
    } else {
      return display_body_en;
    }
  }

  static Briefing createBasic() {
    return Briefing(0, '', '', '', '', '', '', '', '', '', '');
  }

  Briefing(
      this.id,
      this.type,
      this.display_title_id,
      this.display_title_en,
      this.display_greet_id,
      this.display_greet_en,
      this.display_body_id,
      this.display_body_en,
      this.valid_from,
      this.valid_to,
      this.action);

  factory Briefing.fromJson(Map<String, dynamic> parsedJson) {
    int id = Utils.safeInt(parsedJson['id']);
    String type = StringUtils.noNullString(parsedJson['type']);
    String displayTitleId =
        StringUtils.noNullString(parsedJson['display_title_id']);
    String displayTitleEn =
        StringUtils.noNullString(parsedJson['display_title_en']);
    String displayGreetId =
        StringUtils.noNullString(parsedJson['display_greet_id']);
    String displayGreetEn =
        StringUtils.noNullString(parsedJson['display_greet_en']);
    String displayBodyId =
        StringUtils.noNullString(parsedJson['display_body_id']);
    String displayBodyEn =
        StringUtils.noNullString(parsedJson['display_body_en']);
    String validFrom = StringUtils.noNullString(parsedJson['valid_from']);
    String validTo = StringUtils.noNullString(parsedJson['valid_to']);
    String action = StringUtils.noNullString(parsedJson['action']);

    return Briefing(
        id,
        type,
        displayTitleId,
        displayTitleEn,
        displayGreetId,
        displayGreetEn,
        displayBodyId,
        displayBodyEn,
        validFrom,
        validTo,
        action);
  }

  factory Briefing.fromXml(XmlElement element) {
    int id = Utils.safeInt(element.getAttribute('id'));
    String type = StringUtils.noNullString(element.getAttribute('type'));
    String displayTitleId =
        StringUtils.noNullString(element.getAttribute('display_title_id'));
    String displayTitleEn =
        StringUtils.noNullString(element.getAttribute('display_title_en'));
    String displayGreetId =
        StringUtils.noNullString(element.getAttribute('display_greet_id'));
    String displayGreetEn =
        StringUtils.noNullString(element.getAttribute('display_greet_en'));
    String displayBodyId =
        StringUtils.noNullString(element.getAttribute('display_body_id'));
    String displayBodyEn =
        StringUtils.noNullString(element.getAttribute('display_body_en'));
    String validFrom =
        StringUtils.noNullString(element.getAttribute('valid_from'));
    String validTo = StringUtils.noNullString(element.getAttribute('valid_to'));
    String action = StringUtils.noNullString(element.getAttribute('action'));

    return Briefing(
        id,
        type,
        displayTitleId,
        displayTitleEn,
        displayGreetId,
        displayGreetEn,
        displayBodyId,
        displayBodyEn,
        validFrom,
        validTo,
        action);
  }

  void copyValueFrom(Briefing newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.id = newValue.id;
      this.type = newValue.type;
      this.display_title_id = newValue.display_title_id;
      this.display_title_en = newValue.display_title_en;
      this.display_greet_id = newValue.display_greet_id;
      this.display_greet_en = newValue.display_greet_en;
      this.display_body_id = newValue.display_body_id;
      this.display_body_en = newValue.display_body_en;
      this.valid_from = newValue.valid_from;
      this.valid_to = newValue.valid_to;
      this.action = newValue.action;
    } else {
      this.id = 0;
      this.type = '';
      this.display_title_id = '';
      this.display_title_en = '';
      this.display_greet_id = '';
      this.display_greet_en = '';
      this.display_body_id = '';
      this.display_body_en = '';
      this.valid_from = '';
      this.valid_to = '';
      this.action = '';
    }
  }
}

class ResultTopStock {
  String type = '';
  String range = '';
  List<TopStock> datas = List.empty(growable: true);

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }
}

class OrderQueueData {
  String message = '';

  // parameters
  String code = '';
  String board = '';
  int price = 0;
  String type = '';
  int datas_count = 0;

  /*
  "parameters": {
    "code": "BUMI",
    "board": "RG",
    "price": "66",
    "type": "BID"
  },
  */
  String translateType() {
    return StringUtils.equalsIgnoreCase(type, 'Offer') ? 'ASK' : type;
  }

  //additional_data
  int total_volume = 0;
  int total_remaining_volume = 0;

  /*
  "additional_data": {
    "total_volume": 139952700,
    "total_remaining_volume": 138054400
  },
  */
  bool loaded = false;
  List<OrderQueue> datas = List.empty(growable: true);

  int total_lot() {
    if (total_volume > 0) {
      return total_volume ~/ 100;
    } else {
      return 0;
    }
  }

  int total_remaining_lot() {
    if (total_remaining_volume > 0) {
      return total_remaining_volume ~/ 100;
    } else {
      return 0;
    }
  }

  void copyValueFrom(OrderQueueData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
      this.message = newValue.message;
      this.code = newValue.code;
      this.board = newValue.board;
      this.price = newValue.price;
      this.type = newValue.type;
      this.total_volume = newValue.total_volume;
      this.total_remaining_volume = newValue.total_remaining_volume;
      this.datas_count = newValue.datas_count;
    } else {
      this.datas.clear();
      this.message = '';
      this.code = '';
      this.board = '';
      this.price = 0;
      this.type = '';
      this.total_volume = 0;
      this.total_remaining_volume = 0;
      this.datas_count = 0;
    }
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  int count() {
    return isEmpty() ? 0 : datas.length;
  }

  bool hasMessage() {
    return !StringUtils.isEmtpy(message);
  }
}

class ResultInbox {
  String username = '';
  bool more_data = false;
  String date_next = '';
  String date_start = '';
  String message = '';

  /*
  "tag": "INBOX",
  "username": "richy",
  "date_start": "2021-11-02 22:12:43",
  "date_next": "",
  "more_data": "false",
  "date": "2021-11-04",
  "time": "15:50:14",
  "datas_count": 1,
  */

  List<InboxMessage> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }
}

class ResultKeyStatistic {
  String code = '';
  bool show_earningPerShare = false;
  bool show_dataPerformanceYTD = false;
  bool show_dataBalanceSheet = false;
  bool show_dataValuation = false;
  bool show_dataPerShare = false;
  bool show_dataProfitability = false;
  bool show_dataLiquidity = false;

  bool isEmpty() {
    return code == null || code.length <= 0;
  }

  EarningPerShareData earningPerShare = EarningPerShareData.createBasic();

  //"dataPerformanceYTD": {
  int sales = 0;
  int operating_profit = 0;
  int net_profit = 0;
  int cash_flow = 0;

  //"dataBalanceSheet": {
  int assets = 0;
  int cash_and_equiv = 0;
  int liability = 0;
  int debt = 0;
  int equity = 0;

  //"dataValuation": {
  double price_earning_ratio = 0.0;
  double price_sales_ratio = 0.0;
  double price_book_value_ratio = 0.0;
  double price_cash_flow_ratio = 0.0;
  double dividend_yield = 0.0;

  //"dataPerShare": {
  int earning_per_share = 0;
  int dividend_per_share = 0;
  int revenue_per_share = 0;
  int book_value_per_share = 0;
  int cash_equiv_per_share = 0;
  int cash_flow_per_share = 0;
  int net_assets_per_share = 0;

  //"dataProfitability": {
  double operating_profit_margin = 0;
  double net_profit_margin = 0;
  double return_on_equity = 0;
  double return_on_assets = 0;

  //"dataLiquidity": {
  double debt_equity_ratio = 0;
  double current_ratio = 0;
  double cash_ratio = 0;
}

class Dividend extends CorporateAction {
  // String code = '';
  // String year = '';
  String totalValue = '';
  String price = '';
  String cumDate = '';
  String exDate = '';
  String recordingDate = '';
  String paymentDate = '';

  @override
  String caType() {
    return 'DIVIDEND';
  }

  @override
  String toString() {
    return '[Dividend  code : $code  year : $year  totalValue : $totalValue  price : $price  cumDate : $cumDate  exDate : $exDate  recordingDate : $recordingDate  paymentDate : $paymentDate]';
  }

  Dividend(String code, String year, this.totalValue, this.price, this.cumDate,
      this.exDate, this.recordingDate, this.paymentDate)
      : super(code, year);

  factory Dividend.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String year = StringUtils.noNullString(parsedJson['year']);
    String totalValue = StringUtils.noNullString(parsedJson['totalValue']);
    String price = StringUtils.noNullString(parsedJson['price']);
    String cumDate = StringUtils.noNullString(parsedJson['cumDate']);
    String exDate = StringUtils.noNullString(parsedJson['exDate']);
    String recordingDate =
        StringUtils.noNullString(parsedJson['recordingDate']);
    String paymentDate = StringUtils.noNullString(parsedJson['paymentDate']);

    return Dividend(code, year, totalValue, price, cumDate, exDate,
        recordingDate, paymentDate);
  }
}

class RUPS extends CorporateAction {
  // String code = '';
  // String year = '';
  String type = '';
  String dateTime = '';
  String address = '';
  String city = '';

  @override
  String caType() {
    return 'RUPS';
  }

  @override
  String toString() {
    return '[RUPS  code : $code  year : $year  type : $type  dateTime : $dateTime  address : $address  city : $city]';
  }

  RUPS(String code, String year, this.type, this.dateTime, this.address,
      this.city)
      : super(code, year);

  /*
  year": "2021",
  "type": "RUPST",
  "dateTime": "data_dateTime",
  "address": "data_address",
  "city": "data_city"
  */

  factory RUPS.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String year = StringUtils.noNullString(parsedJson['year']);
    String type = StringUtils.noNullString(parsedJson['type']);
    String dateTime = StringUtils.noNullString(parsedJson['dateTime']);
    String address = StringUtils.noNullString(parsedJson['address']);
    String city = StringUtils.noNullString(parsedJson['city']);
    return RUPS(code, year, type, dateTime, address, city);
  }
}

class RightIssue extends CorporateAction {
  // String code = '';
  // String year = '';
  String ratio1 = '';
  String ratio2 = '';
  String ratioPercentage = '';
  String price = '';
  String cumDate = '';
  String exDate = '';
  String recordingDate = '';
  String tradingStart = '';
  String tradingEnd = '';
  String subscriptionDate = '';

  @override
  String toString() {
    return '[RightIssue  code : $code  year : $year  ratio1 : $ratio1  ratio2 : $ratio2  ratioPercentage : $ratioPercentage  price : $price'
        '  cumDate : $cumDate  exDate : $exDate  recordingDate : $recordingDate  tradingStart : $tradingStart  tradingEnd : $tradingEnd  subscriptionDate : $subscriptionDate]';
  }

  @override
  String caType() {
    return 'RIGHT_ISSUE';
  }

  RightIssue(
      String code,
      String year,
      this.ratio1,
      this.ratio2,
      this.ratioPercentage,
      this.price,
      this.cumDate,
      this.exDate,
      this.recordingDate,
      this.tradingStart,
      this.tradingEnd,
      this.subscriptionDate)
      : super(code, year);

  /*
  {
      "year": "2021",
      "ratio1": "1",
      "ratio2": "5",
      "ratioPercentage": "20.0%",
      "price": "300",
      "cumDate": "data_cumDate",
      "exDate": "data_exDate",
      "recordingDate": "data_recordingDate",
      "tradingStart": "data_tradingStart",
      "tradingEnd": "data_tradingEnd",
      "subscriptionDate": "data_subscriptionDate"
    }
  */

  factory RightIssue.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String year = StringUtils.noNullString(parsedJson['year']);
    String ratio1 = StringUtils.noNullString(parsedJson['ratio1']);
    String ratio2 = StringUtils.noNullString(parsedJson['ratio2']);
    String ratioPercentage =
        StringUtils.noNullString(parsedJson['ratioPercentage']);
    String price = StringUtils.noNullString(parsedJson['price']);
    String cumDate = StringUtils.noNullString(parsedJson['cumDate']);
    String exDate = StringUtils.noNullString(parsedJson['exDate']);
    String recordingDate =
        StringUtils.noNullString(parsedJson['recordingDate']);
    String tradingStart = StringUtils.noNullString(parsedJson['tradingStart']);
    String tradingEnd = StringUtils.noNullString(parsedJson['tradingEnd']);
    String subscriptionDate =
        StringUtils.noNullString(parsedJson['subscriptionDate']);
    return RightIssue(
        code,
        year,
        ratio1,
        ratio2,
        ratioPercentage,
        price,
        cumDate,
        exDate,
        recordingDate,
        tradingStart,
        tradingEnd,
        subscriptionDate);
  }
}

class StockSplit extends CorporateAction {
  // String code = '';
  // String year = '';
  String ratio1 = '';
  String ratio2 = '';
  String ratioPercentage = '';
  String cumDate = '';
  String exDate = '';
  String recordingDate = '';
  String tradingDate = '';

  @override
  String caType() {
    return 'RIGHT_ISSUE';
  }

  @override
  String toString() {
    return '[StockSplit  code : $code  year : $year  ratio1 : $ratio1  ratio2 : $ratio2  ratioPercentage : $ratioPercentage  cumDate : $cumDate'
        '  exDate : $exDate  recordingDate : $recordingDate  tradingDate : $tradingDate]';
  }

  StockSplit(
      String code,
      String year,
      this.ratio1,
      this.ratio2,
      this.ratioPercentage,
      this.cumDate,
      this.exDate,
      this.recordingDate,
      this.tradingDate)
      : super(code, year);

  /*
  {
      "year": "2021",
      "ratio1": "1",
      "ratio2": "5",
      "ratioPercentage": "20.0%",
      "cumDate": "data_cumDate",
      "exDate": "data_exDate",
      "recordingDate": "data_recordingDate",
      "tradingDate": "data_tradingDate"
    },
  */

  factory StockSplit.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String year = StringUtils.noNullString(parsedJson['year']);
    String ratio1 = StringUtils.noNullString(parsedJson['ratio1']);
    String ratio2 = StringUtils.noNullString(parsedJson['ratio2']);
    String ratioPercentage =
        StringUtils.noNullString(parsedJson['ratioPercentage']);
    String cumDate = StringUtils.noNullString(parsedJson['cumDate']);
    String exDate = StringUtils.noNullString(parsedJson['exDate']);
    String recordingDate =
        StringUtils.noNullString(parsedJson['recordingDate']);
    String tradingDate = StringUtils.noNullString(parsedJson['tradingDate']);

    return StockSplit(code, year, ratio1, ratio2, ratioPercentage, cumDate,
        exDate, recordingDate, tradingDate);
  }
}

class Warrant extends CorporateAction {
  String ratio1 = '';
  String ratio2 = '';
  String price = '';
  String tradingStart = '';
  String tradingEnd = '';
  String maturityDate = '';
  String exDate = '';
  String cumDate = '';
  String recordingDate = '';
  String subscriptionDate = '';
  String description = '';

  bool isEmptyOrMinus(String text) {
    return StringUtils.isEmtpy(text) ||
        StringUtils.equalsIgnoreCase(text.trim(), '-');
  }

  bool isValidData(String text) {
    return !isEmptyOrMinus(text);
  }

  @override
  String caType() {
    return 'WARRANT';
  }

  Warrant(
      String code,
      String year,
      this.ratio1,
      this.ratio2,
      this.price,
      this.tradingStart,
      this.tradingEnd,
      this.maturityDate,
      this.exDate,
      this.cumDate,
      this.recordingDate,
      this.subscriptionDate,
      this.description)
      : super(code, year);

  /*
   {
      "ratio1": "3",
      "ratio2": "2",
      "price": "50",
      "tradingStart": "05 Dec 2019",
      "tradingEnd": "29 Nov 2022",
      "maturityDate": "02 Dec 2022",
      "exDate": "02 Dec 2022",
      "cumDate": "-",
      "recordingDate": "-",
      "subscriptionDate": "-",
      "description": "Info: Setiap 2 saham hasil pelaksanaan HMETD melekat 3 Waran seri V"
    },
  */

  factory Warrant.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String year = StringUtils.noNullString(parsedJson['year']);
    String ratio1 = StringUtils.noNullString(parsedJson['ratio1']);
    String ratio2 = StringUtils.noNullString(parsedJson['ratio2']);
    String price = StringUtils.noNullString(parsedJson['price']);

    String tradingStart = StringUtils.noNullString(parsedJson['tradingStart']);
    String tradingEnd = StringUtils.noNullString(parsedJson['tradingEnd']);

    String maturityDate = StringUtils.noNullString(parsedJson['maturityDate']);

    String exDate = StringUtils.noNullString(parsedJson['exDate']);
    String cumDate = StringUtils.noNullString(parsedJson['cumDate']);
    String recordingDate =
        StringUtils.noNullString(parsedJson['recordingDate']);
    String subscriptionDate =
        StringUtils.noNullString(parsedJson['recordingDate']);
    String description = StringUtils.noNullString(parsedJson['recordingDate']);

    return Warrant(
        code,
        year,
        ratio1,
        ratio2,
        price,
        tradingStart,
        tradingEnd,
        maturityDate,
        exDate,
        cumDate,
        recordingDate,
        subscriptionDate,
        description);
    //return StockSplit(code, year, ratio1, ratio2, ratioPercentage, cumDate, exDate, recordingDate, tradingDate);
  }

  @override
  String toString() {
    return 'Warrant {ratio1: $ratio1, ratio2: $ratio2, price: $price, tradingStart: $tradingStart, tradingEnd: $tradingEnd, maturityDate: $maturityDate, exDate: $exDate, cumDate: $cumDate, recordingDate: $recordingDate, subscriptionDate: $subscriptionDate, description: $description}';
  }
}

class ResearchRank {
  /*
  <a start="1" end="1"
  code="ASII" value="1.3" subtitle_id="Peringkat Konsensus" subtitle_en="Consensus Rank"
  description_id="Rekomendasi analis bursa saham" description_en="Stock market analyst recommendations"
  valid_from="2021-08-17 22:03:40" valid_to="2021-09-17 22:03:40"/>
 */

  String code = '';
  double value = 0.0;
  String subtitle_id = '';
  String subtitle_en = '';
  String description_id = '';
  String description_en = '';
  String valid_from = '';
  String valid_to = '';

  bool loaded = false;

  bool isEmpty() {
    return StringUtils.isEmtpy(code) || value < 1.0;
  }

  String getSubtitle({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return subtitle_id;
    } else {
      return subtitle_en;
    }
  }

  String getDescription({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return description_id;
    } else {
      return description_en;
    }
  }

  ResearchRank(this.code, this.value, this.subtitle_id, this.subtitle_en,
      this.description_id, this.description_en, this.valid_from, this.valid_to);

  static ResearchRank createBasic() {
    return ResearchRank('', 0.0, '', '', '', '', '', '');
  }

  factory ResearchRank.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    double value = Utils.safeDouble(parsedJson['value']);
    String subtitleId = StringUtils.noNullString(parsedJson['subtitle_id']);
    String subtitleEn = StringUtils.noNullString(parsedJson['subtitle_en']);
    String descriptionId =
        StringUtils.noNullString(parsedJson['description_id']);
    String descriptionEn =
        StringUtils.noNullString(parsedJson['description_en']);
    String validFrom = StringUtils.noNullString(parsedJson['valid_from']);
    String validTo = StringUtils.noNullString(parsedJson['valid_to']);

    return ResearchRank(code, value, subtitleId, subtitleEn, descriptionId,
        descriptionEn, validFrom, validTo);
  }

  factory ResearchRank.fromXml(XmlElement element) {
    String code = StringUtils.noNullString(element.getAttribute('code'));
    double value = Utils.safeDouble(element.getAttribute('value'));
    String subtitleId =
        StringUtils.noNullString(element.getAttribute('subtitle_id'));
    String subtitleEn =
        StringUtils.noNullString(element.getAttribute('subtitle_en'));
    String descriptionId =
        StringUtils.noNullString(element.getAttribute('description_id'));
    String descriptionEn =
        StringUtils.noNullString(element.getAttribute('description_en'));
    String validFrom =
        StringUtils.noNullString(element.getAttribute('valid_from'));
    String validTo = StringUtils.noNullString(element.getAttribute('valid_to'));

    return ResearchRank(code, value, subtitleId, subtitleEn, descriptionId,
        descriptionEn, validFrom, validTo);
  }

  void copyValueFrom(ResearchRank newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.value = newValue.value;
      this.subtitle_id = newValue.subtitle_id;
      this.subtitle_en = newValue.subtitle_en;
      this.description_id = newValue.description_id;
      this.description_en = newValue.description_en;
      this.valid_from = newValue.valid_from;
      this.valid_to = newValue.valid_to;
    } else {
      this.code = '';
      this.value = 0.0;
      this.subtitle_id = '';
      this.subtitle_en = '';
      this.description_id = '';
      this.description_en = '';
      this.valid_from = '';
      this.valid_to = '';
    }
  }

  @override
  String toString() {
    return '[ResearchRank  code : $code  value : $value  subtitle_id : $subtitle_id  subtitle_en : $subtitle_en'
        '  description_id : $description_id  description_en : $description_en  valid_from : $valid_from  valid_to : $valid_to ]';
  }
}

class Range {
  int index = 0;
  String from = 'from_label'.tr();
  String to = 'to_label'.tr();

  Range(this.index, this.from, this.to);

  static Range createBasic() {
    return Range(0, 'from_label'.tr(), 'to_label'.tr());
  }

  @override
  String toString() {
    return 'Range {index: $index, from: $from, to: $to}';
  }
}

class ForeignDomestic {
  String code = '';
  String board = '';
  String date = '';
  String time = '';
  int domesticBuyerValue = 0;
  int domesticSellerValue = 0;
  int domesticNetValue = 0;
  double domesticTotalValueRatio = 0.0;
  int foreignBuyerValue = 0;
  int foreignSellerValue = 0;
  int foreignNetValue = 0;
  double foreignTotalValueRatio = 0.0;
  bool loaded = false;

  ForeignDomestic(
      this.code,
      this.board,
      this.date,
      this.time,
      this.domesticBuyerValue,
      this.domesticSellerValue,
      this.domesticNetValue,
      this.domesticTotalValueRatio,
      this.foreignBuyerValue,
      this.foreignSellerValue,
      this.foreignNetValue,
      this.foreignTotalValueRatio);

  factory ForeignDomestic.fromJson(
      Map<String, dynamic> parsedJson, String code, String board) {
    if (parsedJson == null) {
      return null;
    }
    String date = StringUtils.noNullString(parsedJson['date']);
    String time = StringUtils.noNullString(parsedJson['time']);
    int domesticBuyerValue = Utils.safeInt(parsedJson['domesticBuyerValue']);
    int domesticSellerValue = Utils.safeInt(parsedJson['domesticSellerValue']);
    int domesticNetValue = Utils.safeInt(parsedJson['domesticNetValue']);
    double domesticTotalValueRatio =
        Utils.safeDouble(parsedJson['domesticTotalValueRatio']);
    int foreignBuyerValue = Utils.safeInt(parsedJson['foreignBuyerValue']);
    int foreignSellerValue = Utils.safeInt(parsedJson['foreignSellerValue']);
    int foreignNetValue = Utils.safeInt(parsedJson['foreignNetValue']);
    double foreignTotalValueRatio =
        Utils.safeDouble(parsedJson['foreignTotalValueRatio']);
    return ForeignDomestic(
        code,
        board,
        date,
        time,
        domesticBuyerValue,
        domesticSellerValue,
        domesticNetValue,
        domesticTotalValueRatio,
        foreignBuyerValue,
        foreignSellerValue,
        foreignNetValue,
        foreignTotalValueRatio);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(board) || StringUtils.isEmtpy(date);
  }

  void copyValueFrom(ForeignDomestic newValue) {
    if (newValue != null) {
      this.code = newValue.code;
      this.board = newValue.board;
      this.date = newValue.date;
      this.time = newValue.time;
      this.domesticBuyerValue = newValue.domesticBuyerValue;
      this.domesticSellerValue = newValue.domesticSellerValue;
      this.domesticNetValue = newValue.domesticNetValue;
      this.domesticTotalValueRatio = newValue.domesticTotalValueRatio;
      this.foreignBuyerValue = newValue.foreignBuyerValue;
      this.foreignSellerValue = newValue.foreignSellerValue;
      this.foreignNetValue = newValue.foreignNetValue;
      this.foreignTotalValueRatio = newValue.foreignTotalValueRatio;
    } else {
      this.code = '';
      this.board = '';
      this.date = '';
      this.time = '';
      this.domesticBuyerValue = 0;
      this.domesticSellerValue = 0;
      this.domesticNetValue = 0;
      this.domesticTotalValueRatio = 0.0;
      this.foreignBuyerValue = 0;
      this.foreignSellerValue = 0;
      this.foreignNetValue = 0;
      this.foreignTotalValueRatio = 0.0;
    }
  }
}

class SuspendedStockData {
  bool loaded = false;
  String date = "";
  String time = "";
  Map<String, SuspendStock> affected = Map<String, SuspendStock>();
  void putStockAffected(SuspendStock suspendStock) {
    if (suspendStock != null) {
      affected.update(
        suspendStock.code + '_' + suspendStock.board,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
        (existingValue) => suspendStock,
        ifAbsent: () => suspendStock,
      );

      //rows.put(code,s);
      print("putStockAffected added : " + suspendStock.toString());
    }
  }

  bool isEmpty() {
    if (affected == null || affected.isEmpty) {
      return true;
    }
    return false;
  }

  void copyValueFrom(SuspendedStockData newValue,
      {bool dontClearExistingIfNull = false}) {
    if (newValue != null) {
      this.loaded = true;
      this.date = newValue.date;
      this.time = newValue.time;

      this.affected.clear();
      if (newValue.affected != null) {
        this.affected.addAll(newValue.affected);
      }
    } else {
      if (!dontClearExistingIfNull) {
        this.date = "";
        this.time = "";
        this.affected.clear();
      }
    }
  }
}

class Remark2Data {
  bool loaded = false;

  String date = "";
  String time = "";
  Map<String, Remark2Mapping> mapping = Map<String, Remark2Mapping>();
  Map<String, Remark2Stock> affected = Map<String, Remark2Stock>();

  int countAffected() {
    return affected != null ? affected.length : 0;
  }

  int countMapping() {
    return mapping != null ? mapping.length : 0;
  }

  void putMapping(Remark2Mapping remark2mapping) {
    if (remark2mapping != null) {
      mapping.update(
        remark2mapping.key,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
        (existingValue) => remark2mapping,
        ifAbsent: () => remark2mapping,
      );
      //maps.put(key, map);
      DebugWriter.info("putMapping added : " + remark2mapping.toString());
    }
  }

  String toString() {
    return "Remark2Data  $date $time   mapping.size : " +
        countMapping().toString() +
        "  affected.size : " +
        countAffected().toString();
  }

  void putStockAffected(Remark2Stock remark2stock) {
    if (remark2stock != null) {
      affected.update(
        remark2stock.code,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
        (existingValue) => remark2stock,
        ifAbsent: () => remark2stock,
      );

      //rows.put(code,s);
      DebugWriter.info("putStockAffected added : " + remark2stock.toString());
    }
  }

  bool isEmpty() {
    if (mapping == null || mapping.isEmpty) {
      return true;
    }
    if (affected == null || affected.isEmpty) {
      return true;
    }
    return false;
  }

  void copyValueFrom(Remark2Data newValue,
      {bool dontClearExistingIfNull = false}) {
    if (newValue != null) {
      this.loaded = true;
      this.date = newValue.date;
      this.time = newValue.time;
      this.mapping.clear();
      this.affected.clear();
      if (newValue.mapping != null) {
        this.mapping.addAll(newValue.mapping);
      }
      if (newValue.affected != null) {
        this.affected.addAll(newValue.affected);
      }
    } else {
      if (!dontClearExistingIfNull) {
        this.date = "";
        this.time = "";
        this.mapping.clear();
        this.affected.clear();
      }
    }
  }
}

class SuspendStock {
  String code = '';
  String board = '';
  String status = '';
  String info = '';
  String date = '';
  String time = '';

  SuspendStock(
      this.code, this.board, this.status, this.info, this.date, this.time);

  factory SuspendStock.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    ///int id = Utils.safeInt(parsedJson['id']);
    String code = StringUtils.noNullString(parsedJson['code']);
    String board = StringUtils.noNullString(parsedJson['board']);
    String status = StringUtils.noNullString(parsedJson['status']);
    String info = StringUtils.noNullString(parsedJson['info']);
    String date = StringUtils.noNullString(parsedJson['date']);
    String time = StringUtils.noNullString(parsedJson['time']);

    return SuspendStock(code, board, status, info, date, time);
  }
}

class CorporateActionEvent {
  /*
  {
  "#": 1,
  "code": "SIDO",
  "name": null,
  "type": "STOCK DIVIDEND",
  "today_date": "2021-12-22",
  "cum_date": "2021-09-27",
  "distribution_date": "2021-10-05",
  "proceed_ratio": "1",
  "exercise_ratio": "131",
  "recording_date": "2021-09-29",
  "amount": "0",
  "description": "Rasio Saham Bonus adalah setiap 131 (seratus tiga puluh satu) saham lama akan mendapatkan 1 (satu) saham bonus. Saham Bonus yang dibagikan akan dilakukan pembulatan ke bawah.",
  "hmetd_trx_date1": null,
  "hmetd_trx_date2": null,
  "exercise_instrument": "SIDO"
  }
  */
  String code = '';
  String name = '';
  String type = '';
  String today_date = '';
  String cum_date = '';
  String distribution_date = '';
  double proceed_ratio = 0;
  double exercise_ratio = 0;
  String recording_date = '';
  double amount = 0;
  String description = '';
  String hmetd_trx_date1 = '';
  String hmetd_trx_date2 = '';
  String exercise_instrument = '';

  String pay_date = '';
  String split_date = '';
  String ex_date = '';
  String maturity_date = '';

  Color background_color;
  int priority_color;
  bool loaded = false;

  Widget _labelValue(BuildContext context, String label, String value) {
    String text = label;
    if (!StringUtils.isEmtpy(text)) {
      text = text + " = ";
    }
    return Text.rich(
      TextSpan(
        text: text,
        style: InvestrendTheme.of(context).small_w600,
        children: [
          TextSpan(
              text: value,
              style: InvestrendTheme.of(context).small_w400_greyDarker),
        ],
      ),
    );
  }

  Widget getInformationWidget(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    list.add(Text(type, style: InvestrendTheme.of(context).small_w600_compact));
    if (amount != 0.0) {
      list.add(_labelValue(
          context, 'Amount', InvestrendTheme.formatNewComma(amount)));
    }
    if (exercise_ratio != 0.0 || proceed_ratio != 0.0) {
      String ratioText = InvestrendTheme.formatNewComma(exercise_ratio) +
          ' : ' +
          InvestrendTheme.formatNewComma(proceed_ratio);
      list.add(_labelValue(context, 'Ratio ', ratioText));
    }

    if (!StringUtils.isEmtpy(cum_date) &&
        !StringUtils.equalsIgnoreCase(cum_date, 'null')) {
      list.add(_labelValue(context, 'Cum Date', cum_date));
    }

    if (!StringUtils.isEmtpy(hmetd_trx_date1) &&
        !StringUtils.equalsIgnoreCase(hmetd_trx_date1, 'null')) {
      list.add(_labelValue(context, 'Distribution Date', hmetd_trx_date1));
    }

    if (!StringUtils.isEmtpy(hmetd_trx_date2) &&
        !StringUtils.equalsIgnoreCase(hmetd_trx_date2, 'null')) {
      list.add(_labelValue(context, 'Right End', hmetd_trx_date2));
    }

    if (!StringUtils.isEmtpy(pay_date) &&
        !StringUtils.equalsIgnoreCase(pay_date, 'null')) {
      list.add(_labelValue(context, 'Pay Date', pay_date));
    }

    if (!StringUtils.isEmtpy(split_date) &&
        !StringUtils.equalsIgnoreCase(split_date, 'null')) {
      list.add(_labelValue(context, 'Split Date', split_date));
    }

    if (!StringUtils.isEmtpy(ex_date) &&
        !StringUtils.equalsIgnoreCase(ex_date, 'null')) {
      list.add(_labelValue(context, 'Ex Date', ex_date));
    }

    if (!StringUtils.isEmtpy(maturity_date) &&
        !StringUtils.equalsIgnoreCase(maturity_date, 'null')) {
      list.add(_labelValue(context, 'Maturity Date', maturity_date));
    }

    if (!StringUtils.isEmtpy(description) &&
        !StringUtils.equalsIgnoreCase(description, 'null')) {
      list.add(_labelValue(context, '', description));
    }
    //text.append("<B>TYPE</B> : "+c.type);
    //text.append("<BR><B>AMOUNT</B> : "+c.amount);
    //text.append("<BR><B>RATIO1</B> : "+c.exercise_ratio);
    //text.append("<BR><B>RATIO2</B> : "+c.proceed_ratio);
    //text.append("<BR><B>CUM DATE</B> : "+c.cum_date);
    //text.append("<BR><B>DIST DATE</B> : "+c.hmetd_trx_date1);
    //text.append("<BR><B>RIGHT END</B> : "+c.hmetd_trx_date2);
    //text.append("<BR><B>DESCRIPTION</B> : "+c.description+"<BR>");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  static CorporateActionEvent createBasic() {
    String code = '';
    String name = '';
    String type = '';
    String todayDate = '';
    String cumDate = '';
    String distributionDate = '';
    double proceedRatio = 0;
    double exerciseRatio = 0;
    String recordingDate = '';
    double amount = 0;
    String description = '';
    String hmetdTrxDate1 = '';
    String hmetdTrxDate2 = '';
    String exerciseInstrument = '';

    String payDate = '';
    String splitDate = '';
    String exDate = '';
    String maturityDate = '';

    Color backgroundColor = Colors.black;
    int priorityColor = 0;
    return CorporateActionEvent(
        code,
        name,
        type,
        todayDate,
        cumDate,
        distributionDate,
        proceedRatio,
        exerciseRatio,
        recordingDate,
        amount,
        description,
        hmetdTrxDate1,
        hmetdTrxDate2,
        exerciseInstrument,
        backgroundColor,
        priorityColor,
        payDate,
        splitDate,
        exDate,
        maturityDate);
  }

  CorporateActionEvent(
      this.code,
      this.name,
      this.type,
      this.today_date,
      this.cum_date,
      this.distribution_date,
      this.proceed_ratio,
      this.exercise_ratio,
      this.recording_date,
      this.amount,
      this.description,
      this.hmetd_trx_date1,
      this.hmetd_trx_date2,
      this.exercise_instrument,
      this.background_color,
      this.priority_color,
      this.pay_date,
      this.split_date,
      this.ex_date,
      this.maturity_date);

  static Color getColor(List<CorporateActionEvent> result) {
    //List<CorporateActionEvent> result = List.empty(growable: true);
    int priority = -1;
    Color color = Colors.black;
    int count = result != null ? result.length : 0;
    for (int i = 0; i < count; i++) {
      CorporateActionEvent c = result.elementAt(i);
      if (c.priority_color > priority) {
        color = c.background_color;
        priority = c.priority_color;
      }
    }
    return color;
  }

  factory CorporateActionEvent.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String type = StringUtils.noNullString(parsedJson['type']);
    String today_date = StringUtils.noNullString(parsedJson['today_date']);
    String cum_date = StringUtils.noNullString(parsedJson['cum_date']);
    String distributionDate =
        StringUtils.noNullString(parsedJson['distribution_date']);
    double proceedRatio = Utils.safeDouble(parsedJson['proceed_ratio']);
    double exerciseRatio = Utils.safeDouble(parsedJson['exercise_ratio']);
    String recordingDate =
        StringUtils.noNullString(parsedJson['recording_date']);
    double amount = Utils.safeDouble(parsedJson['amount']);
    String description = StringUtils.noNullString(parsedJson['description']);
    String hmetdTrxDate1 =
        StringUtils.noNullString(parsedJson['hmetd_trx_date1']);
    String hmetdTrxDate2 =
        StringUtils.noNullString(parsedJson['hmetd_trx_date2']);
    String exerciseInstrument =
        StringUtils.noNullString(parsedJson['exercise_instrument']);

    String payDate = StringUtils.noNullString(parsedJson['pay_date']);
    String splitDate = StringUtils.noNullString(parsedJson['hmetd_trx_date1']);
    String exDate = StringUtils.noNullString(parsedJson['ex_date']);
    String maturityDate = StringUtils.noNullString(parsedJson['maturity_date']);

    Color backgroundColor = Colors.black;
    int priorityColor = 0;
    if (StringUtils.equalsIgnoreCase(today_date, cum_date)) {
      //background_color = Color.RED;
      //background_color_id = R.drawable.button_ca_red;
      backgroundColor = InvestrendTheme.redText;
      priorityColor = 2;
    } else {
      int todayDate = Utils.safeInt(today_date.replaceAll("-", ""));
      int cumDate = Utils.safeInt(cum_date.replaceAll("-", ""));

      if (todayDate < cumDate) {
        //background_color = context.getResources().getColor(R.color.Orange);
        //background_color_id = R.drawable.button_ca_orange;
        backgroundColor = Colors.orange;
        priorityColor = 1;
      } else if (todayDate > cumDate) {
        //background_color = Color.GRAY;
        //background_color_id = R.drawable.button_ca_gray;
        backgroundColor = Colors.grey;
        priorityColor = 0;
      }
    }

    return CorporateActionEvent(
        code,
        name,
        type,
        today_date,
        cum_date,
        distributionDate,
        proceedRatio,
        exerciseRatio,
        recordingDate,
        amount,
        description,
        hmetdTrxDate1,
        hmetdTrxDate2,
        exerciseInstrument,
        backgroundColor,
        priorityColor,
        payDate,
        splitDate,
        exDate,
        maturityDate);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }

  @override
  String toString() {
    return 'CorporateActionEvent {code: $code, name: $name, type: $type, today_date: $today_date, cum_date: $cum_date, distribution_date: $distribution_date, proceed_ratio: $proceed_ratio, exercise_ratio: $exercise_ratio, recording_date: $recording_date, amount: $amount, description: $description, hmetd_trx_date1: $hmetd_trx_date1, hmetd_trx_date2: $hmetd_trx_date2, exercise_instrument: $exercise_instrument, loaded: $loaded}';
  }

  void copyValueFrom(CorporateActionEvent newValue) {
    if (newValue != null) {
      this.loaded = true;

      this.code = newValue.code;
      this.name = newValue.name;
      this.type = newValue.type;
      this.today_date = newValue.today_date;
      this.cum_date = newValue.cum_date;
      this.distribution_date = newValue.distribution_date;
      this.proceed_ratio = newValue.proceed_ratio;
      this.exercise_ratio = newValue.exercise_ratio;
      this.recording_date = newValue.recording_date;
      this.amount = newValue.amount;
      this.description = newValue.description;
      this.hmetd_trx_date1 = newValue.hmetd_trx_date1;
      this.hmetd_trx_date2 = newValue.hmetd_trx_date2;
      this.exercise_instrument = newValue.exercise_instrument;

      this.pay_date = newValue.pay_date;
      this.split_date = newValue.split_date;
      this.ex_date = newValue.ex_date;
      this.maturity_date = newValue.maturity_date;
    } else {
      this.code = '';
      this.name = '';
      this.type = '';
      this.today_date = '';
      this.cum_date = '';
      this.distribution_date = '';
      this.proceed_ratio = 0;
      this.exercise_ratio = 0;
      this.recording_date = '';
      this.amount = 0;
      this.description = '';
      this.hmetd_trx_date1 = '';
      this.hmetd_trx_date2 = '';
      this.exercise_instrument = '';

      this.pay_date = '';
      this.split_date = '';
      this.ex_date = '';
      this.maturity_date = '';
    }
  }
}

class Remark2Mapping {
  String key = ""; // "19_B",
  String digit = ""; // "19",
  String code = ""; // "B",
  String value = ""; // "Bankruptcy filing against the company",
  String description = ""; // ""

  bool loaded = false;

  bool isSurveilance() {
    return StringUtils.equalsIgnoreCase(key, '30_X');
  }

  Remark2Mapping(this.key, this.digit, this.code, this.value, this.description);

  String toString() {
    return '[Remark2Mapping  key : $key  digit : $digit  code : $code  value : $value'
        '  description : $description ]';
  }

  /*
  {
  "key": "19_B",
  "digit": "19",
  "code": "B",
  "value": "Bankruptcy filing against the company",
  "description": ""
  }
  */

  factory Remark2Mapping.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String key = StringUtils.noNullString(parsedJson['key']);
    String digit = StringUtils.noNullString(parsedJson['digit']);
    String code = StringUtils.noNullString(parsedJson['code']);
    String value = StringUtils.noNullString(parsedJson['value']);
    String description = StringUtils.noNullString(parsedJson['description']);
    return Remark2Mapping(key, digit, code, value, description);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(key);
  }

  void copyValueFrom(Remark2Mapping newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.key = newValue.key;
      this.digit = newValue.digit;
      this.code = newValue.code;
      this.value = newValue.value;
      this.description = newValue.description;
    } else {
      this.key = ""; // "19_B",
      this.digit = ""; // "19",
      this.code = ""; // "B",
      this.value = ""; // "Bankruptcy filing against the company",
      this.description = ""; // ""
    }
  }
}

class Remark2Stock {
  String code = ''; //" "ABBA",
  String special_notation = ''; // "-E-L-----",
  String key_19 = ''; // "19_-",
  String key_20 = ''; // "20_E",
  String key_21 = ''; // "21_-",
  String key_22 = ''; // "22_L",
  String key_23 = ''; // "23_-",
  String key_24 = ''; // "24_-",
  String key_25 = ''; // "25_-",
  String key_26 = ''; // "26_-",
  String key_27 = ''; // "27_-"

  String key_28 = ''; // "28_-",
  String key_29 = ''; // "29_-",
  String key_30 = ''; // "30_-"

  bool loaded = false;

  String toString() {
    return '[Remark2Stock  code : $code  special_notation : $special_notation  key_19 : $key_19  key_20 : $key_20'
        '  key_21 : $key_21  key_22 : $key_22  key_23 : $key_23  key_24 : $key_24  key_25 : $key_25  key_26 : $key_26  key_27 : $key_27 '
        ' key_28 : $key_28  key_29 : $key_29  key_30 : $key_30 ]';
  }

  Remark2Stock(
      this.code,
      this.special_notation,
      this.key_19,
      this.key_20,
      this.key_21,
      this.key_22,
      this.key_23,
      this.key_24,
      this.key_25,
      this.key_26,
      this.key_27,
      this.key_28,
      this.key_29,
      this.key_30);

  /*
  {
      "start": 1,
      "code": "ABBA",
      "special_notation": "-E-L-----",
      "key_19": "19_-",
      "key_20": "20_E",
      "key_21": "21_-",
      "key_22": "22_L",
      "key_23": "23_-",
      "key_24": "24_-",
      "key_25": "25_-",
      "key_26": "26_-",
      "key_27": "27_-"

      "start": 5,
      "code": "BCIP",
      "special_notation": "-------Y----",
      "key_19": "19_-",
      "key_20": "20_-",
      "key_21": "21_-",
      "key_22": "22_-",
      "key_23": "23_-",
      "key_24": "24_-",
      "key_25": "25_-",
      "key_26": "26_Y",
      "key_27": "27_-",
      "key_28": "28_-",
      "key_29": "29_-",
      "key_30": "30_-"
    }
  */

  factory Remark2Stock.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String code = StringUtils.noNullString(parsedJson['code']);
    String specialNotation =
        StringUtils.noNullString(parsedJson['special_notation']);
    String key_19 = StringUtils.noNullString(parsedJson['key_19']);
    String key_20 = StringUtils.noNullString(parsedJson['key_20']);
    String key_21 = StringUtils.noNullString(parsedJson['key_21']);
    String key_22 = StringUtils.noNullString(parsedJson['key_22']);
    String key_23 = StringUtils.noNullString(parsedJson['key_23']);
    String key_24 = StringUtils.noNullString(parsedJson['key_24']);
    String key_25 = StringUtils.noNullString(parsedJson['key_25']);
    String key_26 = StringUtils.noNullString(parsedJson['key_26']);
    String key_27 = StringUtils.noNullString(parsedJson['key_27']);

    String key_28 = StringUtils.noNullString(parsedJson['key_28']);
    String key_29 = StringUtils.noNullString(parsedJson['key_29']);
    String key_30 = StringUtils.noNullString(parsedJson['key_30']);

    return Remark2Stock(code, specialNotation, key_19, key_20, key_21, key_22,
        key_23, key_24, key_25, key_26, key_27, key_28, key_29, key_30);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }

  void copyValueFrom(Remark2Stock newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.special_notation = newValue.special_notation;
      this.key_19 = newValue.key_19;
      this.key_20 = newValue.key_20;
      this.key_21 = newValue.key_21;
      this.key_22 = newValue.key_22;
      this.key_23 = newValue.key_23;
      this.key_24 = newValue.key_24;
      this.key_25 = newValue.key_25;
      this.key_26 = newValue.key_26;
      this.key_27 = newValue.key_27;
      this.key_28 = newValue.key_28;
      this.key_29 = newValue.key_29;
      this.key_30 = newValue.key_30;
    } else {
      this.code = ''; //" "ABBA",
      this.special_notation = ''; // "-E-L-----",
      this.key_19 = ''; // "19_-",
      this.key_20 = ''; // "20_E",
      this.key_21 = ''; // "21_-",
      this.key_22 = ''; // "22_L",
      this.key_23 = ''; // "23_-",
      this.key_24 = ''; // "24_-",
      this.key_25 = ''; // "25_-",
      this.key_26 = ''; // "26_-",
      this.key_27 = ''; // "27_-"

      this.key_28 = ''; // "28_-",
      this.key_29 = ''; // "29_-",
      this.key_30 = ''; // "30_-"
    }
  }
}

class HelpData {
  bool loaded = false;

  String date = "";
  String time = "";
  String md5_help_contents = "";
  String md5_help_menus = "";

  List<HelpMenu> menus = List.empty(growable: true);
  List<HelpContent> contents = List.empty(growable: true);

  Future<bool> load() async {
    final pref = await SharedPreferences.getInstance();
    String updated = pref.getString('token_updated') ?? '-';
    this.md5_help_contents = pref.getString('md5_help_contents') ?? '';
    this.md5_help_menus = pref.getString('md5_help_menus') ?? '';
    this.date = pref.getString('date') ?? '';
    this.time = pref.getString('time') ?? '';

    String menusString = pref.getString('menusString') ?? '';
    String contentsString = pref.getString('contentsString') ?? '';

    print('HelpData.load menusString : $menusString');
    this.menus.clear();
    Serializeable.unserializeFromString(menusString, this.menus);
    print('HelpData.load Got menus : ' + this.menus.length.toString());

    print('HelpData.load contentsString : $contentsString');
    this.contents.clear();
    Serializeable.unserializeFromString(contentsString, this.contents);
    print('HelpData.load Got contents : ' + this.contents.length.toString());

    print('HelpData.load updated : $updated   date : $date   time : $time'
        '  md5_help_contents : $md5_help_contents   md5_help_menus : $md5_help_menus'
        '  contentsString : $contentsString   menusString : $menusString');
    loaded = true;
    return true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();

    String menusString = Serializeable.serializeAsString(menus);
    String contentsString = Serializeable.serializeAsString(contents);

    bool savedUpdated = await prefs.setString('token_updated', updated);
    bool savedMD5Content =
        await prefs.setString('md5_help_contents', md5_help_contents);
    bool savedMD5Menus =
        await prefs.setString('md5_help_menus', md5_help_menus);
    bool savedDate = await prefs.setString('date', date);
    bool savedTime = await prefs.setString('time', time);
    bool savedMenuString = await prefs.setString('menusString', menusString);
    bool savedContentString =
        await prefs.setString('contentsString', contentsString);

    bool saved = savedUpdated &&
        savedMD5Content &&
        savedMD5Menus &&
        savedDate &&
        savedTime &&
        savedMenuString &&
        savedContentString;
    print(
        'HelpData.save $saved updated : $updated   date : $date   time : $time'
        '  md5_help_contents : $md5_help_contents   md5_help_menus : $md5_help_menus'
        '  menusString : $menusString   contentsString : $contentsString');
    return saved;
  }

  void updateMenus(String newMd5HelpMenus, List<HelpMenu> newMenus) {
    this.menus.clear();
    this.menus.addAll(newMenus);
    this.md5_help_menus = newMd5HelpMenus;
  }

  void updateContents(
      String newMd5HelpContents, List<HelpContent> newContents) {
    this.contents.clear();
    this.contents.addAll(newContents);
    this.md5_help_contents = newMd5HelpContents;
  }

  int countContents() {
    return contents != null ? contents.length : 0;
  }

  int countMenus() {
    return menus != null ? menus.length : 0;
  }

  void putMenu(HelpMenu menu) {
    // final existing =
    // menus.firstWhere((element) =>
    // element.id == menu.id,
    //     orElse: () {
    //       return null;
    //     });

    final index = menus.indexWhere((element) => element.id == menu.id);
    if (index >= 0) {
      menus.removeAt(index);
    }

    //if (!menus.contains(menu)) {
    if (menu != null) {
      menus.add(menu);
      print("putContent added : " + menu.toString());
    }
    /*
    if( menu != null){
      menus.update(
        menu.id,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
            (existingValue) => menu,
        ifAbsent: () => menu,
      );
      //maps.put(key, map);
      print("putMenu added : "+menu.toString());
    }

     */
  }

  String toString() {
    return "HelpData  $date $time   menus.size : " +
        countMenus().toString() +
        "  contents.size : " +
        countContents().toString();
  }

  void putContent(HelpContent content) {
    // final existing =
    // contents.firstWhere((element) =>
    // element.id == content.id,
    //     orElse: () {
    //       return null;
    //     });

    final index = contents.indexWhere((element) => element.id == content.id);
    if (index >= 0) {
      contents.removeAt(index);
    }

    //if (!contents.contains(content)) {
    if (content != null) {
      contents.add(content);
      print("putContent added : " + content.toString());
    }
  }

  bool isEmpty() {
    if (menus == null || menus.isEmpty) {
      return true;
    }
    if (contents == null || contents.isEmpty) {
      return true;
    }
    return false;
  }

  void copyValueFrom(HelpData newValue,
      {bool dontClearExistingIfNull = false}) {
    if (newValue != null) {
      this.loaded = true;
      this.date = newValue.date;
      this.time = newValue.time;
      this.md5_help_contents = newValue.md5_help_contents;
      this.md5_help_menus = newValue.md5_help_menus;
      this.menus.clear();
      this.contents.clear();
      if (newValue.menus != null) {
        this.menus.addAll(newValue.menus);
      }
      if (newValue.contents != null) {
        this.contents.addAll(newValue.contents);
      }
    } else {
      if (!dontClearExistingIfNull) {
        this.date = "";
        this.time = "";
        this.md5_help_contents = "";
        this.md5_help_menus = "";
        this.menus.clear();
        this.contents.clear();
      }
    }
  }
}

class HelpMenu extends Serializeable {
  String id = "";

  String menu_id = "";

  String menu_en = "";

  String updated_at = "";

  bool loaded = false;

  HelpMenu(this.id, this.menu_id, this.menu_en, this.updated_at);

  String getMenu({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return menu_id;
    } else {
      return menu_en;
    }
  }

  String toString() {
    return '[HelpMenu  id : $id  menu_id : $menu_id  menu_en : $menu_en  updated_at : $updated_at ]';
  }

  /*
  {
      "start": 1,
      "id": "1",
      "menu_id": "Tentang Investrend",
      "menu_en": "About Investrend",
      "updated_at": "2021-09-03 23:51:32"
    },
  */

  factory HelpMenu.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String id = StringUtils.noNullString(parsedJson['id']);
    String menuId = StringUtils.noNullString(parsedJson['menu_id']);
    String menuEn = StringUtils.noNullString(parsedJson['menu_en']);
    String updatedAt = StringUtils.noNullString(parsedJson['updated_at']);
    return HelpMenu(id, menuId, menuEn, updatedAt);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(id);
  }

  void copyValueFrom(HelpMenu newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.id = newValue.id;
      this.menu_id = newValue.menu_id;
      this.menu_en = newValue.menu_en;
      this.updated_at = newValue.updated_at;
    } else {
      this.id = ""; // "19_B",
      this.menu_id = ""; // "19",
      this.menu_en = ""; // "B",
      this.updated_at = "";
    }
  }

  @override
  String asPlain() {
    String plain = Serializeable.safePlain(id);
    plain += '|' + Serializeable.safePlain(menu_id);
    plain += '|' + Serializeable.safePlain(menu_en);
    plain += '|' + Serializeable.safePlain(updated_at);
    return plain;
  }

  factory HelpMenu.fromPlain(String data) {
    List<String> datas = data.split('|');
    if (datas != null && datas.isNotEmpty && datas.length >= 4) {
      String id = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(0)));
      String menuId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(1)));
      String menuEn = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(2)));
      String updatedAt = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(3)));

      return HelpMenu(id, menuId, menuEn, updatedAt);
    }
    return null;
  }

  @override
  String identity() {
    return 'HelpMenu';
  }
}

class HelpContent extends Serializeable {
  String id_menu = "";

  String id = "";

  String subtile_id = "";

  String subtile_en = "";

  String content_id = "";

  String content_en = "";

  String updated_at = "";

  bool loaded = false;

  HelpContent(this.id_menu, this.id, this.subtile_id, this.subtile_en,
      this.content_id, this.content_en, this.updated_at);

  String getSubtitle({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return subtile_id;
    } else {
      return subtile_en;
    }
  }

  String getContent({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return content_id;
    } else {
      return content_en;
    }
  }

  String toString() {
    return '[HelpContent  id_menu : $id_menu id : $id  subtile_id : $subtile_id  subtile_en : $subtile_en  content_id : $content_id  content_en : $content_en  updated_at : $updated_at ]';
  }

  /*
  {

      "start": 1,
      "id_menu": "1",
      "id": "1",
      "subtile_id": "Jajaran Direksi",
      "subtile_en": "Board of Directors",
      "content_id": "content_id",
      "content_en": "content_en",
      "updated_at": "2021-09-04 00:15:32"
    },
  */

  factory HelpContent.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String idMenu = StringUtils.noNullString(parsedJson['id_menu']);
    String id = StringUtils.noNullString(parsedJson['id']);
    String subtileId = StringUtils.noNullString(parsedJson['subtile_id']);
    String subtileEn = StringUtils.noNullString(parsedJson['subtile_en']);
    String contentId = StringUtils.noNullString(parsedJson['content_id']);
    String contentEn = StringUtils.noNullString(parsedJson['content_en']);
    String updatedAt = StringUtils.noNullString(parsedJson['updated_at']);
    return HelpContent(
        idMenu, id, subtileId, subtileEn, contentId, contentEn, updatedAt);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(id);
  }

  void copyValueFrom(HelpContent newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.id_menu = newValue.id_menu;
      this.id = newValue.id;
      this.subtile_id = newValue.subtile_id;
      this.subtile_en = newValue.subtile_en;
      this.content_id = newValue.content_id;
      this.content_en = newValue.content_en;
      this.updated_at = newValue.updated_at;
    } else {
      this.id_menu = ""; // "19_B",
      this.id = ""; // "19_
      this.subtile_id = ""; // "19",
      this.subtile_en = ""; // "B",
      this.content_id = ""; // "19",
      this.content_en = ""; // "B",
      this.updated_at = "";
    }
  }

  @override
  String asPlain() {
    String plain = Serializeable.safePlain(id_menu);
    plain += '|' + Serializeable.safePlain(id);
    plain += '|' + Serializeable.safePlain(subtile_id);
    plain += '|' + Serializeable.safePlain(subtile_en);
    plain += '|' + Serializeable.safePlain(content_id);
    plain += '|' + Serializeable.safePlain(content_en);
    plain += '|' + Serializeable.safePlain(updated_at);
    return plain;
  }

  factory HelpContent.fromPlain(String data) {
    List<String> datas = data.split('|');
    if (datas != null && datas.isNotEmpty && datas.length >= 4) {
      String idMenu = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(0)));
      String id = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(1)));
      String subtileId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(2)));
      String subtileEn = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(3)));
      String contentId = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(4)));
      String contentEn = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(5)));
      String updatedAt = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(6)));

      return HelpContent(
          idMenu, id, subtileId, subtileEn, contentId, contentEn, updatedAt);
    }
    return null;
  }

  @override
  String identity() {
    return 'HelpContent';
  }
}

class Mutasi {
  /*
  String date = '';
  String nominal = '';
  String info_trx = '';
  String name = '';
  String bank = '';
  */
  String flag;
  String fundtype;
  String accountcode;
  double amount;
  String transferno;
  String bank;
  String account;
  String date;
  String accountname;
  String note;

  String monthYear = '';
  String dateMonth = '';

  /*
  {
  "flag": "W",
  "fundtype": "Withdraw",
  "accountcode": "C35",
  "amount": 200000000,
  "transferno": "",
  "bank": "BCA",
  "account": "0350448527",
  "accountname": "CHRISTIN",
  "note": "PB DR C35 KE C35M",
  "date": "04-10-2021"
  },
  */

  String info_trx() {
    return fundtype;
    /*
    List<String> infos = [note, fundtype, transferno, account];
    String info = '';
    infos.forEach((text) {
      if (!StringUtils.isEmtpy(text)) {
        if (StringUtils.isEmtpy(info)) {
          info = text;
        } else {
          info = info + ' / ' + text;
        }
      }
    });
    return info;
    */
    /*
    String info_0 = StringUtils.isEmtpy(note) ? '-' : note;
    String info_1 = StringUtils.isEmtpy(fundtype) ? '-' : fundtype;
    String info_2 = StringUtils.isEmtpy(transferno) ? '-' : transferno;
    String info_3 = StringUtils.isEmtpy(account) ? '-' : account;

    return '$info_0 / $info_1 / $info_2 / $info_3';
    */
  }

  Mutasi(
      this.flag,
      this.fundtype,
      this.accountcode,
      this.amount,
      this.transferno,
      this.bank,
      this.account,
      this.date,
      this.accountname,
      this.note,
      this.dateMonth,
      this.monthYear); // Mutasi(this.flag, this.fundtype, this.accountcode, this.amount, this.transferno, this.bank, this.account,
  //     this.date); //Mutasi(this.date, this.nominal, this.info_trx, this.name, this.bank);

  static DateFormat _formatData = DateFormat('dd-MM-yyyy');
  static DateFormat _formatDisplayDateMonth = DateFormat('dd/MM');
  static DateFormat _formatDisplayMonthYear = DateFormat('MMMM yyyy');

  factory Mutasi.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    /*
    String date = StringUtils.noNullString(parsedJson['date']);
    String nominal = StringUtils.noNullString(parsedJson['nominal']);
    String info_trx = StringUtils.noNullString(parsedJson['info_trx']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String bank = StringUtils.noNullString(parsedJson['bank']);
    */
    String flag = StringUtils.noNullString(parsedJson['flag']);
    String fundtype = StringUtils.noNullString(parsedJson['fundtype']);
    String accountcode = StringUtils.noNullString(parsedJson['accountcode']);
    double amount = Utils.safeDouble(parsedJson['amount']);
    String transferno = StringUtils.noNullString(parsedJson['transferno']);
    String bank = StringUtils.noNullString(parsedJson['bank']);
    String account = StringUtils.noNullString(parsedJson['account']);
    String date = StringUtils.noNullString(parsedJson['date']);
    String accountname = StringUtils.noNullString(parsedJson['accountname']);
    String note = StringUtils.noNullString(parsedJson['note']);

    DateTime dataDate = _formatData.parse(date, false);

    String monthYear = _formatDisplayMonthYear.format(dataDate);
    String dateMonth = _formatDisplayDateMonth.format(dataDate);

    //return Mutasi(date, nominal, info_trx, name, bank);
    //return Mutasi(flag, fundtype, accountcode, amount, transferno, bank, account, date);
    return Mutasi(flag, fundtype, accountcode, amount, transferno, bank,
        account, date, accountname, note, dateMonth, monthYear);
  }
}

class ResultMutasi {
  List<Mutasi> datas = List.empty(growable: true);
  String month = '';
  bool loaded = false;

  void copyValueFrom(ResultMutasi newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.month = newValue.month;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.month = '';
      this.datas.clear();
    }
  }

  bool isEmpty() {
    return this.datas != null ? this.datas.isEmpty : true;
  }

  int count() {
    return this.datas != null ? this.datas.length : 0;
  }
}

class Profile {
  String bio = '';
  String email = '';
  String handphone = '';
  String picture = '';
  String realname = '';
  String referral = '';
  String username = '';
  String ranking = '';
  bool loaded = false;

  Profile(this.bio, this.email, this.handphone, this.picture, this.realname,
      this.referral, this.username, this.ranking);

  factory Profile.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String bio = StringUtils.noNullString(parsedJson['bio']);
    String email = StringUtils.noNullString(parsedJson['email']);
    String handphone = StringUtils.noNullString(parsedJson['handphone']);
    String picture = StringUtils.noNullString(parsedJson['picture']);
    String realname = StringUtils.noNullString(parsedJson['realname']);
    String referral = StringUtils.noNullString(parsedJson['referral']);
    String username = StringUtils.noNullString(parsedJson['username']);
    String ranking = StringUtils.noNullString(parsedJson['ranking']);
    return Profile(
        bio, email, handphone, picture, realname, referral, username, ranking);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(username);
  }

  void copyValueFrom(Profile newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.bio = newValue.bio;
      this.email = newValue.email;
      this.handphone = newValue.handphone;
      this.picture = newValue.picture;
      this.realname = newValue.realname;
      this.referral = newValue.referral;
      this.username = newValue.username;
      this.ranking = newValue.ranking;
    } else {
      this.bio = '';
      this.email = '';
      this.handphone = '';
      this.picture = '';
      this.realname = '';
      this.referral = '';
      this.username = '';
      this.ranking = '';
    }
  }
}

class ContentEIPO {
  String code = '';
  String name = '';
  String sector = '';
  String sub_sector = '';
  String offering_date_start = '';
  String offering_date_end = '';
  int offering_price = 0;
  int offering_lot = 0;
  double offering_lot_percentage = 0.0;
  String book_building_date_start = '';
  String book_building_date_end = '';
  int book_building_price_start = 0;
  int book_building_price_end = 0;
  String allotment_date = '';
  String distribution_date = '';
  String listing_date = '';

  // String prospectus_file_url_1 = '';
  // String prospectus_file_url_2 = '';
  // String prospectus_file_url_3 = '';
  // String prospectus_file_url_4 = '';
  // String prospectus_file_url_5 = '';
  // String additional_file_url_1 = '';
  // String additional_file_url_2 = '';
  // String additional_file_url_3 = '';
  // String additional_file_url_4 = '';
  // String additional_file_url_5 = '';
  String company_description = '';
  String company_address = '';
  String company_website = '';

  // String participant_admin_1 = '';
  // String participant_admin_2 = '';
  // String participant_admin_3 = '';
  // String participant_admin_4 = '';
  // String participant_admin_5 = '';
  // String underwriter_1 = '';
  // String underwriter_2 = '';
  // String underwriter_3 = '';
  // String underwriter_4 = '';
  // String underwriter_5 = '';
  String action_register_eipo = '';
  String action_enter_eipo = '';

  List<String> listProspectus = List.empty(growable: true);
  List<String> listAdditional = List.empty(growable: true);
  List<String> listParticipantAdmin = List.empty(growable: true);
  List<String> listUnderwriter = List.empty(growable: true);
  String company_icon = '';
  String company_icon_large = '';

  int countProspectus() {
    return listProspectus != null ? listProspectus.length : 0;
  }

  int countAdditional() {
    return listAdditional != null ? listAdditional.length : 0;
  }

  int countParticipantAdmin() {
    return listParticipantAdmin != null ? listParticipantAdmin.length : 0;
  }

  int countUnderwriter() {
    return listUnderwriter != null ? listUnderwriter.length : 0;
  }

  /*
  {
  "start": 1,
  "code": "OILS",
  "name": "PT Indo Oil Perkasa Tbk",
  "sector": "Basic Materials",
  "sub_sector": "Agricultural Chemicals",
  "offering_date_start": "2021-08-31",
  "offering_date_end": "2021-09-02",
  "offering_price": "270",
  "offering_lot": "1500000",
  "offering_lot_percentage": "33.04",
  "book_building_date_start": "2021-08-09",
  "book_building_date_end": "2021-08-16",
  "book_building_price_start": "270",
  "book_building_price_end": "300",
  "allotment_date": "2021-09-02",
  "distribution_date": "2021-09-03",
  "listing_date": "2021-09-06",
  "prospectus_file_url_1": "https://www.e-ipo.co.id/en/pipeline/get-propectus-file?id=43&type=",
  "prospectus_file_url_2": "https://www.e-ipo.co.id/en/pipeline/get-propectus-file?id=43&type=summary",
  "prospectus_file_url_3": null,
  "prospectus_file_url_4": null,
  "prospectus_file_url_5": null,
  "additional_file_url_1": null,
  "additional_file_url_2": null,
  "additional_file_url_3": null,
  "additional_file_url_4": null,
  "additional_file_url_5": null,
  "company_description": "Kegiatan usaha Perseroan saat ini adalah memproduksi dan memasarkan produk utamanya yaitu minyak kelapa murni atau Crude Coconut Oil (CNO). Perseroan juga memproduksi dan memasarkan produk turunan CNO, yaitu minyak kelapa murni yang diproses kembali atau Refined Coconut Oil (RBD), serta tepung kopra atau Copra Meal, yaitu sisa/residu dari hasil ekstraksi produk minyak kelapa. Selain memproduksi CNO, Perseroan juga memasarkan produk-produk CNO, RBD, dan Copra Meal.",
  "company_address": "Jalan Raya Perning No. 39, Kecamatan Jetis, Kabupaten Mojokerto, Jawa Timur 61352",
  "company_website": "https://www.indooilperkasa.com",
  "participant_admin_1": "BQ - KOREA INVESTMENT AND SEKURITAS INDONESIA",
  "participant_admin_2": null,
  "participant_admin_3": null,
  "participant_admin_4": null,
  "participant_admin_5": null,
  "underwriter_1": "BQ - KOREA INVESTMENT AND SEKURITAS INDONESIA",
  "underwriter_2": null,
  "underwriter_3": null,
  "underwriter_4": null,
  "underwriter_5": null,
  "action_register_eipo": "https://www.e-ipo.co.id/en/register",
  "action_enter_eipo": "https://www.e-ipo.co.id/en/login"
  },
  */

  bool loaded = false;

  ContentEIPO(
      this.code,
      this.name,
      this.sector,
      this.sub_sector,
      this.offering_date_start,
      this.offering_date_end,
      this.offering_price,
      this.offering_lot,
      this.offering_lot_percentage,
      this.book_building_date_start,
      this.book_building_date_end,
      this.book_building_price_start,
      this.book_building_price_end,
      this.allotment_date,
      this.distribution_date,
      this.listing_date,
      // this.prospectus_file_url_1,
      // this.prospectus_file_url_2,
      // this.prospectus_file_url_3,
      // this.prospectus_file_url_4,
      // this.prospectus_file_url_5,
      // this.additional_file_url_1,
      // this.additional_file_url_2,
      // this.additional_file_url_3,
      // this.additional_file_url_4,
      // this.additional_file_url_5,
      this.company_description,
      this.company_address,
      this.company_website,
      // this.participant_admin_1,
      // this.participant_admin_2,
      // this.participant_admin_3,
      // this.participant_admin_4,
      // this.participant_admin_5,
      // this.underwriter_1,
      // this.underwriter_2,
      // this.underwriter_3,
      // this.underwriter_4,
      // this.underwriter_5,
      this.action_register_eipo,
      this.action_enter_eipo,
      this.listProspectus,
      this.listAdditional,
      this.listParticipantAdmin,
      this.listUnderwriter,
      this.company_icon,
      this.company_icon_large);

  factory ContentEIPO.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String bio = StringUtils.noNullString(parsedJson['bio']);

    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String sector = StringUtils.noNullString(parsedJson['sector']);
    String subSector = StringUtils.noNullString(parsedJson['sub_sector']);
    String offeringDateStart =
        StringUtils.noNullString(parsedJson['offering_date_start']);
    String offeringDateEnd =
        StringUtils.noNullString(parsedJson['offering_date_end']);
    int offeringPrice = Utils.safeInt(parsedJson['offering_price']);
    int offeringLot = Utils.safeInt(parsedJson['offering_lot']);
    double offeringLotPercentage =
        Utils.safeDouble(parsedJson['offering_lot_percentage']);
    String bookBuildingDateStart =
        StringUtils.noNullString(parsedJson['book_building_date_start']);
    String bookBuildingDateEnd =
        StringUtils.noNullString(parsedJson['book_building_date_end']);
    int bookBuildingPriceStart =
        Utils.safeInt(parsedJson['book_building_price_start']);
    int bookBuildingPriceEnd =
        Utils.safeInt(parsedJson['book_building_price_end']);
    String allotmentDate =
        StringUtils.noNullString(parsedJson['allotment_date']);
    String distributionDate =
        StringUtils.noNullString(parsedJson['distribution_date']);
    String listingDate = StringUtils.noNullString(parsedJson['listing_date']);
    // String prospectus_file_url_1 = StringUtils.noNullString(parsedJson['prospectus_file_url_1']);
    // String prospectus_file_url_2 = StringUtils.noNullString(parsedJson['prospectus_file_url_2']);
    // String prospectus_file_url_3 = StringUtils.noNullString(parsedJson['prospectus_file_url_3']);
    // String prospectus_file_url_4 = StringUtils.noNullString(parsedJson['prospectus_file_url_4']);
    // String prospectus_file_url_5 = StringUtils.noNullString(parsedJson['prospectus_file_url_5']);
    // String additional_file_url_1 = StringUtils.noNullString(parsedJson['additional_file_url_1']);
    // String additional_file_url_2 = StringUtils.noNullString(parsedJson['additional_file_url_2']);
    // String additional_file_url_3 = StringUtils.noNullString(parsedJson['additional_file_url_3']);
    // String additional_file_url_4 = StringUtils.noNullString(parsedJson['additional_file_url_4']);
    // String additional_file_url_5 = StringUtils.noNullString(parsedJson['additional_file_url_5']);
    String companyDescription =
        StringUtils.noNullString(parsedJson['company_description']);
    String companyAddress =
        StringUtils.noNullString(parsedJson['company_address']);
    String companyWebsite =
        StringUtils.noNullString(parsedJson['company_website']);
    // String participant_admin_1 = StringUtils.noNullString(parsedJson['participant_admin_1']);
    // String participant_admin_2 = StringUtils.noNullString(parsedJson['participant_admin_2']);
    // String participant_admin_3 = StringUtils.noNullString(parsedJson['participant_admin_3']);
    // String participant_admin_4 = StringUtils.noNullString(parsedJson['participant_admin_4']);
    // String participant_admin_5 = StringUtils.noNullString(parsedJson['participant_admin_5']);
    // String underwriter_1 = StringUtils.noNullString(parsedJson['underwriter_1']);
    // String underwriter_2 = StringUtils.noNullString(parsedJson['underwriter_2']);
    // String underwriter_3 = StringUtils.noNullString(parsedJson['underwriter_3']);
    // String underwriter_4 = StringUtils.noNullString(parsedJson['underwriter_4']);
    // String underwriter_5 = StringUtils.noNullString(parsedJson['underwriter_5']);
    String actionRegisterEipo =
        StringUtils.noNullString(parsedJson['action_register_eipo']);
    String actionEnterEipo =
        StringUtils.noNullString(parsedJson['action_enter_eipo']);

    String companyIcon = StringUtils.noNullString(parsedJson['company_icon']);
    String companyIconLarge =
        StringUtils.noNullString(parsedJson['company_icon_large']);

    List<String> listProspectus = List.empty(growable: true);
    List<String> listAdditional = List.empty(growable: true);
    List<String> listParticipantAdmin = List.empty(growable: true);
    List<String> listUnderwriter = List.empty(growable: true);

    for (int i = 1; i < 6; i++) {
      String prospectusFileUrl =
          StringUtils.noNullString(parsedJson['prospectus_file_url_$i']);
      String additionalFileUrl =
          StringUtils.noNullString(parsedJson['additional_file_url_$i']);
      String participantAdmin =
          StringUtils.noNullString(parsedJson['participant_admin_$i']);
      String underwriter =
          StringUtils.noNullString(parsedJson['underwriter_$i']);

      if (!StringUtils.isEmtpy(prospectusFileUrl)) {
        listProspectus.add(prospectusFileUrl);
      }
      if (!StringUtils.isEmtpy(additionalFileUrl)) {
        listAdditional.add(additionalFileUrl);
      }
      if (!StringUtils.isEmtpy(participantAdmin)) {
        listParticipantAdmin.add(participantAdmin);
      }
      if (!StringUtils.isEmtpy(underwriter)) {
        listUnderwriter.add(underwriter);
      }
    }

    return ContentEIPO(
        code,
        name,
        sector,
        subSector,
        offeringDateStart,
        offeringDateEnd,
        offeringPrice,
        offeringLot,
        offeringLotPercentage,
        bookBuildingDateStart,
        bookBuildingDateEnd,
        bookBuildingPriceStart,
        bookBuildingPriceEnd,
        allotmentDate,
        distributionDate,
        listingDate,
        companyDescription,
        companyAddress,
        companyWebsite,
        actionRegisterEipo,
        actionEnterEipo,
        listProspectus,
        listAdditional,
        listParticipantAdmin,
        listUnderwriter,
        companyIcon,
        companyIconLarge);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }

  void copyValueFrom(ContentEIPO newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.name = newValue.name;
      this.sector = newValue.sector;
      this.sub_sector = newValue.sub_sector;
      this.offering_date_start = newValue.offering_date_start;
      this.offering_date_end = newValue.offering_date_end;
      this.offering_price = newValue.offering_price;
      this.offering_lot = newValue.offering_lot;
      this.offering_lot_percentage = newValue.offering_lot_percentage;
      this.book_building_date_start = newValue.book_building_date_start;
      this.book_building_date_end = newValue.book_building_date_end;
      this.book_building_price_start = newValue.book_building_price_start;
      this.book_building_price_end = newValue.book_building_price_end;
      this.allotment_date = newValue.allotment_date;
      this.distribution_date = newValue.distribution_date;
      this.listing_date = newValue.listing_date;
      // this.prospectus_file_url_1 = newValue.prospectus_file_url_1 ;
      // this.prospectus_file_url_2 = newValue.prospectus_file_url_2 ;
      // this.prospectus_file_url_3 = newValue.prospectus_file_url_3 ;
      // this.prospectus_file_url_4 = newValue.prospectus_file_url_4 ;
      // this.prospectus_file_url_5 = newValue.prospectus_file_url_5 ;
      // this.additional_file_url_1 = newValue.additional_file_url_1 ;
      // this.additional_file_url_2 = newValue.additional_file_url_2 ;
      // this.additional_file_url_3 = newValue.additional_file_url_3 ;
      // this.additional_file_url_4 = newValue.additional_file_url_4 ;
      // this.additional_file_url_5 = newValue.additional_file_url_5 ;
      this.company_description = newValue.company_description;
      this.company_address = newValue.company_address;
      this.company_website = newValue.company_website;
      // this.participant_admin_1 = newValue.participant_admin_1 ;
      // this.participant_admin_2 = newValue.participant_admin_2 ;
      // this.participant_admin_3 = newValue.participant_admin_3 ;
      // this.participant_admin_4 = newValue.participant_admin_4 ;
      // this.participant_admin_5 = newValue.participant_admin_5 ;
      // this.underwriter_1 = newValue.underwriter_1 ;
      // this.underwriter_2 = newValue.underwriter_2 ;
      // this.underwriter_3 = newValue.underwriter_3 ;
      // this.underwriter_4 = newValue.underwriter_4 ;
      // this.underwriter_5 = newValue.underwriter_5 ;
      this.action_register_eipo = newValue.action_register_eipo;
      this.action_enter_eipo = newValue.action_enter_eipo;

      this.listProspectus.clear();
      if (newValue.listProspectus != null) {
        this.listProspectus.addAll(newValue.listProspectus);
      }
      this.listAdditional.clear();
      if (newValue.listAdditional != null) {
        this.listAdditional.addAll(newValue.listAdditional);
      }
      this.listParticipantAdmin.clear();
      if (newValue.listParticipantAdmin != null) {
        this.listParticipantAdmin.addAll(newValue.listParticipantAdmin);
      }
      this.listUnderwriter.clear();
      if (newValue.listUnderwriter != null) {
        this.listUnderwriter.addAll(newValue.listUnderwriter);
      }
      this.company_icon = newValue.company_icon;
      this.company_icon_large = newValue.company_icon_large;
    } else {
      this.code = '';
      this.name = '';
      this.sector = '';
      this.sub_sector = '';
      this.offering_date_start = '';
      this.offering_date_end = '';
      this.offering_price = 0;
      this.offering_lot = 0;
      this.offering_lot_percentage = 0.0;
      this.book_building_date_start = '';
      this.book_building_date_end = '';
      this.book_building_price_start = 0;
      this.book_building_price_end = 0;
      this.allotment_date = '';
      this.distribution_date = '';
      this.listing_date = '';
      // this.prospectus_file_url_1 = '';
      // this.prospectus_file_url_2 = '';
      // this.prospectus_file_url_3 = '';
      // this.prospectus_file_url_4 = '';
      // this.prospectus_file_url_5 = '';
      // this.additional_file_url_1 = '';
      // this.additional_file_url_2 = '';
      // this.additional_file_url_3 = '';
      // this.additional_file_url_4 = '';
      // this.additional_file_url_5 = '';
      this.company_description = '';
      this.company_address = '';
      this.company_website = '';
      // this.participant_admin_1 = '';
      // this.participant_admin_2 = '';
      // this.participant_admin_3 = '';
      // this.participant_admin_4 = '';
      // this.participant_admin_5 = '';
      // this.underwriter_1 = '';
      // this.underwriter_2 = '';
      // this.underwriter_3 = '';
      // this.underwriter_4 = '';
      // this.underwriter_5 = '';
      this.action_register_eipo = '';
      this.action_enter_eipo = '';
      this.listProspectus.clear();
      this.listAdditional.clear();
      this.listParticipantAdmin.clear();
      this.listUnderwriter.clear();
      this.company_icon = '';
      this.company_icon_large = '';
    }
  }

  static ContentEIPO createBasic() {
    List<String> listProspectus = List.empty(growable: true);
    List<String> listAdditional = List.empty(growable: true);
    List<String> listParticipantAdmin = List.empty(growable: true);
    List<String> listUnderwriter = List.empty(growable: true);
    return ContentEIPO(
        '',
        '',
        '',
        '',
        '',
        '',
        0,
        0,
        0.0,
        '',
        '',
        0,
        0,
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        listProspectus,
        listAdditional,
        listParticipantAdmin,
        listUnderwriter,
        '',
        '');
  }
}

class ListEIPO {
  String code = '';
  String name = '';
  String offering_date_end = '';
  String company_icon = '';

  /*
  {
      "start": 1,
      "code": "OILS",
      "name": "PT Indo Oil Perkasa Tbk",
      "offering_date_end": "2021-09-02",
      "company_icon": "https://indooilperkasa.com/page/id/img/logo.png"
    }
  */

  bool loaded = false;

  ListEIPO(this.code, this.name, this.offering_date_end, this.company_icon);

  factory ListEIPO.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String offeringDateEnd =
        StringUtils.noNullString(parsedJson['offering_date_end']);
    String companyIcon = StringUtils.noNullString(parsedJson['company_icon']);
    return ListEIPO(code, name, offeringDateEnd, companyIcon);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }

  void copyValueFrom(ContentEIPO newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.name = newValue.name;
      this.offering_date_end = newValue.offering_date_end;
      this.company_icon = newValue.company_icon;
    } else {
      this.code = '';
      this.name = '';
      this.offering_date_end = '';
      this.company_icon = '';
    }
  }
}

/*
class OfferingEIPOData {
  bool loaded = false;
  List<OfferingEIPO> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  void addEIPO(OfferingEIPO eipo){
    if(eipo != null){
      datas.add(eipo);
    }
  }

  void copyValueFrom(OfferingEIPOData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if(newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }

  bool isEmpty() {
    return this.datas != null ? this.datas.isEmpty : true;
  }
}
*/

class StockThemes {
  int id = 0;

  // String name = '';
  String name_id = '';
  String name_en = '';

  // String description = '';
  String description_id = '';
  String description_en = '';
  String background_image_url = '';
  Color background_color = Colors.white;
  int member_stocks_count = 0;
  List<Stock> member_stocks = List.empty(growable: true);

  //String background_color = '';
  //String member_stocks = '';

  String getName({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return name_id;
    } else {
      return name_en;
    }
  }

  String getDescription({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return description_id;
    } else {
      return description_en;
    }
  }

  /*
  "line": 1,
  "id": "1",
  "name": "Digital Banks",
  "name_id": "Bank Digital",
  "name_en": "Digital Banks",
  "description": "Disrupting the financial sector at crazy valuations",
  "description_id": "Disrupting the financial sector at crazy valuations",
  "description_en": "Disrupting the financial sector at crazy valuations",
  "background_image_url": "https://www.investrend.co.id/mobile/assets/themes/new_bg/background_1.png",
  "background_color": "#8d00f0",
  "member_stocks_count": "3",
  "member_stocks": "AGRO,ARTO,BBYB"
  */
  StockThemes(
      this.id,
      /*this.name,*/ this.name_id,
      this.name_en,
      /*this.description,*/ this.description_id,
      this.description_en,
      this.background_image_url,
      this.background_color,
      this.member_stocks_count,
      this.member_stocks);

  factory StockThemes.fromJson(Map<String, dynamic> parsedJson) {
    int id = Utils.safeInt(parsedJson['id']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String nameId = StringUtils.noNullString(parsedJson['name_id']);
    String nameEn = StringUtils.noNullString(parsedJson['name_en']);
    String description = StringUtils.noNullString(parsedJson['description']);
    String descriptionId =
        StringUtils.noNullString(parsedJson['description_id']);
    String descriptionEn =
        StringUtils.noNullString(parsedJson['description_en']);
    String backgroundImageUrl =
        StringUtils.noNullString(parsedJson['background_image_url']);
    String backgroundColorString =
        StringUtils.noNullString(parsedJson['background_color']);
    String memberStocksString =
        StringUtils.noNullString(parsedJson['member_stocks']);
    int memberStocksCount = Utils.safeInt(parsedJson['member_stocks_count']);

    Color backgroundColor = MarketColors.toColor(backgroundColorString);

    List<Stock> memberStocks = List.empty(growable: true);
    if (!StringUtils.isEmtpy(memberStocksString)) {
      List<String> datas = memberStocksString.split(',');
      //int count = datas != null ? datas.length : 0;
      if (datas != null) {
        datas.forEach((code) {
          Stock s = InvestrendTheme.storedData.findStock(code);
          if (s != null) {
            memberStocks.add(s);
          }
        });
      }
    }

    //return StockThemes(id, name, description, background_image_url, background_color, member_stocks_count, member_stocks);
    return StockThemes(
        id,
        /*name,*/
        nameId,
        nameEn,
        /* description,*/
        descriptionId,
        descriptionEn,
        backgroundImageUrl,
        backgroundColor,
        memberStocksCount,
        memberStocks);
  }

  factory StockThemes.fromXml(XmlElement element) {
    int id = Utils.safeInt(element.getAttribute('id'));
    String name = StringUtils.noNullString(element.getAttribute('name'));
    String nameId = StringUtils.noNullString(element.getAttribute('name_id'));
    String nameEn = StringUtils.noNullString(element.getAttribute('name_en'));
    String description =
        StringUtils.noNullString(element.getAttribute('description'));
    String descriptionId =
        StringUtils.noNullString(element.getAttribute('description_id'));
    String descriptionEn =
        StringUtils.noNullString(element.getAttribute('description_en'));
    String backgroundImageUrl =
        StringUtils.noNullString(element.getAttribute('background_image_url'));
    String backgroundColorString =
        StringUtils.noNullString(element.getAttribute('background_color'));
    String memberStocksString =
        StringUtils.noNullString(element.getAttribute('member_stocks'));
    int memberStocksCount =
        Utils.safeInt(element.getAttribute('member_stocks_count'));

    Color backgroundColor = MarketColors.toColor(backgroundColorString);

    List<Stock> memberStocks = List.empty(growable: true);
    if (!StringUtils.isEmtpy(memberStocksString)) {
      List<String> datas = memberStocksString.split(',');
      //int count = datas != null ? datas.length : 0;
      if (datas != null) {
        datas.forEach((code) {
          Stock s = InvestrendTheme.storedData.findStock(code);
          if (s != null) {
            memberStocks.add(s);
          }
        });
      }
    }

    //return StockThemes(id, name, description, background_image_url, background_color, member_stocks_count, member_stocks);
    return StockThemes(
        id,
        /*name, */
        nameId,
        nameEn,
        /*description,*/
        descriptionId,
        descriptionEn,
        backgroundImageUrl,
        backgroundColor,
        memberStocksCount,
        memberStocks);
  }

/*
  <a start="1" end="8"
    id="1"
    name="Digital Banks"
    description="Disrupting the financial sector at crazy valuations"
    background_image_url="https://www.investrend.co.id/mobile/assets/themes/new_bg/background_1.png"
    background_color="#8d00f0"
    member_stocks_count="18"
    member_stocks="AISA,ANTM,ASII,ASRI,BACA,BBCA,BBRI,BBTN,BDMN,BSDE,BUKA,DOID,ELSA,GGRM,LSIP,MTEK,SIAP,WSBP"
  />
  */
}

class ResultTopUpBank {
  List<TopUpBank> datas = List.empty(growable: true);
  String top_up_term_en = '';
  String top_up_term_id = '';
  bool loaded = false;

  String getTerm({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return top_up_term_id;
    } else {
      return top_up_term_en;
    }
  }

  void copyValueFrom(ResultTopUpBank newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.top_up_term_en = newValue.top_up_term_en;
      this.top_up_term_id = newValue.top_up_term_id;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.top_up_term_en = '';
      this.top_up_term_id = '';
      this.datas.clear();
    }
  }

  bool isEmpty() {
    return this.datas != null ? this.datas.isEmpty : true;
  }

  int count() {
    return this.datas != null ? this.datas.length : 0;
  }
}

class ResultFundOutTerm {
  String fund_out_term_en = '';
  String fund_out_term_id = '';
  bool loaded = false;

  ResultFundOutTerm(this.fund_out_term_en, this.fund_out_term_id);

  String getTerm({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return fund_out_term_id;
    } else {
      return fund_out_term_en;
    }
  }

  void copyValueFrom(ResultFundOutTerm newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.fund_out_term_en = newValue.fund_out_term_en;
      this.fund_out_term_id = newValue.fund_out_term_id;
    } else {
      this.fund_out_term_en = '';
      this.fund_out_term_id = '';
    }
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(fund_out_term_en) ||
        StringUtils.isEmtpy(fund_out_term_id);
  }
}

class StockHist {
  /*
  {
  "accountcode": "C35",
  "stockCode": "AGII"
  },
  */

  String accountcode = '';
  String stockCode = '';

  StockHist(this.accountcode, this.stockCode);

  factory StockHist.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String accountcode = StringUtils.noNullString(parsedJson['accountcode']);
    String stockCode = StringUtils.noNullString(parsedJson['stockCode']);

    return StockHist(accountcode, stockCode);
  }
}

class ReportStockHist {
  /*
  {
  "accountcode": "C35",
  "board": "RG",
  "bs": "B",
  "stockCode": "TAPG",
  "lot": 5000,
  "price": 670,
  "value": 335000000,
  "date": "19-04-2021"
  },
  */

  String accountcode = '';
  String board = '';
  String bs = '';
  String stockCode = '';
  int lot = 0;
  int price = 0;
  int value = 0;
  String date = '';

  ReportStockHist(this.accountcode, this.board, this.bs, this.stockCode,
      this.lot, this.price, this.value, this.date);

  factory ReportStockHist.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String accountcode = StringUtils.noNullString(parsedJson['accountcode']);
    String board = StringUtils.noNullString(parsedJson['board']);
    String bs = StringUtils.noNullString(parsedJson['bs']);
    String stockCode = StringUtils.noNullString(parsedJson['stockCode']);
    int lot = Utils.safeInt(parsedJson['lot']);
    int price = Utils.safeInt(parsedJson['price']);
    int value = Utils.safeInt(parsedJson['value']);
    String date = StringUtils.noNullString(parsedJson['date']);

    return ReportStockHist(
        accountcode, board, bs, stockCode, lot, price, value, date);
  }
}

class BankAccount {
  String acc_name = '';
  String acc_name2 = '';
  String acc_no = '';
  String acc_no2 = '';
  String bank = '';
  String bank2 = '';
  String message = '';
  bool loaded = false;

  BankAccount(this.acc_name, this.acc_name2, this.acc_no, this.acc_no2,
      this.bank, this.bank2, this.message);

  bool isMultiple() {
    return !StringUtils.isEmtpy(this.bank) && !StringUtils.isEmtpy(this.bank2);
  }

  void copyValueFrom(BankAccount newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.acc_name = newValue.acc_name;
      this.acc_name2 = newValue.acc_name2;
      this.acc_no = newValue.acc_no;
      this.acc_no2 = newValue.acc_no2;
      this.bank = newValue.bank;
      this.bank2 = newValue.bank2;
      this.message = newValue.message;
    } else {
      this.acc_name = '';
      this.acc_name2 = '';
      this.acc_no = '';
      this.acc_no2 = '';
      this.bank = '';
      this.bank2 = '';
      this.message = '';
    }
  }

  factory BankAccount.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String accName = StringUtils.noNullString(parsedJson['acc_name']);
    String accNo = StringUtils.noNullString(parsedJson['acc_no']);
    String bank = StringUtils.noNullString(parsedJson['bank']);

    String accName2 = StringUtils.noNullString(parsedJson['acc_name2']);
    String accNo2 = StringUtils.noNullString(parsedJson['acc_no2']);
    String bank2 = StringUtils.noNullString(parsedJson['bank2']);

    String message = StringUtils.noNullString(parsedJson['message']);

    return BankAccount(accName, accName2, accNo, accNo2, bank, bank2, message);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(acc_no);
  }
}

class FundamentalCache {
  String code = '';
  double last_eps = 0.0;
  double last_bvp = 0.0;
  double last_roe = 0.0;

  FundamentalCache(this.code, this.last_eps, this.last_bvp, this.last_roe);

  factory FundamentalCache.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String ticker = StringUtils.noNullString(parsedJson['code']);
    double lastEps = Utils.safeDouble(parsedJson['last_eps']);
    double lastBvp = Utils.safeDouble(parsedJson['last_bvp']);
    double lastRoe = Utils.safeDouble(parsedJson['last_roe']);

    return FundamentalCache(ticker, lastEps, lastBvp, lastRoe);
  }

  @override
  String toString() {
    return 'FundamentalCache{code: $code, last_epf: $last_eps, last_bvp: $last_bvp, last_roe: $last_roe}';
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }
}

class BankRDN {
  String acc_name = '';
  String acc_no = '';
  String bank = '';
  String message = '';
  bool loaded = false;

  BankRDN(this.acc_name, this.acc_no, this.bank, this.message);

  void copyValueFrom(BankRDN newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.acc_name = newValue.acc_name;
      this.acc_no = newValue.acc_no;
      this.bank = newValue.bank;
      this.message = newValue.message;
    } else {
      this.acc_name = '';
      this.acc_no = '';
      this.bank = '';
      this.message = '';
    }
  }

  factory BankRDN.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String accName = StringUtils.noNullString(parsedJson['acc_name']);
    String accNo = StringUtils.noNullString(parsedJson['acc_no']);
    String bank = StringUtils.noNullString(parsedJson['bank']);
    String message = StringUtils.noNullString(parsedJson['message']);

    return BankRDN(accName, accNo, bank, message);
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(acc_no);
  }
}

class TopUpBank {
  String code = '';
  String name = '';
  String icon_url = '';
  String guide_id = '';
  String guide_en = '';

  String toString() {
    return 'TopUpBank  code : $code  name : $name  icon_url : $icon_url  guide_id : $guide_id  guide_en : $guide_en';
  }

  String getGuide({String language = 'id'}) {
    if (StringUtils.equalsIgnoreCase(language, 'id')) {
      return guide_id;
    } else {
      return guide_en;
    }
  }

  TopUpBank(this.code, this.name, this.icon_url, this.guide_id, this.guide_en);

  factory TopUpBank.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String iconUrl = StringUtils.noNullString(parsedJson['icon_url']);
    String guideId = StringUtils.noNullString(parsedJson['guide_id']);
    String guideEn = StringUtils.noNullString(parsedJson['guide_en']);

    return TopUpBank(code, name, iconUrl, guideId, guideEn);
  }
}

class StringColorFont {
  String value = '';
  Color color = Colors.white;
  double fontSize = 10.0;
}

class StringColorFontBool {
  StringColorFontBool(
      {this.value = '',
      this.color = Colors.white,
      this.fontSize = 10.0,
      this.flag = false});
  String value = '';
  Color color = Colors.white;
  double fontSize = 10.0;
  bool flag = false;
}

class IntColorFont {
  int value = 0;
  Color color = Colors.white;
  double fontSize = 10.0;
}

class LoadingData {
  bool showLoading = false;
  String textLoading = '';

  void setValue(bool showLoading, String textLoading) {
    this.showLoading = showLoading;
    this.textLoading = textLoading;
  }

  @override
  String toString() {
    return 'showLoading : $showLoading  textLoading : $textLoading';
  }
}

class ActivityRDN {
  String date = '';
  String transaction = '';
  int value = 0;

  ActivityRDN(this.date, this.transaction, this.value);
}

class ActivityRDNData {
  bool loaded = false;
  List<ActivityRDN> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  void copyValueFrom(ActivityRDNData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class Portfolio {
  String code = '';
  int value = 0;
  int gainLoss = 0;
  double gainLossPercent = 0.0;
  int lot = 0;
  int average = 0;

  // market price
  int close = 0;
  int change = 0;
  double percentChange = 0.0;

  Portfolio(this.code, this.value, this.gainLoss, this.gainLossPercent,
      this.lot, this.average, this.close, this.change, this.percentChange);
}

class PortfolioData {
  bool loaded = false;
  List<Portfolio> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  void copyValueFrom(PortfolioData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class GeneralPrice {
  String code = '';
  String name = '';
  double price = 0.0;
  double change = 0.0;
  double percent = 0.0;

  //Color _defaultColor;

  GeneralPrice(this.code, this.price, this.change, this.percent,
      {this.name = ''});

  Color get priceColor => InvestrendTheme.changeTextColor(this.change);
}

class WatchlistPrice extends GeneralPrice {
  int prevPrice = 0;
  int bestBidPrice = 0;
  int bestBidVolume = 0;
  int bestOfferPrice = 0;
  int bestOfferVolume = 0;
  int value = 0;

  List<Remark2Mapping> notation = List.empty(growable: true);
  StockInformationStatus status;
  SuspendStock suspendStock;
  List<CorporateActionEvent> corporateAction = List.empty(growable: true);
  Color corporateActionColor = Colors.black;
  String attentionCodes = '';
  bool loaded = false;
  WatchlistPrice(
    String code,
    double price,
    double change,
    double percent,
    String name, {
    this.notation,
    this.corporateAction,
    this.corporateActionColor,
    this.status,
    this.suspendStock,
    this.bestBidPrice = 0,
    this.bestBidVolume = 0,
    this.bestOfferPrice = 0,
    this.bestOfferVolume = 0,
    this.prevPrice = 0,
    this.value = 0,
    this.attentionCodes,
  }) : super(code, price, change, percent, name: name);

  int bestBidLot() {
    if (bestBidVolume == 0) {
      return 0;
    }
    return bestBidVolume ~/ 100;
  }

  int bestOfferLot() {
    if (bestOfferVolume == 0) {
      return 0;
    }
    return bestOfferVolume ~/ 100;
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }

  void copyValueFrom(WatchlistPrice newValue) {
    if (newValue != null) {
      this.loaded = true;
      // this.accountcode = newValue.accountcode;
      // this.totalCost = newValue.totalCost;
      // this.totalMarket = newValue.totalMarket;
      // this.totalGL = newValue.totalGL;
      // this.totalGLPct = newValue.totalGLPct;
      // this.totalTodayGL = newValue.totalTodayGL;
      // this.totalTodayGLPct = newValue.totalTodayGLPct;
      //
      // this.stocksList.clear();
      // if (newValue.stocksList != null) {
      //   this.stocksList.addAll(newValue.stocksList);
      // }

      super.code = newValue.code;
      super.name = newValue.name;
      super.price = newValue.price;
      super.change = newValue.change;
      super.percent = newValue.percent;

      this.prevPrice = newValue.prevPrice;
      this.bestBidPrice = newValue.bestBidPrice;
      this.bestBidVolume = newValue.bestBidVolume;
      this.bestOfferPrice = newValue.bestOfferPrice;
      this.bestOfferVolume = newValue.bestOfferVolume;
      this.value = newValue.value;

      this.notation.clear();
      if (newValue.notation != null) {
        this.notation.addAll(newValue.notation);
      }

      this.status = newValue.status;
      this.suspendStock = newValue.suspendStock;
      this.corporateAction.clear();
      if (newValue.corporateAction != null) {
        this.corporateAction.addAll(newValue.corporateAction);
      }

      this.corporateActionColor = newValue.corporateActionColor;
      this.attentionCodes = newValue.attentionCodes;
    } else {
      // this.accountcode = '';
      // this.totalCost = 0;
      // this.totalMarket = 0;
      // this.totalGL = 0;
      // this.totalGLPct = 0;
      // this.totalTodayGL = 0;
      // this.totalTodayGLPct = 0;
      // this.stocksList.clear();

      super.code = '';
      super.name = '';
      super.price = 0.0;
      super.change = 0.0;
      super.percent = 0.0;

      this.prevPrice = 0;
      this.bestBidPrice = 0;
      this.bestBidVolume = 0;
      this.bestOfferPrice = 0;
      this.bestOfferVolume = 0;
      this.value = 0;

      this.notation.clear();
      this.status = null;
      this.suspendStock = null;
      this.corporateAction.clear();
      this.corporateActionColor = Colors.transparent;
      this.attentionCodes = null;
    }
  }
}

class GeneralPriceData {
  bool loaded = false;

  List<GeneralPrice> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  void copyValueFrom(GeneralPriceData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }

  bool isEmpty() {
    return count() == 0;
  }
}

class WatchlistPriceData {
  bool loaded = false;

  List<WatchlistPrice> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  void copyValueFrom(WatchlistPriceData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }

  bool isEmpty() {
    return count() == 0;
  }
}

class OrderbookData {
  bool loaded = false;
  OrderBook orderbook = OrderBook.createBasic();
  int prev = 0;
  double averagePrice = 0;
  int close = 0;

  void copyValueFrom(OrderbookData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.orderbook.copyValueFrom(newValue.orderbook);
      this.prev = newValue.prev;
      this.close = newValue.close;
      this.averagePrice = newValue.averagePrice;
    } else {
      this.orderbook = OrderBook.createBasic();
      this.prev = 0;
      this.close = 0;
      this.averagePrice = 0;
    }
  }

  bool isEmpty() {
    return orderbook.countBids() == 0 && orderbook.countOffers() == 0;
  }
}

class StockThemesData {
  bool loaded = false;
  List<StockThemes> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(StockThemesData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class HomeIndicesData {
  bool loaded = false;
  List<HomeWorldIndices> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(HomeIndicesData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class HomeCommoditiesData {
  bool loaded = false;
  List<HomeCommodities> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(HomeCommoditiesData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class HomeCurrenciesData {
  bool loaded = false;
  List<HomeCurrencies> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(HomeCurrenciesData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class HomeCryptoData {
  bool loaded = false;
  List<HomeCrypto> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(HomeCryptoData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class Version {
  String platform = '';
  String version_code = '';
  int version_number = 0;

  int minimum_version_number = 0;
  String changes_notes = '';
  String minimum_version_code = '';
  bool isEmpty() {
    return StringUtils.isEmtpy(version_code);
  }

  Version(
      this.platform,
      this.version_code,
      this.version_number,
      this.minimum_version_number,
      this.changes_notes,
      this.minimum_version_code);

  @override
  String toString() {
    return 'Version {platform: $platform, version_code: $version_code, version_number: $version_number, minimum_version_number: $minimum_version_number, changes_notes: $changes_notes, minimum_version_code: $minimum_version_code  }';
  }

  /*
  {
  "platform": "IOS",
  "version_code": "1.0.29",
  "version_number": 29,
  "minimum_version_number": 29,
  "changes_notes": "Initial Test Release"
  }
  {
    "platform": "IOS",
    "version_code": "1.0.0",
    "version_number": 29,
    "minimum_version_code": "1.0.0",
    "minimum_version_number": 29,
    "changes_notes": "New Release Available"
  }
  */

  factory Version.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String platform = StringUtils.noNullString(parsedJson['platform']);
    String versionCode = StringUtils.noNullString(parsedJson['version_code']);
    int versionNumber = Utils.safeInt(parsedJson['version_number']);
    int minimumVersionNumber =
        Utils.safeInt(parsedJson['minimum_version_number']);
    String changesNotes = StringUtils.noNullString(parsedJson['changes_notes']);
    String minimumVersionCode =
        StringUtils.noNullString(parsedJson['minimum_version_code']);

    return Version(platform, versionCode, versionNumber, minimumVersionNumber,
        changesNotes, minimumVersionCode);
  }
}

class NetBuySellSummary {
  /*
  {
  "#": 1,
  "Broker": "RX",
  "Value": "60812612500",
  "Volume": "10329100",
  "Average": "5887.50"
  },
  */
  int no = 0;
  String Broker = '';
  int Value = 0;
  int Volume = 0;
  double Average = 0.0;
  //Color color;

  bool isEmpty() {
    return StringUtils.isEmtpy(Broker);
  }

  NetBuySellSummary(
      this.no, this.Broker, this.Value, this.Volume, this.Average);

  @override
  String toString() {
    return 'BrokerNetBuySellSummary {no: $no, Broker: $Broker, Value: $Value, Volume: $Volume, Average: $Average}';
  }

  factory NetBuySellSummary.fromJson(Map<String, dynamic> parsedJson) {
    int no = parsedJson['#'];
    String Broker = StringUtils.noNullString(parsedJson['Broker']);
    //String last_date = StringUtils.noNullString(parsedJson['last_date']);
    int Value = Utils.safeInt(parsedJson['Value']);
    int Volume = Utils.safeInt(parsedJson['Volume']);
    double Average = Utils.safeDouble(parsedJson['Average']);

    return NetBuySellSummary(no, Broker, Value, Volume, Average);
  }
}

class BrokerNetBuySell {
  /*
  {
  "#": 1,
  "BrokerCode": "BK",
  "last_date": "2021-12-09",
  "BValue": "2877913107500",
  "SValue": "1880370770000",
  "NValue": "997542337500"
  },
  */

  int no = 0;
  String BrokerCode = '';
  String last_date = '';
  double BValue = 0;
  double SValue = 0;
  double NValue = 0;

  bool isEmpty() {
    return StringUtils.isEmtpy(BrokerCode);
  }

  BrokerNetBuySell(this.no, this.BrokerCode, this.last_date, this.BValue,
      this.SValue, this.NValue);

  @override
  String toString() {
    return 'BrokerNetBuySell {no: $no, BrokerCode: $BrokerCode, last_date: $last_date, BValue: $BValue, SValue: $SValue, NValue: $NValue}';
  }

  factory BrokerNetBuySell.fromJson(Map<String, dynamic> parsedJson) {
    int no = parsedJson['#'];
    String BrokerCode = StringUtils.noNullString(parsedJson['BrokerCode']);
    String lastDate = StringUtils.noNullString(parsedJson['last_date']);
    double BValue = Utils.safeDouble(parsedJson['BValue']);
    double SValue = Utils.safeDouble(parsedJson['SValue']);
    double NValue = Utils.safeDouble(parsedJson['NValue']);

    return BrokerNetBuySell(no, BrokerCode, lastDate, BValue, SValue, NValue);
  }
}

class NetBuySellSummaryData {
  String message = '';

  String code = '';
  String board = '';
  String data_by = '';
  String type = '';
  String from = '';
  String to = '';
  bool loaded = false;
  String last_date = '';
  List<NetBuySellSummary> topBuyer = List.empty(growable: true);
  List<NetBuySellSummary> topSeller = List.empty(growable: true);

  int BValue = 0;
  int BVolume = 0;
  double BAverage = 0.0;
  int SValue = 0;
  int SVolume = 0;
  double SAverage = 0.0;
  int BValueDomestic = 0;
  int BValueForeign = 0;
  int SValueDomestic = 0;
  int SValueForeign = 0;

  bool isEmpty() {
    return topBuyer != null ? topBuyer.isEmpty : true;
  }

  NetBuySellSummary getBuyer(int index) {
    int buyerCount = topBuyer == null ? 0 : topBuyer.length;
    if (index >= 0 && index < buyerCount) {
      return topBuyer.elementAt(index);
    }
    return null;
  }

  NetBuySellSummary getSeller(int index) {
    int count = topSeller == null ? 0 : topSeller.length;
    if (index >= 0 && index < count) {
      return topSeller.elementAt(index);
    }
    return null;
  }

  void copyValueFrom(NetBuySellSummaryData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.message = newValue.message;

      this.code = newValue.code;
      this.board = newValue.board;
      this.data_by = newValue.data_by;
      this.type = newValue.type;
      this.from = newValue.from;
      this.to = newValue.to;
      this.last_date = newValue.last_date;

      this.BValue = newValue.BValue;
      this.BVolume = newValue.BVolume;
      this.BAverage = newValue.BAverage;
      this.SValue = newValue.SValue;
      this.SVolume = newValue.SVolume;
      this.SAverage = newValue.SAverage;
      this.BValueDomestic = newValue.BValueDomestic;
      this.BValueForeign = newValue.BValueForeign;
      this.SValueDomestic = newValue.SValueDomestic;
      this.SValueForeign = newValue.SValueForeign;

      this.topBuyer.clear();
      this.topSeller.clear();
      if (newValue.topBuyer != null) {
        this.topBuyer.addAll(newValue.topBuyer);
      }
      if (newValue.topSeller != null) {
        this.topSeller.addAll(newValue.topSeller);
      }
    } else {
      this.message = '';
      this.code = '';
      this.board = '';
      this.data_by = '';
      this.type = '';
      this.from = '';
      this.to = '';
      this.last_date = '';

      this.BValue = 0;
      this.BVolume = 0;
      this.BAverage = 0.0;
      this.SValue = 0;
      this.SVolume = 0;
      this.SAverage = 0.0;
      this.BValueDomestic = 0;
      this.BValueForeign = 0;
      this.SValueDomestic = 0;
      this.SValueForeign = 0;

      this.topBuyer.clear();
      this.topSeller.clear();
    }
  }

  static NetBuySellSummaryData createBasic() {
    return NetBuySellSummaryData();
  }

  int count() {
    return max(this.topBuyer.length, this.topSeller.length);
  }
}

class ReportStockHistData {
  bool loaded = false;
  List<ReportStockHist> datas = List.empty(growable: true);
  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(ReportStockHistData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }

  int size() {
    return datas != null ? datas.length : 0;
  }
}

class OrderStatusData {
  bool loaded = false;
  List<OrderStatus> datas = List.empty(growable: true);
  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(OrderStatusData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }

  int size() {
    return datas != null ? datas.length : 0;
  }
}

class StockTopBrokerData {
  String code = '';
  String board = '';
  String from = '';
  String to = '';
  bool loaded = false;

  String last_date = '';

  List<BrokerNetBuySell> topBuyer = List.empty(growable: true);
  List<BrokerNetBuySell> topSeller = List.empty(growable: true);
  List<BrokerNetBuySell> topNetBuyer = List.empty(growable: true);
  List<BrokerNetBuySell> topNetSeller = List.empty(growable: true);

  bool isEmpty() {
    return topBuyer != null ? topBuyer.isEmpty : true;
  }

  void copyValueFrom(StockTopBrokerData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.board = newValue.board;
      this.from = newValue.from;
      this.to = newValue.to;
      this.last_date = newValue.last_date;
      this.topBuyer.clear();
      this.topSeller.clear();
      this.topNetBuyer.clear();
      this.topNetSeller.clear();
      if (newValue.topBuyer != null) {
        this.topBuyer.addAll(newValue.topBuyer);
      }
      if (newValue.topSeller != null) {
        this.topSeller.addAll(newValue.topSeller);
      }
      if (newValue.topNetBuyer != null) {
        this.topNetBuyer.addAll(newValue.topNetBuyer);
      }
      if (newValue.topNetSeller != null) {
        this.topNetSeller.addAll(newValue.topNetSeller);
      }
    } else {
      this.code = '';
      this.board = '';
      this.from = '';
      this.to = '';
      this.last_date = '';

      this.topBuyer.clear();
      this.topSeller.clear();
      this.topNetBuyer.clear();
      this.topNetSeller.clear();
    }
  }
}

class Performance {
  String updated = '';
  String range = '';
  String code = '';
  double change = 0;
  double percentChange = 0.0;
  double close = 0;
  double open = 0;
  double prev = 0;
  String startDate = '';
  String endDate = '';

  String toString() {
    return 'Performance  $range  $code  change : $change  percentChange : $percentChange  close : $close  open : $open  prev : $prev  startDate : $startDate  endDate : $endDate';
  }

  bool isEmpty() {
    return StringUtils.isEmtpy(code);
  }

  Performance(
      this.updated,
      this.range,
      this.code,
      this.change,
      this.percentChange,
      this.close,
      this.open,
      this.prev,
      this.startDate,
      this.endDate);

  /*
  {
  "start": 1,
  "updated": "2021-09-01 21:30:03",
  "range": "TODAY",
  "code": "COMPOSITE",
  "change": "-16.704",
  "percentChange": "-0.27",
  "close": "6074.229",
  "open": "6092.651",
  "prev": "6090.933",
  "startDate": "2021-09-02",
  "endDate": "2021-09-02",
  "calculateByCloseToday": "false"
  }
  */
  factory Performance.fromJson(Map<String, dynamic> parsedJson) {
    int start = parsedJson['start'];
    String updated = StringUtils.noNullString(parsedJson['updated']);
    String range = StringUtils.noNullString(parsedJson['range']);
    String code = StringUtils.noNullString(parsedJson['code']);
    double change = Utils.safeDouble(parsedJson['change']);
    double percentChange = Utils.safeDouble(parsedJson['percentChange']);
    double close = Utils.safeDouble(parsedJson['close']);
    double open = Utils.safeDouble(parsedJson['open']);
    double prev = Utils.safeDouble(parsedJson['prev']);
    String startDate = StringUtils.noNullString(parsedJson['startDate']);
    String endDate = StringUtils.noNullString(parsedJson['endDate']);
    return Performance(updated, range, code, change, percentChange, close, open,
        prev, startDate, endDate);
  }
}

class PerformanceData {
  String code = '';
  String type = '';
  bool loaded = false;
  Map<String, Performance> _map = Map();

  Map<String, Performance> get map => _map;

  bool isEmpty() {
    return _map != null ? _map.isEmpty : true;
  }

  Performance _emptyPerformance =
      Performance('', '', '', 0, 0, 0, 0, 0, '', '');

  void addPerformance(Performance performance) {
    if (performance != null) {
      //_datas.add(performance);
      // if(_map.containsKey(performance.range)){
      //   _map.update(key, (value) => null);
      // }
      _map.update(
        performance.range,
        // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
        (existingValue) => performance,
        ifAbsent: () => performance,
      );
    }
  }

  Performance getPerformance(String range) {
    if (range != null && _map.containsKey(range)) {
      return _map[range];
    }
    return _emptyPerformance;
  }

  void copyValueFrom(PerformanceData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.type = newValue.type;
      this._map.clear();
      if (newValue.map != null) {
        this._map.addAll(newValue.map);
      }
    } else {
      this.code = '';
      this.type = '';
      this._map.clear();
    }
  }
}

class Line {
  double close = 0;

  //double prev = 0;
  DateTime date;
  DateTime time;
  static DateFormat dateFormat = new DateFormat('yyyy-MM-dd');

  Line(this.close, this.date, this.time);

  factory Line.fromJson(Map<String, dynamic> parsedJson) {
    int start = parsedJson['start'];
    DateTime time;
    String close = StringUtils.noNullString(parsedJson['close']);
    String vol = StringUtils.noNullString(parsedJson['vol']);

    try {
      time = dateFormat.parse(parsedJson['time']);
    } catch (e) {
      String _timeData = parsedJson['time'];
      List<int> _time =
          _timeData.split(':').toList().map((e) => int.parse(e)).toList();
      time = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, _time[0], _time[1]);
    }
    return Line(Utils.safeDouble(close), time, time);
  }

  factory Line.fromXml(XmlElement element) {
    double close = Utils.safeDouble(element.getAttribute('close'));
    DateTime time;
    try {
      time = dateFormat.parse(element.getAttribute('time'));
    } catch (e) {
      String _timeData = element.getAttribute('time');
      List<int> _time =
          _timeData.split(':').toList().map((e) => int.parse(e)).toList();
      time = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, _time[0], _time[1]);
    }
    //<a start="1" end="58" time="04:04" close="6007.12" vol="0"/>
    // return Line(double.parse(element.getAttribute('close')),
    //     element.getAttribute('time'), element.getAttribute('time'));
    return Line(close, time, time);
  }

  @override
  String toString() {
    return 'Line [close : $close]  [date : $date]  [time : $time]';
  }
}

class Ohlcv {
  double open = 0;
  double hi = 0;
  double low = 0;
  double close = 0;
  int vol = 0;

  //double prev = 0;
  DateTime date;
  DateTime time;
  static DateFormat dateFormat = new DateFormat('yyyy-MM-dd');

  Ohlcv(
      this.open, this.hi, this.low, this.close, this.vol, this.date, this.time);

  factory Ohlcv.fromJson(Map<String, dynamic> parsedJson) {
    int start = parsedJson['#'];
    DateTime time = dateFormat.parse(parsedJson['time'] as String);
    double open = Utils.safeDouble(parsedJson['open']);
    double hi = Utils.safeDouble(parsedJson['hi']);
    double low = Utils.safeDouble(parsedJson['low']);
    double close = Utils.safeDouble(parsedJson['close']);
    int vol = Utils.safeInt(parsedJson['vol']);

    //time itu date
    return Ohlcv(open, hi, low, close, vol, time, time);
  }

  factory Ohlcv.fromXml(XmlElement element) {
    //<a start="1" end="58" time="04:04" close="6007.12" vol="0"/>

    DateTime time = dateFormat.parse(element.getAttribute('time') as String);
    double open = Utils.safeDouble(element.getAttribute('open'));
    double hi = Utils.safeDouble(element.getAttribute('hi'));
    double low = Utils.safeDouble(element.getAttribute('low'));
    double close = Utils.safeDouble(element.getAttribute('close'));
    int vol = Utils.safeInt(element.getAttribute('vol'));

    //return Ohlcv(double.parse(element.getAttribute('close')), element.getAttribute('time'), element.getAttribute('time'));
    return Ohlcv(open, hi, low, close, vol, time, time);
  }

  @override
  String toString() {
    return 'Ohlcv {open: $open, hi: $hi, low: $low, close: $close, vol: $vol, date: $date, time: $time}';
  }
}

class ChartOhlcvData {
  Ohlcv ohlcvData;
  String code = '';
  String from = '';
  String to = '';
  double maxValue = 0;
  double minValue = 0;
  double prevValue = 0;

  void setRequestType(String _code, String _from, String _to) {
    this.code = _code;
    this.from = _from;
    this.to = _to;
  }

  bool isValidResponse(String _code, String _from, String _to) {
    bool codeValid = StringUtils.equalsIgnoreCase(_code, this.code);
    if (!codeValid) {
      return false;
    }
    bool fromValid = /*(_from == null && this.from == null) ||*/ StringUtils
        .equalsIgnoreCase(_from, this.from);
    if (!fromValid) {
      return false;
    }
    bool toValid = /* (_to == null && this.to == null) || */ StringUtils
        .equalsIgnoreCase(_to, this.to);
    if (!toValid) {
      return false;
    }
    return true;
  }

  bool loaded = false;

  //data nya disini dari ohlcv
  List<Ohlcv> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  Ohlcv elemetAt(int index) {
    if (index < count()) {
      return datas.elementAt(index);
    }
    return null;
  }

  Ohlcv last() {
    if (count() > 0) {
      return datas.last;
    }
    return null;
  }

  void addOhlcv(Ohlcv o) {
    if (o != null) {
      maxValue = max(o.open, maxValue);
      maxValue = max(o.hi, maxValue);
      maxValue = max(o.low, maxValue);

      maxValue = max(o.close, maxValue);
      //maxValue = max(o.prev, maxValue);

      if (minValue == 0) {
        minValue = o.close;
      } else {
        //minValue = o.open > 0 ? min(o.open, minValue) : minValue;
        //minValue = o.hi > 0 ? min(o.hi, minValue) : minValue;
        minValue = o.low > 0 ? min(o.low, minValue) : minValue;

        //minValue = o.close > 0 ? min(o.close, minValue) : minValue;

      }
      datas.add(o);
    }
  }

  void normalize({bool middlePrev = false}) {
    if (middlePrev && prevValue > 0) {
      double gapUpper = maxValue - prevValue;
      double gapLower = prevValue - minValue;
      double gap = max(gapUpper.abs(), gapLower.abs());
      if (gap == 0) {
        gap = prevValue * 0.5;
      }
      if (gapUpper <= 0 || gapUpper < gap) {
        maxValue = prevValue + gap;
      }

      if (gapLower <= 0 || gapLower < gap) {
        minValue = prevValue - gap;
      }

      maxValue = prevValue + gap;
      minValue = prevValue - gap;
    } else {
      if (maxValue == minValue) {
        maxValue = maxValue * 1.5;
        minValue = minValue * 0.5;
      }
    }

    print(
        'normalize middlePrev : $middlePrev  prevValue : $prevValue  minValue : $minValue  maxValue : $maxValue');
  }

  void setPrev(
    double _prev,
    /*{bool middlePrev = false} */
  ) {
    this.prevValue = _prev;
    minValue = this.prevValue > 0 ? min(this.prevValue, minValue) : minValue;
    maxValue = max(this.prevValue, maxValue);

    if ((maxValue - maxValue) <= 2) {
      maxValue++;
    }
  }

  void copyValueFrom(ChartOhlcvData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.maxValue = newValue.maxValue;
      this.minValue = newValue.minValue;
      this.prevValue = newValue.prevValue;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
      this.maxValue = 0;
      this.minValue = 0;
      this.prevValue = 0;
    }
  }

  @override
  String toString() {
    return 'ChartOhlcvData count : ' +
        count().toString() +
        '  maxValue : $maxValue  minValue : $minValue  prevValue : $prevValue';
  }

  bool isEmpty() {
    return count() == 0;
  }
}

class ChartLineData {
  String code = '';
  String from = '';
  String to = '';
  double maxValue = 0;
  double minValue = 0;
  double prevValue = 0;

  void setRequestType(String _code, String _from, String _to) {
    this.code = _code;
    this.from = _from;
    this.to = _to;
  }

  bool isValidResponse(String _code, String _from, String _to) {
    bool codeValid = StringUtils.equalsIgnoreCase(_code, this.code);
    if (!codeValid) {
      return false;
    }
    bool fromValid = /*(_from == null && this.from == null) ||*/ StringUtils
        .equalsIgnoreCase(_from, this.from);
    if (!fromValid) {
      return false;
    }
    bool toValid = /* (_to == null && this.to == null) || */ StringUtils
        .equalsIgnoreCase(_to, this.to);
    if (!toValid) {
      return false;
    }
    return true;
  }

  bool loaded = false;
  List<Line> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  Line elemetAt(int index) {
    if (index < count()) {
      return datas.elementAt(index);
    }
    return null;
  }

  Line last() {
    if (count() > 0) {
      return datas.last;
    }
    return null;
  }

  void addOhlcv(Line o) {
    if (o != null) {
      maxValue = max(o.close, maxValue);
      //maxValue = max(o.prev, maxValue);

      if (minValue == 0) {
        minValue = o.close;
        //minValue = o.prev > 0 ? min(o.prev, minValue) : minValue;
      } else {
        minValue = o.close > 0 ? min(o.close, minValue) : minValue;
        //minValue = o.prev > 0 ? min(o.prev, minValue) : minValue;
      }
      datas.add(o);
    }
  }

  void normalize({bool middlePrev = false}) {
    if (middlePrev && prevValue > 0) {
      double gapUpper = maxValue - prevValue;
      double gapLower = prevValue - minValue;
      double gap = max(gapUpper.abs(), gapLower.abs());
      if (gap == 0) {
        gap = prevValue * 0.5;
      }
      if (gapUpper <= 0 || gapUpper < gap) {
        maxValue = prevValue + gap;
      }

      if (gapLower <= 0 || gapLower < gap) {
        minValue = prevValue - gap;
      }

      maxValue = prevValue + gap;
      minValue = prevValue - gap;

      /*


      if(prevValue == maxValue){

      }
      if(maxValue == minValue){
        if(prevValue > 0){
          if(prevValue == maxValue){
            maxValue = prevValue * 1.5;
            minValue = prevValue * 0.5;
          }else if(prevValue < maxValue){
            double gap = (maxValue - prevValue).abs();
            minValue = prevValue - gap;
          }else if(prevValue > maxValue){
            double gap = (prevValue - maxValue).abs();
            maxValue = prevValue + gap;
          }
        }else{
          maxValue = maxValue * 1.5;
          minValue = minValue * 0.5;
        }
      }
      */
    } else {
      if (maxValue == minValue) {
        maxValue = maxValue * 1.5;
        minValue = minValue * 0.5;
      }
    }

    print(
        'normalize middlePrev : $middlePrev  prevValue : $prevValue  minValue : $minValue  maxValue : $maxValue');
  }

  void setPrev(
    double _prev,
    /*{bool middlePrev = false} */
  ) {
    this.prevValue = _prev;
    minValue = this.prevValue > 0 ? min(this.prevValue, minValue) : minValue;
    maxValue = max(this.prevValue, maxValue);

    //normalize(middlePrev: middlePrev);

    /*
    if(middlePrev){
      print('setPrev before middlePrev : $middlePrev  prevValue : $prevValue  minValue : $minValue  maxValue : $maxValue');
      double gapUpper = prevValue - maxValue;
      double gapLower = prevValue - minValue;
      //gapUpper = gapUpper.abs();
      //gapLower = Utils.absDouble(gapLower);
      double gap = max(gapUpper.abs(), gapLower.abs());
      maxValue = prevValue + gap;
      minValue = prevValue - gap;


      print('after middlePrev : $middlePrev  prevValue : $prevValue  minValue : $minValue  maxValue : $maxValue');

      // if(_datas?.isNotEmpty){
      //   Line first =  _datas.first;
      //   if(first != null){
      //     Line prevAsFirstLine = Line(this.prevValue, first.date, first.time);
      //     _datas.insert(0, prevAsFirstLine);
      //   }
      // }

    }
    if(maxValue == minValue){
      maxValue = prevValue * 1.5;
      minValue = prevValue * 0.5;
    }
    */
  }

  void copyValueFrom(ChartLineData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.maxValue = newValue.maxValue;
      this.minValue = newValue.minValue;
      this.prevValue = newValue.prevValue;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
      this.maxValue = 0;
      this.minValue = 0;
      this.prevValue = 0;
    }
  }

  @override
  String toString() {
    return 'ChartLineData count : ' +
        count().toString() +
        '  maxValue : $maxValue  minValue : $minValue  prevValue : $prevValue';
  }

  bool isEmpty() {
    return count() == 0;
  }
}

class LabelValueDivider {
  bool _isDivider = true;

  bool isDivider() {
    return _isDivider;
  }
}

class LabelValue extends LabelValueDivider {
  String _label;
  String _value;
  Color valueColor;

  LabelValue(this._label, this._value, {this.valueColor});

  //Color get valueColor => _valueColor;

  String get value => _value;

  String get label => _label;

  bool isDivider() {
    return false;
  }
}

class ContentPlaceInfo extends LabelValueDivider {
  String _type;
  String _time;
  String _place1;
  String _place2;

  ContentPlaceInfo(this._type, this._time, this._place1, this._place2);

  String get type => _type;

  bool isDivider() {
    return false;
  }

  String get time => _time;

  String get place1 => _place1;

  String get place2 => _place2;
}

class LabelValueSubtitle extends LabelValueDivider {
  String _label;

  LabelValueSubtitle(this._label);

  String get label => _label;

  bool isDivider() {
    return false;
  }
}

class DynamicContent {
  String text_1 = '';
  String text_2 = '';
  String text_3 = '';
  Color color;

  DynamicContent(this.text_1, this.text_2, this.text_3, {this.color});

  bool isDivider() {
    return StringUtils.equalsIgnoreCase(text_1, '-');
  }

  bool isSubtitle() {
    return !StringUtils.equalsIgnoreCase(text_1, '-') &&
        StringUtils.equalsIgnoreCase(text_2, '-') &&
        StringUtils.equalsIgnoreCase(text_3, '-');
  }

  factory DynamicContent.fromJson(List<dynamic> data) {
    // if(data == null){
    //   return null;
    // }
    // print('DynamicContent.fromJson 00');
    // //List data = parsedJson as List;
    print('DynamicContent.fromJson 00');
    if (data == null || data.length < 4) {
      return null;
    }
    print('DynamicContent.fromJson AA');
    String text_1 = StringUtils.noNullString(data.elementAt(0));
    String text_2 = StringUtils.noNullString(data.elementAt(1));
    String text_3 = StringUtils.noNullString(data.elementAt(2));
    String colorText = StringUtils.noNullString(data.elementAt(3));
    print('DynamicContent.fromJson BB');
    if (StringUtils.equalsIgnoreCase(colorText, 'GREEN')) {
      return DynamicContent(text_1, text_2, text_3,
          color: InvestrendTheme.greenText);
    } else if (StringUtils.equalsIgnoreCase(colorText, 'RED')) {
      return DynamicContent(text_1, text_2, text_3,
          color: InvestrendTheme.redText);
    } else if (StringUtils.equalsIgnoreCase(colorText, 'YELLOW')) {
      return DynamicContent(text_1, text_2, text_3,
          color: InvestrendTheme.yellowText);
    }
    return DynamicContent(text_1, text_2, text_3);
  }
}

class DataCompanyProfile {
  String code = '';

  //dataHistory
  String listing_date = '';
  String effective_date = '';
  String nominal = '';
  String ipo_price = '';
  String ipo_shares = '';
  String ipo_amount = '';
  List<String> underwriter_list = List.empty(growable: true);
  List<String> share_registrar_list = List.empty(growable: true);

  //dataShareholders
  String additionalInfo = '';
  List<DynamicContent> contentList = List<DynamicContent>.empty(growable: true);

  //dataCommisioners
  List<String> president_commissioner_list = List.empty(growable: true);
  List<String> vice_president_commissioner_list = List.empty(growable: true);
  List<String> commissioner_list = List.empty(growable: true);
  List<String> president_director_list = List.empty(growable: true);
  List<String> vice_president_director_list = List.empty(growable: true);
  List<String> director_list = List.empty(growable: true);

  bool loaded = false;

  int countUnderwriter() {
    return underwriter_list != null ? underwriter_list.length : 0;
  }

  int countShareRegistrar() {
    return share_registrar_list != null ? share_registrar_list.length : 0;
  }

  int countContentList() {
    return contentList != null ? contentList.length : 0;
  }

  int countPresidentCommissioner() {
    return president_commissioner_list != null
        ? president_commissioner_list.length
        : 0;
  }

  int countVicePresidentCommissioner() {
    return vice_president_commissioner_list != null
        ? vice_president_commissioner_list.length
        : 0;
  }

  int countCommissioner() {
    return commissioner_list != null ? commissioner_list.length : 0;
  }

  int countPresidentDirector() {
    return president_director_list != null ? president_director_list.length : 0;
  }

  int countVicePresidentDirector() {
    return vice_president_director_list != null
        ? vice_president_director_list.length
        : 0;
  }

  int countDirectorList() {
    return director_list != null ? director_list.length : 0;
  }

  DataCompanyProfile(
      this.code,
      this.listing_date,
      this.effective_date,
      this.nominal,
      this.ipo_price,
      this.ipo_shares,
      this.ipo_amount,
      this.underwriter_list,
      this.share_registrar_list,
      this.additionalInfo,
      this.contentList,
      this.president_commissioner_list,
      this.vice_president_commissioner_list,
      this.commissioner_list,
      this.president_director_list,
      this.vice_president_director_list,
      this.director_list);

  bool isEmpty() {
    return code != null ? code.isEmpty : false;
  }

  void copyValueFrom(DataCompanyProfile newValue) {
    if (newValue != null) {
      this.loaded = true;

      this.code = newValue.code;

      //dataHistory
      this.listing_date = newValue.listing_date;
      this.effective_date = newValue.effective_date;
      this.nominal = newValue.nominal;
      this.ipo_price = newValue.ipo_price;
      this.ipo_shares = newValue.ipo_shares;
      this.ipo_amount = newValue.ipo_amount;
      this.underwriter_list.clear();
      if (newValue.underwriter_list != null) {
        this.underwriter_list.addAll(newValue.underwriter_list);
      }
      this.share_registrar_list.clear();
      if (newValue.share_registrar_list != null) {
        this.share_registrar_list.addAll(newValue.share_registrar_list);
      }

      //dataShareholders
      this.additionalInfo = newValue.additionalInfo;
      this.contentList.clear();
      if (newValue.contentList != null) {
        this.contentList.addAll(newValue.contentList);
      }

      //dataCommisioners
      this.president_commissioner_list.clear();
      if (newValue.president_commissioner_list != null) {
        this
            .president_commissioner_list
            .addAll(newValue.president_commissioner_list);
      }
      this.vice_president_commissioner_list.clear();
      if (newValue.vice_president_commissioner_list != null) {
        this
            .vice_president_commissioner_list
            .addAll(newValue.vice_president_commissioner_list);
      }
      this.commissioner_list.clear();
      if (newValue.commissioner_list != null) {
        this.commissioner_list.addAll(newValue.commissioner_list);
      }
      this.president_director_list.clear();
      if (newValue.president_director_list != null) {
        this.president_director_list.addAll(newValue.president_director_list);
      }
      this.vice_president_director_list.clear();
      if (newValue.vice_president_director_list != null) {
        this
            .vice_president_director_list
            .addAll(newValue.vice_president_director_list);
      }
      this.director_list.clear();
      if (newValue.director_list != null) {
        this.director_list.addAll(newValue.director_list);
      }
    } else {
      this.code = '';

      //dataHistory
      this.listing_date = '';
      this.effective_date = '';
      this.nominal = '';
      this.ipo_price = '';
      this.ipo_shares = '';
      this.ipo_amount = '';
      this.underwriter_list.clear();
      this.share_registrar_list.clear();

      //dataShareholders
      this.additionalInfo = '';
      this.contentList.clear();

      //dataCommisioners
      this.president_commissioner_list.clear();
      this.vice_president_commissioner_list.clear();
      this.commissioner_list.clear();
      this.president_director_list.clear();
      this.vice_president_director_list.clear();
      this.director_list.clear();
    }
  }

  static DataCompanyProfile createBasic() {
    String code = '';

    //dataHistory
    String listingDate = '';
    String effectiveDate = '';
    String nominal = '';
    String ipoPrice = '';
    String ipoShares = '';
    String ipoAmount = '';
    List<String> underwriterList = List.empty(growable: true);
    List<String> shareRegistrarList = List.empty(growable: true);

    //dataShareholders
    String additionalInfo = '';
    List<DynamicContent> contentList =
        List<DynamicContent>.empty(growable: true);

    //dataCommisioners
    List<String> presidentCommissionerList = List.empty(growable: true);
    List<String> vicePresidentCommissionerList = List.empty(growable: true);
    List<String> commissionerList = List.empty(growable: true);
    List<String> presidentDirectorList = List.empty(growable: true);
    List<String> vicePresidentDirectorList = List.empty(growable: true);
    List<String> directorList = List.empty(growable: true);
    return DataCompanyProfile(
        code,
        listingDate,
        effectiveDate,
        nominal,
        ipoPrice,
        ipoShares,
        ipoAmount,
        underwriterList,
        shareRegistrarList,
        additionalInfo,
        contentList,
        presidentCommissionerList,
        vicePresidentCommissionerList,
        commissionerList,
        presidentDirectorList,
        vicePresidentDirectorList,
        directorList);
  }
}

class LabelValuePercent extends LabelValue {
  String _valuePercent;
  Color valuePercentColor;

  LabelValuePercent(
    String label,
    String value,
    this._valuePercent, {
    Color valueColor,
    this.valuePercentColor,
  }) : super(label, value, valueColor: valueColor);

  String get valuePercent => _valuePercent;
}

class LabelValueData {
  bool loaded = false;
  List<LabelValueDivider> datas = List.empty(growable: true);
  String additionalInfo = '';

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return count() <= 0;
  }

  void copyValueFrom(LabelValueData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      // newValue.datas.forEach((element) {
      //   this.datas.add(element);
      // });
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
      this.additionalInfo = newValue.additionalInfo;
    } else {
      this.datas.clear();
      this.additionalInfo = '';
    }
  }
}

abstract class CorporateAction {
  String code = '';
  String year = '';

  CorporateAction(this.code, this.year);

  String caType();
}

/*
class CADividend extends CorporateAction {
  int totalValue = 0;
  int price = 0;
  String cumDate = '';
  String exDate = '';
  String recordingDate = '';
  String paymentDate = '';

  CADividend(this.totalValue, this.price, this.cumDate, this.exDate, this.recordingDate, this.paymentDate, String year) : super(year);

  @override
  String caType() {
    return 'Dividend';
  }
}

class CARightIssue extends CorporateAction {
  int ratio1 = 0;
  int ratio2 = 0;
  double ratioPercentage = 0.0;
  int price = 0;
  String cumDate = '';
  String exDate = '';
  String recordingDate = '';
  String tradingStart = '';
  String tradingEnd = '';
  String subscriptionDate = '';

  //String year = '';

  CARightIssue(this.ratio1, this.ratio2, this.ratioPercentage, this.price, this.cumDate, this.exDate, this.recordingDate, this.tradingStart,
      this.tradingEnd, this.subscriptionDate, String year)
      : super(year);

  @override
  String caType() {
    return 'Right Issue';
  }
}

class CARups extends CorporateAction {
  String type = ''; //RUPST RUPSLB
  String dateTime = '';
  String address = '';
  String city = '';

  CARups(this.type, this.dateTime, this.address, this.city, String year) : super(year);

  @override
  String caType() {
    return 'RUPS';
  }
}

class CAStockSplit extends CorporateAction {
  int ratio1 = 0;
  int ratio2 = 0;
  double ratioPercentage = 0.0;
  String cumDate = '';
  String exDate = '';
  String recordingDate = '';
  String tradingDate = '';

  CAStockSplit(this.ratio1, this.ratio2, this.ratioPercentage, this.cumDate, this.exDate, this.recordingDate, this.tradingDate, String year)
      : super(year);

  @override
  String caType() {
    return 'Stock Split';
  }
}
*/
class CorporateActionData {
  bool loaded = false;
  String code = '';
  String type = '';
  List<CorporateAction> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  void addData(CorporateAction ca) {
    datas.add(ca);
  }

  @override
  String toString() {
    return '[CorporateActionData  code : $code  type : $type  datas.count : ' +
        count().toString() +
        ']';
  }

  void copyValueFrom(CorporateActionData newValue) {
    if (newValue != null) {
      this.loaded = true;

      this.code = newValue.code;
      this.type = newValue.type;

      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.code = '';
      this.type = '';
      this.datas.clear();
    }
  }

  bool isEmpty() {
    return count() <= 0;
  }
}

class NewsData {
  bool loaded = false;
  List<News> datas = List.empty(growable: true);

  int count() {
    return datas != null ? datas.length : 0;
  }

  bool isEmpty() {
    return datas != null ? datas.isEmpty : true;
  }

  void copyValueFrom(NewsData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.datas.clear();
      if (newValue.datas != null) {
        this.datas.addAll(newValue.datas);
      }
    } else {
      this.datas.clear();
    }
  }
}

class DataChartTopBrokerNet {
  List<YearValue> netData = List.empty(growable: true);
  bool loaded = false;

  DataChartTopBrokerNet(this.netData);

  bool isEmpty() {
    return netData != null ? netData.isEmpty : false;
  }

  static DataChartTopBrokerNet createBasic() {
    List<YearValue> netData = List.empty(growable: true);
    return DataChartTopBrokerNet(netData);
  }

  void copyValueFrom(DataChartTopBrokerNet newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.netData.clear();
      if (newValue.netData != null) {
        this.netData.addAll(newValue.netData);
      }
    } else {
      this.netData.clear();
    }
  }
}

class DataChartTopBroker {
  // String code = '';
  // String board = '';
  // String type = ''; // Buyer Seller
  // String from = '';
  // String to = '';
  List<YearValue> buyData = List.empty(growable: true);
  List<YearValue> sellData = List.empty(growable: true);

  //List<YearValue> netData = List.empty(growable: true);
  bool loaded = false;

  DataChartTopBroker(
      /*this.code, this.board, this.type, this.from, this.to,*/ this.buyData,
      this.sellData);

  bool isEmpty() {
    return buyData != null ? buyData.isEmpty : false;
  }

  static DataChartTopBroker createBasic() {
    // String code = '';
    // String board = '';
    // String type = ''; // Buyer Seller
    // String from = '';
    // String to = '';

    List<YearValue> buyData = List.empty(growable: true);
    List<YearValue> sellData = List.empty(growable: true);

    return DataChartTopBroker(
        /*code, board, type, from, to,*/ buyData, sellData);
  }

  void copyValueFrom(DataChartTopBroker newValue) {
    if (newValue != null) {
      this.loaded = true;
      // this.code = newValue.code;
      // this.board = newValue.board;
      // this.type = newValue.type;
      // this.from = newValue.from;
      // this.to = newValue.to;

      this.buyData.clear();
      this.sellData.clear();
      if (newValue.buyData != null) {
        this.buyData.addAll(newValue.buyData);
      }

      if (newValue.sellData != null) {
        this.sellData.addAll(newValue.sellData);
      }
    } else {
      // this.code = '';
      // this.board = '';
      // this.type = '';
      // this.from = '';
      // this.to = '';
      this.buyData.clear();
      this.sellData.clear();
    }
  }
}

class DataChartIncomeStatement {
  String code = '';
  String type = ''; // INCOME_STATEMENT
  String show_as = ''; // YEARLY or QUARTERLY
  List<String> label = List.empty(growable: true);
  List<YearValue> net_income = List.empty(growable: true);
  List<YearValue> revenue = List.empty(growable: true);
  List<YearValue> net_profit_margin = List.empty(growable: true);

  double max_net_income = 0.0;
  double min_net_income = 0.0;

  double max_revenue = 0.0;
  double min_revenue = 0.0;

  double max_net_profit_margin = 0.0;
  double min_net_profit_margin = 0.0;

  bool loaded = false;

  bool isEmpty() {
    return label != null ? label.isEmpty : false;
  }

  DataChartIncomeStatement(
      this.code,
      this.type,
      this.show_as,
      this.label,
      this.net_income,
      this.revenue,
      this.net_profit_margin,
      this.max_net_income,
      this.min_net_income,
      this.max_revenue,
      this.min_revenue,
      this.max_net_profit_margin,
      this.min_net_profit_margin);

  static DataChartIncomeStatement createBasic() {
    String code = '';
    String type = ''; // INCOME_STATEMENT
    String showAs = ''; // YEARLY or QUARTERLY

    List<String> label = List.empty(growable: true);
    List<YearValue> netIncome = List.empty(growable: true);
    List<YearValue> revenue = List.empty(growable: true);
    List<YearValue> netProfitMargin = List.empty(growable: true);

    return DataChartIncomeStatement(code, type, showAs, label, netIncome,
        revenue, netProfitMargin, 0, 0, 0, 0, 0, 0);
  }

  factory DataChartIncomeStatement.fromJson(Map<String, dynamic> parsedJson,
      String code, String type, String showAs) {
    if (parsedJson == null) {
      return null;
    }
    var label = parsedJson['label'] as List;
    var netIncome = parsedJson['net_income'] as List;
    var revenue = parsedJson['revenue'] as List;
    var netProfitMargin = parsedJson['net_profit_margin'] as List;

    List<String> labelList = List.empty(growable: true);
    List<YearValue> netIncomeList = List.empty(growable: true);
    List<YearValue> revenueList = List.empty(growable: true);
    List<YearValue> netProfitMarginList = List.empty(growable: true);

    double maxNetIncome = 0.0;
    double minNetIncome;

    double maxRevenue = 0.0;
    double minRevenue;

    double maxNetProfitMargin = 0.0;
    double minNetProfitMargin;

    if (label != null && label.isNotEmpty) {
      int countLabel = label != null ? label.length : 0;
      int countNetIncome = netIncome != null ? netIncome.length : 0;
      int countRevenue = revenue != null ? revenue.length : 0;
      int countNetProfitMargin =
          netProfitMargin != null ? netProfitMargin.length : 0;

      for (int i = 0; i < countLabel; i++) {
        String year = label.elementAt(i).toString();
        labelList.add(year);

        double valueNetIncome =
            i < countNetIncome ? Utils.safeDouble(netIncome.elementAt(i)) : 0.0;
        double valueRevenue =
            i < countRevenue ? Utils.safeDouble(revenue.elementAt(i)) : 0.0;
        double valueNetProfitMargin = i < countNetProfitMargin
            ? Utils.safeDouble(netProfitMargin.elementAt(i))
            : 0.0;

        maxNetIncome = max(maxNetIncome, valueNetIncome);
        if (minNetIncome == null) {
          minNetIncome = valueNetIncome;
        } else {
          minNetIncome = min(minNetIncome, valueNetIncome);
        }

        maxNetProfitMargin = max(maxNetProfitMargin, valueNetProfitMargin);
        if (minNetProfitMargin == null) {
          minNetProfitMargin = valueNetProfitMargin;
        } else {
          minNetProfitMargin = min(minNetProfitMargin, valueNetProfitMargin);
        }

        maxRevenue = max(maxRevenue, valueRevenue);
        if (minRevenue == null) {
          minRevenue = valueRevenue;
        } else {
          minRevenue = min(minRevenue, valueRevenue);
        }

        //min_net_income = value_net_income > 0.0 ? min(min_net_income, value_net_income) : value_net_income;

        netIncomeList.add(new YearValue(year, valueNetIncome));
        revenueList.add(new YearValue(year, valueRevenue));
        netProfitMarginList.add(new YearValue(year, valueNetProfitMargin));

        // net_income_list.add(new YearValue(year, i < count_net_income ? Utils.safeDouble(net_income.elementAt(i)) : 0.0));
        // revenue_list.add(new YearValue(year, i < count_revenue ? Utils.safeDouble(revenue.elementAt(i)) : 0.0));
        // net_profit_margin_list.add(new YearValue(year, i < count_net_profit_margin ? Utils.safeDouble(net_profit_margin.elementAt(i)) : 0.0));
      }
    }

    minNetIncome = minNetIncome ?? 0;
    minRevenue = minRevenue ?? 0;
    minNetProfitMargin = minNetProfitMargin ?? 0;

    return DataChartIncomeStatement(
        code,
        type,
        showAs,
        labelList,
        netIncomeList,
        revenueList,
        netProfitMarginList,
        maxNetIncome,
        minNetIncome,
        maxRevenue,
        minRevenue,
        maxNetProfitMargin,
        minNetProfitMargin);
  }

  void copyValueFrom(DataChartIncomeStatement newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.type = newValue.type;
      this.show_as = newValue.show_as;

      this.label.clear();
      this.net_income.clear();
      this.revenue.clear();
      this.net_profit_margin.clear();

      if (newValue.label != null) {
        this.label.addAll(newValue.label);
      }

      if (newValue.net_income != null) {
        this.net_income.addAll(newValue.net_income);
      }

      if (newValue.revenue != null) {
        this.revenue.addAll(newValue.revenue);
      }

      if (newValue.net_profit_margin != null) {
        this.net_profit_margin.addAll(newValue.net_profit_margin);
      }
    } else {
      this.code = '';
      this.type = ''; // INCOME_STATEMENT
      this.show_as = ''; // YEARLY or QUARTERLY
      this.label.clear();
      this.net_income.clear();
      this.revenue.clear();
      this.net_profit_margin.clear();
    }
  }
}

class DataChartBalanceSheet {
  String code = '';
  String type = ''; // BALANCE_SHEET
  String show_as = ''; // YEARLY or QUARTERLY
  List<String> label = List.empty(growable: true);
  List<YearValue> equity = List.empty(growable: true);
  List<YearValue> liabilities = List.empty(growable: true);
  List<YearValue> assets = List.empty(growable: true);
  List<YearValue> debt_equity_ratio = List.empty(growable: true);
  bool loaded = false;

  bool isEmpty() {
    return label != null ? label.isEmpty : false;
  }

  DataChartBalanceSheet(this.code, this.type, this.show_as, this.label,
      this.equity, this.liabilities, this.assets, this.debt_equity_ratio);

  static DataChartBalanceSheet createBasic() {
    String code = '';
    String type = ''; // BALANCE_SHEET
    String showAs = ''; // YEARLY or QUARTERLY

    List<String> label = List.empty(growable: true);
    List<YearValue> equity = List.empty(growable: true);
    List<YearValue> liabilities = List.empty(growable: true);
    List<YearValue> assets = List.empty(growable: true);
    List<YearValue> debtEquityRatio = List.empty(growable: true);

    return DataChartBalanceSheet(code, type, showAs, label, equity, liabilities,
        assets, debtEquityRatio);
  }

  factory DataChartBalanceSheet.fromJson(Map<String, dynamic> parsedJson,
      String code, String type, String showAs) {
    if (parsedJson == null) {
      return null;
    }
    var label = parsedJson['label'] as List;
    var equity = parsedJson['equity'] as List;
    var liabilities = parsedJson['liabilities'] as List;
    var assets = parsedJson['assets'] as List;
    var debtEquityRatio = parsedJson['debt_equity_ratio'] as List;

    List<String> labelList = List.empty(growable: true);
    List<YearValue> equityList = List.empty(growable: true);
    List<YearValue> liabilitiesList = List.empty(growable: true);
    List<YearValue> assetsList = List.empty(growable: true);
    List<YearValue> debtEquityRatioList = List.empty(growable: true);

    //if (label != null && label.isNotEmpty) {
    int countLabel = label != null ? label.length : 0;
    int countEquity = equity != null ? equity.length : 0;
    int countLiabilities = liabilities != null ? liabilities.length : 0;
    int countAssets = assets != null ? assets.length : 0;
    int countDebtEquityRatio =
        debtEquityRatio != null ? debtEquityRatio.length : 0;

    for (int i = 0; i < countLabel; i++) {
      String year = label.elementAt(i).toString();
      labelList.add(year);
      equityList.add(new YearValue(
          year, i < countEquity ? Utils.safeDouble(equity.elementAt(i)) : 0.0));
      liabilitiesList.add(new YearValue(
          year,
          i < countLiabilities
              ? Utils.safeDouble(liabilities.elementAt(i))
              : 0.0));
      assetsList.add(new YearValue(
          year, i < countAssets ? Utils.safeDouble(assets.elementAt(i)) : 0.0));
      debtEquityRatioList.add(new YearValue(
          year,
          i < countDebtEquityRatio
              ? Utils.safeDouble(debtEquityRatio.elementAt(i))
              : 0.0));
    }
    //}

    print('label_list : ' +
        labelList.length.toString() +
        '  equity_list : ' +
        equityList.length.toString() +
        '  liabilities_list : ' +
        liabilitiesList.length.toString() +
        '  assets_list : ' +
        assetsList.length.toString() +
        '  debt_equity_ratio_list : ' +
        debtEquityRatioList.length.toString());
    return DataChartBalanceSheet(code, type, showAs, labelList, equityList,
        liabilitiesList, assetsList, debtEquityRatioList);
  }

  void copyValueFrom(DataChartBalanceSheet newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.type = newValue.type;
      this.show_as = newValue.show_as;

      this.label.clear();
      this.equity.clear();
      this.liabilities.clear();
      this.assets.clear();
      this.debt_equity_ratio.clear();

      if (newValue.label != null) {
        this.label.addAll(newValue.label);
      }

      if (newValue.equity != null) {
        this.equity.addAll(newValue.equity);
      }

      if (newValue.liabilities != null) {
        this.liabilities.addAll(newValue.liabilities);
      }

      if (newValue.assets != null) {
        this.assets.addAll(newValue.assets);
      }

      if (newValue.debt_equity_ratio != null) {
        this.debt_equity_ratio.addAll(newValue.debt_equity_ratio);
      }
    } else {
      this.code = '';
      this.type = ''; // BALANCE_SHEET
      this.show_as = ''; // YEARLY or QUARTERLY
      this.label.clear();
      this.equity.clear();
      this.liabilities.clear();
      this.assets.clear();
      this.debt_equity_ratio.clear();
    }
  }
}

class DataChartCashFlow {
  String code = '';
  String type = ''; // CASH_FLOW
  String show_as = ''; // YEARLY or QUARTERLY
  List<String> label = List.empty(growable: true);
  List<YearValue> cash_reserve = List.empty(growable: true);
  List<YearValue> investing = List.empty(growable: true);
  List<YearValue> operating = List.empty(growable: true);
  List<YearValue> financing = List.empty(growable: true);
  bool loaded = false;

  bool isEmpty() {
    return label != null ? label.isEmpty : false;
  }

  DataChartCashFlow(this.code, this.type, this.show_as, this.label,
      this.cash_reserve, this.investing, this.operating, this.financing);

  static DataChartCashFlow createBasic() {
    String code = '';
    String type = ''; // CASH_FLOW
    String showAs = ''; // YEARLY or QUARTERLY

    List<String> label = List.empty(growable: true);
    List<YearValue> cashReserve = List.empty(growable: true);
    List<YearValue> investing = List.empty(growable: true);
    List<YearValue> operating = List.empty(growable: true);
    List<YearValue> financing = List.empty(growable: true);

    return DataChartCashFlow(code, type, showAs, label, cashReserve, investing,
        operating, financing);
  }

  factory DataChartCashFlow.fromJson(Map<String, dynamic> parsedJson,
      String code, String type, String showAs) {
    if (parsedJson == null) {
      return null;
    }
    var label = parsedJson['label'] as List;
    var cashReserve = parsedJson['cash_reserve'] as List;
    var investing = parsedJson['investing'] as List;
    var operating = parsedJson['operating'] as List;
    var financing = parsedJson['financing'] as List;

    List<String> labelList = List.empty(growable: true);
    List<YearValue> cashReserveList = List.empty(growable: true);
    List<YearValue> investingList = List.empty(growable: true);
    List<YearValue> operatingList = List.empty(growable: true);
    List<YearValue> financingList = List.empty(growable: true);

    //if (label != null && label.isNotEmpty) {
    int countLabel = label != null ? label.length : 0;
    int countCashReserve = cashReserve != null ? cashReserve.length : 0;
    int countInvesting = investing != null ? investing.length : 0;
    int countOperating = operating != null ? operating.length : 0;
    int countFinancing = financing != null ? financing.length : 0;

    for (int i = 0; i < countLabel; i++) {
      String year = label.elementAt(i).toString();
      labelList.add(year);
      cashReserveList.add(new YearValue(
          year,
          i < countCashReserve
              ? Utils.safeDouble(cashReserve.elementAt(i))
              : 0.0));
      investingList.add(new YearValue(year,
          i < countInvesting ? Utils.safeDouble(investing.elementAt(i)) : 0.0));
      operatingList.add(new YearValue(year,
          i < countOperating ? Utils.safeDouble(operating.elementAt(i)) : 0.0));
      financingList.add(new YearValue(year,
          i < countFinancing ? Utils.safeDouble(financing.elementAt(i)) : 0.0));
    }
    //}

    print('label_list : ' +
        labelList.length.toString() +
        '  cash_reserve_list : ' +
        cashReserveList.length.toString() +
        '  investing_list : ' +
        investingList.length.toString() +
        '  operating_list : ' +
        operatingList.length.toString() +
        '  financing_list : ' +
        financingList.length.toString());
    return DataChartCashFlow(code, type, showAs, labelList, cashReserveList,
        investingList, operatingList, financingList);
  }

  void copyValueFrom(DataChartCashFlow newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.type = newValue.type;
      this.show_as = newValue.show_as;

      this.label.clear();
      this.cash_reserve.clear();
      this.investing.clear();
      this.operating.clear();
      this.financing.clear();

      if (newValue.label != null) {
        this.label.addAll(newValue.label);
      }

      if (newValue.cash_reserve != null) {
        this.cash_reserve.addAll(newValue.cash_reserve);
      }

      if (newValue.investing != null) {
        this.investing.addAll(newValue.investing);
      }

      if (newValue.operating != null) {
        this.operating.addAll(newValue.operating);
      }

      if (newValue.financing != null) {
        this.financing.addAll(newValue.financing);
      }
    } else {
      this.code = '';
      this.type = ''; // CASH_FLOW
      this.show_as = ''; // YEARLY or QUARTERLY
      this.label.clear();
      this.cash_reserve.clear();
      this.investing.clear();
      this.operating.clear();
      this.financing.clear();
    }
  }
}

class DataChartEarningPerShare {
  String code = '';
  String type = ''; // EARNING_PER_SHARE
  String show_as = ''; // YEARLY or QUARTERLY
  List<String> label = List.empty(growable: true);
  List<YearValue> dividend_per_share = List.empty(growable: true);
  List<YearValue> earning_per_share = List.empty(growable: true);
  List<YearValue> dividend_payout_ratio = List.empty(growable: true);
  bool loaded = false;

  bool isEmpty() {
    return label != null ? label.isEmpty : false;
  }

  DataChartEarningPerShare(
      this.code,
      this.type,
      this.show_as,
      this.label,
      this.dividend_per_share,
      this.earning_per_share,
      this.dividend_payout_ratio);

  static DataChartEarningPerShare createBasic() {
    String code = '';
    String type = ''; // EARNING_PER_SHARE
    String showAs = ''; // YEARLY or QUARTERLY

    List<String> label = List.empty(growable: true);
    List<YearValue> dividendPerShare = List.empty(growable: true);
    List<YearValue> earningPerShare = List.empty(growable: true);
    List<YearValue> dividendPayoutRatio = List.empty(growable: true);

    return DataChartEarningPerShare(code, type, showAs, label, dividendPerShare,
        earningPerShare, dividendPayoutRatio);
  }

  factory DataChartEarningPerShare.fromJson(Map<String, dynamic> parsedJson,
      String code, String type, String showAs) {
    if (parsedJson == null) {
      return null;
    }
    var label = parsedJson['label'] as List;
    var dividendPerShare = parsedJson['dividend_per_share'] as List;
    var earningPerShare = parsedJson['earning_per_share'] as List;
    var dividendPayoutRatio = parsedJson['dividend_payout_ratio'] as List;

    List<String> labelList = List.empty(growable: true);
    List<YearValue> dividendPerShareList = List.empty(growable: true);
    List<YearValue> earningPerShareList = List.empty(growable: true);
    List<YearValue> dividendPayoutRatioList = List.empty(growable: true);

    if (label != null && label.isNotEmpty) {
      int countLabel = label != null ? label.length : 0;
      int countDividendPerShare =
          dividendPerShare != null ? dividendPerShare.length : 0;
      int countEarningPerShare =
          earningPerShare != null ? earningPerShare.length : 0;
      int countDividendPayoutRatio =
          dividendPayoutRatio != null ? dividendPayoutRatio.length : 0;

      for (int i = 0; i < countLabel; i++) {
        String year = label.elementAt(i).toString();
        labelList.add(year);
        dividendPerShareList.add(new YearValue(
            year,
            i < countDividendPerShare
                ? Utils.safeDouble(dividendPerShare.elementAt(i))
                : 0.0));
        earningPerShareList.add(new YearValue(
            year,
            i < countEarningPerShare
                ? Utils.safeDouble(earningPerShare.elementAt(i))
                : 0.0));
        dividendPayoutRatioList.add(new YearValue(
            year,
            i < countDividendPayoutRatio
                ? Utils.safeDouble(dividendPayoutRatio.elementAt(i))
                : 0.0));
      }
    }

    return DataChartEarningPerShare(code, type, showAs, labelList,
        dividendPerShareList, earningPerShareList, dividendPayoutRatioList);
  }

  void copyValueFrom(DataChartEarningPerShare newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.code = newValue.code;
      this.type = newValue.type;
      this.show_as = newValue.show_as;

      this.label.clear();
      this.dividend_per_share.clear();
      this.earning_per_share.clear();
      this.dividend_payout_ratio.clear();

      if (newValue.label != null) {
        this.label.addAll(newValue.label);
      }

      if (newValue.dividend_per_share != null) {
        this.dividend_per_share.addAll(newValue.dividend_per_share);
      }

      if (newValue.earning_per_share != null) {
        this.earning_per_share.addAll(newValue.earning_per_share);
      }

      if (newValue.dividend_payout_ratio != null) {
        this.dividend_payout_ratio.addAll(newValue.dividend_payout_ratio);
      }
    } else {
      this.code = '';
      this.type = ''; // INCOME_STATEMENT
      this.show_as = ''; // YEARLY or QUARTERLY
      this.label.clear();
      this.dividend_per_share.clear();
      this.earning_per_share.clear();
      this.dividend_payout_ratio.clear();
    }
  }
}

class EarningPerShareData {
  List<String> years = ["", "", "", ""];
  List<double> quarter1 = [0, 0, 0, 0];
  List<double> quarter2 = [0, 0, 0, 0];
  List<double> quarter3 = [0, 0, 0, 0];
  List<double> quarter4 = [0, 0, 0, 0];

  List<double> eps = [0, 0, 0, 0];
  List<double> dps = [0.0, 0.0, 0.0, 0.0];
  List<double> dpr = [0.0, 0.0, 0.0, 0.0];

  String recentQuarter = '';

  bool loaded = false;

  bool isEmpty() {
    return years != null ? years.isEmpty : false;
  }

  static EarningPerShareData createBasic() {
    List<String> period = List.empty(growable: true);
    List<double> quarter1 = List.empty(growable: true);
    List<double> quarter2 = List.empty(growable: true);
    List<double> quarter3 = List.empty(growable: true);
    List<double> quarter4 = List.empty(growable: true);
    List<double> eps = List.empty(growable: true);
    List<double> dps = List.empty(growable: true);
    List<double> dpr = List.empty(growable: true);
    String recentQuarter = '';
    return EarningPerShareData(period, quarter1, quarter2, quarter3, quarter4,
        eps, dps, dpr, recentQuarter);
  }

  EarningPerShareData(this.years, this.quarter1, this.quarter2, this.quarter3,
      this.quarter4, this.eps, this.dps, this.dpr, this.recentQuarter);

  factory EarningPerShareData.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    /*
    "earningPerShareData": {
      "recentQuarter": "07 Sep 2021",
      "period": [
      "2017", "2018", "2019", "2020"
      ],
      "Q1": [
      "1", "2", "3", "4"
      ],
      "Q2": [
      "1", "2", "3", "4"
      ],
      "Q3": [
      "1", "2", "3", "4"
      ],
      "Q4": [
      "1", "2", "3", "4"
      ],
      "EPS": [
      "1", "2", "3", "4"
      ],
      "DPS": [
      "1", "2", "3", "4"
      ],
      "DPR": [
      "1", "2", "3", "4"
      ]
    },
    */
    String recentQuarter =
        StringUtils.noNullString(parsedJson['recentQuarter']);

    var period = parsedJson['period'] as List;
    var Q1 = parsedJson['Q1'] as List;
    var Q2 = parsedJson['Q2'] as List;
    var Q3 = parsedJson['Q3'] as List;
    var Q4 = parsedJson['Q4'] as List;
    var EPS = parsedJson['EPS'] as List;
    var DPS = parsedJson['DPS'] as List;
    var DPR = parsedJson['DPR'] as List;

    //List<String> period = List.empty(growable: true);
    // List<int> quarter1 = List.empty(growable: true);
    // List<int> quarter2 = List.empty(growable: true);
    // List<int> quarter3 = List.empty(growable: true);
    // List<int> quarter4 = List.empty(growable: true);
    // List<int> eps = List.empty(growable: true);
    // List<double> dps = List.empty(growable: true);
    // List<double> dpr = List.empty(growable: true);

    List<String> years = ["", "", "", ""];
    List<double> quarter1 = [0, 0, 0, 0];
    List<double> quarter2 = [0, 0, 0, 0];
    List<double> quarter3 = [0, 0, 0, 0];
    List<double> quarter4 = [0, 0, 0, 0];

    List<double> eps = [0, 0, 0, 0];
    List<double> dps = [0.0, 0.0, 0.0, 0.0];
    List<double> dpr = [0.0, 0.0, 0.0, 0.0];

    if (period != null && period.isNotEmpty) {
      for (int i = 0; i < period.length; i++) {
        years[i] = period.elementAt(i).toString();
      }
    }

    if (Q1 != null && Q1.isNotEmpty) {
      for (int i = 0; i < Q1.length; i++) {
        quarter1[i] = Utils.safeDouble(Q1.elementAt(i));
      }
    }

    if (Q2 != null && Q2.isNotEmpty) {
      for (int i = 0; i < Q2.length; i++) {
        quarter2[i] = Utils.safeDouble(Q2.elementAt(i));
      }
    }

    if (Q3 != null && Q3.isNotEmpty) {
      for (int i = 0; i < Q3.length; i++) {
        quarter3[i] = Utils.safeDouble(Q3.elementAt(i));
      }
    }

    if (Q4 != null && Q4.isNotEmpty) {
      for (int i = 0; i < Q4.length; i++) {
        quarter4[i] = Utils.safeDouble(Q4.elementAt(i));
      }
    }

    if (EPS != null && EPS.isNotEmpty) {
      for (int i = 0; i < EPS.length; i++) {
        eps[i] = Utils.safeDouble(EPS.elementAt(i));
      }
    }

    if (DPS != null && DPS.isNotEmpty) {
      for (int i = 0; i < DPS.length; i++) {
        dps[i] = Utils.safeDouble(DPS.elementAt(i));
      }
    }

    if (DPR != null && DPR.isNotEmpty) {
      for (int i = 0; i < DPR.length; i++) {
        dpr[i] = Utils.safeDouble(DPR.elementAt(i));
      }
    }

    return EarningPerShareData(years, quarter1, quarter2, quarter3, quarter4,
        eps, dps, dpr, recentQuarter);
  }

  void copyValueFrom(EarningPerShareData newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.years = newValue.years;
      this.quarter1 = newValue.quarter1;
      this.quarter2 = newValue.quarter2;
      this.quarter3 = newValue.quarter3;
      this.quarter4 = newValue.quarter4;

      this.eps = newValue.eps;
      this.dps = newValue.dps;
      this.dpr = newValue.dpr;

      this.recentQuarter = newValue.recentQuarter;
    } else {
      this.years = ["", "", "", ""];
      this.quarter1 = [0, 0, 0, 0];
      this.quarter2 = [0, 0, 0, 0];
      this.quarter3 = [0, 0, 0, 0];
      this.quarter4 = [0, 0, 0, 0];

      this.eps = [0, 0, 0, 0];
      this.dps = [0.0, 0.0, 0.0, 0.0];
      this.dpr = [0.0, 0.0, 0.0, 0.0];

      this.recentQuarter = '';
    }
  }
}

class News {
  String title;
  String description;
  String url_tumbnail;
  String url_news;
  String time;
  String category;
  int commentCount;
  int likedCount;

  String toString() {
    return '[title=$title] [time=$time] [category=$category] [description=$description] [url_tumbnail=$url_tumbnail] [url_news=$url_news]';
  }

  News(this.title, this.description, this.url_news, this.url_tumbnail,
      this.time, this.category, this.commentCount, this.likedCount);

  /*
  <item>
    <title>Apple akan hadirkan kembali platform media sosial Parler ke App Store</title>
    <link>https://www.antaranews.com/berita/2110802/apple-akan-hadirkan-kembali-platform-media-sosial-parler-ke-app-store</link>
    <pubDate>Tue, 20 Apr 2021 13:37:35 +0700</pubDate>
    <description>
    <![CDATA[ <img src="https://img.antaranews.com/cache/800x533/2021/02/17/2021-01-14T000000Z_1937767962_MT1SIPA0006PHF5M_RTRMADP_3_SIPA-USA.jpg" align="left" border="0">Apple Inc akan kembali menghadirkan aplikasi media sosial Parler, yang disukai oleh kaum konservatif di Amerika Serikat, di&nbsp;App Store setelah sempat ditarik menyusul kerusuhan Capitol yang mematikan pada 6 Januari ... ]]>
    </description>
    <guid isPermaLink="false">https://www.antaranews.com/berita/2110802/apple-akan-hadirkan-kembali-platform-media-sosial-parler-ke-app-store</guid>
  </item>
  */
  factory News.fromXml(XmlElement element) {
    String title = element.findElements('title').single.text;
    String description = element.findElements('description').single.text;
    String urlTumbnail = StringUtils.between(description, '<img src=\"', '\"');

    String urlNews = element.findElements('link').single.text;
    String time = element.findElements('pubDate').single.text;

    int indexStart = description.indexOf('>');
    if (indexStart > -1) {
      description = description.substring(indexStart + 1);
    }

    // description = StringUtils.between(description,'>', ']]>');
    //String url_tumbnail = 'aa';
    String category = 'general';
    int commentCount = 3;
    int likedCount = 6;
    return News(title, description, urlNews, urlTumbnail, time, category,
        commentCount, likedCount);
  }
}
