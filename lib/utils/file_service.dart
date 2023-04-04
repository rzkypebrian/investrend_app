import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

typedef OnUploadProgressCallback = void Function(int sentBytes, int totalBytes);

class FileServiceUtil {
  // static String baseUrl = ;
  static Future<String> fileUploadMultipart({
    @required File file,
    @required String url,
    String field,
    Map<String, dynamic> header,
    OnUploadProgressCallback onUploadProgress,
  }) async {
    assert(file != null);

    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    final request = await httpClient.postUrl(
      Uri.parse(url),
    );

    int byteCount = 0;

    var multipart =
        await http.MultipartFile.fromPath(field ?? "media", file.path);

    var requestMultipart = http.MultipartRequest(
      "POST",
      Uri.parse("uri"),
    );

    requestMultipart.files.add(multipart);

    var msStream = requestMultipart.finalize();

    var totalByteLength = requestMultipart.contentLength;

    request.contentLength = totalByteLength;

    request.headers.set(HttpHeaders.contentTypeHeader,
        requestMultipart.headers[HttpHeaders.contentTypeHeader]);

    header?.forEach((key, value) {
      request.headers.set(key, value);
    });

    Stream<List<int>> streamUpload = msStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);

          byteCount += data.length;

          if (onUploadProgress != null) {
            onUploadProgress(byteCount, totalByteLength);
            // CALL STATUS CALLBACK;
          }
        },
        handleError: (error, stack, sink) {
          throw error;
        },
        handleDone: (sink) {
          sink.close();
          // UPLOAD DONE;
        },
      ),
    );

    await request.addStream(streamUpload);

    final httpResponse = await request.close();
//
    var statusCode = httpResponse.statusCode;

    if (statusCode ~/ 100 != 2) {
      throw Exception(
          'Error uploading file, Status code: ${httpResponse.statusCode}');
    } else {
      return await readResponseAsString(httpResponse);
    }
  }

  static Future<String> readResponseAsString(HttpClientResponse response) {
    var completer = Completer<String>();
    var contents = StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }
}
