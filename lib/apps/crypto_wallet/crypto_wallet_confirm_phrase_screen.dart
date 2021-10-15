import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletConfirmPhraseScreen extends StatefulWidget {
  _CryptoWalletConfirmPhraseScreen createState() =>
      _CryptoWalletConfirmPhraseScreen();
}

class _CryptoWalletConfirmPhraseScreen
    extends State<CryptoWalletConfirmPhraseScreen> {
  String originalMnemonic;
  List confirmMnemonic = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void onPressCountinue(context) async {
    if (originalMnemonic == confirmMnemonic.join(" ")) {
      try {
        startLoading();
        CryptoWalletUtils cryptoWalletUtils = new CryptoWalletUtils();
        cryptoWalletUtils.createWallet(originalMnemonic).then((value) => {
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      showWalletSuccessDialog(context))
            });
      } catch (err) {
        print(err);
      } finally {
        stopLoading();
      }
    } else {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Seed Phrase not matched please try again')));
    }
  }

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    this.originalMnemonic = arguments['randomMnemonic'];

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
                          child:
                              Column(mainAxisSize: MainAxisSize.max, children: [
                            HeadingContent(),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                              child: CenterContent(
                                  originalMnemonic, confirmMnemonic),
                            )),
                            getBottomContent(context)
                          ])))));
        }));
  }

  getBottomContent(context) {
    return Column(children: [
      Center(
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ))
            : GestureDetector(
                onTap: () {
                  onPressCountinue(context);
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
                    "Your Crypto wallet is created successfully.",
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
                "tap_the_words_to_put_them_next_to_each_other_in_the_correct_order"),
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
  List confirmPhrase;
  CenterContent(this.randomMnemonic, this.confirmPhrase);

  @override
  _CenterContent createState() => _CenterContent(randomMnemonic, confirmPhrase);
}

class _CenterContent extends State<CenterContent> {
  final String originalMnemonic;
  List randomPhrase;
  List confirmPhrase;
  _CenterContent(this.originalMnemonic, this.confirmPhrase);

  insertPhrase(index) {
    setState(() {
      confirmPhrase.add(randomPhrase[index]);
      randomPhrase.removeAt(index);
    });
  }

  removePhrase(index) {
    setState(() {
      randomPhrase.add(confirmPhrase[index]);
      confirmPhrase.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    randomPhrase = originalMnemonic.split(" ");
    randomPhrase.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Container(
        decoration: BoxDecoration(border: Border.all(color: kTextLightColor)),
        padding: EdgeInsets.all(5),
        height: 200,
        child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 3,
            children: <Widget>[
              for (var i = 0; i < confirmPhrase.length; i++)
                RecoveryPhraseWord(confirmPhrase[i], i, this, 0)
            ]),
      ),
      Container(
        margin: EdgeInsets.only(top: 20),
        height: 220,
        child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3,
            children: <Widget>[
              for (var i = 0; i < randomPhrase.length; i++)
                RecoveryPhraseWord(randomPhrase[i], i, this, 1)
            ]),
      )
    ]));
  }
}

class RecoveryPhraseWord extends StatelessWidget {
  final String phrase;
  final int index;
  final _CenterContent centerContent;
  final int type; //0 for insert box, 1 for upsert
  const RecoveryPhraseWord(
      this.phrase, this.index, this.centerContent, this.type);

  getExpandedChild() {
    return GestureDetector(
        onTap: () {
          if (type == 1)
            centerContent.insertPhrase(this.index);
          else
            centerContent.removePhrase(this.index);
        },
        child: Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.all(10.0), child: Text(phrase))),
                Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding: EdgeInsets.only(top: 3.0, right: 3.0),
                        child: Text((index + 1).toString(),
                            style: TextStyle(fontSize: 10))))
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return getExpandedChild();
  }
}
