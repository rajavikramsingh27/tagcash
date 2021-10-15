import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/wallet/history/deposit_seven_history.dart';
import 'package:tagcash/apps/wallet/models/seven_deposit.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class DepositSevenScreen extends StatefulWidget {
  final Wallet wallet;

  const DepositSevenScreen({Key key, this.wallet}) : super(key: key);

  @override
  _DepositSevenScreenState createState() => _DepositSevenScreenState();
}

class _DepositSevenScreenState extends State<DepositSevenScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  TextEditingController _amountController = TextEditingController();

  String amountDeposit;
  bool depositPossible = false;
  String barcodeData;
  String barcodeExpiryDate;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void amountCheckClicked() async {
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

        generateBarcode();
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'transaction_limit'),
            message:
                '${getTranslated(context, 'exceed_maximum_transaction_limit')} ${getTranslated(context, 'transaction_limit')} : PHP  ${responseMap['in_remaining_amount']}');
      }
    }
  }

  generateBarcode() async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['type'] = 'deposit';
    apiBodyObj['amount'] = amountDeposit;

    Map<String, dynamic> response =
        await NetworkHelper.request('deposit/7connectNew', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['data'];
      setState(() {
        depositPossible = true;

        barcodeData = responseMap['pay_id'];
        barcodeExpiryDate = responseMap['expiryDate'];
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

  void transactionDetailShow(SevenDeposit value) {
    if (value.status == "UNPAID") {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: kBottomSheetShape,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.all(20),
                  child: BarcodeArea(
                    amountDeposit:
                        '${value.amount} ${widget.wallet.currencyCode}',
                    barcodeData: value.payId,
                    barcodeExpiryDate: value.expiryDate,
                  )),
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
              Text(getTranslated(context, 'seven_eleven_info')),
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
                  : barcodeData != null
                      ? BarcodeArea(
                          amountDeposit:
                              '$amountDeposit ${widget.wallet.currencyCode}',
                          barcodeData: barcodeData,
                          barcodeExpiryDate: barcodeExpiryDate,
                        )
                      : SizedBox(),
              SizedBox(height: 20),
              DepositSevenHistory(
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

class BarcodeArea extends StatelessWidget {
  const BarcodeArea({
    Key key,
    @required this.amountDeposit,
    @required this.barcodeData,
    @required this.barcodeExpiryDate,
  }) : super(key: key);

  final String amountDeposit;
  final String barcodeData;
  final String barcodeExpiryDate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 20),
      children: [
        Text(
          getTranslated(context, 'seven_eleven_message'),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          amountDeposit,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox(height: 10),
        Center(
          child: BarcodeWidget(
            barcode: Barcode.code128(),
            data: barcodeData,
            height: 100,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.white
                : Colors.black,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'You have until $barcodeExpiryDate to make the payment.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }
}
