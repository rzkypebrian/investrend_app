import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class DropdownForm extends StatefulWidget {
  //final _valueNotifier = ValueNotifier('');
  String label = '';
  String hint = '';
  String validatorErrorText = '';

  String value = '';
  bool validatorError = true;
  List<String> list = [];
  ValueChanged<String> onChanged;
  UniqueKey keyDropdown = UniqueKey();

  @override
  _DropdownFormState createState() => _DropdownFormState();

  DropdownForm(
      this.label, this.hint, this.validatorErrorText, this.list, this.onChanged,
      {Key key}
      //{this.validatorError: false}
      );
}

class _DropdownFormState extends State<DropdownForm> {
  @override
  Widget build(BuildContext context) {
    // bool lightTheme =
    //     MediaQuery.of(context).platformBrightness == Brightness.light;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.caption.copyWith(
                    //  color: InvestrendCustomTheme.textfield_labelTextColor(lightTheme),
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontSize: 12.6,
                    //wordSpacing: 1.1
                  ),

              // style: TextStyle(
              //     color: InvestrendCustomTheme.textfield_labelTextColor(
              //         lightTheme)),
            ),
            SizedBox(
              height: 2.0,
            ),
            DropdownButton<String>(
              //style: TextStyle(color: Colors.gr),
              //value: 'Pilih Kota',
              key: widget.keyDropdown,
              hint: Text(widget.hint),
              //style: Theme.of(context).textTheme.bodyText2.copyWith(height: 1.5),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.transparent,
              ),
              iconSize: 24,
              elevation: 16,
              isDense: true,

              value: StringUtils.isEmtpy(widget.value) ? null : widget.value,
              //style: const TextStyle(color: Colors.deepPurple),
              underline: SizedBox(
                height: 0,
              ),
              //onChanged: widget.onChanged,
              onChanged: (newValue) {
                //widget.value = newValue;
                widget.value = newValue;
                //myFocusNode.requestFocus();
                setState(() {});
                //widget.onChanged(newValue);
              },
              items: widget.list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              height: 2.0,
            ),
            Container(
              width: double.maxFinite,
              height: 1.0,
              color: Colors.grey,
            ),
            Text(
              widget.validatorErrorText,
              style: Theme.of(context).textTheme.caption.copyWith(
                  color:
                      widget.validatorError ? Colors.red : Colors.transparent),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              )),
        ),
      ],
    );
  }
}
