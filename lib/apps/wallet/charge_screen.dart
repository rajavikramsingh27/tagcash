import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/pin_entry_text_field.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/screens/qr_scan_screen.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class ChargeScreen extends StatefulWidget {
  final Wallet wallet;

  const ChargeScreen({Key key, this.wallet}) : super(key: key);

  @override
  _ChargeScreenState createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool transferClickPossible = true;

  TextEditingController _amountController;
  String scanUserId;

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

  void scanVoucherClicked() async {
    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    if (!Validator.isAmount(amountValue)) {
      showSnackBar(getTranslated(context, 'vouchers_error_amount_not_empty'));
      return;
    }

    FocusScope.of(context).unfocus();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanScreen(
          returnScan: true,
        ),
      ),
    );

    processQRScan(result);
  }

  void processQRScan(scanData) {
    if (Validator.isJSON(scanData)) {
      Map resultJson = jsonDecode(scanData);

      if (resultJson.containsKey('action')) {
        String actionInput = resultJson['action'].toUpperCase();

        if (actionInput == "QUICKPAY") {
          showSnackBar(getTranslated(context, 'not_charge_voucher'));
        } else if (actionInput == "CHARGE") {
          if (widget.wallet.walletId == resultJson['currency']) {
            quickpayRedume(resultJson['id']);
          } else {
            // tagEvents.emit("alertEvent", { type: "info", title: "Default Wallet", message: "Default wallets does not match. Please scan a Charge QR with same wallet." });
          }
        } else {
          showSnackBar(getTranslated(context, 'not_valid_qr_code'));
        }
      } else {
        showSnackBar(getTranslated(context, 'not_valid_qr_code'));
      }
    } else {
      String resultData = scanData;
      if (resultData.indexOf("https://tagcash.com/u/") != -1) {
        scanUserId = resultData.replaceFirst("https://tagcash.com/u/", '');
        searchUsersHandler(scanUserId);
      } else {
        showSnackBar(getTranslated(context, 'not_valid_qr_code'));
      }
    }
  }

  void quickpayRedume(String code) async {
    setState(() {
      isLoading = true;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['voucher'] = code;

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/redeem', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      _amountController.text = "";
      showSimpleDialog(context,
          title: getTranslated(context, 'transaction_confirmed'),
          message: '${_amountController.text} ${widget.wallet.currencyCode}');
    } else {
      if (response['error'] == 'invalid_or_expired_voucher') {
        showSnackBar(getTranslated(
            context, 'vouchers_error_invalid_or_expired_voucher'));
      } else if (response['error'] == 'expired_voucher') {
        showSnackBar(getTranslated(context, 'vouchers_error_expired_voucher'));
      } else if (response['error'] == 'Insufficient') {
        showSnackBar(
            getTranslated(context, 'vouchers_error_insufficient_funds'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  searchUsersHandler(String value) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['id'] = value;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      validateUserPin();
    } else {
      showSnackBar(getTranslated(context, 'not_valid_qr_code'));
    }
  }

  void validateUserPin() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(20.0), // content padding
                child: PinEntryTextField(
                  showFieldAsBox: true,
                  onSubmit: (String pin) {
                    Navigator.pop(context);
                    transferProcess(pin);
                  }, // end onSubmit
                ),
              ),
            ),
          );
        });
  }

  transferProcess(String pin) async {
    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['from_wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['to_wallet_id'] = widget.wallet.walletId.toString();

    apiBodyObj['charging'] = 'true';
    apiBodyObj['pin'] = pin;
    apiBodyObj['from_id'] = scanUserId;
    apiBodyObj['from_type'] = 'user';

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/transfer', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      _amountController.text = "";
      showSimpleDialog(context,
          title: getTranslated(context, 'transaction_confirmed'),
          message: '${_amountController.text} ${widget.wallet.currencyCode}');
    } else {
      TransferError.errorHandle(context, response['error']);
    }
  }

  void nfcChargeClicked() async {
    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    if (!Validator.isAmount(amountValue)) {
      showSnackBar(getTranslated(context, 'vouchers_error_amount_not_empty'));
      return;
    }

    FocusScope.of(context).unfocus();
    nfcProgressAlertShow();
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) ;

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var identifier = tag.data['nfca']['identifier'];

      final String tagId =
          identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
      Navigator.pop(context);
    });
  }

  stopNfcScan() {
    NfcManager.instance.stopSession();
  }

  nfcProgressAlertShow() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, 'charge_nfc'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${widget.wallet.currencyCode} ${_amountController.text}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.green),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.nfc),
                      Text(
                        getTranslated(context, 'waiting_nfc_touch'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      child: Text(getTranslated(context, 'cancel')),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ),
            ),
          );
        }).whenComplete(() => stopNfcScan());
  }

  void nfcChargeCall(String nfcIdData) async {
    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['nfc_id'] = nfcIdData;

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/charge', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      _amountController.text = "";
      showSimpleDialog(context,
          title: getTranslated(context, 'transaction_confirmed'),
          message: '${_amountController.text} ${widget.wallet.currencyCode}');
    } else {
      if (response['error'] == 'nfc_not_linked_to_user' ||
          response['error'] == 'nfc_linked_user_not_found') {
        showSnackBar(getTranslated(context, 'card_not_linked'));
      } else if (response['error'] == 'nfc_max_amount_error') {
        showSnackBar(getTranslated(context, 'amount_maximum_allowed_nfc'));
      } else if (response['error'] == 'duplicate_nfc_id_found') {
        showSnackBar(getTranslated(context, 'error_occurred'));
      } else {
        TransferError.errorHandle(context, response['error']);
      }
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
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'charge'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  icon: Icon(Icons.account_balance_wallet),
                  labelText: '${getTranslated(context, 'amount')} (PHP)',
                  hintText: getTranslated(context, 'enter_amount'),
                ),
                validator: (value) {
                  if (!Validator.isAmount(value)) {
                    return getTranslated(context, 'enter_valid_amount');
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text(getTranslated(context, 'scan_qr_code')),
                      onPressed: () => scanVoucherClicked(),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      child: Text(getTranslated(context, 'charge_nfc')),
                      onPressed: () => nfcChargeClicked(),
                    ),
                  ),
                ],
              ),
              Text(getTranslated(context, 'charge_message'))
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
