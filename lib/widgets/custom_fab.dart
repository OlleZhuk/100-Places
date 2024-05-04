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
    final cScheme = Theme.of(context).colorScheme;

    return FilledButton.tonalIcon(
      label: Text(labelText),
      style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          backgroundColor: cScheme.onPrimary.withOpacity(0.75),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          )),
      icon: Icon(
        buttonIcon,
        color: cScheme.primary,
        size: 30,
      ),
      onPressed: action,
    );
  }
}
