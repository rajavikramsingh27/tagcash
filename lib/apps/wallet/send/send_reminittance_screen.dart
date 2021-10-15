import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

import '../models/center_item.dart';

class SendReminittanceScreen extends StatefulWidget {
  final Wallet wallet;

  const SendReminittanceScreen({Key key, this.wallet}) : super(key: key);

  @override
  _SendReminittanceScreenState createState() => _SendReminittanceScreenState();
}

class _SendReminittanceScreenState extends State<SendReminittanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  Future<List<CenterItem>> remittanceCenterItems;

  TextEditingController _amountController;
  TextEditingController _namePickupController;
  TextEditingController _numberPickupController;

  CenterItem remittanceSelected;
  String calculatedFeeAmount;
  String amountDeductTotal = '0';

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _namePickupController = TextEditingController();
    _numberPickupController = TextEditingController();

    remittanceCenterItems = loadCentersListCall();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _namePickupController.dispose();
    _numberPickupController.dispose();
    super.dispose();
  }

  Future<List<CenterItem>> loadCentersListCall([String searchKey]) async {
    Map<String, dynamic> response =
        await NetworkHelper.request('remittanceCenters/list');

    List responseList = response['data'];

    List<CenterItem> getData = responseList.map<CenterItem>((json) {
      return CenterItem.fromJson(json);
    }).toList();

    return getData;
  }

  calculateFeeHandler() async {
    if (!Validator.isAmount(_amountController.text)) {
      return;
    }

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['rid'] = remittanceSelected.id.toString();
    apiBodyObj['amount'] = amountValue;

    Map<String, dynamic> response =
        await NetworkHelper.request('remittanceCenters/getFee', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Map resultObj = response['result'];
      var feeValue = resultObj['fee'];

      double total = double.parse(amountValue) + feeValue;

      setState(() {
        calculatedFeeAmount = feeValue.toString();
        amountDeductTotal = total.toString();
      });
    } else {
      if (response['error'] == "cashout_limit_exceeded") {
        showSimpleDialog(context,
            title: getTranslated(context, 'transaction_limit'),
            message:
                '${getTranslated(context, 'requested_amount_more_than_transaction_limit')} : ${response['cashout_limit']} PHP');
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'error_occurred'));
      }
    }
  }

  transferClickHandler() async {
    if (calculatedFeeAmount == null) {
      showSnackBar(
          getTranslated(context, 'calculate_fee_after_entering_amount'));
      return;
    }

    setState(() {
      transferClickPossible = false;
      isLoading = true;
    });

    FocusScope.of(context).unfocus();

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Receipt receiptData = Receipt(
      type: 'send_remittance',
      direction: 'out',
      walletId: widget.wallet.walletId,
      amount: amountDeductTotal,
      currencyCode: widget.wallet.currencyCode,
      narration:
          'Will be collected by ${_namePickupController.text}. Contact number ${_numberPickupController.text} ',
      name: remittanceSelected.name,
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['fee'] = calculatedFeeAmount;
    apiBodyObj['remittance_id'] = remittanceSelected.id.toString();

    apiBodyObj['pickup_name'] = _namePickupController.text;
    apiBodyObj['pickup_mobile'] = _numberPickupController.text;
    apiBodyObj['type'] = 'deposit';

    apiBodyObj['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    apiBodyObj['time'] = DateFormat('h:m:s').format(DateTime.now());

    Map<String, dynamic> response =
        await NetworkHelper.request('payment/remittanceCenter', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      receiptData.transactionId = response['message'];
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
                    FutureBuilder(
                        future: remittanceCenterItems,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<CenterItem>> snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? DropdownButtonFormField<CenterItem>(
                                  // hint: Text("Select Remittance Center"),
                                  decoration: InputDecoration(
                                    labelText: getTranslated(
                                        context, 'select_remittance_center'),
                                    border: const OutlineInputBorder(),
                                  ),
                                  value: remittanceSelected,
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  items: snapshot.data
                                      .map<DropdownMenuItem<CenterItem>>(
                                          (CenterItem value) {
                                    return DropdownMenuItem<CenterItem>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return getTranslated(
                                          context, 'select_remittance_center');
                                    }
                                    return null;
                                  },
                                  onChanged: (CenterItem newValue) {
                                    setState(() {
                                      remittanceSelected = newValue;
                                    });
                                  },
                                )
                              : Center(child: Loading());
                        }),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.account_balance_wallet,
                              ),
                              labelText: getTranslated(context, 'amount'),
                              hintText: getTranslated(context, 'enter_amount'),
                            ),
                            validator: (value) {
                              if (!Validator.isAmount(value)) {
                                return getTranslated(
                                    context, 'enter_valid_amount');
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => calculateFeeHandler(),
                          child: Text(getTranslated(context, 'calculate_fee')),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: calculatedFeeAmount != null
                          ? Text(
                              '${getTranslated(context, 'fee')} : $calculatedFeeAmount',
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          : Text(
                              getTranslated(context,
                                  'calculate_fee_after_entering_amount'),
                              style: Theme.of(context).textTheme.caption,
                            ),
                    ),
                    TextFormField(
                      controller: _namePickupController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText:
                            getTranslated(context, 'name_of_person_to_pickup'),
                      ),
                      validator: (value) {
                        if (!Validator.isRequired(value)) {
                          return getTranslated(context, 'please_enter_name');
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _numberPickupController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        icon: Icon(Icons.mobile_friendly),
                        labelText: getTranslated(
                            context, 'mobile_number_of_person_to_pickup'),
                      ),
                      validator: (value) {
                        if (!Validator.isMobile(value)) {
                          return getTranslated(
                              context, 'please_enter_mobile_number');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(getTranslated(context, 'total_amount_to_be_deducted')),
                    SizedBox(height: 10),
                    Text(
                      '${widget.wallet.currencyCode} $amountDeductTotal',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: kPrimaryColor),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
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
                      child: Text(getTranslated(context, 'transfer')),
                    ),
                  ],
                ),
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
          // RequestHistory(),
        ],
      ),
    );
  }
}
