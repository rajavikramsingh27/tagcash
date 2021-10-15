import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tagcash/components/wallets_dropdown.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/components/image_select_form_field.dart';
import 'package:tagcash/components/loading.dart';

import 'models/expense_merchant_list.dart';
import 'models/expense_type.dart';

class CreateExpenseScreen extends StatefulWidget {
  final data;
  CreateExpenseScreen({this.data});
  CreateExpensePage createState() => CreateExpensePage();
}

var merchantList = new List<MerchantList>();
var expenseType = new List<ExpenseType>();
bool otherExpenseTypeBo = false;
bool isLoading = false;
List<int> _receiptFile;
var claimUserId;
var expenseTypeId;
var walletId;

class CreateExpensePage extends State<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;
  MerchantList selectedUser;
  ExpenseType selectedExpense;
  final walletAmount = TextEditingController();
  final description = TextEditingController();
  final additionOtherTxt = TextEditingController();
  var obj;

  void initState() {
    merchantList.clear();
    obj = widget.data;
    merchantList.addAll(obj);
    otherExpenseTypeBo = false;
    getExpenseType();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    walletAmount.dispose();
    description.dispose();
    additionOtherTxt.dispose();
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  getExpenseType() async {
    Map<String, String> apiBodyObj = {};

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/ExpenseTypes', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        Iterable list = response['list'];
        expenseType = list.map((model) => ExpenseType.fromJson(model)).toList();
      });
    }
  }

  createExpenseRequest() async {
    if (walletId == null) {
      var msg = getTranslated(context, "expense_wallet_select");
      showMessage(msg);

      return;
    }

    Map<String, String> apiBodyObj = {};

    apiBodyObj['claimuser_id'] = claimUserId.toString();
    apiBodyObj['wallet_id'] = walletId.toString();
    apiBodyObj['amount'] = walletAmount.text.toString();
    apiBodyObj['description'] = description.text.toString();

    apiBodyObj['receipt'] = base64Encode(_receiptFile);

    apiBodyObj['type_id'] = expenseTypeId.toString();
    apiBodyObj['type_description'] = additionOtherTxt.text.toString();
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/Request', apiBodyObj);

    if (response["status"] == "success") {
      Navigator.pop(context, true);
    } else {
      if (response['error'] == 'user_not_verified') {
        var msg =
            getTranslated(context, "red_envelope_kyc_verification_failed");
        showMessage(msg);
      } else if (response['error'] == 'comm_not_verified') {
        var msg = getTranslated(context, "expense_group_verify");
        showMessage(msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "expense_create_request"),
      ),
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
                DropdownButtonFormField<MerchantList>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  hint: Text(getTranslated(context, "expense_select_group")),
                  value: selectedUser,
                  validator: (value) => value == null
                      ? getTranslated(context, "expense_please_select_group")
                      : null,
                  onChanged: (MerchantList value) {
                    setState(() {
                      selectedUser = value;
                      claimUserId = selectedUser.claimuserId;
                    });
                  },
                  items: merchantList.map((MerchantList user) {
                    return DropdownMenuItem<MerchantList>(
                      value: user,
                      child: Row(
                        children: <Widget>[
                          Text(user.communityName),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: WalletsDropdown(
                        currencyCode: ValueNotifier<String>('PHP'),
                        onSelected: (wallet) {
                          walletId = wallet.walletId;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: walletAmount,
                        validator: (walletAmount) {
                          if (walletAmount.isEmpty) {
                            var msg = getTranslated(
                                context, "expense_wallet_require");
                            return msg;
                          }
                          return null;
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          // icon: Icon(Icons.person),
                          labelText: getTranslated(context, "amount"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<ExpenseType>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  hint: Text(getTranslated(context, "amount")),
                  value: selectedExpense,
                  validator: (value) => value == null
                      ? getTranslated(context, "expense_select_expense_types")
                      : null,
                  onChanged: (ExpenseType value) {
                    setState(() {
                      selectedExpense = value;
                      expenseTypeId = selectedExpense.id;
                      if (selectedExpense.typeDetails == "Others") {
                        otherExpenseTypeBo = true;
                      } else {
                        otherExpenseTypeBo = false;
                      }
                    });
                  },
                  items: expenseType.map((ExpenseType type) {
                    return DropdownMenuItem<ExpenseType>(
                      value: type,
                      child: Row(
                        children: <Widget>[
                          Text(
                            type.typeDetails,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (otherExpenseTypeBo == true)
                  TextFormField(
                    controller: additionOtherTxt,
                    decoration: new InputDecoration(
                        labelText: getTranslated(context, "expense_other")),
                    validator: (additionOtherTxt) {
                      if (additionOtherTxt.isEmpty) {
                        var msg =
                            getTranslated(context, "expense_other_require");
                        return msg;
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  minLines: 2,
                  maxLines: null,
                  controller: description,
                  decoration: InputDecoration(
                      labelText: getTranslated(context, "expense_details")),
                  validator: (additionOtherTxt) {
                    if (additionOtherTxt.isEmpty) {
                      var msg =
                          getTranslated(context, "expense_details_require");
                      return msg;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ImageSelectFormField(
                  icon: Icon(Icons.note),
                  labelText: getTranslated(context, "expense_receipt"),
                  hintText: getTranslated(context, "expense_receipt_image"),
                  source: ImageFrom.both,
                  crop: true,
                  onChanged: (img) {
                    if (img != null) {
                      _receiptFile = img;
                      _formKey.currentState.validate();
                    }
                  },
                  validator: (img) {
                    if (img == null) {
                      var msg = getTranslated(context, "expense_receipt_image");
                      return msg;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(getTranslated(context, "expense_request_create")),
                  onPressed: () {
                    setState(() {
                      enableAutoValidate = true;
                    });
                    if (_formKey.currentState.validate()) {
                      createExpenseRequest();
                    }
                  },
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
