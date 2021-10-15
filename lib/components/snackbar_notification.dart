

import 'package:flutter/material.dart';

class SnackbarNotification {
  static show(GlobalKey<ScaffoldState> scaffoldKey, String message, [int seconds]) {
    seconds ??= 3;

    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: new Text(message),
        duration: new Duration(seconds: seconds),
      )
    );
  }
}
