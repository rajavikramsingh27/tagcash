import 'package:flutter/material.dart';
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

class SendGoferScreen extends StatefulWidget {
  final Wallet wallet;

  const SendGoferScreen({Key key, this.wallet}) : super(key: key);

  @override
  _SendGoferScreenState createState() => _SendGoferScreenState();
}

class _SendGoferScreenState extends State<SendGoferScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  TextEditingController _amountController;
  TextEditingController _addressController;
  TextEditingController _notesController;

  String calculatedFeeAmount;
  String amountDeductTotal = '0';

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
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
    apiBodyObj['amount'] = amountValue;

    Map<String, dynamic> response = await NetworkHelper.request(
        'GoferDelivery/GetMoneyDeliveryFee', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      var feeValue = response['result'];
      double total = double.parse(amountValue) + feeValue;

      setState(() {
        calculatedFeeAmount = feeValue.toString();
        amountDeductTotal = total.toString();
      });
    } else {
      //TODO:check if gofer have these errors

      // if (response['error'] == "cashout_limit_exceeded") {
      //   showSimpleDialog(context,
      //       title: 'Transaction limit',
      //       message:
      //           'Requested amount is more than one time transaction limit for this remittance center. Possible amount is  ${response['cashout_limit']} PHP');
      // } else {
      //   showSimpleDialog(context,
      //       title: getTranslated(context, 'error'),
      //       message: getTranslated(context,'network_error_message'));
      // }
    }
  }

  transferClickHandler() async {
    setState(() {
      transferClickPossible = false;
      isLoading = true;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Receipt receiptData = Receipt(
      type: 'send_gofer',
      direction: 'out',
      walletId: widget.wallet.walletId,
      amount: amountDeductTotal,
      currencyCode: widget.wallet.currencyCode,
      narration: _notesController.text,
      name: _addressController.text,
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['delivery_address'] = _addressController.text;
    apiBodyObj['note'] = _notesController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('GoferDelivery/OrderMoney', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      // tagEvents.emit("alertEvent", { type: "info", title: "Withdrawal", message: "Successfully submitted a withdrawal request. We have sent you a validation email. Simply click on the link in the email you receive from us.", callback: confirmWithdrawalClosedHandler });
      // Map responseMap = response['result'];

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
                        CustomButton(
                          label: getTranslated(context, 'calculate_fee'),
                          color: Colors.grey,
                          onPressed: () => calculateFeeHandler(),
                        )
                        // <Tag.BlackButton Text="{loc.}" Clicked="{}"/>
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
                      minLines: 3,
                      maxLines: 5,
                      controller: _addressController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.place),
                        labelText: getTranslated(context, 'kyc_address'),
                        hintText: getTranslated(context, 'receiving_address'),
                      ),
                      validator: (value) {
                        if (!Validator.isRequired(value)) {
                          return getTranslated(
                              context, 'address_should_not_be_empty');
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
              isLoading
                  ? Container(child: Center(child: Loading()))
                  : SizedBox(),
            ],
          ),
          // RequestHistory(),
        ],
      ),
    );
  }
}
