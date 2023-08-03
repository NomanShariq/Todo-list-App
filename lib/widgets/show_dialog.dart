import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/routes.dart';

class ShowDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback button;

  const ShowDialog({
    super.key,
    required this.title,
    required this.content,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () async {
            button;
          },
        ),
      ],
    );
  }
}
