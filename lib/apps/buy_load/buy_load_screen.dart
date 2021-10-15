import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/buy_load/models/telcom.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

import 'models/denomination.dart';

class BuyLoadScreen extends StatefulWidget {
  const BuyLoadScreen({Key key}) : super(key: key);

  @override
  _BuyLoadScreenState createState() => _BuyLoadScreenState();
}

class _BuyLoadScreenState extends State<BuyLoadScreen> {
  bool isLoading = false;
  bool isLoadingPro = false;
  bool transferClickPossible = true;

  List<Denomination> denominationOptions;

  Telcom selectedTelcom;
  Denomination selectedDenomination;
  TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    selectedTelcom = telcoms[0];
    denominationsListLoad();

    super.initState();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  newTelcomProcess(Telcom telcom) {
    setState(() {
      selectedTelcom = telcom;
    });

    denominationsListLoad();
  }

  denominationsListLoad() async {
    setState(() {
      isLoadingPro = true;
      selectedDenomination = null;
      denominationOptions = null;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['telco'] = selectedTelcom.value;

    Map<String, dynamic> response =
        await NetworkHelper.request('credit/getproductlist', apiBodyObj);

    List<Denomination> getData = [];
    List responseList = response['result'];

    if (responseList != null) {
      getData = responseList.map<Denomination>((json) {
        return Denomination.fromJson(json);
      }).toList();
      selectedDenomination = getData[0];
      denominationOptions = getData.toList();
    }

    setState(() {
      isLoadingPro = false;
    });
  }

  denominationsSelectClick(Denomination denomination) {
    setState(() {
      selectedDenomination = denomination;
    });
  }

  showDenominationList() {
    if (denominationOptions == null) {
      return;
    }
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: denominationOptions.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('${denominationOptions[index].denomination} PHP'),
                  subtitle: Text(denominationOptions[index].telcoTag),
                  onTap: () {
                    denominationsSelectClick(denominationOptions[index]);
                    Navigator.pop(context);
                  },
                );
              });
        });
  }

  transferClickHandler() async {
    if (selectedDenomination == null) {
      showSnackBar('Please select valid amount');
      return;
    }
    if (!isPhMobile(_numberController.text)) {
      showSnackBar('Phone number is invalid');
      return;
    }

    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['telco'] = selectedTelcom.value;
    apiBodyObj['amount'] = selectedDenomination.denomination;
    apiBodyObj['exttag'] = selectedDenomination.extTag;
    apiBodyObj['deno'] = selectedDenomination.telcoTag;
    apiBodyObj['cellphoneno'] = _numberController.text;
    apiBodyObj['wallet_type_id'] = '1';

    Map<String, dynamic> response =
        await NetworkHelper.request('credit/buyload', apiBodyObj);

    setState(() {
      isLoading = false;
      transferClickPossible = true;
    });
    if (response['status'] == 'success') {
      Receipt receiptData = Receipt(
        type: 'buy_load',
        direction: 'out',
        walletId: 1,
        amount: selectedDenomination.denomination,
        currencyCode: 'PHP',
        narration: '',
        name: 'BUY LOAD',
      );

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
      if (response['error'] == 'insufficient_balance') {
        showSnackBar(getTranslated(context, 'insufficient_balance'));
      } else if (response['error'] == 'dail_limit_exceeded') {
        showSimpleDialog(context,
            title: 'ERROR',
            message:
                'This buy load can\'t be completed because you\'ve reached your daily limit. Please try again later.');
      } else if (response['error'] ==
          'Server was unable to process request. ---> The URI prefix is not recognized.') {
        showSnackBar('Unable to process request. Please try again.');
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  bool isPhMobile(String value) {
    if (value.isEmpty) return false;

    var mobileRegExp = RegExp(r"^(09|\+639)\d{9}$");

    return mobileRegExp.hasMatch(value);
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Buy Load',
      ),
      body: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              TelcomMenu(onTelcomChange: (value) => newTelcomProcess(value)),
              SizedBox(height: 20),
              selectedDenomination != null
                  ? Card(
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        title: Text('${selectedDenomination.denomination} PHP'),
                        subtitle: Text(selectedDenomination.telcoTag),
                        trailing: Icon(Icons.arrow_downward_rounded),
                        onTap: () => showDenominationList(),
                      ),
                    )
                  : Center(child: Loading()),
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(
                  icon: Icon(Icons.phone_android_rounded),
                  labelText: 'Number(ex:09123456789)',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: transferClickPossible
                    ? () {
                        transferClickHandler();
                      }
                    : null,
                child: Text('BUY LOAD'),
              )
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}

class TelcomMenu extends StatefulWidget {
  final Function(Telcom) onTelcomChange;
  const TelcomMenu({
    Key key,
    this.onTelcomChange,
  }) : super(key: key);

  @override
  _TelcomMenuState createState() => _TelcomMenuState();
}

class _TelcomMenuState extends State<TelcomMenu> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: telcoms.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(top: 0, right: 20),
            child: GestureDetector(
              onTap: () {
                widget.onTelcomChange(telcoms[index]);
                setState(() {
                  selectedIndex = telcoms[index].id;
                });
              },
              child: Container(
                // height: 50,
                width: 84,
                child: Center(
                  child: Text(
                    telcoms[index].name,
                    textScaleFactor: 1,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: selectedIndex == telcoms[index].id
                              ? Colors.white
                              : Colors.black,
                        ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == telcoms[index].id
                      ? Colors.red
                      : Color(0xFFF8F8FA),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      blurRadius: 8,
                      color: Color(0xFFd8d7d7).withOpacity(1),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    ;
  }
}
