import 'package:flutter/material.dart';

class SwipeComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SwipeComponentState();
}

class _SwipeComponentState extends State<SwipeComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe Test'),
      ),
      body: Container(
        height: 200,
        color: Colors.blue,
      ),
    );
  }
}
