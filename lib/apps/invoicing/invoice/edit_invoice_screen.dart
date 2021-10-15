import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/invoice/add_item_screen.dart';
import 'package:tagcash/apps/invoicing/invoice/payments_screen.dart';
import 'package:tagcash/apps/invoicing/invoice/record_payment_screen.dart';
import 'package:tagcash/apps/invoicing/invoice/send_invoice_screen.dart';
import 'package:tagcash/apps/invoicing/invoice/send_receipt_screen.dart';
import 'package:tagcash/apps/invoicing/invoice/send_reminder_screen.dart';
import 'package:tagcash/apps/invoicing/models/Invoice.dart';
import 'package:tagcash/apps/invoicing/models/add_item.dart';
import 'package:tagcash/apps/invoicing/models/item.dart';
import 'package:tagcash/apps/invoicing/models/tax.dart';
import 'package:tagcash/apps/invoicing/models/tax_total.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../invoice_detail_screen.dart';
import 'add_customer_screen.dart';
import 'invoice_preview_screen.dart';
import 'select_item_screen.dart';


class EditInvoiceScreen extends StatefulWidget {
  final String invoice_id;

  EditInvoiceScreen({Key key, this.invoice_id}) : super(key: key);

  @override
  _EditInvoiceScreenState createState() => _EditInvoiceScreenState(invoice_id);
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  //Edit
  String invoice_id;
  Future<List<Invoice>> invoiceList;
  List<Invoice> getInvoiceData = new List<Invoice>();

  final TextEditingController _notesController = new TextEditingController();
  final TextEditingController _footerController = new TextEditingController();
  Future<List<Item>> itemList;

  bool isLoading = false;
  String default_id = '', default_payment_term = 'On receipt', default_title = '', default_subheading = 'Project name/description', default_footer = '', default_notes = '';
  String invoice_no = '', invoice_status = '', items = '';
  String ponumber = 'P.O/S.O. number', po_so_number = '', summary = '';
  String currentDate;
  String invoiceDate;
  String customerId = '', customerName = '', customerEmail = '', customerAddress1 = '', customerAddress2 = '', customerCity = '',
      customerZipcode = '', customerState = '', customerCountry = '', phone = '';

  List<String> selectedefault = [];
  List<String> selectmenu = [];


  List<Item> getItem_Data = new List<Item>();
  List<AddItem> getData = new List<AddItem>();
  List<AddItem> getIdData = new List<AddItem>();

  List<Tax> getTaxData = new List<Tax>();
  int subTotal = 0;
  List<Tax_total> setTaxData = new List<Tax_total>();
  double total_amount = 0.0;
  double ttl_tax = 0.0;

  List<String> stufflist = [];
  List<String> taxlist = [];
  List<String> paymentduelist = [];

  var payment_due;
  var paymentDate;
  var Stuffjson;
  var Taxjson;


  _EditInvoiceScreenState(String invoice_id) {
    this.invoice_id = invoice_id;
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    invoiceList = loadStaffCommunities();
    main();
    getConfig();
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


  Future<List<Invoice>> loadStaffCommunities() async {

    print('loadStaffCommunities');
    setState(() {
      isLoading = true;
    });


    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/searchInvoice');

    List responseList = response['result'];

    getInvoiceData = responseList.map<Invoice>((json) {
      return Invoice.fromJson(json);
    }).toList();

    var jsonn = response['result'];


    for (var items in jsonn) {
      List<AddItem> getItemData = new List<AddItem>();
      Map myMap = items;
      if(myMap['id'] == invoice_id){
        default_title = myMap['invoice_name'];
        invoice_no = myMap['invoice_no'];
        invoice_status = myMap['status'];
        invoiceDate = myMap['invoice_date'];
        _notesController.text = myMap['note'];
        _footerController.text = myMap['footer'];
        var formatter = new DateFormat('yMMMMd');
        String d = formatter.format(DateTime.parse(myMap['invoice_date'])); //set formate
        currentDate = d;

        changePaymentDue( myMap['payment_due']['flag']); //change payment due

        customerId = myMap['customer']['id'];
        customerName = myMap['customer']['customer_name'];
        customerEmail = myMap['customer']['email'];

        if(myMap['customer']['address'] == '' || myMap['customer']['address'] == null){
          customerAddress1 = '';
          customerAddress2 = '';
          customerCity = '';
          customerZipcode = '';
          customerState = '';
          customerCountry = '';
        } else{
          customerAddress1 = myMap['customer']['address']['address1'];
          customerAddress2 = myMap['customer']['address']['address2'];
          customerCity = myMap['customer']['address']['city'];
          customerZipcode = myMap['customer']['address']['zipCode'];
          customerState = myMap['customer']['address']['state']['addressState'];
          customerCountry = myMap['customer']['address']['country']['addressCountry'];
        }


        phone = myMap['customer']['phone_no'];

        Stuffjson = myMap['stuff'];
        List responseList = myMap['stuff'];
        getData = responseList.map<AddItem>((json) {
          return AddItem.fromJson(json);
        }).toList();
        getIdData.addAll(getData);
        print(getData.length);

        for(int i=0; i<getData.length; i++){
          String id = getData[i].id;
          String quantity = getData[i].qty;
          var stuff = '{"id" : "$id", "quantity" : "$quantity"}';
          stufflist.add("$stuff");

          print("stufflist" + stufflist.toString());


          double d_price = double.parse(getData[i].price);
          int qun = int.parse(quantity);
          int price;
          price = d_price.toInt();
          price = qun * d_price.toInt();

          subTotal = subTotal + price;


          for(int j=0; j<getData[i].taxx.length; j++){
            Tax_total itm = new Tax_total();
            itm.id = getData[i].taxx[j].id;
            itm.name = getData[i].taxx[j].name;
            itm.rate = getData[i].taxx[j].rate;
            itm.tax_id = getData[i].taxx[j].tax_id;
            itm.recoverable = getData[i].taxx[j].recoverable;
            itm.compound = getData[i].taxx[j].compound;
            itm.price = price.toString();
            setTaxData.add(itm);
          }
//        setTaxData = getData[i].taxx;
        }

      }else{
      }

    }

    setState(() {
      isLoading = false;
    });

    return getInvoiceData;
  }

  changePaymentDue(String flag){
    if(flag == 'onreceipt'){
      default_payment_term =  'On receipt';
    }else if(flag == '15days'){
      default_payment_term =  'Within 15 days';
    }else if(flag == '30days'){
      default_payment_term =  'Within 30 days';
    }else if(flag == '45days'){
      default_payment_term =  'Within 45 days';
    }else if(flag == '60days'){
      default_payment_term =  'Within 60 days';
    }else if(flag == '90days'){
      default_payment_term =  'Within 90 days';
    }else if(flag == 'custom'){
      default_payment_term =  'Custom';
    }
    default_payment_due(default_payment_term); //set paymentdue
  }

  default_payment_due(String default_payment_term){
    if(default_payment_term == 'On receipt'){
      var today = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(today);
      payment_due = '{"flag" : "onreceipt", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");

    } else if(default_payment_term == 'Within 15 days'){

      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 15));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "15days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");

    }else if(default_payment_term == 'Within 30 days'){

      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 30));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "30days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");

    }else if(default_payment_term == 'Within 45 days'){

      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 45));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "45days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");

    }else if(default_payment_term == 'Within 60 days'){

      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 50));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "50days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");

    }else if(default_payment_term == 'Within 90 days'){

      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 90));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "90days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");

    }else if(default_payment_term == 'Custom'){
      payment_due = '{"flag" : "custom", "date" : $paymentDate}';
    }
  }

  getDefaultData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    default_title = prefs.getString('invoice_title');
    invoice_no = prefs.getString('invoice_number');

    String invoice_summary = prefs.getString('invoice_summary');
    if(invoice_summary == ''){
      default_subheading = 'Project name/description';
      summary = '';
    } else{
      default_subheading = prefs.getString('invoice_summary');
      summary = default_subheading;
    }

    String invoice_ponumber = prefs.getString('invoice_ponumber');
    if(invoice_ponumber == ''){
      ponumber = 'P.O/S.O. number';
      po_so_number = '';
    } else{
      ponumber = prefs.getString('invoice_ponumber');
      po_so_number = ponumber;
    }
    //Return String
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker( //we wait for the dialog to return
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

  Future<void> _selectCustomDate(BuildContext context) async {
    final DateTime d = await showDatePicker( //we wait for the dialog to return
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );
    if (d != null) //if the user has selected a date
      setState(() {
        // we format the selected date and assign it to the state variable
//        currentDate = new DateFormat.yMMMMd("en_US").format(d);

        paymentduelist.clear();
        var formatter1 = new DateFormat('yyyy-MM-dd');
        String invoiceDate = formatter1.format(d);
        payment_due = '{"flag" : "custom", "date" : "$invoiceDate"}';
        paymentduelist.add("$payment_due");

      });
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
        items = jsonn[0]['columns_titles'][0]['Items'];

      });

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }


  Future<List<Item>> getItem() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['item'] = 'true';

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'invoicing/searchInvoice', apiBodyObj);

    List responseList = response['result'];

    getItem_Data = responseList.map<Item>((json) {
      return Item.fromJson(json);
    }).toList();


    setState(() {

      for(int i=0; i<getItem_Data.length; i++){
        for(int j=0; j<getIdData.length; j++){
          if(getItem_Data[i].id == getIdData[j].id){
            print(getItem_Data[i].id);
            AddItem itm = new AddItem('', '', '', '', '', '');
            itm.id = getItem_Data[i].id;
            itm.name = getItem_Data[i].name;
            itm.desc = getItem_Data[i].desc;
            itm.price = getItem_Data[i].price;
            itm.qty = getIdData[j].qty;
            itm.income_account = getItem_Data[i].income_account;
            itm.taxx = getItem_Data[i].taxx;

            getData.add(itm);
          }
        }
      }

      print(getData.length);

      for(int i=0; i<getData.length; i++){
        String id = getData[i].id;
        String quantity = getData[i].qty;
        var stuff = '{"id" : "$id", "quantity" : "$quantity"}';
        stufflist.add("$stuff");

        print("stufflist" + stufflist.toString());


        double d_price = double.parse(getData[i].price);
        int qun = int.parse(quantity);
        int price;
        price = d_price.toInt();
        price = qun * d_price.toInt();

        subTotal = subTotal + price;


        for(int j=0; j<getData[i].taxx.length; j++){
          Tax_total itm = new Tax_total();
          itm.id = getData[i].taxx[j].id;
          itm.name = getData[i].taxx[j].name;
          itm.rate = getData[i].taxx[j].rate;
          itm.tax_id = getData[i].taxx[j].tax_id;
          itm.recoverable = getData[i].taxx[j].recoverable;
          itm.compound = getData[i].taxx[j].compound;
          itm.price = price.toString();
          setTaxData.add(itm);
        }
//        setTaxData = getData[i].taxx;
      }
      print(getData.length);

      isLoading = false;
    });


    return getItem_Data;

  }


  void getInvoiceNumber() async {
    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/getInvoiceNumber');

    if (response['status'] == 'success') {
      var jsonn = response['result'];

      setState(() {
        invoice_no = jsonn['invoice_no'].toString();
        invoice_status = jsonn['status'];
      });

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }


  getAddcustomerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    setState(() {
      customerId = prefs.getString('add_customer_id');
      customerName = prefs.getString('add_customer_name');
      customerEmail = prefs.getString('add_customer_email');
      customerAddress1 = prefs.getString('add_customer_address1');
      customerAddress2 = prefs.getString('add_customer_address2');
      customerCity = prefs.getString('add_customer_city');
      customerZipcode = prefs.getString('add_customer_zipcode');
      customerState = prefs.getString('add_customer_state');
      customerCountry = prefs.getString('add_customer_country');
      phone = prefs.getString('add_phone');

      print(customerAddress1);
    });
  }


  getItemData() async {
    getData.clear();
    stufflist.clear();
    setTaxData.clear();
    subTotal = 0;
    ttl_tax = 0.0;
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {

      Map json = jsonDecode(pref.getString('userData'));
      var user = AddItem.fromJson(json);

//      Map deletejson = jsonDecode(pref.getString('deleteItemData'));
      var deleteItem = pref.getString('deleteItemData');

      AddItem itm = new AddItem('', '', '', '', '', '');
      itm.id = user.id;
      itm.qty = user.qty;

      for(int i=0; i<getIdData.length; i++){
        if(getIdData[i].id == user.id){
          getIdData.removeWhere((AddItem) => AddItem.id == user.id);
        }
      }

      getIdData.add(itm);

      if(deleteItem != ''){
        for(int i=0; i<getIdData.length; i++){
          if(getIdData[i].id == deleteItem){
            getIdData.removeWhere((AddItem) => AddItem.id == deleteItem);
            total_amount = 0.0;
          }
        }
      }
      pref.remove('deleteItemData');

      itemList = getItem();

    });

  }


  void editInvoice(String type) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['customer_name'] = customerName;
    apiBodyObj['invoice_date'] = invoiceDate;
    apiBodyObj['invoice_name'] = default_title;
    apiBodyObj['invoice_no'] = invoice_no;
    apiBodyObj['payment_due'] = paymentduelist.toString();
    apiBodyObj['color'] ='#757575';
    apiBodyObj['currency'] = 'PHP';
    apiBodyObj['total'] = total_amount.toStringAsFixed(2);
    apiBodyObj['subtotal'] = subTotal.toString();
    apiBodyObj['customer_id'] = customerId;
    apiBodyObj['stuff'] = stufflist.toString();
    apiBodyObj['status'] = invoice_status;
    apiBodyObj['tax'] = taxlist.toString();
    apiBodyObj['note'] = _notesController.text;
    apiBodyObj['footer'] = _footerController.text;
    apiBodyObj['po_so_number'] = po_so_number;
    apiBodyObj['summary'] = summary;
    apiBodyObj['id'] = invoice_id;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/EditInvoice', apiBodyObj);

//
    if (response['status'] == 'success') {

      if (type == '1'){
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => InvoicePreviewScreen(invoice_id:invoice_id, invoice: invoice_no, amount_due: total_amount.toStringAsFixed(2), due_on: paymentDate,
                customerId: customerId, customerName: customerName, customerEmail: customerEmail, customerAddress1: customerAddress1, customerAddress2: customerAddress2,
                customerCity: customerCity, customerZipcode: customerZipcode, customerState: customerState, customerCountry: customerCountry, phone: phone, getData: getData,
                subtotal: subTotal.toString(), setTaxData: setTaxData, totalamount: getTotal()),
            )).then((val)=>val?Navigator.pop(context,true):null);
      } else if(type == '2'){
        Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => SendInvoiceScreen(invoice_id:invoice_id, customer_email: customerEmail, invoice_no: invoice_no, total_amout: total_amount.toStringAsFixed(2), send_type: 'edit',))
        ).then((val)=>val?Navigator.pop(context,true):null);
      }else{
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context,true);
      }




    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }

  void addInvoice(String type) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['customer_name'] = customerName;
    apiBodyObj['invoice_date'] = invoiceDate;
    apiBodyObj['invoice_name'] = default_title;
    apiBodyObj['invoice_no'] = invoice_no;
    apiBodyObj['payment_due'] = paymentduelist.toString();
    apiBodyObj['color'] ='#757575';
    apiBodyObj['currency'] = 'PHP';
    apiBodyObj['total'] = total_amount.toStringAsFixed(2);
    apiBodyObj['subtotal'] = subTotal.toString();
    apiBodyObj['customer_id'] = customerId;
    apiBodyObj['stuff'] = stufflist.toString();
    apiBodyObj['status'] = invoice_status;
    apiBodyObj['tax'] = taxlist.toString();
    apiBodyObj['note'] = _notesController.text;
    apiBodyObj['footer'] = _footerController.text;
    apiBodyObj['po_so_number'] = po_so_number;
    apiBodyObj['summary'] = summary;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/addInvoice', apiBodyObj);

//
    if (response['status'] == 'success') {

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context,true);


    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }


  void deleteInvoice(String invoiceid) async {

    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = invoiceid;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/DeleteInvoice', apiBodyObj);

//
    if (response['status'] == 'success') {

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context,true);


    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }


  void sendInvoice(String invoice_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = invoice_id;
    apiBodyObj['from'] = 'test';
    apiBodyObj['message'] = 'test';
    apiBodyObj['subject'] = 'test';
    apiBodyObj['attachCopy'] = 'false';
    apiBodyObj['sendCopy'] = 'false';
    apiBodyObj['to'] = 'test';
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

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Invoice'),
          actions: <Widget>[

            IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () {

                if(getData.length == 0){
                  if(customerName == ''){
                    showDialog(
                        context: context,
                        builder: (context) {
                          return _TaxDialog(
                            taxMessage: 'A customer must be selected to save the invoice!',
                          );
                        });
                  }else{
                    showDialog(
                        context: context,
                        builder: (context) {
                          return _TaxDialog(
                            taxMessage: 'An invoice must be have one or more items to be sent!',
                          );
                        });
                  }

                } else{

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        content: new Text("Previewing the invoice will save it first. Do you want to continue?"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          new FlatButton(
                            child: new Text("CANCEL"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          new FlatButton(
                            child: new Text("SAVE AND PREVIEW"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              editInvoice('1');
                            },
                          ),
                        ],
                      );
                    },
                  );

                }

              },
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return _MenuDialog(
                        selectedText:selectmenu,
                        onTextChanged: (cities) {
                          selectmenu = cities;
                          var str_Name = selectmenu.reduce((value, element) => value + element);
                          setState(() {
                            if(str_Name == 'Save'){
                              if(getData.length == 0){
                                if(customerName == ''){
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _TaxDialog(
                                          taxMessage: 'A customer must be selected to save the invoice!',
                                        );
                                      });
                                }else{
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _TaxDialog(
                                          taxMessage: 'An invoice must be have one or more items to be sent!',
                                        );
                                      });
                                }

                              } else{
                                editInvoice('0');
                              }
                            } else if(str_Name == 'Discard changes'){
                              Navigator.of(context).pop();
                            } else if(str_Name == 'Duplicate'){
                              addInvoice('');
                            } else if(str_Name == 'Delete'){
                              deleteInvoice(invoice_id);
                            }else if(str_Name == 'Resend'){
                              if(getData.length == 0){
                                if(customerName == ''){
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _TaxDialog(
                                          taxMessage: 'A customer must be selected to save the invoice!',
                                        );
                                      });
                                }else{
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _TaxDialog(
                                          taxMessage: 'An invoice must be have one or more items to be sent!',
                                        );
                                      });
                                }

                              } else{
                                sendInvoice(invoice_id);
                              }
                            }
                          });
                        },
                      );
                    });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      invoiceDetailModule(),
                      SizedBox(height: 20),
                      invoicedateModule(),
                      SizedBox(height: 15),
                      customerName == ''?
                      addCustomerModule():listCustomerModule(),
                      Container(
                        padding: EdgeInsets.all(5),
                        child:   Divider(
                          color: Color(0xFFACACAC),
                        ),
                      ),
                      getData.length == 0?
                      Container():
                      listItemModule(),
                      addItemModule(),
                      Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child:   Divider(
                          color: Color(0xFFACACAC),
                        ),
                      ),
                      total(),
                    ],
                  ),
                )
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }

  Widget invoiceDetailModule() {
    return InkWell(
      onTap: (){
        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoice_title: default_title, invoice_number: invoice_no, invoice_ponumber: ponumber, invoice_summary:default_subheading))
        ).then((val)=>val?getDefaultData():null);
      },
      child:  Container(
        padding: EdgeInsets.all(8),
        color: invoice_status == 'paid'?
        Color(0xff8FAC1B):invoice_status == 'sent'?
        Color(0xff2CB5E2): invoice_status == 'viewed'?
        Color(0xffEF9B25):invoice_status == 'overdue'?
        Color(0xffD74343): Color(0xFF535353).withOpacity(0.8),
        child: Row(
          children: [
            Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        default_title + "   " +invoice_no,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        default_subheading,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )),
            Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        invoice_status,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        ponumber,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );

  }

  Widget invoicedateModule() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Row(
              children: [
                Flexible(
                    child: Container(
                        margin: EdgeInsets.only(right: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice Date',
                              style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ))),
                Flexible(
                    child: Container(
                        margin: EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Due',
                              style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Row(
              children: [
                Flexible(
                    child: Container(
                        margin: EdgeInsets.only(right: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child:Container(
                                  padding: EdgeInsets.only(top: 15, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        onTap: (){
                                          setState(() {
                                            currentDate = '';
                                          });
                                        },
                                      )

                                    ],
                                  )
                              ),
                              onTap: (){
                                _selectDate(context);
                              },
                            ),

                            Divider(
                              color: Color(0xFFACACAC),
                            ),
                          ],
                        ))),
                Flexible(
                    child: Container(
                        margin: EdgeInsets.only(left: 10),
                        decoration: new BoxDecoration(
                            color: Color(0xfff2f3f5),
                            border:
                            Border.all(color: Color(0xFFACACAC), width: 0.5),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        default_payment_term,
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
                                  )
                              ),
                              onTap: (){
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return _TermsDialog(
                                        selectedText:selectedefault,
                                        onTextChanged: (cities) {
                                          selectedefault = cities;
                                          var str_Name = selectedefault.reduce((value, element) => value + element);
                                          setState(() {
                                            paymentduelist.clear();
                                            default_payment_term = str_Name;

                                            if(default_payment_term == 'On receipt'){
                                              var today = new DateTime.now();
                                              var formatter = new DateFormat('yyyy-MM-dd');
                                              paymentDate = formatter.format(today);
                                              payment_due = '{"flag" : "onreceipt", "date" : "$paymentDate"}';
                                              paymentduelist.add("$payment_due");

                                            } else if(default_payment_term == 'Within 15 days'){

                                              var today = new DateTime.now();
                                              var payment_date = today.add(new Duration(days: 15));
                                              var formatter = new DateFormat('yyyy-MM-dd');
                                              paymentDate = formatter.format(payment_date);
                                              payment_due = '{"flag" : "15days", "date" : "$paymentDate"}';
                                              paymentduelist.add("$payment_due");

                                            }else if(default_payment_term == 'Within 30 days'){

                                              var today = new DateTime.now();
                                              var payment_date = today.add(new Duration(days: 30));
                                              var formatter = new DateFormat('yyyy-MM-dd');
                                              paymentDate = formatter.format(payment_date);
                                              payment_due = '{"flag" : "30days", "date" : "$paymentDate"}';
                                              paymentduelist.add("$payment_due");

                                            }else if(default_payment_term == 'Within 45 days'){

                                              var today = new DateTime.now();
                                              var payment_date = today.add(new Duration(days: 45));
                                              var formatter = new DateFormat('yyyy-MM-dd');
                                              paymentDate = formatter.format(payment_date);
                                              payment_due = '{"flag" : "45days", "date" : "$paymentDate"}';
                                              paymentduelist.add("$payment_due");

                                            }else if(default_payment_term == 'Within 60 days'){

                                              var today = new DateTime.now();
                                              var payment_date = today.add(new Duration(days: 50));
                                              var formatter = new DateFormat('yyyy-MM-dd');
                                              paymentDate = formatter.format(payment_date);
                                              payment_due = '{"flag" : "60days", "date" : "$paymentDate"}';
                                              paymentduelist.add("$payment_due");

                                            }else if(default_payment_term == 'Within 90 days'){

                                              var today = new DateTime.now();
                                              var payment_date = today.add(new Duration(days: 90));
                                              var formatter = new DateFormat('yyyy-MM-dd');
                                              paymentDate = formatter.format(payment_date);
                                              payment_due = '{"flag" : "90days", "date" : "$paymentDate"}';
                                              paymentduelist.add("$payment_due");

                                            }else if(default_payment_term == 'Custom'){

                                              _selectCustomDate(context);
                                              if(paymentduelist.length == 0){
                                                payment_due = '{"flag" : "custom", "date" : "$invoiceDate"}';
                                                paymentduelist.add("$payment_due");
                                              }
                                            }
                                          });
                                        },
                                      );
                                    });
                              },
                            )
                          ],
                        ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addCustomerModule() {
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.userPlus, size: 24, color: Color(0xFF832b17)),
            SizedBox(width: 10),
            Text(
              'Add customer',
              style: TextStyle(
                  color: kUserBackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      onTap: (){
        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => AddCustomerScreen())
        ).then((val)=>val?getAddcustomerData():null);
      },
    );
  }

  Widget listCustomerModule() {
    return InkWell(
      child: Container(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Row(
            children: [
              Ink(
                  decoration: const ShapeDecoration(
                    color:  kPrimaryColor,
                    shape: CircleBorder(),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(25),
                  )
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(customerName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                  SizedBox(height: 2),
                  Text(customerEmail,
                    style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                  ),
                ],
              )
            ],
          )),
      onTap: (){
        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => AddCustomerScreen())
        ).then((val)=>val?getAddcustomerData():null);
      },
    );
  }

  Widget listItemModule() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child:Text(getData.length.toString() +' '+ items,
                style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: getData.length,
                      itemBuilder: (BuildContext context, int index) {
                        List<String> multipletax = [];
                        List<String> taxlist = [];
                        List<String> taxidlist = [];

                        var multiple_tax;
                        var tax;
                        var tax_id;

                        List<Tax> taxData = getData[index].taxx;
                        for(int i = 0; i<taxData.length; i++){
                          multipletax.add(taxData[i].name + ' '+ taxData[i].rate + '%');
                          multiple_tax = multipletax.reduce((value, element) => value + ',' + element);

                          taxlist.add(taxData[i].name);
                          tax = taxlist.reduce((value, element) => value + ',' + element);

                          taxidlist.add(taxData[i].tax_id);
                          tax_id = taxidlist.reduce((value, element) => value + ',' + element);

                        }
                        print(multiple_tax);

                        return InkWell(
                            child:  Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Text(getData[index].name,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: kUserBackColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text('PHP'+getData[index].price,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: kUserBackColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Text(getData[index].desc,
                                            style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                          ),
                                        ),
                                        Text('',
                                          style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Text(getData[index].qty + ' x ' + getData[index].price,
                                            style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                          ),
                                        ),
                                        Container(
                                          child: getData[index].taxx.length != 0 && getData[index].taxx.length != null
                                              ? Text(
                                              '+ '+ multiple_tax,
                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFF535353).withOpacity(0.8))
                                          ) : Text(
                                              '',
                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFF535353).withOpacity(0.8))
                                          ),

                                        )
                                      ],
                                    ),

                                    Divider(
                                      color: Color(0xFFACACAC),
                                    ),
                                  ],
                                )
                            ),
                            onTap: () async {
                              Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => AddItemScreen(user_id: getData[index].id, name: getData[index].name, desc: getData[index].desc, price: getData[index].price, tax: tax, income_account: getData[index].income_account, txt_id: tax_id, qty: getData[index].qty, getTaxData: getData[index].taxx,edittype:'1')),
                              ).then((val)=>val?getItemData()():null);
                            });
                      },
                    ),)
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget addItemModule() {
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.folderPlus, size: 24, color: Color(0xFF832b17)),
            SizedBox(width: 10),
            Text(
              'Add Item',
              style: TextStyle(
                  color: kUserBackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      onTap: (){
        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => SelectItemScreen())
        ).then((val)=>val?getItemData()():null);
      },
    );
  }

  Widget total() {
    return Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            'Subtotal',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        )

                      ],

                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            'PHP' + subTotal.toString(),
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],

                    ),
                  ),
                ],
              ),
            ),

            setTaxData.length == 0?
            Container():  Divider(
              color: Color(0xFFACACAC),
            ),

            ListView.builder(
              shrinkWrap: true,
              itemCount: setTaxData.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    child:  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(setTaxData[index].name + ' '+ setTaxData[index].rate + '%',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: kUserBackColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text('PHP'+percentage1Calculate(setTaxData[index].id, setTaxData[index].name, setTaxData[index].rate, int.parse(setTaxData[index].price)),
                            style: TextStyle(
                                fontSize: 14,
                                color: kUserBackColor,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                    });
              },
            ),

            Divider(
              color: Color(0xFFACACAC),
            ),

            Container(
              padding: EdgeInsets.only(top: 5),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(

                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            'Total',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        )

                      ],

                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            'PHP'+getTotal(),
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],

                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xfff2f3f5),
              margin: EdgeInsets.only(top:10, bottom: 15),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            'Due (PHP)',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        )

                      ],

                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            'PHP'+getTotal(),
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],

                    ),
                  ),
                ],
              ),
            ),

            TextField(
              controller: _notesController,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              decoration: new InputDecoration(
                  labelText: 'Notes'
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Additional notes visible to your customer',
              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
              textAlign: TextAlign.start,
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _footerController,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              decoration: new InputDecoration(
                  labelText: 'Footer'
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Tax information or a thank you note to your customer',
              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
              textAlign: TextAlign.start,
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              color: Color(0xFFACACAC),
            ),
            SizedBox(
              height: 15,
            ),

            Container(
              child: Row(
                children: [
                  Flexible(
                    child: ButtonTheme(
                      height: 45,
                      minWidth: MediaQuery.of(context).size.width,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        color: Color(0xff2b2b2b),
                        onPressed: () {
                          if(invoice_status == 'paid'){
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => PaymentScreen(invoice_id:invoice_id, payment_amount: total_amount.toStringAsFixed(2), customer_email: customerEmail, invoice_no:invoice_no))
                            ).then((val)=>val?Navigator.pop(context,true):null);
                          } else{
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => RecordPaymentScreen(invoice_id:invoice_id, payment_amount: total_amount.toStringAsFixed(2)))).then((val)=>val?Navigator.pop(context,true):null);
                          }
                        },
                        child: Text(invoice_status == 'paid'?
                            'Edit Payment':
                          'Record Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: ButtonTheme(
                      height: 45,
                      minWidth: MediaQuery.of(context).size.width,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        color: kPrimaryColor,
                        onPressed: () {
                          if(invoice_status == 'sent'){
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => SendReminderScreen(invoice_id:invoice_id, customer_email: customerEmail, invoice_no: invoice_no, total_amount: total_amount.toStringAsFixed(2), payment_date: paymentDate))
                            ).then((val)=>val?Navigator.pop(context,true):null);
                          } else if(invoice_status == 'Draft'){
                            editInvoice('2');
                          } else if(invoice_status == 'paid'){
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => SendReceiptScreen(invoice_id:invoice_id, customer_email: customerEmail, invoice_no: invoice_no, total_amout: total_amount.toStringAsFixed(2)))
                            ).then((val)=>val?Navigator.pop(context,true):null);
                          }

                        },
                        child: Text(invoice_status == 'sent'?
                          'Send Reminder': invoice_status == 'paid'?
                        'Send Receipt':'Send Invoice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),),
                      ),
                    ),
                  )
                ],
              ),
            )

          ],
        )

    );
  }

  String percentage1Calculate(String id, String name, String ratee, int price) {
    int rate = int.parse(ratee);
    double total = (rate / 100) * price;

    String amount = total.toStringAsFixed(2);
    var tax = '{"id" : "$id", "amount" : "$amount.", "name" : "$name", "rate" : "$ratee"}';
    taxlist.add("$tax");
    print('Taxess' + tax);

    ttl_tax = ttl_tax + total;
    print("ttl_tax_ " + ttl_tax.toString());
    double doubleVar = subTotal.toDouble();
    total_amount = ttl_tax + doubleVar;
    print("ttl_anount_ " + total_amount.toString());
    return total.toStringAsFixed(2);
  }

  String getTotal(){
    int rate;
    double total;
    double ttl_tax = 0.0;
    double totalAmount = 0.0;

    if(setTaxData.length == 0){
      total_amount = subTotal.toDouble();
      totalAmount = subTotal.toDouble();
    }else{
      for(int i=0; i<setTaxData.length; i++){
        rate = int.parse(setTaxData[i].rate);
        total = (rate / 100) * int.parse(setTaxData[i].price);
        ttl_tax = ttl_tax + total;
        print("get_ttl_tax_ " + ttl_tax.toString());
        double doubleVar = subTotal.toDouble();
        totalAmount = ttl_tax + doubleVar;
        print("get_ttl_anount_ " + totalAmount.toString());
      }
    }

    return totalAmount.toStringAsFixed(2);
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
                          'Save',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                        onTap: (){
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Save');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      ),

                      Divider(),
                      InkWell(
                        child:Text(
                          'Discard changes',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                        onTap: (){
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Discard changes');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      ),

                      Divider(),
                      InkWell(
                        child: Text(
                          'Duplicate',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                        onTap: (){
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Duplicate');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      ),
                      Divider(),
                      InkWell(
                        child: Text(
                          'Delete',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                        onTap: (){
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Delete');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      ),
                      Divider(),
                      InkWell(
                        child: Text(
                          'Resend',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                        onTap: (){
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Resend');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      )
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



class _TermsDialog extends StatefulWidget {
  _TermsDialog({
    this.selectedText,
    this.onTextChanged,
  });

  final List<String> selectedText;
  final ValueChanged<List<String>> onTextChanged;


  @override
  _TermsDialogState createState() => _TermsDialogState();
}

class _TermsDialogState extends State<_TermsDialog> {
  List<String> _tempSelectedTxt = [];
  List<String> getData = new List<String>();

  @override
  void initState() {
    super.initState();
    _tempSelectedTxt = widget.selectedText;

    getData.add('On receipt');
    getData.add('Within 15 days');
    getData.add('Within 30 days');
    getData.add('Within 45 days');
    getData.add('Within 60 days');
    getData.add('Within 90 days');
    getData.add('Custom');
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

                ],
              ),
            ),

            ListView.builder(
                shrinkWrap: true,
                itemCount: getData.length,
                itemBuilder: (BuildContext context, int index) {
                  final cityName = getData[index];
                  return InkWell(child:
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        getData[index],
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




class _TaxDialog extends StatefulWidget {
  _TaxDialog({
    this.taxMessage,
  });

  String taxMessage;

  @override
  _TaxDialogState createState() => _TaxDialogState();
}

class _TaxDialogState extends State<_TaxDialog> {
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

