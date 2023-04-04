import 'package:Investrend/utils/string_utils.dart';

import '../RedisProtocol.dart';
import '../RedisReceiver.dart';
import 'RedisResult.dart';

abstract class RedisQuery implements RedisProtocol{
  String get parameter;
  //String get packet => parameter+"\r\n";
  //bool get isReplied;
  RedisReceiver listener;
  RedisResult result;
  //RedisResult get reply => result;
}
class Auth extends RedisQuery {
  String password = "";
  String code     = "";
  String device   = "";
  String version  = "";
  String _param  = "";
  Auth(this.password, this.code, this.device, this.version, RedisReceiver listener)
  {
    super.listener = listener;
    super.result = new AuthResult(this);
    if(StringUtils.isEmtpy(code) || StringUtils.isEmtpy(device) || StringUtils.isEmtpy(version)){
      _param  = "AUTH $password";
    }else{
      _param  = "AUTH $password $code $device $version";
    }
  }
  //String get parameter => "AUTH $password $code $device $version";
  String get parameter => _param;
}

class Ping extends RedisQuery {

  Ping(RedisReceiver listener){
    super.listener = listener;
    super.result = new PingResult(this);
  }

  String get parameter => "PING";
}

class Subscribe extends RedisQuery {
  String key = "";
  Subscribe(this.key , RedisReceiver listener)
  {
    super.listener = listener;
    super.result = new SubscribeResult(this);
  }
  String get parameter => "SUBSCRIBE $key";
}
class Unsubscribe extends RedisQuery {
  String key = "";
  Unsubscribe(this.key , RedisReceiver listener)
  {
    super.listener = listener;
  }
  String get parameter => "UNSUBSCRIBE $key";
}
class Get extends RedisQuery {
  String key = "";
  Get(this.key , RedisReceiver listener)
  {
    super.listener = listener;
  }
  String get parameter => "GET $key";
}


class MGet extends RedisQuery {
  List<String> keys = new List<String>();
  MGet(this.keys , RedisReceiver listener)
  {
    super.listener = listener;
  }
  String get parameter => "MGET "+keys.join(" ");
}



class HGetAll extends RedisQuery {
  String key = "";
  HGetAll(this.key , RedisReceiver listener)
  {
    super.listener = listener;
  }
  String get parameter => "HGETALL $key";
}

class HMGet extends RedisQuery {
  String key = "";
  List<String> fields = new List<String>();
  HMGet(this.key , this.fields, RedisReceiver listener)
  {
    super.listener = listener;
  }
  String get parameter => "HMGET $key "+fields.join(" ");

}