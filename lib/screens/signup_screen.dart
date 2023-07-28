import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/widgets/error_dialog.dart';

import '../constants/routes.dart';
import '../widgets/suffix_icon_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formkey = GlobalKey();
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
      key: _formkey,
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SignUp',
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      hintText: 'Enter Your Username',
                      prefixIcon: Icon(
                        Icons.people,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
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
                      hintText: 'Enter Your Email',
                      prefixIcon: Icon(
                        Icons.email,
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
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        User? user = FirebaseAuth.instance.currentUser;

                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (route) => false,
                        );
                      } catch (e) {
                        // Show error using the ErrorDialog widget
                        String errorMessage =
                            'An error occurred during sign-up';
                        if (e is FirebaseAuthException) {
                          if (e.code == 'weak-password') {
                            errorMessage = 'The password provided is too weak.';
                          } else if (e.code == 'email-already-in-use') {
                            errorMessage =
                                'The email address is already in use by another account.';
                          } else {
                            errorMessage = 'Error during sign-up: ${e.message}';
                          }
                        } else {
                          errorMessage = 'Unexpected error during sign-up: $e';
                        }

                        showDialog(
                          context: context,
                          builder: (context) => ErrorDialog(
                            title: 'Sign-up Error',
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
                      'SignUp',
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            loginRoute,
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Login',
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
