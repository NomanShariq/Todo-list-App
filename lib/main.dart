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


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      themeMode: ThemeMode.system,
      theme: myThemes.lightTheme,
      darkTheme: myThemes.darkTheme,
      home: ToDoList(),
    );
  }
}
