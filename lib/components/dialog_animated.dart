import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';

void showAnimatedDialog(BuildContext context, {String title, String message}) {
  showGeneralDialog(
    context: context,
    // barrierDismissible: true,
    transitionDuration: Duration(milliseconds: 800),
    transitionBuilder: (context, a1, a2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
            parent: a1,
            curve: Curves.elasticOut,
            reverseCurve: Curves.elasticOut),
        child: AlertDialog(
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
        ),
      );
    },
    pageBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation) {
      return null;
    },
  );
}
