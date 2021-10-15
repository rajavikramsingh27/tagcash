import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';

class QuickpayScreen extends StatefulWidget {
  final Wallet wallet;

  const QuickpayScreen({Key key, this.wallet}) : super(key: key);

  @override
  _QuickpayScreenState createState() => _QuickpayScreenState();
}

class _QuickpayScreenState extends State<QuickpayScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  TextEditingController _amountController;

  String qrDataString;

  Timer timer;
  Duration timerInterval = Duration(seconds: 1);
  int totalTime = 60;
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    if (timer != null) {
      timer.cancel();
    }

    super.dispose();
  }

  void generateVoucherHandler() async {
    FocusScope.of(context).unfocus();

    if (timer != null) {
      timer.cancel();
    }
    qrDataString = null;

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    if (amountValue != '') {
      apiBodyObj['amount'] = amountValue;
    }
    // 1, hour , 2 day ,  3 seconds
    apiBodyObj['expiration_type'] = '3';
    apiBodyObj['expires_at'] = '60';
    apiBodyObj['open'] = '1';
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();
    apiBodyObj['voucher_count'] = '1';
    apiBodyObj['quick_pay'] = '1';

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/generate', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      displayCode(responseMap['codes'][0]);
    } else {
      if (response['error'] == 'no_tickets_is_required') {
        showSnackBar(getTranslated(context, 'insufficient_balance'));
      }
    }
  }

  void displayCode(String codes) {
    Map<String, String> dataObj = {};
    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    if (amountValue == "") {
      dataObj['action'] = 'CHARGE';
    } else {
      dataObj['action'] = 'QUICKPAY';
    }
    dataObj['currency'] = widget.wallet.walletId.toString();

    dataObj['id'] = codes;

    String qrString = jsonEncode(dataObj);
    setState(() {
      qrDataString = qrString;
    });

    _counter.value = 0;
    timer = Timer.periodic(timerInterval, tick);
  }

  void tick(_) {
    _counter.value++;

    if (_counter.value == totalTime) {
      generateVoucherHandler();
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
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'quickpay'),
      ),
      key: _scaffoldKey,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              Text(
                getTranslated(context, 'set_amount_business_charge'),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.account_balance_wallet,
                    ),
                    labelText:
                        '${getTranslated(context, 'amount')} (${widget.wallet.currencyCode})',
                    hintText: getTranslated(context, 'enter_amount'),
                  )),
              SizedBox(height: 20),
              CustomButton(
                label: getTranslated(context, 'vouchers_generate'),
                onPressed: transferClickPossible
                    ? () {
                        generateVoucherHandler();
                      }
                    : null,
              ),
              SizedBox(height: 20),
              qrDataString != null
                  ? Column(
                      children: [
                        Text(
                          getTranslated(context, 'qr_code_valid_minute'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        SizedBox(height: 10),
                        Text(
                          getTranslated(context, 'business_scan_claim_amount'),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: QrImage(
                            data: qrDataString,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            size: 240,
                            embeddedImage: AssetImage('assets/images/logo.png'),
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              size: Size(60, 60),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          builder:
                              (BuildContext context, int value, Widget child) {
                            return Text(
                              '${totalTime - value} s',
                              style: Theme.of(context).textTheme.subtitle1,
                            );
                          },
                          valueListenable: _counter,
                        )
                      ],
                    )
                  : SizedBox(),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
