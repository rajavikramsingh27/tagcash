import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/theme_provider.dart';

class LoginInput extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final Widget suffix;
  final bool obscureText;
  final Iterable autofillHints;
  final VoidCallback onSubmitted;

  final TextEditingController controller;
  const LoginInput({
    Key key,
    this.icon,
    this.hintText,
    this.controller,
    this.suffix,
    this.obscureText,
    this.autofillHints,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      constraints: BoxConstraints(minHeight: 50.0, maxWidth: 360),
      padding: EdgeInsetsDirectional.only(start: 20, end: 10),
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context).isDarkMode
            ? Color(0xFF1A1A1A)
            : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 6),
            blurRadius: 12,
            color: Color(0xFF173347).withOpacity(0.23),
          ),
        ],
      ),
      child: TextField(
        // style: TextStyle(fontSize: 30),
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon),
          suffixIcon: suffix,
          border: InputBorder.none,
        ),
        autofillHints: autofillHints,
        onSubmitted: (value) => onSubmitted(),
      ),
    );
  }
}
