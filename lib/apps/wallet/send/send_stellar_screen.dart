import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class SendStellarScreen extends StatefulWidget {
  final Wallet wallet;

  const SendStellarScreen({Key key, this.wallet}) : super(key: key);

  @override
  _SendStellarScreenState createState() => _SendStellarScreenState();
}

class _SendStellarScreenState extends State<SendStellarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  TextEditingController _addressController;
  TextEditingController _amountController;
  TextEditingController _memoController;
  TextEditingController _authoriseController;

  bool stellarAuthorisePossible = false;
  bool memoTextEditable = true;

  String toStellerTransferAddress = '';
  String stellarAddressResolvedShow = '';
  String momoResolvedShow = '';

  @override
  void initState() {
    super.initState();

    _addressController = TextEditingController();
    _amountController = TextEditingController();
    _memoController = TextEditingController();
    _authoriseController = TextEditingController();

    // checkCommunityAndUserVerified();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _authoriseController.dispose();
    super.dispose();
  }

  void checkCommunityAndUserVerified() async {
    // setState(() {
    //     isLoading = true;
    //   });

    Map<String, dynamic> response =
        await NetworkHelper.request('verification/GetLevel');

    // setState(() {
    //   isLoading = false;
    // });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      var verifivationlevel = responseMap['verification_level'];

      if (Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective() ==
          'user') {
        if (verifivationlevel >= 3) {
          stellarAuthorisePossible = true;
        } else {
          stellarAuthorisePossible = false;
        }
      } else {
        if (verifivationlevel == 0) {
          stellarAuthorisePossible = false;
        } else {
          stellarAuthorisePossible = true;
        }
      }
      setState(() {});
    }
  }

  void stellerAddressInputChange(String addressInput) async {
    toStellerTransferAddress = addressInput;

    if (addressInput.indexOf("*test.tagcash.com") != -1 ||
        addressInput.indexOf("*tagcash.com") != -1) {
      setState(() {
        isLoading = true;
      });
      Map<String, String> apiBodyObj = {};
      apiBodyObj['federated_address'] = addressInput;

      Map<String, dynamic> response = await NetworkHelper.request(
          'stellar/ResolveFederatedAddress', apiBodyObj);

      setState(() {
        isLoading = false;
      });

      if (response['status'] == 'success') {
        Map responseMap = response['result'];

        toStellerTransferAddress = responseMap['address'];
        setState(() {
          stellarAddressResolvedShow = responseMap['address'];
          momoResolvedShow = responseMap['memo'];
          memoTextEditable = false;
        });
      } else {
        setState(() {
          stellarAddressResolvedShow = "";
          momoResolvedShow = "";
          memoTextEditable = true;
        });
        showSnackBar(getTranslated(context, 'invalid_address'));
      }
    } else {
      if (!memoTextEditable) {
        setState(() {
          momoResolvedShow = "";
          memoTextEditable = true;
        });
      }
    }
  }

  transferClickHandler() {
    // String addressInput = _addressController.text;
    String addressInput = toStellerTransferAddress;

    if (addressInput.indexOf("*") != -1 || Validator.isAddress(addressInput)) {
      setState(() {
        transferClickPossible = true;
      });

      FocusScope.of(context).unfocus();

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
                      addressInput,
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
      narration: '',
      name: _addressController.text,
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['from_wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['to_wallet_id'] = widget.wallet.walletId.toString();

    if (momoResolvedShow == '') {
      apiBodyObj['narration'] = _memoController.text;
    } else {
      apiBodyObj['narration'] = momoResolvedShow;
    }

    // apiBodyObj['to_crypto_address'] = _addressController.text;
    apiBodyObj['to_crypto_address'] = toStellerTransferAddress;

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

  void stellarAuthoriseClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['trustor'] = _authoriseController.text;
    apiBodyObj['assetCode'] = widget.wallet.currencyCode.toString();
    apiBodyObj['authorize'] = 'true';

    Map<String, dynamic> response =
        await NetworkHelper.request('stellar/Authorize', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      showSnackBar('Address authorised successfully');
      setState(() {
        _authoriseController.text = '';
      });
    }
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.badge),
                    labelText: getTranslated(context, 'kyc_address'),
                    hintText: getTranslated(
                        context, 'stellar_address_federation_address'),
                  ),
                  onChanged: (value) => stellerAddressInputChange(value),
                  validator: (value) {
                    if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                      return getTranslated(
                          context, 'stellar_address_federation_address');
                    }
                    return null;
                  },
                ),
                stellarAddressResolvedShow != ''
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(stellarAddressResolvedShow),
                      )
                    : SizedBox(),
                memoTextEditable
                    ? TextFormField(
                        controller: _memoController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.note_outlined),
                          labelText: getTranslated(context, 'memo'),
                        ),
                        // validator: (value) {
                        //   if (!Validator.isRequired(value,
                        //       allowEmptySpaces: false)) {
                        //     return 'Please enter memo';
                        //   }
                        //   return null;
                        // },
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          momoResolvedShow,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                stellarAuthorisePossible
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(6)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(getTranslated(context, 'authorise_message')),
                              TextFormField(
                                controller: _authoriseController,
                                decoration: InputDecoration(
                                  labelText:
                                      getTranslated(context, 'kyc_address'),
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                child:
                                    Text(getTranslated(context, 'authorise')),
                                onPressed: transferClickPossible
                                    ? () {
                                        stellarAuthoriseClickHandler();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
