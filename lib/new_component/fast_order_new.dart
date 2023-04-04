import 'package:Investrend/input_component.dart';
import 'package:flutter/material.dart';

class FastOrderNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FastOrderNewState();
}

class _FastOrderNewState extends State<FastOrderNew> {
  String title = 'Horizontal List';
  TextEditingController controller;
  Key fieldKey;
  double fontSize;
  BuildContext context;
  TextAlign textAlign;
  FocusNode focusNode;
  FocusNode nextFocusNode;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: body(),
      ),
    );
  }

  Widget body() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 20, bottom: 20),
        height: 600,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10, right: 20),
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lot'),
                  InputComponent.inputTextWithUnderLine(
                    underLineColor: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              width: 160.0,
              color: Colors.blue,
            ),
            Container(
              width: 160.0,
              color: Colors.green,
            ),
            Container(
              width: 160.0,
              color: Colors.yellow,
            ),
            Container(
              width: 160.0,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
