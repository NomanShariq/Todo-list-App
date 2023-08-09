import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/constants/routes.dart';
import '../widgets/todo_item_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = false;

  String userEmail = '';

  @override
  void initState() {
    _updateUserEmail();
    super.initState();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/logo');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _loadTodoItems();
  }

  // Getting username fromemail
  Future<void> _updateUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String name = user.displayName ?? '';
      String email = user.email ?? '';

      // If the name is not provided, try to extract it from the email
      if (name.isEmpty) {
        List<String> nameParts = email.split('@');
        if (nameParts.length == 2) {
          name = nameParts[0];
          // Extract only alphabetic characters from the name
          name = name.replaceAll(RegExp(r'[^a-zA-Z]'), '');
          // Capitalize the first letter of the name (optional)
          name = name[0].toUpperCase() + name.substring(1);
        }
      }

      setState(() {
        userEmail = name;
      });
    } else {
      setState(() {
        userEmail = '';
      });
    }
  }

  // Loading tasks
  void _loadTodoItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference tasksCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks');

      List<Map<String, dynamic>> items = [];
      await tasksCollection.get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          String task = doc['task'];

          // Parse the 'date' field
          DateTime? date;
          try {
            date = doc['date'] != null ? DateTime.parse(doc['date']) : null;
          } catch (e) {
            date = null;
          }
          TimeOfDay? time;
          try {
            if (doc['time'] != null) {
              List<String> timeParts = doc['time'].split(':');
              int hour = int.parse(timeParts[0]);
              int minute = int.parse(timeParts[1]);
              time = TimeOfDay(hour: hour, minute: minute);
            }
          } catch (e) {
            time = null;
          }

          items.add({
            'task': task,
            'date': date,
            'time': time,
          });
        }
      });

      setState(() {
        _todoItems = items;
      });
    }
  }

  // Trying to save the task into firebase
  void _saveTodoItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference tasksCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks');

      await tasksCollection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      for (var item in _todoItems) {
        String task = item['task'];
        DateTime? date = item['date'];
        TimeOfDay? time = item['time'];

        String? timeString;
        if (time != null) {
          timeString = '${time.hour}:${time.minute}';
        }

        tasksCollection.add({
          'task': task,
          'date': date != null ? date.toIso8601String() : null,
          'time': timeString,
        });
      }
    }
  }

  // Add a new to-do item
  void _addTodoItem(
      String newTodoItem, DateTime? selectedDate, TimeOfDay? selectedTime) {
    // Check for numbers in the task name
    bool hasNumbers = RegExp(r'\d').hasMatch(newTodoItem);
    if (hasNumbers) {
      // Display an error message or show a snackbar indicating that numbers are not allowed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Numbers are not allowed in the to-do task."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 10, right: 10),
        ),
      );
      return;
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
      _saveTodoItems(); // Save the task to Firestore

      // Schedule the notification
      scheduleNotification(newTodoItem, selectedDate, selectedTime);

      // Show a success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task has been added'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 10, right: 10),
        ),
      );
    } else {
      // Show a snackbar if the input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Input cannot be empty'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 10, right: 10),
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
        'Please Complete Your Task Before Deadline',
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
    TextEditingController editTextFieldController =
        TextEditingController(text: _todoItems[index]['task']);
    DateTime? existingDate = _todoItems[index]['date'];
    TimeOfDay? existingTime = _todoItems[index]['time'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ToDoItemDialog(
          title: 'Edit Task',
          textFieldController: editTextFieldController,
          initialDate: existingDate,
          initialTime: existingTime,
          onSave: (newTodoItem, selectedDate, selectedTime) {
            // Check if the newTodoItem contains numbers and perform validation...

            setState(() {
              _todoItems[index]['task'] = newTodoItem;
              _todoItems[index]['date'] = selectedDate;
              _todoItems[index]['time'] = selectedTime;
            });
            Navigator.pop(context);
            _saveTodoItems(); // Save the updated task to Firestore

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your task has been edited'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(left: 10, right: 10),
              ),
            );
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

  // Logout user function
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
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
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Deleting task dialog
  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _removeTodoItem(index);
                Navigator.pop(context); // Close the dialog after deleting
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome,',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              userEmail.isNotEmpty
                  ? userEmail
                  : 'Guest', // Show 'Guest' if userEmail is empty
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
            icon: const Icon(
              Icons.add,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () async {
                _showLogoutConfirmationDialog();
              },
              child: const Icon(
                Icons.more_vert,
                size: 26.0,
              ),
            ),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Search Task Here',
                      //lable style
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: "verdana_regular",
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
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
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors.grey
                                                            : Colors.white,
                                                      ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: DateFormat.yMd()
                                                          .format(date)
                                                          .toString(),
                                                    )
                                                  ]),
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                  text: 'Time: ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors.grey
                                                            : Colors.white,
                                                      ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text:
                                                          '${time != null ? _formatTime(time) : ''}',
                                                    ),
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
                                      _showDeleteConfirmationDialog(
                                          context, index);
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
