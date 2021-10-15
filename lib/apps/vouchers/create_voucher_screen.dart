import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/own_wallet_select.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:flutter/services.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/components/snackbar_notification.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/apps/vouchers/vouchers_manage_screen.dart';
import 'package:tagcash/services/networking.dart';
import 'dart:convert';

class CreateVoucherScreen extends StatefulWidget {
  @override
  _CreateVoucherScreenState createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends State<CreateVoucherScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  //var vouchersCountInputControl = TextEditingController();

  final vouchersCountInputControl = TextEditingController(text: '1');
  var emailInputControl = TextEditingController();
  var amountInputControl = TextEditingController();
  var expiresControl = TextEditingController();

  int walletId;
  bool redemptionChargeStatus;

  String currencyCode;
  String selectedVoucherType = "open";
  String selectedRedemptionType = "redeemer";
  int selectedVoucherExpires = 2;
  int selectedVoucherRestriction = 1;

  int recWalletId = 0;
  List<String> voucherEmails = new List<String>();

  bool isLoading;
  List<Wallet> defaultwalletsList = [];

  @override
  void initState() {
    super.initState();
    isLoading = false;
    redemptionChargeStatus = false;
    getDefaultWallet();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Wallet>> getDefaultWallet() async {
    print(
        '============================getting default wallets============================');

    Map<String, dynamic> response =
        await NetworkHelper.request('user/DefaultWallet');

    if (response["status"] == "success") {
      setState(() {
        currencyCode = response['result']['currency_code'] ?? "";
        walletId = int.parse(response['result']['wallet_id']) ?? -1;
      });
    }
  }

  handleAddEmailUser() {
    var emailValue = emailInputControl.text.toLowerCase();

    if (emailValue.isEmpty || !Validator.isEmail(emailValue)) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "vouchers_error_enter_valid_email"));
      return;
    }

    var emailExist = voucherEmails.contains(emailValue);

    if (emailExist) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "vouchers_error_email_already_added"));
      return;
    }

    setState(() {
      voucherEmails.add(emailValue);
      emailInputControl = TextEditingController(text: '');
    });
  }

  emailErrorCheck() {
    var amountValue = amountInputControl.text.toLowerCase();
    var expiresValue = expiresControl.text.toLowerCase();

    if (voucherEmails.isEmpty) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "vouchers_error_enter_valid_email"));
      return;
    }

    if (amountValue.isEmpty) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "vouchers_error_amount_not_empty"));
      return;
    }

    if (currencyCode == '' || currencyCode == null) {
      SnackbarNotification.show(
          _scaffoldKey, getTranslated(context, "vouchers_wallet_empty"));
      return;
    }

    if (selectedVoucherExpires == 0 || selectedVoucherExpires == 1) {
      if (expiresValue.isEmpty) {
        SnackbarNotification.show(
            _scaffoldKey, getTranslated(context, "vouchers_expires_empty"));
        return;
      }
    }

    voucherEmailCall();
  }

  openErrorCheck() {
    var voucherAmt = vouchersCountInputControl.text.toLowerCase();
    var amountValue = amountInputControl.text.toLowerCase();
    var expiresValue = expiresControl.text.toLowerCase();

    if (voucherAmt.isEmpty) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "vouchers_error_no_of_vouchers"));
      return;
    }

    if (amountValue.isEmpty) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "vouchers_error_amount_not_empty"));
      return;
    }

    if (currencyCode == '' || currencyCode == null) {
      SnackbarNotification.show(
          _scaffoldKey, getTranslated(context, "vouchers_wallet_empty"));
      return;
    }

    if (selectedVoucherExpires == 0 || selectedVoucherExpires == 1) {
      if (expiresValue.isEmpty) {
        SnackbarNotification.show(
            _scaffoldKey, getTranslated(context, "vouchers_expires_empty"));
        return;
      }
    }

    voucherEmailCall();
  }

  Future voucherEmailCall() async {
    print('===============Email vouchers call =====================');

    setState(() {
      isLoading = true;
    });

    var expiration_type;
    var expires_at;

    var expiresValue = expiresControl.text.toLowerCase();
    var amountValue = amountInputControl.text.toLowerCase();
    var vouchersCountInput = vouchersCountInputControl.text.toLowerCase();

    // 1 - hour, 2 - day, 0 - never
    if (selectedVoucherExpires == 0) {
      expiration_type = 1;
      expires_at = expiresValue;
    } else if (selectedVoucherExpires == 1) {
      expiration_type = 2;
      expires_at = expiresValue;
    } else {
      expiration_type = 0;
      expires_at = 0;
    }

    var apiBodyObj = {};

    var emailArray = voucherEmails.toString();

    if (selectedVoucherType == 'email') {
      // if email checkbox selected
      apiBodyObj = {
        "open": '0',
        "email": json.encode(emailArray),
        "voucher_count": voucherEmails.length.toString(),
        "amount": amountValue.toString(),
        "wallet_id": walletId.toString(),
        "expiration_type": expiration_type.toString(),
        "expires_at": expires_at.toString(),
        "redemption_charge_creator": selectedRedemptionType.toString(),
      };
    } else {
      // if open checkbox selected
      apiBodyObj = {
        "open": '1',
        "voucher_count": vouchersCountInput,
        "unique_code": '1',
        "redemption_per_user": '1',
        "amount": amountValue.toString(),
        "wallet_id": walletId.toString(),
        "expiration_type": expiration_type.toString(),
        "expires_at": expires_at.toString(),
        "redemption_charge_creator": selectedRedemptionType.toString(),
      };
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/generate', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        isLoading = false;
      });

      // success redirect to back
      SnackbarNotification.show(
          _scaffoldKey, getTranslated(context, "vouchers_created"));
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.pop(context);
    } else {
      setState(() {
        isLoading = false;
      });
      var errorMessage = '';
      if (response["error"] == 'insuffcient_balance') {
        errorMessage = getTranslated(context, response["error"]);
      } else {
        errorMessage = getTranslated(context, "vouchers_vouchers_error");
      }
      // success redirect to back
      SnackbarNotification.show(_scaffoldKey, errorMessage);
      return;
    }
  }

  handleWalletChange(Wallet wallet) {
    setState(() {
      walletId = wallet.walletId;
      currencyCode = wallet.currencyCode;

      if (wallet.walletTypeNumeric == 0) {
        redemptionChargeStatus = true;
      }
    });
  }

  buildForm() {
    return Form(
        child: Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Row(children: [
              Radio<String>(
                groupValue: selectedVoucherType,
                value: "email",
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  print("Radio tile pressed $value");
                  setState(() {
                    selectedVoucherType = value;
                  });
                },
              ),
              Text(getTranslated(context, "email"),
                  style: TextStyle(fontSize: 15))
            ])),
            Expanded(
                child: Row(children: [
              Radio<String>(
                groupValue: selectedVoucherType,
                value: "open",
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  print("Radio tile pressed $value");
                  setState(() {
                    selectedVoucherType = value;
                  });
                },
              ),
              Text(getTranslated(context, "open"),
                  style: TextStyle(fontSize: 15))
            ]))
          ],
        ),
        SizedBox(height: 10),
        selectedVoucherType == "open"
            ? Row(children: [
                Expanded(
                    child: Text('No of vouchers',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15))),
                Expanded(
                    child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: vouchersCountInputControl,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Enter No Of Vouchers';
                    }
                    return null;
                  },
                ))
              ])
            : Row(children: [
                Expanded(
                  child: TextFormField(
                      controller: emailInputControl,
                      decoration: InputDecoration(hintText: 'Enter Email')),
                ),
                SizedBox(width: 20),
                Container(
                    width: 36,
                    height: 36,
                    color: Theme.of(context).primaryColor,
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        color: Colors.white,
                        icon: Icon(Icons.add),
                        onPressed: handleAddEmailUser))
              ]),
        SizedBox(height: 15),
        selectedVoucherType == "email" && voucherEmails.length > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                margin: EdgeInsets.only(bottom: 15),
                width: double.infinity,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: voucherEmails
                      .map((email) => Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                email,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              )),
                              SizedBox(width: 20),
                              Container(
                                  width: 20,
                                  height: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      color: Colors.white,
                                      icon: Icon(Icons.remove, size: 16),
                                      onPressed: () {
                                        var index =
                                            voucherEmails.indexOf(email);
                                        if (index > -1) {
                                          setState(() {
                                            voucherEmails.removeAt(index);
                                          });
                                        }
                                      }))
                            ],
                          )))
                      .toList(),
                ),
              )
            : SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OwnWalletSelect(
              currencyCode: currencyCode,
              onChange: handleWalletChange,
            ),
            SizedBox(width: 25),
            Expanded(
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'enter_a_valid_amount');
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                controller: amountInputControl,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'amount'),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              'Redemption charge from',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            )),
        Row(
          children: [
            Expanded(
                child: Row(children: [
              Radio<String>(
                groupValue: selectedRedemptionType,
                value: "redeemer",
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  print("Radio tile pressed $value");
                  setState(() {
                    selectedRedemptionType = value;
                  });
                },
              ),
              Text(getTranslated(context, "redeemer"))
            ])),
            Expanded(
                child: Row(children: [
              Radio<String>(
                groupValue: selectedRedemptionType,
                value: "creator",
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  print("Radio tile pressed $value");
                  setState(() {
                    selectedRedemptionType = value;
                  });
                },
              ),
              Text(getTranslated(context, "creator"))
            ]))
          ],
        ),
        Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                      child: Row(children: [
                    Radio<int>(
                      groupValue: selectedVoucherExpires,
                      value: 0,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        print("Radio tile pressed $value");
                        setState(() {
                          selectedVoucherExpires = value;
                        });
                      },
                    ),
                    Text(getTranslated(context, "hours"))
                  ])),
                  Expanded(
                      child: Row(children: [
                    Radio<int>(
                      groupValue: selectedVoucherExpires,
                      value: 1,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        print("Radio tile pressed $value");
                        setState(() {
                          selectedVoucherExpires = value;
                        });
                      },
                    ),
                    Text(getTranslated(context, "days")),
                  ])),
                  Expanded(
                      child: Row(children: [
                    Radio<int>(
                      groupValue: selectedVoucherExpires,
                      value: 2,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        print("Radio tile pressed $value");
                        setState(() {
                          selectedVoucherExpires = value;
                        });
                      },
                    ),
                    Text(getTranslated(context, "never"))
                  ])),
                ],
              ),
              (selectedVoucherExpires == 1 || selectedVoucherExpires == 0)
                  ? TextFormField(
                      controller: expiresControl,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, 'vouchers_expires'),
                      ),
                    )
                  : SizedBox(),
            ])),
        SizedBox(height: 20),
        selectedVoucherType == "open"
            ? Column(
                children: [
                  Row(children: [
                    Radio<int>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: selectedVoucherRestriction,
                      value: 0,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        print("Radio tile pressed $value");
                        setState(() {
                          selectedVoucherRestriction = value;
                        });
                      },
                    ),
                    Text(getTranslated(
                        context, "vouchers_unique_code_each_voucher"))
                  ]),
                  Row(children: [
                    Radio<int>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      groupValue: selectedVoucherRestriction,
                      value: 1,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        print("Radio tile pressed $value");
                        setState(() {
                          selectedVoucherRestriction = value;
                        });
                      },
                    ),
                    Text(getTranslated(
                        context, "vouchers_one_voucher_per_person"))
                  ])
                ],
              )
            : Row(),
        SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: CustomButton(
                label:
                    getTranslated(context, 'vouchers_generate').toUpperCase(),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  selectedVoucherType == "open"
                      ? openErrorCheck()
                      : emailErrorCheck();
                }))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "vouchers"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 0.0,
                            offset: Offset(0.0, 0.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.grey[800]
                            : Colors.white),
                    child: Padding(
                        padding: EdgeInsets.all(15), child: buildForm()))),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
