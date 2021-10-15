import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/invoicing/invoice/send_receipt_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';

import '../../../constants.dart';
import 'edit_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  String invoice_id, payment_amount, customer_email, invoice_no;

  PaymentScreen({Key key, this.invoice_id, this.payment_amount, this.customer_email, this.invoice_no}) : super(key: key);


  @override
  _PaymentScreenState createState() => _PaymentScreenState(invoice_id, payment_amount, customer_email, invoice_no);
}

class _PaymentScreenState extends State<PaymentScreen> {
  String invoice_id, payment_amount, customer_email, invoice_no;
  String currentDate, invoiceDate;
  List<String> selectmenu = [];

  _PaymentScreenState(String invoice_id, String payment_amount, String customer_email, String invoice_no) {
    this.invoice_id = invoice_id;
    this.payment_amount = payment_amount;
    this.customer_email = customer_email;
    this.invoice_no = invoice_no;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    main();
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



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Payments',
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                InkWell(
                  child: Container(
            child: Row(
            children: [
            Container(
            padding: EdgeInsets.all(8),
            color: kPrimaryColor,
            child: FaIcon(
              FontAwesomeIcons.moneyBillAlt,
              size: 20,
              color: Colors.white,
            ),
          ),

          SizedBox(width: 10),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHP'+payment_amount + ' paid using bank',
                  style: TextStyle(
                      color: kUserBackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                Text(
                  currentDate,
                  style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    ),
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (context) {
                          return _MenuDialog(
                            selectedText:selectmenu,
                            onTextChanged: (cities) {
                              selectmenu = cities;
                              var str_Name = selectmenu.reduce((value, element) => value + element);
                              setState(() {
                                if(str_Name == 'Send receipt'){
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(builder: (context) => SendReceiptScreen(invoice_id:invoice_id, customer_email: customer_email, invoice_no: invoice_no, total_amout: payment_amount))
                                  ).then((val)=>val?Navigator.pop(context,true):null);
                                } else if(str_Name == 'Edit payment'){
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(builder: (context) => EditPaymentScreen(invoice_id:invoice_id))
                                  ).then((val)=>val?Navigator.pop(context,true):null);
                                }
                              });
                            },
                          );
                        });
                  },
                )

              ],
            ),
          )
        ],
      ),
    );
  }

}



class _MenuDialog extends StatefulWidget {
  _MenuDialog({
    this.selectedText,
    this.onTextChanged,
  });

  final List<String> selectedText;
  final ValueChanged<List<String>> onTextChanged;


  @override
  _MenuDialogState createState() => _MenuDialogState();
}

class _MenuDialogState extends State<_MenuDialog> {
  List<String> _tempSelectedTxt = [];
  List<String> getData = new List<String>();

  @override
  void initState() {
    super.initState();
    _tempSelectedTxt = widget.selectedText;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Text(
                          'Send receipt',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        onTap: (){
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Send receipt');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      ),


                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        child:Text(
                          'Edit payment',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        onTap: (){
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Edit payment');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      ),
                    ],
                  )
              ),
            ),

          ],
        ),
      ),
    );

  }
}

