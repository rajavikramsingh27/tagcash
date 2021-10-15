import 'package:flutter/material.dart';
import 'package:tagcash/apps/wallet/history/deposit_eclink_history.dart';
import 'package:tagcash/apps/wallet/models/eclink_deposit.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class DepositEcpayScreen extends StatefulWidget {
  final Wallet wallet;

  const DepositEcpayScreen({Key key, this.wallet}) : super(key: key);

  @override
  _DepositEcpayScreenState createState() => _DepositEcpayScreenState();
}

class _DepositEcpayScreenState extends State<DepositEcpayScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  TextEditingController _amountController;

  String amountDeposit = '';
  bool depositPossible = false;
  String eclinkPayID = '';
  String eclinkExpiryDate = '';

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  amountCheckClicked() {
    amountPossibleCheck();
  }

  amountPossibleCheck() async {
    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    if (!Validator.isAmount(amountValue)) {
      showSnackBar(getTranslated(context, 'vouchers_error_amount_not_empty'));
      return;
    }

    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['amount'] = amountValue;
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/AmountCanReceive', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];
      if (responseMap['success']) {
        setState(() {
          amountDeposit = amountValue;
        });

        createEclinkRequestHandler();
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'transaction_limit'),
            message:
                '${getTranslated(context, 'exceed_maximum_transaction_limit')} ${getTranslated(context, 'transaction_limit')} PHP  ${responseMap['in_remaining_amount']}');
      }
    }
  }

  createEclinkRequestHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountDeposit;

    Map<String, dynamic> response = await NetworkHelper.request(
        'deposit/EcpayEclinkCommitPayment', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      depositPossible = true;

      setState(() {
        eclinkPayID = response['reference_id'].toString();
        eclinkExpiryDate = response['expiry_date'];
      });
    } else {
      if (response['error'] == 'pending_request_found') {
        showSimpleDialog(context,
            title: getTranslated(context, 'pending_request'),
            message: getTranslated(context, 'you_have_a_pending_request'));
      } else if (response['error'] == 'incoming_limit_error') {
        showSimpleDialog(context,
            title: getTranslated(context, 'transaction_limit'),
            message:
                getTranslated(context, 'exceed_maximum_transaction_limit'));
      } else {
        TransferError.errorHandle(context, response['error']);
      }
    }
  }

  void transactionDetailShow(EclinkDeposit transactionData) {
    // if (transactionData.status == "UNPAID" && transactionData.payId != 0) {
    if (transactionData.status == "UNPAID") {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: kBottomSheetShape,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'CLIQQ',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 20),
                    Text(
                      getTranslated(
                          context, 'details_to_generate_payment_slip'),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      getTranslated(context, 'reference_number'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    Text(
                      transactionData.referenceId.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(height: 20),
                    Text(
                      getTranslated(context, 'amount'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    Text(
                      'PHP ${transactionData.amount}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'You have until ${transactionData.expiryDate} to make the payment.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              Text(getTranslated(context, 'generate_reference_number')),
              !depositPossible
                  ? ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        TextField(
                          controller: _amountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.account_balance_wallet,
                            ),
                            labelText:
                                '${getTranslated(context, 'amount')} (${widget.wallet.currencyCode})',
                            hintText: getTranslated(context, 'enter_amount'),
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          label: getTranslated(context, 'continue'),
                          onPressed: () => amountCheckClicked(),
                        ),
                      ],
                    )
                  : ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 20),
                        Text(
                          getTranslated(
                              context, 'details_to_generate_payment_slip'),
                          style: Theme.of(context).textTheme.subtitle2,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          getTranslated(context, 'reference_number'),
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          eclinkPayID,
                          style: Theme.of(context).textTheme.headline4,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          getTranslated(context, 'amount'),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${widget.wallet.currencyCode} $amountDeposit ',
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'You have until $eclinkExpiryDate to make the payment.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              DepositEclinkHistory(
                onTransactionClick: (value) => transactionDetailShow(value),
              ),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
