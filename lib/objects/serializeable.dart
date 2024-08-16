import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/string_utils.dart';
// import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Serializeable {
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

  static Serializeable? unserialize(String serialize) {
    String tag1 = tagIdentity + ":\"";
    String tag2 = tagData + ":\"";
    String tagEnd = "\" ";
    String identity = StringUtils.between(serialize, tag1, tagEnd) ?? '';
    String data = StringUtils.between(serialize, tag2, tagEnd) ?? '';

    //print('unserialize for identity : $identity  data : $data   $serialize');

    if (StringUtils.equalsIgnoreCase(identity, 'Watchlist')) {
      Watchlist watchlist = Watchlist.fromPlain(data)!;
      return watchlist;
    } else if (StringUtils.equalsIgnoreCase(identity, 'HelpMenu')) {
      HelpMenu helpMenu = HelpMenu.fromPlain(data);
      return helpMenu;
    } else if (StringUtils.equalsIgnoreCase(identity, 'HelpContent')) {
      HelpContent helpContent = HelpContent.fromPlain(data);
      return helpContent;
    } else if (StringUtils.equalsIgnoreCase(identity, 'INBOX')) {
      InboxMessage? inbox = InboxMessage.fromPlain(data);
      return inbox;
    } else if (StringUtils.equalsIgnoreCase(identity, 'BROADCAST')) {
      BroadcastMessage broadcast = BroadcastMessage.fromPlain(data);
      return broadcast;
    } else {
      print(
          'unserialize failed for identity : $identity  data : $data   $serialize');
    }
    return null;
  }

  static const String _pipe = '|';
  static const String _LF = '\n';
  static const String _CR = '\r';
  static const String _braceOpen = '{';
  static const String _braceClose = '}';
  static const String _quote = '"';

  static const String _replacementPipe = '+∏+';
  static const String _replacementLF = '+Ø+';
  static const String _replacementCR = '+∑+';
  static const String _replacementBraceOpen = '+€+';
  static const String _replacementBraceClose = '+¢+';
  static const String _replacementQuote = '+§+';

  static String safePlain(String text) {
    //text = text.replaceAll('|', _replacementPipe);
    //text = text.replaceAll('\n', _replacementLF);

    text = text.replaceAll(_pipe, _replacementPipe);
    text = text.replaceAll(_LF, _replacementLF);
    text = text.replaceAll(_CR, _replacementCR);
    text = text.replaceAll(_braceOpen, _replacementBraceOpen);
    text = text.replaceAll(_braceClose, _replacementBraceClose);
    text = text.replaceAll(_quote, _replacementQuote);
    return text;
  }

  static String unsafePlain(String? text) {
    //text = text.replaceAll(_replacementPipe, '|' );
    //text = text.replaceAll(_replacementLF, '\n' );

    text = text!.replaceAll(_replacementPipe, _pipe);
    text = text.replaceAll(_replacementLF, _LF);
    text = text.replaceAll(_replacementCR, _CR);
    text = text.replaceAll(_replacementBraceOpen, _braceOpen);
    text = text.replaceAll(_replacementBraceClose, _braceClose);
    text = text.replaceAll(_replacementQuote, _quote);
    return text;
  }

  static List unserializeFromString(String string, List listTo) {
    List<String> rows = string.split('\n');
    rows.forEach((String serialize) {
      Serializeable? base = Serializeable.unserialize(serialize);
      if (base != null) {
        listTo.add(base);
      } else {
        print('Invalid Serializeable is NULL for : ' + serialize);
      }
    });
    return List.empty();
  }

  static String serializeAsString(List? list) {
    String string = '';
    list?.forEach((Object? object) {
      //bool validObject = object is CodeName || object is Stock || object is Index;
      if (object is Serializeable) {
        if (string.isEmpty) {
          string = object.serialize();
        } else {
          string += '\n' + object.serialize();
        }
      } else {
        print('serializeAsString is Invalid object!!!! [error] ' +
            object.toString());
      }
    });
    return string;
  }
}

class Watchlist extends Serializeable {
  String name = '';
  String image = '';
  List<String>? stocks = List.empty(growable: true);

  Watchlist(this.name, {this.image = '', this.stocks}) {
    if (this.stocks == null) {
      this.stocks = List.empty(growable: true);
    }
  }
  int count() {
    return stocks == null ? 0 : stocks!.length;
  }

  bool addStock(String? code) {
    bool canAdd = !StringUtils.isEmtpy(code) && !stocks!.contains(code);
    if (canAdd) {
      stocks?.add(code!);
    }
    return canAdd;
  }

  bool removeStock(String? code) {
    bool canRemove = !StringUtils.isEmtpy(code) && stocks!.contains(code);
    if (canRemove) {
      stocks!.remove(code);
    }
    return canRemove;
  }

  @override
  String asPlain() {
    String stockString = stocks!.join('*');
    String plain = Serializeable.safePlain(name);
    plain += '|' + Serializeable.safePlain(image);
    plain += '|' + Serializeable.safePlain(stockString);
    return plain;
  }

  static Watchlist? fromPlain(String? data) {
    List<String>? datas = data?.split('|');
    if (datas != null && datas.isNotEmpty && datas.length >= 2) {
      String name = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(0)));
      String image = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(1)));
      String stockString = Serializeable.unsafePlain(
          StringUtils.noNullString(datas.elementAt(2)));
      List<String> stocks = stockString.split('*');
      stocks.remove('');
      if (StringUtils.isEmtpy(name)) {
        return null;
      }
      return Watchlist(name, image: image, stocks: stocks);
    }
    return null;
  }

  @override
  String identity() {
    return 'Watchlist';
  }

  static Future<List<Watchlist>> load() async {
    List<Watchlist> _listWatchlist = List.empty(growable: true);
    final pref = await SharedPreferences.getInstance();
    String updated = pref.getString('watchlist_updated') ?? '-';
    String watchlistString = pref.getString('watchlist_list') ?? '';

    print(
        'Watchlist.load updated : $updated   watchlistString : $watchlistString');
    Serializeable.unserializeFromString(watchlistString, _listWatchlist);
    print('Watchlist.load Got _listWatchlist : ' +
        _listWatchlist.length.toString());
    return _listWatchlist;
  }

  static Future<bool> save(List<Watchlist>? _listWatchlist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updated = DateTime.now().toString();
    String watchlistString = Serializeable.serializeAsString(_listWatchlist);

    bool savedUpdated = await prefs.setString('watchlist_updated', updated);
    bool savedWatchlistString =
        await prefs.setString('watchlist_list', watchlistString);

    bool saved = savedUpdated && savedWatchlistString;
    print(
        'Watchlist.save $saved updated : $updated   savedWatchlistString : $savedWatchlistString  watchlistString : $watchlistString');
    return saved;
  }
}
