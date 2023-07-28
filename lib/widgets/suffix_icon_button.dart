import 'package:flutter/material.dart';

class PasswordToggleField extends StatefulWidget {
  final TextEditingController controller;
  bool isPasswordVisible;

  PasswordToggleField({
    required this.controller,
    required this.isPasswordVisible,
  });

  @override
  _PasswordToggleFieldState createState() => _PasswordToggleFieldState();
}

class _PasswordToggleFieldState extends State<PasswordToggleField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !widget.isPasswordVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(),
        ),
        hintText: 'Enter Your Password',
        prefixIcon: Icon(
          Icons.security,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              widget.isPasswordVisible = !widget.isPasswordVisible;
            });
          },
          child: Icon(
            widget.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
