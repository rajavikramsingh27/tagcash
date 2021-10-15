import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletAddToken extends StatefulWidget {
  _CryptoWalletAddToken createState() => _CryptoWalletAddToken();
}

class _CryptoWalletAddToken extends State<CryptoWalletAddToken> {
  String dropdownValue = "ERC20 Token";

  static final getData = [
    {"name": "Bitcoin", "short_name": "BTC", "us_value": 6478, "balance": 10.4},
    {"name": "Ethereum", "short_name": "ETH", "us_value": 133, "balance": 64.3},
    {"name": "Stellar", "short_name": "XLM", "us_value": 0.04, "balance": 4568},
  ];

  @override
  Widget build(BuildContext context) {
    return (DefaultTabController(
        length: 2,
        child: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(80),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    backgroundColor:
                        Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.grey[800]
                            : Colors.white,
                    shadowColor: Colors.transparent,
                    flexibleSpace: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              getTranslated(context, "add_new_token_type"),
                              style: TextStyle(
                                color: Provider.of<ThemeProvider>(context)
                                        .isDarkMode
                                    ? Colors.white
                                    : kPrimaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            )),
                        TabBar(
                          labelPadding: EdgeInsets.all(0),
                          indicator: BoxDecoration(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white),
                          tabs: [
                            Container(
                                margin: EdgeInsets.only(right: 2.5),
                                width: double.maxFinite,
                                padding: EdgeInsets.only(top: 7.5, bottom: 7.5),
                                decoration: BoxDecoration(
                                    color: Provider.of<ThemeProvider>(context)
                                            .isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    border: Border(
                                      top: BorderSide(
                                          color: Colors.grey[300], width: 1.0),
                                      left: BorderSide(
                                          color: Colors.grey[300], width: 1.0),
                                      right:
                                          BorderSide(color: Colors.grey[300]),
                                    )),
                                child: Text(
                                  "Currency",
                                  style: TextStyle(
                                      color: Provider.of<ThemeProvider>(context)
                                              .isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                  textAlign: TextAlign.center,
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 2.5),
                                width: double.maxFinite,
                                padding: EdgeInsets.only(top: 7.5, bottom: 7.5),
                                decoration: BoxDecoration(
                                    color: Provider.of<ThemeProvider>(context)
                                            .isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    border: Border(
                                      top: BorderSide(
                                          color: Colors.grey[300], width: 1.0),
                                      left: BorderSide(
                                          color: Colors.grey[300], width: 1.0),
                                      right:
                                          BorderSide(color: Colors.grey[300]),
                                    )),
                                child: Text(
                                  "Add Token",
                                  style: TextStyle(
                                      color: Provider.of<ThemeProvider>(context)
                                              .isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                  textAlign: TextAlign.center,
                                )),
                          ],
                        ),
                      ],
                    ),
                  )),
              body: Container(
                decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.grey[800]
                        : Colors.white),
                child: TabBarView(
                  children: [currencyWidget(), addToken()],
                ),
              ),
            ))));
  }

  Widget currencyWidget() {
    return (Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.maxFinite,
            height: 35,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: kTextLightColor)),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
              dropdownColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.grey[800]
                  : Colors.white,
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
              items: <String>["ERC20 Token", "Stellar Token"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toString(),
                      style: Theme.of(context).textTheme.caption),
                );
              }).toList(),
            )),
          ),
          SizedBox(height: 15),
          Expanded(
            child: Container(
              height: double.maxFinite,
              child: getCurrencyList(),
            ),
          ),
          SizedBox(height: 15),
          AnimatedContainer(
            height: 50,
            width: 320,
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  color: Color(0xFF173347).withOpacity(0.23),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                  color: Color(0x006A75CC),
                  child: Center(
                      child: Text(
                    getTranslated(context, 'add').toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ))),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    ));
  }

  ListView getCurrencyList() {
    return ListView.builder(
        itemCount: getData.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () => {
                    /*Navigator.pushNamed(context, '/crypto/wallet/details',
                        arguments: getData[index]["short_name"])*/
                  },
              child: Container(
                  width: double.maxFinite,
                  child: Card(
                    shadowColor: Colors.white,
                    margin:
                        EdgeInsets.only(top: 4, bottom: 4, left: 0, right: 0),
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.cyan[200]),
                            ),
                            Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: Text(
                                        getData[index]['name'].toString() +
                                            ' (' +
                                            getData[index]['short_name'] +
                                            ')',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2)))
                          ],
                        )),
                  )));
        });
  }

  Widget addToken() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.maxFinite,
            height: 35,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: kTextLightColor)),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
              dropdownColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.grey[800]
                  : Colors.white,
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
              items: <String>["ERC20 Token", "Stellar Token"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toString(),
                      style: Theme.of(context).textTheme.caption),
                );
              }).toList(),
            )),
          ),
          SizedBox(height: 35),
          Expanded(
            child: Container(
              height: double.maxFinite,
              child: Column(
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        // suffixText: "Paste",
                        // suffixStyle: Theme.of(context).textTheme.caption,
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kTextLightColor, width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kTextLightColor, width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        labelText: getTranslated(context, "issuer_contract"),
                        labelStyle: Theme.of(context).textTheme.caption),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        // suffixText: "Paste",
                        // suffixStyle: Theme.of(context).textTheme.caption,
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kTextLightColor, width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kTextLightColor, width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        labelText: getTranslated(context, "short_code"),
                        labelStyle: Theme.of(context).textTheme.caption),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          AnimatedContainer(
            height: 50,
            width: 320,
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  color: Color(0xFF173347).withOpacity(0.23),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                  color: Color(0x006A75CC),
                  child: Center(
                      child: Text(
                    getTranslated(context, 'add').toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ))),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

Dialog showAddTokenModal(BuildContext context) {
  return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      insetPadding: EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: Center(
          child: Container(
              padding: EdgeInsets.all(20),
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
                  child: CryptoWalletAddToken(),
                ),
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
              ]))));
}
