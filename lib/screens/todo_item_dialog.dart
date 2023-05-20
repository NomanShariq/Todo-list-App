import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToDoItemDialog extends StatelessWidget {
  final String title;
  final TextEditingController textFieldController;
  final Function(String) onSave;

  const ToDoItemDialog({
    super.key,
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
    DateTime? _selectedDate;

    return AlertDialog(
      title: Text(title),
      content: TextFormField(
        controller: textFieldController,
        validator: _validateTextField,
      ),
      actions: <Widget>[
        Row(children: <Widget>[
          const SizedBox(
            width: 15.0,
          ),
          Text(
            _selectedDate == null
                ? 'No Date Choosen'
                : 'Date Picked ${DateFormat.yMd().format(_selectedDate)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 20.0,
          ),
          ElevatedButton(
            onPressed: () {
              // _presentDatePicker();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: const Text(
              "Choose Date",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(
              width: 10.0,
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
        )
      ],
    );
  }
}
