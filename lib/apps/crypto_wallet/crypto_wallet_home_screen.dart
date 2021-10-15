import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_add_token.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletHomeScreen extends StatefulWidget {
  _CryptoWalletHomeScreen createState() => _CryptoWalletHomeScreen();
}

class _CryptoWalletHomeScreen extends State<CryptoWalletHomeScreen> {
  String dropdownValue = "ETH";

  static final getData = [
    {"name": "Bitcoin", "short_name": "BTC", "us_value": 6478, "balance": 10.4},
    {"name": "Ethereum", "short_name": "ETH", "us_value": 133, "balance": 64.3},
    {"name": "Stellar", "short_name": "XLM", "us_value": 0.04, "balance": 4568},
    {
      "name": "Tagbond",
      "short_name": "TAG",
      "us_value": 0.04,
      "balance": 1000000000
    },
    {"name": "Bitcoin", "short_name": "BTC", "us_value": 6478, "balance": 10.4},
    {"name": "Ethereum", "short_name": "ETH", "us_value": 133, "balance": 64.3},
    {"name": "Stellar", "short_name": "XLM", "us_value": 0.04, "balance": 4568},
    {
      "name": "Tagbond",
      "short_name": "TAG",
      "us_value": 0.04,
      "balance": 1000000000
    },
    {"name": "Bitcoin", "short_name": "BTC", "us_value": 6478, "balance": 10.4},
    {"name": "Ethereum", "short_name": "ETH", "us_value": 133, "balance": 64.3},
    {"name": "Stellar", "short_name": "XLM", "us_value": 0.04, "balance": 4568},
    {
      "name": "Tagbond",
      "short_name": "TAG",
      "us_value": 0.04,
      "balance": 1000000000
    },
    {"name": "Bitcoin", "short_name": "BTC", "us_value": 6478, "balance": 10.4},
    {"name": "Ethereum", "short_name": "ETH", "us_value": 133, "balance": 64.3},
    {"name": "Stellar", "short_name": "XLM", "us_value": 0.04, "balance": 4568},
    {
      "name": "Tagbond",
      "short_name": "TAG",
      "us_value": 0.04,
      "balance": 1000000000
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'crypto_wallet'),
        ),
        body: Container(
            child: Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: ListView(shrinkWrap: true, children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 25.0),
                      child: getDropDown()),
                  Padding(
                      padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                      child: getWalletList())
                ]))),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      walletInformation(context));
            },
            child: Icon(Icons.add),
            backgroundColor: kPrimaryColor));
  }

  Row getDropDown() {
    return Row(children: [
      Expanded(
          child: Container(
        height: 40,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: kTextLightColor)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          dropdownColor: Colors.white,
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          value: dropdownValue,
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;

              //onCountChange(dropdownValue);
            });
          },
          items: <String>["ETH", "PHP", "BTC"]
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.toString(),
                  style: Theme.of(context).textTheme.caption),
            );
          }).toList(),
        )),
      )),
      Container(
          padding: EdgeInsets.only(left: 10),
          child: Icon(Icons.add,
              color: kTextLightColor,
              size: Theme.of(context).textTheme.headline4.fontSize)),
    ]);
  }

  ListView getWalletList() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: getData.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () => {
                    Navigator.pushNamed(context, '/crypto/wallet/details',
                        arguments: getData[index]["short_name"])
                  },
              child: Container(
                  width: double.maxFinite,
                  child: Card(
                    margin:
                        EdgeInsets.only(top: 4, bottom: 4, left: 0, right: 0),
                    child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: kTextLightColor),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    getData[index]['name'].toString() +
                                        ' (' +
                                        getData[index]['short_name'] +
                                        ')',
                                    style:
                                        Theme.of(context).textTheme.subtitle2),
                                Text(
                                    "US\$ " +
                                        getData[index]["us_value"].toString(),
                                    style: Theme.of(context).textTheme.caption)
                              ],
                            ),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(getData[index]['balance'].toString(),
                                    style:
                                        Theme.of(context).textTheme.subtitle2)
                              ],
                            ))
                          ],
                        )),
                  )));
        });
  }

  Widget walletInformation(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
            child: Stack(children: <Widget>[
          Container(
              padding: EdgeInsets.only(
                top: 18.0,
              ),
              margin: EdgeInsets.only(top: 13.0, right: 8.0),
              decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.grey[800]
                      : Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 0.0,
                      offset: Offset(0.0, 0.0),
                    ),
                  ]),
              child: CryptoWalletAddToken()),
          Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 15.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ))
        ])));
  }
}
