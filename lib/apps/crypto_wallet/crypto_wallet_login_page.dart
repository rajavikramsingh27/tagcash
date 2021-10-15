import 'package:flutter/material.dart';
import 'package:flutter_numpad_widget/flutter_numpad_widget.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';
import 'package:tagcash/components/app_logo.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

class CryptoWalletLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LoginArea(),
    );
  }
}

class LoginArea extends StatefulWidget {
  @override
  _LoginAreaState createState() => _LoginAreaState();
}

class _LoginAreaState extends State<LoginArea> {
  bool isLoading = false;
  final cryptoWalletUtils = new CryptoWalletUtils();

//Instantiate a NumpadController
  NumpadController _privateKeyPassword =
      NumpadController(format: NumpadFormat.PIN4);

  @override
  void initState() {
    super.initState();
    _privateKeyPassword.addListener(() {
      if (_privateKeyPassword.rawString != null &&
          _privateKeyPassword.rawString.length == 4) {
        passwordSubmit(_privateKeyPassword.rawString);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'crypto_wallet'),
        ),
        body: Container(
            margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
            child: Column(children: <Widget>[
              AppLogo(),
              SizedBox(height: 30),
              Container(
                height: MediaQuery.of(context).size.width / 1.3,
                child: Center(
                    child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text("Please insert your four digit pin.",
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.headline5.fontSize,
                            fontWeight: Theme.of(context)
                                .textTheme
                                .headline6
                                .fontWeight,
                            color:
                                Theme.of(context).textTheme.headline5.color)),
                    SizedBox(height: 30),
                    NumpadText(
                        controller: _privateKeyPassword,
                        style: TextStyle(fontSize: 40))
                  ],
                )),
              ),
              Expanded(
                  child: Numpad(
                      controller: _privateKeyPassword, buttonTextSize: 25))
            ])));
  }

  passwordSubmit(String password) {
    print("PASSWORD IS === " + password);
  }
}
