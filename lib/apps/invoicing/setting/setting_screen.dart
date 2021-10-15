import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/components/app_top_bar.dart';

import '../../../constants.dart';
import 'invoice_customization.dart';
import 'invoice_defaults_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        title: 'Settings',
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Remote',
                    style: TextStyle(
                        color: kUserBackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.left,
                  ),
                ),
                GestureDetector(
                  child: Container(
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.tag,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                            'Invoice customization',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => InvoiceCustomizationScreen()));
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, left: 40, bottom: 10),
                  child: Divider(
                    color: Color(0xFFACACAC),
                    height: 10,
                  ),
                ),
                GestureDetector(
                  child: Container(
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.cog,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                            'Invoice defaults',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => InvoiceDefaultsScreen()));
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
