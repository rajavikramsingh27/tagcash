import 'package:flutter/material.dart';
import 'package:tagcash/apps/wallet/history/send_bank_history.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/apps/wallet/send/add_beneficiary.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/components/pin_entry_text_field.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

import '../models/bank.dart';
import '../models/beneficiary.dart';

class SendBankphpScreen extends StatefulWidget {
  final Wallet wallet;

  const SendBankphpScreen({Key key, this.wallet}) : super(key: key);

  @override
  _SendBankphpScreenState createState() => _SendBankphpScreenState();
}

class _SendBankphpScreenState extends State<SendBankphpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  Future<List<Bank>> bankOptions;
  Bank bankSelected;

  Future<List<Beneficiary>> beneficiaryList;
  Beneficiary beneficiarySelected;

  TextEditingController _amountController;
  TextEditingController _notesController;

  String calculatedFeeAmount;
  String amountDeductTotal = '0';

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _notesController = TextEditingController();

    bankOptions = loadDirectBanksList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<List<Bank>> loadDirectBanksList() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('payment/instaAndPesoNetBanks');

    List responseList = response['result'];

    List<Bank> getData = responseList.map<Bank>((json) {
      return Bank.fromJson(json);
    }).toList();

    if (getData.length != 0) {
      bankSelected = getData[0];
      bankChangeProcess();
    }
    return getData;
  }

  bankSelectionChange(Bank bank) {
    setState(() {
      bankSelected = bank;
    });

    bankChangeProcess();
  }

  bool bankingMethodChangePossible = false;

  String bankMethod;
  int _methodGroupValue = 0;

  bankChangeProcess() {
    String method;
    bool changePossible = false;
    _methodGroupValue = 0;

    if (bankSelected.bankCode == "UBP") {
      method = "UBP";
    } else {
      if (bankSelected.pesonetEnabled && bankSelected.instapayEnabled) {
        changePossible = true;
        method = "PESONET";
      } else if (bankSelected.pesonetEnabled == true) {
        method = "PESONET";
      } else if (bankSelected.instapayEnabled == true) {
        method = "INSTAPAY";
      }
    }
    setState(() {
      bankMethod = method;
      bankingMethodChangePossible = changePossible;
    });

    beneficiaryList = beneficiaryListCall();
  }

  methodChangeHandler(int value) {
    if (value == 0) {
      setState(() {
        bankMethod = "PESONET";
      });
    } else {
      setState(() {
        bankMethod = "INSTAPAY";
      });
    }
  }

  Future<List<Beneficiary>> beneficiaryListCall() async {
    setState(() {
      beneficiarySelected = null;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['bank_code'] = bankSelected.code.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('bank/ListBeneficiary', apiBodyObj);

    List responseList = response['data'];

    List<Beneficiary> getData = responseList.map<Beneficiary>((json) {
      return Beneficiary.fromJson(json);
    }).toList();

    if (getData.length != 0) {
      setState(() {
        beneficiarySelected = getData[0];
      });
    }
    return getData;
  }

  addBeneficiaryClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddBeneficiary(
                bankName: bankSelected.bank,
                bankCode: bankSelected.code.toString(),
              )),
    ).then((value) {
      if (value != null) {
        beneficiaryListCall();
      }
    });
  }

  transferClickHandler() {
    if (beneficiarySelected == null) {
      showSnackBar('Select beneficiary');
      return;
    }

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

    // if (bankMethod == "INSTAPAY" && amountValue > bankSelected.instapayLimit) {
    //     tagEvents.emit("toastShow", { message: "Amount is more than allowed limit" });
    //     return;
    // }

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
      name: beneficiarySelected.beneficiaryName,
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['pin'] = pin;
    apiBodyObj['amount'] = amountValue;

    if (bankMethod == "UBP") {
      apiBodyObj['bank_code'] = 'UBP';
    } else if (bankMethod == "PESONET") {
      apiBodyObj['bank_transfer_method'] = 'pesonet';
    } else if (bankMethod == "INSTAPAY") {
      apiBodyObj['bank_transfer_method'] = 'insta_pay';
    }
    apiBodyObj['beneficiary_id'] = beneficiarySelected.id.toString();

    if (_notesController.text != "") {
      apiBodyObj['description'] = _notesController.text;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('payment/bankOnline', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      if (response['result'] == "sent_for_processing") {
        receiptData.narration =
            'Successfully submitted a withdrawal request. Requests are processed within the day on a weekday.';
      } else {
        // if (directBankMethod.value == "UBP" ||
        //     directBankMethod.value == "INSTAPAY") {
        receiptData.narration =
            'Amount will be credited to your account. We have sent you a email with details.';

        // } else if (directBankMethod.value == "PESONET") {
        //         "Amount will be credited to your account within the day on a weekday. We have sent you a email with transaction details.",
        //   });
      }

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

      if (response.containsKey('error_from_bank')) {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'), message: response['error']);
      } else {
        if (response['error'] == 'invalid_bank_account_number') {
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'Account number is not valid');
        } else if (response['error'] == 'special_char_found_in_description') {
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'Special characters not possible in transaction note');
        } else if (response['error'] == 'cooling_period_amount_error') {
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'Amount will exceed transaction limit');
        } else {
          TransferError.errorHandle(context, response['error']);
        }
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
                          'Choose your bank and method to cashout and click request. Confirm with PIN.'),
                    ),
                    FutureBuilder(
                        future: bankOptions,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Bank>> snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? DropdownButtonFormField<Bank>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Bank',
                                    border: const OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  value: bankSelected,
                                  icon: Icon(Icons.arrow_downward),
                                  items: snapshot.data
                                      .map<DropdownMenuItem<Bank>>(
                                          (Bank value) {
                                    return DropdownMenuItem<Bank>(
                                      value: value,
                                      child: Text(
                                        value.bank,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select bank';
                                    }
                                    return null;
                                  },
                                  onChanged: (Bank newValue) =>
                                      bankSelectionChange(newValue),
                                )
                              : Center(child: Loading());
                        }),
                    bankingMethodChangePossible
                        ? Row(
                            children: [
                              Radio(
                                value: 0,
                                groupValue: _methodGroupValue,
                                onChanged: methodChangeHandler,
                              ),
                              Text(
                                'PESONET',
                              ),
                              Radio(
                                value: 1,
                                groupValue: _methodGroupValue,
                                onChanged: methodChangeHandler,
                              ),
                              Text(
                                'INSTAPAY',
                              )
                            ],
                          )
                        : SizedBox(),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        icon: Icon(Icons.account_balance_wallet),
                        labelText: 'Amount (${widget.wallet.currencyCode})',
                        hintText: getTranslated(context, 'enter_amount'),
                      ),
                      validator: (value) {
                        if (!Validator.isAmount(value)) {
                          return getTranslated(context, 'enter_valid_amount');
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Beneficiary',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder(
                              future: beneficiaryList,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Beneficiary>> snapshot) {
                                if (snapshot.hasError) print(snapshot.error);

                                return snapshot.hasData
                                    ? DropdownButtonFormField<Beneficiary>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText: 'Beneficiary',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                        value: beneficiarySelected,
                                        icon: Icon(Icons.arrow_downward),
                                        items: snapshot.data
                                            .map<DropdownMenuItem<Beneficiary>>(
                                                (Beneficiary value) {
                                          return DropdownMenuItem<Beneficiary>(
                                            value: value,
                                            child: Text(
                                              value.beneficiaryName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (Beneficiary newValue) {
                                          setState(
                                            () {
                                              beneficiarySelected = newValue;
                                            },
                                          );
                                        },
                                      )
                                    : Center(child: Loading());
                              }),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => addBeneficiaryClick(),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_box,
                                color: Colors.red,
                                size: 44,
                              ),
                              Text(
                                'ADD',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    bankSelected != null ? feeDisplay(context) : SizedBox(),
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
                    SizedBox(height: 20),
                    CustomButton(
                      label: 'TRANSFER',
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
          // RequestHistory(),
          SizedBox(height: 20),
          SendBankHistory(walletId: widget.wallet.walletId.toString()),
        ],
      ),
    );
  }

  Padding feeDisplay(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        bankMethod == "UBP" || bankMethod == "PESONET"
            ? bankSelected.pesonetFee
            : bankSelected.instapayFee,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: kPrimaryColor),
      ),
    );
  }
}
