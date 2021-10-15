import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:clipboard/clipboard.dart';
import 'package:bip39/bip39.dart' as bip39;

class CryptoWalletPhraseRecoverScreen extends StatelessWidget {
  final String randomMnemonic = bip39.generateMnemonic();

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
                        top: 25.0, left: 15.0, right: 15.0, bottom: 25.0),
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      HeadingContent(),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                              child: CenterContent(randomMnemonic))),
                      BottomContent(randomMnemonic)
                    ]),
                  ))));
        }));
  }
}

class HeadingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
          child: Text(getTranslated(context, "your_recovery_phrase"),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline5.fontSize,
                  fontWeight: Theme.of(context).textTheme.headline6.fontWeight,
                  color: Theme.of(context).textTheme.headline5.color))),
      Center(
          child: Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Text(
            getTranslated(context,
                "write_down_or_copy_these_words_in_the_right_order_and_save_them_somewhere_safe"),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
                color: Theme.of(context).textTheme.subtitle1.color)),
      ))
    ]);
  }
}

class CenterContent extends StatefulWidget {
  final String randomMnemonic;
  CenterContent(this.randomMnemonic);
  @override
  _CenterContent createState() => _CenterContent(randomMnemonic);
}

class _CenterContent extends State<CenterContent> {
  bool showQr = false;
  String copyButtonText = "copy";
  String qrButtonText = "show_qr";
  List<String> mnemonic;
  final String randomMnemonic;
  _CenterContent(this.randomMnemonic);

  getButton(buttonText) {
    return AnimatedContainer(
      height: 50,
      width: 320,
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: kTextLightColor,
        borderRadius: BorderRadius.circular(10),
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
          if (buttonText == "qr") {
            setState(() {
              showQr = !showQr;
              qrButtonText = (showQr) ? "hide_qr" : "show_qr";
            });
          }
          if (buttonText == "copy") {
            FlutterClipboard.copy(randomMnemonic).then((value) => {
                  Fluttertoast.showToast(
                      msg: getTranslated(context, "copied_to_clipboard"),
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black,
                      textColor: Colors.white)
                });
          }
        },
        child: Container(
            color: Color(0x006A75CC),
            child: Center(
                child: Text(
              getTranslated(context,
                      (buttonText == "copy") ? copyButtonText : qrButtonText)
                  .toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mnemonic = randomMnemonic.split(" ");
    return Container(
        child: Column(
      children: <Widget>[
        Column(
            children: (showQr)
                ? <Widget>[
                    SizedBox(
                        height: 200.0,
                        child: QrImage(
                          data: randomMnemonic,
                          version: QrVersions.auto,
                          size: 200.0,
                        ))
                  ]
                : <Widget>[
                    RecoveryPhraseWord(1, mnemonic),
                    SizedBox(height: 15.0),
                    RecoveryPhraseWord(4, mnemonic),
                    SizedBox(height: 15.0),
                    RecoveryPhraseWord(7, mnemonic),
                    SizedBox(height: 15.0),
                    RecoveryPhraseWord(10, mnemonic),
                  ]),
        SizedBox(height: 25.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: getButton("copy"))),
            Expanded(
                child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: getButton("qr")))
          ],
        ),
        SizedBox(height: 25.0),
        Center(
            child: Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
              getTranslated(context,
                  "if_someone_knows_these_words_they_can_steal_your_assets"),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                  fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
                  color: Theme.of(context).textTheme.subtitle1.color)),
        )),
        Center(
            child: Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
              getTranslated(context,
                  "never_share_your_recovery_phrase_with_anyone_store_it_securely"),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                  fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
                  color: Theme.of(context).textTheme.subtitle1.color)),
        ))
      ],
    ));
  }
}

class BottomContent extends StatelessWidget {
  final String randomMnemonic;
  BottomContent(this.randomMnemonic);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
          child: AnimatedContainer(
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
          onTap: () {
            Navigator.pushNamed(context, '/crypto/confirm/phrase',
                arguments: {'randomMnemonic': randomMnemonic});
          },
          child: Container(
              color: Color(0x006A75CC),
              child: Center(
                  child: Text(
                getTranslated(context, 'continue').toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 16),
              ))),
        ),
      ))
    ]);
  }
}

class RecoveryPhraseWord extends StatelessWidget {
  final int index;
  final List<String> mnemonic;
  const RecoveryPhraseWord(this.index, this.mnemonic);

  getExpandedChild(index) {
    return Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(mnemonic[index - 1].toString()))),
                Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding: EdgeInsets.only(top: 3.0, right: 3.0),
                        child: Text((index).toString(),
                            style: TextStyle(fontSize: 10))))
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        getExpandedChild(index),
        getExpandedChild(index + 1),
        getExpandedChild(index + 2)
      ],
    );
  }
}
