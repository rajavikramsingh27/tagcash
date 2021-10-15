import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const CustomButton({Key key, this.label, this.color, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      color: color ?? Color(0xFFe44933),
      disabledColor: color ?? Color(0xFFe44933).withOpacity(.6),
      textColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Text(
        label,
        style:
            Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
