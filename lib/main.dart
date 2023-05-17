import 'package:flutter/material.dart';
import 'model/theme.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(ToDoListApp());
}

class ToDoListApp extends StatefulWidget {
  @override
  State<ToDoListApp> createState() => _ToDoListAppState();
}

class _ToDoListAppState extends State<ToDoListApp> {
  AppTheme _currentTheme = AppTheme.Light;

  void _toggleTheme() {
    setState(() {
      _currentTheme = _currentTheme == AppTheme.Light ? AppTheme.Dark : AppTheme.Light;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: _currentTheme == AppTheme.Light ? lightTheme : darkTheme,
      home: ToDoList(),
    );
  }
}
