import 'package:flutter/material.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_login_page.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_screen.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';

class CryptoWalletLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LandingArea(),
    );
  }
}

class LandingArea extends StatefulWidget {
  @override
  _LandingAreaState createState() => _LandingAreaState();
}

class _LandingAreaState extends State<LandingArea> {
  final cryptoWalletUtils = new CryptoWalletUtils();
  bool isWalletLogin = false;

  @override
  void initState() {
    super.initState();
    checkWalletLogin();
  }

  checkWalletLogin() async {
    isWalletLogin = await cryptoWalletUtils.isWalletLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child:
            (isWalletLogin) ? CryptoWalletLoginPage() : CryptoWalletScreen());
  }
}
