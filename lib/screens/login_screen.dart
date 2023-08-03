import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/constants/routes.dart';

import '../widgets/error_dialog.dart';
import '../widgets/suffix_icon_button.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  'LogIn',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    labelText: 'Enter Your Email',
                    //lable style
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: "verdana_regular",
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                PasswordToggleField(
                  controller: _password,
                  isPasswordVisible: _isPasswordVisible,
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      final credential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: password);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        homeScreenroute,
                        (route) => false,
                      );
                    } catch (e) {
                      String errorMessage = 'An error occurred during login';
                      if (e is FirebaseAuthException) {
                        if (e.code == 'user-not-found') {
                          errorMessage = 'No user found for that email.';
                        } else if (e.code == 'wrong-password') {
                          errorMessage = 'Invalid Credentials.';
                        } else {
                          errorMessage = 'Error during login: ${e.message}';
                        }
                      } else {
                        errorMessage = 'Unexpected error during login: $e';
                      }
                      showDialog(
                        context: context,
                        builder: (context) => ErrorDialog(
                          title: 'Login Error',
                          content: errorMessage,
                          buttonText: 'OK',
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      const Size(130, 50),
                    ),
                  ),
                  child: const Text(
                    'LogIn',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'not Register yet?',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          signUpRoute,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Register Now',
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
