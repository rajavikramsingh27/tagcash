import 'package:flutter/material.dart';
import 'package:tagcash/apps/wallet/send/send_agent_screen.dart';
import 'package:tagcash/apps/wallet/send/send_bankphp_screen.dart';
import 'package:tagcash/apps/wallet/send/send_gofer_screen.dart';
import 'package:tagcash/apps/wallet/send/send_reminittance_screen.dart';
import 'package:tagcash/apps/wallet/send/send_tagcash_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

import 'models/transaction_method.dart';
import 'send/send_bank_screen.dart';
import 'send/send_stellar_screen.dart';

class WalletSendScreen extends StatefulWidget {
  final Wallet wallet;

  const WalletSendScreen({Key key, this.wallet}) : super(key: key);

  @override
  _WalletSendScreenState createState() => _WalletSendScreenState();
}

class _WalletSendScreenState extends State<WalletSendScreen> {
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
        if (wallet.walletId == 1) {
          if (AppConstants.getServer() == 'beta') {
            methodList.add(TransactionMethod(
                title: getTranslated(context, 'bank'),
                subTitle: 'Bank',
                value: 'bankphp'));
          } else {
            methodList.add(TransactionMethod(
                title: getTranslated(context, 'bank'),
                subTitle: 'Bank',
                value: 'bank'));
          }
        } else {
          methodList.add(TransactionMethod(
              title: getTranslated(context, 'bank'),
              subTitle: 'Bank',
              value: 'bank'));
        }
      }

      if (wallet.walletId == 1) {
        methodList.add(TransactionMethod(
            title: getTranslated(context, 'remittance_center'),
            subTitle: 'Remittance Center',
            value: 'remittance'));
        methodList.add(TransactionMethod(
            title: getTranslated(context, 'cash_out_via_agent'),
            subTitle: 'Cash out via agent',
            value: 'agentcashout'));
        methodList.add(TransactionMethod(
            title: getTranslated(context, 'gofer_cash_out'),
            subTitle: 'Gofer Cash out',
            value: 'gofer'));
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
        return SendTagcashScreen(wallet: widget.wallet);
        break;
      case 'stellar':
        return SendStellarScreen(wallet: widget.wallet);
        break;
      case 'bankphp':
        return SendBankphpScreen(wallet: widget.wallet);
        break;
      case 'bank':
        return SendBankScreen(wallet: widget.wallet);
        break;
      case 'remittance':
        return SendReminittanceScreen(wallet: widget.wallet);
        break;
      case 'agentcashout':
        return SendAgentScreen(wallet: widget.wallet);
        break;
      case 'gofer':
        return SendGoferScreen(wallet: widget.wallet);
        break;
      default:
        return SendTagcashScreen(wallet: widget.wallet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'send'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: DropdownButtonFormField<TransactionMethod>(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
