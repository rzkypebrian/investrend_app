import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/material.dart';

class FormatTextBullet extends StatelessWidget {
  final String text;
  TextStyle style;
  FormatTextBullet(this.text, {this.style, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return formattedWidget(context, text);
  }

  Widget formattedWidget(BuildContext context, String text) {
    if (StringUtils.isEmtpy(text)) {
      return SizedBox(
        width: 1.0,
      );
    }
    List<Widget> list = List.empty(growable: true);

    String lastBullet = '';
    List<String> lines = text.split('\n');
    lines.forEach((line) {
      if (line.startsWith('• ')) {
        line = line.replaceFirst('• ', '');
        list.add(bulletOrLine(context, '•', line));
        lastBullet = '•';
      } else if (line.startsWith('   ')) {
        line = line.replaceFirst('   ', '');
        if (StringUtils.isEmtpy(lastBullet)) {
          list.add(Text(line,
              style: style ??= Theme.of(context).textTheme.bodyText2));
        } else {
          list.add(
              bulletOrLine(context, lastBullet, line, showBulletLine: false));
        }
      } else {
        bool marked = false;
        String marker = '. ';
        int index = line.indexOf(marker);
        if (index > 0 && index <= 4) {
          int no = Utils.safeInt(line.substring(0, index), defaultNo: -1);
          if (no >= 0) {
            line = line.substring(index + marker.length);
            list.add(bulletOrLine(context, '$no.', line));
            marked = true;
            lastBullet = '$no.';
          }
        }
        if (!marked) {
          list.add(Text(line,
              style: style ??= Theme.of(context).textTheme.bodyText2));
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget bulletOrLine(BuildContext context, String bulletLine, String text,
      {bool showBulletLine = true}) {
    TextStyle bulletStyle = style ??= Theme.of(context).textTheme.bodyText2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.0,
          child: Text(
            bulletLine,
            style: showBulletLine
                ? bulletStyle
                : bulletStyle.copyWith(color: Colors.transparent),
          ),
        ),
        // SizedBox(
        //   width: 5.0,
        // ),
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: style ??= Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ],
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;
  TextStyle style;
  BulletText(this.text, {this.style, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: style ??= Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(
          width: 5.0,
        ),
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: style ??= Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ],
    );
  }
}
