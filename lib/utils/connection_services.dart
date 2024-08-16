// ignore_for_file: unused_local_variable, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:async';

import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/sosmed_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:xml/xml.dart';

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image/image.dart' as imageTools;

//dart:html
class TradingHttpException implements IOException {
  final int code;
  final String? reasonPhrase;
  final String body;
  final Uri? uri;

  const TradingHttpException(this.code, this.reasonPhrase, this.body,
      {this.uri});

  bool isUnauthorized() {
    return code == 401 ||
        StringUtils.equalsIgnoreCase(reasonPhrase, 'unauthorized');
  }

  bool isErrorTrading() {
    return code == 500;
  }

  String? message() {
    if (code == 500 || code == 401) {
      Map<String, dynamic>? parsedJson = jsonDecode(body);
      if (parsedJson != null) {
        return StringUtils.noNullString(parsedJson['message']);
      }
    }
    return reasonPhrase;
  }

  String toString() {
    var b = new StringBuffer()
      ..write('TradingHttpException: ')
      ..write(message())
      ..write(' ' + code.toString());
    var uri = this.uri;
    if (uri != null) {
      b.write(', uri = $uri');
    }
    return b.toString();
  }
}

class TradingHttp {
  Token? token = Token('', '');

  // bali
  // final String _tradingBaseUrl = 'dev.buanacapital.com:8888';
  // final bool _is_production = false;

  //"https://dev.buanacapital.com:8888/setserverstatus?server=${name}&port=${port}&connection=${count}"
  // live ada 2 port
  //TODO: LIVE AND PRODUCTION
  final String _tradingBaseUrl = 'ws1.buanacapital.com:8888';
  final bool _is_production = true;

  // String _tradingBaseUrl = 'investrend-prod.teltics.in:8888';
  // bali
  // String _tradingBaseUrl = '103.109.155.226:8888';

  // live ada 2 port∂ƒ
  // String _tradingBaseUrl = '36.89.110.93:8888';
  //String _tradingBaseUrl = '36.89.110.93:8899';

  /* request bili 2021-10-07
  String _tradingBaseUrl = 'olt1.buanacapital.com:8888';
  bool _is_production = true;

  void setProduction(bool flag){
    _is_production = flag;
    if(_is_production){
      _tradingBaseUrl = 'olt1.buanacapital.com:8888';
    }else{
      _tradingBaseUrl = 'dev.buanacapital.com:8888';
    }
  }
  */

  static final String _sosmedBaseUrl = 'investrend-prod.teltics.in';

  // http://investrend.teltics.in/api/

  bool get is_production => _is_production;

  static int sosmed_timeout_in_seconds = 30;
  static int trading_timeout_in_seconds = 60;

  TradingHttp() {
    token?.load();
  }

  bool hasToken() {
    return !StringUtils.isEmtpy(token?.access_token) &&
        !StringUtils.isEmtpy(token?.refresh_token);
  }

  //String get refresh_token => _refresh_token;
  String? get refresh_token => token?.refresh_token;

  String get tradingBaseUrl => _tradingBaseUrl;
  //TODO : ACCESS TOKEN
  //String get access_token => _access_token;
  String? get access_token => token?.access_token;

  // set tradingBaseUrlNew(String newUrl) {
  //   _tradingBaseUrl = newUrl;
  // }

  // ====================================================================
  // Sosmed Start =======================================================
  // ====================================================================

  Future<FetchComment> sosmedFetchComment(String filterPostId,
      /*String access_token,*/ String? platform, String? version,
      {int? page, String language = ''}) async {
    String path = 'api/post-comments';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');
    var parameters;
    if (page != null) {
      parameters = {
        'access_token': token?.access_token,
        'filter_post_id': filterPostId,
        'page': page.toString(),
        'language': language,
        'platform': platform,
        'version': version,
      };
    } else {
      parameters = {
        'access_token': token?.access_token,
        'filter_post_id': filterPostId,
        'language': language,
        'platform': platform,
        'version': version,
      };
    }

    final response = await http
        .get(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('fetch_comment --> ' + response.body);

      FetchComment fetchComment =
          FetchComment.fromJson(jsonDecode(response.body));

      DebugWriter.info('fetch_comment --> \n' + fetchComment.toString());
      // String _access_token = user.token?.access_token;
      // String _refresh_token = user.token.refresh_token;
      // token.update(_access_token, _refresh_token);
      // token.save();
      return fetchComment;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<FetchPost> sosmedFetchPost(
      /*String access_token,*/ String? platform, String? version,
      {int? page, String? language = '', bool mine = false}) async {
    String path = 'api/posts';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');
    var parameters;
    if (page != null) {
      parameters = {
        'access_token': token?.access_token,
        'page': page.toString(),
        'mine': (mine ? '1' : ''),
        'language': language,
        'platform': platform,
        'version': version,
      };
    } else {
      parameters = {
        'access_token': token?.access_token,
        'mine': (mine ? '1' : ''),
        'language': language,
        'platform': platform,
        'version': version,
      };
    }

    final response = await http
        .get(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('fetch_post --> ' + response.body);

      FetchPost fetchPost = FetchPost.fromJson(jsonDecode(response.body));

      DebugWriter.info('fetch_post --> \n' + fetchPost.toString());
      // String _access_token = user.token?.access_token;
      // String _refresh_token = user.token.refresh_token;
      // token.update(_access_token, _refresh_token);
      // token.save();
      return fetchPost;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitBasic> sosmedDeletePost(int id, String platform, String version,
      {String language = ''}) async {
    String path = 'api/posts/delete';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': token?.access_token,
      'id': id.toString(),
      'language': language,
      'platform': platform,
      'version': version,
    };
    DebugWriter.info(parameters);
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('delete_post --> ' + response.body);

      SubmitBasic result = SubmitBasic.fromJson(jsonDecode(response.body));

      return result;
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitBasic> sosmedFollow(
      int userId, bool flag, String platform, String version,
      {String language = ''}) async {
    String path = 'api/users/follow';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': token?.access_token,
      'user_id': userId.toString(),
      'state': flag ? '1' : '0',
      'language': language,
      'platform': platform,
      'version': version,
    };
    DebugWriter.info(parameters);
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('delete_post --> ' + response.body);

      SubmitBasic result = SubmitBasic.fromJson(jsonDecode(response.body));

      return result;
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitLike>? sosmedLike(bool flag,
      /*String access_token,*/ int? postId, String? platform, String? version,
      {String language = ''}) async {
    String path = 'api/posts/like';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': token?.access_token,
      'post_id': postId.toString(),
      //'flag': flag.toString(),
      'state': flag ? '1' : '0',

      'language': language,
      'platform': platform,
      'version': version,
    };
    DebugWriter.info(parameters);
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    //{"status":200,"message":"Like created!","result":{"user_id":1,"post_id":"24","updated_at":"2021-07-27T05:15:02.000000Z","created_at":"2021-07-27T05:15:02.000000Z","id":9}}
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('like --> ' + response.body);

      SubmitLike result = SubmitLike.fromJson(jsonDecode(response.body));

      //print('fetch_post --> \n'+fetchPost.toString());
      // String _access_token = user.token?.access_token;
      // String _refresh_token = user.token.refresh_token;
      // token.update(_access_token, _refresh_token);
      // token.save();
      //return fetchPost;
      return result;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitVote>? sosmedVote(
      /*String access_token,*/ int? pollId, String? platform, String? version,
      {String language = ''}) async {
    String path = 'api/posts/vote';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': token?.access_token,
      'post_poll_id': pollId.toString(),
      'language': language,
      'platform': platform,
      'version': version,
    };
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    //{"status":200,"message":"Like created!","result":{"user_id":1,"post_id":"24","updated_at":"2021-07-27T05:15:02.000000Z","created_at":"2021-07-27T05:15:02.000000Z","id":9}}
    /*
    {
      "status": 200,
      "message": "Poll created!",
      "result": {
        "user_id": 1,
        "post_poll_id": "1",
        "updated_at": "2021-07-27T15:35:36.000000Z",
        "created_at": "2021-07-27T15:35:36.000000Z",
        "id": 8
      }
    }
    */
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('vote --> ' + response.body);

      SubmitVote result = SubmitVote.fromJson(jsonDecode(response.body));

      //print('fetch_post --> \n'+fetchPost.toString());
      // String _access_token = user.token?.access_token;
      // String _refresh_token = user.token.refresh_token;
      // token.update(_access_token, _refresh_token);
      // token.save();
      //return fetchPost;
      return result;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitCreateComment>? sosmedCreateComment(
      /*String access_token,*/ int postId,
      String text,
      String? platform,
      String? version,
      {String language = ''}) async {
    String path = 'api/post-comments/create';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': access_token,
      'post_id': postId.toString(),
      'text': text,
      'language': language,
      'platform': platform,
      'version': version,
    };
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    //{"status":200,"message":"Like created!","result":{"user_id":1,"post_id":"24","updated_at":"2021-07-27T05:15:02.000000Z","created_at":"2021-07-27T05:15:02.000000Z","id":9}}
    /*
    {
      "status": 200,
      "message": "Poll created!",
      "result": {
        "user_id": 1,
        "post_poll_id": "1",
        "updated_at": "2021-07-27T15:35:36.000000Z",
        "created_at": "2021-07-27T15:35:36.000000Z",
        "id": 8
      }
    }
    */
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('create_comment --> ' + response.body);

      SubmitCreateComment result =
          SubmitCreateComment.fromJson(jsonDecode(response.body));

      //print('fetch_post --> \n'+fetchPost.toString());
      // String _access_token = user.token?.access_token;
      // String _refresh_token = user.token.refresh_token;
      // token.update(_access_token, _refresh_token);
      // token.save();
      //return fetchPost;
      return result;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitCreateText>? sosmedCreatePostTextWithAttachments(
      String text,
      List<String> attachments,
      /*String access_token,*/ String? platform,
      String? version,
      {String language = ''}) async {
    String path = 'api/posts/create';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': token?.access_token,
      'type': 'TEXT',
      'text': text,
      'language': language,
      'platform': platform,
      'version': version,
    };

    DebugWriter.info(parameters);
    var uri = Uri.http(_sosmedBaseUrl, path, parameters);
    var request = new http.MultipartRequest("POST", uri);

    int countAttachments = Utils.safeLenght(attachments);
    for (int i = 0; i < countAttachments; i++) {
      //final File file = File(pickedFile.path);
      String filePath = attachments.elementAt(i);
      imageTools.Image? imageFile = Utils.resizeImage(filePath);

      //File imageFile = File(attachments.elementAt(i));
      if (imageFile != null) {
        // bool exist = imageFile.existsSync();
        // if(exist){

        List<int> encodedJpeg = imageTools.encodeJpg(imageFile);
        var multipartFile = new http.MultipartFile.fromBytes(
          'attachments[]',
          encodedJpeg,
          filename: basename(filePath),
          contentType: MediaType.parse('image/jpeg'),
        );
        request.files.add(multipartFile);
        DebugWriter.info('create_text_attachments adding imageFile : ' +
            filePath +
            '  length : ' +
            encodedJpeg.length.toString());
      } else {
        DebugWriter.info(
            'create_text_attachments NOT adding imageFile[$i] file is NULL');
      }
    }

    /*
      File imageFile = File(attachments.elementAt(i));
      if(imageFile != null){
        bool exist = imageFile.existsSync();
        if(exist){

          var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
          var length = await imageFile.length();
          var multipartFile = new http.MultipartFile('attachments[]', stream, length, filename: basename(imageFile.path));
          request.files.add(multipartFile);
          DebugWriter.info('create_text_attachments adding imageFile : '+imageFile.path+'  length : $length');
        }else{
          DebugWriter.info('create_text_attachments NOT adding imageFile[$i] existsSync : $exist');
        }
      }else{
        DebugWriter.info('create_text_attachments NOT adding imageFile[$i] file is NULL');
      }
    }
    */

    //var msStream = request.finalize();
    // var totalByteLength = request.contentLength;
    //request.contentLength = totalByteLength;

    //request.headers.set(HttpHeaders.contentTypeHeader, requestMultipart.headers[HttpHeaders.contentTypeHeader]);
    // int byteCount = 0;
    // Stream<List<int>> streamUpload = msStream.transform(
    //   new StreamTransformer.fromHandlers(
    //     handleData: (data, sink) {
    //       sink.add(data);
    //
    //       byteCount += data.length;
    //       DebugWriter.info('onUploadProgress : $byteCount / $totalByteLength');
    //       // if (onUploadProgress != null) {
    //       //   onUploadProgress(byteCount, totalByteLength);
    //       //   // CALL STATUS CALLBACK;
    //       // }
    //     },
    //     handleError: (error, stack, sink) {
    //       throw error;
    //     },
    //     handleDone: (sink) {
    //       sink.close();
    //       // UPLOAD DONE;
    //     },
    //   ),
    // );

    //await request.addStream(streamUpload);
    //request.headers.addAll(headers);

    // asli
    var response = await request.send();

    // coba progress upload
    /*
    var response = request.send();
    await response.asStream().transform(new StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        sink.add(data);

        byteCount += data.contentLength;
        DebugWriter.info('onUploadProgress : $byteCount / $totalByteLength');
        // if (onUploadProgress != null) {
        //   onUploadProgress(byteCount, totalByteLength);
        //   // CALL STATUS CALLBACK;
        // }
      },
      handleError: (error, stack, sink) {
        throw error;
      },
      handleDone: (sink) {
        sink.close();
        // UPLOAD DONE;
      },
    ));
    */
    DebugWriter.info('create_text_attachments --> response.statusCode : ' +
        response.statusCode.toString());
    if (response.statusCode == 200) {
      // await for (var value in response.stream) {
      //   sum += value;
      // }

      final body = await response.stream.bytesToString();
      //var body = await http.Response.fromStream(response);

      SubmitCreateText result = SubmitCreateText.fromJson(jsonDecode(body));

      return result;

      /*
      response.stream.transform(utf8.decoder).listen((body) {
        DebugWriter.info('create_text_attachments --> ' + body);

        SubmitCreateText result = SubmitCreateText.fromJson(jsonDecode(body));

        return result;
      });
      */
    } else {
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      final body = await response.stream.bytesToString();
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, body);
    }

    /*
    final response = await http.post(uri).timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      DebugWriter.info('create_text --> '+response.body);

      SubmitCreateText result = SubmitCreateText.fromJson(jsonDecode(response.body));

      return result;
    } else {
      throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
    }
     */
  }

  Future<SubmitCreateText> sosmedCreatePostText(
      String text, /*String access_token,*/ String? platform, String? version,
      {String language = ''}) async {
    // if(Utils.safeLenght(attachments) > 0){
    //   return await _createPostTextWithAttachments(text, attachments, access_token, platform, version);
    // }
    String path = 'api/posts/create';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': token?.access_token,
      'type': 'TEXT',
      'text': text,
      'language': language,
      'platform': platform,
      'version': version,
    };
    var uri = Uri.http(_sosmedBaseUrl, path, parameters);
    final response = await http
        .post(uri)
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));

    /*
    {
      "status": 200,
      "message": "Poll created!",
      "result": {
        "user_id": 1,
        "post_poll_id": "1",
        "updated_at": "2021-07-27T15:35:36.000000Z",
        "created_at": "2021-07-27T15:35:36.000000Z",
        "id": 8
      }
    }
    */
    if (response.statusCode == 200) {
      DebugWriter.info('create_text --> ' + response.body);

      SubmitCreateText result =
          SubmitCreateText.fromJson(jsonDecode(response.body));

      return result;
    } else {
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitCreateTransaction>? sosmedCreatePostTransaction(
      String? code,
      String transactionType,
      int? buyPrice,
      int? sellPrice,
      String text,
      String? orderId,
      String publishTime,
      String? orderDate,
      String? platform,
      String? version,
      {String language = ''}) async {
    String path = 'api/posts/create';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': access_token,
      'type': 'TRANSACTION',
      'code': code,
      'start_price': buyPrice.toString(),
      'transaction_type': transactionType, // BUY  or SELL
      'text': text,
      'sell_price': sellPrice.toString(),

      'publish_time': publishTime, // NOW  or PENDING
      'order_id': orderId,
      'order_date': orderDate,

      'language': language,
      'platform': platform,
      'version': version,
    };

    DebugWriter.info(parameters);
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    /*
    {
        "status": 200,
        "message": "Post created!",
        "result": {
            "slug": "TRANSACTION-1627543115-3919",
            "user_id": 1,
            "type": "TRANSACTION",
            "text": "Coba beli",
            "code": "BBCA",
            "start_price": "32500",
            "transaction_type": "BUY",
            "sell_price": 0,
            "updated_at": "2021-07-29T07:18:35.000000Z",
            "created_at": "2021-07-29T07:18:35.000000Z",
            "id": 55,
            "polls": [],
            "top_comments": [],
            "liked": false,
            "voted": false
        }
    }
    */
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('create_transaction --> ' + response.body);

      SubmitCreateTransaction result =
          SubmitCreateTransaction.fromJson(jsonDecode(response.body));

      return result;
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitCreatePolls>? sosmedCreatePostPoll(
      String text,
      List<String> polls,
      String expireAt,
      /*String access_token,*/ String? platform,
      String? version,
      {String language = ''}) async {
    String path = 'api/posts/create';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': access_token,
      'type': 'POLL',
      'text': text,
      'expired_at': expireAt,
      'polls': polls.join(','),
      'language': language,
      'platform': platform,
      'version': version,
    };
    DebugWriter.info(parameters);
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    /*
    {
      "status": 200,
      "message": "200_post_created",
      "result": {
          "slug": "POLL-1627488135-805",
          "user_id": 1,
          "type": "POLL",
          "text": "Pada dapat BBCA gk?",
          "updated_at": "2021-07-28T16:02:15.000000Z",
          "created_at": "2021-07-28T16:02:15.000000Z",
          "id": 15,
          "polls": [
              {
                  "id": 7,
                  "post_id": 15,
                  "text": "YA",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              },
              {
                  "id": 8,
                  "post_id": 15,
                  "text": "TIDAK",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              }
          ],
          "top_comments": []
      }
    }
    */
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('create_polls --> ' + response.body);

      SubmitCreatePolls result =
          SubmitCreatePolls.fromJson(jsonDecode(response.body));

      return result;
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);

      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<SubmitCreatePrediction>? sosmedCreatePostPrediction(
      String transactionType,
      String text,
      String code,
      int startPrice,
      int targetPrice,
      String expireAt,
      /*String access_token,*/
      String? platform,
      String? version,
      {String language = ''}) async {
    String path = 'api/posts/create';
    DebugWriter.info('path = $_sosmedBaseUrl/$path');

    var parameters = {
      'access_token': access_token,
      'type': 'PREDICTION',
      'text': text,
      'code': code,
      'transaction_type': transactionType,
      'target_price': targetPrice.toString(),
      'start_price': startPrice.toString(),
      'expired_at': expireAt,
      'language': language,
      'platform': platform,
      'version': version,
    };
    DebugWriter.info(parameters);
    final response = await http
        .post(Uri.http(_sosmedBaseUrl, path, parameters))
        .timeout(Duration(seconds: sosmed_timeout_in_seconds));
    /*
    {
      "status": 200,
      "message": "200_post_created",
      "result": {
          "slug": "POLL-1627488135-805",
          "user_id": 1,
          "type": "POLL",
          "text": "Pada dapat BBCA gk?",
          "updated_at": "2021-07-28T16:02:15.000000Z",
          "created_at": "2021-07-28T16:02:15.000000Z",
          "id": 15,
          "polls": [
              {
                  "id": 7,
                  "post_id": 15,
                  "text": "YA",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              },
              {
                  "id": 8,
                  "post_id": 15,
                  "text": "TIDAK",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              }
          ],
          "top_comments": []
      }
    }
    */
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('create_prediction --> ' + response.body);

      SubmitCreatePrediction result =
          SubmitCreatePrediction.fromJson(jsonDecode(response.body));

      return result;
    } else {
      // If the server did not return a 200 OK response,
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  // Sosmed End =========================================================
  // ====================================================================

  Future<RegisterReply> register(
      String? username,
      String? realname,
      String? handphone,
      String? email,
      String? password,
      String? referral,
      String? platform,
      String? version,
      {String? invitation = ''}) async {
    //POST: http://investrend-prod.teltics.in:8888/register

    /*
    {
      "username": "dealer1",
      "realname": "wulan",
      "handphone": "123456",
      "email": "wulan@test.com",
      "password": "password",
      "referral": "emil"
    }
    */

    Map data = {
      "username": username,
      "realname": realname,
      "handphone": handphone,
      "email": email,
      "password": password,
      "referral": referral,
      "invitation": invitation,
      "platform": platform,
      "version": version
    };

    DebugWriter.info(data);

    //encode Map to JSON
    var body = json.encode(data);

    final response = await http.post(Uri.https(_tradingBaseUrl, 'register'),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('register --> ' + response.body);
      //return response.body;
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      return RegisterReply(parsedJson?['message'], parsedJson?['username'],
          parsedJson?['email']);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<RegisterReply> registerPin(
      String? username, String? pin, String? platform, String? version) async {
    //POST: http://investrend-prod.teltics.in:8888/registerpin
    /*
    {
      "username": "dealer1",
    "pin": "111111"
    }

    success:
    {
    "message": "success",
    "username": "dealer1"
    }

    failed:
    {
    "message": "pin already set"
    }

    or:
    {
    "message": "Invalid Data"
    }
    */

    Map data = {
      "username": username,
      "pin": pin,
      "platform": platform,
      "version": version
    };

    DebugWriter.info(data);

    //encode Map to JSON
    var body = json.encode(data);

    final response = await http.post(Uri.https(_tradingBaseUrl, 'registerpin'),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('register_pin --> ' + response.body);
      //return response.body;
      Map<String, dynamic> parsedJson = jsonDecode(response.body);
      return RegisterReply(
          parsedJson['message'], parsedJson['username'], parsedJson['email']);
    } else {
      DebugWriter.info('Error : ' +
          response.statusCode.toString() +
          '  ' +
          response.reasonPhrase!);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<RegisterReply> changePin(String? username, String? pinOld,
      String? pinNew, String? platform, String? version) async {
    //POST: http://investrend-prod.teltics.in:8888/registerpin
    /*
    {
      "username": "dealer1",
    "pin": "111111"
    }

    success:
    {
    "message": "success",
    "username": "dealer1"
    }

    failed:
    {
    "message": "pin already set"
    }

    or:
    {
    "message": "Invalid Data"
    }
    */
    //"oldpin": "111111",
    //"newpin": "1111"

    // DebugWriter.info(data);
    //
    // //encode Map to JSON
    // var body = json.encode(data);
    //
    // final response = await http.post(Uri.https(_tradingBaseUrl, 'changepin'), headers: {"Content-Type": "application/json"}, body: body);

    String auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "username": username,
      "oldpin": pinOld,
      "newpin": pinNew,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);

    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'changepin'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('change_pin --> ' + response.body);
      //return response.body;
      Map<String, dynamic> parsedJson = jsonDecode(response.body);
      return RegisterReply(
          parsedJson['message'], parsedJson['username'], parsedJson['email']);
    } else {
      DebugWriter.info('Error : ' +
          response.statusCode.toString() +
          '  ' +
          response.reasonPhrase!);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<RegisterReply> changePassword(String? username, String? passwordOld,
      String? passwordNew, String? platform, String? version) async {
    //POST: http://investrend-prod.teltics.in:8888/registerpin

    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "username": username,
      "oldpassword": passwordOld,
      "newpassword": passwordNew,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);

    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'changepassword'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('change_password --> ' + response.body);
      //return response.body;
      Map<String, dynamic> parsedJson = jsonDecode(response.body);
      return RegisterReply(
          parsedJson['message'], parsedJson['username'], parsedJson['email']);
    } else {
      DebugWriter.info('Error : ' +
          response.statusCode.toString() +
          '  ' +
          response.reasonPhrase!);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<User> login(
      String email, String password, String? platform, String? version) async {
    //POST: 192.168.110.213:8888/login
    // Map data;
    // if(username.contains("@")){
    //   data = {"email": username, "password": password, "platform": platform, "version": version};
    // } else {
    //   data = {"username": username, "password": password, "platform": platform, "version": version};
    // }
    //Map data = {"username": username, "password": password, "platform": platform, "version": version};
    Map data = {
      "email": email,
      "password": password,
      "platform": platform,
      "version": version
    };

    DebugWriter.info(data);
    /*
    result:
    {
        "accounts": [
            {
                "accountcode": "E108",
                "accountname": "EKA PRIADI WONGSO",
                "branchcode": "1",
                "brokercode": "RF"
            },
            {
                "accountcode": "E108M",
                "accountname": "EKA PRIADI WONGSO",
                "branchcode": "1",
                "brokercode": "RF"
            }
        ],
        "token": {
            "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3NfdXVpZCI6IjcwOTc2Y2QzLTBjNDItNDU5OS1iYzZlLTAyMGZiOWE4YjU2MCIsImV4cCI6MTYyMjA4NzUwOSwidXNlcm5hbWUiOiJ1c2VyIn0.u3qTsagVCLXnk_vJV49DVY1X0j75jL0VwccytCLsmXM",
            "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MjIxNzAzMDksInJlZnJlc2hfdXVpZCI6IjcwOTc2Y2QzLTBjNDItNDU5OS1iYzZlLTAyMGZiOWE4YjU2MCsrdXNlciIsInVzZXJuYW1lIjoidXNlciJ9.zz0IcNtri9FnJqq1MZ3eApQGxHrf-SbLvvHKYNAaryk"
        },
        "username": "user"
    }
     */
    //encode Map to JSON
    var body = json.encode(data);

    // var response = await http.post(url,
    //     headers: {"Content-Type": "application/json"},
    //     body: body
    // );

    // try{
    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'login'),
            headers: {"Content-Type": "application/json"}, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));

    DebugWriter.info('login statusCode ' + response.statusCode.toString());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      DebugWriter.info('login --> ' + response.body);

      User user = User.fromJson(jsonDecode(response.body));

      String? AccessToken = user.token?.access_token;
      String? RefreshToken = user.token?.refresh_token;
      token?.update(AccessToken, RefreshToken);
      token?.save();
      return user;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
    // }catch(error){
    //
    // }
  }

  Future<User> refresh(String? platform, String? version,
      {String? refresh_token /*, String device=''*/}) async {
    //POST: 192.168.110.213:8888/refresh

    if (StringUtils.isEmtpy(refresh_token)) {
      refresh_token = token?.refresh_token;
    }
    Map data = {
      "refresh_token": refresh_token,
      //"device": device,
      "platform": platform,
      "version": version
    };

    DebugWriter.info('refresh try');
    DebugWriter.info(data);
    //encode Map to JSON
    var body = json.encode(data);

    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'refresh'),
            headers: {"Content-Type": "application/json"}, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(response.body);
      DebugWriter.info('refresh --> ' + response.body);

      User user = User.fromJson(jsonDecode(response.body));
      String? AccessToken = user.token?.access_token;
      String? RefreshToken = user.token?.refresh_token;
      token?.update(AccessToken, RefreshToken);
      token?.save();
      return user;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);

      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
    }
  }

  Future<String?>? updateBiography(
      String? biography, String? platform, String? version) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {"bio": biography, "platform": platform, "version": version};

    DebugWriter.info('updateBiography try');
    DebugWriter.info(headers);
    DebugWriter.info(data);
    //encode Map to JSON
    var body = json.encode(data);

    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'setbio'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('updateBiography --> ' + response.body);
      /*
      "message": "success",
      "username": "richy"
      */
      var parsedJson = jsonDecode(response.body);
      String? message = '';
      String? username = '';
      if (parsedJson != null) {
        message = StringUtils.noNullString(parsedJson['message']);
        username = StringUtils.noNullString(parsedJson['username']);
      }
      return message;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<String?> logout(String? platform, String? version) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {"platform": platform, "version": version};
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);

    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'logout'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));

    DebugWriter.info('logout --> ' + response.statusCode.toString());
    DebugWriter.info('logout --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        return StringUtils.noNullString(parsedJson['message']);
      }
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<String?> loginPin(
      String pin, String? platform, String? version) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {"pin": pin, "platform": platform, "version": version};
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);

    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'loginpin'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));

    DebugWriter.info('loginPin --> ' + response.statusCode.toString());
    DebugWriter.info('loginPin --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        return StringUtils.noNullString(parsedJson['message']);
      }
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<Profile> getProfile(/*String platform, String version*/) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    // Map data = { "platform": platform, "version": version};
    //encode Map to JSON
    DebugWriter.info(headers);
    // DebugWriter.info(data);
    // var body = json.encode(data);
    // DebugWriter.info(body);
    DebugWriter.info('getProfile');
    final response = await http
        .get(
          Uri.https(_tradingBaseUrl, 'getprofile'),
          headers: headers, /*body: body*/
        )
        .timeout(Duration(seconds: trading_timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('getProfile --> ' + response.body);

      /*
      {
        "bio": "hello world i am an egg",
        "email": "richy@investrend.co.id",
        "handphone": "6288888888",
        "picture": "/images/4dc928cc-4b18-45bc-9b48-a0125c91e0b9.jpg",
        "realname": "richy",
        "referral": "tes ref",
        "username": "richy"
      }
      */
      /*
      Map<String, dynamic> parsedJson = jsonDecode(response.body);
      String bio = StringUtils.noNullString(parsedJson['bio']);
      String email = StringUtils.noNullString(parsedJson['email']);
      String handphone = StringUtils.noNullString(parsedJson['handphone']);
      String picture = StringUtils.noNullString(parsedJson['picture']);
      String realname = StringUtils.noNullString(parsedJson['realname']);
      String referral = StringUtils.noNullString(parsedJson['referral']);
      String username = StringUtils.noNullString(parsedJson['username']);
      */
      return Profile.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<String?> checkInvitation(
      String? code, String? platform, String? version) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    var parameters = {'code': code, 'platform': platform, 'version': version};

    DebugWriter.info(parameters);

    // Map data = { "platform": platform, "version": version};
    //encode Map to JSON
    DebugWriter.info(headers);
    // DebugWriter.info(data);
    // var body = json.encode(data);
    // DebugWriter.info(body);
    DebugWriter.info('checkInvitation');
    final response = await http
        .get(
          Uri.https(_tradingBaseUrl, 'checkinvitation', parameters),
          headers: headers, /*body: body*/
        )
        .timeout(Duration(seconds: trading_timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('checkInvitation --> ' + response.body);

      /*
      {
          "invitationcode": "ZFzscPNTKmwKWSD",
          "message": "success"
      }
      */
      final parsedJson = jsonDecode(response.body);
      String? message = StringUtils.noNullString(parsedJson['message']);

      return message;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<BankRDN> getBankRDN(
      String? account, String? platform, String? version) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {"acct": account, "platform": platform, "version": version};
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'bankrdn'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));
    //final response = await http.post(Uri.http(_tradingBaseUrl, 'bankrdn'), headers: {"Content-Type": "application/json"}, body: body).timeout(Duration(seconds: trading_timeout_in_seconds));

    DebugWriter.info('getBankRDN --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      return BankRDN.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<String> submitFundOut(
      String email,
      String realname,
      String account,
      String amount,
      String rdnbank,
      String rdnno,
      String rdnname,
      String bank,
      String bankno,
      String bankname,
      String date,
      String message,
      String? platform,
      String? version) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "email": email,
      "realname": realname,
      "acct": account,
      "amount": amount,
      "rdnbank": rdnbank,
      "rdnno": rdnno,
      "rdnname": rdnname,
      "bank": bank,
      "bankno": bankno,
      "bankname": bankname,
      "date": date,
      "message": message,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'fundout'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));
    DebugWriter.info('submitFundOut --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      String message = '';
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        message = parsedJson['message'];
      }
      return message;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<BankAccount> getBankAcccount(
      String? account, String? platform, String? version) async {
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {"acct": account, "platform": platform, "version": version};
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'bankaccount'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));
    //final response = await http.post(Uri.http(_tradingBaseUrl, 'bankrdn'), headers: {"Content-Type": "application/json"}, body: body).timeout(Duration(seconds: trading_timeout_in_seconds));

    DebugWriter.info('getBankAcccount --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      return BankAccount.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<OrderReply> orderNew(
      String? reffID,
      String? broker,
      String? account,
      String? user,
      String? buySell,
      String? stock,
      String? board,
      String? prices,
      String? qtys,
      String? platform,
      String? version,
      {int? type = 0,
      int counter = 1}) async {
    //192.168.110.213:8888/ordernew
    /*
    {
        "broker": "RF",
        "acct": "A76",
        "user": "user",
        "platform": "desktop",
        
        "bs": "S",
        "stock": "TLKM",
        "board": "RG",
        "price": "3300",
        "qty": "5",
        "type": "1",
        "counter": "5"
    }
    {
    "broker":"RF",
    "acct":"E108",
    "user":"user",
    "bs":"B",
    "stock":"PWON",
    "board":"RG",
    "price":100,"qty":10,"type":0,"counter":1,"platform":"mobile"}

    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,

      "refno": reffID,

      "bs": buySell,
      "stock": stock,
      "board": board,
      "price": prices,
      "qty": qtys,
      "type": type.toString(), // 0 = normal   1 = Loop   2 = SPLIT   3 = FAST
      "counter": counter.toString(),

      "platform": platform, "version": version
    };
    //encode Map to JSON
    DebugWriter.info('--> Order - headers');
    DebugWriter.info(headers);
    DebugWriter.info('--> Order - data');
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info('--> Order - body');
    DebugWriter.info(body);
    final response = await http.post(Uri.https(_tradingBaseUrl, 'ordernew'),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();

      DebugWriter.info('<-- Order -  response.body');
      DebugWriter.info(response.body);
      OrderReply orderReply = OrderReply.fromJson(jsonDecode(response.body));
      return orderReply;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<OrderReply> amend(
      String reffID,
      String? broker,
      String? account,
      String? user,
      String? orderid,
      int? price,
      int? qty,
      String? platform,
      String? version) async {
    //192.168.110.213:8888/orderamend
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "A12",
    "price": "3100",
    "qty": "25"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "refno": reffID,
      "price": price.toString(),
      "qty": qty.toString(),
      "orderid": orderid,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info('--> Amend - headers');
    DebugWriter.info(headers);
    DebugWriter.info('--> Amend - data');
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info('--> Amend - body');
    DebugWriter.info(body);
    final response = await http.post(Uri.https(_tradingBaseUrl, 'orderamend'),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('<-- Amend -  response.body');
      DebugWriter.info(response.body);

      OrderReply orderReply = OrderReply.fromJson(jsonDecode(response.body));
      return orderReply;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<String> withdraw(String? reffID, String? broker, String? account,
      String? user, String? orderid, String? platform, String? version) async {
    //192.168.110.213:8888/orderwithdraw
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "orderid": orderid,
      "refno": reffID,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http.post(
        Uri.https(_tradingBaseUrl, 'orderwithdraw'),
        headers: headers,
        body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info(response.body);
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);

      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<StockPosition> stock_position(String? broker, String? account,
      String? user, String? platform, String? version,
      {String? stock = ''}) async {
    //192.168.110.213:8888/stockposition
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "stock": stock,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'stockposition'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('stock_position --> ' + response.body);
      StockPosition stockPosition =
          StockPosition.fromJson(jsonDecode(response.body));
      DebugWriter.info('stock_position parsed : ' +
          stockPosition.accountcode! +
          '  stockList.size : ' +
          stockPosition.stockListSize().toString());
      return stockPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<CashPosition> cashPosition(String? broker, String? account,
      String? user, String? platform, String? version) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http.post(Uri.https(_tradingBaseUrl, 'cashposition'),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      DebugWriter.info('cash_position --> ' + response.body);
      CashPosition cashPosition =
          CashPosition.fromJson(jsonDecode(response.body));

      return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<List<OrderStatus>> orderStatus(String? broker, String? account,
      String? user, String? platform, String? version,
      {String orderid = '',
      bool historical = false,
      String historicalFilterTransaction = '',
      String historicalFilterPeriod = '',
      String? stock = ''}) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "orderid": orderid,
      "platform": platform,
      "version": version,

      "stock": stock,

      // historical
      "type": historicalFilterTransaction,
      "period": historicalFilterPeriod,
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    String path = 'orderstatus';
    if (historical) {
      path = 'orderstatushist';
    }
    final response = await http.post(
        Uri.https(_tradingBaseUrl, path /*'orderstatus'*/),
        headers: headers,
        body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      if (historical) {
        DebugWriter.info('order_status historical --> ' + response.body);
      } else {
        DebugWriter.info('order_status --> ' + response.body);
      }

      //CashPosition cashPosition = CashPosition.fromJson(jsonDecode(response.body));
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      return parsed
          .map<OrderStatus>((json) => OrderStatus.fromJson(json))
          .toList();

      //return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      //throw TradingHttpException(response.statusCode, response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<List<StockHist>> list_stock_hist(
    String? broker,
    String? account,
    String? user,
    String? platform,
    String? version,
  ) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "user": "cakrahimawan",
    "acct": "C35",
    "platform": "desktop",
    "stock": "TAPG"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "user": user,
      "acct": account,
      "platform": platform,
      "version": version,
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    String path = 'liststockhist';
    final response = await http.post(Uri.https(_tradingBaseUrl, path),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      DebugWriter.info('list_stock_hist --> ' + response.body);

      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      List<StockHist> list =
          parsed.map<StockHist>((json) => StockHist.fromJson(json)).toList();
      return list;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<ReportStockHistData> report_stock_hist(String? broker, String? account,
      String? user, String? stock, String? platform, String? version,
      {String bs = '', String from = '', String to = ''}) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "user": "cakrahimawan",
    "acct": "C35",
    "platform": "desktop",
    "stock": "TAPG"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "user": user,
      "acct": account,
      "platform": platform,
      "version": version,
      "stock": stock,
      "bs": bs,
      "from": from,
      "to": to,
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    String path = 'reportstockhist';
    final response = await http.post(Uri.https(_tradingBaseUrl, path),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      DebugWriter.info('report_stock_hist --> ' + response.body);

      //CashPosition cashPosition = CashPosition.fromJson(jsonDecode(response.body));
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      List<ReportStockHist> list = parsed
          .map<ReportStockHist>((json) => ReportStockHist.fromJson(json))
          .toList();
      ReportStockHistData result = ReportStockHistData();
      result.datas = list;
      return result;
      //return parsed.map<ReportStockHist>((json) => ReportStockHist.fromJson(json)).toList();

      //return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      //throw TradingHttpException(response.statusCode, response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<ReportStockHistData> report_stock_today(
    String? broker,
    String? account,
    String? user,
    String? stock,
    String? platform,
    String? version,
  ) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "user": "cakrahimawan",
    "acct": "C35",
    "platform": "desktop",
    "stock": "TAPG"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "user": user,
      "acct": account,
      "platform": platform,
      "version": version,
      "stock": stock,
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    String path = 'reportstocktoday';
    final response = await http.post(Uri.https(_tradingBaseUrl, path),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      DebugWriter.info('report_stock_today --> ' + response.body);

      //CashPosition cashPosition = CashPosition.fromJson(jsonDecode(response.body));
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      List<ReportStockHist> list = parsed
          .map<ReportStockHist>((json) => ReportStockHist.fromJson(json))
          .toList();
      ReportStockHistData result = ReportStockHistData();
      result.datas = list;
      return result;
      //return parsed.map<ReportStockHist>((json) => ReportStockHist.fromJson(json)).toList();

      //return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      //throw TradingHttpException(response.statusCode, response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<GroupedData> riwayatRDN(String? broker, String? account, String? user,
      String? platform, String? version) async {
    //https://dev.buanacapital.com:8888/reportrdn
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    {
      "broker": "RF",
      "user": "cakrahimawan",
      "acct": "E108",
      "platform": "desktop"
    }

    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "user": user,
      "acct": account,
      "platform": platform,
      "version": version,
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    String path = 'reportrdn';

    final response = await http.post(
        Uri.https(_tradingBaseUrl, path /*'orderstatus'*/),
        headers: headers,
        body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('riwayatRDN --> ' + response.body);

      GroupedData groupedData = GroupedData();

      //ResultMutasi result = ResultMutasi();
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      //result.datas = parsed.map<Mutasi>((json) => Mutasi.fromJson(json)).toList();

      List<Mutasi>? list =
          parsed.map<Mutasi>((json) => Mutasi.fromJson(json)).toList();
      int count = list != null ? list.length : 0;
      for (int i = 0; i < count; i++) {
        Mutasi? mutasi = list?.elementAt(i);
        if (mutasi != null) {
          groupedData.addData(mutasi.monthYear, mutasi);
        }
      }
      groupedData.constructAsList();
      return groupedData;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<RealizedStockData> realizedStock(String? broker, String? account,
      String? user, String? range, String? platform, String? version) async {
    //https://dev.buanacapital.com:8888/reportgainloss
    /*
    {
        "accountcode": "E108",
        "stockCode": "BUKA",
        "gl": 96750000,
        "date": "09-08-2021"
    },


    {
        "broker": "RF",
        "user": "cakrahimawan",
        "acct": "E108",
        "platform": "desktop"
    }

    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "user": user,
      "acct": account,
      "platform": platform,
      "version": version,
      "period": range,
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    String path = 'reportgainloss';

    final response = await http.post(
        Uri.https(_tradingBaseUrl, path /*'orderstatus'*/),
        headers: headers,
        body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('realizedStock --> ' + response.body);

      RealizedStockData result = RealizedStockData();
      final parsed = jsonDecode(response.body);
      if (parsed != null) {
        result.totalGL = Utils.safeDouble(parsed['totalGL']);
        var listRows = parsed['rows'] as List;
        DebugWriter.info(listRows.runtimeType); //returns List<dynamic>
        List<RealizedStock>? rowDatas =
            listRows.map((i) => RealizedStock.fromJson(i)).toList();
        result.datas = rowDatas;
      }
      //final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      //result.datas = parsed.map<RealizedStock>((json) => RealizedStock.fromJson(json)).toList();
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<PortfolioSummaryData> portfolioSummary(String? broker, String? account,
      String? user, String? platform, String? version) async {
    //https://dev.buanacapital.com:8888/reportsummary
    /*
    {
        "accountcode": "C35",
        "totalasset": 1602642788.47,
        "portfoliovalue": 1574121500,
        "cashvalue": 28521288.47,
        "modalsetor": 3456325280.94,
        "cashin": 6182747916.92,
        "cashout": 2726422635.98,
        "totalprofit": 414576661.18,
        "realizedprofit": 482680153.18,
        "unrealizedprofit": -68103492,
        "topgain1stock": "BOLA",
        "topgain1value": 523400000,
        "topgain2stock": "FREN",
        "topgain2value": 273000000,
        "topgain3stock": "BINA",
        "topgain3value": 81937000,
        "toploss1stock": "BRMS",
        "toploss1value": -230000000,
        "toploss2stock": "ANTM",
        "toploss2value": -128000000,
        "toploss3stock": "BBYB",
        "toploss3value": -121500000
    }


    {
        "broker": "RF",
        "user": "cakrahimawan",
        "acct": "C35",
        "platform": "desktop"
    }


    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "user": user,
      "acct": account,
      "platform": platform,
      "version": version,
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    String path = 'reportsummary';

    final response = await http.post(
        Uri.https(_tradingBaseUrl, path /*'orderstatus'*/),
        headers: headers,
        body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('portfolioSummary --> ' + response.body);

      final parsed = jsonDecode(response.body); //.cast<Map<String, dynamic>>();
      //print(parsed);
      PortfolioSummaryData result = PortfolioSummaryData.fromJson(parsed);
      //result.datas = parsed.map<RealizedStock>((json) => RealizedStock.fromJson(json)).toList();
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<List<OpenOrder>> openOrder(
      String? broker,
      String? account,
      String? user,
      String? stock,
      String? buySell,
      String? platform,
      String? version) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "stock": stock,
      "bs": buySell,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http.post(Uri.https(_tradingBaseUrl, 'openorder'),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      DebugWriter.info('open_order --> ' + response.body);
      //CashPosition cashPosition = CashPosition.fromJson(jsonDecode(response.body));
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      return parsed.map<OpenOrder>((json) => OpenOrder.fromJson(json)).toList();

      //return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  /* Trade Status
  period = sum
  {
    "tradePrice": 635,
    "matchQty": 100000,
    "idxTradeId": "000000300068, 000000300064, 000000300067, 000000300065, 000000300059, 000000300061, 000000300060, 000000300058, 000000300063, 000000300066, 000000300062"
  }
  {
    "parentOrderId": "3",
    "internalOrderId": "4",
    "idxOrderId": "830296",
    "sasOrderId": "252798/WBOL1/C35",
    "idxTradeId": "000000300068",
    "accountcode": "C35",
    "bs": "B",
    "boardCode": "RG",
    "stockCode": "BOLA",
    "tradePrice": 635,
    "matchQty": 16300,
    "tradeVal": 10350500,
    "tradeTime": "172155184",
    "executor": "",
    "executeDevice": ""
  },
  */
  Future<List<TradeStatusSummary>> tradeStatusSummary(
      String broker,
      String account,
      String? user,
      String orderid,
      String? platform,
      String? version) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "user": "emil",
    "platform": "desktop",
    "orderid": "3",
    "period": "sum"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "orderid": orderid,
      "period": "sum",
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http.post(Uri.https(_tradingBaseUrl, 'tradestatus'),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      DebugWriter.info('trade_status_summary --> ' + response.body);
      //CashPosition cashPosition = CashPosition.fromJson(jsonDecode(response.body));
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      return parsed
          .map<TradeStatusSummary>((json) => TradeStatusSummary.fromJson(json))
          .toList();

      //return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<List<TradeStatus>> tradeStatus(String broker, String account,
      String user, String platform, String version) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    Map data = {
      "broker": broker,
      "acct": account,
      "user": user,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http.post(Uri.https(_tradingBaseUrl, 'tradestatus'),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      DebugWriter.info('trade_status --> ' + response.body);
      //CashPosition cashPosition = CashPosition.fromJson(jsonDecode(response.body));
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      return parsed
          .map<TradeStatus>((json) => TradeStatus.fromJson(json))
          .toList();

      //return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }

  Future<List<AccountStockPosition>> accountStockPosition(
      String? broker,
      List<String>? listAccounts,
      String? user,
      String? platform,
      String? version) async {
    //192.168.110.213:8888/cashposition
    /*
    {
    "broker": "RF",
    "acct": "A76",
    "user": "user",
    "platform": "desktop",

    "orderid": "B9"
    }
    */
    String? auth = 'Bearer ' + token!.access_token!;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};

    String? accounts = listAccounts?.join('|');
    Map data = {
      "broker": broker,
      "acct": accounts,
      "user": user,
      "platform": platform,
      "version": version
    };
    //encode Map to JSON
    DebugWriter.info(headers);
    DebugWriter.info(data);
    var body = json.encode(data);
    DebugWriter.info(body);
    final response = await http
        .post(Uri.https(_tradingBaseUrl, 'stockpos'),
            headers: headers, body: body)
        .timeout(Duration(seconds: trading_timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      //print(response.body);
      DebugWriter.info('account_stock_position --> ' + response.body);
      //CashPosition cashPosition = CashPosition.fromJson(jsonDecode(response.body));

      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      return parsed
          .map<AccountStockPosition>(
              (json) => AccountStockPosition.fromJson(json))
          .toList();

      //return cashPosition;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw TradingHttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
  }
}

class HttpIII {
  bool isLoaded = false;
  ServerAddress serverAddress =
      ServerAddress('', null, null, '', '', 0, '', '', 0);
  HttpIII() {
    serverAddress.load().then((value) {
      this.isLoaded = true;
    });
  }
  // static final String baseUrlLocalhost = 'localhost';
  // static final String baseUrlLocalhost = '192.168.110.111';
  //static final String baseUrlLocalhost = '192.168.110.127';
  //static String baseUrlLocalhost = '36.89.110.91:80';
  //String _baseUrlLocalhost = 'no_domain:no_port';
  int timeout_in_seconds = 30;

  // void setUrlPort(String url, int port) {
  //   _baseUrlLocalhost = '$url:$port';
  // }

  String get baseUrlLocalhost => serverAddress.urlPortRequester();

  Future<ChartOhlcvData> fetchChartOhlcv(String? code, bool isIndex,
      {String from = '', String to = ''}) async {
    String type;

    bool isIntraday = StringUtils.isEmtpy(from) || StringUtils.isEmtpy(to);

    if (isIndex) {
      if (isIntraday) {
        type = 'intraday_indices';
      } else {
        type = 'historical_indices';
      }
    } else {
      if (isIntraday) {
        type = 'intraday_stock';
      } else {
        type = 'historical_stock';
      }
    }

    var parameters = {
      'code': code,
      'type': type,
      'start': from,
      'end': to,
      //'interval':'1',
    };

    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, 'm_chart_ohlcv.php', parameters));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('fetchChartOhlcv --> ' + response.body);

      ChartOhlcvData? data = ChartOhlcvData();
      data.setRequestType(code, from, to);
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        // String message = parsedJson['message'];
        List<dynamic>? datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            Ohlcv ohlcv = Ohlcv.fromJson(parsedJson);
            DebugWriter.info(ohlcv.toString());
            if (ohlcv.close! > 0) {
              data.addOhlcv(ohlcv);
            }
          });
        }
      }

      /*
      final document = XmlDocument.parse(response.body);
      data.setRequestType(code, from, to);
      List<Line> list = List<Line>.empty(growable: true);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          //list.add();
          Line line =  Line.fromXml(element);
          data.addOhlcv(line);
        });
      }
      */
      return data;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<ChartLineData> fetchChartLine(String? code, bool isIndex,
      {String from = '', String to = ''}) async {
    String type;

    bool isIntraday = StringUtils.isEmtpy(from) || StringUtils.isEmtpy(to);

    if (isIndex) {
      if (isIntraday) {
        type = 'intraday_indices';
      } else {
        type = 'historical_indices';
      }
    } else {
      if (isIntraday) {
        type = 'intraday_stock';
      } else {
        type = 'historical_stock';
      }
    }

    var parameters = {
      'code': code,
      'type': type,
      'start': from,
      'end': to,
      //'interval':'1',
    };

    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, 'm_chart_line.php', parameters));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('fetchChartLine --> ' + response.body);

      ChartLineData data = ChartLineData();
      data.setRequestType(code, from, to);
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String? message = parsedJson['message'];
        List<dynamic>? datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            Line line = Line.fromJson(parsedJson);
            DebugWriter.info(line.toString());
            if (line.close! > 0) {
              data.addOhlcv(line);
            }
          });
        }
      }

      /*
      final document = XmlDocument.parse(response.body);
      data.setRequestType(code, from, to);
      List<Line> list = List<Line>.empty(growable: true);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          //list.add();
          Line line =  Line.fromXml(element);
          data.addOhlcv(line);
        });
      }
      */
      return data;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<List<HomeWorldIndices>> fetchWorldIndices() async {
    final response = await http.get(Uri.http(
      baseUrlLocalhost,
      'm_world_indices.php',
    ));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchWorldIndices -> ' + response.body);
      List<HomeWorldIndices> list =
          List<HomeWorldIndices>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(HomeWorldIndices.fromJson(parsedJson));
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          list.add(HomeWorldIndices.fromXml(element));
        });
      }
      */
      return list;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<List<StockThemes>> fetchThemes() async {
    final response = await http.get(Uri.http(
      baseUrlLocalhost, // nanti ganti ke baseUrl
      'm_themes.php',
    ));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchThemes -> ' + response.body);

      List<StockThemes> list = List<StockThemes>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(StockThemes.fromJson(parsedJson));
          });
        }
      }

      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          list.add(StockThemes.fromXml(element));
        });
      }
      */
      return list;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<HomeData> fetchHomeData() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_home_data.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchHomeData -> ' + response.body);

      HomeData homeData = HomeData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            String? group = StringUtils.noNullString(parsedJson['group']);
            String? code = StringUtils.noNullString(parsedJson['code']);
            double price = Utils.safeDouble(parsedJson['price']);
            double change = Utils.safeDouble(parsedJson['change']);
            double percentChange =
                Utils.safeDouble(parsedJson['percentChange']);
            if (StringUtils.equalsIgnoreCase(group, 'currencies')) {
              HomeCurrencies currencies =
                  HomeCurrencies(code, price, percentChange);
              homeData.addCurrencies(currencies);
            } else if (StringUtils.equalsIgnoreCase(group, 'commodities')) {
              HomeCommodities commodities =
                  HomeCommodities(code, price, percentChange);
              homeData.addCommodities(commodities);
            } else if (StringUtils.equalsIgnoreCase(group, 'indices')) {
              HomeWorldIndices indices =
                  HomeWorldIndices(code, code, price, change, percentChange);
              homeData.addIndices(indices);
            } else if (StringUtils.equalsIgnoreCase(group, 'crypto')) {
              HomeCrypto crypto = HomeCrypto(code, price, percentChange);
              homeData.addCrypto(crypto);
            }
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          //<a start="1" end="15" group="currencies" code="USD" price="14364.50" change="22.00" percentChange="0.15" updated_at="2021-08-06 11:55:20"/>
          //<a start="4" end="15" group="commodities" code="Oil WTI Crude" price="69.22" change="0.13" percentChange="0.18" updated_at="2021-08-06 11:55:22"/>
          //<a start="12" end="15" group="indices" code="DJI" price="35064.25" change="271.58" percentChange="0.78" updated_at="2021-08-06 11:55:21"/>
          String group          = StringUtils.noNullString(element.getAttribute('group'));
          String code           = StringUtils.noNullString(element.getAttribute('code'));
          double price          = Utils.safeDouble(element.getAttribute('price'));
          double change         = Utils.safeDouble(element.getAttribute('change'));
          double percentChange  = Utils.safeDouble(element.getAttribute('percentChange'));
          if(StringUtils.equalsIgnoreCase(group, 'currencies')){
            HomeCurrencies currencies = HomeCurrencies(code, price, percentChange);
            homeData.addCurrencies(currencies);
          }else if(StringUtils.equalsIgnoreCase(group, 'commodities')){
            HomeCommodities commodities = HomeCommodities(code, price, percentChange);
            homeData.addCommodities(commodities);
          }else if(StringUtils.equalsIgnoreCase(group, 'indices')){
            HomeWorldIndices indices = HomeWorldIndices(code, code, price, change, percentChange);
            homeData.addIndices(indices);
          }else if(StringUtils.equalsIgnoreCase(group, 'crypto')){
            HomeCrypto crypto = HomeCrypto(code, price, percentChange);
            homeData.addCrypto(crypto);
          }
        });
      }
      */
      return homeData;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<GroupedData> fetchGlobal() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_global.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchGlobal -> ' + response.body);

      GroupedData groupedData = GroupedData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            String? group = StringUtils.noNullString(parsedJson['group']);
            String? code = StringUtils.noNullString(parsedJson['code']);
            String? name = StringUtils.noNullString(parsedJson['name']);
            double open = Utils.safeDouble(parsedJson['open']);
            double hi = Utils.safeDouble(parsedJson['hi']);
            double low = Utils.safeDouble(parsedJson['low']);
            double price = Utils.safeDouble(parsedJson['price']);
            double change = Utils.safeDouble(parsedJson['change']);
            double percentChange =
                Utils.safeDouble(parsedJson['percentChange']);
            String? date = StringUtils.noNullString(parsedJson['date']);
            String? time = StringUtils.noNullString(parsedJson['time']);
            String? timezone = StringUtils.noNullString(parsedJson['timezone']);
            String? updatedAt =
                StringUtils.noNullString(parsedJson['updated_at']);

            GeneralDetailPrice global = GeneralDetailPrice(
                group,
                code,
                name,
                open,
                hi,
                low,
                price,
                change,
                percentChange,
                date,
                time,
                timezone,
                updatedAt);
            DebugWriter.info(global.toString());
            groupedData.addData(group, global);
          });
        }
      }
      groupedData.constructAsList();

      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          //<a start="1" end="17" group="INDEX FUTURE" code="DOW FUT" name="Dow Jones Indeks Future (New york)" open="34922.00" hi="34930.00" low="34883.00" price="34912.00" change="-31.00" percentChange="-0.08" date="8/6/2021" time="12:44 AM" timezone="EDT" updated_at="2021-08-06 11:55:20"/>
          //<a start="3" end="17" group="ASIA" code="N225" name="Nikkei 225 Indeks (Tokyo)" open="27709.22" hi="27888.87" low="27709.22" price="27821.79" change="93.67" percentChange="0.33" date="8/6/2021" time="12:34 AM" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          //<a start="11" end="17" group="EUROPE" code="FTSE" name="FTSE 100 Indeks (London)" open="7123.86" hi="7130.35" low="7099.03" price="7120.43" change="-3.43" percentChange="-0.04" date="8/5/2021" time="11:35 AM" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          //<a start="15" end="17" group="AMERICA" code="DJI" name="Dow Jones Indeks (New York)"
          // open="34815.61" hi="35067.54" low="34815.61" price="35064.25"
          // change="271.58" percentChange="0.78" date="8/5/2021" time="" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          String group          = StringUtils.noNullString(element.getAttribute('group'));
          String code           = StringUtils.noNullString(element.getAttribute('code'));
          String name           = StringUtils.noNullString(element.getAttribute('name'));
          double open           = Utils.safeDouble(element.getAttribute('open'));
          double hi             = Utils.safeDouble(element.getAttribute('hi'));
          double low            = Utils.safeDouble(element.getAttribute('low'));
          double price          = Utils.safeDouble(element.getAttribute('price'));
          double change         = Utils.safeDouble(element.getAttribute('change'));
          double percentChange  = Utils.safeDouble(element.getAttribute('percentChange'));
          String date           = StringUtils.noNullString(element.getAttribute('date'));
          String time           = StringUtils.noNullString(element.getAttribute('time'));
          String timezone       = StringUtils.noNullString(element.getAttribute('timezone'));
          String updated_at     = StringUtils.noNullString(element.getAttribute('updated_at'));

          GeneralDetailPrice global = GeneralDetailPrice(group, code, name, open, hi, low, price, change, percentChange, date, time, timezone, updated_at);
          DebugWriter.info(global.toString());
          groupedData.addData(group, global);

        });
      }
      groupedData.constructAsList();
      */

      return groupedData;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<GroupedData> fetchCommodities() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_commodities.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('fetchCommodities -> ' + response.body);

      GroupedData groupedData = GroupedData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            String? group = StringUtils.noNullString(parsedJson['group']);
            String? code = StringUtils.noNullString(parsedJson['code']);
            String? name = StringUtils.noNullString(parsedJson['name']);
            double open = Utils.safeDouble(parsedJson['open']);
            double hi = Utils.safeDouble(parsedJson['hi']);
            double low = Utils.safeDouble(parsedJson['low']);
            double price = Utils.safeDouble(parsedJson['price']);
            double change = Utils.safeDouble(parsedJson['change']);
            double percentChange =
                Utils.safeDouble(parsedJson['percentChange']);
            String? date = StringUtils.noNullString(parsedJson['date']);
            String? time = StringUtils.noNullString(parsedJson['time']);
            String? timezone = StringUtils.noNullString(parsedJson['timezone']);
            String? updatedAt =
                StringUtils.noNullString(parsedJson['updated_at']);

            GeneralDetailPrice global = GeneralDetailPrice(
                group,
                code,
                name,
                open,
                hi,
                low,
                price,
                change,
                percentChange,
                date,
                time,
                timezone,
                updatedAt);
            DebugWriter.info(global.toString());
            groupedData.addData(group, global);
          });
        }
      }
      groupedData.constructAsList();

      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          //<a start="1" end="17" group="INDEX FUTURE" code="DOW FUT" name="Dow Jones Indeks Future (New york)" open="34922.00" hi="34930.00" low="34883.00" price="34912.00" change="-31.00" percentChange="-0.08" date="8/6/2021" time="12:44 AM" timezone="EDT" updated_at="2021-08-06 11:55:20"/>
          //<a start="3" end="17" group="ASIA" code="N225" name="Nikkei 225 Indeks (Tokyo)" open="27709.22" hi="27888.87" low="27709.22" price="27821.79" change="93.67" percentChange="0.33" date="8/6/2021" time="12:34 AM" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          //<a start="11" end="17" group="EUROPE" code="FTSE" name="FTSE 100 Indeks (London)" open="7123.86" hi="7130.35" low="7099.03" price="7120.43" change="-3.43" percentChange="-0.04" date="8/5/2021" time="11:35 AM" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          //<a start="15" end="17" group="AMERICA" code="DJI" name="Dow Jones Indeks (New York)"
          // open="34815.61" hi="35067.54" low="34815.61" price="35064.25"
          // change="271.58" percentChange="0.78" date="8/5/2021" time="" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          String group          = StringUtils.noNullString(element.getAttribute('group'));
          String code           = StringUtils.noNullString(element.getAttribute('code'));
          String name           = StringUtils.noNullString(element.getAttribute('name'));
          double open           = Utils.safeDouble(element.getAttribute('open'));
          double hi             = Utils.safeDouble(element.getAttribute('hi'));
          double low            = Utils.safeDouble(element.getAttribute('low'));
          double price          = Utils.safeDouble(element.getAttribute('price'));
          double change         = Utils.safeDouble(element.getAttribute('change'));
          double percentChange  = Utils.safeDouble(element.getAttribute('percentChange'));
          String date           = StringUtils.noNullString(element.getAttribute('date'));
          String time           = StringUtils.noNullString(element.getAttribute('time'));
          String timezone       = StringUtils.noNullString(element.getAttribute('timezone'));
          String updated_at     = StringUtils.noNullString(element.getAttribute('updated_at'));

          GeneralDetailPrice global = GeneralDetailPrice(group, code, name, open, hi, low, price, change, percentChange, date, time, timezone, updated_at);
          DebugWriter.info(global.toString());
          groupedData.addData(group, global);

        });
      }
      groupedData.constructAsList();
      */
      return groupedData;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Errorw  : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<Version> checkVersion(String platform) async {
    String path = 'mobile_' + platform.toLowerCase() + '.txt';

    // String path = 'mobile_test.txt';

    //print(path);
    var parameters = {
      'nocache': DateTime.now().toString(),
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(
            baseUrlLocalhost, // nanti ganti ke baseUrl
            path,
            parameters))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      DebugWriter.info('checkVersion -> ' + response.body);

      Version? version;
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        version = Version.fromJson(parsedJson);
      }

      return version!;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<Map<String, FundamentalCache>> fetchFundamentalCache() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_fund_cache.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      DebugWriter.info('fetchFundamentalCache -> ' + response.body);

      Map<String, FundamentalCache> maps = Map();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            FundamentalCache? cache = FundamentalCache.fromJson(parsedJson);

            DebugWriter.info(cache.toString());
            if (cache != null) {
              //list.add(cache);
              maps.update(
                cache.code!,
                (existingValue) => cache,
                ifAbsent: () => cache,
              );
            }
          });
        }
      }
      return maps;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<List<CorporateActionEvent>> fetchCorporateActionEvent() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_corporate_action_event.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      DebugWriter.info('fetchCorporateActionEvent -> ' + response.body);

      List<CorporateActionEvent> list = List.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            CorporateActionEvent? cache =
                CorporateActionEvent.fromJson(parsedJson);

            DebugWriter.info(cache.toString());
            if (cache != null) {
              list.add(cache);
              // maps.update(
              //   cache.code,
              //       (existingValue) => cache,
              //   ifAbsent: () => cache,
              // );
            }
          });
        }
      }
      return list;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<GroupedData> fetchCrypto() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_crypto_currencies.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info('fetchCrypto -> ' + response.body);

      GroupedData groupedData = GroupedData();
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            String? group = StringUtils.noNullString(parsedJson['group']);
            String? code = StringUtils.noNullString(parsedJson['code']);
            String? name = StringUtils.noNullString(parsedJson['name']);
            double price = Utils.safeDouble(parsedJson['price']);
            double percentChange1h =
                Utils.safeDouble(parsedJson['percent_change_1h']);
            double percentChange24h =
                Utils.safeDouble(parsedJson['percent_change_24h']);
            double percentChange7d =
                Utils.safeDouble(parsedJson['percent_change_7d']);
            double percentChange30d =
                Utils.safeDouble(parsedJson['percent_change_30d']);
            double percentChange60d =
                Utils.safeDouble(parsedJson['percent_change_60d']);
            double percentChange90d =
                Utils.safeDouble(parsedJson['percent_change_90d']);
            double volume_24h = Utils.safeDouble(parsedJson['volume_24h']);
            double marketCap = Utils.safeDouble(parsedJson['market_cap']);
            String? iconUrl = StringUtils.noNullString(parsedJson['icon_url']);
            String? lastUpdated =
                StringUtils.noNullString(parsedJson['last_updated']);
            String? updatedAt =
                StringUtils.noNullString(parsedJson['updated_at']);

            CryptoPrice cp = CryptoPrice(
                group,
                code,
                name,
                price,
                percentChange1h,
                percentChange24h,
                percentChange7d,
                percentChange30d,
                percentChange60d,
                percentChange90d,
                volume_24h,
                marketCap,
                iconUrl,
                lastUpdated,
                updatedAt);
            DebugWriter.info(cp.toString());
            groupedData.addData(group, cp);
          });
        }
      }
      groupedData.constructAsList();

      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {

          // <a start="1" end="11"
          //   group="CRYPTO" code="BTC" name="Bitcoin" price="631804979.17"
          //   percent_change_1h="-0.18" percent_change_24h="-0.04" percent_change_7d="5.20" percent_change_30d="30.64"
          //   percent_change_60d="19.77" percent_change_90d="-23.20" volume_24h="511511475135536.56"
          //   market_cap="11865364480157380.00" icon_url="https://s2.coinmarketcap.com/static/img/coins/64x64/1.png"
          //   last_updated="2021-08-08T17:57:15.000Z" updated_at="2021-08-09 00:57:50"/>

          String group          = StringUtils.noNullString(element.getAttribute('group'));
          String code           = StringUtils.noNullString(element.getAttribute('code'));
          String name           = StringUtils.noNullString(element.getAttribute('name'));
          double price          = Utils.safeDouble(element.getAttribute('price'));

          double percent_change_1h    = Utils.safeDouble(element.getAttribute('percent_change_1h'));
          double percent_change_24h   = Utils.safeDouble(element.getAttribute('percent_change_24h'));
          double percent_change_7d    = Utils.safeDouble(element.getAttribute('percent_change_7d'));
          double percent_change_30d   = Utils.safeDouble(element.getAttribute('percent_change_30d'));
          double percent_change_60d   = Utils.safeDouble(element.getAttribute('percent_change_60d'));
          double percent_change_90d   = Utils.safeDouble(element.getAttribute('percent_change_90d'));
          double volume_24h           = Utils.safeDouble(element.getAttribute('volume_24h'));
          double market_cap           = Utils.safeDouble(element.getAttribute('market_cap'));



          String icon_url             = StringUtils.noNullString(element.getAttribute('icon_url'));
          String last_updated         = StringUtils.noNullString(element.getAttribute('last_updated'));
          String updated_at       = StringUtils.noNullString(element.getAttribute('updated_at'));

          CryptoPrice cp = CryptoPrice(group, code, name, price, percent_change_1h, percent_change_24h, percent_change_7d, percent_change_30d, percent_change_60d, percent_change_90d, volume_24h, market_cap, icon_url, last_updated, updated_at);
          DebugWriter.info(cp.toString());
          groupedData.addData(group, cp);

        });
      }
      groupedData.constructAsList();
      */
      return groupedData;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<List> fetchOfferingEIPO(
      {String type = 'LIST', String code = ''}) async {
    var parameters = {
      'type': type,
      'code': code,
    };
    DebugWriter.info(parameters);

    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_eipo.php',
          //'m_eipo_offering.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchOfferingEIPO -> ' + response.body);

      //List<ContentEIPO> result = List.empty(growable: true);
      List result = List.empty(growable: true);
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        String type = parsedJson['type'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            if (StringUtils.equalsIgnoreCase(type, "LIST")) {
              ListEIPO eipo = ListEIPO.fromJson(parsedJson);
              DebugWriter.info(eipo.toString());
              result.add(eipo);
            } else if (StringUtils.equalsIgnoreCase(type, "CONTENT")) {
              ContentEIPO eipo = ContentEIPO.fromJson(parsedJson);
              DebugWriter.info(eipo.toString());
              result.add(eipo);
            }
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<List<ListEIPO>> fetchEIPOList() async {
    var parameters = {
      'type': 'LIST',
    };
    DebugWriter.info(parameters);

    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_eipo.php',
          parameters,
          //'m_eipo_offering.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchEIPOList -> ' + response.body);

      //List<ContentEIPO> result = List.empty(growable: true);
      List<ListEIPO> result = List.empty(growable: true);
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        String type = parsedJson['type'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            if (StringUtils.equalsIgnoreCase(type, "LIST")) {
              ListEIPO eipo = ListEIPO.fromJson(parsedJson);
              DebugWriter.info(eipo.toString());
              result.add(eipo);
            }
            /*else if(StringUtils.equalsIgnoreCase(type, "CONTENT")){
              ContentEIPO eipo = ContentEIPO.fromJson(parsedJson);
              DebugWriter.info(eipo?.toString());
              result.add(eipo);
            }
             */
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<ContentEIPO> fetchEIPOContent(String code) async {
    var parameters = {
      'type': 'CONTENT',
      'code': code,
    };
    DebugWriter.info(parameters);

    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_eipo.php',
          parameters,
          //'m_eipo_offering.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchEIPOContent -> ' + response.body);

      //List<ContentEIPO> result = List.empty(growable: true);
      List result = List.empty(growable: true);
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        String type = parsedJson['type'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            if (StringUtils.equalsIgnoreCase(type, "CONTENT")) {
              ContentEIPO eipo = ContentEIPO.fromJson(parsedJson);
              DebugWriter.info(eipo.toString());
              result.add(eipo);
            }
          });
        }
      }
      return result.isNotEmpty ? result.first : null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<GroupedData> fetchBonds() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_bonds.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchCommodities -> ' + response.body);

      GroupedData groupedData = GroupedData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            String? group = StringUtils.noNullString(parsedJson['group']);
            String? code = StringUtils.noNullString(parsedJson['code']);
            String? name = StringUtils.noNullString(parsedJson['name']);
            double open = Utils.safeDouble(parsedJson['open']);
            double hi = Utils.safeDouble(parsedJson['hi']);
            double low = Utils.safeDouble(parsedJson['low']);
            double price = Utils.safeDouble(parsedJson['price']);
            double change = Utils.safeDouble(parsedJson['change']);
            double percentChange =
                Utils.safeDouble(parsedJson['percentChange']);
            String? date = StringUtils.noNullString(parsedJson['date']);
            String? time = StringUtils.noNullString(parsedJson['time']);
            String? timezone = StringUtils.noNullString(parsedJson['timezone']);
            String? updatedAt =
                StringUtils.noNullString(parsedJson['updated_at']);

            GeneralDetailPrice global = GeneralDetailPrice(
                group,
                code,
                name,
                open,
                hi,
                low,
                price,
                change,
                percentChange,
                date,
                time,
                timezone,
                updatedAt);
            DebugWriter.info(global.toString());
            groupedData.addData(group, global);
          });
        }
      }
      groupedData.constructAsList();

      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          //<a start="1" end="17" group="INDEX FUTURE" code="DOW FUT" name="Dow Jones Indeks Future (New york)" open="34922.00" hi="34930.00" low="34883.00" price="34912.00" change="-31.00" percentChange="-0.08" date="8/6/2021" time="12:44 AM" timezone="EDT" updated_at="2021-08-06 11:55:20"/>
          //<a start="3" end="17" group="ASIA" code="N225" name="Nikkei 225 Indeks (Tokyo)" open="27709.22" hi="27888.87" low="27709.22" price="27821.79" change="93.67" percentChange="0.33" date="8/6/2021" time="12:34 AM" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          //<a start="11" end="17" group="EUROPE" code="FTSE" name="FTSE 100 Indeks (London)" open="7123.86" hi="7130.35" low="7099.03" price="7120.43" change="-3.43" percentChange="-0.04" date="8/5/2021" time="11:35 AM" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          //<a start="15" end="17" group="AMERICA" code="DJI" name="Dow Jones Indeks (New York)"
          // open="34815.61" hi="35067.54" low="34815.61" price="35064.25"
          // change="271.58" percentChange="0.78" date="8/5/2021" time="" timezone="EDT" updated_at="2021-08-06 11:55:21"/>
          String group          = StringUtils.noNullString(element.getAttribute('group'));
          String code           = StringUtils.noNullString(element.getAttribute('code'));
          String name           = StringUtils.noNullString(element.getAttribute('name'));
          double open           = Utils.safeDouble(element.getAttribute('open'));
          double hi             = Utils.safeDouble(element.getAttribute('hi'));
          double low            = Utils.safeDouble(element.getAttribute('low'));
          double price          = Utils.safeDouble(element.getAttribute('price'));
          double change         = Utils.safeDouble(element.getAttribute('change'));
          double percentChange  = Utils.safeDouble(element.getAttribute('percentChange'));
          String date           = StringUtils.noNullString(element.getAttribute('date'));
          String time           = StringUtils.noNullString(element.getAttribute('time'));
          String timezone       = StringUtils.noNullString(element.getAttribute('timezone'));
          String updated_at     = StringUtils.noNullString(element.getAttribute('updated_at'));

          GeneralDetailPrice global = GeneralDetailPrice(group, code, name, open, hi, low, price, change, percentChange, date, time, timezone, updated_at);
          DebugWriter.info(global.toString());
          groupedData.addData(group, global);

        });
      }
      groupedData.constructAsList();
      */

      return groupedData;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<ResultTopUpBank> fetchTopUpBanks() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_top_up_banks.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchTopUpBanks -> ' + response.body);

      ResultTopUpBank result = ResultTopUpBank();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.top_up_term_en =
            StringUtils.noNullString(parsedJson['top_up_term_en']);
        result.top_up_term_id =
            StringUtils.noNullString(parsedJson['top_up_term_id']);
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            TopUpBank? bank = TopUpBank.fromJson(parsedJson);
            if (bank != null) {
              DebugWriter.info(bank.toString());
              result.datas?.add(bank);
            }
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<ResultFundOutTerm> fetchFundOutTerm() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_fund_out_term.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchFundOutTerm -> ' + response.body);

      ResultFundOutTerm result = ResultFundOutTerm('', '');

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.fund_out_term_en =
            StringUtils.noNullString(parsedJson['fund_out_term_en']);
        result.fund_out_term_id =
            StringUtils.noNullString(parsedJson['fund_out_term_id']);
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase! */);
    }
  }

  Future<GroupedData> fetchCurrencies() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_currencies.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchCurrencies -> ' + response.body);

      GroupedData groupedData = GroupedData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            String? group = StringUtils.noNullString(parsedJson['group']);
            String? code = StringUtils.noNullString(parsedJson['code']);
            String? name = StringUtils.noNullString(parsedJson['name']);
            // double open           = Utils.safeDouble(parsedJson['open']);
            // double hi             = Utils.safeDouble(parsedJson['hi']);
            // double low            = Utils.safeDouble(parsedJson['low']);
            double price = Utils.safeDouble(parsedJson['price']);
            double change = Utils.safeDouble(parsedJson['change']);
            double percentChange =
                Utils.safeDouble(parsedJson['percentChange']);
            String? date = StringUtils.noNullString(parsedJson['date']);
            String? time = StringUtils.noNullString(parsedJson['time']);
            String? timezone = StringUtils.noNullString(parsedJson['timezone']);
            String? updatedAt =
                StringUtils.noNullString(parsedJson['updated_at']);

            GeneralPrice global =
                GeneralPrice(code, price, change, percentChange, name: name);
            DebugWriter.info(global.toString());
            groupedData.addData(group, global);
          });
        }
      }
      groupedData.constructAsList();

      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          //<a start="1" end="12" group="IDR RATE" code="USD" name="United States Dollar" price="14364.50" change="22.00" percentChange="0.15" date="8/6/2021" time="12:21 AM" timezone="EDT" updated_at="2021-08-06 11:55:20"/>
          //<a start="10" end="12" group="CROSS RATE" code="EURCHF" name="Euro - Swiss Franc" price="1.07" change="0.00" percentChange="0.05" date="8/6/2021" time="12:55 AM" timezone="EDT" updated_at="2021-08-06 11:55:20"/>
          String group          = StringUtils.noNullString(element.getAttribute('group'));
          String code           = StringUtils.noNullString(element.getAttribute('code'));
          String name           = StringUtils.noNullString(element.getAttribute('name'));
          // double open           = Utils.safeDouble(element.getAttribute('open'));
          // double hi             = Utils.safeDouble(element.getAttribute('hi'));
          // double low            = Utils.safeDouble(element.getAttribute('low'));
          double price          = Utils.safeDouble(element.getAttribute('price'));
          double change         = Utils.safeDouble(element.getAttribute('change'));
          double percentChange  = Utils.safeDouble(element.getAttribute('percentChange'));
          String date           = StringUtils.noNullString(element.getAttribute('date'));
          String time           = StringUtils.noNullString(element.getAttribute('time'));
          String timezone       = StringUtils.noNullString(element.getAttribute('timezone'));
          String updated_at     = StringUtils.noNullString(element.getAttribute('updated_at'));

          GeneralPrice global = GeneralPrice(code, price, change, percentChange,name: name);
          DebugWriter.info(global.toString());
          groupedData.addData(group, global);

        });
      }
      groupedData.constructAsList();
      */

      return groupedData;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<Remark2Data> fetchRemark2() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_remark_2_mapping.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchRemark2 -> ' + response.body);

      Remark2Data result = Remark2Data();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.date = StringUtils.noNullString(parsedJson['date']);
        result.time = StringUtils.noNullString(parsedJson['time']);
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            Remark2Stock stockAffected = Remark2Stock.fromJson(parsedJson);
            result.putStockAffected(stockAffected);
          });
        }

        var mapping = parsedJson['mapping'] as List?;
        if (mapping != null) {
          mapping.forEach((parsedJson) {
            Remark2Mapping map = Remark2Mapping.fromJson(parsedJson);
            result.putMapping(map);
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<SuspendedStockData> fetchStockSuspend() async {
    final response = await http
        .get(Uri.http(
          baseUrlLocalhost, // nanti ganti ke baseUrl
          'm_stock_suspend.php',
        ))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchStockSuspend -> ' + response.body);

      SuspendedStockData result = SuspendedStockData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.date = StringUtils.noNullString(parsedJson['date']);
        result.time = StringUtils.noNullString(parsedJson['time']);
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            SuspendStock stockAffected = SuspendStock.fromJson(parsedJson);
            result.putStockAffected(stockAffected);
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<HelpData> fetchHelp(
      {String? md5_help_menus = '0', String? md5_help_contents = '0'}) async {
    var parameters = {
      'md5_help_menus': md5_help_menus,
      'md5_help_contents': md5_help_contents
    };

    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(
            baseUrlLocalhost, // nanti ganti ke baseUrl
            'm_help.php',
            parameters))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchHelp -> ' + response.body);

      HelpData result = HelpData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.time = StringUtils.noNullString(parsedJson['time']);
        result.date = StringUtils.noNullString(parsedJson['date']);
        result.md5_help_menus =
            StringUtils.noNullString(parsedJson['md5_help_menus']);
        result.md5_help_contents =
            StringUtils.noNullString(parsedJson['md5_help_contents']);
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            HelpContent content = HelpContent.fromJson(parsedJson);
            result.putContent(content);
          });
        }

        var mapping = parsedJson['menus'] as List?;
        if (mapping != null) {
          mapping.forEach((parsedJson) {
            HelpMenu menu = HelpMenu.fromJson(parsedJson);
            result.putMenu(menu);
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<Briefing?> fetchBriefing() async {
    final response = await http
        .get(Uri.http(
            baseUrlLocalhost //baseUrl
            ,
            'm_home_briefing.php'))
        .timeout(Duration(seconds: timeout_in_seconds));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      DebugWriter.info('fetchBriefing : ' + response.body);
      List<Briefing>? list = List<Briefing>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(Briefing.fromJson(parsedJson));
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          list.add(Briefing.fromXml(element));
        });
      }
      */
      if (list != null && list.isNotEmpty) {
        return list.first;
      }

      return null;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ResearchRank?> fetchResearchRank(String? code) async {
    String path = 'm_research_rank.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchResearchRank : ' + response.body);

      List<ResearchRank> list = List<ResearchRank>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(ResearchRank.fromJson(parsedJson));
          });
        }
      }

      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          list.add(ResearchRank.fromXml(element));
        });
      }
      */

      if (list != null && list.isNotEmpty) {
        return list.first;
      }

      return null;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<DataCompanyProfile> fetchCompanyProfile(String? code) async {
    String path = 'm_company_profile.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchCompanyProfile : ' + response.body);

      DataCompanyProfile result = DataCompanyProfile.createBasic();
      //List<ResearchRank> list = List<ResearchRank>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.code = parsedJson['code'];
        var datas = parsedJson['datas'];
        if (datas != null) {
          var dataHistory = datas['dataHistory'];
          result.listing_date = dataHistory['listing_date'];
          result.effective_date = dataHistory['effective_date'];
          result.nominal = dataHistory['nominal'];
          result.ipo_price = dataHistory['ipo_price'];
          result.ipo_shares = dataHistory['ipo_shares'];
          result.ipo_amount = dataHistory['ipo_amount'];
          String underwriter = dataHistory['underwriter'];
          result.underwriter_list = underwriter.split('|');
          String shareRegistrar = dataHistory['share_registrar'];
          result.share_registrar_list = shareRegistrar.split('|');
          DebugWriter.info('dataHistory ok');

          var dataShareholders = datas['dataShareholders'];
          result.additionalInfo = dataShareholders['additionalInfo'];
          var contents = dataShareholders['contents'] as List;
          DebugWriter.info('dataShareholders contents');
          contents.forEach((content) {
            DebugWriter.info('dataShareholders contents A');
            DynamicContent? dc = DynamicContent.fromJson(content);
            if (dc != null) {
              result.contentList?.add(dc);
            }
            DebugWriter.info('dataShareholders contents B');
          });
          DebugWriter.info('dataShareholders ok');

          var dataCommisioners = datas['dataCommisioners'];
          String presidentCommissioner =
              dataCommisioners['president_commissioner'];
          String vicePresidentCommissioner =
              dataCommisioners['vice_president_commissioner'];
          String commissioner = dataCommisioners['commissioner'];
          String presidentDirector = dataCommisioners['president_director'];
          String vicePresidentDirector =
              dataCommisioners['vice_president_director'];
          String director = dataCommisioners['director'];

          result.president_commissioner_list = presidentCommissioner.split('|');
          result.vice_president_commissioner_list =
              vicePresidentCommissioner.split('|');
          result.commissioner_list = commissioner.split('|');
          result.president_director_list = presidentDirector.split('|');
          result.vice_president_director_list =
              vicePresidentDirector.split('|');
          result.director_list = director.split('|');
          DebugWriter.info('dataCommisioners ok');
        }
      }

      return result;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future fetchFinancialChart(String? code, String type, String showAs) async {
    String path = 'm_financial_chart.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'type':
          type, // INCOME_STATEMENT or  BALANCE_SHEET or CASH_FLOW or EARNING_PER_SHARE
      'show_as': showAs,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchFinancialChart : ' + response.body);

      //List<ResearchRank> list = List<ResearchRank>.empty(growable: true);
      var result;
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        String? code = StringUtils.noNullString(parsedJson['code']);
        String? type = StringUtils.noNullString(parsedJson['type']);
        String? showAs = StringUtils.noNullString(parsedJson['show_as']);
        //var datas = parsedJson['datas'] as List?;
        var datas = parsedJson['datas'];
        if (datas != null) {
          if (StringUtils.equalsIgnoreCase(type, 'INCOME_STATEMENT')) {
            result =
                DataChartIncomeStatement.fromJson(datas, code, type, showAs);
          } else if (StringUtils.equalsIgnoreCase(type, 'BALANCE_SHEET')) {
            result = DataChartBalanceSheet.fromJson(datas, code, type, showAs);
          } else if (StringUtils.equalsIgnoreCase(type, 'CASH_FLOW')) {
            result = DataChartCashFlow.fromJson(datas, code, type, showAs);
          } else if (StringUtils.equalsIgnoreCase(type, 'EARNING_PER_SHARE')) {
            result =
                DataChartEarningPerShare.fromJson(datas, code, type, showAs);
          }
        }
      }

      return result;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<CorporateActionData> fetchCorporateAction(
      String? code, String type) async {
    String path = 'm_corporate_action.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'type': type, // DIVIDEND or  RIGHT_ISSUE  or  RUPS  or  STOCK_SPLIT
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchCorporateAction : ' + response.body);

      CorporateActionData result = CorporateActionData();
      //List list = List<ResearchRank>.empty(growable: true);
      //var result;
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.code = StringUtils.noNullString(parsedJson['code']);
        result.type = StringUtils.noNullString(parsedJson['type']);

        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((element) {
            if (StringUtils.equalsIgnoreCase(type, 'DIVIDEND')) {
              Dividend? dividend = Dividend.fromJson(element);
              if (dividend != null) {
                result.addData(dividend);
                DebugWriter.info('added ' + dividend.toString());
              }
            } else if (StringUtils.equalsIgnoreCase(type, 'RIGHT_ISSUE')) {
              RightIssue? rightIssue = RightIssue.fromJson(element);
              if (rightIssue != null) {
                result.addData(rightIssue);
                DebugWriter.info('added ' + rightIssue.toString());
              }
            } else if (StringUtils.equalsIgnoreCase(type, 'RUPS')) {
              RUPS? rups = RUPS.fromJson(element);
              if (rups != null) {
                result.addData(rups);
                DebugWriter.info('added ' + rups.toString());
              }
            } else if (StringUtils.equalsIgnoreCase(type, 'STOCK_SPLIT')) {
              StockSplit? stockSplit = StockSplit.fromJson(element);
              if (stockSplit != null) {
                result.addData(stockSplit);
                DebugWriter.info('added ' + stockSplit.toString());
              }
            } else if (StringUtils.equalsIgnoreCase(type, 'WARRANT')) {
              Warrant? warrant = Warrant.fromJson(element);
              if (warrant != null) {
                result.addData(warrant);
                DebugWriter.info('added ' + warrant.toString());
              }
            }
          });
        }
      }

      return result;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ResultKeyStatistic> fetchKeyStatistic(
      String? code, String lastprice) async {
    String path = 'm_key_statistic.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'lastprice': lastprice,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchKeyStatistic : ' + response.body);

      //List<ResearchRank> list = List<ResearchRank>.empty(growable: true);
      ResultKeyStatistic result = ResultKeyStatistic();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.code = parsedJson['code'];
        var datas = parsedJson['datas'];
        if (datas != null) {
          var earningPerShareData = datas['earningPerShareData'];
          var dataPerformanceYTD = datas['dataPerformanceYTD'];
          var dataBalanceSheet = datas['dataBalanceSheet'];
          var dataValuation = datas['dataValuation'];
          var dataPerShare = datas['dataPerShare'];
          var dataProfitability = datas['dataProfitability'];
          var dataLiquidity = datas['dataLiquidity'];

          EarningPerShareData? earningPerShare =
              EarningPerShareData.fromJson(earningPerShareData);
          if (earningPerShare != null) {
            result.earningPerShare = earningPerShare;
            result.show_earningPerShare = true;
          }
          if (dataPerformanceYTD != null) {
            result.sales = Utils.safeInt(dataPerformanceYTD['sales']);
            result.operating_profit =
                Utils.safeInt(dataPerformanceYTD['operating_profit']);
            result.net_profit = Utils.safeInt(dataPerformanceYTD['net_profit']);
            result.cash_flow = Utils.safeInt(dataPerformanceYTD['cash_flow']);
            result.show_dataPerformanceYTD = true;
          }

          if (dataBalanceSheet != null) {
            result.assets = Utils.safeInt(dataBalanceSheet['assets']);
            result.cash_and_equiv =
                Utils.safeInt(dataBalanceSheet['cash_and_equiv']);
            result.liability = Utils.safeInt(dataBalanceSheet['liability']);
            result.debt = Utils.safeInt(dataBalanceSheet['debt']);
            result.equity = Utils.safeInt(dataBalanceSheet['equity']);
            result.show_dataBalanceSheet = true;
          }

          if (dataValuation != null) {
            result.price_earning_ratio =
                Utils.safeDouble(dataValuation['price_earning_ratio']);
            result.price_sales_ratio =
                Utils.safeDouble(dataValuation['price_sales_ratio']);
            result.price_book_value_ratio =
                Utils.safeDouble(dataValuation['price_book_value_ratio']);
            result.price_cash_flow_ratio =
                Utils.safeDouble(dataValuation['price_cash_flow_ratio']);
            result.dividend_yield =
                Utils.safeDouble(dataValuation['dividend_yield']);
            result.show_dataValuation = true;
          }

          if (dataPerShare != null) {
            result.earning_per_share =
                Utils.safeInt(dataPerShare['earning_per_share']);
            result.dividend_per_share =
                Utils.safeInt(dataPerShare['dividend_per_share']);
            result.revenue_per_share =
                Utils.safeInt(dataPerShare['revenue_per_share']);
            result.book_value_per_share =
                Utils.safeInt(dataPerShare['book_value_per_share']);
            result.cash_equiv_per_share =
                Utils.safeInt(dataPerShare['cash_equiv_per_share']);
            result.cash_flow_per_share =
                Utils.safeInt(dataPerShare['cash_flow_per_share']);
            result.net_assets_per_share =
                Utils.safeInt(dataPerShare['net_assets_per_share']);
            result.show_dataPerShare = true;
          }

          if (dataProfitability != null) {
            result.operating_profit_margin =
                Utils.safeDouble(dataProfitability['operating_profit_margin']);
            result.net_profit_margin =
                Utils.safeDouble(dataProfitability['net_profit_margin']);
            result.return_on_equity =
                Utils.safeDouble(dataProfitability['return_on_equity']);
            result.return_on_assets =
                Utils.safeDouble(dataProfitability['return_on_assets']);
            result.show_dataProfitability = true;
          }

          if (dataLiquidity != null) {
            result.debt_equity_ratio =
                Utils.safeDouble(dataLiquidity['debt_equity_ratio']);
            result.current_ratio =
                Utils.safeDouble(dataLiquidity['current_ratio']);
            result.cash_ratio = Utils.safeDouble(dataLiquidity['cash_ratio']);
            result.show_dataLiquidity = true;
          }

          /*
          "dataPerformanceYTD": {
            "sales": 29,
            "operating_profit": 30,
            "net_profit": 31,
            "cash_flow": 32
          },
          "dataBalanceSheet": {
            "assets": 33,
            "cash_and_equiv": 34,
            "liability": 35,
            "debt": 36,
            "equity": 37
          },
          "dataValuation": {
            "price_earning_ratio": 38,
            "price_sales_ratio": 39,
            "price_book_value_ratio": 40,
            "price_cash_flow_ratio": 41,
            "dividend_yield": 42
          },
          "dataPerShare": {
            "earning_per_share": 43,
            "dividend_per_share": 44,
            "revenue_per_share": 45,
            "book_value_per_share": 46,
            "cash_equiv_per_share": 47,
            "cash_flow_per_share": 48,
            "net_assets_per_share": 49
          },
          "dataProfitability": {
            "operational_profit_margin": 50,
            "net_profit_margin": 51,
            "return_on_equity": 52,
            "return_on_assets": 53
          },
          "dataLiquidity": {
            "debt_equity_ratio": 54,
            "current_ratio": 55,
            "cash_ratio": 56
          }
          */
        }
        /*
        var datas = parsedJson['datas'] as List?;
        if(datas != null){
          datas.forEach((parsedJson) {
            list.add(ResearchRank.fromJson(parsedJson));

          });
        }

         */
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ForeignDomestic?> fetchCompositeFD(String board) async {
    String path = 'r_composite_fd.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'board': board,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchCompositeFD : ' + response.body);

      List<ForeignDomestic>? list = List<ForeignDomestic>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String? message = StringUtils.noNullString(parsedJson['message']);
        String? board = StringUtils.noNullString(parsedJson['board']);
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(ForeignDomestic.fromJson(parsedJson, 'COMPOSITE', board));
          });
        }
      }
      if (list != null && list.isNotEmpty) {
        return list.first;
      }
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ForeignDomestic?> fetchCompositeFDHistorical(
      String board, String? from, String? to) async {
    String path = 'm_composite_fd_historical.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'board': board,
      'from': from,
      'to': to,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchCompositeFDHistorical : ' + response.body);

      List<ForeignDomestic> list = List<ForeignDomestic>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String? message = StringUtils.noNullString(parsedJson['message']);
        //String board = StringUtils.noNullString(parsedJson['board']);

        String? board = '';
        String? from = '';
        String? to = '';

        var parameters = parsedJson['parameters'];
        if (parameters != null && parameters is Map) {
          board = StringUtils.noNullString(parameters['board']);
          from = StringUtils.noNullString(parameters['from']);
          to = StringUtils.noNullString(parameters['to']);
        }

        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(ForeignDomestic.fromJson(parsedJson, 'COMPOSITE', board));
          });
        }
      }
      if (list != null && list.isNotEmpty) {
        return list.first;
      }
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ForeignDomestic?> fetchStockFDHistorical(
      String? code, String board, String? from, String? to) async {
    String path = 'm_stock_fd_historical.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'board': board,
      'from': from,
      'to': to,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchStockFDHistorical : ' + response.body);

      List<ForeignDomestic> list = List<ForeignDomestic>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String? message = StringUtils.noNullString(parsedJson['message']);
        //String board = StringUtils.noNullString(parsedJson['board']);
        //String code = StringUtils.noNullString(parsedJson['code']);

        String? board = '';
        String? code = '';
        String? from = '';
        String? to = '';

        var parameters = parsedJson['parameters'];
        if (parameters != null && parameters is Map) {
          code = StringUtils.noNullString(parameters['code']);
          board = StringUtils.noNullString(parameters['board']);
          from = StringUtils.noNullString(parameters['from']);
          to = StringUtils.noNullString(parameters['to']);
        }

        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(ForeignDomestic.fromJson(parsedJson, code, board));
          });
        }
      }
      if (list != null && list.isNotEmpty) {
        return list.first;
      }
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ForeignDomestic?> fetchStockFD(String? code, String board) async {
    String path = 'r_stock_fd.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'board': board,
    };
    DebugWriter.info(parameters);
    final response = await http
        .get(Uri.http(baseUrlLocalhost, path, parameters))
        .timeout(Duration(seconds: timeout_in_seconds));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info('fetchStockFD : ' + response.body);

      List<ForeignDomestic> list = List<ForeignDomestic>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String? message = StringUtils.noNullString(parsedJson['message']);
        String? board = StringUtils.noNullString(parsedJson['board']);
        String? code = StringUtils.noNullString(parsedJson['code']);
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(ForeignDomestic.fromJson(parsedJson, code, board));
          });
        }
      }
      if (list != null && list.isNotEmpty) {
        return list.first;
      }
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<TradeBook?> fetchTradeBook(String code, String board) async {
    var parameters = {
      'code': code,
      'board': board,
    };
    final response = await http
        .get(Uri.http(baseUrlLocalhost, 'r_trade_book.php', parameters));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<TradeBook> list = List<TradeBook>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(TradeBook.fromJson(parsedJson));
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          list.add(TradeBook.fromXml(element));
        });
      }
      */
      if (list != null && list.isNotEmpty) {
        return list.first;
      }

      return null;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<OrderBook?> fetchOrderBook(String code, String board) async {
    var parameters = {
      'code': code,
      'board': board,
    };
    final response = await http
        .get(Uri.http(baseUrlLocalhost, 'r_order_book.php', parameters));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<OrderBook> list = List<OrderBook>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(OrderBook.fromJson(parsedJson));
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          list.add(OrderBook.fromXml(element));
        });
      }
      */

      if (list != null && list.isNotEmpty) {
        return list.first;
      }

      return null;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<List<IndexSummary>> fetchIndices(List<String?>? codes) async {
    //String path = 'r_indices.php?code='+codes.join("_");
    String path = 'r_indices.php';
    //print('path = $baseUrlLocalhost/$path');
    //Map map = Map();
    //map['code'] = codes.join('_');
    var parameters = {
      'code': codes?.join('_'),
      //'param2': 'two',
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('indices --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<IndexSummary> list = List<IndexSummary>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            list.add(IndexSummary.fromJson(parsedJson));
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          IndexSummary indexSummary = IndexSummary.fromXml(element);
          //print(indexSummary.toString());
          list.add(indexSummary);
        });
      }
      */
      return list;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<StockSummary?> fetchStockSummary(String? code, String board) async {
    String path = 'r_summary.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'board': board,
    };
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('stockSummary --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<StockSummary> list = List<StockSummary>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        List<dynamic>? datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            StockSummary? stockSummary = StockSummary.fromJson(parsedJson);
            DebugWriter.info(stockSummary.toString());
            if (stockSummary != null &&
                StringUtils.isContains(code, stockSummary.code)! &&
                StringUtils.equalsIgnoreCase(board, stockSummary.board)) {
              list.add(stockSummary);
            }
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);
      if (document != null) {
        document.findAllElements('a').forEach((element) {
          StockSummary stockSummary = StockSummary.fromXml(element);
          //print(indexSummary.toString());
          if (StringUtils.equalsIgnoreCase(code, stockSummary.code) && StringUtils.equalsIgnoreCase(board, stockSummary.board)) {
            list.add(stockSummary);
          }
        });
      }
      */
      return list.isNotEmpty ? list.first : null;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<List<StockSummary>> fetchStockSummaryMultiple(
      String? code, String? board) async {
    String path = 'r_summary.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'board': board,
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('stockSummaryMultiple --> ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<StockSummary> list = List<StockSummary>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            StockSummary? stockSummary = StockSummary.fromJson(parsedJson);
            DebugWriter.info(stockSummary.toString());
            if (stockSummary != null &&
                StringUtils.isContains(
                    code,
                    stockSummary
                        .code)! /*&& StringUtils.equalsIgnoreCase(board, stockSummary.board) */) {
              list.add(stockSummary);
            }
          });
        }
      }
      /*
      final document = XmlDocument.parse(response.body);


      if (document != null) {
        document.findAllElements('a').forEach((element) {
          StockSummary stockSummary = StockSummary.fromXml(element);
          DebugWriter.info(stockSummary?.toString());
          if (StringUtils.isContains(code, stockSummary.code) && StringUtils.equalsIgnoreCase(board, stockSummary.board)) {
            list.add(stockSummary);
          }
        });
      }
      */
      return list;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ResultTopStock> fetchTopStock(String type) async {
    String path = 'm_top_stock.php';
    DebugWriter.info('path = $baseUrlLocalhost/$path');

    var parameters = {
      'type': type, // GAINERS LOSERS ACTIVE VOLUME VALUE
      'warant': 'false',
      'right': 'false',
      'limit': '15',
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('fetchTopStock body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //List<TopStock> list = List<TopStock>.empty(growable: true);
      ResultTopStock result = ResultTopStock();
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.range = 'INTRADAY';
        result.type = parsedJson['type'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            TopStock? top = TopStock.fromJson(parsedJson);
            DebugWriter.info(top.toString());
            if (top != null) {
              result.datas?.add(top);
            }
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<OrderQueueData> fetchOrderQueue(
      String? code, String? board, int? price, String? type) async {
    String path = 'r_queue.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'board': board,
      'price': price.toString(),
      'type': type, // BID OFFER
    };
    DebugWriter.info(parameters);

    DebugWriter.info("fetchOrderQueue " + serverAddress.toString());
    DebugWriter.info("fetchOrderQueue baseUrlLocalhost : " + baseUrlLocalhost);

    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('fetchOrderQueue body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //List<TopStock> list = List<TopStock>.empty(growable: true);
      OrderQueueData result = OrderQueueData();
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        result.message = StringUtils.noNullString(parsedJson['message']);
        result.datas_count = Utils.safeInt(parsedJson['datas_count']);

        var parameters = parsedJson['parameters'];
        if (parameters != null && parameters is Map) {
          result.code = StringUtils.noNullString(parameters['code']);
          result.board = StringUtils.noNullString(parameters['board']);
          result.price = Utils.safeInt(parameters['price']);
          result.type = StringUtils.noNullString(parameters['type']);
        }
        // Map<String, dynamic> additional_data = parsedJson['additional_data'] as Map;
        var additionalData = parsedJson['additional_data'];
        if (additionalData != null && additionalData is Map) {
          result.total_volume = Utils.safeInt(additionalData['total_volume']);
          result.total_remaining_volume =
              Utils.safeInt(additionalData['total_remaining_volume']);
        }

        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            OrderQueue? queue = OrderQueue.fromJson(parsedJson);
            DebugWriter.info(queue.toString());
            if (queue != null) {
              result.datas?.add(queue);
            }
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ResultTopStock> fetchTopStockHistorical(
      String type, String range) async {
    String path = 'm_top_stock_historical.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'type': type, // GAINERS LOSERS ACTIVE VOLUME VALUE
      'range': range,
      'warant': 'false',
      'right': 'false',
      'limit': '15',
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('fetchTopStockHistorical body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //List<TopStock> list = List<TopStock>.empty(growable: true);
      ResultTopStock result = ResultTopStock();
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        result.range = parsedJson['range'];
        result.type = parsedJson['type'];
        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            TopStock? top = TopStock.fromJson(parsedJson);
            DebugWriter.info(top?.toString());
            if (top != null) {
              result.datas?.add(top);
            }
          });
        }
      }
      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<String> registerDevice(
      String? username,
      String? deviceId,
      String? devicePlatform,
      String? fcmToken,
      String? applicationVersion) async {
    String path = 'n_device_registration.php';
    //print('path = $baseUrlLocalhost/$path');
    //username=AAA&device_id=1234&device_platform=Web&fcm_token=abctoken&application_version=0.01
    var parameters = {
      'username': username, // GAINERS LOSERS ACTIVE VOLUME VALUE
      'device_id': deviceId,
      'device_platform': devicePlatform,
      'fcm_token': fcmToken,
      'application_version': applicationVersion,
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('registerDevice body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //List<TopStock> list = List<TopStock>.empty(growable: true);

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      String message = '';
      if (parsedJson != null) {
        message = parsedJson['message'];
        String action = parsedJson['action'];
        DebugWriter.info('message : $message  action : $action');
      }
      return message;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<ResultInbox> fetchInbox(
      String username,
      String?
          dateStart /*, String device_id, String device_platform, String application_version*/) async {
    String path = 'n_inbox.php';
    //print('path = $baseUrlLocalhost/$path');
    //username=AAA&device_id=1234&device_platform=Web&fcm_token=abctoken&application_version=0.01
    var parameters = {
      'username': username,
      'date_start': dateStart,
      'limit': '10',
      // 'device_id': device_id,
      // 'device_platform': device_platform,
      // 'application_version': application_version,
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('fetchInbox body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      /*
      {
        "tag": "INBOX",
        "username": "richy",
        "date_start": "2021-11-02 22:12:43",
        "date_next": "",
        "more_data": "false",
        "date": "2021-11-04",
        "time": "15:50:14",
        "datas_count": 1,
        "datas": [
          {
          "#": 1,
          "ib_id": "1",
          "created_at": "2021-11-02 22:12:43",
          "sent_at": null,
          "fcm_title": "fcm_title",
          "fcm_body": "fcm_body",
          "fcm_image_url": "fcm_image_url",
          "fcm_android_color": "color",
          "fcm_android_channel_id": "fcm_android_channel_id",
          "fcm_data_keys": "fcm_data_keys",
          "fcm_data_values": "fcm_data_values",
          "fcm_message_id": "fcm_message_id",
          "read_count": "0"
          }
        ]
      }
      */
      ResultInbox result = ResultInbox();
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);

      if (parsedJson != null) {
        result.message = StringUtils.noNullString(parsedJson['message']);
        result.username = StringUtils.noNullString(parsedJson['username']);
        result.date_start = StringUtils.noNullString(parsedJson['date_start']);
        result.date_next = StringUtils.noNullString(parsedJson['date_next']);
        result.more_data = Utils.safeBool(parsedJson['more_data']);
        DebugWriter.info('fetchInbox message : ' +
            result.message! +
            '  username : ' +
            result.username! +
            '  more_data : ' +
            result.more_data.toString());

        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            InboxMessage? top =
                InboxMessage.fromJson(parsedJson, result.username);
            DebugWriter.info(top.toString());
            if (top != null) {
              result.datas?.add(top);
            }
          });
        }
      }

      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<String?> reportNotification(
      String? notifType, String? notifId, String? deviceId,
      {String action = ''}) async {
    String path = 'n_report_notification.php';
    //print('path = $baseUrlLocalhost/$path');
    //n_report_notification.php?notif_type=INBOX&notif_id=1&device_id=H0Gxo_2021-11-08%2022:18:19.155940&action=read
    var parameters = {
      'notif_type': notifType,
      'notif_id': notifId,
      'device_id': deviceId,
      'action': action,
    };
    DebugWriter.info(parameters);
    String result = '';
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('reportNotification body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      /*
      {
        "tag": "REPORT_NOTIFICATION",
        "notif_id": "1",
        "notif_type": "INBOX",
        "device_id": "H0Gxo_2021-11-08 22:18:19.155940",
        "action": "",
        "action_performed": "readed",
        "date": "2021-11-09",
        "time": "13:41:00",
        "message": "",
        "datas_count": 3
      }
      */
      String? result = '';
      Map<String, dynamic>? parsedJson = jsonDecode(response.body);

      if (parsedJson != null) {
        String? message = StringUtils.noNullString(parsedJson['message']);
        String? actionPerformed =
            StringUtils.noNullString(parsedJson['action_performed']);
        result = actionPerformed;
        DebugWriter.info('reportNotification action_performed : ' +
            actionPerformed! +
            '  message : ' +
            message!);
      }

      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<PerformanceData> fetchPerformance(String type, String? code) async {
    String path = 'm_performance.php';
    //print('path = $baseUrlLocalhost/$path');

    var parameters = {
      'type': type, // INDEX , STOCK
      'code': code,
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('fetchPerformance body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //List<TopStock> list = List<TopStock>.empty(growable: true);

      PerformanceData result = PerformanceData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        Null message = parsedJson['message'];
        String type = parsedJson['type'];
        String code = parsedJson['code'];
        result.code = code;
        result.type = type;

        var datas = parsedJson['datas'] as List?;
        if (datas != null) {
          datas.forEach((parsedJson) {
            Performance? performance = Performance.fromJson(parsedJson);
            DebugWriter.info(performance.toString());
            if (performance != null) {
              result.addPerformance(performance);
            }
          });
        }
      }

      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<StockTopBrokerData?> fetchStockTopBroker(
      String? code, String board, String? from, String? to) async {
    String path = 'm_stock_top_broker.php';
    DebugWriter.info('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'board': board,
      'from': from,
      'to': to,
    };
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('fetchStockTopBroker body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //List<TopStock> list = List<TopStock>.empty(growable: true);

      StockTopBrokerData result = StockTopBrokerData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        String message = parsedJson['message'];
        result.last_date = StringUtils.noNullString(parsedJson['last_date']);

        var parameters = parsedJson['parameters'];
        if (parameters != null && parameters is Map) {
          result.code = StringUtils.noNullString(parameters['code']);
          result.board = StringUtils.noNullString(parameters['board']);
          result.from = StringUtils.noNullString(parameters['from']);
          result.to = StringUtils.noNullString(parameters['to']);
        }
        var datas = parsedJson['datas'];
        if (datas != null) {
          var buyer = datas['Buyer'] as List?;
          var seller = datas['Seller'] as List?;
          var netBuyer = datas['NetBuyer'] as List?;
          var netSeller = datas['NetSeller'] as List?;

          if (buyer != null) {
            buyer.forEach((parsedJson) {
              BrokerNetBuySell? b = BrokerNetBuySell.fromJson(parsedJson);
              DebugWriter.info(b?.toString());
              if (b != null) {
                result.topBuyer?.add(b);
              }
            });
          }

          if (seller != null) {
            seller.forEach((parsedJson) {
              BrokerNetBuySell? b = BrokerNetBuySell.fromJson(parsedJson);
              DebugWriter.info(b?.toString());
              if (b != null) {
                result.topSeller?.add(b);
              }
            });
          }

          if (netBuyer != null) {
            netBuyer.forEach((parsedJson) {
              BrokerNetBuySell? b = BrokerNetBuySell.fromJson(parsedJson);
              DebugWriter.info(b?.toString());
              if (b != null) {
                result.topNetBuyer?.add(b);
              }
            });
          }
          if (netSeller != null) {
            netSeller.forEach((parsedJson) {
              BrokerNetBuySell? b = BrokerNetBuySell.fromJson(parsedJson);
              DebugWriter.info(b?.toString());
              if (b != null) {
                result.topNetSeller?.add(b);
              }
            });
          }
        }

        return result;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Error : ' +
            response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
      }
    }
    return null;
  }

  Future<NetBuySellSummaryData?> fetchStockTopBrokerSummary(
      String code,
      String board,
      String? from,
      String? to,
      String type,
      String dataBy) async {
    String path = 'm_stock_top_broker_summary.php';
    DebugWriter.info('path = $baseUrlLocalhost/$path');

    var parameters = {
      'code': code,
      'board': board,
      'from': from,
      'to': to,
      'type': type,
      'data_by': dataBy,
    };
    DebugWriter.info('fetchStockTopBrokerSummary parameters');
    DebugWriter.info(parameters);
    final response =
        await http.get(Uri.http(baseUrlLocalhost, path, parameters));
    DebugWriter.info('fetchStockTopBrokerSummary body : ' + response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //List<TopStock> list = List<TopStock>.empty(growable: true);

      NetBuySellSummaryData result = NetBuySellSummaryData();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        result.message = parsedJson['message'];
        result.last_date = StringUtils.noNullString(parsedJson['last_date']);

        var parameters = parsedJson['parameters'];
        if (parameters != null && parameters is Map) {
          result.code = StringUtils.noNullString(parameters['code']);
          result.board = StringUtils.noNullString(parameters['board']);
          result.from = StringUtils.noNullString(parameters['from']);
          result.to = StringUtils.noNullString(parameters['to']);
          result.type = StringUtils.noNullString(parameters['type']);
          result.data_by = StringUtils.noNullString(parameters['data_by']);
        }
        var datas = parsedJson['datas'];
        if (datas != null) {
          var buyer = datas['Buyer'] as List?;
          var seller = datas['Seller'] as List?;
          var total = datas['Total'];
          if (total != null && total is Map) {
            result.BValue = Utils.safeInt(total['BValue']);
            result.BVolume = Utils.safeInt(total['BVolume']);
            result.BAverage = Utils.safeDouble(total['BAverage']);
            result.SValue = Utils.safeInt(total['SValue']);
            result.SVolume = Utils.safeInt(total['SVolume']);
            result.SAverage = Utils.safeDouble(total['SAverage']);
            result.BValueDomestic = Utils.safeInt(total['BValueDomestic']);
            result.BValueForeign = Utils.safeInt(total['BValueForeign']);
            result.SValueDomestic = Utils.safeInt(total['SValueDomestic']);
            result.SValueForeign = Utils.safeInt(total['SValueForeign']);
          }

          if (buyer != null) {
            buyer.forEach((parsedJson) {
              NetBuySellSummary? b = NetBuySellSummary.fromJson(parsedJson);
              DebugWriter.info(b.toString());
              if (b != null) {
                result.topBuyer?.add(b);
              }
            });
          }

          if (seller != null) {
            seller.forEach((parsedJson) {
              NetBuySellSummary? b = NetBuySellSummary.fromJson(parsedJson);
              DebugWriter.info(b.toString());
              if (b != null) {
                result.topSeller?.add(b);
              }
            });
          }
        }

        return result;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Error : ' +
            response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
      }
    }
    return null;
  }

  Future<Map> fetchStockBrokerIndex(
      String md5broker, String md5stock, String md5index) async {
    var parameters = {
      'md5broker': md5broker,
      'md5stock': md5stock,
      'md5index': md5index,
    };

    final response = await http.get(
      Uri.http(baseUrlLocalhost, 'm_stock_broker_index.php', parameters),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      // DebugWriter.info(response.body);
      final XmlDocument? document = XmlDocument.parse(response.body);

      MD5StockBrokerIndex? md5;
      List<Broker> listBroker = List<Broker>.empty(growable: true);
      List<Stock> listStock = List<Stock>.empty(growable: true);
      List<Index> listIndex = List<Index>.empty(growable: true);
      bool stockChanged = false;
      bool indexChanged = false;
      bool brokerChanged = false;

      var maps = new Map();

      if (document != null) {
        DebugWriter.info('document = ' + document.toString());
        //print('firstChild = '+document.firstChild.toString());
        DebugWriter.info('document.children.length = ' +
            document.children.length.toString());
        DebugWriter.info('document.firstChild.document.children.length = ' +
            document.firstChild!.document!.children.length.toString());

        // final brokers = document.findAllElements('BROKER');
        // brokers.map((node) => {
        //   node.findAllElements('a').map((e) => e.getAttribute('code')).forEach(print)
        // });

        /** DEBUG
            for (XmlNode child in document.children) {
            if (child is XmlDeclaration) {
            DebugWriter.info(child.version); // 1.0
            } else if (child is XmlDoctype) {
            DebugWriter.info(child.text); // rootDtd
            } else if (child is XmlElement) {
            DebugWriter.info(child.name); // root
            for (XmlNode sub_child in child.children) {
            if (sub_child is XmlElement) {
            DebugWriter.info(sub_child.name); // root

            for (XmlNode node in sub_child.children) {
            if (node is XmlElement) {
            DebugWriter.info(node.name); // root
            }
            }
            }
            }
            }
            }
         */
        final Iterable<XmlElement>? md5s = document.findAllElements('MD5');
        final Iterable<XmlElement>? stocks =
            document.findAllElements('STOCK_SHORT');
        final Iterable<XmlElement>? brokers =
            document.findAllElements('BROKER');
        final Iterable<XmlElement>? indexs = document.findAllElements('INDEX');

        if (md5s == null) {
          DebugWriter.info('md5s NULL');
        } else if (md5s.isEmpty) {
          DebugWriter.info('md5s EMPTY');
        } else {
          // DebugWriter.info('stocks ada : '+stocks.join('|'));
          DebugWriter.info(
              'md5s ada md5s.name : ' + md5s.first.name.toString());

          final Iterable<XmlElement>? allMd5s = md5s.first.findElements('a');
          if (allMd5s == null) {
            DebugWriter.info('allMd5s NULL');
          } else if (allMd5s.isEmpty) {
            DebugWriter.info('allMd5s EMPTY');
          } else {
            DebugWriter.info('allMd5s size : ' + allMd5s.length.toString());
            allMd5s.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              md5 = MD5StockBrokerIndex.fromXml(element);
              //print(md5.toString());
              if (md5 != null && md5!.isValid()) {
                stockChanged =
                    !StringUtils.equalsIgnoreCase(md5?.md5stock, md5stock);
                brokerChanged =
                    !StringUtils.equalsIgnoreCase(md5?.md5broker, md5broker);
                indexChanged =
                    !StringUtils.equalsIgnoreCase(md5?.md5index, md5index);
              }
            });
          }
        }

        if (stocks == null) {
          DebugWriter.info('stocks NULL');
        } else if (stocks.isEmpty) {
          DebugWriter.info('stocks EMPTY');
        } else {
          // DebugWriter.info('stocks ada : '+stocks.join('|'));
          DebugWriter.info(
              'stocks ada first.name : ' + stocks.first.name.toString());

          final Iterable<XmlElement>? allStocks =
              stocks.first.findElements('a');
          if (allStocks == null) {
            DebugWriter.info('allStocks NULL');
          } else if (allStocks.isEmpty) {
            DebugWriter.info('allStocks EMPTY');
          } else {
            DebugWriter.info('allStocks size : ' + allStocks.length.toString());
            allStocks.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              Stock stock = Stock.fromXml(element);
              //print(stock.toString());
              listStock.add(stock);
            });
          }
        }

        if (brokers == null) {
          DebugWriter.info('brokers NULL');
        } else if (brokers.isEmpty) {
          DebugWriter.info('brokers EMPTY');
        } else {
          // DebugWriter.info('brokers ada : '+brokers.join('|'));
          DebugWriter.info(
              'brokers ada first.name : ' + brokers.first.name.toString());

          final Iterable<XmlElement>? allBrokers =
              brokers.first.findElements('a');
          if (allBrokers == null) {
            DebugWriter.info('allBrokers NULL');
          } else if (allBrokers.isEmpty) {
            DebugWriter.info('allBrokers EMPTY');
          } else {
            DebugWriter.info(
                'allBrokers size : ' + allBrokers.length.toString());
            allBrokers.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              Broker broker = Broker.fromXml(element);
              //print(broker);
              listBroker.add(broker);
            });
          }
        }

        if (indexs == null) {
          DebugWriter.info('indexs NULL');
        } else if (indexs.isEmpty) {
          DebugWriter.info('indexs EMPTY');
        } else {
          // DebugWriter.info('indexs ada : '+indexs.join('|'));
          DebugWriter.info(
              'indexs ada first.name : ' + indexs.first.name.toString());

          final Iterable<XmlElement>? allIndexs =
              indexs.first.findElements('a');
          if (allIndexs == null) {
            DebugWriter.info('allIndexs NULL');
          } else if (allIndexs.isEmpty) {
            DebugWriter.info('allIndexs EMPTY');
          } else {
            DebugWriter.info('allIndexs size : ' + allIndexs.length.toString());
            allIndexs.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              Index index = Index.fromXml(element);
              //print(index);
              listIndex.add(index);
            });
          }
        }

        // final titles = document.findAllElements('a');
        // titles
        //     .map((node) => node.getAttribute('code'))
        //     .forEach(print);
        //document.nodes.map((node) => DebugWriter.info('node = '+node.toString()));

        // document.findAllElements('a').forEach((element) {
        //   DebugWriter.info('code = '+element.getAttribute('code'));
        // });

        // document.children.map((node) => (){
        //   DebugWriter.info('node = '+node.toString());
        // });
        // XmlElement brokers = document.getElement('BROKER');
        // DebugWriter.info(brokers);
        // brokers.findElements('a').forEach((element) {
        //   Broker broker = Broker.fromXml(element);
        //   DebugWriter.info(broker);
        //   listBroker.add(broker);
        // });
        //
        // XmlElement stocks = document.getElement('STOCK_SHORT');
        // DebugWriter.info(stocks);
        // stocks.findElements('a').forEach((element) {
        //   Stock stock = Stock.fromXml(element);
        //   DebugWriter.info(stock);
        //   listStock.add(stock);
        // });
        //
        // XmlElement indexs = document.getElement('INDEX');
        // DebugWriter.info(indexs);
        // document.findElements('a').forEach((element) {
        //   Index index = Index.fromXml(element);
        //   DebugWriter.info(index);
        //   listIndex.add(index);
        // });
        /*
        document.findElements('a').forEach((element) {
          DebugWriter.info('element = ' + element.toString());
          // element.findElements('a').forEach((element) {
          //   Broker broker = Broker.fromXml(element);
          //   DebugWriter.info(broker);
          //   listBroker.add(broker);
          // });
        });

         */
        /*
        document.findElements('STOCK_SHORT').forEach((element) {
          document.findElements('a').forEach((element) {
            DebugWriter.info(element.text);
            Stock stock = Stock.fromXml(element);
            DebugWriter.info(stock);
            listStock.add(stock);
          });

        });

        document.findElements('INDEX').forEach((element) {
          DebugWriter.info(element.text);
          document.findElements('a').forEach((element) {
            Index index = Index.fromXml(element);
            DebugWriter.info(index);
            listIndex.add(index);
          });

        });
        */
      } else {
        DebugWriter.info('XML data null');
      }
      DebugWriter.info('XML done');

      bool validBrokerChanged = brokerChanged && listBroker.isNotEmpty;
      bool validStockChanged = stockChanged && listStock.isNotEmpty;
      bool validIndexChanged = indexChanged && listIndex.isNotEmpty;

      DebugWriter.info('XML validBrokerChanged : $validBrokerChanged');
      DebugWriter.info('XML validStockChanged : $validStockChanged');
      DebugWriter.info('XML validIndexChanged : $validIndexChanged');

      maps['brokers'] = validBrokerChanged ? listBroker : null;
      maps['stocks'] = validStockChanged ? listStock : null;
      maps['indexs'] = validIndexChanged ? listIndex : null;

      maps['md5broker'] = validBrokerChanged ? md5broker : null;
      maps['md5stock'] = validStockChanged ? md5stock : null;
      maps['md5index'] = validIndexChanged ? md5index : null;

      maps['md5'] = md5;

      maps['validBrokerChanged'] = validBrokerChanged;
      maps['validStockChanged'] = validStockChanged;
      maps['validIndexChanged'] = validIndexChanged;

      // maps['brokers'] = listBroker;
      // maps['stocks'] = listStock;
      // maps['indexs'] = listIndex;

      return maps;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  Future<Map> fetchMarketData(String? md5broker, String? md5stock,
      String? md5index, String? md5sector) async {
    var parameters = {
      'md5broker': md5broker,
      'md5stock': md5stock,
      'md5index': md5index,
      'md5sector': md5sector,
    };

    final response = await http
        .get(Uri.http(baseUrlLocalhost, 'm_market_data.php', parameters));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      DebugWriter.info('marketData --> ' + response.body);

      MD5StockBrokerIndex? md5;
      List<Broker> listBroker = List<Broker>.empty(growable: true);
      List<Stock> listStock = List<Stock>.empty(growable: true);
      List<Index> listIndex = List<Index>.empty(growable: true);
      List<Sector> listSector = List<Sector>.empty(growable: true);
      bool stockChanged = false;
      bool indexChanged = false;
      bool brokerChanged = false;
      bool sectorChanged = false;

      var maps = new Map();

      Map<String, dynamic>? parsedJson = jsonDecode(response.body);
      if (parsedJson != null) {
        // String? message = parsedJson['message'];
        dynamic datas = parsedJson['datas'];
        if (datas != null) {
          /*
          "md5": {
          "md5broker": "ecb43bbb92d8911fa953a245987c1ba8",
          "md5stock": "b29ed7c9355f64cc45bdf059f2e0a200",
          "md5index": "b243bac87cf76a0e958e77cd87e8c0e1",
          "md5sector": "44932c977223d53a86982626e15d3cfb",
          "md5brokerUpdate": "2021-08-28 10:07:45",
          "md5stockUpdate": "2021-08-28 10:07:45",
          "md5indexUpdate": "2021-08-28 10:07:45",
          "md5sectorUpdate": "2021-08-28 10:07:45",
          "sharePerLot": 100
          },
          */
          DebugWriter.info(datas);
          var md5Json = datas['md5'];
          DebugWriter.info(md5Json);
          md5 = MD5StockBrokerIndex.fromJson(md5Json);

          if (md5 != null && md5.isValid()) {
            stockChanged =
                !StringUtils.equalsIgnoreCase(md5.md5stock, md5stock);
            brokerChanged =
                !StringUtils.equalsIgnoreCase(md5.md5broker, md5broker);
            indexChanged =
                !StringUtils.equalsIgnoreCase(md5.md5index, md5index);
            sectorChanged =
                !StringUtils.equalsIgnoreCase(md5.md5sector, md5sector);
          }

          var broker = datas['broker'] as List?;
          if (broker != null) {
            broker.forEach((element) {
              Broker broker = Broker.fromJson(element);
              DebugWriter.info(broker.toString());
              listBroker.add(broker);
            });
          }

          var stock = datas['stock'] as List?;
          if (stock != null) {
            stock.forEach((element) {
              Stock? stock = Stock.fromJson(element);
              DebugWriter.info(stock.toString());
              listStock.add(stock);
            });
          }
          var index = datas['index'] as List?;
          if (index != null) {
            index.forEach((element) {
              Index index = Index.fromJson(element);
              DebugWriter.info(index.toString());
              listIndex.add(index);
            });
          }

          var sector = datas['sector'] as List?;
          if (sector != null) {
            sector.forEach((element) {
              Sector sector = Sector.fromJson(element);
              DebugWriter.info(sector.toString());
              listSector.add(sector);
            });
          }
          bool validBrokerChanged = brokerChanged && listBroker.isNotEmpty;
          bool validStockChanged = stockChanged && listStock.isNotEmpty;
          bool validIndexChanged = indexChanged && listIndex.isNotEmpty;
          bool validSectorChanged = sectorChanged && listSector.isNotEmpty;

          DebugWriter.info('JSON validBrokerChanged : $validBrokerChanged');
          DebugWriter.info('JSON validStockChanged : $validStockChanged');
          DebugWriter.info('JSON validIndexChanged : $validIndexChanged');
          DebugWriter.info('JSON validSectorChanged : $validSectorChanged');

          maps['brokers'] = validBrokerChanged ? listBroker : null;
          maps['stocks'] = validStockChanged ? listStock : null;
          maps['indexs'] = validIndexChanged ? listIndex : null;
          maps['sectors'] = validSectorChanged ? listSector : null;

          maps['md5broker'] = validBrokerChanged ? md5broker : null;
          maps['md5stock'] = validStockChanged ? md5stock : null;
          maps['md5index'] = validIndexChanged ? md5index : null;
          maps['md5sector'] = validSectorChanged ? md5sector : null;

          maps['md5'] = md5;

          maps['validBrokerChanged'] = validBrokerChanged;
          maps['validStockChanged'] = validStockChanged;
          maps['validIndexChanged'] = validIndexChanged;
          maps['validSectorChanged'] = validSectorChanged;

          // maps['brokers'] = listBroker;
          // maps['stocks'] = listStock;
          // maps['indexs'] = listIndex;
        }
      }
      return maps;
      /*
      final document = XmlDocument.parse(response.body);


      List<Broker> listBroker = List<Broker>.empty(growable: true);
      List<Stock> listStock = List<Stock>.empty(growable: true);
      List<Index> listIndex = List<Index>.empty(growable: true);
      bool stockChanged = false;
      bool indexChanged = false;
      bool brokerChanged = false;

      var maps = new Map();

      if (document != null) {
        DebugWriter.info('document = ' + document.toString());
        //print('firstChild = '+document.firstChild.toString());
        DebugWriter.info('document.children.length = ' + document.children.length.toString());
        DebugWriter.info('document.firstChild.document.children.length = ' + document.firstChild.document.children.length.toString());
        final md5s = document.findAllElements('MD5');
        final stocks = document.findAllElements('STOCK_SHORT');
        final brokers = document.findAllElements('BROKER');
        final indexs = document.findAllElements('INDEX');

        if (md5s == null) {
          DebugWriter.info('md5s NULL');
        } else if (md5s.isEmpty) {
          DebugWriter.info('md5s EMPTY');
        } else {
          // DebugWriter.info('stocks ada : '+stocks.join('|'));
          DebugWriter.info('md5s ada md5s.name : ' + md5s.first.name.toString());

          final allMd5s = md5s.first.findElements('a');
          if (allMd5s == null) {
            DebugWriter.info('allMd5s NULL');
          } else if (allMd5s.isEmpty) {
            DebugWriter.info('allMd5s EMPTY');
          } else {
            DebugWriter.info('allMd5s size : ' + allMd5s.length.toString());
            allMd5s.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              md5 = MD5StockBrokerIndex.fromXml(element);
              //print(md5.toString());
              if (md5 != null && md5.isValid()) {
                stockChanged = !StringUtils.equalsIgnoreCase(md5.md5stock, md5stock);
                brokerChanged = !StringUtils.equalsIgnoreCase(md5.md5broker, md5broker);
                indexChanged = !StringUtils.equalsIgnoreCase(md5.md5index, md5index);
              }
            });
          }
        }

        if (stocks == null) {
          DebugWriter.info('stocks NULL');
        } else if (stocks.isEmpty) {
          DebugWriter.info('stocks EMPTY');
        } else {
          // DebugWriter.info('stocks ada : '+stocks.join('|'));
          DebugWriter.info('stocks ada first.name : ' + stocks.first.name.toString());

          final allStocks = stocks.first.findElements('a');
          if (allStocks == null) {
            DebugWriter.info('allStocks NULL');
          } else if (allStocks.isEmpty) {
            DebugWriter.info('allStocks EMPTY');
          } else {
            DebugWriter.info('allStocks size : ' + allStocks.length.toString());
            allStocks.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              Stock stock = Stock.fromXml(element);
              //print(stock.toString());
              listStock.add(stock);
            });
          }
        }

        if (brokers == null) {
          DebugWriter.info('brokers NULL');
        } else if (brokers.isEmpty) {
          DebugWriter.info('brokers EMPTY');
        } else {
          // DebugWriter.info('brokers ada : '+brokers.join('|'));
          DebugWriter.info('brokers ada first.name : ' + brokers.first.name.toString());

          final allBrokers = brokers.first.findElements('a');
          if (allBrokers == null) {
            DebugWriter.info('allBrokers NULL');
          } else if (allBrokers.isEmpty) {
            DebugWriter.info('allBrokers EMPTY');
          } else {
            DebugWriter.info('allBrokers size : ' + allBrokers.length.toString());
            allBrokers.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              Broker broker = Broker.fromXml(element);
              //print(broker);
              listBroker.add(broker);
            });
          }
        }

        if (indexs == null) {
          DebugWriter.info('indexs NULL');
        } else if (indexs.isEmpty) {
          DebugWriter.info('indexs EMPTY');
        } else {
          // DebugWriter.info('indexs ada : '+indexs.join('|'));
          DebugWriter.info('indexs ada first.name : ' + indexs.first.name.toString());

          final allIndexs = indexs.first.findElements('a');
          if (allIndexs == null) {
            DebugWriter.info('allIndexs NULL');
          } else if (allIndexs.isEmpty) {
            DebugWriter.info('allIndexs EMPTY');
          } else {
            DebugWriter.info('allIndexs size : ' + allIndexs.length.toString());
            allIndexs.forEach((element) {
              // DebugWriter.info(element.getAttribute('code'));
              Index index = Index.fromXml(element);
              //print(index);
              listIndex.add(index);
            });
          }
        }

      } else {
        DebugWriter.info('XML data null');
      }
      DebugWriter.info('XML done');

      bool validBrokerChanged = brokerChanged && listBroker.isNotEmpty;
      bool validStockChanged = stockChanged && listStock.isNotEmpty;
      bool validIndexChanged = indexChanged && listIndex.isNotEmpty;

      DebugWriter.info('XML validBrokerChanged : $validBrokerChanged');
      DebugWriter.info('XML validStockChanged : $validStockChanged');
      DebugWriter.info('XML validIndexChanged : $validIndexChanged');

      maps['brokers'] = validBrokerChanged ? listBroker : null;
      maps['stocks'] = validStockChanged ? listStock : null;
      maps['indexs'] = validIndexChanged ? listIndex : null;

      maps['md5broker'] = validBrokerChanged ? md5broker : null;
      maps['md5stock'] = validStockChanged ? md5stock : null;
      maps['md5index'] = validIndexChanged ? md5index : null;

      maps['md5'] = md5;

      maps['validBrokerChanged'] = validBrokerChanged;
      maps['validStockChanged'] = validStockChanged;
      maps['validIndexChanged'] = validIndexChanged;

      return maps;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
      */
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  static Future<List<HomeNews>> fetchNews() async {
    //https://www.antaranews.com/rss/terkini.xml
    final response =
        await http.get(Uri.https('www.antaranews.com', 'rss/terkini.xml'));
    //print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //listWorldIndices.clear();
      DebugWriter.info(response.body);
      final XmlDocument? document = XmlDocument.parse(response.body);

      /*
    <item>
    <title>Apple akan hadirkan kembali platform media sosial Parler ke App Store</title>
    <link>https://www.antaranews.com/berita/2110802/apple-akan-hadirkan-kembali-platform-media-sosial-parler-ke-app-store</link>
    <pubDate>Tue, 20 Apr 2021 13:37:35 +0700</pubDate>
    <description>
    <![CDATA[ <img src="https://img.antaranews.com/cache/800x533/2021/02/17/2021-01-14T000000Z_1937767962_MT1SIPA0006PHF5M_RTRMADP_3_SIPA-USA.jpg" align="left" border="0">Apple Inc akan kembali menghadirkan aplikasi media sosial Parler, yang disukai oleh kaum konservatif di Amerika Serikat, di&nbsp;App Store setelah sempat ditarik menyusul kerusuhan Capitol yang mematikan pada 6 Januari ... ]]>
    </description>
    <guid isPermaLink="false">https://www.antaranews.com/berita/2110802/apple-akan-hadirkan-kembali-platform-media-sosial-parler-ke-app-store</guid>
    </item>
    */

      List<HomeNews> list = List<HomeNews>.empty(growable: true);
      if (document != null) {
        document.findAllElements('item').forEach((element) {
          HomeNews news = HomeNews.fromXml(element);
          list.add(news);
          DebugWriter.info(news.toString());
        });
      }
      DebugWriter.info('list.size : ' + list.length.toString());
      return list;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  static Future<List<HomeNews>>? fetchNewsPasarDana(String? code,
      {int lenght = 20}) async {
    //https://pasardana.id/rss?full=full&tag=AALI;BBCA&length=20

    var parameters = {
      //'full': 'full',
      'tag': code,
      'length': '$lenght',
      //'interval':'1',
    };

    DebugWriter.info(parameters);

    final response =
        await http.get(Uri.https('www.pasardana.id', 'rss', parameters));
    //print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      DebugWriter.info(response.body);
      final XmlDocument? document = XmlDocument.parse(response.body);

      /*
    <item>
      <title> Tekanan Jual Bayangi IHSG, Pilih Tujuh Saham Ini </title>
      <link>https://pasardana.id/news/2021/9/15/tekanan-jual-bayangi-ihsg-pilih-tujuh-saham-ini/</link>
      <guid isPermaLink="false"> https://pasardana.id/news/2021/9/15/tekanan-jual-bayangi-ihsg-pilih-tujuh-saham-ini/ </guid>
      <media:content url="https://pasardana.id/media/41084/bursa-saham-gabunganemiten1.jpg?crop=0,0,0.14250000000000004,0&cropmode=percentage&width=175&height=125&rnd=132762135520000000" medium="image" height="175" width="125"/>
      <description> &lt;p&gt;&lt;strong&gt;Pasardana.id - &lt;/strong&gt;Indeks Harga Saham Gabungan (IHSG) ditaksir akan mengalami tekanan jual pada perdagangan Kamis, 16 September 2021, setelah ditutup melemah 0,3 persen diperdagangan Rabu (15/9/2021) sore ini.&lt;/p&gt; &lt;p&gt;Menurut CEO Indosurya Bersinar Sekuritas, Wiliam Surya Wijaya, perkembangan pergerakan IHSG masih terlihat akan bergerak melemah.&lt;/p&gt; &lt;p&gt;“Hingga saat ini, IHSG terlihat masih berada dalam fase konsolidasi jangka panjang dikarenakan masih minimnya sentimen yang dapat mem-booster kenaikan IHSG,” papar William kepada media, Rabu (15/9/2021).&lt;/p&gt; &lt;p&gt;Sementara itu, lanjut dia, arus modal asing belum terlihat akan bertumbuh secara signifikan, hal ini cukup menjadi tantangan untuk dapat mendorong kenaikan IHSG.&lt;/p&gt; &lt;p&gt;“Besok (16/9), IHSG masih berpotensi terkonsolidasi,” kata dia.&lt;/p&gt; &lt;p&gt;Lebih lanjut ia menaksir, IHSG akan bergerak dari batas bawah di level 5.969 hingga batas atas pada level 6.202.&lt;/p&gt; &lt;p&gt;Adapun saham-saham yang dipatut dicermati, yakni; AALI, INDF, TLKM, ITMG, CTRA, WIKA, dan BMRI.&lt;/p&gt; &lt;p&gt; &lt;/p&gt; </description>
      <dc:creator>aziz</dc:creator>
      <pubDate>Wed, 15 Sep 2021 13:44:38 GMT</pubDate>
      <category>IHSG</category>
      <category>William Surja Wijaya</category>
      <category>AALI</category>
      <category>INDF</category>
      <category>TLKM</category>
      <category>ITMG</category>
      <category>CTRA</category>
      <category>WIKA</category>
      <category>BMRI</category>
    </item>
    */

      List<HomeNews> list = List<HomeNews>.empty(growable: true);
      if (document != null) {
        document.normalize();
        document.findAllElements('item').forEach((element) {
          HomeNews news = HomeNews.fromXmlPasarDana(element);
          list.add(news);
          DebugWriter.info(news.toString());
        });
      }
      DebugWriter.info('list.size : ' + list.length.toString());
      return list;

      // return document.findAllElements('a')
      //     .map((element) => new HomeWorldIndices.fromXml(element)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw HttpException('Error : '+response.statusCode.toString()+'  '+response.reasonPhrase);
      //throw Exception('Error : ' + response.statusCode.toString() + '  ' + response.reasonPhrase);
      throw Exception('Error : ' +
          response.statusCode.toString() /*+ '  ' + response.reasonPhrase */);
    }
  }

  // @override
  // bool updateShouldNotify(covariant InheritedWidget oldWidget) {
  //   return true;
  // }

//static ConnectionServices of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ConnectionServices>();
}

// class InvestrendCustomTheme {
//   //static Color textfield_labelTextColor(bool light) => light ? Colors.black : Colors.white;
//   static Color friends_bottom_container(bool light) => light ? Colors.white : Colors.black;
// }
