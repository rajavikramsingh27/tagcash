import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/wallet/history/send_bank_approve_history.dart';
import 'package:tagcash/apps/wallet/models/bank_approve.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class SendBankScreen extends StatefulWidget {
  final Wallet wallet;

  const SendBankScreen({Key key, this.wallet}) : super(key: key);

  @override
  _SendBankScreenState createState() => _SendBankScreenState();
}

class _SendBankScreenState extends State<SendBankScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  Future<List<BankApprove>> bankOptions;
  BankApprove bankSelected;

  TextEditingController _amountController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController _branchController = TextEditingController();
  TextEditingController _swiftCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    bankOptions = loadDirectBanksList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _nameController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _swiftCodeController.dispose();

    super.dispose();
  }

  Future<List<BankApprove>> loadDirectBanksList() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['method'] = 'cash_out';

    Map<String, dynamic> response =
        await NetworkHelper.request('bank/list', apiBodyObj);

    List responseList = response['data'];

    List<BankApprove> getData = responseList.map<BankApprove>((json) {
      return BankApprove.fromJson(json);
    }).toList();

    if (widget.wallet.walletId != 1) {
      getData.add(BankApprove(bankName: 'other', bankFullName: 'Other'));
    }

    if (getData.length != 0) {
      setState(() {
        bankSelected = getData[0];
      });
    }
    return getData;
  }

  bankSelectionChange(BankApprove bank) {
    setState(() {
      bankSelected = bank;
    });
  }

  transferClickHandler() async {
    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    setState(() {
      transferClickPossible = false;
      isLoading = true;
    });

    Receipt receiptData = Receipt(
      type: 'send_bankphp',
      direction: 'out',
      walletId: widget.wallet.walletId,
      amount: amountValue,
      currencyCode: widget.wallet.currencyCode,
      name: _nameController.text,
    );

    Map<String, String> apiBodyObj = {};
    apiBodyObj['amount'] = amountValue;
    apiBodyObj['bank_code'] = bankSelected.bankName;
    apiBodyObj['banking_method'] = "otc";
    apiBodyObj['bank_account_number'] = _accountNumberController.text;
    apiBodyObj['beneficiary_name'] = _nameController.text;
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();

    if (bankSelected.bankName == "other") {
      apiBodyObj['bank_name'] = _bankNameController.text;
      apiBodyObj['bank_branch'] = _branchController.text;
      apiBodyObj['swift_code'] = _swiftCodeController.text;
    } else {
      apiBodyObj['bank_name'] = bankSelected.bankFullName;
    }

    apiBodyObj['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    apiBodyObj['time'] = DateFormat('h:m:s').format(DateTime.now());

    Map<String, dynamic> response =
        await NetworkHelper.request('payment/bank', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      receiptData.narration =
          getTranslated(context, 'successfully_submitted_withdrawal_request');

      receiptData.transactionId = '';
      receiptData.date = DateTime.now().toString();

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
        children: [
          Stack(
            children: [
              Form(
                key: _formKey,
                autovalidateMode: enableAutoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  padding: EdgeInsets.all(kDefaultPadding),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                          getTranslated(context, 'choose_your_bank_message')),
                    ),
                    FutureBuilder(
                        future: bankOptions,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<BankApprove>> snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? DropdownButtonFormField<BankApprove>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: getTranslated(context, 'bank'),
                                    border: const OutlineInputBorder(),
                                  ),
                                  value: bankSelected,
                                  icon: Icon(Icons.arrow_downward),
                                  items: snapshot.data
                                      .map<DropdownMenuItem<BankApprove>>(
                                          (BankApprove value) {
                                    return DropdownMenuItem<BankApprove>(
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
                                  onChanged: (BankApprove newValue) =>
                                      bankSelectionChange(newValue),
                                )
                              : Center(child: Loading());
                        }),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                      controller: _accountNumberController,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, 'account_number'),
                      ),
                      validator: (value) {
                        if (!Validator.isRequired(value,
                            allowEmptySpaces: false)) {
                          return getTranslated(
                              context, 'please_enter_account_number');
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, 'beneficiary_name'),
                      ),
                      validator: (value) {
                        if (!Validator.isRequired(value,
                            allowEmptySpaces: true)) {
                          return getTranslated(
                              context, 'please_enter_beneficiary_name');
                        }
                        return null;
                      },
                    ),
                    if (bankSelected != null &&
                        bankSelected.bankName == 'other') ...[
                      TextFormField(
                        controller: _bankNameController,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, 'bank_name'),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value,
                              allowEmptySpaces: true)) {
                            return getTranslated(
                                context, 'please_enter_bank_name');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _branchController,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, 'branch'),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value,
                              allowEmptySpaces: true)) {
                            return getTranslated(
                                context, 'please_enter_branch');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _swiftCodeController,
                        decoration: InputDecoration(
                          labelText: getTranslated(context, 'swift_code'),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value,
                              allowEmptySpaces: true)) {
                            return getTranslated(
                                context, 'please_enter_swift_code');
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 20),
                    bankSelected != null
                        ? Text(
                            bankSelected.bankName == 'other'
                                ? getTranslated(context,
                                    'equivalent_charged_wire_transfer_fee')
                                : bankSelected.fee,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: kPrimaryColor),
                          )
                        : SizedBox(),
                    SizedBox(height: 20),
                    CustomButton(
                      label: getTranslated(context, 'transfer'),
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
                    )
                  ],
                ),
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
          SizedBox(height: 20),
          SendBankApproveHistory(walletId: widget.wallet.walletId.toString()),
        ],
      ),
    );
  }
}
