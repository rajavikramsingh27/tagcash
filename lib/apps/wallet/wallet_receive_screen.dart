import 'package:flutter/material.dart';
import 'package:tagcash/apps/wallet/receive/deposit_bank_screen.dart';
import 'package:tagcash/apps/wallet/receive/deposit_ecpay_screen.dart';
import 'package:tagcash/apps/wallet/receive/deposit_seven_screen.dart';
import 'package:tagcash/apps/wallet/receive/deposit_stellar_screen.dart';
import 'package:tagcash/apps/wallet/receive/deposit_tagcash_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';

import 'models/transaction_method.dart';

class WalletReceiveScreen extends StatefulWidget {
  final Wallet wallet;

  const WalletReceiveScreen({Key key, this.wallet}) : super(key: key);

  @override
  _WalletReceiveScreenState createState() => _WalletReceiveScreenState();
}

class _WalletReceiveScreenState extends State<WalletReceiveScreen> {
  TransactionMethod methodSelected;
  List<TransactionMethod> sendMethodList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Wallet wallet = widget.wallet;
    List<TransactionMethod> methodList = [];

    methodList.add(new TransactionMethod(
        title: getTranslated(context, 'tagcash'),
        subTitle: 'Tagcash',
        value: 'tagcash'));

    List<int> subSetTokenTypeId = wallet.subSetTokenTypeId;
    if (subSetTokenTypeId.contains(16)) {
      methodList.add(new TransactionMethod(
          title: getTranslated(context, 'stellar'),
          subTitle: 'Stellar',
          value: 'stellar'));
    }

    if (wallet.walletTypeNumeric == 0) {
      if (wallet.bankDepositWithdraw == true) {
        methodList.add(TransactionMethod(
            title: getTranslated(context, 'bank'),
            subTitle: 'Deposit via Bank',
            value: 'bank'));
      }

      if (wallet.walletId == 1) {
        methodList.add(TransactionMethod(
            title: getTranslated(context, 'seven_eleven'),
            subTitle: 'Deposit via 7-Eleven',
            value: 'seven'));
        methodList.add(TransactionMethod(
            title: 'CLIQQ',
            subTitle: 'Deposit via CLIQQ kiosk',
            value: 'ecpay'));
        // methodList.add(TransactionMethod(
        //     title: 'Dragonpay',
        //     subTitle: 'Deposit via Dragonpay',
        //     value: 'dragonpay'));
      }
    }

    setState(() {
      sendMethodList = methodList;
      methodSelected = sendMethodList[0];
    });
  }

  selectedMethodView() {
    switch (methodSelected.value) {
      case 'tagcash':
        return DepositTagcashScreen(wallet: widget.wallet);
        break;
      case 'stellar':
        return DepositStellarScreen(wallet: widget.wallet);
        break;
      case 'bank':
        return DepositBankScreen(wallet: widget.wallet);
        break;
      case 'seven':
        return DepositSevenScreen(wallet: widget.wallet);
        break;
      case 'ecpay':
        return DepositEcpayScreen(wallet: widget.wallet);
        break;
      case 'dragonpay':
        return DepositSevenScreen(wallet: widget.wallet);
        break;
      default:
        return DepositTagcashScreen(wallet: widget.wallet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'add_money'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: DropdownButtonFormField<TransactionMethod>(
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  border: const OutlineInputBorder(),
                ),
                value: methodSelected,
                icon: Icon(Icons.arrow_downward),
                items: sendMethodList.map<DropdownMenuItem<TransactionMethod>>(
                    (TransactionMethod value) {
                  return DropdownMenuItem<TransactionMethod>(
                    value: value,
                    child: Text(
                      value.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (TransactionMethod method) {
                  setState(() {
                    methodSelected = method;
                  });
                }),
          ),
          Expanded(
            child: Container(
              child: selectedMethodView(),
            ),
          ),
        ],
      ),
    );
  }
}
