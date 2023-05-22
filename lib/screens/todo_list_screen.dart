import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo_item_dialog.dart';

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<Map<String, dynamic>> _todoItems = [];
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String search = '';

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  // Load the to-do items from shared preferences
  void _loadTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoItems = prefs.getStringList('todoItems') ?? [];
    List<Map<String, dynamic>> items = [];
    for (String item in todoItems) {
      items.add({'task': item, 'date': null});
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
      items.add(item['task']);
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
                backgroundColor: Colors.red,
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
                                                        text: date.toString(),
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
                                                            '${time!.format(context)}',
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
