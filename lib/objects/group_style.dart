import 'package:flutter/material.dart';

class GroupStyle {
  TextStyle? _style_1;
  TextStyle? _style_2;
  TextStyle? _style_3;
  TextStyle? _style_4;
  TextStyle? _style_5;

  set style_1(TextStyle value) {
    _style_1 = value;
  }

  set style_2(TextStyle? value) {
    _style_2 = value;
  }

  set style_5(TextStyle value) {
    _style_5 = value;
  }

  set style_4(TextStyle value) {
    _style_4 = value;
  }

  set style_3(TextStyle value) {
    _style_3 = value;
  }

  TextStyle get style_5 => _style_5!;

  TextStyle get style_4 => _style_4!;

  TextStyle get style_3 => _style_3!;

  TextStyle get style_2 => _style_2!;

  TextStyle get style_1 => _style_1!;

  void reset() {
    _style_1 = null;
    _style_2 = null;
    _style_3 = null;
    _style_4 = null;
    _style_5 = null;
  }
}
