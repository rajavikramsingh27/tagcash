import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletImportScreen extends StatefulWidget {
  _CryptoWalletImportScreen createState() => _CryptoWalletImportScreen();
}

class _CryptoWalletImportScreen extends State<CryptoWalletImportScreen> {
  static const String SEED_PHRASE = "Seed Phrase";
  static const String PRIVATE_KEY = "Private Key";
  static const String WATCH_ONLY_WALLET = "Watch Only Wallet";

  // String dropdownValue = SEED_PHRASE;

  // TextEditingController _walletNameController =
  //     new TextEditingController(text: '');
  TextEditingController _seedPhraseController =
      new TextEditingController(text: '');
  // TextEditingController _privateKeyController =
  //     new TextEditingController(text: '');
  // TextEditingController _privateKeyPassword =
  //     new TextEditingController(text: '');

  bool isWalletErrorShow = false;
  bool isSeedPhraseErrorShow = false;
  // bool isPrivateKeyErrorShow = false;
  bool isValidSeedsEnter = true;
  // bool isValidPrivateKeyEnter = false;
  // bool isPasswordErrorShow = false;
  bool isLoading = false;

  CryptoWalletUtils cryptoWalletUtils = new CryptoWalletUtils();

  @override
  void initState() {
    super.initState();

    // _walletNameController = TextEditingController(text: 'Boparai');
    _seedPhraseController = TextEditingController(text: '');
    // _privateKeyController = TextEditingController(
    //     text:
    //         '');
    // _privateKeyPassword = TextEditingController(text: '123456');
  }

  @override
  void dispose() {
    // _walletNameController.dispose();
    _seedPhraseController.dispose();
    // _privateKeyController.dispose();
    // _privateKeyPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'crypto_wallet'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: 25.0, left: 20.0, right: 20.0, bottom: 25.0),
                          child:
                              Column(mainAxisSize: MainAxisSize.max, children: [
                            // getDropDown(),
                            Expanded(
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 25.0, bottom: 25.0),
                                  child: getCenterContent()),
                            ),
                            getBottomButton()
                          ])))));
        }));
  }

  // getDropDown() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: 40,
  //     padding: EdgeInsets.fromLTRB(10, 0, 10, 2),
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(5),
  //         border: Border.all(color: kTextLightColor)),
  //     child: DropdownButtonHideUnderline(
  //         child: DropdownButton<String>(
  //       dropdownColor: Colors.white,
  //       iconSize: 24,
  //       elevation: 16,
  //       style: TextStyle(
  //         color: Colors.black,
  //         fontSize: 16,
  //       ),
  //       value: dropdownValue,
  //       onChanged: (String newValue) {
  //         setState(() {
  //           dropdownValue = newValue;
  //           setShowErrorsToFalse();
  //         });
  //       },
  //       items: <String>[SEED_PHRASE, PRIVATE_KEY, WATCH_ONLY_WALLET]
  //           .map<DropdownMenuItem<String>>((String value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(value.toString(),
  //               style: Theme.of(context).textTheme.caption),
  //         );
  //       }).toList(),
  //     )),
  //   );
  // }

  getCenterContent() {
    return Container(
      child: Column(
        children: [
          // if (dropdownValue == "Seed Phrase")
          Text(
              getTranslated(context,
                  "write_down_or_copy_these_words_in_the_right_order_and_save_them_somewhere_safe"),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                  fontWeight: Theme.of(context).textTheme.subtitle2.fontWeight,
                  color: Theme.of(context).textTheme.subtitle1.color)),
          // if (dropdownValue == SEED_PHRASE) SizedBox(height: 20),
          // if (dropdownValue == SEED_PHRASE)
          SizedBox(height: 35),
          Container(
            child: TextField(
                controller: _seedPhraseController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: kTextLightColor, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: kTextLightColor, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    labelText: getTranslated(context, "seed_phrase"),
                    labelStyle: Theme.of(context).textTheme.caption)),
          ),
          if (isSeedPhraseErrorShow)
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      getTranslated(context, "seed_phrase_cannot_be_empty"),
                      style: TextStyle(color: kPrimaryColor, fontSize: 12))),
            ),
          if (!isValidSeedsEnter)
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(getTranslated(context, "not_a_valid_seed_phrase"),
                      style: TextStyle(color: kPrimaryColor, fontSize: 12))),
            ),
          // if (dropdownValue != SEED_PHRASE)
          //   Container(
          //     child: TextField(
          //       controller: _privateKeyController,
          //       keyboardType: TextInputType.text,
          //       decoration: InputDecoration(
          //           suffixText: getTranslated(context, "paste"),
          //           suffixStyle: Theme.of(context).textTheme.caption,
          //           focusedBorder: OutlineInputBorder(
          //               borderSide:
          //                   const BorderSide(color: kTextLightColor, width: 1),
          //               borderRadius: BorderRadius.circular(5)),
          //           enabledBorder: OutlineInputBorder(
          //               borderSide:
          //                   const BorderSide(color: kTextLightColor, width: 1),
          //               borderRadius: BorderRadius.circular(5)),
          //           labelText: getTranslated(context,
          //               "public_key_private_key_depends_if_watch_wallet"),
          //           labelStyle: Theme.of(context).textTheme.caption),
          //     ),
          //   ),
          // if (isPrivateKeyErrorShow &&
          //     (dropdownValue == PRIVATE_KEY ||
          //         dropdownValue == WATCH_ONLY_WALLET))
          //   Container(
          //       margin: EdgeInsets.only(top: 5),
          //       child: Align(
          //         alignment: Alignment.centerLeft,
          //         child: Text(
          //             getTranslated(context, "private_key_cannot_be_empty"),
          //             style: TextStyle(color: kPrimaryColor, fontSize: 12)),
          //       )),
          // if (!isValidPrivateKeyEnter &&
          //     (dropdownValue == PRIVATE_KEY ||
          //         dropdownValue == WATCH_ONLY_WALLET))
          //   Container(
          //     margin: EdgeInsets.only(top: 5),
          //     child: Align(
          //         alignment: Alignment.centerLeft,
          //         child: Text(getTranslated(context, "not_a_valid_private_key"),
          //             style: TextStyle(color: kPrimaryColor, fontSize: 12))),
          //   ),
          // SizedBox(height: 20),
          // Container(
          //   child: TextField(
          //     controller: _walletNameController,
          //     keyboardType: TextInputType.text,
          //     decoration: InputDecoration(
          //         // suffixText: "Paste",
          //         // suffixStyle: Theme.of(context).textTheme.caption,
          //         focusedBorder: OutlineInputBorder(
          //             borderSide:
          //                 const BorderSide(color: kTextLightColor, width: 1),
          //             borderRadius: BorderRadius.circular(5)),
          //         enabledBorder: OutlineInputBorder(
          //             borderSide:
          //                 const BorderSide(color: kTextLightColor, width: 1),
          //             borderRadius: BorderRadius.circular(5)),
          //         labelText: getTranslated(context, "wallet_name"),
          //         labelStyle: Theme.of(context).textTheme.caption),
          //   ),
          // ),
          // if (isWalletErrorShow)
          //   Container(
          //       margin: EdgeInsets.only(top: 5),
          //       child: Align(
          //         alignment: Alignment.centerLeft,
          //         child: Text(getTranslated(context, "wallet_name_required"),
          //             style: TextStyle(color: kPrimaryColor, fontSize: 12)),
          //       )),
          // SizedBox(height: 20),
          // Container(
          //     margin: EdgeInsets.only(top: 5),
          //     child: Align(
          //       alignment: Alignment.centerLeft,
          //       child: Text(getTranslated(context, "wallet_password"),
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: Theme.of(context).textTheme.subtitle1.color,
          //           )),
          //     )),
          // SizedBox(height: 10),
          // Container(
          //   child: TextField(
          //       controller: _privateKeyPassword,
          //       keyboardType: TextInputType.number,
          //       decoration: InputDecoration(
          //           // suffixText: "Paste",
          //           // suffixStyle: Theme.of(context).textTheme.caption,
          //           focusedBorder: OutlineInputBorder(
          //               borderSide:
          //                   const BorderSide(color: kTextLightColor, width: 1),
          //               borderRadius: BorderRadius.circular(5)),
          //           enabledBorder: OutlineInputBorder(
          //               borderSide:
          //                   const BorderSide(color: kTextLightColor, width: 1),
          //               borderRadius: BorderRadius.circular(5)),
          //           labelStyle: Theme.of(context).textTheme.caption),
          //       inputFormatters: <TextInputFormatter>[
          //         FilteringTextInputFormatter.digitsOnly
          //       ]),
          // ),
          // if (isPasswordErrorShow)
          //   Container(
          //       margin: EdgeInsets.only(top: 5),
          //       child: Align(
          //         alignment: Alignment.centerLeft,
          //         child: Text(getTranslated(context, "wallet_password_invalid"),
          //             style: TextStyle(color: kPrimaryColor, fontSize: 12)),
          //       )),
        ],
      ),
    );
  }

  getBottomButton() {
    return Center(
        child: AnimatedContainer(
      height: 50,
      width: isLoading ? 50 : 320,
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
        onTap: () async {
          importWalletSubmit();
          //Navigator.pushNamed(context, '/crypto/wallet/dashboard');
        },
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ))
            : Container(
                color: Color(0x006A75CC),
                child: Center(
                    child: Text(
                  getTranslated(context, 'continue').toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ))),
      ),
    ));
  }

  void importWalletSubmit() async {
    setShowErrorsToFalse();

    if (!validateForm()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await new Future.delayed(const Duration(seconds: 2));

    await importWithSeedPhrase();

    // switch (dropdownValue) {
    //   case SEED_PHRASE:
    //     importWithSeedPhrase();
    //     break;
    //   case PRIVATE_KEY:
    //     importWithPrivateKey();
    //     break;
    //   case WATCH_ONLY_WALLET:
    //     importWatchOnly();
    //     break;
    // }
  }

  Future<void> importWithSeedPhrase() async {
    bool isValidSeeds =
        await cryptoWalletUtils.createWallet(_seedPhraseController.text);
    setState(() {
      isValidSeedsEnter = isValidSeeds;
      isLoading = false;
    });
    if (isValidSeeds) {
      showDialog(
          context: context,
          builder: (BuildContext context) => showWalletSuccessDialog(context));
    }
  }

  // Future<void> importWithPrivateKey() async {
  //   bool isValidPrivateKey = await cryptoWalletUtils
  //       .importWalletFromPrivateKey(_privateKeyController.text);
  //   setState(() {
  //     isValidPrivateKeyEnter = isValidPrivateKey;
  //   });
  // }

  // Future<void> importWatchOnly() async {
  //   bool isValidPrivateKey = await cryptoWalletUtils
  //       .importWalletWatchOnly(_privateKeyController.text);
  //   setState(() {
  //     isValidPrivateKeyEnter = isValidPrivateKey;
  //   });
  // }

  bool validateForm() {
    bool isValid = true;

    // if (_walletNameController.text.length <= 0) {
    //   setState(() {
    //     isWalletErrorShow = true;
    //   });
    //   isValid = false;
    // }

    if (_seedPhraseController.text.length <= 0) {
      setState(() {
        isSeedPhraseErrorShow = true;
      });
      isValid = false;
    }

    // if (dropdownValue == PRIVATE_KEY &&
    //     _privateKeyController.text.length <= 0) {
    //   setState(() {
    //     isPrivateKeyErrorShow = true;
    //   });
    //   isValid = false;
    // }

    // if (dropdownValue == WATCH_ONLY_WALLET &&
    //     _privateKeyController.text.length <= 0) {
    //   setState(() {
    //     isPrivateKeyErrorShow = true;
    //   });
    //   isValid = false;
    // }

    // if (_privateKeyPassword.text.length < 6 ||
    //     _privateKeyPassword.text.length > 6) {
    //   setState(() {
    //     isPasswordErrorShow = true;
    //   });
    //   isValid = false;
    // }

    return isValid;
  }

  void setShowErrorsToFalse() {
    this.setState(() {
      isWalletErrorShow = false;
      // isPrivateKeyErrorShow = false;
      isSeedPhraseErrorShow = false;
      isValidSeedsEnter = true;
      // isValidPrivateKeyEnter = true;
      // isPasswordErrorShow = false;
    });
  }

  Dialog showWalletSuccessDialog(BuildContext context) {
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
            child: Container(
                padding: EdgeInsets.all(20.0),
                width: double.maxFinite,
                height: 200,
                child: Column(children: [
                  Text(
                    "Your Crypto wallet is imported successfully.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 35),
                  Center(
                      child: AnimatedContainer(
                    height: 50,
                    width: 200,
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
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (Route<dynamic> route) => false);
                      },
                      child: Container(
                          color: Color(0x006A75CC),
                          child: Center(
                              child: Text(
                            getTranslated(context, 'ok').toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ))),
                    ),
                  ))
                ])),
          ),
          Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (Route<dynamic> route) => false);
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
