/// Меню диалога
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConfirmAlert extends StatelessWidget {
  const ConfirmAlert({
    super.key,
    required this.question,
    required this.event,
  });

  final String question;
  final void Function() event;

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(question),
      titleTextStyle: TextStyle(
        color: cScheme.primary,
        fontSize: 20,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      backgroundColor: cScheme.surfaceVariant.withOpacity(.6),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.only(bottom: 24),
      actions: [
        //> Нет
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("О, нет!"),
        ),
        //> Да
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cScheme.errorContainer,
            foregroundColor: cScheme.primary,
          ),
          onPressed: event,
          child: const Text("Да"),
        )
      ],
    )
        .animate()
        .fadeIn(
          duration: 800.ms,
        )
        .scale(
          curve: Curves.easeOutBack,
        );
  }
}

/// -----------------------------------------
class WarningAlert extends StatelessWidget {
  const WarningAlert({
    super.key,
    required this.warningText,
    required this.actionOK,
  });

  final String warningText;
  final void Function() actionOK;

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(warningText),
      titleTextStyle: TextStyle(
        color: cScheme.primary,
        fontSize: 20,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      backgroundColor: cScheme.surfaceVariant.withOpacity(.6),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.only(bottom: 24),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cScheme.errorContainer,
            foregroundColor: cScheme.primary,
          ),
          onPressed: actionOK,
          child: const Text("ОК"),
        )
      ],
    )
        .animate()
        .fadeIn(
          duration: 800.ms,
        )
        .scale(
          curve: Curves.easeOutBack,
        );
  }
}
