import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/crypto_wallet/models/TagbondModel.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';
import 'package:tagcash/apps/crypto_wallet/utils/BTC.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletQrScanner.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletSendView extends StatefulWidget {
  final Wallets defaultWallet;
  CryptoWalletSendView(this.defaultWallet);
  _CryptoWalletSendView createState() => _CryptoWalletSendView();
}

class _CryptoWalletSendView extends State<CryptoWalletSendView> {
  TagbondModel tagbondModel;
  CryptoWalletUtils cryptoWalletUtils = CryptoWalletUtils();
  String toAddress = null;
  String amount = null;
  String errorMessage = "";
  bool isError = false;
  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() async {
    tagbondModel = await cryptoWalletUtils.loadWallet();
  }

  void sendPayment() {
    setState(() {
      isError = false;
    });
    switch (widget.defaultWallet.symbol) {
      case "BTC":
        break;
      case "XLM":
        break;
      case "ETH":
        break;
    }
  }

  void sendBTC() async {
    try {
      TXSkeleton tXSkeleton =
          await tagbondModel.newBTCTransaction(toAddress, double.parse(amount));
      if (tXSkeleton.errors.length > 0) {
        showSendError(tXSkeleton.errors.first);
      }
    } catch (err) {
      print(err);
    }
  }

  showSendError(String message) {
    print(message);
    setState(() {
      isError = true;
      errorMessage = message;
      //"you_don_t_have_enough_balance_to_transafer";
    });
  }

  bool isQr = false;
  StreamController<String> scanController =
      StreamController<String>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      (isQr == false)
          ? Container(
              padding: EdgeInsets.all(20.0),
              width: double.maxFinite,
              child: Column(
                children: <Widget>[
                  Text(getTranslated(context, "send"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.white
                              : kPrimaryColor)),
                  SizedBox(height: 45.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        getTranslated(context, "amount_to_send"),
                        style: TextStyle(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.white
                                    : kPrimaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                      )),
                  SizedBox(height: 5),
                  TextField(
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        amount = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () => {},
                            icon: Icon(Icons.qr_code_outlined)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kTextLightColor, width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kTextLightColor, width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        labelText: getTranslated(context, "amount_to_send"),
                        labelStyle: Theme.of(context).textTheme.caption),
                  ),
                  SizedBox(height: 45),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(getTranslated(context, "recipient_address"),
                          style: TextStyle(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white
                                      : kPrimaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400))),
                  SizedBox(height: 5),
                  TextField(
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        toAddress = value.trim();
                      });
                    },
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
                        labelText: widget.defaultWallet.symbol +
                            " " +
                            getTranslated(context, "address"),
                        labelStyle: Theme.of(context).textTheme.caption),
                  ),
                  SizedBox(height: 10),
                  (isError)
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(errorMessage,
                              style: TextStyle(
                                  color: kPrimaryColor, fontSize: 12)))
                      : SizedBox(height: 0),
                  SizedBox(height: 45),
                  AnimatedContainer(
                    height: 50,
                    width: double.maxFinite,
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
                        sendPayment();
                      },
                      child: Container(
                          color: Color(0x006A75CC),
                          child: Center(
                              child: Text(
                            getTranslated(context, 'send').toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ))),
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ))
          : CryptoWalletQrScanner(
              resultCallback: onQRScanned, stream: scanController.stream)
    ]);
  }

  void onQRScanned(String result) {
    print("QR Result ==== " + result);
  }
}

class SendViewWidget {}

Dialog showSendView(BuildContext context, Wallets defaultWallet) {
  return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      insetPadding: EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
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
              child: CryptoWalletSendView(defaultWallet),
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
          ])));
}
