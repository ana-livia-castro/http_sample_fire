import 'package:flutter/material.dart';

class MessageDialogWidget extends StatelessWidget {
  const MessageDialogWidget({
    super.key,
    required this.isError,
    required this.messageTitle,
    required this.messageBody,
    required this.messageAction,
  });

  final bool isError;
  final String messageTitle;
  final String messageBody;
  final String messageAction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      icon: isError
          ? const Icon(Icons.error_outline_outlined)
          : const Icon(Icons.person_2_outlined),
      iconColor: isError ? Colors.red.shade500 : Colors.green.shade500,
      title: Text(messageTitle),
      content: Text(messageBody),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          )),
          child: Text(messageAction),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
