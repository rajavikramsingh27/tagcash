import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/constants.dart';

class CryptoWalletBackupScreen extends StatelessWidget {
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
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(child: HeadingContent()),
                                BottomContent()
                              ])))));
        }));
  }
}

class HeadingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
                  getTranslated(context, "back_up_your_crypto_wallet_now"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline5.fontSize,
                      fontWeight:
                          Theme.of(context).textTheme.headline6.fontWeight,
                      color: Theme.of(context).textTheme.headline6.color))),
          Center(
              child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text(
                getTranslated(context,
                    "in_the_next_step_you_will_see_12_words_that_allow_you_to_recover_a_wallet"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.subtitle1.fontWeight,
                    color: Theme.of(context).textTheme.subtitle1.color)),
          ))
        ]);
  }
}

class BottomContent extends StatefulWidget {
  @override
  _BottomContent createState() => _BottomContent();
}

class _BottomContent extends State<BottomContent> {
  bool agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      SizedBox(height: 30),
      Center(
          child: Stack(children: [
        CheckboxListTile(
            activeColor: kPrimaryColor,
            title: Text(
                getTranslated(context,
                    "i_understand_that_if_i_lose_my_recovery_words_i_will_not_able_to_access_my_wallet"),
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.headline6.fontWeight,
                    color: Theme.of(context).textTheme.headline6.color)),
            value: agreeTerms,
            onChanged: (newValue) {
              setState(() {
                agreeTerms = newValue;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding:
                EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0)),
      ])),
      SizedBox(height: 15),
      AnimatedContainer(
        height: 50,
        width: 320,
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: (agreeTerms) ? kPrimaryColor : kTextLightColor,
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
            if (agreeTerms)
              Navigator.pushNamed(context, "/crypto/recover/phrase");
          },
          child: Container(
              color: Color(0x006A75CC),
              child: Center(
                  child: Text(
                getTranslated(context, 'continue').toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 16),
              ))),
        ),
      ),
      SizedBox(height: 20)
    ]);
  }
}
