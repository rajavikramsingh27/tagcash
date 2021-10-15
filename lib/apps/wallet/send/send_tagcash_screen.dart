import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/dialog_animated.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/screens/qr_scan_screen.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

enum SendTarget { user, merchant }

class SendTagcashScreen extends StatefulWidget {
  final Wallet wallet;

  const SendTagcashScreen({Key key, this.wallet}) : super(key: key);

  @override
  _SendTagcashScreenState createState() => _SendTagcashScreenState();
}

class _SendTagcashScreenState extends State<SendTagcashScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  SendTarget sendTargetSelected = SendTarget.user;

  TextEditingController _idController;
  TextEditingController _amountController;
  TextEditingController _notesController;

  String transferTo;
  String toTransferName;
  String toTransferIdType;
  String toTransferId;

  @override
  void initState() {
    super.initState();

    _idController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void sendTargetChangeHandler(SendTarget value) {
    setState(() {
      sendTargetSelected = value;
    });
  }

  getUserScanData() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanScreen(
          returnScan: true,
        ),
      ),
    );

    if (Validator.isJSON(result)) {
      Map resultJson = jsonDecode(result);

      if (resultJson.containsKey('action')) {
        String actionInput = resultJson['action'].toUpperCase();

        if (actionInput == "PAY") {
          _idController.text = resultJson['address'];
        }
      }
    } else {
      String resultData = result;
      if (resultData.indexOf("https://tagcash.com/") != -1) {
        String scanDataCheck =
            resultData.replaceFirst("https://tagcash.com/", '');

        _idController.text = scanDataClean(scanDataCheck);
      } else if (Validator.isAddress(resultData)) {
        _idController.text = resultData;
      }
    }

    setState(() {});
  }

  String scanDataClean(String value) {
    String returnId = value.substring(1);
    if (returnId.startsWith('/')) {
      returnId = returnId.substring(1);
    }
    return returnId;
  }

  transferClickHandler() {
    setState(() {
      transferClickPossible = false;
    });

    FocusScope.of(context).unfocus();

    String checkId = _idController.text;

    if (sendTargetSelected == SendTarget.user) {
      if (Validator.isMobile(checkId)) {
        searchUser(checkId, 'mobile');
      } else if (Validator.isNumber(checkId)) {
        searchUser(checkId, 'id');
      } else if (Validator.isEmail(checkId)) {
        transferTo = 'email';
        toTransferName = checkId;
        confirmAlertShow();
      } else if (checkId.indexOf("*") != -1) {
        transferTo = 'address';
        toTransferName = checkId;
        confirmAlertShow();
      } else if (Validator.isAddress(checkId)) {
        transferTo = 'address';
        toTransferName = checkId;
        confirmAlertShow();
      } else {
        setState(() {
          transferClickPossible = true;
        });
      }
    } else {
      if (Validator.isNumber(checkId)) {
        searchCommunity(checkId);
      } else {
        setState(() {
          transferClickPossible = true;
        });
      }
    }
  }

  searchUser(String value, String type) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    if (type == 'mobile') {
      apiBodyObj['mobile'] = value;
    } else {
      apiBodyObj['id'] = value;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];
      transferTo = 'id';

      toTransferIdType = "user";
      toTransferId = responseList[0]['id'].toString();
      toTransferName = responseList[0]['name'];
      confirmAlertShow();
    } else {
      setState(() {
        transferClickPossible = true;
      });
      showAnimatedDialog(context,
          title: getTranslated(context, 'error'),
          message: getTranslated(context, 'reward_id_invalid'));
    }
  }

  searchCommunity(String value) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = value;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];

      transferTo = 'id';
      toTransferIdType = "community";
      toTransferId = responseList[0]['id'].toString();
      toTransferName = responseList[0]['community_name'];

      confirmAlertShow();
    } else {
      setState(() {
        transferClickPossible = true;
      });
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: getTranslated(context, 'id_entered_not_valid'));
    }
  }

  confirmAlertShow() {
    setState(() {
      transferClickPossible = true;
    });
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
                    getTranslated(context, 'you_are_transferring'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${_amountController.text} ${widget.wallet.currencyCode}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  Text(
                    getTranslated(context, 'to'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 10),
                  Text(
                    toTransferName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                            label: getTranslated(context, 'cancel'),
                            color: Colors.grey,
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: CustomButton(
                            label: getTranslated(context, 'confirm'),
                            onPressed: () {
                              Navigator.pop(context);
                              transferAamound();
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  transferAamound() async {
    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Receipt receiptData = Receipt(
      type: 'send_tagcash',
      direction: 'out',
      walletId: widget.wallet.walletId,
      amount: amountValue,
      currencyCode: widget.wallet.currencyCode,
      narration: _notesController.text,
      name: toTransferName,
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['from_wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['to_wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['narration'] = _notesController.text;

    if (transferTo == 'id') {
      apiBodyObj['to_type'] = toTransferIdType;
      apiBodyObj['to_id'] = toTransferId;

      receiptData.toId = toTransferId;
      receiptData.toType = toTransferIdType;
    } else if (transferTo == 'email') {
      apiBodyObj['to_email'] = toTransferName;
    } else if (transferTo == 'address') {
      apiBodyObj['to_crypto_address'] = toTransferName;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/transfer', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      receiptData.transactionId = responseMap['transaction_id'];
      receiptData.date = responseMap['transfer_date'];
      receiptData.scratchcardGameId =
          responseMap['scratchcard_game_id'].toString();
      receiptData.winCombinationId =
          responseMap['win_combination_id'].toString();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            receipt: receiptData,
          ),
        ),
      );
    } else {
      setState(() {
        transferClickPossible = true;
      });
      TransferError.errorHandle(context, response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: enableAutoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              padding: EdgeInsets.all(kDefaultPadding),
              children: [
                Text(getTranslated(context, 'send_to')),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Radio(
                        value: SendTarget.user,
                        groupValue: sendTargetSelected,
                        onChanged: sendTargetChangeHandler,
                      ),
                      Text(
                        getTranslated(context, 'user'),
                      ),
                      SizedBox(width: 20),
                      Radio(
                        value: SendTarget.merchant,
                        groupValue: sendTargetSelected,
                        onChanged: sendTargetChangeHandler,
                      ),
                      Text(
                        getTranslated(context, 'businessprogram'),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _idController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: sendTargetSelected == SendTarget.user
                              ? getTranslated(context, 'reward_id_email')
                              : getTranslated(context, 'business_id'),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value,
                              allowEmptySpaces: false)) {
                            return sendTargetSelected == SendTarget.user
                                ? getTranslated(
                                    context, 'reward_request_id_email')
                                : getTranslated(
                                    context, 'please_enter_business_id');
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.qr_code_outlined),
                      onPressed: () => getUserScanData(),
                    )
                  ],
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    if (widget.wallet.walletTypeNumeric == 0) ...[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ]
                  ],
                  decoration: InputDecoration(
                    icon: Icon(Icons.account_balance_wallet),
                    labelText:
                        '${getTranslated(context, 'amount')} (${widget.wallet.currencyCode})',
                    hintText: getTranslated(context, 'enter_amount'),
                  ),
                  validator: (value) {
                    if (!Validator.isAmount(value)) {
                      return getTranslated(context, 'enter_valid_amount');
                    }
                    return null;
                  },
                ),
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
                  child: Text(getTranslated(context, 'send')),
                  onPressed: transferClickPossible
                      ? () {
                          setState(() {
                            enableAutoValidate = true;
                          });
                          if (_formKey.currentState.validate()) {
                            transferClickHandler();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
