import 'package:flutter/material.dart';

class ToDoItemDialog extends StatelessWidget {
  final String title;
  final TextEditingController textFieldController;
  final Function(String) onSave;

  const ToDoItemDialog({
    required this.title,
    required this.textFieldController,
    required this.onSave,
  });

  String? _validateTextField(String? value) {
    if (value == null || value.isEmpty) {
      return 'The Field Cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextFormField(
        controller: textFieldController,
        validator: _validateTextField,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog without saving
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            String todoItem = textFieldController.text;
            onSave(todoItem);
            // Call the onSave callback with the entered text
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
