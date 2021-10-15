import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';

import '../../constants.dart';

class CreateTabScreen extends StatefulWidget {
  @override
  _CreateTabScreenState createState() => _CreateTabScreenState();
}

class _CreateTabScreenState extends State<CreateTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  getTranslated(context, 'invoice_createtext'),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),

              ButtonTheme(
                height: 45,
                minWidth: MediaQuery.of(context).size.width,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: RaisedButton(
                  color: kPrimaryColor,
                  onPressed: () {
                    Navigator.pushNamed(context, '/merchants');
                  },
                  child: Text(
                    getTranslated(context, 'invoice_switchmerchant'),
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),),
                ),
              ),

            ],
          ),
        )

    );

  }

}