import 'query/RedisResult.dart';
import 'query/RedisQuery.dart';

abstract class RedisReceiver{
  void onGetterResponse(String id, RedisResult res) ;//throws Exception;
  void onGetterException(String id, RedisQuery req,String exception);
}