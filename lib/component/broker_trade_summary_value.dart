import 'dart:math';

class BrokerTradeSummaryValue {
  String message = '';
  String brokerCode = '';
  String brokerName = '';
  int brokerType = 0;
  int buyStockSector = 0;
  int sellStockSector = 0;

  /*
  IDXBASIC = 1 UNGU TUA
  IDXCYCLIC = 2 KUNING
  IDXENERGY = 3 HIJAU MUDA
  IDXFINANCE = 4 BIRU TUA
  IDXHEALTH = 5 COKLAT TUA
  IDXINDUSTRY = 6 MERAH
  IDXINFRA = 7 BIRU MUDA
  IDXNONCYC = 8 PINK
  IDXPROPERTY = 9 PUTIH 
  IDXTECHNO = 10 HIJAU TENTARA
  IDXTRANS = 11 COKLAT MUDA
  */

  String buyStock = '';
  String sellStock = '';
  String board = '';
  String dataBy = '';
  String type = '';
  String from = '';
  String to = '';
  bool loaded = false;
  String lastDate = '';

  String bValue;
  String bVolume;
  String bAverage;
  String sValue;
  String sVolume;
  String sAverage;
  String bValueDomestic;
  String bValueForeign;
  String sValueDomestic;
  String sValueForeign;

  BrokerTradeSummaryValue({
    this.message,
    this.brokerCode,
    this.brokerName,
    this.brokerType,
    this.buyStockSector,
    this.sellStockSector,
    this.buyStock,
    this.sellStock,
    this.board,
    this.dataBy,
    this.type,
    this.from,
    this.to,
    this.loaded,
    this.lastDate,
    this.bValue,
    this.bVolume,
    this.bAverage,
    this.sValue,
    this.sVolume,
    this.sAverage,
    this.bValueDomestic,
    this.bValueForeign,
    this.sValueDomestic,
    this.sValueForeign,
  });

  static List<BrokerTradeSummaryValue> listDummy = [
    BrokerTradeSummaryValue(
      buyStockSector: 1,
      buyStock: 'MDKA',
      bAverage: '2,436',
      bValue: '56,5 M',
      sellStockSector: 2,
      sellStock: 'FILM',
      sAverage: '2,473',
      sValue: '43,1 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 8,
      buyStock: 'NSSS',
      bAverage: '158',
      bValue: '24,2 M',
      sellStockSector: 1,
      sellStock: 'NCKL',
      sAverage: '786',
      sValue: '31,7 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 1,
      buyStock: 'ANTM',
      bAverage: '1,942',
      bValue: '6,2 M',
      sellStockSector: 8,
      sellStock: 'NSSS',
      sAverage: '158',
      sValue: '22,5 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 3,
      buyStock: 'RAJA',
      bAverage: '1,206',
      bValue: '5,8 M',
      sellStockSector: 4,
      sellStock: 'BBCA',
      sAverage: '9,314',
      sValue: '14,2 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 6,
      buyStock: 'UNTR',
      bAverage: '22,761',
      bValue: '5 M',
      sellStockSector: 4,
      sellStock: 'LPGI',
      sAverage: '6,400',
      sValue: '8,2 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 10,
      buyStock: 'TRON',
      bAverage: '257',
      bValue: '3,5 M',
      sellStockSector: 8,
      sellStock: 'ICBP',
      sAverage: '11,205',
      sValue: '5,6 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 6,
      buyStock: 'ASII',
      bAverage: '6,511',
      bValue: '2,8 M',
      sellStockSector: 3,
      sellStock: 'RAJA',
      sAverage: '1,187',
      sValue: '3,9 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 3,
      buyStock: 'ADRO',
      bAverage: '2,120',
      bValue: '2,8 M',
      sellStockSector: 5,
      sellStock: 'HEAL',
      sAverage: '1,362',
      sValue: '3,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 1,
      buyStock: 'NCKL',
      bAverage: '791',
      bValue: '2,8 M',
      sellStockSector: 3,
      sellStock: 'BUMI',
      sAverage: '102',
      sValue: '3,3 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 5,
      buyStock: 'PGAS',
      bAverage: '1,424',
      bValue: '2,1 M',
      sellStockSector: 10,
      sellStock: 'TRON',
      sAverage: '258',
      sValue: '3,2 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 1,
      buyStock: 'MDKA',
      bAverage: '2,880',
      bValue: '1,4 M',
      sellStockSector: 9,
      sellStock: 'SAGE',
      sAverage: '130',
      sValue: '2,6 M',
    ),
    //first
    BrokerTradeSummaryValue(
      buyStockSector: 4,
      buyStock: 'BMRI',
      bAverage: '5,150',
      bValue: '1,3 M',
      sellStockSector: 3,
      sellStock: 'MEDC',
      sAverage: '925',
      sValue: '2 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
    BrokerTradeSummaryValue(
      buyStockSector: 9,
      buyStock: 'SAGE',
      bAverage: '131',
      bValue: '1,3 M',
      sellStockSector: 7,
      sellStock: 'PGEO',
      sAverage: '875',
      sValue: '1,8 M',
    ),
  ];
}

class BrokerTradeSummaryCodeValue {
  List<String> idxBasic = [];
  List<String> idxCyclic = [];
  List<String> idxEnergy = [];
  List<String> idxFinance = [];
  List<String> idxHealth = [];
  List<String> idxIndust = [];
  List<String> idxInfras = [];
  List<String> idxNoncyc = [];
  List<String> idxProper = [];
  List<String> idxTechno = [];
  List<String> idxTransp = [];
}

class IdxBasic {
  String codeBasic;

  IdxBasic({this.codeBasic});
}

class BrokerData {
  String brokerCode;
  String brokerName;
  int brokerType;
  double bVal;
  double sVal;
  double nVal;
  double tVal;

  BrokerData({
    this.brokerCode,
    this.brokerName,
    this.brokerType,
    this.bVal,
    this.sVal,
    double nVal,
    double tVal,
  })  : nVal = roundDecimal(bVal - sVal),
        tVal = roundDecimal(bVal + sVal);

  static List<BrokerData> dummy = [
    BrokerData(
      brokerCode: 'RF',
      brokerName: 'PT. Buana Capital Sekuritas',
      brokerType: 2,
      //nVal: 533.3,
      bVal: 1082,
      sVal: 548.7,
      //tVal: 1630.7,
    ),
    BrokerData(
      brokerCode: 'YU',
      brokerName: 'CGS-CIMB Sekuritas Indonesia',
      brokerType: 3,
      //nVal: 165,
      bVal: 839.7,
      sVal: 674.6,
      //tVal: 1514.4,
    ),
    BrokerData(
      brokerCode: 'BK',
      brokerName: 'J.P. Morgan Sekuritas Indonesia',
      brokerType: 3,
      //nVal: -293.7,
      bVal: 475.9,
      sVal: 769.6,
      //tVal: 1245.5,
    ),
    BrokerData(
      brokerCode: 'ZP',
      brokerName: 'Maybank Sekuritas Indonesia',
      brokerType: 3,
      //nVal: 65.8,
      bVal: 606.7,
      sVal: 540.9,
      //tVal: 1147.6,
    ),
    BrokerData(
      brokerCode: 'YP',
      brokerName: 'Mirae Asset Sekuritas Indonesia',
      brokerType: 3,
      //nVal: 7,
      bVal: 522.6,
      sVal: 515.6,
      //tVal: 1038.2,
    ),
    BrokerData(
      brokerCode: 'AK',
      brokerName: 'UBS Sekuritas Indonesia',
      brokerType: 3,
      //nVal: -65.2,
      bVal: 465.5,
      sVal: 530.8,
      //tVal: 996.4,
    ),
    BrokerData(
      brokerCode: 'CC',
      brokerName: 'Mandiri Sekuritas',
      brokerType: 1,
      //nVal: -25.8,
      bVal: 415.4,
      sVal: 441.3,
      //tVal: 856.8,
    ),
    BrokerData(
      brokerCode: 'RX',
      brokerName: 'Macquarie Sekuritas Indonesia',
      brokerType: 3,
      //nVal: -18.9,
      bVal: 99.7,
      sVal: 118.6,
      //tVal: 218.3,
    ),
    BrokerData(
      brokerCode: 'PD',
      brokerName: 'Indo Premier Sekuritas',
      brokerType: 2,
      //nVal: 11,
      bVal: 115.8,
      sVal: 104.8,
      //tVal: 220.6,
    ),
    BrokerData(
      brokerCode: 'KZ',
      brokerName: 'CLSA Sekuritas Indonesia',
      brokerType: 3,
      //nVal: 1,
      bVal: 118.3,
      sVal: 117.3,
      //tVal: 235.7,
    ),
    BrokerData(
      brokerCode: 'AI',
      brokerName: 'UOB Kay Hian Sekuritas',
      brokerType: 3,
      //nVal: -8.4,
      bVal: 114.9,
      sVal: 123.3,
      //tVal: 238.3,
    ),
    BrokerData(
      brokerCode: 'DH',
      brokerName: 'Sinarmas Sekuritas',
      brokerType: 2,
      //nVal: -32.1,
      bVal: 119.7,
      sVal: 151.8,
      //tVal: 271.6,
    ),
    BrokerData(
      brokerCode: 'MG',
      brokerName: 'Semesta Indovest Sekuritas',
      brokerType: 2,
      //nVal: -172,
      bVal: 79.9,
      sVal: 252,
      //tVal: 332,
    ),
    BrokerData(
      brokerCode: 'NI',
      brokerName: 'BNI Sekuritas',
      brokerType: 1,
      //nVal: 7,
      bVal: 220.5,
      sVal: 109.6,
      //tVal: 542,
    ),
    BrokerData(
      brokerCode: 'DX',
      brokerName: 'Bahana Sekuritas',
      brokerType: 1,
      //nVal: 7,
      bVal: 225.6,
      sVal: 675.6,
      //tVal: 1038.2,
    ),
    BrokerData(
      brokerCode: 'LG',
      brokerName: 'Trimegah Sekuritas Indonesia Tbk.',
      brokerType: 3,
      //nVal: 7,
      bVal: 126.6,
      sVal: 90.6,
      //tVal: 1038.2,
    ),
    BrokerData(
      brokerCode: 'GR',
      brokerName: 'Panin Sekuritas Tbk.',
      brokerType: 2,
      //nVal: 7,
      bVal: 10.6,
      sVal: 900.6,
      //tVal: 1038.2,
    ),
    BrokerData(
      brokerCode: 'OD',
      brokerName: 'BRI Danareksa Sekuritas',
      brokerType: 1,
      //nVal: 7,
      bVal: 12.8,
      sVal: 51.6,
      //tVal: 1038.2,
    ),
    BrokerData(
      brokerCode: 'EP',
      brokerName: 'MNC Sekuritas',
      brokerType: 2,
      //nVal: 7,
      bVal: 902.8,
      sVal: 10.6,
      //tVal: 1038.2,
    ),
    BrokerData(
      brokerCode: 'XA',
      brokerName: 'NH Korindo Sekuritas Indonesia',
      brokerType: 3,
      //nVal: 7,
      bVal: 176.2,
      sVal: 262.6,
      //tVal: 1038.2,
    ),
    BrokerData(
      brokerCode: 'AG',
      brokerName: 'Kiwoom Sekuritas Indonesia',
      brokerType: 3,
      //nVal: 7,
      bVal: 423.3,
      sVal: 51.6,
      //tVal: 1038.2,
    ),
  ];
}

double roundDecimal(double number, {int numberOfDecimal = 2}) {
  // To prevent number that ends with 5 not round up correctly in Dart (eg: 2.275 round off to 2.27 instead of 2.28)
  String numbersAfterDecimal = number.toString().split('.')[1];
  if (numbersAfterDecimal != '0') {
    int existingNumberOfDecimal = numbersAfterDecimal.length;
    double incrementValue = 1 / (10 * pow(10, existingNumberOfDecimal));
    if (number < 0) {
      number -= incrementValue;
    } else {
      number += incrementValue;
    }
  }

  return double.parse(number.toStringAsFixed(numberOfDecimal));
}
