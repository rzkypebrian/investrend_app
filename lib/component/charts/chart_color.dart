/*
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:charts_common/src/common/palette.dart';
import 'package:charts_common/src/common/color.dart' as chart;
import 'package:flutter/material.dart' as material;

class ChartColor extends Palette {

  ChartColor(material.Color color){

    material.Color color200 = InvestrendTheme.lightenColor(color, 0.2);
    material.Color color500 = color;
    material.Color color700 = InvestrendTheme.darkenColor(color, 0.2);


    _shade200 = chart.Color(r: color200.red, g: color200.green, b: color200.blue);
    _shade700 = chart.Color(r: color700.red, g: color700.green, b: color700.blue);


    _shade500 = chart.Color(r: color500.red, g: color500.green, b: color500.blue, darker: _shade700, lighter: _shade200);

  }
  chart.Color _shade200;// = Color(r: 0x90, g: 0xCA, b: 0xF9); //#90CAF9
  chart.Color _shade500;// = Color(r: 0x21, g: 0x96, b: 0xF3, darker: _shade700, lighter: _shade200);
  chart.Color _shade700;// = Color(r: 0x19, g: 0x76, b: 0xD2); //#1976D2



  @override
  chart.Color get shadeDefault => _shade500;
}



class ChartColorPurple extends Palette {
  //#5414DB
  static const _shade200 = chart.Color(r: 0xdd, g: 0xd0, b: 0xF8); //#ddd0f8
  static const _shade500 = chart.Color(r: 0x54, g: 0x14, b: 0xDB, darker: _shade700, lighter: _shade200); // aa8aed
  static const _shade700 = chart.Color(r: 0x76, g: 0x43, b: 0xe2); //#7643e2

  const ChartColorPurple();

  @override
  chart.Color get shadeDefault => _shade500;
}
*/