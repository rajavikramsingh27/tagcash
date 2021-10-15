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

class SendInvoiceScreen extends StatefulWidget {
  String invoice_id, customer_email, invoice_no, total_amout, send_type;

  SendInvoiceScreen(
      {Key key,
      this.invoice_id,
      this.customer_email,
      this.invoice_no,
      this.total_amout,
      this.send_type})
      : super(key: key);

  @override
  _SendInvoiceScreenState createState() => _SendInvoiceScreenState(
      invoice_id, customer_email, invoice_no, total_amout, send_type);
}

class _SendInvoiceScreenState extends State<SendInvoiceScreen> {
  String invoice_id,
      customer_email,
      invoice_no,
      company,
      total_amout,
      send_type;
  bool isLoading = false;

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  bool option_send = false;
  bool option_attach = false;

  _SendInvoiceScreenState(String invoice_id, String customer_email,
      String invoice_no, String total_amout, String send_type) {
    this.invoice_id = invoice_id;
    this.customer_email = customer_email;
    this.invoice_no = invoice_no;
    this.total_amout = total_amout;
    this.send_type = send_type;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConfig();
    if (send_type == 'edit') {
      _toController.text = customer_email;
      _messageController.text = 'Here\' Invoice #' +
          invoice_no +
          'for the total amount of\nPHP$total_amout';
    }
  }

  getOptionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    setState(() {
      option_send = prefs.getBool('option_send');
      option_attach = prefs.getBool('option_attach');
    });
  }

  void sendInvoice() async {
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
        await NetworkHelper.request('invoicing/sendInvoice', apiBodyObj);

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

  void getConfig() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/getConfig');


    if (response['status'] == 'success') {
      var jsonn = response['result'];

      if (send_type == 'edit') {
        setState(() {
          company = jsonn[0]['company'];
          _subjectController.text = 'Invoice #' + invoice_no + 'from' + company;
        });
      }

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
          title: 'Send Invoice',
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
                                sendInvoice();
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
