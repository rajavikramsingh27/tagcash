import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'option_screen.dart';

class SendReceiptScreen extends StatefulWidget {
  String invoice_id, customer_email, invoice_no, total_amout;

  SendReceiptScreen(
      {Key key,
      this.invoice_id,
      this.customer_email,
      this.invoice_no,
      this.total_amout})
      : super(key: key);

  @override
  _SendReceiptScreenState createState() => _SendReceiptScreenState(
      invoice_id, customer_email, invoice_no, total_amout);
}

class _SendReceiptScreenState extends State<SendReceiptScreen> {
  String invoice_id, customer_email, invoice_no, company, total_amout;
  bool isLoading = false;

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  bool option_send = false;
  bool option_attach = false;

  _SendReceiptScreenState(String invoice_id, String customer_email,
      String invoice_no, String total_amout) {
    this.invoice_id = invoice_id;
    this.customer_email = customer_email;
    this.invoice_no = invoice_no;
    this.total_amout = total_amout;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConfig();
    _toController.text = customer_email;
    _subjectController.text = 'Payment Receipt for Invoice #' + invoice_no;
    _messageController.text = 'Here\'s your payment receipt for Invoice #' +
        invoice_no +
        ' for the total amount of PHP$total_amout';
  }

  getOptionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    setState(() {
      option_send = prefs.getBool('option_send');
      option_attach = prefs.getBool('option_attach');
    });
  }

  void sendReceipt() async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = invoice_id;
    apiBodyObj['from'] = _fromController.text;
    apiBodyObj['message'] = _messageController.text;
    apiBodyObj['subject'] = _subjectController.text;
    apiBodyObj['attachCopy'] = option_attach.toString();
    apiBodyObj['sendCopy'] = option_send.toString();
    apiBodyObj['to'] = _toController.text;
//
    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/SendReceipt', apiBodyObj);

//
    if (response['status'] == 'Success') {
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

  void getConfig() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/getConfig');


    if (response['status'] == 'success') {
      var jsonn = response['result'];

      setState(() {
        company = jsonn[0]['company'];
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Send Receipt',
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
                controller: _toController,
                decoration: InputDecoration(
                  labelText: 'To',
                ),
                style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                ),
                style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _messageController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Message',
                ),
                style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
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
                        margin: EdgeInsets.only(right: 5),
                        width: MediaQuery.of(context).size.width,
                        child: ButtonTheme(
                          height: 40,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          child: RaisedButton(
                            padding: EdgeInsets.all(8),
                            color: kUserBackColor,
                            onPressed: () {
                              Navigator.of(context)
                                  .push(new MaterialPageRoute(
                                      builder: (context) => OptionScreen()))
                                  .then((val) => val ? getOptionData() : null);
                            },
                            child: Text(
                              'Options',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      )),
                      Flexible(
                          child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 5),
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
                              } else if (_subjectController.text == '') {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return _ValidationDialog(
                                        taxMessage:
                                            'Add subject to send invoice',
                                      );
                                    });
                              } else if (_messageController.text == '') {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return _ValidationDialog(
                                        taxMessage:
                                            'Add message to send invoice',
                                      );
                                    });
                              } else {
                                sendReceipt();
                              }
                            },
                            child: Text(
                              'Send email',
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
