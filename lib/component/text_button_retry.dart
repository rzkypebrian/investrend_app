import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TextButtonRetry extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  const TextButtonRetry({this.text, this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Text(
          text ?? 'button_retry'.tr(),
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Colors.red),
        ));
  }
}
