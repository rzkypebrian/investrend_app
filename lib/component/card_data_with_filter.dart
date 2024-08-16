import 'package:Investrend/component/component_creator.dart';
import 'package:flutter/material.dart';

class CardDataWithFilter<T> extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final String? title;
  final List<CardDataWithFilterModel<T>>? data;

  CardDataWithFilter({
    this.margin,
    this.title,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: Colors.transparent,
      margin: margin,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ComponentCreator.subtitleNoButtonMore(
                context,
                title!,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.filter_alt_rounded),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CardDataWithFilterModel<T> {
  String name;
  bool isShown;
  T data;

  CardDataWithFilterModel({
    required this.name,
    this.isShown = true,
    required this.data,
  });
}
