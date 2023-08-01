import 'package:cloud_firestore/cloud_firestore.dart';
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
bool shouldUseFirestoreEmulator = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(ToDoListApp());
}

class ToDoListApp extends StatefulWidget {
  @override
  State<ToDoListApp> createState() => _ToDoListAppState();
}

class _ToDoListAppState extends State<ToDoListApp> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final isUserLoggedIn =
              snapshot.connectionState == ConnectionState.active && snapshot.hasData;
          return 
          MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'To-Do List',
            themeMode: ThemeMode.system,
            theme: ThemeData(fontFamily: 'Raleway'),
            darkTheme: myThemes.darkTheme,
            home: isUserLoggedIn ? ToDoList() : LogInScreen(),
            routes: {
              loginRoute: (context) => const LogInScreen(),
              signUpRoute: (context) => const SignUpScreen(),
              homeScreenroute: (context) => const ToDoList(),
            },
          );
        });
  }
}
