import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

class CreateCurrencyScreen extends StatefulWidget {
  @override
  _CreateCurrencyScreenState createState() => _CreateCurrencyScreenState();
}

class _CreateCurrencyScreenState extends State<CreateCurrencyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  var codeInputControl = TextEditingController();
  var nameInputControl = TextEditingController();
  var amountInputControl = TextEditingController();
  var stellarAddressInputControl = TextEditingController();

  String selectedDecimal;
  bool canIssueMore = true;
  bool transferable = true;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  createCurrency() async {
    if (!formKey.currentState.validate()) return;

    setState(() {
      isLoading = true;
    });

    var currencyCode = codeInputControl.text.toString();

    final apiBodyObj = {
      "currency_code": currencyCode.toUpperCase(),
      "wallet_name": nameInputControl.text.toString(),
      "token_type_id": "1",
      "balance": amountInputControl.text,
      "decimal": selectedDecimal,
      "u2u": transferable ? "1" : "0",
      "c2c": transferable ? "1" : "0",
      "u2c": transferable ? "1" : "0",
      "c2u": transferable ? "1" : "0",
      "can_issue_more_later": canIssueMore ? "y" : "n",
      "exchange": "1",
      "allow_nfc_transfer": "y"
    };
    if (stellarAddressInputControl.text.isNotEmpty)
      apiBodyObj['stellar_issuer_address'] = stellarAddressInputControl.text;
    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/CreateToken', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    var status = response["status"].toString();
    var arr = response["result"];

    if (status == "success") {
      print("====================CreateToken call=====================");
      Navigator.of(context).pop({'status': 'createSuccess'});
    } else {
      var error = response["error"];

      var message = '';
      if (error == "charging_failed") {
        message = getTranslated(context, "insufficient_balance") +
            " (" +
            getTranslated(context, "required_balance") +
            " - " +
            arr["currency_code"].toString() +
            " " +
            arr["amount"].toString() +
            ")";
      } else if (error == "please_switch_to_merchant_account") {
        message = getTranslated(context, "please_switch_to_merchant_account");
      } else if (error == "wallet_name_missing") {
        message = getTranslated(context, "wallet_name_missing");
      } else if (error == "currency_code_data_missing") {
        message = getTranslated(context, "currency_code_data_missing");
      } else if (error == "currency_code_not_unique") {
        message = getTranslated(context, "duplicate_code_message");
      } else if (error == "allowded_decimals_are_0,1,2,3,4,5,6,7,8") {
        message =
            getTranslated(context, "allowded_decimals_are_0,1,2,3,4,5,6,7,");
      } else if (error == "can\'t update balance for this wallet") {
        message =
            getTranslated(context, "can_not_update_balance_for_this_wallet");
      } else if (error == "invalid_or_missing_payment_method_id") {
        message =
            getTranslated(context, "invalid_or_missing_payment_method_id");
      } else if (error == "missing_purchase_id_or_transaction_id") {
        message =
            getTranslated(context, "missing_purchase_id_or_transaction_id");
      } else if (error == "invalid_credit_card_purchase_info") {
        message = getTranslated(context, "invalid_credit_card_purchase_info");
      } else if (error == "no_active_plan_found") {
        message = getTranslated(context, "no_active_plan_found");
      } else {
        message = getTranslated(context, "error_occurred");
      }

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: new Text(getTranslated(context, 'error') + ': ' + message),
        duration: new Duration(seconds: 3),
      ));
    }
  }

  buildForm() {
    final codeFormField = TextFormField(
        keyboardType: TextInputType.text,
        controller: codeInputControl,
        validator: (value) {
          if (value.isEmpty) {
            return getTranslated(context, 'enter_currency_code');
          }
          if (isNumeric(value)) {
            var msg = getTranslated(context, "code_cannot_string");
            return msg;
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: getTranslated(context, 'code'),
        ));

    final nameFormField = TextFormField(
        keyboardType: TextInputType.text,
        controller: nameInputControl,
        validator: (value) {
          if (value.isEmpty) {
            return getTranslated(context, 'enter_name');
          }
          if (isNumeric(value)) {
            return 'Name should be a string';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: getTranslated(context, 'name'),
        ));

    final amountFormField = TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: amountInputControl,
      validator: (value) {
        if (value.isEmpty) {
          return getTranslated(context, 'enter_amount');
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: getTranslated(context, 'amount'),
      ),
    );

    final decimalFormField = DropdownButtonFormField<String>(
        hint: new Text("decimals"),
        isExpanded: true,
        value: selectedDecimal,
        items: <String>['0', '1', '2', '3', '4', '5', '6', '7', '8']
            .map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return getTranslated(context, 'select_decimals');
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            selectedDecimal = value;
          });
        });

    final transferableFormField = CheckboxListTile(
      title: Text(getTranslated(context, "transferable")),
      value: transferable,
      contentPadding: EdgeInsets.all(0),
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool value) {
        setState(() {
          transferable = value;
        });
      },
    );

    final canIssueMoreFormField = CheckboxListTile(
      title: Text(getTranslated(context, "issue_more_capitalize")),
      value: canIssueMore,
      contentPadding: EdgeInsets.all(0),
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool value) {
        setState(() {
          canIssueMore = value;
        });
      },
    );

    final stellarIssuerAddressField = TextFormField(
      keyboardType: TextInputType.text,
      controller: stellarAddressInputControl,
      decoration: InputDecoration(
        labelText: getTranslated(context, 'stellar_issuer_address'),
      ),
    );

    return Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: codeFormField),
            SizedBox(width: 20),
            Expanded(child: nameFormField)
          ]),
          Row(children: [
            Expanded(child: amountFormField),
            SizedBox(width: 20),
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.bottomCenter,
                  child: decimalFormField),
            )
          ]),
          SizedBox(child: canIssueMoreFormField),
          SizedBox(child: transferableFormField),
          SizedBox(child: stellarIssuerAddressField),
          Expanded(
              child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(top: 20),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      getTranslated(context, 'create'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              color: Theme.of(context).primaryColor,
              onPressed: createCurrency,
            ),
          )),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "create_currency_create_token"),
        ),
        body: Stack(children: [
          Container(
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
              child: Padding(padding: EdgeInsets.all(15), child: buildForm())),
          isLoading ? Center(child: Loading()) : SizedBox()
        ]));
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
