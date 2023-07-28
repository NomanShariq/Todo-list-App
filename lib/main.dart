import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_list_app/constants/routes.dart';
import 'package:todo_list_app/screens/login_screen.dart';
import 'package:todo_list_app/screens/signup_screen.dart';
import 'firebase_options.dart';
import 'model/theme.dart';
import 'screens/todo_list_screen.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

late final FirebaseApp app;
late final FirebaseAuth auth;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      theme: ThemeData(fontFamily: 'Raleway'),
      darkTheme: myThemes.darkTheme,
      home: const ToDoList(),
      routes: {
        loginRoute: (context) => const LogInScreen(),
        signUpRoute: (context) => const SignUpScreen(),
        homeScreenroute: (context) => const ToDoList(),
      },
    );
  }
}
