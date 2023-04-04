import 'dart:ui';

import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import 'dart:math';

abstract class SerializeableSSI {
  String asPlain();

  String identity();

  //String serialize = '{identity:"Stock" data:"$plain"}';
  static String tagIdentity = 'identity';
  static String tagData = 'data';

  String serialize() {
    return '{identity:"' + identity() + '" data:"' + asPlain() + '" }';
  }

  // static List<String> unserialize(String serialize){
  //   String identity = StringUtils.between(serialize, '$tagIdentity:"', '" ') ?? '';
  //   String data = StringUtils.between(serialize, '$tagData:"', '" ') ?? '';
  //   return [identity, data];
  // }

  static SerializeableSSI unserialize(String serialize) {
    String tag1 = tagIdentity + ":\"";
    String tag2 = tagData + ":\"";
    String tagEnd = "\" ";
    String identity = StringUtils.between(serialize, tag1, tagEnd) ?? '';
    String data = StringUtils.between(serialize, tag2, tagEnd) ?? '';

    //print('unserialize for identity : $identity  data : $data   $serialize');

    if (StringUtils.equalsIgnoreCase(identity, 'Broker')) {
      Broker broker = Broker.fromPlain(data);
      return broker;
    } else if (StringUtils.equalsIgnoreCase(identity, 'Stock')) {
      Stock stock = Stock.fromPlain(data);
      return stock;
    } else if (StringUtils.equalsIgnoreCase(identity, 'Index')) {
      Index index = Index.fromPlain(data);
      return index;
    } else if (StringUtils.equalsIgnoreCase(identity, 'Sector')) {
      Sector sector = Sector.fromPlain(data);
      return sector;
    } else if (StringUtils.equalsIgnoreCase(identity, 'People')) {
      People people = People.fromPlain(data);
      return people;
    } else {
      print(
          'unserialize failed for identity : $identity  data : $data   $serialize');
    }
    return null;
  }
}

abstract class CodeNameSSI extends SerializeableSSI {
  String code;
  String name;

  CodeNameSSI(this.code, this.name);

  bool isValid() {
    return !StringUtils.isEmtpy(code);
  }

  bool invalid() {
    return StringUtils.isEmtpy(code);
  }
// String asPlain();
// String identity();
// //String serialize = '{identity:"Stock" data:"$plain"}';
// static String tagIdentity = 'identity';
// static String tagData = 'data';
//
// String serialize() {
//   return '{identity:"'+identity()+'" data:"'+asPlain()+'"}';
// }
//
// // static List<String> unserialize(String serialize){
// //   String identity = StringUtils.between(serialize, '$tagIdentity:"', '" ') ?? '';
// //   String data = StringUtils.between(serialize, '$tagData:"', '" ') ?? '';
// //   return [identity, data];
// // }
//
// static CodeName unserialize(String serialize){
//   String identity = StringUtils.between(serialize, '$tagIdentity:"', '" ') ?? '';
//   String data = StringUtils.between(serialize, '$tagData:"', '" ') ?? '';
//   if(StringUtils.equalsIgnoreCase(identity, 'Broker')){
//     Broker broker = Broker.fromPlain(data);
//     return broker;
//   }else if(StringUtils.equalsIgnoreCase(identity, 'Stock')){
//     Stock stock = Stock.fromPlain(data);
//     return stock;
//   }else if(StringUtils.equalsIgnoreCase(identity, 'Index')){
//     Index index = Index.fromPlain(data);
//     return index;
//   }
//   return null;
// }
}

class Stock extends CodeNameSSI {
  //<a start="1" end="847"
  // code="AALI" name="Astra Agro Lestari Tbk." sector="D232" status="0"
  // type="ORDI" sectorText="IDXNONCYC" subSectorDescription="Food & Beverage"
  // ipo_price="1550" base_price="1230" listed_share="1924688333" tradable_share="1924688333"
  // syariah="Y" papan="1" typeText=""/>

  // String code;
  // String name;
  String sector = '    ';
  String status = ' ';
  String type = ' ';
  String sectorText = ' ';
  String subSectorDescription = '';
  int ipo_price = 0;
  int base_price = 0;
  int listed_share = 0;
  int tradable_share = 0;
  bool syariah = false;
  String papan = '';
  String typeText = ''; // Pre-opening , Warrant , Acceleration Board
  String icon = '';
  double percentChange = 0.0;

  String sectorName = '';

  String identity() {
    return 'Stock';
  }

  bool isValid() {
    return !StringUtils.isEmtpy(code);
  }

  bool isAccelerationBoard() {
    return StringUtils.equalsIgnoreCase(type, 'ACCEL');
  }

  bool isWarrant() {
    return StringUtils.equalsIgnoreCase(type, 'WARI');
  }

  String get defaultBoard =>
      StringUtils.equalsIgnoreCase(type, 'RGHI') ? 'TN' : 'RG';

  static String defaultBoardByCode(String _code) {
    return StringUtils.isContains(_code, '-R') ? 'TN' : 'RG';
  }

  /* Asli
  Stock(String code, String name, this.sector, this.status, this.type, this.sectorText, this.subSectorDescription, this.ipo_price,
      this.base_price, this.listed_share, this.tradable_share, this.syariah, this.papan, this.typeText
      // Pre-opening , Warrant , Acceleration Board
      )
      : super(code, name);
  */
  Stock(String code, String name,
      {this.sector,
      this.status,
      this.type,
      this.sectorText,
      this.subSectorDescription,
      this.ipo_price,
      this.base_price,
      this.listed_share,
      this.tradable_share,
      this.syariah,
      this.papan,
      this.typeText}
      // Pre-opening , Warrant , Acceleration Board
      )
      : super(code, name);

  factory Stock.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String sector = StringUtils.noNullString(parsedJson['sector']);
    String status = StringUtils.noNullString(parsedJson['status']);
    String type = StringUtils.noNullString(parsedJson['type']);
    String sectorText = StringUtils.noNullString(parsedJson['sectorText']);
    String subSectorDescription =
        StringUtils.noNullString(parsedJson['subSectorDescription']);
    int ipo_price = Utils.safeInt(parsedJson['ipo_price']);
    int base_price = Utils.safeInt(parsedJson['base_price']);
    int listed_share = Utils.safeInt(parsedJson['listed_share']);
    int tradable_share = Utils.safeInt(parsedJson['tradable_share']);
    bool syariah = Utils.safeBool(parsedJson['syariah']);
    String papan = StringUtils.noNullString(parsedJson['papan']);
    String typeText = StringUtils.noNullString(parsedJson['typeText']);
    return Stock(code, name,
        sector: sector,
        status: status,
        type: type,
        sectorText: sectorText,
        subSectorDescription: subSectorDescription,
        ipo_price: ipo_price,
        base_price: base_price,
        listed_share: listed_share,
        tradable_share: tradable_share,
        syariah: syariah,
        papan: papan,
        typeText: typeText);
  }

  factory Stock.fromXml(XmlElement element) {
    //return Stock(element.getAttribute('last'), element.getAttribute('code'), double.parse(element.getAttribute('change')), double.parse(element.getAttribute('percentChange')));

    String code = StringUtils.noNullString(element.getAttribute('code'));
    String name = StringUtils.noNullString(element.getAttribute('name'));
    String sector = StringUtils.noNullString(element.getAttribute('sector'));
    String status = StringUtils.noNullString(element.getAttribute('status'));
    String type = StringUtils.noNullString(element.getAttribute('type'));
    String sectorText =
        StringUtils.noNullString(element.getAttribute('sectorText'));
    String subSectorDescription =
        StringUtils.noNullString(element.getAttribute('subSectorDescription'));
    int ipo_price = Utils.safeInt(element.getAttribute('ipo_price'));
    int base_price = Utils.safeInt(element.getAttribute('base_price'));
    int listed_share = Utils.safeInt(element.getAttribute('listed_share'));
    int tradable_share = Utils.safeInt(element.getAttribute('tradable_share'));
    bool syariah = Utils.safeBool(element.getAttribute('syariah'));
    String papan = StringUtils.noNullString(element.getAttribute('papan'));
    String typeText = StringUtils.noNullString(element.getAttribute(
        'typeText')); // Pre-opening , Warrant , Acceleration Board

    return Stock(code, name,
        sector: sector,
        status: status,
        type: type,
        sectorText: sectorText,
        subSectorDescription: subSectorDescription,
        ipo_price: ipo_price,
        base_price: base_price,
        listed_share: listed_share,
        tradable_share: tradable_share,
        syariah: syariah,
        papan: papan,
        typeText: typeText);
  }

  factory Stock.fromPlain(String data) {
    List<String> datas = data.split('|');
    if (datas != null && datas.isNotEmpty && datas.length >= 14) {
      String code = StringUtils.noNullString(datas.elementAt(0));
      String name = StringUtils.noNullString(datas.elementAt(1));
      String sector = StringUtils.noNullString(datas.elementAt(2));
      String status = StringUtils.noNullString(datas.elementAt(3));
      String type = StringUtils.noNullString(datas.elementAt(4));
      String sectorText = StringUtils.noNullString(datas.elementAt(5));
      String subSectorDescription =
          StringUtils.noNullString(datas.elementAt(6));
      int ipo_price = Utils.safeInt(datas.elementAt(7));
      int base_price = Utils.safeInt(datas.elementAt(8));
      int listed_share = Utils.safeInt(datas.elementAt(9));
      int tradable_share = Utils.safeInt(datas.elementAt(10));
      bool syariah = Utils.safeBool(datas.elementAt(11));
      String papan = StringUtils.noNullString(datas.elementAt(12));
      String typeText = StringUtils.noNullString(
          datas.elementAt(13)); // Pre-opening , Warrant , Acceleration Board

      // return Stock(code, name, sector, status, type, sectorText, subSectorDescription, ipo_price, base_price, listed_share, tradable_share,
      //     syariah, papan, typeText);
      return Stock(code, name,
          sector: sector,
          status: status,
          type: type,
          sectorText: sectorText,
          subSectorDescription: subSectorDescription,
          ipo_price: ipo_price,
          base_price: base_price,
          listed_share: listed_share,
          tradable_share: tradable_share,
          syariah: syariah,
          papan: papan,
          typeText: typeText);
    }

    return null;
  }

  bool copyValueFrom(Stock newValue) {
    bool changedCode = false;
    if (newValue != null) {
      changedCode = !StringUtils.equalsIgnoreCase(this.code, newValue.code);
      this.code = newValue.code;
      this.name = newValue.name;
      this.sector = newValue.sector;
      this.status = newValue.status;
      this.type = newValue.type;
      this.sectorText = newValue.sectorText;
      this.subSectorDescription = newValue.subSectorDescription;
      this.ipo_price = newValue.ipo_price;
      this.base_price = newValue.base_price;
      this.listed_share = newValue.listed_share;
      this.tradable_share = newValue.tradable_share;
      this.syariah = newValue.syariah;
      this.papan = newValue.papan;
      this.typeText = newValue.typeText;
      this.sectorName = newValue.sectorName;
    } else {
      changedCode = true;
      this.code = '';
      this.name = '';
      this.sector = '    ';
      this.status = ' ';
      this.type = ' ';
      this.sectorText = ' ';
      this.subSectorDescription = '';
      this.ipo_price = 0;
      this.base_price = 0;
      this.listed_share = 0;
      this.tradable_share = 0;
      this.syariah = false;
      this.papan = '';
      this.typeText = ''; // Pre-opening , Warrant , Acceleration Board
      this.icon = '';
      this.percentChange = 0.0;
      this.sectorName = '';
    }
    return changedCode;
  }

  @override
  String asPlain() {
    String plain = code;
    plain += '|' + name;
    plain += '|' + sector;
    plain += '|' + status;
    plain += '|' + type;
    plain += '|' + sectorText;
    plain += '|' + subSectorDescription;
    plain += '|' + ipo_price.toString();
    plain += '|' + base_price.toString();
    plain += '|' + listed_share.toString();
    plain += '|' + tradable_share.toString();
    plain += '|' + syariah.toString();
    plain += '|' + papan;
    plain += '|' + typeText;
    return plain;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '[Stock --> $code, $name, $sector, $status, $type, $sectorText, $subSectorDescription, $ipo_price, $base_price, $listed_share, $tradable_share, $syariah, $papan, $typeText]';
  }
}

class Broker extends CodeNameSSI {
  //<a start="1" end="99"
  // code="AF" name="Harita Kencana Sekuritas" status="0" is_local="1"/>
  //String code;
  //String name;
  String status;
  int is_local;

  Color color(BuildContext context) {
    Color _color;
    //if(_color == null){
    if (is_local == 0) {
      _color = InvestrendTheme.foreignColor;
    } else {
      _color = InvestrendTheme.of(context).small_w400.color;
    }
    //}
    return _color;
  }
  //Color get color => _color;

  Broker(String code, String name, this.status, this.is_local)
      : super(code, name);

  String identity() {
    return 'Broker';
  }

  factory Broker.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String status = StringUtils.noNullString(parsedJson['status']);
    int is_local = Utils.safeInt(parsedJson['is_local']);
    return Broker(code, name, status, is_local);
  }

  factory Broker.fromXml(XmlElement element) {
    String code = StringUtils.noNullString(element.getAttribute('code'));
    String name = StringUtils.noNullString(element.getAttribute('name'));
    String status = StringUtils.noNullString(element.getAttribute('status'));
    int is_local = Utils.safeInt(element.getAttribute('is_local'));
    //return Broker(element.getAttribute('last'), element.getAttribute('code'), double.parse(element.getAttribute('change')), double.parse(element.getAttribute('percentChange')));
    return Broker(code, name, status, is_local);
  }

  factory Broker.fromPlain(String data) {
    List<String> datas = data.split('|');

    if (datas != null && datas.isNotEmpty && datas.length >= 4) {
      String code = StringUtils.noNullString(datas.elementAt(0));
      String name = StringUtils.noNullString(datas.elementAt(1));
      String status = StringUtils.noNullString(datas.elementAt(2));
      int is_local = Utils.safeInt(datas.elementAt(3));

      return Broker(code, name, status, is_local);
    }
    return null;
  }

  @override
  String asPlain() {
    String plain = code;
    plain += '|' + name;
    plain += '|' + status;
    plain += '|' + is_local.toString();
    return plain;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '[Broker --> $code, $name, $status, $is_local]';
  }
}

class Sector extends SerializeableSSI {
  String code; // "A111"
  String sector; // "IDXENERGY",
  String sector_text; //"Energy",
  String sub_sector; // "Oil, Gas & Coal",
  String industry; //"Oil & Gas",
  String sub_industry; //"Oil & Gas Production & Refinery"

  Sector(this.code, this.sector, this.sector_text, this.sub_sector,
      this.industry, this.sub_industry);

  factory Sector.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String sector = StringUtils.noNullString(parsedJson['sector']);
    String sector_text = StringUtils.noNullString(parsedJson['sector_text']);
    String sub_sector = StringUtils.noNullString(parsedJson['sub_sector']);
    String industry = StringUtils.noNullString(parsedJson['industry']);
    String sub_industry = StringUtils.noNullString(parsedJson['sub_industry']);

    return Sector(
        code, sector, sector_text, sub_sector, industry, sub_industry);
  }

  @override
  String asPlain() {
    String plain = code;
    plain += '|' + sector;
    plain += '|' + sector_text;
    plain += '|' + sub_sector;
    plain += '|' + industry;
    plain += '|' + sub_industry;
    return plain;
  }

  factory Sector.fromPlain(String data) {
    List<String> datas = data.split('|');

    if (datas != null && datas.isNotEmpty && datas.length >= 6) {
      // data
      String code = StringUtils.noNullString(datas.elementAt(0));
      String sector = StringUtils.noNullString(datas.elementAt(1));
      String sector_text = StringUtils.noNullString(datas.elementAt(2));
      String sub_sector = StringUtils.noNullString(datas.elementAt(3));
      String industry = StringUtils.noNullString(datas.elementAt(4));
      String sub_industry = StringUtils.noNullString(datas.elementAt(5));
      return Sector(
          code, sector, sector_text, sub_sector, industry, sub_industry);
    }

    return null;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '[Sector --> $code, $sector, $sector_text, $sub_sector, $industry, $sub_industry]';
  }

  @override
  String identity() {
    return 'Sector';
  }
}

class Index extends CodeNameSSI {
  //<a start="1" end="37"
  // code="COMPOSITE" name="Jakarta Composite Index (JCI)"
  // grouping="INDEX" color="FFFFFF" color_digit="-"/>
  //String code;
  //String name;
  String grouping;
  String color;
  String color_digit;
  bool isSector = false;
  bool isComposite = false;
  List<Stock> listMembers = List<Stock>.empty(growable: true);

  Index(String code, String name, this.grouping, this.color, this.color_digit,
      this.isSector, this.isComposite)
      : super(code, name);

  String identity() {
    return 'Index';
  }

  factory Index.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);
    String name = StringUtils.noNullString(parsedJson['name']);
    String grouping = StringUtils.noNullString(parsedJson['grouping']);
    String color = StringUtils.noNullString(parsedJson['color']);
    String color_digit = StringUtils.noNullString(parsedJson['color_digit']);

    // logic
    bool isSector = StringUtils.equalsIgnoreCase(grouping, 'JCI SECTOR');
    bool isComposite = StringUtils.equalsIgnoreCase(code, 'COMPOSITE');

    return Index(
        code, name, grouping, color, color_digit, isSector, isComposite);
  }

  factory Index.fromXml(XmlElement element) {
    // data
    String code = StringUtils.noNullString(element.getAttribute('code'));
    String name = StringUtils.noNullString(element.getAttribute('name'));
    String grouping =
        StringUtils.noNullString(element.getAttribute('grouping'));
    String color = StringUtils.noNullString(element.getAttribute('color'));
    String color_digit =
        StringUtils.noNullString(element.getAttribute('color_digit'));

    // logic
    bool isSector = StringUtils.equalsIgnoreCase(grouping, 'JCI SECTOR');
    bool isComposite = StringUtils.equalsIgnoreCase(code, 'COMPOSITE');

    return Index(
        code, name, grouping, color, color_digit, isSector, isComposite);
  }

  factory Index.fromPlain(String data) {
    List<String> datas = data.split('|');

    if (datas != null && datas.isNotEmpty && datas.length >= 5) {
      // data
      String code = StringUtils.noNullString(datas.elementAt(0));
      String name = StringUtils.noNullString(datas.elementAt(1));
      String grouping = StringUtils.noNullString(datas.elementAt(2));
      String color = StringUtils.noNullString(datas.elementAt(3));
      String color_digit = StringUtils.noNullString(datas.elementAt(4));

      // logic
      bool isSector = StringUtils.equalsIgnoreCase(grouping, 'JCI SECTOR');
      bool isComposite = StringUtils.equalsIgnoreCase(code, 'COMPOSITE');

      return Index(
          code, name, grouping, color, color_digit, isSector, isComposite);
    }

    return null;
  }

  @override
  String asPlain() {
    String plain = code;
    plain += '|' + name;
    plain += '|' + grouping;
    plain += '|' + color;
    plain += '|' + color_digit;

    return plain;
  }

  void checkAndAddMembers(Stock stock) {
    if (stock != null) {
      if (stock.sector.startsWith(color_digit)) {
        if (!listMembers.contains(stock)) {
          listMembers.add(stock);
          stock.sectorName = name;
        }
      }
    }
  }

  @override
  String toString() {
    return '[Index --> $code, $name, $grouping, $color, $color_digit, $isSector, ' +
        listMembers.length.toString() +
        ']';
  }

  void copyValueFrom(Index newValue) {
    if (newValue != null) {
      this.code = newValue.code;
      this.name = newValue.name;
      this.grouping = newValue.grouping;
      this.color = newValue.color;
      this.color_digit = newValue.color_digit;
      this.isSector = newValue.isSector;
      this.isComposite = newValue.isComposite;
      this.listMembers = newValue.listMembers;
    } else {
      this.code = '';
      this.name = '';
      this.grouping = '';
      this.color = '';
      this.color_digit = '';
      this.isSector = false;
      this.isComposite = false;
      this.listMembers.clear();
    }
  }
}

class MD5StockBrokerIndex {
  //<a md5broker="68c64e816e03797159d17ca23f2e2b16"
  // md5stock="5fba8fa0d5dc83c21d60d85caf12f170"
  // md5index="6816c63704d23fdf4cef8a66472f4359"
  // md5brokerUpdate="2021-04-26 08:47:42"
  // md5stockUpdate="2021-04-26 08:47:42"
  // md5indexUpdate="2021-04-26 08:47:42"
  // sharePerLot="100"/>

  String md5broker;
  String md5stock;
  String md5index;
  String md5sector;
  int sharePerLot;

  String md5brokerUpdate;
  String md5stockUpdate;
  String md5indexUpdate;
  String md5sectorUpdate;

  MD5StockBrokerIndex(
      this.md5broker,
      this.md5stock,
      this.md5index,
      this.md5sector,
      this.sharePerLot,
      this.md5brokerUpdate,
      this.md5stockUpdate,
      this.md5indexUpdate,
      this.md5sectorUpdate);

  bool isValid() {
    return !StringUtils.isEmtpy(this.md5broker) &&
        !StringUtils.isEmtpy(this.md5stock) &&
        !StringUtils.isEmtpy(this.md5index) &&
        !StringUtils.isEmtpy(this.md5sector) &&
        this.sharePerLot > 0;
  }

  factory MD5StockBrokerIndex.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    String md5broker = StringUtils.noNullString(parsedJson['md5broker']);
    String md5stock = StringUtils.noNullString(parsedJson['md5stock']);
    String md5index = StringUtils.noNullString(parsedJson['md5index']);
    String md5sector = StringUtils.noNullString(parsedJson['md5sector']);
    int sharePerLot = parsedJson['sharePerLot'];
    String md5brokerUpdate =
        StringUtils.noNullString(parsedJson['md5brokerUpdate']);
    String md5stockUpdate =
        StringUtils.noNullString(parsedJson['md5stockUpdate']);
    String md5indexUpdate =
        StringUtils.noNullString(parsedJson['md5indexUpdate']);
    String md5sectorUpdate =
        StringUtils.noNullString(parsedJson['md5sectorUpdate']);
    return MD5StockBrokerIndex(
        md5broker,
        md5stock,
        md5index,
        md5sector,
        sharePerLot,
        md5brokerUpdate,
        md5stockUpdate,
        md5indexUpdate,
        md5sectorUpdate);
  }

  factory MD5StockBrokerIndex.fromXml(XmlElement element) {
    String md5broker =
        StringUtils.noNullString(element.getAttribute('md5broker'));
    String md5stock =
        StringUtils.noNullString(element.getAttribute('md5stock'));
    String md5index =
        StringUtils.noNullString(element.getAttribute('md5index'));
    String md5sector =
        StringUtils.noNullString(element.getAttribute('md5sector'));
    int sharePerLot = Utils.safeInt(element.getAttribute('sharePerLot'));
    String md5brokerUpdate =
        StringUtils.noNullString(element.getAttribute('md5brokerUpdate'));
    String md5stockUpdate =
        StringUtils.noNullString(element.getAttribute('md5stockUpdate'));
    String md5indexUpdate =
        StringUtils.noNullString(element.getAttribute('md5indexUpdate'));
    String md5sectorUpdate =
        StringUtils.noNullString(element.getAttribute('md5sectorUpdate'));

    return MD5StockBrokerIndex(
        md5broker,
        md5stock,
        md5index,
        md5sector,
        sharePerLot,
        md5brokerUpdate,
        md5stockUpdate,
        md5indexUpdate,
        md5sectorUpdate);
  }

  Future<bool> save(/*SharedPreferences prefs*/) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedBroker = await prefs.setString('md5broker', md5broker);
    bool savedStock = await prefs.setString('md5stock', md5stock);
    bool savedIndex = await prefs.setString('md5index', md5index);
    bool savedSector = await prefs.setString('md5sector', md5sector);
    bool savedLot = await prefs.setInt('sharePerLot', sharePerLot);
    bool savedBrokerUpdate =
        await prefs.setString('md5brokerUpdate', md5brokerUpdate);
    bool savedStockUpdate =
        await prefs.setString('md5stockUpdate', md5stockUpdate);
    bool savedIndexUpdate =
        await prefs.setString('md5indexUpdate', md5indexUpdate);
    bool savedSectorUpdate =
        await prefs.setString('md5sectorUpdate', md5sectorUpdate);
    print('save MD5 to SharedPreferences');
    bool saved = savedBroker &&
        savedStock &&
        savedIndex &&
        savedSector &&
        savedLot &&
        savedBrokerUpdate &&
        savedStockUpdate &&
        savedIndexUpdate &&
        savedSectorUpdate;
    return saved;
  }

  void copyValueFrom(MD5StockBrokerIndex newValue) {
    if (newValue != null) {
      this.md5broker = newValue.md5broker;
      this.md5stock = newValue.md5stock;
      this.md5index = newValue.md5index;
      this.sharePerLot = newValue.sharePerLot;
      this.md5brokerUpdate = newValue.md5brokerUpdate;
      this.md5stockUpdate = newValue.md5stockUpdate;
      this.md5indexUpdate = newValue.md5indexUpdate;
    }
  }

  // String toXmlString() {
  //   return '<a md5broker="'+md5broker+'" md5stock="'+md5stock+'" md5index="'+md5index+'" md5brokerUpdate="'+md5brokerUpdate+'" md5stockUpdate="'+md5stockUpdate+'" md5indexUpdate="'+md5indexUpdate+'" sharePerLot="'+sharePerLot.toString()+'"/>';
  // }
  @override
  String toString() {
    return '[MD5StockBrokerIndex --> $md5broker, $md5stock, $md5index, $md5sector, $sharePerLot, $md5brokerUpdate, $md5stockUpdate, $md5indexUpdate, $md5sectorUpdate]';
  }
}

class IndexSummary {
  /*
  <a start="1" end="37"
  time="14:50:00" indexCode="COMPOSITE"
  prev="5993.242" last="5992.502" open="6004.794" hi="6024.938" low="5980.455"
  change="-0.739" percentChange="-0.01" freq="870388"
  volume="14351321704" value="7843907889158"
  up="195" down="289" unchange="169" untrade="83"
  date="2021-04-22" hi52W="6504.99" low52W="4441.09" return52W="33.1"

  domesticBuyerValue="6216303468771" domesticSellerValue="6035425275771"
  foreignBuyerValue="1627604420387" foreignSellerValue="1808482613387"
  hiYTD="6504.99" lowYTD="5735.47" returnYTD="0.22"
  grouping="INDEX" hiMTD="6115.62" lowMTD="5883.52" returnMTD="0.11"/>
  */

  String time;
  String code;
  double prev;
  double last;
  double open;
  double hi;
  double low;
  double change;
  double percentChange;
  int freq;
  int volume;
  int value;

  int up;
  int down;
  int unchange;
  int untrade;
  String date;
  double hi52W;
  double low52W;
  double return52W;

  int domesticBuyerValue;
  int domesticSellerValue;
  int foreignBuyerValue;
  int foreignSellerValue;

  double hiYTD;
  double lowYTD;
  double returnYTD;

  String grouping;

  double hiMTD;
  double lowMTD;
  double returnMTD;

  IndexSummary(this.code,
      {this.time,
      this.prev,
      this.last,
      this.open,
      this.hi,
      this.low,
      this.change,
      this.percentChange,
      this.freq,
      this.volume,
      this.value,
      this.up,
      this.down,
      this.unchange,
      this.untrade,
      this.date,
      this.hi52W,
      this.low52W,
      this.return52W,
      this.domesticBuyerValue,
      this.domesticSellerValue,
      this.foreignBuyerValue,
      this.foreignSellerValue,
      this.hiYTD,
      this.lowYTD,
      this.returnYTD,
      this.grouping,
      this.hiMTD,
      this.lowMTD,
      this.returnMTD});
  factory IndexSummary.fromJson(Map<String, dynamic> parsedJson) {
    //String code         = StringUtils.noNullString(parsedJson['code']);

    String time = StringUtils.noNullString(parsedJson['time']);
    String code = StringUtils.noNullString(parsedJson['indexCode']);
    double prev = Utils.safeDouble(parsedJson['prev']);
    double last = Utils.safeDouble(parsedJson['last']);
    double open = Utils.safeDouble(parsedJson['open']);
    double hi = Utils.safeDouble(parsedJson['hi']);
    double low = Utils.safeDouble(parsedJson['low']);
    double change = Utils.safeDouble(parsedJson['change']);
    double percentChange = Utils.safeDouble(parsedJson['percentChange']);
    int freq = Utils.safeInt(parsedJson['freq']);
    int volume = Utils.safeInt(parsedJson['volume']);
    int value = Utils.safeInt(parsedJson['value']);

    int up = Utils.safeInt(parsedJson['up']);
    int down = Utils.safeInt(parsedJson['down']);
    int unchange = Utils.safeInt(parsedJson['unchange']);
    int untrade = Utils.safeInt(parsedJson['untrade']);
    String date = StringUtils.noNullString(parsedJson['date']);
    double hi52W = Utils.safeDouble(parsedJson['hi52W']);
    double low52W = Utils.safeDouble(parsedJson['low52W']);
    double return52W = Utils.safeDouble(parsedJson['return52W']);

    int domesticBuyerValue = Utils.safeInt(parsedJson['domesticBuyerValue']);
    int domesticSellerValue = Utils.safeInt(parsedJson['domesticSellerValue']);
    int foreignBuyerValue = Utils.safeInt(parsedJson['foreignBuyerValue']);
    int foreignSellerValue = Utils.safeInt(parsedJson['foreignSellerValue']);

    double hiYTD = Utils.safeDouble(parsedJson['hiYTD']);
    double lowYTD = Utils.safeDouble(parsedJson['lowYTD']);
    double returnYTD = Utils.safeDouble(parsedJson['returnYTD']);

    String grouping = StringUtils.noNullString(parsedJson['grouping']);

    double hiMTD = Utils.safeDouble(parsedJson['hiMTD']);
    double lowMTD = Utils.safeDouble(parsedJson['lowMTD']);
    double returnMTD = Utils.safeDouble(parsedJson['returnMTD']);

    return IndexSummary(code,
        time: time,
        prev: prev,
        last: last,
        open: open,
        hi: hi,
        low: low,
        change: change,
        percentChange: percentChange,
        freq: freq,
        volume: volume,
        value: value,
        up: up,
        down: down,
        unchange: unchange,
        untrade: untrade,
        date: date,
        hi52W: hi52W,
        low52W: low52W,
        return52W: return52W,
        domesticBuyerValue: domesticBuyerValue,
        domesticSellerValue: domesticSellerValue,
        foreignBuyerValue: foreignBuyerValue,
        foreignSellerValue: foreignSellerValue,
        hiYTD: hiYTD,
        lowYTD: lowYTD,
        returnYTD: returnYTD,
        grouping: grouping,
        hiMTD: hiMTD,
        lowMTD: lowMTD,
        returnMTD: returnMTD);
  }

  factory IndexSummary.fromXml(XmlElement element) {
    String time = StringUtils.noNullString(element.getAttribute('time'));
    String code = StringUtils.noNullString(element.getAttribute('indexCode'));
    double prev = Utils.safeDouble(element.getAttribute('prev'));
    double last = Utils.safeDouble(element.getAttribute('last'));
    double open = Utils.safeDouble(element.getAttribute('open'));
    double hi = Utils.safeDouble(element.getAttribute('hi'));
    double low = Utils.safeDouble(element.getAttribute('low'));
    double change = Utils.safeDouble(element.getAttribute('change'));
    double percentChange =
        Utils.safeDouble(element.getAttribute('percentChange'));
    int freq = Utils.safeInt(element.getAttribute('freq'));
    int volume = Utils.safeInt(element.getAttribute('volume'));
    int value = Utils.safeInt(element.getAttribute('value'));

    int up = Utils.safeInt(element.getAttribute('up'));
    int down = Utils.safeInt(element.getAttribute('down'));
    int unchange = Utils.safeInt(element.getAttribute('unchange'));
    int untrade = Utils.safeInt(element.getAttribute('untrade'));
    String date = StringUtils.noNullString(element.getAttribute('date'));
    double hi52W = Utils.safeDouble(element.getAttribute('hi52W'));
    double low52W = Utils.safeDouble(element.getAttribute('low52W'));
    double return52W = Utils.safeDouble(element.getAttribute('return52W'));

    int domesticBuyerValue =
        Utils.safeInt(element.getAttribute('domesticBuyerValue'));
    int domesticSellerValue =
        Utils.safeInt(element.getAttribute('domesticSellerValue'));
    int foreignBuyerValue =
        Utils.safeInt(element.getAttribute('foreignBuyerValue'));
    int foreignSellerValue =
        Utils.safeInt(element.getAttribute('foreignSellerValue'));

    double hiYTD = Utils.safeDouble(element.getAttribute('hiYTD'));
    double lowYTD = Utils.safeDouble(element.getAttribute('lowYTD'));
    double returnYTD = Utils.safeDouble(element.getAttribute('returnYTD'));

    String grouping =
        StringUtils.noNullString(element.getAttribute('grouping'));

    double hiMTD = Utils.safeDouble(element.getAttribute('hiMTD'));
    double lowMTD = Utils.safeDouble(element.getAttribute('lowMTD'));
    double returnMTD = Utils.safeDouble(element.getAttribute('returnMTD'));

    return IndexSummary(code,
        time: time,
        prev: prev,
        last: last,
        open: open,
        hi: hi,
        low: low,
        change: change,
        percentChange: percentChange,
        freq: freq,
        volume: volume,
        value: value,
        up: up,
        down: down,
        unchange: unchange,
        untrade: untrade,
        date: date,
        hi52W: hi52W,
        low52W: low52W,
        return52W: return52W,
        domesticBuyerValue: domesticBuyerValue,
        domesticSellerValue: domesticSellerValue,
        foreignBuyerValue: foreignBuyerValue,
        foreignSellerValue: foreignSellerValue,
        hiYTD: hiYTD,
        lowYTD: lowYTD,
        returnYTD: returnYTD,
        grouping: grouping,
        hiMTD: hiMTD,
        lowMTD: lowMTD,
        returnMTD: returnMTD);
  }

  bool isValid() {
    return !StringUtils.isEmtpy(code);
  }

  Color openColor() {
    return InvestrendTheme.changeTextColor(open, prev: prev);
  }

  Color hiColor() {
    return InvestrendTheme.changeTextColor(hi, prev: prev);
  }

  Color lowColor() {
    return InvestrendTheme.changeTextColor(low, prev: prev);
  }

  Color closeColor() {
    return InvestrendTheme.changeTextColor(last, prev: prev);
  }

  @override
  String toString() {
    // TODO: implement toString
    return '[Index Summary --> $time, $code, $prev, $last, $open, $hi, $low, $change, $percentChange, $freq, $volume, $value, $up, $down, $unchange, $untrade, $date, $hi52W, $low52W, $return52W, $domesticBuyerValue, $domesticSellerValue, $foreignBuyerValue, $foreignSellerValue, $hiYTD, $lowYTD, $returnYTD, $grouping, $hiMTD, $lowMTD, $returnMTD]';
  }

  void copyValueFrom(IndexSummary newValue) {
    if (newValue != null) {
      this.time = newValue.time;
      this.code = newValue.code;
      this.prev = newValue.prev;
      this.last = newValue.last;
      this.open = newValue.open;
      this.hi = newValue.hi;
      this.low = newValue.low;
      this.change = newValue.change;
      this.percentChange = newValue.percentChange;
      this.freq = newValue.freq;
      this.volume = newValue.volume;
      this.value = newValue.value;
      this.up = newValue.up;
      this.down = newValue.down;
      this.unchange = newValue.unchange;
      this.untrade = newValue.untrade;
      this.date = newValue.date;
      this.hi52W = newValue.hi52W;
      this.low52W = newValue.low52W;
      this.return52W = newValue.return52W;
      this.domesticBuyerValue = newValue.domesticBuyerValue;
      this.domesticSellerValue = newValue.domesticSellerValue;
      this.foreignBuyerValue = newValue.foreignBuyerValue;
      this.foreignSellerValue = newValue.foreignSellerValue;
      this.hiYTD = newValue.hiYTD;
      this.lowYTD = newValue.lowYTD;
      this.returnYTD = newValue.returnYTD;
      this.grouping = newValue.grouping;
      this.hiMTD = newValue.hiMTD;
      this.lowMTD = newValue.lowMTD;
      this.returnMTD = newValue.returnMTD;
    } else {
      this.time = '';
      this.code = '';
      this.prev = 0.0;
      this.last = 0.0;
      this.open = 0.0;
      this.hi = 0.0;
      this.low = 0.0;
      this.change = 0.0;
      this.percentChange = 0.0;
      this.freq = 0;
      this.volume = 0;
      this.value = 0;
      this.up = 0;
      this.down = 0;
      this.unchange = 0;
      this.untrade = 0;
      this.date = '';
      this.hi52W = 0.0;
      this.low52W = 0.0;
      this.return52W = 0.0;
      this.domesticBuyerValue = 0;
      this.domesticSellerValue = 0;
      this.foreignBuyerValue = 0;
      this.foreignSellerValue = 0;
      this.hiYTD = 0.0;
      this.lowYTD = 0.0;
      this.returnYTD = 0.0;
      this.grouping = '';
      this.hiMTD = 0.0;
      this.lowMTD = 0.0;
      this.returnMTD = 0.0;
    }
  }
}

class TradeBook {
  /*
  <TRADEBOOK>
    <a start="1" end="1"
    time="10:05:47" stockCode="ASII" boardCode="RG"
    tradeBookString="5600_182_10577840000_1888900_0_0_182_1888900_0_10577840000*5575_1286_47789457500_8572100_676_4899900_610_3672200_27316942500_20472515000*5550_1075_20444535000_3683700_474_1534800_601_2148900_8518140000_11926395000*5525_874_37198167500_6732700_56_803300_818_5929400_4438232500_32759935000*5500_1396_49687550000_9034100_815_4487300_581_4546800_24680150000_25007400000*5475_174_9441090000_1724400_174_1724400_0_0_9441090000_0"
    totalBuyerValue="74394555000" totalBuyerFreq="2195" totalBuyerVol="13449700"
    totalSellerValue="100744085000" totalSellerFreq="2792" totalSellerVol="18186200"/>
  </TRADEBOOK>
  */
  String time = '';
  String code = '';
  String board = '';
  String tradeBookString = '';
  int totalBuyerValue = 0;
  int totalBuyerFreq = 0;
  int totalBuyerVol = 0;
  int totalSellerValue = 0;
  int totalSellerFreq = 0;
  int totalSellerVol = 0;
  List<TradeBookRow> listTradeBookRows = List.empty(growable: true);
  bool loaded = false;
  int countRows() {
    return listTradeBookRows != null ? listTradeBookRows.length : 0;
  }

  static TradeBook createBasic() {
    TradeBook tb = new TradeBook('', '');
    tb.time = '';
    tb.tradeBookString = '';
    tb.totalBuyerValue = 0;
    tb.totalBuyerFreq = 0;
    tb.totalBuyerVol = 0;
    tb.totalSellerValue = 0;
    tb.totalSellerFreq = 0;
    tb.totalSellerVol = 0;
    tb.listTradeBookRows = List.empty(growable: true);
    return tb;
  }

  TradeBook(this.code, this.board,
      {this.time,
      this.tradeBookString,
      this.totalBuyerValue,
      this.totalBuyerFreq,
      this.totalBuyerVol,
      this.totalSellerValue,
      this.totalSellerFreq,
      this.totalSellerVol,
      this.listTradeBookRows});

  bool isValid() {
    return !StringUtils.isEmtpy(code) && !StringUtils.isEmtpy(board);
  }

  factory TradeBook.fromStreaming(List<String> data) {
    final String HEADER = data[0];
    final String type = data[1];
    final String start = data[2];
    final String end = data[3];
    final String code = data[4];
    final String board = data[5];

    final String time = data[6];
    final int totalBuyerFreq = Utils.safeInt(data[7]);
    final int totalBuyerValue = Utils.safeInt(data[8]);
    final int totalBuyerVol = Utils.safeInt(data[9]);
    final int totalSellerFreq = Utils.safeInt(data[10]);
    final int totalSellerValue = Utils.safeInt(data[11]);
    final int totalSellerVol = Utils.safeInt(data[12]);
    final String tradeBookString = data[13];

    List<TradeBookRow> listTradeBookRows =
        List<TradeBookRow>.empty(growable: true);
    if (!StringUtils.isEmtpy(tradeBookString)) {
      List<String> rows = tradeBookString.split('*');
      if (rows != null && rows.isNotEmpty) {
        rows.forEach((row) {
          List<String> data = row.split('_');
          if (data != null && data.isNotEmpty && data.length >= 10) {
            int price = Utils.safeInt(data.elementAt(0));
            int freq = Utils.safeInt(data.elementAt(1));
            int val = Utils.safeInt(data.elementAt(2));
            int volume = Utils.safeInt(data.elementAt(3));
            int buyerFreq = Utils.safeInt(data.elementAt(4));
            int buyerVolume = Utils.safeInt(data.elementAt(5));
            int sellerFreq = Utils.safeInt(data.elementAt(6));
            int sellerVolume = Utils.safeInt(data.elementAt(7));
            int buyerValue = Utils.safeInt(data.elementAt(7));
            int sellerValue = Utils.safeInt(data.elementAt(9));

            TradeBookRow tb = TradeBookRow(
                price,
                volume,
                val,
                freq,
                buyerVolume,
                buyerValue,
                buyerFreq,
                sellerVolume,
                sellerValue,
                sellerFreq);
            //print(tb);
            listTradeBookRows.add(tb);
          }
        });
      }
    }
    return TradeBook(code, board,
        time: time,
        tradeBookString: tradeBookString,
        totalBuyerValue: totalBuyerValue,
        totalBuyerFreq: totalBuyerFreq,
        totalBuyerVol: totalBuyerVol,
        totalSellerValue: totalSellerValue,
        totalSellerFreq: totalSellerFreq,
        totalSellerVol: totalSellerVol,
        listTradeBookRows: listTradeBookRows);
  }
  factory TradeBook.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['stockCode']);

    String time = StringUtils.noNullString(parsedJson['time']);
    //String code = StringUtils.noNullString(parsedJson['stockCode']);
    String board = StringUtils.noNullString(parsedJson['boardCode']);
    String tradeBookString =
        StringUtils.noNullString(parsedJson['tradeBookString']);
    int totalBuyerValue = Utils.safeInt(parsedJson['totalBuyerValue']);
    int totalBuyerFreq = Utils.safeInt(parsedJson['totalBuyerFreq']);
    int totalBuyerVol = Utils.safeInt(parsedJson['totalBuyerVol']);
    int totalSellerValue = Utils.safeInt(parsedJson['totalSellerValue']);
    int totalSellerFreq = Utils.safeInt(parsedJson['totalSellerFreq']);
    int totalSellerVol = Utils.safeInt(parsedJson['totalSellerVol']);
    //                     0             1           2         3                 4
    //tradeBookString = tb.price+"_"+tb.freq+"_"+tb.val+"_"+tb.volume+"_"+tb.getBuyerFreq()
    //               5                     6                       7                     8                       9
    // +"_"+tb.getBuyerVol()+"_"+tb.getSellerFreq()+"_"+tb.getSellerVol()+"_"+tb.getBuyerValue()+"_"+tb.getSellerValue();

    List<TradeBookRow> listTradeBookRows =
        List<TradeBookRow>.empty(growable: true);
    if (!StringUtils.isEmtpy(tradeBookString)) {
      List<String> rows = tradeBookString.split('*');
      if (rows != null && rows.isNotEmpty) {
        rows.forEach((row) {
          List<String> data = row.split('_');
          if (data != null && data.isNotEmpty && data.length >= 10) {
            int price = Utils.safeInt(data.elementAt(0));
            int freq = Utils.safeInt(data.elementAt(1));
            int val = Utils.safeInt(data.elementAt(2));
            int volume = Utils.safeInt(data.elementAt(3));
            int buyerFreq = Utils.safeInt(data.elementAt(4));
            int buyerVolume = Utils.safeInt(data.elementAt(5));
            int sellerFreq = Utils.safeInt(data.elementAt(6));
            int sellerVolume = Utils.safeInt(data.elementAt(7));
            int buyerValue = Utils.safeInt(data.elementAt(7));
            int sellerValue = Utils.safeInt(data.elementAt(9));

            TradeBookRow tb = TradeBookRow(
                price,
                volume,
                val,
                freq,
                buyerVolume,
                buyerValue,
                buyerFreq,
                sellerVolume,
                sellerValue,
                sellerFreq);
            //print(tb);
            listTradeBookRows.add(tb);
          }
        });
      }
    }
    return TradeBook(code, board,
        time: time,
        tradeBookString: tradeBookString,
        totalBuyerValue: totalBuyerValue,
        totalBuyerFreq: totalBuyerFreq,
        totalBuyerVol: totalBuyerVol,
        totalSellerValue: totalSellerValue,
        totalSellerFreq: totalSellerFreq,
        totalSellerVol: totalSellerVol,
        listTradeBookRows: listTradeBookRows);
  }
  factory TradeBook.fromXml(XmlElement element) {
    String time = StringUtils.noNullString(element.getAttribute('time'));
    String code = StringUtils.noNullString(element.getAttribute('stockCode'));
    String board = StringUtils.noNullString(element.getAttribute('boardCode'));
    String tradeBookString =
        StringUtils.noNullString(element.getAttribute('tradeBookString'));
    int totalBuyerValue =
        Utils.safeInt(element.getAttribute('totalBuyerValue'));
    int totalBuyerFreq = Utils.safeInt(element.getAttribute('totalBuyerFreq'));
    int totalBuyerVol = Utils.safeInt(element.getAttribute('totalBuyerVol'));
    int totalSellerValue =
        Utils.safeInt(element.getAttribute('totalSellerValue'));
    int totalSellerFreq =
        Utils.safeInt(element.getAttribute('totalSellerFreq'));
    int totalSellerVol = Utils.safeInt(element.getAttribute('totalSellerVol'));
    //                     0             1           2         3                 4
    //tradeBookString = tb.price+"_"+tb.freq+"_"+tb.val+"_"+tb.volume+"_"+tb.getBuyerFreq()
    //               5                     6                       7                     8                       9
    // +"_"+tb.getBuyerVol()+"_"+tb.getSellerFreq()+"_"+tb.getSellerVol()+"_"+tb.getBuyerValue()+"_"+tb.getSellerValue();

    List<TradeBookRow> listTradeBookRows =
        List<TradeBookRow>.empty(growable: true);
    if (!StringUtils.isEmtpy(tradeBookString)) {
      List<String> rows = tradeBookString.split('*');
      if (rows != null && rows.isNotEmpty) {
        rows.forEach((row) {
          List<String> data = row.split('_');
          if (data != null && data.isNotEmpty && data.length >= 10) {
            int price = Utils.safeInt(data.elementAt(0));
            int freq = Utils.safeInt(data.elementAt(1));
            int val = Utils.safeInt(data.elementAt(2));
            int volume = Utils.safeInt(data.elementAt(3));
            int buyerFreq = Utils.safeInt(data.elementAt(4));
            int buyerVolume = Utils.safeInt(data.elementAt(5));
            int sellerFreq = Utils.safeInt(data.elementAt(6));
            int sellerVolume = Utils.safeInt(data.elementAt(7));
            int buyerValue = Utils.safeInt(data.elementAt(7));
            int sellerValue = Utils.safeInt(data.elementAt(9));

            TradeBookRow tb = TradeBookRow(
                price,
                volume,
                val,
                freq,
                buyerVolume,
                buyerValue,
                buyerFreq,
                sellerVolume,
                sellerValue,
                sellerFreq);
            //print(tb);
            listTradeBookRows.add(tb);
          }
        });
      }
    }
    return TradeBook(code, board,
        time: time,
        tradeBookString: tradeBookString,
        totalBuyerValue: totalBuyerValue,
        totalBuyerFreq: totalBuyerFreq,
        totalBuyerVol: totalBuyerVol,
        totalSellerValue: totalSellerValue,
        totalSellerFreq: totalSellerFreq,
        totalSellerVol: totalSellerVol,
        listTradeBookRows: listTradeBookRows);
  }

  void copyValueFrom(TradeBook newValue) {
    if (newValue != null) {
      this.loaded = true;
      this.time = newValue.time;
      this.code = newValue.code;
      this.board = newValue.board;
      this.tradeBookString = newValue.tradeBookString;
      this.totalBuyerValue = newValue.totalBuyerValue;
      this.totalBuyerFreq = newValue.totalBuyerFreq;
      this.totalBuyerVol = newValue.totalBuyerVol;
      this.totalSellerValue = newValue.totalSellerValue;
      this.totalSellerFreq = newValue.totalSellerFreq;
      this.totalSellerVol = newValue.totalSellerVol;
      this.listTradeBookRows = newValue.listTradeBookRows;
    } else {
      this.time = '';
      this.code = '';
      this.board = '';
      this.tradeBookString = '';
      this.totalBuyerValue = 0;
      this.totalBuyerFreq = 0;
      this.totalBuyerVol = 0;
      this.totalSellerValue = 0;
      this.totalSellerFreq = 0;
      this.totalSellerVol = 0;
      this.listTradeBookRows?.clear();
    }
  }

  @override
  String toString() {
    return '[TradeBook --> $time, $code, $board, $totalBuyerValue, $totalBuyerFreq, $totalBuyerVol, $totalSellerValue, $totalSellerFreq, $totalSellerVol, $tradeBookString]';
  }
}

class TradeBookRow {
  int price;
  int volume;
  int val;
  int freq;
  int buyerVolume;
  int buyerValue;
  int buyerFreq;
  int sellerVolume;
  int sellerValue;
  int sellerFreq;

  TradeBookRow(
      this.price,
      this.volume,
      this.val,
      this.freq,
      this.buyerVolume,
      this.buyerValue,
      this.buyerFreq,
      this.sellerVolume,
      this.sellerValue,
      this.sellerFreq);

  @override
  String toString() {
    return '[TradeBookRow --> $price, $volume, $val, $freq, $buyerVolume, $buyerValue, $buyerFreq, $sellerVolume, $sellerValue, $sellerFreq]';
  }
}

class OrderBook {
  /*
  <ORDERBOOK>
    <a start="1" end="1"
    time="10:44:47" stockCode="ASII" boardCode="RG" totalBid="10154300" totalOffer="20676800"
    bid_0="5575" bidLot_0="2335000" offer_0="5600" offerLot_0="5880400" bid_1="5550" bidLot_1="2518500"
    offer_1="5625" offerLot_1="1739000" bid_2="5525" bidLot_2="1410200" offer_2="5650" offerLot_2="2840000"
    bid_3="5500" bidLot_3="842600" offer_3="5675" offerLot_3="1113400" bid_4="5475" bidLot_4="874700"
    offer_4="5700" offerLot_4="3214300" bid_5="5450" bidLot_5="909100" offer_5="5725" offerLot_5="838200"
    bid_6="5425" bidLot_6="450200" offer_6="5750" offerLot_6="1666000" bid_7="5400" bidLot_7="409200" offer_7="5775"
    offerLot_7="999500" bid_8="5375" bidLot_8="132300" offer_8="5800" offerLot_8="2065300" bid_9="5350" bidLot_9="272500"
    offer_9="5825" offerLot_9="320700" bidQueue_0="34" bidQueue_1="187" bidQueue_2="118" bidQueue_3="233" bidQueue_4="134"
    bidQueue_5="212" bidQueue_6="65" bidQueue_7="123" bidQueue_8="45" bidQueue_9="83" offerQueue_0="1286" offerQueue_1="352"
    offerQueue_2="503" offerQueue_3="241" offerQueue_4="625" offerQueue_5="154" offerQueue_6="287" offerQueue_7="138"
    offerQueue_8="398" offerQueue_9="77"/>
</ORDERBOOK>
  */
  String time = '';
  String code = '';
  String board = '';

  int totalBid = 0;
  int totalOffer = 0;

  List bids = List.empty(growable: true);
  List bidsLot = List.empty(growable: true);
  List bidsQueue = List.empty(growable: true);
  List offers = List.empty(growable: true);
  List offersLot = List.empty(growable: true);
  List offersQueue = List.empty(growable: true);

  List bidsText = List.empty(growable: true);
  List bidsLotText = List.empty(growable: true);
  List bidsQueueText = List.empty(growable: true);
  List offersText = List.empty(growable: true);
  List offersLotText = List.empty(growable: true);
  List offersQueueText = List.empty(growable: true);

  static OrderBook createBasic() {
    OrderBook ob = new OrderBook('', '');
    ob.time = '';
    ob.totalBid = 0;
    ob.totalOffer = 0;
    ob.bids = List.empty(growable: true);
    ob.bidsLot = List.empty(growable: true);
    ob.bidsQueue = List.empty(growable: true);
    ob.offers = List.empty(growable: true);
    ob.offersLot = List.empty(growable: true);
    ob.offersQueue = List.empty(growable: true);
    ob.bidsText = List.empty(growable: true);
    ob.bidsLotText = List.empty(growable: true);
    ob.bidsQueueText = List.empty(growable: true);
    ob.offersText = List.empty(growable: true);
    ob.offersLotText = List.empty(growable: true);
    ob.offersQueueText = List.empty(growable: true);

    return ob;
  }

  OrderBook(this.code, this.board,
      {this.time,
      this.totalBid,
      this.totalOffer,
      this.bids,
      this.bidsLot,
      this.bidsQueue,
      this.offers,
      this.offersLot,
      this.offersQueue});

  int totalVolumeShowedBid = 0;
  int totalVolumeShowedOffer = 0;

  bool isValid() {
    return !StringUtils.isEmtpy(code) && !StringUtils.isEmtpy(board);
  }

  int countBids() {
    return bids == null ? 0 : bids.length;
  }

  int countOffers() {
    return offers == null ? 0 : offers.length;
  }

  int countBidsLot() {
    return bidsLot == null ? 0 : bidsLot.length;
  }

  int countOffersLot() {
    return offersLotText == null ? 0 : offersLotText.length;
  }

  int countBidsQueue() {
    return bidsQueue == null ? 0 : bidsQueue.length;
  }

  int countOffersQueue() {
    return offersQueue == null ? 0 : offersQueue.length;
  }

  void generateDataForUI(int maxShowLevel, {BuildContext context}) {
    bidsText.clear();
    bidsLotText.clear();
    bidsQueueText.clear();
    offersText.clear();
    offersLotText.clear();
    offersQueueText.clear();

    // int maxLoop = max(bids.length, bidsLot.length);
    // maxLoop = max(maxLoop, bidsQueue.length);
    // maxLoop = max(maxLoop, offers.length);
    // maxLoop = max(maxLoop, offersLot.length);
    // maxLoop = max(maxLoop, offersQueue.length);

    int maxLoop = max(countBids(), countBidsLot());
    maxLoop = max(maxLoop, countBidsQueue());
    maxLoop = max(maxLoop, countOffers());
    maxLoop = max(maxLoop, countOffersLot());
    maxLoop = max(maxLoop, countOffersQueue());

    print('orderbook generateDataForUI maxLoop : $maxLoop');
    for (int i = 0; i < maxLoop; i++) {
      bool showBid = bids.elementAt(i) > 0;
      bool showOffer = offers.elementAt(i) > 0;

      print(
          'orderbook generateDataForUI [$i] showBid : $showBid  showOffer : $showOffer');

      String bidQueueText;
      String bidLotText;
      String bidPriceText;

      String offerQueueText;
      String offerLotText;
      String offerPriceText;

      if (showBid) {
        bidQueueText = InvestrendTheme.formatComma(bidsQueue.elementAt(i));
        bidLotText = InvestrendTheme.formatComma(bidLot(i));
        bidPriceText = InvestrendTheme.formatPrice(bids.elementAt(i));
      } else {
        bidQueueText = ' ';
        bidLotText = ' ';
        bidPriceText = ' ';
      }

      if (showOffer) {
        offerQueueText = InvestrendTheme.formatComma(offersQueue.elementAt(i));
        offerLotText = InvestrendTheme.formatComma(offerLot(i));
        offerPriceText = InvestrendTheme.formatPrice(offers.elementAt(i));
      } else {
        offerQueueText = ' ';
        offerLotText = ' ';
        offerPriceText = ' ';
      }

      if (i < maxShowLevel) {
        totalVolumeShowedBid += bidLot(i);
        totalVolumeShowedOffer += offerLot(i);
      }

      bidsText.insert(i, bidPriceText);
      bidsLotText.insert(i, bidLotText);
      bidsQueueText.insert(i, bidQueueText);
      offersText.insert(i, offerPriceText);
      offersLotText.insert(i, offerLotText);
      offersQueueText.insert(i, offerQueueText);
    }
  }

  void copyValueFrom(OrderBook newValue) {
    if (newValue != null) {
      this.time = newValue.time;
      this.code = newValue.code;
      this.board = newValue.board;
      this.totalBid = newValue.totalBid;
      this.totalOffer = newValue.totalOffer;

      this.bids = newValue.bids;
      this.bidsLot = newValue.bidsLot;
      this.bidsQueue = newValue.bidsQueue;

      this.offers = newValue.offers;
      this.offersLot = newValue.offersLot;
      this.offersQueue = newValue.offersQueue;
      this.generateDataForUI(10);
    } else {
      this.time = '';
      this.code = '';
      this.board = '';
      this.totalBid = 0;
      this.totalOffer = 0;

      this.bids?.clear();
      this.bidsLot?.clear();
      this.bidsQueue?.clear();

      this.offers?.clear();
      this.offersLot?.clear();
      this.offersQueue?.clear();

      this.bidsText?.clear();
      this.bidsLotText?.clear();
      this.bidsQueueText?.clear();
      this.offersText?.clear();
      this.offersLotText?.clear();
      this.offersQueueText?.clear();
    }
  }

  int bidLot(int index) {
    int sharePerLot = 100;
    if (bidsLot != null && index < bidsLot.length) {
      num vol = bidsLot.elementAt(index);
      int result = vol.toInt() ~/ sharePerLot;
      return result;
    }
    return 0;
  }

  int bidVol(int index) {
    if (bidsLot != null && index < bidsLot.length) {
      return bidsLot.elementAt(index);
    }
    return 0;
  }

  int offerLot(int index) {
    if (offersLot != null && index < offersLot.length) {
      num vol = offersLot.elementAt(index);
      return vol ~/ 100;
    }
    return 0;
  }

  int offerVol(int index) {
    if (offersLot != null && index < offersLot.length) {
      return offersLot.elementAt(index);
    }
    return 0;
  }

  /*
  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr, )
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
  double useFontSize(BuildContext context, double fontSize, double widthSection, OrderBook value, int maxShowLevel){
    print('.useFontSize try fontSize  : $fontSize');
    TextStyle small_w400 = InvestrendTheme.of(context).small_w400.copyWith(fontSize: fontSize);
    TextStyle small_w500 = InvestrendTheme.of(context).small_w500.copyWith(fontSize: fontSize);

    for (int index = 0; index < maxShowLevel; index++) {

      // String bidQueue = '100,000';
      // String bidLot = '1,000,000';
      // String bidPrice = '200,000';
      //
      // String offerQueue = InvestrendTheme.formatComma(value.offersQueue.elementAt(index));
      // String offerLot = InvestrendTheme.formatComma(value.offerLot(index));
      // String offerPrice = '1,780';

      String bidQueue = value.bidsQueueText.elementAt(index);
      String bidLot = value.bidsLotText.elementAt(index);
      String bidPrice = value.bidsText.elementAt(index);

      String offerQueue = value.offersQueueText.elementAt(index);
      String offerLot = value.offersLotText.elementAt(index);
      String offerPrice = value.offersText.elementAt(index);


      double widthSectionTextLeft = _textSize(bidQueue, small_w400).width + _textSize(bidLot, small_w400).width + _textSize(bidPrice, small_w500).width;
      double widthSectionTextRight = _textSize(offerPrice, small_w500).width + _textSize(offerLot, small_w400).width + _textSize(offerQueue, small_w400).width;


      bool reduceFontSize = widthSectionTextLeft > widthSection || widthSectionTextRight > widthSection;
      print(' useFontSize widthSection  : $widthSection   widthSectionTextLeft : $widthSectionTextLeft   widthSectionTextRight : $widthSectionTextRight  reduceFontSize : $reduceFontSize');
      if(reduceFontSize){
        fontSize = useFontSize(context, fontSize - 2, widthSection, value, maxShowLevel);
        break;
      }
    }
    print('.useFontSize Final fontSize  : $fontSize');
    return fontSize;
  }
  */

  factory OrderBook.fromStreaming(List<String> data) {
    final String HEADER = data[0];
    final String type = data[1];
    final String start = data[2];
    final String end = data[3];
    final String code = data[4];
    final String board = data[5];
    final String time = data[6];
    final String bidText = data[7];
    final String bidRaw = data[8];
    final String offerText = data[9];
    final String offerRaw = data[10];
    final int totalBid = Utils.safeInt(data[11]);
    final int totalOffer = Utils.safeInt(data[12]);
    /*
    flutter: [0] = III
    flutter: [1] = N
    flutter: [2] = 0
    flutter: [3] = 0
    flutter: [4] = BBCA
    flutter: [5] = RG
    flutter: [6] = 15:14:56
    flutter: [7] = BID
    flutter: [8] = 36425=15100=24*36400=41500=46*36375=76200=56*36350=20700=18*36325=62500=29*36300=60000=95*36275=10900=19*36250=12000=18*36225=4300=16*36200=55600=51
    flutter: [9] = OFFER
    flutter: [10] = 36450=878300=628*36475=366200=276*36500=2475800=1499*36525=115900=94*36550=77200=128*36575=46800=44*36600=349100=322*36625=16600=38*36650=129300=97*36675=22100=41
    flutter: [11] = 358800
    flutter: [12] = 4477300
    */
    Utils.printList(data);
    //String bidOffer	 = bidText+"|"+bidRaw+"|"+offerText+"|"+offerRaw+"|"+totalBid+"|"+totalOffer;

    //[III, N, 0, 0, BBCA, RG, 15:10:56,
    // BID, 36425=16000=25*36400=41500=46*36375=76200=56*36350=22700=19*36325=62500=29*36300=60000=95*36275=10900=19*36250=12000=18*36225=4300=16*36200=55600=51,
    // OFFER, 36450=835600=594*36475=366200=276*36500=2476800=1503*36525=115900=94*36550=77200=128*36575=46800=44*36600=349300=324*36625=16600=38*36650=129300=97*36675=22100=41,
    // 361700, 4435800]

    var bids = List.empty(growable: true);
    var bidsLot = List.empty(growable: true);
    var bidsQueue = List.empty(growable: true);
    var offers = List.empty(growable: true);
    var offersLot = List.empty(growable: true);
    var offersQueue = List.empty(growable: true);

    List<String> bidsList = bidRaw.split('*');
    List<String> offersList = offerRaw.split('*');

    for (int i = 0; i < 10; i++) {
      int bid = 0;
      int bidLot = 0;
      int bidQueue = 0;
      int offer = 0;
      int offerLot = 0;
      int offerQueue = 0;

      if (bidsList != null && i < bidsList.length) {
        List<String> bidsData = bidsList.elementAt(i).split('=');
        if (bidsData.length >= 3) {
          bid = Utils.safeInt(bidsData.elementAt(0));
          bidLot = Utils.safeInt(bidsData.elementAt(1));
          bidQueue = Utils.safeInt(bidsData.elementAt(2));
        }
      }

      if (offersList != null && i < offersList.length) {
        List<String> offersData = offersList.elementAt(i).split('=');
        if (offersData.length >= 3) {
          offer = Utils.safeInt(offersData.elementAt(0));
          offerLot = Utils.safeInt(offersData.elementAt(1));
          offerQueue = Utils.safeInt(offersData.elementAt(2));
        }
      }

      // int bid = Utils.safeInt(parsedJson['bid_' + i.toString()]);
      // int bidLot = Utils.safeInt(parsedJson['bidLot_' + i.toString()]);
      // int bidQueue = Utils.safeInt(parsedJson['bidQueue_' + i.toString()]);
      // int offer = Utils.safeInt(parsedJson['offer_' + i.toString()]);
      // int offerLot = Utils.safeInt(parsedJson['offerLot_' + i.toString()]);
      // int offerQueue = Utils.safeInt(parsedJson['offerQueue_' + i.toString()]);

      bids.add(bid);
      bidsLot.add(bidLot);
      bidsQueue.add(bidQueue);
      offers.add(offer);
      offersLot.add(offerLot);
      offersQueue.add(offerQueue);
    }
    return OrderBook(code, board,
        time: time,
        totalBid: totalBid,
        totalOffer: totalOffer,
        bids: bids,
        bidsLot: bidsLot,
        bidsQueue: bidsQueue,
        offers: offers,
        offersLot: offersLot,
        offersQueue: offersQueue);
  }
  factory OrderBook.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['stockCode']);
    String time = StringUtils.noNullString(parsedJson['time']);
    //String code = StringUtils.noNullString(parsedJson['stockCode']);
    String board = StringUtils.noNullString(parsedJson['boardCode']);

    int totalBid = Utils.safeInt(parsedJson['totalBid']);
    int totalOffer = Utils.safeInt(parsedJson['totalOffer']);

    var bids = List.empty(growable: true);
    var bidsLot = List.empty(growable: true);
    var bidsQueue = List.empty(growable: true);
    var offers = List.empty(growable: true);
    var offersLot = List.empty(growable: true);
    var offersQueue = List.empty(growable: true);

    for (int i = 0; i < 10; i++) {
      int bid = Utils.safeInt(parsedJson['bid_' + i.toString()]);
      int bidLot = Utils.safeInt(parsedJson['bidLot_' + i.toString()]);
      int bidQueue = Utils.safeInt(parsedJson['bidQueue_' + i.toString()]);
      int offer = Utils.safeInt(parsedJson['offer_' + i.toString()]);
      int offerLot = Utils.safeInt(parsedJson['offerLot_' + i.toString()]);
      int offerQueue = Utils.safeInt(parsedJson['offerQueue_' + i.toString()]);

      bids.add(bid);
      bidsLot.add(bidLot);
      bidsQueue.add(bidQueue);
      offers.add(offer);
      offersLot.add(offerLot);
      offersQueue.add(offerQueue);
    }

    return OrderBook(code, board,
        time: time,
        totalBid: totalBid,
        totalOffer: totalOffer,
        bids: bids,
        bidsLot: bidsLot,
        bidsQueue: bidsQueue,
        offers: offers,
        offersLot: offersLot,
        offersQueue: offersQueue);
  }

  factory OrderBook.fromXml(XmlElement element) {
    String time = StringUtils.noNullString(element.getAttribute('time'));
    String code = StringUtils.noNullString(element.getAttribute('stockCode'));
    String board = StringUtils.noNullString(element.getAttribute('boardCode'));

    int totalBid = Utils.safeInt(element.getAttribute('totalBid'));
    int totalOffer = Utils.safeInt(element.getAttribute('totalOffer'));

    var bids = List.empty(growable: true);
    var bidsLot = List.empty(growable: true);
    var bidsQueue = List.empty(growable: true);
    var offers = List.empty(growable: true);
    var offersLot = List.empty(growable: true);
    var offersQueue = List.empty(growable: true);
    // int countBid = 0;
    // int countOffer = 0;
    for (int i = 0; i < 10; i++) {
      int bid = Utils.safeInt(element.getAttribute('bid_' + i.toString()));
      int bidLot =
          Utils.safeInt(element.getAttribute('bidLot_' + i.toString()));
      int bidQueue =
          Utils.safeInt(element.getAttribute('bidQueue_' + i.toString()));
      int offer = Utils.safeInt(element.getAttribute('offer_' + i.toString()));
      int offerLot =
          Utils.safeInt(element.getAttribute('offerLot_' + i.toString()));
      int offerQueue =
          Utils.safeInt(element.getAttribute('offerQueue_' + i.toString()));
      // if(bid > 0 && bidLot > 0){
      //   countBid++;
      // }
      // if(offer > 0 && offerLot > 0){
      //   countOffer++;
      // }
      bids.add(bid);
      bidsLot.add(bidLot);
      bidsQueue.add(bidQueue);
      offers.add(offer);
      offersLot.add(offerLot);
      offersQueue.add(offerQueue);
    }

    return OrderBook(code, board,
        time: time,
        totalBid: totalBid,
        totalOffer: totalOffer,
        bids: bids,
        bidsLot: bidsLot,
        bidsQueue: bidsQueue,
        offers: offers,
        offersLot: offersLot,
        offersQueue: offersQueue);
  }

  @override
  String toString() {
    return '[OrderBook --> $time, $code, $board, $totalBid, $totalOffer, ' +
        bids.length.toString() +
        ', ' +
        bidsLot.length.toString() +
        ', ' +
        bidsQueue.length.toString() +
        ', ' +
        offers.length.toString() +
        ', ' +
        offersLot.length.toString() +
        ', ' +
        offersQueue.length.toString() +
        ']';
  }
}

class People extends SerializeableSSI {
  String name;
  String username;
  String urlTumbnail;

  People(this.name, this.username, this.urlTumbnail);

  factory People.fromPlain(String data) {
    List<String> datas = data.split('|');
    if (datas != null && datas.isNotEmpty && datas.length >= 3) {
      String name = StringUtils.noNullString(datas.elementAt(0));
      String username = StringUtils.noNullString(datas.elementAt(1));
      String urlTumbnail = StringUtils.noNullString(datas.elementAt(2));

      return People(name, username, urlTumbnail);
    }

    return null;
  }

  @override
  String asPlain() {
    String plain = name;
    plain += '|' + username;
    plain += '|' + urlTumbnail;
    return plain;
  }

  @override
  String identity() {
    return 'People';
  }
}
/*
class MutationRDN {

  {
  "flag": "D",
  "fundtype": "Deposit",
  "accountcode": "E108",
  "amount": 101.69,
  "transferno": "",
  "bank": "MANDIRI",
  "account": "",
  "date": "30-09-2021"
  },


  String flag;
  String fundtype;
  String accountcode;
  double amount;
  String transferno;
  String bank;
  String account;
  String date;

  MutationRDN(this.flag, this.fundtype, this.accountcode, this.amount, this.transferno, this.bank, this.account, this.date);

  factory MutationRDN.fromJson(Map<String, dynamic> parsedJson) {
    print(parsedJson);

    String flag = StringUtils.noNullString(parsedJson['flag']);
    String fundtype = StringUtils.noNullString(parsedJson['fundtype']);
    String accountcode = StringUtils.noNullString(parsedJson['accountcode']);
    double amount  = Utils.safeDouble(parsedJson['amount']);
    String transferno = StringUtils.noNullString(parsedJson['transferno']);
    String bank = StringUtils.noNullString(parsedJson['bank']);
    String account = StringUtils.noNullString(parsedJson['account']);
    String date = StringUtils.noNullString(parsedJson['date']);


    return MutationRDN(flag, fundtype, accountcode, amount, transferno, bank, account, date);
  }

  @override
  String toString() {
    return 'MutationRDN {flag: $flag, fundtype: $fundtype, accountcode: $accountcode, amount: $amount, transferno: $transferno, bank: $bank, account: $account, date: $date}';
  }
}
*/

class OrderQueue {
  /*
  {
  "#": 1,
  "time": "09:00:17",
  "order": "272703",
  "linked_time": "",
  "linked": "0",
  "broker": "CC",
  "price": "66",
  "volume": "2000000",
  "remaining": "1418200",
  "queue": 1418200,
  "type": "D"
  },
  */
  int no;
  String time;
  String order;
  String linked_time;
  String linked;
  String broker;
  int price;
  int volume;
  int remaining;
  int queue;
  String type;
  int lot() {
    if (volume > 0) {
      return volume ~/ 100;
    } else {
      return 0;
    }
  }

  String status() {
    String status = '';
    if (remaining == volume) {
      status = "Open";
    } else {
      status = "Partial";
    }
    return status;
  }

  int remaining_lot() {
    if (remaining > 0) {
      return remaining ~/ 100;
    } else {
      return 0;
    }
  }

  bool brokerIsEmpty() {
    return StringUtils.isEmtpy(broker) ||
        StringUtils.equalsIgnoreCase(broker, '-');
  }

  OrderQueue(
      this.no,
      this.time,
      this.order,
      this.linked_time,
      this.linked,
      this.broker,
      this.price,
      this.volume,
      this.remaining,
      this.queue,
      this.type);

  factory OrderQueue.fromJson(Map<String, dynamic> parsedJson) {
    print(parsedJson);
    int no = Utils.safeInt(parsedJson['#']);
    String time = StringUtils.noNullString(parsedJson['time']);
    String order = StringUtils.noNullString(parsedJson['order']);
    String linked_time = StringUtils.noNullString(parsedJson['linked_time']);
    String linked = StringUtils.noNullString(parsedJson['linked']);
    String broker = StringUtils.noNullString(parsedJson['broker']);
    int price = Utils.safeInt(parsedJson['price']);
    int volume = Utils.safeInt(parsedJson['volume']);
    int remaining = Utils.safeInt(parsedJson['remaining']);
    int queue = Utils.safeInt(parsedJson['queue']);
    String type = StringUtils.noNullString(parsedJson['type']);

    if (StringUtils.isEmtpy(broker)) {
      broker = '-';
    }
    if (StringUtils.isEmtpy(type)) {
      type = '-';
    }
    return OrderQueue(no, time, order, linked_time, linked, broker, price,
        volume, remaining, queue, type);
  }

  bool isValid() {
    return !StringUtils.isEmtpy(order);
  }

  @override
  String toString() {
    return 'OrderQueue{time: $time, order: $order, linked_time: $linked_time, linked: $linked, broker: $broker, price: $price, volume: $volume, remaining: $remaining, queue: $queue, type: $type}';
  }
}

class TopStock {
  /*
  <TOPSTOCK data_type="INITIAL" data_max_update="2021-08-04 13:56:37" type="GAINERS" date="2021-08-04" time="13:56:40" limit="2" syariah="false" warant="true" right="true">
  <a start="1" end="2" code="CPRI-W" close="16" change="6" percentChange="60" open="11" hi="19" low="11" prev="10" val="27856300" vol="1681800" freq="151" marketCap="1093399920" marketCapFreeFloat="0" return52W="23.07" returnYTD="45.45" returnMTD="14.28"/>
  <a start="2" end="2" code="INPC-W" close="93" change="22" percentChange="30.98" open="72" hi="95" low="72" prev="71" val="5449423600" vol="65765000" freq="2130" marketCap="402368832963" marketCapFreeFloat="0" return52W="3000" returnYTD="3000" returnMTD="47.61"/>
  </TOPSTOCK>
  */
  String code;
  int close;
  int change;
  double percentChange;
  int open;
  int hi;
  int low;
  int prev;
  int val;
  int vol;
  int freq;
  int marketCap;
  int marketCapFreeFloat;
  double return52W;
  double returnYTD;
  double returnMTD;

  TopStock(
      this.code,
      this.close,
      this.change,
      this.percentChange,
      this.open,
      this.hi,
      this.low,
      this.prev,
      this.val,
      this.vol,
      this.freq,
      this.marketCap,
      this.marketCapFreeFloat,
      this.return52W,
      this.returnYTD,
      this.returnMTD);

  factory TopStock.fromJson(Map<String, dynamic> parsedJson) {
    String code = StringUtils.noNullString(parsedJson['code']);

    int close = Utils.safeInt(parsedJson['close']);
    int change = Utils.safeInt(parsedJson['change']);
    double percentChange = Utils.safeDouble(parsedJson['percentChange']);
    int open = Utils.safeInt(parsedJson['open']);
    int hi = Utils.safeInt(parsedJson['hi']);
    int low = Utils.safeInt(parsedJson['low']);
    int prev = Utils.safeInt(parsedJson['prev']);
    int val = Utils.safeInt(parsedJson['val']);
    int vol = Utils.safeInt(parsedJson['vol']);
    int freq = Utils.safeInt(parsedJson['freq']);
    int marketCap = Utils.safeInt(parsedJson['marketCap']);
    int marketCapFreeFloat = Utils.safeInt(parsedJson['marketCapFreeFloat']);

    double return52W = Utils.safeDouble(parsedJson['return52W']);
    double returnYTD = Utils.safeDouble(parsedJson['returnYTD']);
    double returnMTD = Utils.safeDouble(parsedJson['returnMTD']);

    return TopStock(
        code,
        close,
        change,
        percentChange,
        open,
        hi,
        low,
        prev,
        val,
        vol,
        freq,
        marketCap,
        marketCapFreeFloat,
        return52W,
        returnYTD,
        returnMTD);
  }

  factory TopStock.fromXml(XmlElement element) {
    String code = StringUtils.noNullString(element.getAttribute('code'));
    int close = Utils.safeInt(element.getAttribute('close'));
    int change = Utils.safeInt(element.getAttribute('change'));
    double percentChange =
        Utils.safeDouble(element.getAttribute('percentChange'));
    int open = Utils.safeInt(element.getAttribute('open'));
    int hi = Utils.safeInt(element.getAttribute('hi'));
    int low = Utils.safeInt(element.getAttribute('low'));
    int prev = Utils.safeInt(element.getAttribute('prev'));
    int val = Utils.safeInt(element.getAttribute('val'));
    int vol = Utils.safeInt(element.getAttribute('vol'));
    int freq = Utils.safeInt(element.getAttribute('freq'));
    int marketCap = Utils.safeInt(element.getAttribute('marketCap'));
    int marketCapFreeFloat =
        Utils.safeInt(element.getAttribute('marketCapFreeFloat'));

    double return52W = Utils.safeDouble(element.getAttribute('return52W'));
    double returnYTD = Utils.safeDouble(element.getAttribute('returnYTD'));
    double returnMTD = Utils.safeDouble(element.getAttribute('returnMTD'));

    return TopStock(
        code,
        close,
        change,
        percentChange,
        open,
        hi,
        low,
        prev,
        val,
        vol,
        freq,
        marketCap,
        marketCapFreeFloat,
        return52W,
        returnYTD,
        returnMTD);
  }

  bool isValid() {
    return !StringUtils.isEmtpy(code);
  }

  @override
  String toString() {
    return '[TopStock --> code : $code,  close : $close,  change : $change,  percentChange : $percentChange,  open : $open,  hi : $hi,  low : $low, prev : $prev,  val : $val, vol : $vol,  freq : $freq,  marketCap : $marketCap, marketCapFreeFloat : $marketCapFreeFloat, return52W : $return52W,  returnYTD : $returnYTD,  returnMTD : $returnMTD]';
  }
}

class StockSummary {
  /*
  <SUMMARY>
    <a start="1" end="1"
    tradeDate="2021-04-28" tradeTime="11:26:14" stockCode="AALI" boardCode="RG"
    sector="D232" prev="9350" hi="9525" low="9325" close="9350" hi52W="13350"
    low52W="5650" start52W="2020-04-28" end52W="2021-04-28" close52W="5975"
    return52W="68.46" change="0" percentChange="0.0" volume="655600" value="6150097500"
    freq="585" individualIndex="7595704" availableForForeigners="1924688333" open="9500"
    bestBidPrice="9325" bestBidVolume="11000" bestOfferPrice="9350" bestOfferVolume="10400"
    corporateAction="XD Ex Dividend" marketCap="17995835913550" averagePrice="9381.0" hiYTD="13350"
    lowYTD="9075" returnYTD="-24.13" marketCapFreeFloat="0" hiMTD="10450" lowMTD="9075" returnMTD="-6.73"
    />
  </SUMMARY>
  */
  String tradeDate;
  String tradeTime;
  String code;
  String board;
  String sector;
  int prev;
  int hi;
  int low;
  int close;
  int hi52W;
  int low52W;
  //String start52W;
  //String end52W;
  //int close52W;
  double return52W;
  double change;
  double percentChange;
  int volume;
  int value;
  int freq;
  int individualIndex;
  int availableForForeigners;
  int open;
  int bestBidPrice;
  int bestBidVolume;
  int bestOfferPrice;
  int bestOfferVolume;
  String corporateAction;
  int marketCap;
  double averagePrice;
  int hiYTD;
  int lowYTD;
  double returnYTD;
  int marketCapFreeFloat;
  int hiMTD;
  int lowMTD;
  double returnMTD;

  int iep;
  int iev;

  String PE = '-';
  String PBV = '-';
  String ROE = '-';

  Color peColor = InvestrendTheme.yellowText;
  Color pbvColor = InvestrendTheme.yellowText;
  Color roeColor = InvestrendTheme.yellowText;

  Color openColor() {
    return InvestrendTheme.priceTextColor(open, prev: prev);
  }

  Color hiColor() {
    return InvestrendTheme.priceTextColor(hi, prev: prev);
  }

  Color lowColor() {
    return InvestrendTheme.priceTextColor(low, prev: prev);
  }

  Color closeColor() {
    return InvestrendTheme.priceTextColor(close, prev: prev);
  }

  Color averagePriceColor() {
    return InvestrendTheme.changeTextColor(averagePrice, prev: prev.toDouble());
  }

  Color iepColor() {
    if (iep == 0) {
      return InvestrendTheme.yellowText;
    }
    return InvestrendTheme.changeTextColor(iep.toDouble(),
        prev: prev.toDouble());
  }

  void updateCache(BuildContext context, FundamentalCache cache) {
    if (cache != null) {
      print(cache);
      if (cache.last_eps > 0) {
        double pe = close.toDouble() / cache.last_eps;
        PE = InvestrendTheme.formatPriceDouble(pe, showDecimal: true);
        peColor = InvestrendTheme.changeTextColor(pe);
      } else {
        PE = '-';
        peColor = InvestrendTheme.yellowText;
      }
      if (cache.last_bvp > 0) {
        double pbv = close.toDouble() / cache.last_bvp;
        PBV = InvestrendTheme.formatPriceDouble(pbv, showDecimal: true);
        pbvColor = InvestrendTheme.changeTextColor(pbv);
      } else {
        PBV = '-';
        pbvColor = InvestrendTheme.yellowText;
      }

      double roe = cache.last_roe;
      ROE = InvestrendTheme.formatPriceDouble(roe, showDecimal: true);
      roeColor = InvestrendTheme.changeTextColor(roe);
    } else {
      PE = '-';
      PBV = '-';
      ROE = '-';
      peColor = InvestrendTheme.yellowText;
      pbvColor = InvestrendTheme.yellowText;
      roeColor = InvestrendTheme.yellowText;
    }
  }

  StockSummary(this.code, this.board,
      {this.tradeDate,
      this.tradeTime,
      this.sector,
      this.prev,
      this.hi,
      this.low,
      this.close,
      this.hi52W,
      this.low52W,
      //this.start52W,
      //this.end52W,
      //this.close52W,
      this.return52W,
      this.change,
      this.percentChange,
      this.volume,
      this.value,
      this.freq,
      this.individualIndex,
      this.availableForForeigners,
      this.open,
      this.bestBidPrice,
      this.bestBidVolume,
      this.bestOfferPrice,
      this.bestOfferVolume,
      this.corporateAction,
      this.marketCap,
      this.averagePrice,
      this.hiYTD,
      this.lowYTD,
      this.returnYTD,
      this.marketCapFreeFloat,
      this.hiMTD,
      this.lowMTD,
      this.returnMTD,
      this.iep,
      this.iev});

  factory StockSummary.fromStreaming(List<String> data) {
    String HEADER = data[0];
    String TYPE_SUMMARY = data[1];
    String start = data[2];
    String end = data[3];
    String stockCode = data[4];
    String boardCode = data[5];
    String tradeDate = data[6];
    String tradeTime = data[7];
    int prev = Utils.safeInt(data[8]);
    int open = Utils.safeInt(data[9]);
    int hi = Utils.safeInt(data[10]);
    int low = Utils.safeInt(data[11]);
    int close = Utils.safeInt(data[12]);
    double averagePrice = Utils.safeDouble(data[13]);
    double change = Utils.safeDouble(data[14]);
    double percentChange = Utils.safeDouble(data[15]);
    int volume = Utils.safeInt(data[16]);
    int value = Utils.safeInt(data[17]);
    int freq = Utils.safeInt(data[18]);
    int marketCap = Utils.safeInt(data[19]);
    int marketCapFreeFloat = Utils.safeInt(data[20]);
    String sector = data[21];
    int bestBidPrice = Utils.safeInt(data[22]);
    int bestBidVolume = Utils.safeInt(data[23]);
    int bestOfferPrice = Utils.safeInt(data[24]);
    int bestOfferVolume = Utils.safeInt(data[25]);
    int domesticBuyerValue = Utils.safeInt(data[26]);
    int domesticSellerValue = Utils.safeInt(data[27]);
    int foreignBuyerValue = Utils.safeInt(data[28]);
    int foreignSellerValue = Utils.safeInt(data[29]);
    int individualIndex = Utils.safeInt(data[30]);
    int availableForForeigners = Utils.safeInt(data[31]);
    String corporateAction = data[32];
    int hiMTD = Utils.safeInt(data[33]);
    int lowMTD = Utils.safeInt(data[34]);
    double returnMTD = Utils.safeDouble(data[35]);
    int hiYTD = Utils.safeInt(data[36]);
    int lowYTD = Utils.safeInt(data[37]);
    double returnYTD = Utils.safeDouble(data[38]);
    int hi52W = Utils.safeInt(data[39]);
    int low52W = Utils.safeInt(data[40]);
    double return52W = Utils.safeDouble(data[41]);

    int iep = Utils.safeInt(data[42]);
    int iev = Utils.safeInt(data[43]);
    return StockSummary(stockCode, boardCode,
        tradeDate: tradeDate,
        tradeTime: tradeTime,
        sector: sector,
        prev: prev,
        hi: hi,
        low: low,
        close: close,
        hi52W: hi52W,
        low52W: low52W,
        //start52W: start52W,
        //end52W: end52W,
        //close52W: close52W,
        return52W: return52W,
        change: change,
        percentChange: percentChange,
        volume: volume,
        value: value,
        freq: freq,
        individualIndex: individualIndex,
        availableForForeigners: availableForForeigners,
        open: open,
        bestBidPrice: bestBidPrice,
        bestBidVolume: bestBidVolume,
        bestOfferPrice: bestOfferPrice,
        bestOfferVolume: bestOfferVolume,
        corporateAction: corporateAction,
        marketCap: marketCap,
        averagePrice: averagePrice,
        hiYTD: hiYTD,
        lowYTD: lowYTD,
        returnYTD: returnYTD,
        marketCapFreeFloat: marketCapFreeFloat,
        hiMTD: hiMTD,
        lowMTD: lowMTD,
        returnMTD: returnMTD,
        iep: iep,
        iev: iev);
  }
  factory StockSummary.fromJson(Map<String, dynamic> parsedJson) {
    String tradeDate = StringUtils.noNullString(parsedJson['tradeDate']);
    String tradeTime = StringUtils.noNullString(parsedJson['tradeTime']);
    String stockCode = StringUtils.noNullString(parsedJson['stockCode']);
    String boardCode = StringUtils.noNullString(parsedJson['boardCode']);
    String sector = StringUtils.noNullString(parsedJson['sector']);
    int prev = Utils.safeInt(parsedJson['prev']);
    int hi = Utils.safeInt(parsedJson['hi']);
    int low = Utils.safeInt(parsedJson['low']);
    int close = Utils.safeInt(parsedJson['close']);
    int hi52W = Utils.safeInt(parsedJson['hi52W']);
    int low52W = Utils.safeInt(parsedJson['low52W']);
    String start52W = StringUtils.noNullString(parsedJson['start52W']);
    String end52W = StringUtils.noNullString(parsedJson['end52W']);
    int close52W = Utils.safeInt(parsedJson['close52W']);
    double return52W = Utils.safeDouble(parsedJson['return52W']);
    double change = Utils.safeDouble(parsedJson['change']);
    double percentChange = Utils.safeDouble(parsedJson['percentChange']);
    int volume = Utils.safeInt(parsedJson['volume']);
    int value = Utils.safeInt(parsedJson['value']);
    int freq = Utils.safeInt(parsedJson['freq']);
    int individualIndex = Utils.safeInt(parsedJson['individualIndex']);
    int availableForForeigners =
        Utils.safeInt(parsedJson['availableForForeigners']);
    int open = Utils.safeInt(parsedJson['open']);
    int bestBidPrice = Utils.safeInt(parsedJson['bestBidPrice']);
    int bestBidVolume = Utils.safeInt(parsedJson['bestBidVolume']);
    int bestOfferPrice = Utils.safeInt(parsedJson['bestOfferPrice']);
    int bestOfferVolume = Utils.safeInt(parsedJson['bestOfferVolume']);
    String corporateAction =
        StringUtils.noNullString(parsedJson['corporateAction']);
    int marketCap = Utils.safeInt(parsedJson['marketCap']);
    double averagePrice = Utils.safeDouble(parsedJson['averagePrice']);
    int hiYTD = Utils.safeInt(parsedJson['hiYTD']);
    int lowYTD = Utils.safeInt(parsedJson['lowYTD']);
    double returnYTD = Utils.safeDouble(parsedJson['returnYTD']);
    int marketCapFreeFloat = Utils.safeInt(parsedJson['marketCapFreeFloat']);
    int hiMTD = Utils.safeInt(parsedJson['hiMTD']);
    int lowMTD = Utils.safeInt(parsedJson['lowMTD']);
    double returnMTD = Utils.safeDouble(parsedJson['returnMTD']);

    //int iep 	= Utils.safeInt(data[42]);
    //int iev 	= Utils.safeInt(data[43]);
    return StockSummary(stockCode, boardCode,
        tradeDate: tradeDate,
        tradeTime: tradeTime,
        sector: sector,
        prev: prev,
        hi: hi,
        low: low,
        close: close,
        hi52W: hi52W,
        low52W: low52W,
        //start52W: start52W,
        //end52W: end52W,
        //close52W: close52W,
        return52W: return52W,
        change: change,
        percentChange: percentChange,
        volume: volume,
        value: value,
        freq: freq,
        individualIndex: individualIndex,
        availableForForeigners: availableForForeigners,
        open: open,
        bestBidPrice: bestBidPrice,
        bestBidVolume: bestBidVolume,
        bestOfferPrice: bestOfferPrice,
        bestOfferVolume: bestOfferVolume,
        corporateAction: corporateAction,
        marketCap: marketCap,
        averagePrice: averagePrice,
        hiYTD: hiYTD,
        lowYTD: lowYTD,
        returnYTD: returnYTD,
        marketCapFreeFloat: marketCapFreeFloat,
        hiMTD: hiMTD,
        lowMTD: lowMTD,
        returnMTD: returnMTD);
  }

  factory StockSummary.fromXml(XmlElement element) {
    String tradeDate =
        StringUtils.noNullString(element.getAttribute('tradeDate'));
    String tradeTime =
        StringUtils.noNullString(element.getAttribute('tradeTime'));
    String stockCode =
        StringUtils.noNullString(element.getAttribute('stockCode'));
    String boardCode =
        StringUtils.noNullString(element.getAttribute('boardCode'));
    String sector = StringUtils.noNullString(element.getAttribute('sector'));
    int prev = Utils.safeInt(element.getAttribute('prev'));
    int hi = Utils.safeInt(element.getAttribute('hi'));
    int low = Utils.safeInt(element.getAttribute('low'));
    int close = Utils.safeInt(element.getAttribute('close'));
    int hi52W = Utils.safeInt(element.getAttribute('hi52W'));
    int low52W = Utils.safeInt(element.getAttribute('low52W'));
    String start52W =
        StringUtils.noNullString(element.getAttribute('start52W'));
    String end52W = StringUtils.noNullString(element.getAttribute('end52W'));
    int close52W = Utils.safeInt(element.getAttribute('close52W'));
    double return52W = Utils.safeDouble(element.getAttribute('return52W'));
    double change = Utils.safeDouble(element.getAttribute('change'));
    double percentChange =
        Utils.safeDouble(element.getAttribute('percentChange'));
    int volume = Utils.safeInt(element.getAttribute('volume'));
    int value = Utils.safeInt(element.getAttribute('value'));
    int freq = Utils.safeInt(element.getAttribute('freq'));
    int individualIndex =
        Utils.safeInt(element.getAttribute('individualIndex'));
    int availableForForeigners =
        Utils.safeInt(element.getAttribute('availableForForeigners'));
    int open = Utils.safeInt(element.getAttribute('open'));
    int bestBidPrice = Utils.safeInt(element.getAttribute('bestBidPrice'));
    int bestBidVolume = Utils.safeInt(element.getAttribute('bestBidVolume'));
    int bestOfferPrice = Utils.safeInt(element.getAttribute('bestOfferPrice'));
    int bestOfferVolume =
        Utils.safeInt(element.getAttribute('bestOfferVolume'));
    String corporateAction =
        StringUtils.noNullString(element.getAttribute('corporateAction'));
    int marketCap = Utils.safeInt(element.getAttribute('marketCap'));
    double averagePrice =
        Utils.safeDouble(element.getAttribute('averagePrice'));
    int hiYTD = Utils.safeInt(element.getAttribute('hiYTD'));
    int lowYTD = Utils.safeInt(element.getAttribute('lowYTD'));
    double returnYTD = Utils.safeDouble(element.getAttribute('returnYTD'));
    int marketCapFreeFloat =
        Utils.safeInt(element.getAttribute('marketCapFreeFloat'));
    int hiMTD = Utils.safeInt(element.getAttribute('hiMTD'));
    int lowMTD = Utils.safeInt(element.getAttribute('lowMTD'));
    double returnMTD = Utils.safeDouble(element.getAttribute('returnMTD'));

    return StockSummary(stockCode, boardCode,
        tradeDate: tradeDate,
        tradeTime: tradeTime,
        sector: sector,
        prev: prev,
        hi: hi,
        low: low,
        close: close,
        hi52W: hi52W,
        low52W: low52W,
        //start52W: start52W,
        //end52W: end52W,
        //close52W: close52W,
        return52W: return52W,
        change: change,
        percentChange: percentChange,
        volume: volume,
        value: value,
        freq: freq,
        individualIndex: individualIndex,
        availableForForeigners: availableForForeigners,
        open: open,
        bestBidPrice: bestBidPrice,
        bestBidVolume: bestBidVolume,
        bestOfferPrice: bestOfferPrice,
        bestOfferVolume: bestOfferVolume,
        corporateAction: corporateAction,
        marketCap: marketCap,
        averagePrice: averagePrice,
        hiYTD: hiYTD,
        lowYTD: lowYTD,
        returnYTD: returnYTD,
        marketCapFreeFloat: marketCapFreeFloat,
        hiMTD: hiMTD,
        lowMTD: lowMTD,
        returnMTD: returnMTD);
  }

  bool isValid() {
    return !StringUtils.isEmtpy(code) && !StringUtils.isEmtpy(board);
  }

  @override
  String toString() {
    // TODO: implement toString
    return '[Stock Summary --> $tradeDate, $tradeTime, $code, $board, $sector, $prev, $hi, $low, $close, $hi52W, $low52W, $return52W, $change, $percentChange, $volume, $value, $freq, $individualIndex, $availableForForeigners, $open, $bestBidPrice, $bestBidVolume, $bestOfferPrice, $bestOfferVolume, $corporateAction, $marketCap, $averagePrice, $hiYTD, $lowYTD, $returnYTD, $marketCapFreeFloat, $hiMTD, $lowMTD, $returnMTD]';
  }

  void copyValueFrom(StockSummary newValue) {
    if (newValue != null) {
      this.tradeDate = newValue.tradeDate;
      this.tradeTime = newValue.tradeTime;
      this.code = newValue.code;
      this.board = newValue.board;
      this.sector = newValue.sector;
      this.prev = newValue.prev;
      this.hi = newValue.hi;
      this.low = newValue.low;
      this.close = newValue.close;
      this.hi52W = newValue.hi52W;
      this.low52W = newValue.low52W;
      // this.start52W = newValue.start52W;
      // this.end52W = newValue.end52W;
      // this.close52W = newValue.close52W;
      this.return52W = newValue.return52W;
      this.change = newValue.change;
      this.percentChange = newValue.percentChange;
      this.volume = newValue.volume;
      this.value = newValue.value;
      this.freq = newValue.freq;
      this.individualIndex = newValue.individualIndex;
      this.availableForForeigners = newValue.availableForForeigners;
      this.open = newValue.open;
      this.bestBidPrice = newValue.bestBidPrice;
      this.bestBidVolume = newValue.bestBidVolume;
      this.bestOfferPrice = newValue.bestOfferPrice;
      this.bestOfferVolume = newValue.bestOfferVolume;
      this.corporateAction = newValue.corporateAction;
      this.marketCap = newValue.marketCap;
      this.averagePrice = newValue.averagePrice;
      this.hiYTD = newValue.hiYTD;
      this.lowYTD = newValue.lowYTD;
      this.returnYTD = newValue.returnYTD;
      this.marketCapFreeFloat = newValue.marketCapFreeFloat;
      this.hiMTD = newValue.hiMTD;
      this.lowMTD = newValue.lowMTD;
      this.returnMTD = newValue.returnMTD;

      this.iep = newValue.iep;
      this.iev = newValue.iev;

      this.PE = newValue.PE;
      this.PBV = newValue.PBV;
      this.ROE = newValue.ROE;
      this.peColor = newValue.peColor;
      this.pbvColor = newValue.pbvColor;
      this.roeColor = newValue.roeColor;
    } else {
      this.tradeDate = '';
      this.tradeTime = '';
      this.code = '';
      this.board = '';
      this.sector = '';
      this.prev = 0;
      this.hi = 0;
      this.low = 0;
      this.close = 0;
      this.hi52W = 0;
      this.low52W = 0;
      // this.start52W = '';
      // this.end52W = '';
      // this.close52W = 0;
      this.return52W = 0;
      this.change = 0;
      this.percentChange = 0;
      this.volume = 0;
      this.value = 0;
      this.freq = 0;
      this.individualIndex = 0;
      this.availableForForeigners = 0;
      this.open = 0;
      this.bestBidPrice = 0;
      this.bestBidVolume = 0;
      this.bestOfferPrice = 0;
      this.bestOfferVolume = 0;
      this.corporateAction = '';
      this.marketCap = 0;
      this.averagePrice = 0;
      this.hiYTD = 0;
      this.lowYTD = 0;
      this.returnYTD = 0;
      this.marketCapFreeFloat = 0;
      this.hiMTD = 0;
      this.lowMTD = 0;
      this.returnMTD = 0;
      this.iep = 0;
      this.iev = 0;

      this.PE = '-';
      this.PBV = '-';
      this.ROE = '-';
      this.peColor = InvestrendTheme.yellowText;
      this.pbvColor = InvestrendTheme.yellowText;
      this.roeColor = InvestrendTheme.yellowText;
    }
  }
}
