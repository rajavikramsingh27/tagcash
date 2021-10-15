import 'package:flutter/material.dart';

class SearchAndAddFloatingButton extends StatelessWidget {
  Function onSeachAddClick;
  IconData icon;
  SearchAndAddFloatingButton(this.onSeachAddClick, this.icon);
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        onSeachAddClick();
      },
      //tooltip: 'Increment',
      child: Icon(icon),
      backgroundColor: Colors.red,
    );
  }
}
