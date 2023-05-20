import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo_item_dialog.dart';

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<String> _todoItems = [];
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
    setState(() {
      _todoItems = todoItems;
    });
  }

  // Save the to-do items to shared preferences
  void _saveTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todoItems', _todoItems);
  }

  // Add a new to-do item
  void _addTodoItem() {
    String todoItem = _textFieldController.text;
    bool hasNumbers = RegExp(r'\d').hasMatch(todoItem);
    if (hasNumbers) {
      // Display an error message or show a snackbar indicating that numbers are not allowed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Numbers are not allowed in the to-do task."),
        ),
      );
    }
    if (todoItem.isNotEmpty) {
      setState(() {
        _todoItems.add(todoItem);
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
    _textFieldController.text = _todoItems[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ToDoItemDialog(
          title: 'Edit Task',
          textFieldController: _textFieldController,
          onSave: (newTodoItem) {
            _todoItems[index] = newTodoItem;
            setState(() {});
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
          style: TextStyle(fontFamily: 'Raleway'),
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
                    onSave: (newTodoItem) {
                      _addTodoItem();
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
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (String? value) {
                      print(value);
                      setState(() {
                        search = value.toString();
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
                      late String position = _todoItems[index].toString();
                      if (searchController.text.isEmpty) {
                        return ListTile(
                          title: Text(_todoItems[index]),
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
                        );
                      } else if (position
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase())) {
                        return ListTile(
                          title: Text(_todoItems[index]),
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
                onSave: (newTodoItem) {
                  _addTodoItem();
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
