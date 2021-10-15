import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tagcash/localization/language_constants.dart';

class LendingTermsandConditionsScreen extends StatelessWidget {
  final String termsAndCondtions;

  const LendingTermsandConditionsScreen({Key key, this.termsAndCondtions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, "crowd_lending")+' - '+getTranslated(context, "terms_and_conditions"),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Html(
            data: termsAndCondtions,
          ),
        ),
      ),
    );
  }
}
