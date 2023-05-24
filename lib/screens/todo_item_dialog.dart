import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToDoItemDialog extends StatefulWidget {
  final String title;
  final TextEditingController textFieldController;
  final Function(String, DateTime?, TimeOfDay?) onSave;

  const ToDoItemDialog({
    Key? key,
    required this.title,
    required this.textFieldController,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ToDoItemDialog> createState() => _ToDoItemDialogState();
}

class _ToDoItemDialogState extends State<ToDoItemDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay timeOfDay = TimeOfDay.now();

  
  void presentDatePicker() {
    // Show a date picker dialog.
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      // If the user cancels the dialog, return.
      if (pickedDate == null) {
        return;
      }

      // Update the _selectedDate state variable.
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: timeOfDay,
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }

  String _formatSelectedTime() {
    if (_selectedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final formattedTime = DateFormat.jms().format(selectedDateTime);
      return formattedTime;
    }
    return 'No Time Chosen';
  }

  String? _validateTextField(String? value) {
    if (value == null || value.isEmpty) {
      return 'The Field Cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextFormField(
        controller: widget.textFieldController,
        validator: _validateTextField,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(),
          ),
          hintText: 'Add Task Here',
          prefixIcon: Icon(Icons.add_task),
        ),
      ),
      actions: <Widget>[
        Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 15.0,
                ),
                Text(
                  _selectedTime == null
                      ? 'No Time Chosen'
                      : 'Time Picked ${_formatSelectedTime()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    _presentTimePicker();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text(
                    "Choose Time",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  height: 35.0,
                ),
                const SizedBox(
                  width: 15.0,
                ),
                Text(
                  _selectedDate == null
                      ? 'No Date Chosen'
                      : 'Date Picked ${DateFormat.yMd().format(_selectedDate!).trimRight()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 23.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    presentDatePicker();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text(
                    "Choose Date",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                String todoItem = widget.textFieldController.text;
                widget.onSave(todoItem, _selectedDate, _selectedTime);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
