

abstract class RedisStreamerReceiver{
  void onStreamerMessage(String channel, String message) ;
  void onStreamerSubscribe(String channel, String message) ;
  void onStreamerUnsubscribe(String channel, String message) ;
  void onUnknownMessage(String message) ;
  void onStreamerPsubscribe(String channel, String message) {}
  void onStreamerPunsubscribe(String channel, String message) {}

  void onStreamerPmessage(String channel, String message) {}
}