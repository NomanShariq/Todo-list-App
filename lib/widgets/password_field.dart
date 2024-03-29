import 'package:flutter/material.dart';

class PasswordToggleField extends StatefulWidget {
  final TextEditingController controller;
  bool isPasswordVisible;

  PasswordToggleField({
    super.key,
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
      textInputAction: TextInputAction.done,
      controller: widget.controller,
      obscureText: !widget.isPasswordVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(),
        ),
        labelText: 'Enter Your Password',
        //lable style
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontFamily: "verdana_regular",
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(
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
