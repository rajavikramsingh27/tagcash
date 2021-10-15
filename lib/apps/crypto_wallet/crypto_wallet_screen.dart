import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/constants.dart';

class CryptoWalletScreen extends StatelessWidget {
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
                          child:
                              Column(mainAxisSize: MainAxisSize.max, children: [
                            _HeadingContent(),
                            _CenterContent(),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: _BottomContent()))
                          ])))));
        }));
  }
}

class _HeadingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
            getTranslated(context,
                "non_custodial_wallet_for_bitcoin_ethereum_token_and_stellar_assets"),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline5.fontSize,
                fontWeight: Theme.of(context).textTheme.headline6.fontWeight,
                color: Theme.of(context).textTheme.headline5.color)));
  }
}

class _CenterContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(top: 45.0),
      child: Text(getTranslated(context, "non_custodial_home_description"),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
              fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
              color: Theme.of(context).textTheme.subtitle1.color)),
    ));
  }
}

class _BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      SizedBox(height: 30),
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
          onTap: () {
            Navigator.pushNamed(context, '/crypto/backup');
          },
          child: Container(
              color: Color(0x006A75CC),
              child: Center(
                  child: Text(
                getTranslated(context, 'create_new_crypto_wallet')
                    .toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 16),
              ))),
        ),
      ),
      SizedBox(height: 20),
      Center(
          child: GestureDetector(
              onTap: () =>
                  {Navigator.pushNamed(context, '/crypto/wallet/import')},
              child: Text(
                  getTranslated(
                      context, "i_already_have_a_backup_phrase_or_private_key"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline6.fontSize,
                      fontWeight:
                          Theme.of(context).textTheme.headline6.fontWeight,
                      color: Theme.of(context).textTheme.headline6.color)))),
      SizedBox(height: 20)
    ]);
  }
}
