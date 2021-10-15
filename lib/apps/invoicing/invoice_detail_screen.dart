import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/app_top_bar.dart';


class InvoiceDetailScreen extends StatefulWidget {
  String invoice_title, invoice_number, invoice_ponumber, invoice_summary;

  InvoiceDetailScreen({Key key, this.invoice_title, this.invoice_number, this.invoice_ponumber, this.invoice_summary}): super(key: key);

  @override
  _InvoiceDdetailScreenState createState() => _InvoiceDdetailScreenState(invoice_title, invoice_number, invoice_ponumber, invoice_summary);
}

class _InvoiceDdetailScreenState extends State<InvoiceDetailScreen> {
  final TextEditingController _invoice_titleController = new TextEditingController();
  final TextEditingController _invoice_numberController = new TextEditingController();
  final TextEditingController _invoice_ponumberController = new TextEditingController();
  final TextEditingController _invoice_summaryController = new TextEditingController();


  String invoice_title, invoice_number, invoice_ponumber, invoice_summary;

  _InvoiceDdetailScreenState(String invoice_title, String invoice_number, String invoice_ponumber, String invoice_summary){
    this.invoice_title = invoice_title;
    this.invoice_number = invoice_number;
    this.invoice_ponumber = invoice_ponumber;
    this.invoice_summary = invoice_summary;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _invoice_titleController.text = invoice_title;
      _invoice_numberController.text = invoice_number;
      if(invoice_ponumber != 'P.O/S.O. number'){
        _invoice_ponumberController.text = invoice_ponumber;
      }
      if(invoice_summary != 'Project name/description'){
        _invoice_summaryController.text = invoice_summary;
      }

    });
  }

  _showToast(String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(message),
        ],
      ),
    );}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Invoice Details',
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                total(),
              ],
            ),
          )
        ],
      ),
    );
  }


  Widget total() {
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(fontWeight: FontWeight.normal),
              controller: _invoice_titleController,
              decoration: new InputDecoration(
                  labelText: 'Invoice title*'
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _invoice_numberController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: new InputDecoration(
                  labelText: 'Invoice number*'
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _invoice_ponumberController,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: new InputDecoration(
                  labelText: 'P.O/S.O. number'
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _invoice_summaryController,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: new InputDecoration(
                  labelText: 'Summary'
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ButtonTheme(
              height: 45,
              minWidth: MediaQuery.of(context).size.width,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: RaisedButton(
                color: Color(0xff2b2b2b),
                onPressed: () {
                  if(_invoice_titleController.text == '' || _invoice_numberController.text == ''){
                    Fluttertoast.showToast(
                        msg: "Please fill all required fields to continue!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  } else{
                    addStringToSF(_invoice_titleController.text, _invoice_numberController.text, _invoice_ponumberController.text, _invoice_summaryController.text);
                    Navigator.pop(context, true);
                  }
                },
                child: Text('Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),),
              ),
            ),
          ],
        )

    );
  }

  addStringToSF(String invoice_title, String invoice_number, String invoice_ponumber, String invoice_summary) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('invoice_title', invoice_title);
    prefs.setString('invoice_number', invoice_number);
    prefs.setString('invoice_ponumber', invoice_ponumber);
    prefs.setString('invoice_summary', invoice_summary);
  }

}
