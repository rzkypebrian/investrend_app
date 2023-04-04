import 'package:Investrend/objects/iii_objects.dart';

typedef StringCallback = String Function(String);
typedef IntCallback = int Function(int);
typedef DoubleCallback = double Function(double);
typedef RangeCallback = Function(int, String, String);
typedef StockCallback = Function(Stock newStock);
typedef BoolCallback = bool Function(String);
typedef ListStringCallback = String Function(List<String>);