import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToDoItemDialog extends StatefulWidget {
  final String title;
  final TextEditingController textFieldController;
  final Function(String, DateTime?, TimeOfDay?) onSave;
final DateTime? initialDate; // Add this line
  final TimeOfDay? initialTime;
  const ToDoItemDialog({
    Key? key,
    required this.title,
    required this.textFieldController,
    required this.onSave,
    this.initialDate,
    this.initialTime, 
  }) : super(key: key);

  @override
  State<ToDoItemDialog> createState() => _ToDoItemDialogState();
}

class _ToDoItemDialogState extends State<ToDoItemDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay timeOfDay = TimeOfDay.now();
  DateTime? _previousSelectedDate;
  TimeOfDay? _previousSelectedTime;

  @override
  void initState() {
    super.initState();

    // Set the initial values if provided
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate;
    }

    if (widget.initialTime != null) {
      _selectedTime = widget.initialTime;
    }
  }

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
      setState(() {
        _selectedDate = pickedDate;
        _previousSelectedDate = pickedDate;
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
        _previousSelectedTime = pickedTime;
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
          labelText: 'Add Task here',
          //lable style
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontFamily: "verdana_regular",
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.add_task),
        ),
      ),
      actions: <Widget>[
        Stack(
          children: [
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
                        if (_selectedTime == null) {
                          _presentTimePicker();
                        } else {
                          _presentTimePicker();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      child: _selectedTime == null
                          ? const Text(
                              "Choose Time",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.edit), // Replace with edit icon
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
                        if (_selectedDate == null || _selectedTime == null) {
                          presentDatePicker();
                        } else {
                          presentDatePicker();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      child: _selectedDate == null
                          ? const Text(
                              "Choose Date",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.edit), // Replace with edit icon
                    ),
                  ],
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
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).brightness == Brightness.light
                      ? Colors
                          .black // Set the text color to black for light theme
                      : Colors
                          .white, // Set the text color to white for dark theme
                ),
              ),
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
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).brightness == Brightness.light
                      ? Colors
                          .black // Set the text color to black for light theme
                      : Colors
                          .white, // Set the text color to white for dark theme
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
