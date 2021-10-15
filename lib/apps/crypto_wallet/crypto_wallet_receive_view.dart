import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:toast/toast.dart';

class CryptoWalletReceiveView extends StatefulWidget {
  final Wallets defaultWallet;
  CryptoWalletReceiveView(this.defaultWallet);
  _CryptoWalletReceiveView createState() =>
      _CryptoWalletReceiveView(this.defaultWallet);
}

class _CryptoWalletReceiveView extends State<CryptoWalletReceiveView> {
  final Wallets defaultWallet;
  _CryptoWalletReceiveView(this.defaultWallet);
  String amountValue = "0";

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Container(
          padding: EdgeInsets.all(20.0),
          width: double.maxFinite,
          child: Column(children: <Widget>[
            Text(getTranslated(context, "receive"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : kPrimaryColor)),
            SizedBox(height: 35.0),
            Text(
                getTranslated(context,
                    "tap_to_copy_the_address_into_clipboard_give_this_to_person_sending_to_you"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.grey[800])),
            SizedBox(height: 25.0),
            SizedBox(
                height: 150.0,
                child: QrImage(
                  data: "{'address': '" +
                      defaultWallet.address +
                      "', 'ammount': '" +
                      amountValue +
                      "', 'action':'pay','currency': '" +
                      defaultWallet.symbol +
                      "'}",
                  version: QrVersions.auto,
                  size: 150.0,
                )),
            SizedBox(height: 15),
            Text(defaultWallet.address,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.grey[800])),
            SizedBox(height: 15),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getTranslated(context, "set_amount"),
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                )),
            SizedBox(height: 5),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  amountValue = value;
                });
              },
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kUserBackColor, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kTextLightColor, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  labelText: getTranslated(context, "set_amount"),
                  labelStyle: Theme.of(context).textTheme.caption),
            ),
            SizedBox(height: 25),
            Container(
                width: double.maxFinite,
                child: new LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AnimatedContainer(
                        height: 50,
                        width: constraints.maxWidth / 2.1,
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
                          onTap: () {
                            FlutterClipboard.copy(defaultWallet.address)
                                .then((value) => {
                                      Fluttertoast.showToast(
                                          msg: getTranslated(
                                              context, "copied_to_clipboard"),
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white)
                                    });
                          },
                          child: Container(
                              color: Color(0x006A75CC),
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'copy').toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ))),
                        ),
                      ),
                      AnimatedContainer(
                        height: 50,
                        width: constraints.maxWidth / 2.1,
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
                          onTap: () {
                            Share.share(defaultWallet.address);
                          },
                          child: Container(
                              color: Color(0x006A75CC),
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'share').toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ))),
                        ),
                      )
                    ],
                  );
                })),
            SizedBox(height: 15)
          ]))
    ]);
  }
}

Dialog showReceiveView(BuildContext context, Wallets defaultWallet) {
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
                  child: CryptoWalletReceiveView(defaultWallet),
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
