import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/crypto_wallet/models/TagbondModel.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:toast/toast.dart';

class CryptoWalletInformation extends StatefulWidget {
  final Wallets wallets;
  CryptoWalletInformation(this.wallets);
  _CryptoWalletInformation createState() => _CryptoWalletInformation();
}

class _CryptoWalletInformation extends State<CryptoWalletInformation> {
  bool showPrivateKey = false;
  String privateKey;
  TagbondModel tagbondModel;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    tagbondModel = await TagbondModel.loadWallet();
    var privateKey = await widget.wallets.getPrivateKey(tagbondModel);
    setState(() {
      this.privateKey = privateKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Container(
          padding: EdgeInsets.all(20.0),
          width: double.maxFinite,
          child: Column(children: <Widget>[
            Text(getTranslated(context, "wallet_address"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : kPrimaryColor)),
            SizedBox(height: 25),
            Text(":" + widget.wallets.address,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.grey[500])),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () => {
                FlutterClipboard.copy(widget.wallets.address).then((value) => {
                      Fluttertoast.showToast(
                          msg: getTranslated(context, "copied_to_clipboard"),
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white)
                    })
              },
              child: Icon(Icons.copy_outlined,
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.grey[500],
                  size: 22),
            ),
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
                  setState(() {
                    showPrivateKey = true;
                  });
                },
                child: Container(
                    color: Color(0x006A75CC),
                    child: Center(
                        child: Text(
                      getTranslated(context, 'show_private_key').toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ))),
              ),
            ),
            SizedBox(height: 45.0),
            showPrivateKey
                ? Text(":$privateKey",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w200,
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.white
                            : Colors.grey[500]))
                : Container(),
            showPrivateKey ? SizedBox(height: 15) : Container(),
            showPrivateKey
                ? GestureDetector(
                    onTap: () => {
                      FlutterClipboard.copy(privateKey).then((value) => {
                            Fluttertoast.showToast(
                                msg: getTranslated(
                                    context, "copied_to_clipboard"),
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.black,
                                textColor: Colors.white)
                          })
                    },
                    child: Icon(Icons.copy_outlined,
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.white
                            : Colors.grey[500],
                        size: 22),
                  )
                : Container(),
          ]))
    ]);
  }
}

Dialog showInformationView(BuildContext context, Wallets wallets) {
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
              child: CryptoWalletInformation(wallets),
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
