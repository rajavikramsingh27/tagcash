import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';

class SendReminderScreen extends StatefulWidget {
  String invoice_id, customer_email, invoice_no, total_amount, payment_date;

  SendReminderScreen(
      {Key key,
      this.invoice_id,
      this.customer_email,
      this.invoice_no,
      this.total_amount,
      this.payment_date})
      : super(key: key);

  @override
  _SendReminderScreenState createState() => _SendReminderScreenState(
      invoice_id, customer_email, invoice_no, total_amount, payment_date);
}

class _SendReminderScreenState extends State<SendReminderScreen> {
  String invoice_id, customer_email, invoice_no, total_amount, payment_date;
  bool isLoading = false;

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();

  bool option_send = false;
  bool option_attach = false;

  _SendReminderScreenState(String invoice_id, String customer_email,
      String invoice_no, String total_amount, String payment_date) {
    this.invoice_id = invoice_id;
    this.customer_email = customer_email;
    this.invoice_no = invoice_no;
    this.total_amount = total_amount;
    this.payment_date = payment_date;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _toController.text = customer_email;

    var formatter = new DateFormat('yMMMMd');
    String d = formatter.format(DateTime.parse(payment_date)); //set formate
    payment_date = d;
  }

  getOptionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    setState(() {
      option_send = prefs.getBool('option_send');
      option_attach = prefs.getBool('option_attach');
    });
  }

  void sendReminder() async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = invoice_id;
    apiBodyObj['from'] = _fromController.text;
    apiBodyObj['to'] = _toController.text;
//
    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/SendReminder', apiBodyObj);

//
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
          title: 'Send reminder',
        ),
        body: Stack(
          children: [
            textModule(),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }

  Widget textModule() {
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _fromController,
                decoration: InputDecoration(
                  labelText: 'From',
                ),
                style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 10),
              TextField(
                readOnly: true,
                enableInteractiveSelection: true,
                controller: _toController,
                decoration: InputDecoration(
                  labelText: 'To',
                ),
                style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 20),
              Text(
                'Below is an example of the email reminder that your customer will receive:',
                style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Color(0xFFACACAC))),
                child: Column(
                  children: [
                    Text(
                      'Reminder For',
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 22,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Invoice #' + invoice_no,
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Due on ' + payment_date,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .apply(color: Color(0xFFACACAC)),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Unpaid',
                      style: TextStyle(
                          color: Color(0xff2CB5E2).withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 10),
                    Container(
                        margin: EdgeInsets.only(left: 50, right: 50),
                        child: Divider()),
                    SizedBox(height: 10),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Amount: ',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 22,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'PHP' + total_amount,
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Due: ',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 22,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            payment_date,
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                        margin: EdgeInsets.only(left: 50, right: 50),
                        child: Divider()),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.only(left: 50, right: 50),
                      width: MediaQuery.of(context).size.width,
                      child: ButtonTheme(
                        height: 40,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: RaisedButton(
                          padding: EdgeInsets.all(8),
                          color: kUserBackColor,
                          onPressed: () {},
                          child: Text(
                            'View Invoice',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            softWrap: false,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: ButtonTheme(
                          height: 40,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          child: RaisedButton(
                            padding: EdgeInsets.all(8),
                            color: kPrimaryColor,
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_fromController.text == '') {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return _ValidationDialog(
                                        taxMessage:
                                            'Add FROM address to send invoice',
                                      );
                                    });
                              } else if (_toController.text == '') {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return _ValidationDialog(
                                        taxMessage:
                                            'Add TO address to send invoice',
                                      );
                                    });
                              } else {
                                sendReminder();
                              }
                            },
                            child: Text(
                              'Send',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              )),
            ],
          ),
        )
      ],
    );
  }
}

class _ValidationDialog extends StatefulWidget {
  _ValidationDialog({
    this.taxMessage,
  });

  String taxMessage;

  @override
  _ValidationDialogState createState() => _ValidationDialogState();
}

class _ValidationDialogState extends State<_ValidationDialog> {
  String _taxMessages;

  @override
  void initState() {
    _taxMessages = widget.taxMessage;
    super.initState();
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
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Marking as sent',
                      style: TextStyle(
                        fontSize: 18,
                        color: kUserBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                _taxMessages,
                style: TextStyle(
                  fontSize: 16,
                  color: kUserBackColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ButtonTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: RaisedButton(
                          padding: EdgeInsets.all(8),
                          color: kPrimaryColor,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Ok',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
