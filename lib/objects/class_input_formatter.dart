import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/services.dart';

class PriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    String scrapped = newValue.text.replaceAll(',', '');
    int srappedInt = Utils.safeInt(scrapped);
    String price = InvestrendTheme.formatPrice(srappedInt);
    int gap = price.length - newValue.text.length;
    if(newValue.text.isEmpty ){
      gap = 0;
      price = '';
    }
    return TextEditingValue(text: price, selection:  TextSelection.collapsed(offset: newValue.selection.baseOffset + gap));
  }
}
