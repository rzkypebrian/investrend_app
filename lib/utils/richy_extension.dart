import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

extension DateExtension on DateTime {
  static String nowAsString() {
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
  }
}

extension ImageExtension on Image {
  networkLoader(
    String src, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Center(child: CircularProgressIndicator());
        // You can use LinearProgressIndicator or CircularProgressIndicator instead
      },
      errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      )),
    );
  }
}

extension StringExtension on String {
  String? between(String tagStart, String tagEnd) {
    int indexStart = indexOf(tagStart, 0);
    if (indexStart != -1) {
      indexStart = indexStart + tagStart.length;
      int indexEnd = indexOf(tagEnd, indexStart);
      if (indexEnd != -1) {
        return substring(indexEnd, indexEnd);
      }
    }
    return '';
  }
}
