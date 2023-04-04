import 'RedisConnector.dart';

class RedisGetterConnector extends RedisConnector{
  RedisGetterConnector(String ip, int port,
      String authPass, String clientCode, String clientDevice, String clientVersion)
      : super('GetterConnector',ip, port, authPass:authPass, clientCode:clientCode, clientDevice:clientDevice, clientVersion:clientVersion);

  void onAuthenticated() {
    super.onAuthenticated();
    if(super.isReady()){

    }
  }
  void onConnected() {
    super.onConnected();

    if(super.isReady()){

    }
  }
}