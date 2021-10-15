import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/wallet/models/bank_deposit.dart';
import 'package:tagcash/components/date_time_form_field.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/image_select_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/apps/wallet/history/deposit_bank_history.dart';

enum BankingMethod { otc, ot }

class DepositBankScreen extends StatefulWidget {
  final Wallet wallet;

  const DepositBankScreen({Key key, this.wallet}) : super(key: key);

  @override
  _DepositBankScreenState createState() => _DepositBankScreenState();
}

class _DepositBankScreenState extends State<DepositBankScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  TextEditingController _amountController;
  TextEditingController _transactionIdController;
  TextEditingController _dateTimeController;

  String amountDeposit;
  bool depositPossible = false;
  Future<List<BankDeposit>> bankOptions;
  BankDeposit bankSelected;
  BankingMethod depositMethodSelected = BankingMethod.otc;

  List<int> _transactionSlipFile;
  List<int> _selfiFile;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _transactionIdController = TextEditingController();
    _dateTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _dateTimeController.dispose();
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
          depositPossible = true;
          amountDeposit = amountValue;
          if (widget.wallet.walletId == 1) {
            depositMethodSelected = BankingMethod.otc;
          } else {
            depositMethodSelected = BankingMethod.ot;
          }
        });

        bankOptions = loadBanksListCall();
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'transaction_limit'),
            message:
                '${getTranslated(context, 'exceed_maximum_transaction_limit')} ${getTranslated(context, 'transaction_limit')} PHP  ${responseMap['in_remaining_amount']}');
      }
    }
  }

  Future<List<BankDeposit>> loadBanksListCall() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['method'] = 'cash_in';
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('bank/list', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    List responseList = response['data'];

    List<BankDeposit> getData = responseList.map<BankDeposit>((json) {
      return BankDeposit.fromJson(json);
    }).toList();

    if (getData.length != 0) {
      bankSelected = getData[0];
    }
    return getData;
  }

  void methodChangeHandler(BankingMethod value) {
    setState(() {
      depositMethodSelected = value;
    });
  }

  void depositClickHandler() async {
    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Map<String, String> apiBodyObj = {};

    if (depositMethodSelected == BankingMethod.otc) {
      apiBodyObj['banking_method'] = 'otc';

      apiBodyObj['image'] = base64Encode(_transactionSlipFile);
      apiBodyObj['selfie'] = base64Encode(_selfiFile);
    } else {
      apiBodyObj['banking_method'] = 'ot';
      apiBodyObj['transaction_id'] = _transactionIdController.text;

      DateTime dt = DateTime.parse(_dateTimeController.text);
      apiBodyObj['date'] = DateFormat('yyyy-MM-dd').format(dt);
      apiBodyObj['time'] = DateFormat('h:m:s').format(dt);
    }

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['bank_code'] = bankSelected.bankName;

    Map<String, dynamic> response =
        await NetworkHelper.request('deposit/bank', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(getTranslated(context, 'deposit')),
              content: Text(getTranslated(
                  context, 'deposit_details_submitted_successfully')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(getTranslated(context, 'ok')),
                ),
              ],
            );
          });
    } else {
      setState(() {
        transferClickPossible = true;
      });

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

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        padding: EdgeInsets.all(kDefaultPadding),
        children: [
          Text(getTranslated(context, 'deposit_bank_info')),
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
              : Form(
                  key: _formKey,
                  autovalidateMode: enableAutoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              getTranslated(context, 'amount'),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$amountDeposit ${widget.wallet.currencyCode}',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                          future: bankOptions,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<BankDeposit>> snapshot) {
                            if (snapshot.hasError) print(snapshot.error);

                            return snapshot.hasData
                                ? DropdownButtonFormField<BankDeposit>(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: getTranslated(context, 'bank'),
                                      border: const OutlineInputBorder(),
                                    ),
                                    value: bankSelected,
                                    icon: Icon(Icons.arrow_downward),
                                    items: snapshot.data
                                        .map<DropdownMenuItem<BankDeposit>>(
                                            (BankDeposit value) {
                                      return DropdownMenuItem<BankDeposit>(
                                        value: value,
                                        child: Text(
                                          value.bankFullName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return getTranslated(
                                            context, 'select_bank');
                                      }
                                      return null;
                                    },
                                    onChanged: (BankDeposit bank) {
                                      setState(() {
                                        bankSelected = bank;
                                      });
                                    })
                                : Center(child: Loading());
                          }),
                      if (bankSelected != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            getTranslated(context, 'deposit_into'),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        Text(
                          bankSelected.accountName,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        bankSelected.address.isNotEmpty
                            ? Text(
                                bankSelected.address,
                                style: Theme.of(context).textTheme.subtitle2,
                              )
                            : SizedBox(),
                        SizedBox(height: 4),
                        Text(getTranslated(context, 'acc_no')),
                        Text(
                          bankSelected.accountNumber,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                      if (bankSelected != null &&
                          widget.wallet.walletId != 1) ...[
                        SizedBox(height: 4),
                        Text(
                          getTranslated(context, 'swift_code'),
                        ),
                        Text(
                          bankSelected.switfCode,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                      widget.wallet.walletId == 1
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Radio(
                                    value: BankingMethod.otc,
                                    groupValue: depositMethodSelected,
                                    onChanged: methodChangeHandler,
                                  ),
                                  Text(
                                    getTranslated(context, 'over_the_counter'),
                                  ),
                                  Radio(
                                    value: BankingMethod.ot,
                                    groupValue: depositMethodSelected,
                                    onChanged: methodChangeHandler,
                                  ),
                                  Text(
                                    getTranslated(context, 'online'),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(),
                      depositMethodSelected == BankingMethod.otc
                          ? ImageSelectFormField(
                              icon: Icon(Icons.note),
                              labelText: getTranslated(context, 'deposit_slip'),
                              hintText: getTranslated(
                                  context, 'please_add_deposit_slip_image'),
                              source: ImageFrom.both,
                              crop: true,
                              onChanged: (img) {
                                if (img != null) {
                                  _transactionSlipFile = img;
                                  _formKey.currentState.validate();
                                }
                              },
                              validator: (img) {
                                if (img == null) {
                                  return getTranslated(
                                      context, 'add_a_deposit_slip');
                                }
                                return null;
                              },
                            )
                          : SizedBox(),
                      SizedBox(height: 20),
                      depositMethodSelected == BankingMethod.otc
                          ? ImageSelectFormField(
                              icon: Icon(Icons.person_outline),
                              labelText:
                                  getTranslated(context, 'selfie_with_slip'),
                              hintText:
                                  getTranslated(context, 'please_add_a_selfie'),
                              source: ImageFrom.camera,
                              crop: true,
                              onChanged: (img) {
                                if (img != null) {
                                  _selfiFile = img;
                                  _formKey.currentState.validate();
                                }
                              },
                              validator: (img) {
                                if (img == null) {
                                  return getTranslated(
                                      context, 'add_selfie_with_slip');
                                }
                                return null;
                              },
                            )
                          : SizedBox(),
                      depositMethodSelected == BankingMethod.ot
                          ? TextFormField(
                              controller: _transactionIdController,
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.receipt,
                                ),
                                labelText:
                                    getTranslated(context, 'transaction_id'),
                                hintText: getTranslated(
                                    context, 'deposit_transaction_id'),
                              ),
                              validator: (value) {
                                if (!Validator.isRequired(value)) {
                                  return getTranslated(context,
                                      'transaction_id_should_not_be_empty');
                                }
                                return null;
                              },
                            )
                          : SizedBox(),
                      depositMethodSelected == BankingMethod.ot
                          ? DateTimeFormField(
                              type: DateTimePickerType.dateTime,
                              controller: _dateTimeController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.date_range),
                                labelText: getTranslated(context, 'date'),
                                hintText:
                                    getTranslated(context, 'transaction_date'),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return getTranslated(
                                      context, 'please_select_a_valid_date');
                                }
                                return null;
                              },
                            )
                          : SizedBox(),
                      SizedBox(height: 20),
                      CustomButton(
                        label: getTranslated(context, 'send'),
                        onPressed: () {
                          setState(() {
                            enableAutoValidate = true;
                          });
                          if (_formKey.currentState.validate()) {
                            depositClickHandler();
                          }
                        },
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 20),
          DepositBankHistory(walletId: widget.wallet.walletId.toString()),
        ],
      ),
    );
  }
}
