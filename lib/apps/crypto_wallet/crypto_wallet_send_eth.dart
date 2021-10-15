import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/crypto_wallet/models/TagbondModel.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletQrScanner.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletSendETHView extends StatefulWidget {
  final Wallets defaultWallet;
  CryptoWalletSendETHView(this.defaultWallet);
  _CryptoWalletSendETHView createState() => _CryptoWalletSendETHView();
}

class _CryptoWalletSendETHView extends State<CryptoWalletSendETHView> {
  TagbondModel tagbondModel;
  CryptoWalletUtils cryptoWalletUtils = CryptoWalletUtils();
  String toAddress = "";
  String amount = "";
  String errorMessage = "";
  bool isError = false;
  bool confirmView = false;
  bool isLoading = false;
  bool showSuccessView = false;
  String gasFees = "";

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() async {
    tagbondModel = await cryptoWalletUtils.loadWallet();
  }

  void sendPaymentForConfirmation() async {
    if (amount.isEmpty || toAddress.isEmpty) {
      showError(getTranslated(
          context, "amount_and_recipient_address_cannot_be_empty"));
    } else if (double.parse(amount) >
        double.parse(widget.defaultWallet.balance)) {
      showError(getTranslated(
          context, "amount_and_recipient_address_cannot_be_empty"));
    } else {
      try {
        setState(() {
          isError = false;
          isLoading = true;
        });
        gasFees = await tagbondModel.getEstimateGasPrice(toAddress, amount);
        showConfirmView();
      } catch (e) {
        print(e);
      }
    }
  }

  void showConfirmView() {
    setState(() {
      isLoading = false;
      confirmView = true;
    });
  }

  void confirmETHTransaction() async {
    setState(() {
      isError = false;
      isLoading = true;
    });
    try {
      String hash =
          await tagbondModel.confirmETHTransaction(toAddress, amount, gasFees);
      print(hash);
      setState(() {
        showSuccessView = true;
        isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        errorMessage =
            getTranslated(context, "something_went_wrong_please_try_again");
        isError = true;
        isLoading = false;
      });
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

  showError(String message) {
    setState(() {
      isError = true;
      errorMessage = message;
      isLoading = false;
    });
  }

  bool isQr = false;
  StreamController<String> scanController =
      StreamController<String>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      (isQr == false)
          ? (!confirmView)
              ? getXLMSendView()
              : (showSuccessView)
                  ? getSuccessView()
                  : getConfirmView()
          : CryptoWalletQrScanner(
              resultCallback: onQRScanned, stream: scanController.stream)
    ]);
  }

  void onQRScanned(String result) {
    print("QR Result ==== " + result);
  }

  getXLMSendView() {
    return Container(
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
                      color: Provider.of<ThemeProvider>(context).isDarkMode
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
                      onPressed: () => {}, icon: Icon(Icons.qr_code_outlined)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kTextLightColor, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kTextLightColor, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  labelText: getTranslated(context, "amount_to_send"),
                  labelStyle: Theme.of(context).textTheme.caption),
            ),
            SizedBox(height: 45),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(getTranslated(context, "recipient_address"),
                    style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).isDarkMode
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
                      borderSide:
                          const BorderSide(color: kTextLightColor, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kTextLightColor, width: 1),
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
                        style: TextStyle(color: kPrimaryColor, fontSize: 12)))
                : SizedBox(height: 0),
            SizedBox(height: 45),
            AnimatedContainer(
              height: 50,
              width: (isLoading) ? 50 : double.maxFinite,
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
              child: (isLoading)
                  ? Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                  : GestureDetector(
                      onTap: () {
                        sendPaymentForConfirmation();
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
        ));
  }

  getConfirmView() {
    return Container(
        padding: EdgeInsets.all(20.0),
        width: double.maxFinite,
        child: Column(
          children: <Widget>[
            Text(getTranslated(context, "confirmation"),
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
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                )),
            SizedBox(height: 5),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(amount.toString(),
                    style: TextStyle(color: kTextLightColor, fontSize: 12))),
            SizedBox(height: 45.0),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getTranslated(context, "gas_limit"),
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                )),
            SizedBox(height: 5),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(gasFees,
                    style: TextStyle(color: kTextLightColor, fontSize: 12))),
            SizedBox(height: 45),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(getTranslated(context, "recipient_address"),
                    style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.white
                            : kPrimaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400))),
            SizedBox(height: 5),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(toAddress,
                    style: TextStyle(color: kTextLightColor, fontSize: 12))),
            SizedBox(height: 45),
            (isError)
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(errorMessage,
                        style: TextStyle(color: kPrimaryColor, fontSize: 14)))
                : SizedBox(height: 0),
            SizedBox(height: 15),
            (!isLoading)
                ? Container(
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
                                setState(() {
                                  confirmView = false;
                                  amount = "";
                                  toAddress = "";
                                  isError = false;
                                });
                              },
                              child: Container(
                                  color: Color(0x006A75CC),
                                  child: Center(
                                      child: Text(
                                    getTranslated(context, 'cancel')
                                        .toUpperCase(),
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
                                confirmETHTransaction();
                              },
                              child: Container(
                                  color: Color(0x006A75CC),
                                  child: Center(
                                      child: Text(
                                    getTranslated(context, 'confirm')
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ))),
                            ),
                          )
                        ],
                      );
                    }))
                : Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                        height: 50,
                        width: 50,
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
                        child: Center(
                            child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )))),
            SizedBox(height: 15)
          ],
        ));
  }

  getSuccessView() {
    return Container(
        padding: EdgeInsets.all(20.0),
        width: double.maxFinite,
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: kPrimaryColor,
                ),
                iconSize: 70,
              )),
          Text(getTranslated(context, "eth_transafer_to_address"),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : kPrimaryColor)),
          SizedBox(height: 15.0),
          Text(toAddress,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : kTextLightColor))
        ]));
  }

  void confirmPayment() {}
}

class SendViewWidget {}

Dialog showETHSendView(BuildContext context, Wallets defaultWallet) {
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
              child: CryptoWalletSendETHView(defaultWallet),
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
