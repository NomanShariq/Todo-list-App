import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'model/theme.dart';
import 'screens/todo_list_screen.dart';
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() {
    WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification plugin
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);
  notificationsPlugin.initialize(initializationSettings);
  runApp(
    ToDoListApp());
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
      theme: ThemeData(fontFamily: 'Raleway'),
      darkTheme: myThemes.darkTheme,
      home: ToDoList(),
    );
  }
}
