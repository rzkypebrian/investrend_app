import 'BooleanString.dart';
import 'RedisProtocol.dart';

class RedisReply implements RedisProtocol {
  /*
  auth 1d26fd6fe2758f7b32729370b63724bc
  +OK

  GET SSI.FITR0000
  $-1

  MGET SSI.FITR000 SSI.FITR00001
  *2
  $-1
  $-1

  GET SSI.FITR007
  $186
  oauth_token:e6f718259062481db7bb930557fabef6|status:connected|message:loggedin|VersionDetail:1.0.128.0 - Desktop:Windows 7 Professional Service Pack 1 Bit32 - |time:2/17/2020 11:05:17 AM

  MGET SSI.FITR007 SSI.BEK
  *2
  $186
  oauth_token:e6f718259062481db7bb930557fabef6|status:connected|message:loggedin|VersionDetail:1.0.128.0 - Desktop:Windows 7 Professional Service Pack 1 Bit32 - |time:2/17/2020 11:05:17 AM
  $186
  oauth_token:2a0957b571fb4e8a95c69cd0cc6e9cdf|status:connected|message:loggedin|VersionDetail:1.0.128.0 - Desktop:Windows 7 Professional Service Pack 1 Bit64 - |time:2/17/2020 10:55:12 AM

  quit
  +OK

  */

  int count = 1;
  int nextIndex = 0;

  /// default butuh satu x reply, dioverride ama message dari redis
  bool completed = false;
  bool needMoreData() {
    return !completed;
  }

  List<BooleanString>? currentReply;

  bool insertReply(BooleanString data, int size) {
    if (currentReply == null) {
      // currentReply = new List<BooleanString>(size);
      currentReply = new List<BooleanString>.filled(size, data, growable: true);
    }
    currentReply?.add(data);
    nextIndex++;

    return nextIndex == currentReply!.length;
  }

  void processData(String? msg) {
    if (msg != null && msg.trim().length > 0) {
      if (msg.startsWith(RedisProtocol.POSITIVE) ||
          msg.startsWith(RedisProtocol.NEGATIVE)) {
        //res = new String[]{msg.charAt(0)+"",msg.substring(1,msg.length)};
        String message = msg.substring(1, msg.length);
        bool status = msg.startsWith(RedisProtocol.POSITIVE);
        insertReply(BooleanString(status, message), count);
      } else if (msg == RedisProtocol.DOLLAR_NO_DATA) {
        //res = new String[]{RedisProtocol.NILL};
      } else if (msg.startsWith(RedisProtocol.DOLLAR)) {
//      String lS = msg.substring(1,msg.length);
//      int length = Integer.parseInt(lS) + RedisProtocol.CR_LF_LENGTH;
//      msg = readInputStreamByte(is, new byte[length]);
//      res = new String[]{msg};
      } else if (msg.startsWith(RedisProtocol.COUNT)) {
//      int index = 0;
//      int loop = Integer.parseInt(msg.substring(1,msg.length));
//      res = new String[loop];
//      while ( index < loop) {
//      if(!isRun){
//      break;
//      }
//      String msg_rep = readInputStream(is);
//      if(msg_rep.equals(RedisProtocol.DOLLAR_NO_DATA)){
//      res[index] = RedisProtocol.NILL;
//      index++;
//      }else if(msg_rep.startsWith(RedisProtocol.DOLLAR)){
//      String lS = msg_rep.substring(1,msg_rep.length);
//      int length = Integer.parseInt(lS) + RedisProtocol.CR_LF_LENGTH;
//      res[index] = readInputStreamByte(is, new byte[length]);
//      index++;
//      }else if(msg_rep.startsWith(RedisProtocol.COLON)){
//      res[index] = msg_rep.substring(1);
//      index++;
//      }
//      }
      }
    } else {
      //res = new String[]{RedisProtocol.NILL};
    }
  }
}
