
import 'RedisConnector.dart';

abstract class RedisConnectionListener{
  void onReConnecting(RedisConnector connector, String info) ;
  void onConnecting(RedisConnector connector, String info) ;
  void onConnected(RedisConnector connector, String info, bool isReady) ;
  void onConnectionFailed(RedisConnector connector, String info) ;
  void onAuthenticated(RedisConnector connector, String info, bool isReady) ;
  void onAuthenticationFailed(RedisConnector connector, String info) ;
  void onErrorHandler(RedisConnector connector, String info) ;
  void onDisconnected(RedisConnector connector, String info) ;
}