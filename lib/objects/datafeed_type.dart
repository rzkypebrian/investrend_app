// ignore_for_file: non_constant_identifier_names

class DatafeedType {
  static final String TYPE_SUMMARY = 'Q'; // 'SUMMARY';
  static final String TYPE_SUMMARY_LIST = 'W'; // 'SUMMARY_LIST';
  static final String TYPE_SUMMARY_SHORT = 'E'; // 'SUMMARY_SHORT';
  static final String TYPE_STOCK = 'R'; // 'STOCK';
  static final String TYPE_STOCK_FD = 'T'; // 'STOCK_FD';
  static final String TYPE_COMPOSITE_FD = 'Y'; // 'COMPOSITE_FD';
  static final String TYPE_STOCK_SHORT = 'U'; // 'STOCK_SHORT';
  static final String TYPE_BROKER = 'I'; // 'BROKER';
  static final String TYPE_TRADE = 'O'; // 'TRADE';
  static final String TYPE_INDICES = 'Z'; // 'INDICES';
  static final String TYPE_INDICES_STOCK = 'X'; // 'INDICES_STOCK';
  static final String TYPE_STATUS = 'C'; // 'STATUS';
  static final String TYPE_NEWS = 'V'; // 'NEWS';
  static final String TYPE_INFO = 'B'; // 'INFO';
  static final String TYPE_ORDERBOOK = 'N'; // 'ORDERBOOK';
  static final String TYPE_TRADEBOOK = 'M'; // 'TRADEBOOK';
  static final String TYPE_ORDER = 'A'; // 'ORDER';
  static final String TYPE_ORDERBOOK_QUEUE = 'S'; // 'ORDER_QUEUE';
  static final String TYPE_ORDERBOOK_QUEUE_DETAIL =
      'D'; // 'ORDERBOOK_QUEUE_DETAIL';

  static final String COLLECTION = 'C';
  static final String HASH = 'H';
  static final String KEY = 'K';
  static final String SORTED_SET = 'SS';

  static final String COLLECTION_SUMMARY = 'CQ'; // "IDX.SUMMARY";
  static final String COLLECTION_INDICES = 'CZ'; // "IDX.INDICES";
  static final String COLLECTION_ORDERBOOK = 'CN'; // "IDX.ORDERBOOK";
  static final String COLLECTION_STOCK_FD = 'CT'; // "IDX.STOCK_FD";
  static final String COLLECTION_TRADEBOOK = 'CM'; // "IDX.TRADEBOOK";

  static final String HASH_SUMMARY = 'HQ'; // "HASH.SUMMARY";
  static final String HASH_ORDERBOOK = 'HN'; // "HASH.ORDERBOOK";
  static final String HASH_TRADEBOOK = 'HM'; // "HASH.TRADEBOOK";
  static final String HASH_INDICES = 'HZ'; // "HASH.INDICES";
  static final String HASH_INDICES_STOCK = 'HX'; // "HASH.INDICES_STOCK";
  static final String HASH_STATUS = 'HC'; // "HASH.STATUS";
  static final String HASH_STOCK_FD = 'HT'; // "HASH.STOCK_FD";
  static final String HASH_COMPOSITE_FD = 'HY'; // "HASH.COMPOSITE_FD";
  static final String HASH_ORDER = 'HA'; // "HASH.ORDER";

  static final String KEY_SUMMARY = 'KQ'; // "IDX.SUMMARY";
  static final String KEY_ORDERBOOK = 'KN'; // "IDX.ORDERBOOK";
  static final String KEY_TRADEBOOK = 'KM'; // "IDX.TRADEBOOK";
  static final String KEY_INDICES = 'KZ'; // "IDX.INDICES";
  static final String KEY_INDICES_STOCK = 'KX'; // "IDX.INDICES_STOCK";
  static final String KEY_STATUS = 'KC'; // "IDX.STATUS";
  static final String KEY_STOCK_FD = 'KT'; // "IDX.STOCK_FD";
  static final String KEY_COMPOSITE_FD = 'KY'; // "IDX.COMPOSITE_FD";
  static final String KEY_STOCK = 'KR'; // "IDX.STOCK";
  static final String KEY_BROKER = 'KI'; // "IDX.BROKER";
  static final String KEY_TRADE = 'KO'; // "IDX.TRADE";
  static final String KEY_ORDER = 'KA';
}
