import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/screens/qr_scan_screen.dart';
import 'package:tagcash/services/networking.dart';

class VouchersRedeemScreen extends StatefulWidget {
  @override
  _VouchersRedeemScreenState createState() => _VouchersRedeemScreenState();
}

class _VouchersRedeemScreenState extends State<VouchersRedeemScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool isLoading;
  bool isResultView;
  String resultAmountShow;

  var codeInputControl = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLoading = false;
    isResultView = false;
    resultAmountShow = "";
  }

  redeemVoucher() async {
    if (!_formKey.currentState.validate()) return;

    setState(() {
      isLoading = true;
    });

    final apiBodyObj = {"voucher": codeInputControl.text};

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/redeem', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    final bool success = response["status"] == "success";

    if (success) {
      var result = response["result"];

      setState(() {
        isResultView = true;
        resultAmountShow =
            "${result['voucher_amount']} ${result['currency_code']}";
      });
    } else {
      var error = response["error"];

      String message = getTranslated(context, "vouchers_error_$error");
      if (message.isEmpty) message = getTranslated(context, "error_occurred");

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: new Text(message),
        duration: new Duration(seconds: 3),
      ));
    }
  }

  voucherScan() async {
    final qrData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanScreen(
          returnScan: true,
        ),
      ),
    );

    print(qrData);
    if (qrData != null) {
      try {
        var qrDataJson = jsonDecode(qrData);
        setState(() {
          codeInputControl = TextEditingController(text: qrDataJson["code"]);
        });
      } catch (Exception) {}
    }
  }

  Widget initialView() {
    return Column(
      children: [
        Container(
            width: 65,
            height: 65,
            margin: EdgeInsets.symmetric(vertical: 30),
            alignment: Alignment.center,
            child: Icon(Icons.article,
                size: 30, color: Theme.of(context).primaryColor),
            decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 1),
                borderRadius: BorderRadius.circular(75))),
        Container(
          margin: EdgeInsets.only(left: 25, top: 10, right: 25, bottom: 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: codeInputControl,
                  decoration: InputDecoration(
                    hintText: getTranslated(context, "vouchers_voucher_code"),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code_outlined,
                            size: 36,
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                        onPressed: voucherScan),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return getTranslated(
                          context, "vouchers_enter_voucher_code");
                    }
                    return null;
                  },
                ),
                Container(
                    padding: EdgeInsets.only(top: 25),
                    width: double.infinity,
                    child: CustomButton(
                        label: getTranslated(context, 'vouchers_process_code')
                            .toUpperCase(),
                        color: Theme.of(context).primaryColor,
                        onPressed: redeemVoucher)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget resultView() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
                child: Column(children: [
              Container(
                  width: 65,
                  height: 65,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 30),
                  child: Icon(Icons.check, size: 30, color: Colors.green),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(75))),
              Text(getTranslated(context, "transaction_confirmed"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 20),
              Text(resultAmountShow,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green))
            ])),
            SizedBox(
                width: double.infinity,
                child: CustomButton(
                    label: getTranslated(context, 'vouchers_redeem_more')
                        .toUpperCase(),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      setState(() {
                        isResultView = false;
                        resultAmountShow = null;
                        codeInputControl = TextEditingController(text: '');
                      });
                    }))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(children: [
          isResultView ? resultView() : initialView(),
          isLoading ? Center(child: Loading()) : SizedBox()
        ]),
      ),
    );
  }
}
