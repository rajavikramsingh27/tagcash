import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';

class EditPaymentScreen extends StatefulWidget {
  String invoice_id;

  EditPaymentScreen({Key key, this.invoice_id}) : super(key: key);

  @override
  _EditPaymentScreenState createState() => _EditPaymentScreenState(invoice_id);
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  bool isLoading = false;
  String invoice_id;

  String currentDate, invoiceDate;
  final TextEditingController _notesController = new TextEditingController();

  List<String> selectedefault = [];
  List<String> recordPaymentList = [];

  String payment_method = 'Bank Payment';
  String payment_account = 'Shareholder Loan';

  int pay_method_index = 0;
  String pay_method_name = 'Bank Payment';
  String pay_method_value = 'bank';
  String pay_method_namelocal = 'Bank Payment';
  int pay_method_indexlocal = 0;

  int pay_account_index = 1;
  String pay_account_name = 'Shareholder Loan';
  String pay_account_value = 'shareholder';
  String pay_account_namelocal = 'Shareholder Loan';
  int pay_account_indexlocal = 1;

  String note;

  _EditPaymentScreenState(String invoice_id) {
    this.invoice_id = invoice_id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    main();
    getRecordPayment();
  }

  // get current date
  main() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yMMMMd');
    var formatter1 = new DateFormat('yyyy-MM-dd');
    currentDate = formatter.format(now);
    invoiceDate = formatter1.format(now);
    print(currentDate); // 2016-01-25
  }

  void getRecordPayment() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = invoice_id;

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/GetRecordPayment', apiBodyObj);

    if (response['status'] == 'success') {
      var jsonn = response['result'];

      setState(() {
        currentDate = jsonn['payment_date'];
        pay_method_index = jsonn['payment_method']['index'];
        payment_method = jsonn['payment_method']['name'];
        pay_method_name = jsonn['payment_method']['name'];
        pay_method_value = jsonn['payment_method']['value'];
        pay_method_namelocal = jsonn['payment_method']['nameLocal'];
        pay_method_indexlocal = jsonn['payment_method']['indexLocal'];

        pay_account_index = jsonn['payment_account']['index'];
        pay_account_name = jsonn['payment_account']['name'];
        payment_account = jsonn['payment_account']['name'];
        pay_account_value = jsonn['payment_account']['value'];
        pay_account_namelocal = jsonn['payment_account']['nameLocal'];
        pay_account_indexlocal = jsonn['payment_account']['indexLocal'];

        _notesController.text = jsonn['note'];
        note = jsonn['note'];
      });

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  void recordPayment() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = invoice_id;
    apiBodyObj['record_payment'] = recordPaymentList.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/recordPayment', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Edit Payment',
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment date',
                        style: TextStyle(
                            color: kUserBackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                child: Container(
                                    padding:
                                        EdgeInsets.only(top: 15, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currentDate,
                                          style: TextStyle(
                                              color: kUserBackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                        InkWell(
                                          child: FaIcon(
                                            FontAwesomeIcons.times,
                                            size: 18,
                                            color: kUserBackColor,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              currentDate = '';
                                            });
                                          },
                                        )
                                      ],
                                    )),
                                onTap: () {
                                  _selectDate(context);
                                },
                              ),
                              Divider(
                                color: Color(0xFFACACAC),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Payment Method',
                        style: TextStyle(
                            color: kUserBackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          decoration: new BoxDecoration(
                              color: Color(0xfff2f3f5),
                              border: Border.all(
                                  color: Color(0xFFACACAC), width: 0.5),
                              borderRadius: BorderRadius.circular(5.0)),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          payment_method,
                                          style: TextStyle(
                                              color: kUserBackColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                        FaIcon(
                                          FontAwesomeIcons.angleDown,
                                          size: 16,
                                          color: Color(0xFFACACAC),
                                        ),
                                      ],
                                    )),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _PaymentMethodDialog(
                                          selectedText: selectedefault,
                                          onTextChanged: (cities) {
                                            selectedefault = cities;
                                            var str_Name = selectedefault
                                                .reduce((value, element) =>
                                                    value + element);
                                            setState(() {
                                              payment_method = str_Name;
                                              if (payment_method ==
                                                  'Bank Payment') {
                                                pay_method_index = 0;
                                                pay_method_name =
                                                    'Bank Payment';
                                                pay_method_value = 'bank';
                                                pay_method_namelocal =
                                                    'Bank Payment';
                                                pay_method_indexlocal = 0;
                                              } else if (payment_method ==
                                                  'Cash') {
                                                pay_method_index = 1;
                                                pay_method_name = 'Cash';
                                                pay_method_value = 'cash';
                                                pay_method_namelocal = 'Cash';
                                                pay_method_indexlocal = 1;
                                              } else if (payment_method ==
                                                  'Cheque') {
                                                pay_method_index = 2;
                                                pay_method_name = 'Cheque';
                                                pay_method_value = 'cheque';
                                                pay_method_namelocal = 'Cheque';
                                                pay_method_indexlocal = 2;
                                              } else if (payment_method ==
                                                  'Credit Card') {
                                                pay_method_index = 3;
                                                pay_method_name = 'Credit Card';
                                                pay_method_value =
                                                    'credit card';
                                                pay_method_namelocal =
                                                    'Credit Card';
                                                pay_method_indexlocal = 3;
                                              } else if (payment_method ==
                                                  'Paypal') {
                                                pay_method_index = 4;
                                                pay_method_name = 'Paypal';
                                                pay_method_value = 'paypal';
                                                pay_method_namelocal = 'Paypal';
                                                pay_method_indexlocal = 4;
                                              } else if (payment_method ==
                                                  'Other') {
                                                pay_method_index = 5;
                                                pay_method_name = 'Other';
                                                pay_method_value = 'other';
                                                pay_method_namelocal = 'Other';
                                                pay_method_indexlocal = 5;
                                              }
                                            });
                                          },
                                        );
                                      });
                                },
                              )
                            ],
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Payment Account',
                        style: TextStyle(
                            color: kUserBackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          decoration: new BoxDecoration(
                              color: Color(0xfff2f3f5),
                              border: Border.all(
                                  color: Color(0xFFACACAC), width: 0.5),
                              borderRadius: BorderRadius.circular(5.0)),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          payment_account,
                                          style: TextStyle(
                                              color: kUserBackColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                        FaIcon(
                                          FontAwesomeIcons.angleDown,
                                          size: 16,
                                          color: Color(0xFFACACAC),
                                        ),
                                      ],
                                    )),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _PaymentAccountDialog(
                                          selectedText: selectedefault,
                                          onTextChanged: (cities) {
                                            selectedefault = cities;
                                            var str_Name = selectedefault
                                                .reduce((value, element) =>
                                                    value + element);
                                            setState(() {
                                              payment_account = str_Name;
                                              if (payment_account ==
                                                  'Cash on Hand') {
                                                pay_account_index = 0;
                                                pay_account_name =
                                                    'Cash on Hand';
                                                pay_account_value = 'cash';
                                                pay_account_namelocal =
                                                    'Cash on Hand';
                                                pay_account_indexlocal = 0;
                                              } else if (payment_account ==
                                                  'Shareholder Loan') {
                                                pay_account_index = 1;
                                                pay_account_name =
                                                    'Shareholder Loan';
                                                pay_account_value =
                                                    'shareholder';
                                                pay_account_namelocal =
                                                    'Shareholder Loan';
                                                pay_account_indexlocal = 1;
                                              }
                                            });
                                          },
                                        );
                                      });
                                },
                              )
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Any account into which you can deposit and withdraw funds from',
                        style: TextStyle(
                            color: kUserBackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: TextField(
                          controller: _notesController,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 14),
                          decoration:
                              new InputDecoration(labelText: 'Memo/Notes'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Row(
                          children: [
                            Flexible(
                              child: ButtonTheme(
                                height: 45,
                                minWidth: MediaQuery.of(context).size.width,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                child: RaisedButton(
                                  color: Color(0xff2b2b2b),
                                  onPressed: () {
                                    note = _notesController.text;
                                    var recPayment =
                                        '{"payment_date" : "$currentDate", "payment_method" : {"index" : $pay_method_index, "name" : "$pay_method_name", "value" : "$pay_method_value", "nameLocal" : "$pay_method_namelocal", "indexLocal" : $pay_method_indexlocal}, "payment_account" : {"index" : $pay_account_index, "name" : "$pay_account_name", "value" : "$pay_account_value", "nameLocal" : "$pay_account_namelocal", "indexLocal" : $pay_account_indexlocal}, "note" : "$note"}';
                                    recordPaymentList.add("$recPayment");
                                    recordPayment();
                                  },
                                  child: Text(
                                    'Edit Payment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker(
      //we wait for the dialog to return
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );
    if (d != null) //if the user has selected a date
      setState(() {
        // we format the selected date and assign it to the state variable
        currentDate = new DateFormat.yMMMMd("en_US").format(d);

        var formatter1 = new DateFormat('yyyy-MM-dd');
        invoiceDate = formatter1.format(d);
        print(invoiceDate);
      });
  }
}

class _PaymentMethodDialog extends StatefulWidget {
  _PaymentMethodDialog({
    this.selectedText,
    this.onTextChanged,
  });

  final List<String> selectedText;
  final ValueChanged<List<String>> onTextChanged;

  @override
  __PaymentMethodDialogState createState() => __PaymentMethodDialogState();
}

class __PaymentMethodDialogState extends State<_PaymentMethodDialog> {
  List<String> _tempSelectedTxt = [];
  List<String> getData = new List<String>();

  @override
  void initState() {
    super.initState();
    _tempSelectedTxt = widget.selectedText;

    getData.add('Bank Payment');
    getData.add('Cash');
    getData.add('Cheque');
    getData.add('Credit Card');
    getData.add('Paypal');
    getData.add('Other');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.close,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  )),
                ],
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: getData.length,
                itemBuilder: (BuildContext context, int index) {
                  final cityName = getData[index];
                  return InkWell(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(getData[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: kUserBackColor,
                            )),
                      ),
                      onTap: () async {
                        _tempSelectedTxt.clear();
                        _tempSelectedTxt.add(getData[index]);
                        Navigator.of(context).pop();
                        widget.onTextChanged(_tempSelectedTxt);
//                        widget.onSelectedCountryIdChanged(_tempSelectedCountryId);
                      });
                }),
          ],
        ),
      ),
    );
  }
}

class _PaymentAccountDialog extends StatefulWidget {
  _PaymentAccountDialog({
    this.selectedText,
    this.onTextChanged,
  });

  final List<String> selectedText;
  final ValueChanged<List<String>> onTextChanged;

  @override
  __PaymentAccountDialogState createState() => __PaymentAccountDialogState();
}

class __PaymentAccountDialogState extends State<_PaymentAccountDialog> {
  List<String> _tempSelectedTxt = [];
  List<String> getData = new List<String>();

  @override
  void initState() {
    super.initState();
    _tempSelectedTxt = widget.selectedText;

    getData.add('Cash on Hand');
    getData.add('Shareholder Loan');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.close,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  )),
                ],
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: getData.length,
                itemBuilder: (BuildContext context, int index) {
                  final cityName = getData[index];
                  return InkWell(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(getData[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: kUserBackColor,
                            )),
                      ),
                      onTap: () async {
                        _tempSelectedTxt.clear();
                        _tempSelectedTxt.add(getData[index]);
                        Navigator.of(context).pop();
                        widget.onTextChanged(_tempSelectedTxt);
//                        widget.onSelectedCountryIdChanged(_tempSelectedCountryId);
                      });
                }),
          ],
        ),
      ),
    );
  }
}
