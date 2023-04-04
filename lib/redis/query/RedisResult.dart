
import '../RedisProtocol.dart';
import 'RedisQuery.dart';

abstract class RedisResult implements RedisProtocol {
  RedisQuery query;
  RedisResult(this.query) ;
  bool isEmpty = true;
  bool _status = false;
  String _message = "";
  int count = 1;
  int nextIndex = 0;
  bool isEmptyResult(List<String> data) {
    bool empty = true;
    if (data != null && data.length > 0) {
      for (int i = 0; i < data.length; i++) {
        if (data[i] == null || data.isEmpty || data[i] == "nill") {
        } else {
          empty = false;
        }
      }
    }
    //System.out.println("isEmptyResult : "+empty+"  data : "+(data == null ? "null" : data.length));
    return empty;
  }

  bool addReply(String msg);
  //bool get isSuccess;
  bool get isSuccess => this._status;
  String get info => this._message;
}

class SingleResult extends RedisResult {
  SingleResult(RedisQuery req) : super(req) ;

  bool addReply(String msg) {
    if (msg.startsWith(RedisProtocol.POSITIVE) ||
        msg.startsWith(RedisProtocol.NEGATIVE)) {
      //res = new String[]{msg.charAt(0)+"",msg.substring(1,msg.length)};
      this._message = msg.substring(1, msg.length);
      this._status = msg.startsWith(RedisProtocol.POSITIVE);
      //insertReply(BooleanString(status, message), count);
      nextIndex++;
    }
    return nextIndex == count;
  }
}

class AuthResult extends SingleResult {
  // auth a
  // -ERR invalid password

  // auth 1d26fd6fe2758f7b32729370b63724bc
  // +OK

  AuthResult(RedisQuery req) : super(req);
}

class PingResult extends SingleResult {
  // ping
  // -ERR operation not permitted

  // ping
  // +PONG

  // ping
  // -ERR only (P)SUBSCRIBE / (P)UNSUBSCRIBE / QUIT allowed in this context

  PingResult(RedisQuery req) : super(req) ;
}

class MultipleResult extends RedisResult {
  //bool _status;
  //String _message;

  int nextLenght = 0;
  List<String> datas;

  MultipleResult(RedisQuery req) : super(req) ;

  void _addData(String data) {
    if (datas == null) {
      datas = new List();
      //print("create List($count)");
    }
    datas.add(data);
  }

  void printDatas(){
    datas.forEach((item) {
      print('${datas.indexOf(item)}: $item');
    });
  }

  bool addReply(String msg) {
    if (msg.startsWith(RedisProtocol.NEGATIVE)) {
      this._message = msg.substring(1, msg.length);
      this._status = false;
      //insertReply(BooleanString(status, message), count);
      nextIndex++;
    } else if (msg.startsWith(RedisProtocol.COUNT)) {
      int newLoop = int.parse(msg.substring(1, msg.length));
      count = newLoop;
      print("create set new count : $count");
      this._status = true;
    } else if (msg.startsWith(RedisProtocol.DOLLAR_NO_DATA)) {
      nextIndex++;
      _addData(RedisProtocol.NILL);
    } else if (msg.startsWith(RedisProtocol.COLON)) {
      nextIndex++;
      _addData(msg.substring(1, msg.length));
    } else if (msg.startsWith(RedisProtocol.DOLLAR)) {
      nextLenght = int.parse(msg.substring(1, msg.length));
      print("create set next Lenght : $nextLenght");
    } else if (nextLenght > 0) {
      if (msg.length == nextLenght) {
        nextLenght = 0;
        nextIndex++;
        _addData(msg);
      }else{
        print("RedisConnector INVALID expected length : $nextLenght but receive length : "+msg.length.toString()+" --> "+msg);
      }
    } else {
      nextIndex++;
      _addData(msg);
    }
    return nextIndex == count;
  }
}

class SubscribeResult extends MultipleResult {
  //  subscribe SSI.FITR007
  //  -ERR operation not permitted

  //  subscribe SSI.FITR007
  //  *3
  //  $9
  //  subscribe
  //  $11
  //  SSI.FITR007
  //  :1

  SubscribeResult(RedisQuery req) : super(req) ;
}

class UnSubscribeResult extends MultipleResult {
  //  unsubscribe SSI.FITR007
  //  -ERR operation not permitted

  //  unsubscribe SSI.FITR007
  //  *3
  //  $11
  //  unsubscribe
  //  $11
  //  SSI.FITR007
  //  :1

  //  unsubscribe SSI.FITR007
  //  *3
  //  $11
  //  unsubscribe
  //  $11
  //  SSI.FITR007
  //  :1

  UnSubscribeResult(RedisQuery req) : super(req) ;
}

class MGetResult extends MultipleResult {
  //  MGET KA.BUMI.RG KA.BNBR.RG
  //  -ERR operation not permitted

  //  MGET KA.BUMI.RG KA.ASII.RG
  //  *2
  //  $244
  //  SSI|A|0|0|2020-02-17|14:14:34|BUMI|RG|21|51|53|51|52|167|50|2019-02-18|2020-02-17|153|-65.56|1|1.96|25022100|1302322000|648|30180|66946909815|51|52|13423000|53|87085800|--|3481239310380|52.0|1250322000|1294090600|52000000|8231400|75|50|-21.21|0
  //  $292
  //  SSI|A|0|0|2020-02-17|14:15:26|ASII|RG|42|6100|6175|6050|6100|8025|5925|2019-02-18|2020-02-17|7875|-19.73|0|0.0|6979300|42765745000|2205|43622217|40483553140|6150|6075|420800|6100|744300|--|246949674154000|6128.0|30135520000|22477287500|12630225000|20288457500|7250|5925|-11.91|111349608077100

  //  MGET KA.BBCA.RG KA.XXXX.RG
  //  *2
  //  $309
  //  SSI|A|0|0|2020-02-17|14:16:13|BBCA|RG|81|33400|33750|33400|33575|35300|25700|2019-02-18|2020-02-17|27400|25.27|175|0.52|12641100|424386647500|3379|191857143|24408459900|33400|33575|2400|33600|580400|--|819514041142500|33572.0|185542962500|36146032500|238843685000|388240615000|35300|31850|0.44|243076865746775
  //  $-1

  MGetResult(RedisQuery req) : super(req) ;
}

class HGetAll extends MultipleResult {

  //  HGETALL HL
  //  -ERR operation not permitted

  //  HGETALL HL
  //  *6
  //  $4
  //  time
  //  $8
  //  14:20:20
  //  $7
  //  message
  //  $14
  //  Second Session
  //  $6
  //  status
  //  $1
  //  S

  HGetAll(RedisQuery req) : super(req) ;
}

class HMGet extends MultipleResult {

  //  HMGET HL status
  //  -ERR operation not permitted

  //  HMGET HL status xxx
  //  *2
  //  $1
  //  S
  //  $-1

  //  HMGET HL status time message
  //  *3
  //  $1
  //  S
  //  $8
  //  14:23:50
  //  $14
  //  Second Session

  HMGet(RedisQuery req) : super(req) ;
}