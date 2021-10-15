import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/utils/validator.dart';

class DepositTagcashScreen extends StatefulWidget {
  final Wallet wallet;

  const DepositTagcashScreen({Key key, this.wallet}) : super(key: key);

  @override
  _DepositTagcashScreenState createState() => _DepositTagcashScreenState();
}

class _DepositTagcashScreenState extends State<DepositTagcashScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  TextEditingController _amountController;
  TextEditingController _notesController;

  String qrDataString;

  String transferTo;
  String toTransferName;
  String toTransferIdType;
  String toTransferId;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  depositClickHandler() {
    FocusScope.of(context).unfocus();

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Map<String, String> dataObj = {};
    dataObj['action'] = 'PAY';
    dataObj['currency'] = widget.wallet.walletId.toString();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      dataObj['type'] = '1';
      dataObj['user'] = Provider.of<UserProvider>(context, listen: false)
          .userData
          .id
          .toString();

      dataObj['full_name'] =
          Provider.of<UserProvider>(context, listen: false).userData.firstName;
    } else {
      dataObj['type'] = '2';
      dataObj['user'] = Provider.of<MerchantProvider>(context, listen: false)
          .merchantData
          .id
          .toString();
      dataObj['full_name'] =
          Provider.of<MerchantProvider>(context, listen: false)
              .merchantData
              .name;
    }

    dataObj['amount'] = amountValue;
    dataObj['remarks'] = _notesController.text;

    String qrString = jsonEncode(dataObj);
    setState(() {
      qrDataString = qrString;
    });
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
      body: Form(
        key: _formKey,
        autovalidateMode: enableAutoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: EdgeInsets.all(kDefaultPadding),
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                icon: Icon(
                  Icons.account_balance_wallet,
                ),
                labelText:
                    '${getTranslated(context, 'amount')} ${widget.wallet.currencyCode}',
                hintText: getTranslated(context, 'enter_amount'),
              ),
              validator: (value) {
                if (!Validator.isAmount(value)) {
                  return getTranslated(context, 'enter_valid_amount');
                }
                return null;
              },
            ),
            // SizedBox(height: 10),
            // Text('Leave blank for sender to decide how much to send'),
            TextFormField(
              minLines: 3,
              maxLines: 5,
              controller: _notesController,
              decoration: InputDecoration(
                icon: Icon(Icons.note),
                labelText: getTranslated(context, 'notes'),
                hintText: getTranslated(context, "transaction_notes"),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: transferClickPossible
                  ? () {
                      setState(() {
                        enableAutoValidate = true;
                      });
                      if (_formKey.currentState.validate()) {
                        depositClickHandler();
                      }
                    }
                  : null,
              child: Text(getTranslated(context, 'create_request_qr_code')),
            ),

            qrDataString != null
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      getTranslated(context, 'scan_with_tagcash_app'),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SizedBox(),
            qrDataString != null
                ? Center(
                    child: QrImage(
                      data: qrDataString,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      size: 240,
                      embeddedImage: AssetImage('assets/images/logo.png'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(60, 60),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
