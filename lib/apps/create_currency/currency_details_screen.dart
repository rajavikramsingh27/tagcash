import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/create_currency/models/token.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/common_methods.dart';

class CurrencyDetailsScreen extends StatefulWidget {
  const CurrencyDetailsScreen({this.token});

  final Token token;

  @override
  _CurrencyDetailsScreenState createState() => _CurrencyDetailsScreenState();
}

class _CurrencyDetailsScreenState extends State<CurrencyDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = false;
  double _amount;

  bool transferable = false;

  Token _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    transferable = _token.transferPermission.communityToUser;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  updateTokenDetails() async {
    setState(() {
      isLoading = true;
    });
    final apiBodyObj = {
      "id": _token.walletId.toString(),
      "currency_code": _token.currencyCode,
      "wallet_name": _token.walletName,
      "token_type_id": "1",
      "balance": _amount != null ? _amount.toString() : "",
      "decimal": _token.decimal.toString(),
      "u2u": transferable ? "1" : "0",
      "c2c": transferable ? "1" : "0",
      "u2c": transferable ? "1" : "0",
      "c2u": transferable ? "1" : "0",
      "can_issue_more_later": _token.canIssueMoreLater ? "y" : "n",
      "exchange": "1",
      "allow_nfc_transfer": "y"
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/CreateToken', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    var status = response["status"].toString();
    var arr = response['result'];

    if (status == "success") {
      print("====================CreateToken call=====================");

      List<TopUpDetails> topUpDetails =
          arr["top_up_details"].map<TopUpDetails>((json) {
        return TopUpDetails.fromJson(json);
      }).toList();

      setState(() {
        _token.topUpDetails = topUpDetails;
      });

//      _scaffoldKey.currentState.showSnackBar(SnackBar(
//        content: new Text(getTranslated(context, "token_created_successfully")),
//        duration: new Duration(seconds: 3),
//      ));
//      Navigator.of(context).pop();
      Navigator.of(context).pop({'status': 'updateSuccess'});
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

  @override
  Widget build(BuildContext context) {
    final transferableFormField = CheckboxListTile(
      title: Text(getTranslated(context, "transferable")),
      value: transferable,
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.all(0),
      onChanged: (bool value) {
        setState(() {
          transferable = value;
        });
      },
    );

    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(20, 25, 20, 25),
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 0.0,
                                offset: Offset(0.0, 0.0),
                              ),
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(_token.currencyCode,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16))),
                              Text(_token.walletName,
                                  style: TextStyle(color: Colors.white))
                            ])),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: Provider.of<ThemeProvider>(context)
                                            .isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 0.0,
                                        offset: Offset(0.0, 0.0),
                                      ),
                                    ]),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                            getTranslated(context, "isuances")),
                                        contentPadding: EdgeInsets.all(0),
                                        trailing: _token.canIssueMoreLater
                                            ? RaisedButton(
                                                child: Text(
                                                  getTranslated(
                                                      context, "issue_more"),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1
                                                      .copyWith(
                                                          color: Colors.white),
                                                ),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return IssueMoreDialog(
                                                          onSubmitted:
                                                              (double amount) {
                                                            setState(() {
                                                              _amount = amount;
                                                            });
                                                            updateTokenDetails();
                                                          },
                                                        );
                                                      });
                                                })
                                            : SizedBox(),
                                      ),
                                      SizedBox(height: 10),
                                      ..._token.topUpDetails
                                          .map((details) => Container(
                                                margin: EdgeInsets.only(top: 5),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey)),
                                                child: ListTile(
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    dense: true,
                                                    title: Text(
                                                        details.narration,
                                                        style: TextStyle(
                                                            fontSize: 14)),
                                                    subtitle:
                                                        Text(CommonMethods.formatDateTime(details.transferDate),
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                    trailing: Text(
                                                        CommonMethods.removeTrailingZeros(
                                                            details.amount),
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              )),
                                      Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: EdgeInsets.only(top: 20),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  child: transferableFormField),
                                              FlatButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        getTranslated(
                                                            context, 'update'),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                onPressed: updateTokenDetails,
                                              ),
                                            ],
                                          ))
                                    ]))))
                  ])),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ]));
  }
}

class IssueMoreDialog extends StatefulWidget {
  const IssueMoreDialog({this.onSubmitted});

  final void Function(double) onSubmitted;

  @override
  State createState() => new IssueMoreDialogState();
}

class IssueMoreDialogState extends State<IssueMoreDialog> {
  final formKey = GlobalKey<FormState>();
  var amountInputControl = TextEditingController();

  double amount;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: popupElements(),
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  popupElements() {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: Text(
            getTranslated(context, 'issue_more'),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
              fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(
          height: 3.0,
        ),
        Center(
          child: SizedBox(
            width: 40,
            height: 2.5,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
            padding: EdgeInsets.all(20),
            height: 190.0, // Change as per your requirement
            // width: 300.0, // Change as per your requirement
            child: Form(
                key: formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(child: amountFormField),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  getTranslated(context, 'issue'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              var amount =
                                  double.parse(amountInputControl.text);
                              widget.onSubmitted(amount);
                            }
                          },
                        ),
                      )
                    ])))
      ],
    );
  }
}
