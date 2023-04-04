import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:Investrend/utils/debug_writer.dart';

import 'RedisConnectionListener.dart';
import 'RedisProtocol.dart';
import 'RedisReceiver.dart';
import 'query/RedisQuery.dart';
import 'query/RedisResult.dart';

class RedisConnector implements RedisProtocol, RedisReceiver {
  String connectorId;

  String authPass;
  String ip;
  int port;
  String clientCode;
  String clientDevice;
  String clientVersion;

  Socket socket;
  RawSocket rawSocket;
  bool authRequired;

  //bool authWaitingReply;
  bool pingWaitingReply;
  bool autoPing = true;
  DateTime last_receive;

  final delayEachPing = const Duration(seconds: 30);
  final delayEachReconnect = const Duration(seconds: 5); // 5 second
  final socketConnectTimeout = const Duration(seconds: 10); // 10 second
  Timer pingTimer;
  Timer reconnectTimer;

  bool autoReconnect = true;
  bool _onReconnecting = false;
  bool _isReady = false;
  RedisConnectionListener _connectionListener;

  RedisQuery currentQuery;
  MultipleResult currentResult;

  //var commandNeedReply = <String>{};
  List<RedisQuery> queryList = List<RedisQuery>();

  // Constructor, with syntactic sugar for assignment to members.
  RedisConnector(this.connectorId, this.ip, this.port,
      {this.authPass, this.clientCode, this.clientDevice, this.clientVersion}) {
    // Initialization code goes here.
    authRequired = this.authPass != null && this.authPass.isNotEmpty;
    //authWaitingReply = false;
    pingWaitingReply = false;
  }

  void removeConnectionListener() {
    this._connectionListener = null;
  }

  void setConnectionListener(RedisConnectionListener connectionListener){
    this._connectionListener = connectionListener;
  }
  /// ONLY outside this class usage -- to remove Connection Listener call removeConnectionListener
  void connectRedis({RedisConnectionListener connectionListener}) {
    if (connectionListener != null) {
      this._connectionListener = connectionListener;
    }

    DebugWriter.info("$connectorId connectRedis ${DateTime.now()}");
    if (socket != null || pingTimer != null) {
      _stopPingTimer();
      _disconnectSocket();
    }
    autoReconnect = true;
    //_stopPingTimer();
    _connectSocket(socket);
  }

  void _reconnectRedis() {
    DebugWriter.info("$connectorId _reconnectRedis : $autoReconnect  ${DateTime.now()}  ");
    if (_connectionListener != null) {
      _connectionListener.onReConnecting(
          this,
          "Reconnecting" );
    }

    if (autoReconnect) {
      if (socket != null || pingTimer != null) {
        _stopPingTimer();
        _disconnectSocket();
      }
      _connectSocket(socket);
    }
  }

  // ONLY outside this class usage
  void disconnectRedis({String info}) {
    DebugWriter.info("$connectorId disconnectRedis : " + (info ?? '-'));
    autoReconnect = false;
    _disconnectSocket();
    _stopPingTimer();
  }

  void _disconnectSocket() {
    _isReady = false;
    if (socket != null) {
      DebugWriter.info("$connectorId _disconnectSocket");
      socket.add(utf8.encode('QUIT\r\n'));
      socket.destroy();
      socket = null;
    }
  }

  void _ping() {
    DebugWriter.info("$connectorId ping  _onReconnecting $_onReconnecting");
    if (this.socket != null) {

      int gapLastMessage = last_receive == null ? delayEachPing.inSeconds : DateTime.now().difference(last_receive).inSeconds;

      int maxWaitingData = delayEachPing.inSeconds + 10;
      bool noRecentlyMessageReceived = gapLastMessage >= maxWaitingData;
      DebugWriter.info("$connectorId ping  noRecentlyMessageReceived : $noRecentlyMessageReceived   gapLastMessage : $gapLastMessage in seconds,  Max is : "+maxWaitingData.toString()+' seconds');
      //if (pingWaitingReply) {
      if (noRecentlyMessageReceived) {
        if (!_onReconnecting) {
          _onReconnecting = true;
          _disconnectSocket();
          _stopPingTimer();
          DebugWriter.info("$connectorId ping not responded, try to reconnect");

          _startReconnectTimer(callerInfo: "via Ping");
        }
      } else {
        DebugWriter.info("$connectorId send ping");
        pingWaitingReply = true;
        socket.add(utf8.encode('PING\r\n'));
      }
    }
  }

  void _connectSocket(Socket socket) async {
    // 'trialb2.e-samuel.com'
    _onReconnecting = false;


    Socket.connect(ip, port, timeout: socketConnectTimeout)
        .then((Socket socket) {
      this.socket = socket;

      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      onConnected();

      if (authRequired) {
//        authWaitingReply = true;
//        String authPacket =
//            'AUTH $authPass $clientCode $clientDevice $clientVersion\r\n';
//        DebugWriter.info('--> ' + authPacket);
//        socket.add(utf8.encode(authPacket));

        currentQuery =
            Auth(authPass, clientCode, clientDevice, clientVersion, this);
        //DebugWriter.info('--> ' + currentQuery.pa);
        //socket.add(utf8.encode(currentQuery.packet));

        writeToServer(currentQuery.parameter);
      }

      //socket.flush();

      //socket.add(utf8.encode('SUBSCRIBE SSI.FITR007\r\n'));
      //socket.flush();
    }).catchError((e) {
      DebugWriter.info("$connectorId Unable to connect ${DateTime.now()} : $e");
      onConnectionFailed();
    });
  }

  //void subcribe(String channel) {}

  //void unsubcribe(String channel) {}

  void _stopPingTimer() {
    if (autoPing) {
      pingWaitingReply = false;
      if (pingTimer != null) {
        DebugWriter.info('$connectorId _stopPingTimer autoPing : $autoPing');
        pingTimer.cancel();
        pingTimer = null;
      }
    }
  }

  void _startPingTimer() {
    if (autoPing) {
      _stopPingTimer();
      DebugWriter.info('$connectorId _startPingTimer autoPing : $autoPing');
      pingTimer = new Timer.periodic(delayEachPing, (Timer t) => _ping());
    }
  }

  void onConnected() {
    DebugWriter.info('$connectorId onConnected');
    if (!authRequired) {
      _startPingTimer();
      _isReady = true;
    }
    if (_connectionListener != null) {
      _connectionListener.onConnected(this, "Connected", _isReady);
    }
  }

  void onConnectionFailed() {
    DebugWriter.info('$connectorId onConnectionFailed _onReconnecting $_onReconnecting');
    if (_connectionListener != null) {
      _connectionListener.onConnectionFailed(this, "Connection Failed");
    }
    if (!_onReconnecting) {
      _onReconnecting = true;
      _disconnectSocket();
      _stopPingTimer();

      _startReconnectTimer(callerInfo: "via onConnectionFailed");
    }
  }

  /// return boolean indicate the data is writen to stream or not
  /// DO NOT add CR LF in data being send, because it automatically adding CRLF before write to stream.
  bool writeToServer(String data) {
    if (socket != null) {
      DebugWriter.info("$connectorId --> $data");
      socket.add(utf8.encode('$data\r\n'));
      //socket.flush();
      return true;
    }
    return false;
  }

  void onAuthenticated() {
    DebugWriter.info('$connectorId onAuthenticated');
    _startPingTimer();
//    if (socket != null) {
//      socket.add(utf8.encode('SUBSCRIBE SSI.FITR007\r\n'));
////      socket.add(utf8.encode('SUBSCRIBE RT\r\n'));
//      socket.add(utf8.encode('SUBSCRIBE KL\r\n'));
//      socket.flush();
//
//      _isReady = true;
//    }
    _isReady = true;
    if (_connectionListener != null) {
      _connectionListener.onAuthenticated(this, "Authenticated", _isReady);
    }
  }

  bool isReady() {
    return _isReady;
  }

  void onAuthenticationFailed(String error) {
    DebugWriter.info("$connectorId onAuthenticationFailed : $error");
    //disconnectRedis(info: "onAuthenticationFailed : $error" );

    autoReconnect = false;
    _stopPingTimer();
    _disconnectSocket();

    if (_connectionListener != null) {
      _connectionListener.onAuthenticationFailed(this, error);
    }
  }

  void _startReconnectTimer({String callerInfo}) async {
    _cancelReconnectTimer();
    //const delay = const Duration(seconds:5); // 5 second
    //reconnectTimer = Timer(delay, () => ());
    /*
    if (_connectionListener != null) {
      _connectionListener.onReConnecting(
          this,
          "Reconnecting in " +
              delayEachReconnect.inSeconds.toString() +
              " seconds. " +
              (callerInfo ?? ""));
    }
    */
    reconnectTimer = Timer(delayEachReconnect, () => _reconnectRedis());
  }

  void _cancelReconnectTimer() {
    if (reconnectTimer != null) {
      reconnectTimer.cancel();
      reconnectTimer = null;
    }
  }

  void onMessage(String message) {
    last_receive = DateTime.now();
    DebugWriter.info("$connectorId "+last_receive.toString()+' onMessage received $message');
    pingWaitingReply = false;

    if (currentQuery != null) {
      bool finished = currentQuery.result.addReply(message);
      if (finished) {
        if (currentQuery.listener != null) {
          currentQuery.listener.onGetterResponse("", currentQuery.result);
        }
        currentQuery = null;
      }
    } else {
      if (currentResult == null) {
        currentResult = new MultipleResult(null);
      }
      bool finished = currentResult.addReply(message);
      if (finished) {
        //onGetterResponse("", currentResult);
        onRedisMessage("", currentResult);
        currentResult = null;
      }
    }
    //DebugWriter.info(utf8.decode(event));
    //DebugWriter.info(data);
    /*
    if (authWaitingReply) {
      authWaitingReply = false;
      if (message == '+OK') {
        onAuthenticated();
      } else {
        onAuthenticationFailed(message);
      }
    } else if (message == '+PONG') {
      if (pingWaitingReply) {
        pingWaitingReply = false;
      }
    }
    */
  }
  String excessData = "";
  void dataHandler(List<int> event) {
    //print(new String.fromCharCodes(data).trim());
    //event.forEach(print);

    //event.sub

    String data = utf8.decode(event);
    if(excessData.length > 0){
      data = excessData + data;
      excessData = "";
    }

    //print("dataHandler new : $data");


    int offset = 0;





    int indexBreak = data.indexOf(RedisProtocol.CR_LF);

    while (indexBreak >= 0) {
      String line = data.substring(0, indexBreak);
      offset = indexBreak + RedisProtocol.CR_LF_LENGTH;
      data = data.substring(offset, data.length);
      onMessage(line.trim());
      indexBreak = data.indexOf(RedisProtocol.CR_LF);
    }
    if(data.length > 0){
      excessData += data;
    }
    /*
    int indexLF = data.indexOf('\n');
    int lenghtLF = '\n'.length;
    while (indexLF >= 0) {
      String line = data.substring(0, indexLF);
      offset = indexLF + lenghtLF;
      data = data.substring(offset, data.length);
      onMessage(line.trim());
      indexLF = data.indexOf('\n');
    }
    */
  }

  void errorHandler(error, StackTrace trace) {
    DebugWriter.info("$connectorId errorHandler : $error  _onReconnecting $_onReconnecting");
    //disconnectRedis( info: 'errorHandler');
    if (!_onReconnecting) {
      _onReconnecting = true;
      _stopPingTimer();
      _disconnectSocket();

      if (_connectionListener != null) {
        _connectionListener?.onDisconnected(this, 'errorHandler');
      }

      _startReconnectTimer(callerInfo: "via ErrorHandler");
    }
  }

  void doneHandler() {
    DebugWriter.info("$connectorId doneHandler  _onReconnecting $_onReconnecting");
    //disconnectRedis( info: 'doneHandler');

    if (!_onReconnecting) {
      _onReconnecting = true;
      _stopPingTimer();
      _disconnectSocket();

      _startReconnectTimer(callerInfo: "via DoneHandler");
    }
  }

  void onRedisMessage(String id, RedisResult result) {

  }

  @override
  void onGetterException(String id, RedisQuery req, String exception) {}

  @override
  void onGetterResponse(String id, RedisResult result) {
    if (result is AuthResult) {
      AuthResult res = result;
      if (res.isSuccess) {
        onAuthenticated();
      } else {
        onAuthenticationFailed(res.info);
      }
    } /*else if (result is MultipleResult) {
      MultipleResult res = result;
      res.printDatas();
    }*/
  }
}
