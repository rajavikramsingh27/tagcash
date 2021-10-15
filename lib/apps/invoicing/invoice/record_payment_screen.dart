import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';

import '../../../constants.dart';
import 'creditcard_tab_screen.dart';
import 'manual_payment_tab_screen.dart';


class RecordPaymentScreen extends StatefulWidget {
  String invoice_id, payment_amount;

  RecordPaymentScreen({Key key, this.invoice_id, this.payment_amount}) : super(key: key);

  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState(invoice_id, payment_amount);
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> with SingleTickerProviderStateMixin{
  String invoice_id, payment_amount;
  bool isLoading = false;

  TabController _controller;


  bool option_send = false;
  bool option_attach = false;

  _RecordPaymentScreenState(String invoice_id, String payment_amount) {
    this.invoice_id = invoice_id;
    this.payment_amount = payment_amount;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new TabController(
      length: 2,
      vsync: this,
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Record Payment',
        ),

        body: Column(
          children: [
            textModule(),
            Container(
              padding: EdgeInsets.all(15),
              decoration: new BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
              child: TabBar(
                unselectedLabelColor:  Color(0xFFACACAC),
                labelColor:  kUserBackColor,
                indicatorWeight: 2,
                indicatorColor:  kPrimaryColor,
                controller: _controller,
                tabs: [
                  const Tab(text: 'CREDIT CARD'),
                  const Tab(text: 'MANUAL PAYMENT'),
                ],
              ),
            ),

            Flexible(child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  new CreditCardTabScreen(),
                  new ManualPaymentTabScreen(invoice_id),
                ],
              ),
            )
            ),

            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }
  Widget textModule(){
    return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                color: Color(0xFF535353).withOpacity(0.8),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                        flex: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment amount',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'PHP' + payment_amount,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )),
                    Flexible(
                        flex: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'PHP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

            ],
          ),
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
                              child:Icon(
                                Icons.close,
                              ),
                              onTap: (){
                                Navigator.of(context).pop();
                              },)
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child:  Text(
                      'Marking as sent',
                      style: TextStyle(
                        fontSize: 18,
                        color: kUserBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),



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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: RaisedButton(
                          padding: EdgeInsets.all(8),
                          color: kPrimaryColor,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Ok',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),),
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

