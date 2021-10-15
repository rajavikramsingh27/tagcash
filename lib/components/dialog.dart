import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';

void showSimpleDialog(BuildContext context, {String title, String message}) {
  showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(getTranslated(context, 'ok')),
            ),
          ],
        );
      });
}
