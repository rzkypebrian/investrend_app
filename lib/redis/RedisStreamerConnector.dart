import 'RedisConnector.dart';
import 'RedisStreamerReceiver.dart';
import 'query/RedisResult.dart';

class RedisStreamerConnector extends RedisConnector {
  RedisStreamerReceiver receiver;
  RedisStreamerConnector(String ip, int port, String authPass,
      String clientCode, String clientDevice, String clientVersion
      , this.receiver,{String streamerid='StreamerConnector'})
      : super(streamerid/*'StreamerConnector'*/, ip, port,
            authPass: authPass,
            clientCode: clientCode,
            clientDevice: clientDevice,
            clientVersion: clientVersion);

  void onAuthenticated() {
    super.onAuthenticated();
    if (super.isReady()) {
      sendInitialCommands();
    }
  }

  void onConnected() {
    super.onConnected();

    if (super.isReady()) {
      sendInitialCommands();
    }
  }

  //Map<String, List> subscriber = new Map();

  void sendInitialCommands() async {
    //await super.writeToServer("SUBSCRIBE KL");
    // await super.writeToServer("SUBSCRIBE SSI.FITR007");
    // await super.writeToServer("SUBSCRIBE RT");
  }
  void subscribe(String channel) async {
    super.writeToServer("SUBSCRIBE $channel");
  }
  void unsubscribe(String channel) async {
    super.writeToServer("UNSUBSCRIBE $channel");
  }

  void psubscribe(String channel) async {
    super.writeToServer("PSUBSCRIBE $channel");
  }
  void punsubscribe(String channel) async {
    super.writeToServer("PUNSUBSCRIBE $channel");
  }

  @override
  void onRedisMessage(String id, RedisResult result) {
    if (result is MultipleResult) {
      MultipleResult res = result;
      //res.printDatas();
      if (res.datas != null) {
        if (res.datas.length == 3) {
          String type     = res.datas.elementAt(0);
          String channel  = res.datas.elementAt(1);
          String message  = res.datas.elementAt(2);
          if(this.receiver != null){
            if(type == "message"){
              this.receiver.onStreamerMessage(channel, message);
            }else if(type == "pmessage"){
              this.receiver.onStreamerPmessage(channel, message);
            }else if(type == "subscribe"){
              this.receiver.onStreamerSubscribe(channel, message);
            }else if(type == "unsubscribe"){
              this.receiver.onStreamerUnsubscribe(channel, message);
            }else if(type == "psubscribe"){
              this.receiver.onStreamerPsubscribe(channel, message);
            }else if(type == "punsubscribe"){
              this.receiver.onStreamerPunsubscribe(channel, message);
            }
          }
          /*
          flutter: 0: message
          flutter: 1: RT
          flutter: 2: 14:20:53|TELE|RG|132|-18|-12|10000|PD|D|DX|D|93|1474178759|1474175825|150|692385364|140|1320000
          */

        }else if (res.datas.length == 4) {
          String type     = res.datas.elementAt(0);
          String channel  = res.datas.elementAt(1);
          String key  = res.datas.elementAt(2);
          String message  = res.datas.elementAt(3);
          if(this.receiver != null){
            if(type == "pmessage"){
              this.receiver.onStreamerPmessage(channel, message);
            }
          }
          /*
          flutter: 0: message
          flutter: 1: RT
          flutter: 2: 14:20:53|TELE|RG|132|-18|-12|10000|PD|D|DX|D|93|1474178759|1474175825|150|692385364|140|1320000
          */

        }else{
          if(this.receiver != null){
            this.receiver.onUnknownMessage(res.datas.first);
          }
        }
      }
    }
  }
}
