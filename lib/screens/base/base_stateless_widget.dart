import 'package:flutter/material.dart';

class BaseStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: createBody(context),

    );
  }
  Widget createBody(BuildContext context){
    return Container(
      child: Text('Base Body'),
    );
  }
  Widget createAppBar(BuildContext context){
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }

}

