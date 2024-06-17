/// Кнопка
library;

import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({
    super.key,
    required this.labelText,
    required this.buttonIcon,
    required this.action,
  });

  final String labelText;
  final IconData buttonIcon;
  final void Function() action;

  @override
  Widget build(BuildContext context) {
    final double deviceSize = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: deviceSize * .9,
      child: FilledButton.tonalIcon(
        label: Text(labelText),
        icon: Icon(buttonIcon),
        onPressed: action,
      ),
    );
  }
}
