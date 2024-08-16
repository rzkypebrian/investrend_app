import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ErrorHandlingUtil {
  static handleApiError(
    dynamic error, {
    String prefix = "",
    String? onTimeOut = "",
  }) {
    String _message;
    try {
      http.Response response = error;
      _message =
          "$prefix ${response.body.isNotEmpty ? response.body : response.statusCode}";
    } catch (e) {
      _message = "$prefix $error";
      if (onTimeOut != null && onTimeOut != "") {
        _message = "$prefix $onTimeOut";
      }
    }
    debugPrint("error $prefix $_message");
    return _message;
  }

  static String readMessage(http.Response response) {
    try {
      return json.decode(response.body)["Message"].toString() == ""
          ? defaultMessage(response)
          : json.decode(response.body)["Message"].toString();
    } catch (e) {
      return defaultMessage(response);
    }
  }

  static String defaultMessage(http.Response response) {
    return "${response.body.isNotEmpty ? response.body : response.statusCode}";
  }
}
