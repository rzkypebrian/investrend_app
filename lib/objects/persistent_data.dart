// ignore_for_file: unnecessary_type_check, unused_local_variable, non_constant_identifier_names

import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredData {
  static final String VALID_VERSION = '0.0.2';
  String updated = '-';
  String version = '-';

  MD5StockBrokerIndex md5 =
      MD5StockBrokerIndex('', '', '', '', 1, '', '', '', '');

  List<Broker>? listBroker = List<Broker>.empty(growable: true);
  List<Stock>? listStock = List<Stock>.empty(growable: true);
  List<Index>? listIndex = List<Index>.empty(growable: true);
  List<Sector>? listSector = List<Sector>.empty(growable: true);
  List? listFinderRecent = List.empty(growable: true);

  Stock findStock(String? code) {
    Stock? result;
    for (int i = 0; i < listStock!.length; i++) {
      Stock? stock = listStock?.elementAt(i);
      if (StringUtils.equalsIgnoreCase(stock?.code, code)) {
        result = stock;
        break;
      }
    }
    return result!;
  }

  Broker findBroker(String code) {
    Broker? result;
    for (int i = 0; i < listBroker!.length; i++) {
      Broker? broker = listBroker?.elementAt(i);
      if (StringUtils.equalsIgnoreCase(broker?.code, code)) {
        result = broker;
        break;
      }
    }
    return result!;
  }

  List<Stock> getRelatedStock(String? forCode) {
    List<Stock> relatedStocks = List.empty(growable: true);
    String? mainCode = forCode;
    int? index = forCode?.indexOf('-');
    if (index! > 0) {
      mainCode = forCode?.substring(0, index);
      print('getRelatedStock mainCode = $mainCode  from stock.code = ' +
          forCode!);
    }
    relatedStocks.clear();

    for (Stock? value in listStock!) {
      if (value != null &&
          value is Stock &&
          value.code!.toLowerCase().startsWith(mainCode!.toLowerCase())) {
        relatedStocks.add(value);
      }
    }
    return relatedStocks;
  }

  void copyValueFrom(StoredData? newValue) {
    if (newValue != null) {
      this.md5.copyValueFrom(newValue.md5);
      this.updated = newValue.updated;
      this.version = newValue.version;

      this.listBroker?.clear();
      this.listStock?.clear();
      this.listIndex?.clear();
      this.listFinderRecent?.clear();

      if (newValue.listBroker != null) {
        this.listBroker = newValue.listBroker;
      }

      if (newValue.listStock != null) {
        this.listStock = newValue.listStock;
      }

      if (newValue.listIndex != null) {
        this.listIndex = newValue.listIndex;
      }

      if (newValue.listFinderRecent != null) {
        this.listFinderRecent = newValue.listFinderRecent;
      }
    }
  }

  static Future<StoredData> load() async {
    final pref = await SharedPreferences.getInstance();
    String version = pref.getString('version') ?? '-';
    if (!StringUtils.equalsIgnoreCase(version, VALID_VERSION)) {
      bool cleared = await pref.clear();
      print(
          'StoredData.load outdated version $version valid is $VALID_VERSION, cleared : ' +
              cleared.toString());
    }

    String updated = pref.getString('updated') ?? '-';
    String md5broker = pref.getString('md5broker') ?? '';
    String md5stock = pref.getString('md5stock') ?? '';
    String md5index = pref.getString('md5index') ?? '';
    String md5sector = pref.getString('md5sector') ?? '';
    int sharePerLot = pref.getInt('sharePerLot') ?? 1;

    String md5brokerUpdate = pref.getString('md5brokerUpdate') ?? '';
    String md5stockUpdate = pref.getString('md5stockUpdate') ?? '';
    String md5indexUpdate = pref.getString('md5indexUpdate') ?? '';
    String md5sectorUpdate = pref.getString('md5sectorUpdate') ?? '';

    String brokerString = pref.getString('brokerString') ?? '';
    String stockString = pref.getString('stockString') ?? '';
    String indexString = pref.getString('indexString') ?? '';
    String sectorString = pref.getString('sectorString') ?? '';
    String finderRecentString = pref.getString('finderRecentString') ?? '';

    StoredData storedData = StoredData();

    storedData.listBroker?.clear();
    storedData.listStock?.clear();
    storedData.listIndex?.clear();
    storedData.listSector?.clear();
    storedData.listFinderRecent?.clear();

    storedData.unserializeFromString(brokerString, storedData.listBroker);
    storedData.unserializeFromString(stockString, storedData.listStock);
    storedData.unserializeFromString(indexString, storedData.listIndex);
    storedData.unserializeFromString(sectorString, storedData.listSector);
    storedData.unserializeFromString(
        finderRecentString, storedData.listFinderRecent);

    md5broker = storedData.listBroker!.isEmpty ? '' : md5broker;
    md5stock = storedData.listStock!.isEmpty ? '' : md5stock;
    md5index = storedData.listIndex!.isEmpty ? '' : md5index;
    md5sector = storedData.listSector!.isEmpty ? '' : md5sector;

    MD5StockBrokerIndex md5 = MD5StockBrokerIndex(
        md5broker,
        md5stock,
        md5index,
        md5sector,
        sharePerLot,
        md5brokerUpdate,
        md5stockUpdate,
        md5indexUpdate,
        md5sectorUpdate);
    storedData.md5.copyValueFrom(md5);
    storedData.updated = updated;
    storedData.version = VALID_VERSION;

    // print('StoredData.load from SharedPrefferences-----------');
    // print('StoredData.load updated : $updated');
    // print('StoredData.load md5broker $md5broker');
    // print('StoredData.load md5stock $md5stock');
    // print('StoredData.load md5index $md5index');
    // print('StoredData.load sharePerLot $sharePerLot');
    // print('StoredData.load md5brokerUpdate $md5brokerUpdate');
    // print('StoredData.load md5stockUpdate $md5stockUpdate');
    // print('StoredData.load md5indexUpdate $md5indexUpdate');
    //
    print('StoredData.load storedData.listBroker : ' +
        storedData.listBroker!.length.toString());
    print('StoredData.load storedData.listStock : ' +
        storedData.listStock!.length.toString());
    print('StoredData.load storedData.listIndex : ' +
        storedData.listIndex!.length.toString());
    print('StoredData.load storedData.listSector : ' +
        storedData.listSector!.length.toString());
    print('StoredData.load storedData.listFinderRecent : ' +
        storedData.listFinderRecent!.length.toString());

    return storedData;
  }

  Future<bool> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool cleared = await prefs.clear();
    return cleared;
  }

  Future<bool> save(/*SharedPreferences prefs*/) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    bool savedUpdated = await prefs.setString('updated', updated);
    bool savedVersion = await prefs.setString('version', VALID_VERSION);

    bool savedBroker = await prefs.setString('md5broker', md5.md5broker!);
    bool savedStock = await prefs.setString('md5stock', md5.md5stock!);
    bool savedIndex = await prefs.setString('md5index', md5.md5index!);
    bool savedSector = await prefs.setString('md5sector', md5.md5sector!);
    bool savedLot = await prefs.setInt('sharePerLot', md5.sharePerLot!);
    bool savedBrokerUpdate =
        await prefs.setString('md5brokerUpdate', md5.md5brokerUpdate!);
    bool savedStockUpdate =
        await prefs.setString('md5stockUpdate', md5.md5stockUpdate!);
    bool savedIndexUpdate =
        await prefs.setString('md5indexUpdate', md5.md5indexUpdate!);
    bool savedSectorUpdate =
        await prefs.setString('md5sectorUpdate', md5.md5sectorUpdate!);

    String brokerString = serializeAsString(listBroker);
    String stockString = serializeAsString(listStock);
    String indexString = serializeAsString(listIndex);
    String sectorString = serializeAsString(listSector);
    String finderRecentString = serializeAsString(listFinderRecent);

    //listBroker.forEach((Broker broker){(brokerString.isEmpty ? brokerString = broker.asPlain() : brokerString += broker.asPlain());});
    // print('StoredData.save brokerString : '+brokerString);
    // print('StoredData.save stockString : '+stockString);
    // print('StoredData.save indexString : '+indexString);
    // print('StoredData.save finderRecentString : '+finderRecentString);

    bool savedBrokerString =
        await prefs.setString('brokerString', brokerString);
    bool savedStockString = await prefs.setString('stockString', stockString);
    bool savedIndexString = await prefs.setString('indexString', indexString);
    bool savedSectorString =
        await prefs.setString('sectorString', sectorString);
    bool savedFinderRecentString =
        await prefs.setString('finderRecentString', finderRecentString);

    bool saved = savedBroker &&
        savedStock &&
        savedIndex &&
        savedSector &&
        savedLot &&
        savedBrokerUpdate &&
        savedStockUpdate &&
        savedIndexUpdate &&
        savedSectorUpdate &&
        savedBrokerString &&
        savedStockString &&
        savedIndexString &&
        savedSectorString &&
        savedFinderRecentString;
    if (saved) {
      this.updated = updated;
      this.version = VALID_VERSION;
      print('StoredData.save at : ' +
          this.updated +
          "  version : $VALID_VERSION");
    } else {
      print('StoredData.save failed');
    }

    return saved;
  }

  List unserializeFromString(String string, List? listTo) {
    List<String> rows = string.split('\n');
    rows.forEach((String serialize) {
      SerializeableSSI? base = SerializeableSSI.unserialize(serialize);
      if (base != null) {
        listTo!.add(base);
      } else {
        print('Invalid Serializeable is NULL for : ' + serialize);
      }
    });
    return unserializeFromString('', null);
  }

  String serializeAsString(List? list) {
    String string = '';
    list?.forEach((Object? object) {
      //bool validObject = object is CodeName || object is Stock || object is Index;
      if (object is SerializeableSSI) {
        if (string.isEmpty) {
          string = object.serialize();
        } else {
          string += '\n' + object.serialize();
        }
      } else {
        print('StoredData.serializeAsString is Invalid object!!!! [error] ' +
            object.toString());
      }
    });
    return string;
  }
}
