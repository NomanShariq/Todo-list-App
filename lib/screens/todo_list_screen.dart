import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_item_dialog.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<Map<String, dynamic>> _todoItems = [];
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String search = '';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/logo');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Load the to-do items from shared preferences
  void _loadTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoItems = prefs.getStringList('todoItems') ?? [];
    List<Map<String, dynamic>> items = [];
    for (String item in todoItems) {
      List<String> parts = item.split('||');
      if (parts.length == 3) {
        DateTime? date;
        if (parts[1].isNotEmpty) {
          date = DateTime.parse(parts[1]);
        }
        TimeOfDay? time;
        if (parts[2].isNotEmpty) {
          List<String> timeParts = parts[2].split(':');
          time = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
        items.add({
          'task': parts[0],
          'date': date,
          'time': time,
        });
      }
    }
    setState(() {
      _todoItems = items;
    });
  }

  // Save the to-do items to shared preferences
  void _saveTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> items = [];
    for (var item in _todoItems) {
      String task = item['task'];
      DateTime? date = item['date'];
      TimeOfDay? time = item['time'];

      String dateString = date != null ? date.toIso8601String() : '';
      String timeString = time != null ? '${time.hour}:${time.minute}' : '';

      String combined = '$task||$dateString||$timeString';
      items.add(combined);
    }
    await prefs.setStringList('todoItems', items);
  }

  // Add a new to-do item
  void _addTodoItem(
      String newTodoItem, DateTime? selectedDate, TimeOfDay? selectedTime) {
    bool hasNumbers = RegExp(r'\d').hasMatch(newTodoItem);
    if (hasNumbers) {
      // Display an error message or show a snackbar indicating that numbers are not allowed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Numbers are not allowed in the to-do task."),
        ),
      );
    }
    if (newTodoItem.isNotEmpty) {
      setState(() {
        _todoItems.add({
          'task': newTodoItem,
          'date': selectedDate,
          'time': selectedTime,
        });
      });
      _textFieldController.clear();
      _saveTodoItems();
      scheduleNotification(newTodoItem, selectedDate, selectedTime);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task has been added'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Input cannot be empty'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
        ),
      );
    }
  }

  // Schedule a notification
  Future<void> scheduleNotification(
      String title, DateTime? selectedDate, TimeOfDay? selectedTime) async {
    if (selectedDate != null && selectedTime != null) {
      DateTime scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (scheduledDateTime.isBefore(DateTime.now())) {
        // If the scheduled date and time have already passed, don't schedule the notification
        return;
      }

      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'channel_id', // Replace with your own channel ID
        'Channel Name', // Replace with your own channel name
        importance: Importance.high,
        priority: Priority.high,
      );
      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.schedule(
        0,
        title,
        'Please Complete YourTask Before Deadline',
        scheduledDateTime,
        platformChannelSpecifics,
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final format = DateFormat.jm(); // Format with AM/PM

    return format.format(dateTime);
  }

  // Edit a to-do item
  void _editTodoItem(int index) {
    _textFieldController.text = _todoItems[index]['task'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ToDoItemDialog(
          title: 'Edit Task',
          textFieldController: _textFieldController,
          onSave: (newTodoItem, selectedDate, selectedTime) {
            setState(() {
              _todoItems[index]['task'] = newTodoItem;
              _todoItems[index]['date'] = selectedDate;
              _todoItems[index]['time'] = selectedTime;
            });
            Navigator.pop(context);
            _saveTodoItems();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your task has been edited'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
              ),
            ); // Save the updated to-do items
          },
        );
      },
    );
  }

  // Remove a to-do item
  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    _saveTodoItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task has been deleted'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
      ),
    ); // Save the updated to-do items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'To-Do List',
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ToDoItemDialog(
                    title: 'Add Task',
                    textFieldController: _textFieldController,
                    onSave: (newTodoItem, selectedDate, selectedTime) {
                      _addTodoItem(newTodoItem, selectedDate, selectedTime);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _todoItems.isEmpty
          ? const Center(
              child: Text(
                "No To Do Task Added",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Raleway',
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (String value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      hintText: 'Search Task Here',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todoItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      String task = _todoItems[index]['task'];
                      DateTime? date = _todoItems[index]['date'];
                      TimeOfDay? time = _todoItems[index]['time'];

                      if (searchController.text.isEmpty ||
                          task
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            )),
                            child: ListTile(
                              title: Text(task,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  )),
                              subtitle: date != null
                                  ? Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                  text: 'Date: ',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: DateFormat.yMd()
                                                            .format(date)
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ))
                                                  ]),
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                  text: 'Time: ',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            '${time != null ? _formatTime(time) : ''}',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ))
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    color: Colors.green,
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editTodoItem(index);
                                    },
                                  ),
                                  IconButton(
                                    color: Colors.red,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _removeTodoItem(index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ToDoItemDialog(
                title: 'Add Task',
                textFieldController: _textFieldController,
                onSave: (newTodoItem, selectedDate, selectedTime) {
                  _addTodoItem(newTodoItem, selectedDate, selectedTime);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
