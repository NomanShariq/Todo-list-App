import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;

  const ErrorDialog({super.key, 
    required this.title,
    required this.content,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 16.0,
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    );
  }
}
