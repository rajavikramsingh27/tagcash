import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/apps/invoicing/models/Invoice.dart';
import 'package:tagcash/apps/invoicing/models/add_item.dart';
import 'package:tagcash/apps/invoicing/models/tax_total.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:intl/intl.dart';

import 'invoice/edit_invoice_screen.dart';
import 'invoice/invoice_preview_screen.dart';
import 'invoice/new_invoice_screen.dart';
import 'invoice/payments_screen.dart';
import 'invoice/record_payment_screen.dart';
import 'invoice/send_invoice_screen.dart';
import 'invoice/send_receipt_screen.dart';
import 'invoice/send_reminder_screen.dart';

class MerchantUnpaidTabScreen extends StatefulWidget {
  @override
  _MearchantUnpaidTabScreenState createState() =>
      _MearchantUnpaidTabScreenState();
}

class _MearchantUnpaidTabScreenState extends State<MerchantUnpaidTabScreen>
    with SingleTickerProviderStateMixin {
  Future<List<Invoice>> invoiceList;
  Future<List<Invoice>> invoiceeList;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Invoice> getData = new List<Invoice>();
  List<AddItem> getAddData = new List<AddItem>();

  List<String> paymentduelist = [];

  bool isLoading = false;
  List<Invoice> getinvoiceData = new List<Invoice>();

  List<String> selectmenu = [];

  bool _darkModeEnabled = false;

  //get
  List<Invoice> getInvoiceData = new List<Invoice>();
  String default_id = '',
      default_payment_term = 'On receipt',
      default_title = '',
      default_subheading = 'Project name/description',
      default_footer = '',
      default_notes = '';
  String invoice_no = '',
      invoice_status = '',
      items = '',
      note = '',
      footer = '';
  String currentDate;
  String invoiceDate;

  var payment_due;
  var paymentDate;
  var Stuffjson;
  var Taxjson;

  String customerId = '',
      customerName = '',
      customerEmail = '',
      customerAddress1 = '',
      customerAddress2 = '',
      customerCity = '',
      customerZipcode = '',
      customerState = '',
      customerCountry = '',
      phone = '',
      po_so_number = '',
      summary = '',
      total = '';
  List<AddItem> getItemData = new List<AddItem>();
  List<AddItem> getIdData = new List<AddItem>();
  List<String> stufflist = [];
  List<String> taxlist = [];
  int subTotal = 0;
  List<Tax_total> setTaxData = new List<Tax_total>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // memberDataList = {} as Future<List<Merchant>>;
    invoiceList = loadStaffCommunities();
  }

  Future<List<Invoice>> loadStaffCommunities() async {
    getData.clear();
    getinvoiceData.clear();
    print('loadStaffCommunities');
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/searchInvoice');

    List responseList = response['result'];

    getData = responseList.map<Invoice>((json) {
      return Invoice.fromJson(json);
    }).toList();

    var jsonn = response['result'];

    for (var items in jsonn) {
      Map myMap = items;
      Invoice model = new Invoice();
      if (myMap['status'] == 'Draft') {
      } else {
        model.id = myMap['id'];
        model.customer_name = myMap['customer_name'];
        model.invoice_date = myMap['invoice_date'];
        model.invoice_name = myMap['invoice_name'];
        model.invoice_no = myMap['invoice_no'];
        model.date = myMap['payment_due']['date'];
        model.currency = myMap['currency'];
        model.total = myMap['total'];
        model.subtotal = myMap['subtotal'];
        model.status = myMap['status'];
        model.email = myMap['customer']['email'];
        model.payment_date = myMap['payment_due']['date'];
        model.customer_id = myMap['customer']['id'];
        if (myMap['customer']['address'] == '' ||
            myMap['customer']['address'] == null) {
          model.customeraddress1 = '';
          model.customeraddress2 = '';
          model.customercity = '';
          model.customerzipcode = '';
          model.customerstate = '';
          model.customercountry = '';
        } else {
          model.customeraddress1 = myMap['customer']['address']['address1'];
          model.customeraddress2 = myMap['customer']['address']['address2'];
          model.customercity = myMap['customer']['address']['city'];
          model.customerzipcode = myMap['customer']['address']['zipCode'];
          model.customerstate =
              myMap['customer']['address']['state']['addressState'];
          model.customercountry =
              myMap['customer']['address']['country']['addressCountry'];
        }

        model.customer_phone = myMap['customer']['phone_no'];
        model.payment_due = myMap['payment_due'];
        getinvoiceData.add(model);
      }
    }

    date('2020-04-11');

    setState(() {
      isLoading = false;
    });

    return getinvoiceData;
  }

  Future<List<Invoice>> getInvoice(
      String invoice_id, String press_status) async {
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
      Map myMap = items;
      if (myMap['id'] == invoice_id) {
        default_title = myMap['invoice_name'];
        invoice_no = myMap['invoice_no'];
        invoice_status = myMap['status'];
        invoiceDate = myMap['invoice_date'];
        note = myMap['note'];
        footer = myMap['footer'];
        po_so_number = myMap['po_so_number'];
        summary = myMap['summary'];
        total = myMap['total'];
        var formatter = new DateFormat('yMMMMd');
        String d = formatter
            .format(DateTime.parse(myMap['invoice_date'])); //set formate
        currentDate = d;

        changePaymentDue(myMap['payment_due']['flag']); //change payment due

        customerId = myMap['customer']['id'];
        customerName = myMap['customer']['customer_name'];
        customerEmail = myMap['customer']['email'];
        if (myMap['customer']['address'] == '' ||
            myMap['customer']['address'] == null) {
          customerAddress1 = '';
          customerAddress2 = '';
          customerCity = '';
          customerZipcode = '';
          customerState = '';
          customerCountry = '';
        } else {
          customerAddress1 = myMap['customer']['address']['address1'];
          customerAddress2 = myMap['customer']['address']['address2'];
          customerCity = myMap['customer']['address']['city'];
          customerZipcode = myMap['customer']['address']['zipCode'];
          customerState = myMap['customer']['address']['state']['addressState'];
          customerCountry =
              myMap['customer']['address']['country']['addressCountry'];
        }
        phone = myMap['customer']['phone_no'];

        Stuffjson = myMap['stuff'];
        List responseList = myMap['stuff'];
        getItemData = responseList.map<AddItem>((json) {
          return AddItem.fromJson(json);
        }).toList();
        getIdData.addAll(getItemData);
        print(getItemData.length);

        for (int i = 0; i < getItemData.length; i++) {
          String id = getItemData[i].id;
          String quantity = getItemData[i].qty;
          var stuff = '{"id" : "$id", "quantity" : "$quantity"}';
          stufflist.add("$stuff");

          print("stufflist" + stufflist.toString());

          double d_price = double.parse(getItemData[i].price);
          int price = d_price.toInt();
          subTotal = subTotal + price;

          for (int j = 0; j < getItemData[i].taxx.length; j++) {
            Tax_total itm = new Tax_total();
            itm.id = getItemData[i].taxx[j].id;
            itm.name = getItemData[i].taxx[j].name;
            itm.rate = getItemData[i].taxx[j].rate;
            itm.tax_id = getItemData[i].taxx[j].tax_id;
            itm.recoverable = getItemData[i].taxx[j].recoverable;
            itm.compound = getItemData[i].taxx[j].compound;
            itm.price = price.toString();
            setTaxData.add(itm);
          }
//        setTaxData = getData[i].taxx;
        }
      } else {}
    }

    if (press_status == 'preview') {
      Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => InvoicePreviewScreen(
            invoice_id: invoice_id,
            invoice: invoice_no,
            amount_due: total,
            due_on: paymentDate,
            customerId: customerId,
            customerName: customerName,
            customerEmail: customerEmail,
            customerAddress1: customerAddress1,
            customerAddress2: customerAddress2,
            customerCity: customerCity,
            customerZipcode: customerZipcode,
            customerState: customerState,
            customerCountry: customerCountry,
            phone: phone,
            getData: getItemData,
            subtotal: subTotal.toString(),
            setTaxData: setTaxData,
            totalamount: total),
      ));

      setState(() {
        isLoading = false;
      });
    } else {
      addInvoice('');
    }

    return getInvoiceData;
  }

  void addInvoice(String type) async {

    Map<String, String> apiBodyObj = {};
    apiBodyObj['customer_name'] = customerName;
    apiBodyObj['invoice_date'] = invoiceDate;
    apiBodyObj['invoice_name'] = default_title;
    apiBodyObj['invoice_no'] = invoice_no;
    apiBodyObj['payment_due'] = paymentduelist.toString();
    apiBodyObj['color'] = '#757575';
    apiBodyObj['currency'] = 'PHP';
    apiBodyObj['total'] = total;
    apiBodyObj['subtotal'] = subTotal.toString();
    apiBodyObj['customer_id'] = customerId;
    apiBodyObj['stuff'] = stufflist.toString();
    apiBodyObj['status'] = invoice_status;
    apiBodyObj['tax'] = taxlist.toString();
    apiBodyObj['note'] = note;
    apiBodyObj['footer'] = footer;
    apiBodyObj['po_so_number'] = po_so_number;
    apiBodyObj['summary'] = summary;
//
    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/addInvoice', apiBodyObj);

//
    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      String invoice_id = response['invoice_id'];
      print('Invoice_id......' + invoice_id);

      Navigator.of(context)
          .push(new MaterialPageRoute(
            builder: (context) => EditInvoiceScreen(invoice_id: invoice_id),
          ))
          .then((val) => val ? invoiceList = loadStaffCommunities() : null);
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
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
      invoiceList = loadStaffCommunities();
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

/*
  void addInvoice(String customer_name, String invoice_date, String invoice_name, String invoice_no,
      List<String> paymentduelist, String total, String subtotal, String customer_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['customer_name'] = customer_name;
    apiBodyObj['invoice_date'] = invoice_date;
    apiBodyObj['invoice_name'] = invoice_name;
    apiBodyObj['invoice_no'] = invoice_no;
    apiBodyObj['payment_due'] = paymentduelist.toString();
    apiBodyObj['color'] ='#757575';
    apiBodyObj['currency'] = 'PHP';
    apiBodyObj['total'] = total;
    apiBodyObj['subtotal'] = subtotal;
    apiBodyObj['customer_id'] = customer_id;
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


          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);

    }
  }
*/

  changePaymentDue(String flag) {
    if (flag == 'onreceipt') {
      default_payment_term = 'On receipt';
    } else if (flag == '15days') {
      default_payment_term = 'Within 15 days';
    } else if (flag == '30days') {
      default_payment_term = 'Within 30 days';
    } else if (flag == '45days') {
      default_payment_term = 'Within 45 days';
    } else if (flag == '60days') {
      default_payment_term = 'Within 60 days';
    } else if (flag == '90days') {
      default_payment_term = 'Within 90 days';
    } else if (flag == 'custom') {
      default_payment_term = 'Custom';
    }
    default_payment_due(default_payment_term); //set paymentdue
  }

  default_payment_due(String default_payment_term) {
    if (default_payment_term == 'On receipt') {
      var today = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(today);
      payment_due = '{"flag" : "onreceipt", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");
    } else if (default_payment_term == 'Within 15 days') {
      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 15));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "15days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");
    } else if (default_payment_term == 'Within 30 days') {
      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 30));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "30days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");
    } else if (default_payment_term == 'Within 45 days') {
      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 45));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "45days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");
    } else if (default_payment_term == 'Within 60 days') {
      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 50));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "50days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");
    } else if (default_payment_term == 'Within 90 days') {
      var today = new DateTime.now();
      var payment_date = today.add(new Duration(days: 90));
      var formatter = new DateFormat('yyyy-MM-dd');
      paymentDate = formatter.format(payment_date);
      payment_due = '{"flag" : "90days", "date" : "$paymentDate"}';
      paymentduelist.add("$payment_due");
    } else if (default_payment_term == 'Custom') {
      payment_due = '{"flag" : "custom", "date" : ""}';
    }
  }

  void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);

    theme.brightness == MediaQuery.of(context).platformBrightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  @override
  Widget build(BuildContext context) {
    _checkIfDarkModeEnabled();
    // TODO: implement build
    return Scaffold(
        body: Stack(
      children: [
        ListView(
          children: [
            FutureBuilder(
                future: invoiceList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Invoice>> snapshot) {
                  if (snapshot.hasError) ;
                  print(snapshot.error);
                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                child: Container(
                                  child: snapshot.data[index].status == 'sent'
                                      ? Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 15,
                                                  bottom: 10,
                                                  left: 20,
                                                  right: 20),
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                      flex: 1,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                                child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  snapshot
                                                                      .data[
                                                                          index]
                                                                      .customer_name,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  snapshot
                                                                          .data[
                                                                              index]
                                                                          .invoice_name +
                                                                      ' ' +
                                                                      snapshot
                                                                          .data[
                                                                              index]
                                                                          .invoice_no,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyText2
                                                                      .apply(
                                                                          color:
                                                                              Color(0xFFACACAC)),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              2,
                                                                          bottom:
                                                                              2),
                                                                  child: Text(
                                                                    snapshot
                                                                        .data[
                                                                            index]
                                                                        .status,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  decoration: new BoxDecoration(
                                                                      borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                                                                      color: snapshot.data[index].status == 'paid'
                                                                          ? Color(0xff8FAC1B)
                                                                          : snapshot.data[index].status == 'sent'
                                                                              ? Color(0xff2CB5E2)
                                                                              : snapshot.data[index].status == 'viewed'
                                                                                  ? Color(0xffEF9B25)
                                                                                  : snapshot.data[index].status == 'overdue'
                                                                                      ? Color(0xffD74343)
                                                                                      : Color(0xff8FAC1B)),
                                                                )
                                                              ],
                                                            )),
                                                          ],
                                                        ),
                                                      )),
                                                  Flexible(
                                                      flex: 1,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                                child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  snapshot
                                                                          .data[
                                                                              index]
                                                                          .currency +
                                                                      snapshot
                                                                          .data[
                                                                              index]
                                                                          .total,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  main(snapshot
                                                                      .data[
                                                                          index]
                                                                      .date),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          kMerchantBackColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                InkWell(
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .pencilAlt,
                                                                    size: 14,
                                                                    color: Color(
                                                                        0xFF535353),
                                                                  ),
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                            new MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              EditInvoiceScreen(invoice_id: snapshot.data[index].id),
                                                                        ))
                                                                        .then((val) => val
                                                                            ? invoiceList =
                                                                                loadStaffCommunities()
                                                                            : null);
                                                                  },
                                                                )
                                                              ],
                                                            )),
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            Divider(), //
                                          ],
                                        )
                                      : snapshot.data[index].status == 'paid'
                                          ? Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 15,
                                                      bottom: 10,
                                                      left: 20,
                                                      right: 20),
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                          flex: 1,
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    child:
                                                                        Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      snapshot
                                                                          .data[
                                                                              index]
                                                                          .customer_name,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.normal),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      snapshot.data[index].invoice_name +
                                                                          ' ' +
                                                                          snapshot
                                                                              .data[index]
                                                                              .invoice_no,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText2
                                                                          .apply(
                                                                              color: Color(0xFFACACAC)),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Container(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              2,
                                                                          bottom:
                                                                              2),
                                                                      child:
                                                                          Text(
                                                                        snapshot
                                                                            .data[index]
                                                                            .status,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                      decoration: new BoxDecoration(
                                                                          borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                                                                          color: snapshot.data[index].status == 'paid'
                                                                              ? Color(0xff8FAC1B)
                                                                              : snapshot.data[index].status == 'sent'
                                                                                  ? Color(0xff2CB5E2)
                                                                                  : snapshot.data[index].status == 'viewed'
                                                                                      ? Color(0xffEF9B25)
                                                                                      : snapshot.data[index].status == 'overdue'
                                                                                          ? Color(0xffD74343)
                                                                                          : Color(0xff8FAC1B)),
                                                                    )
                                                                  ],
                                                                )),
                                                              ],
                                                            ),
                                                          )),
                                                      Flexible(
                                                          flex: 1,
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Container(
                                                                    child:
                                                                        Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      snapshot.data[index].currency +
                                                                          snapshot
                                                                              .data[index]
                                                                              .total,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.normal),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            5),
                                                                    Text(
                                                                      main(snapshot
                                                                          .data[
                                                                              index]
                                                                          .date),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              kMerchantBackColor,
                                                                          fontWeight:
                                                                              FontWeight.normal),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            5),
                                                                    InkWell(
                                                                      child:
                                                                          FaIcon(
                                                                        FontAwesomeIcons
                                                                            .pencilAlt,
                                                                        size:
                                                                            14,
                                                                        color: Color(
                                                                            0xFF535353),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        Navigator.of(
                                                                                context)
                                                                            .push(
                                                                                new MaterialPageRoute(
                                                                              builder: (context) => EditInvoiceScreen(invoice_id: snapshot.data[index].id),
                                                                            ))
                                                                            .then((val) => val
                                                                                ? invoiceList = loadStaffCommunities()
                                                                                : null);
                                                                      },
                                                                    )
                                                                  ],
                                                                )),
                                                              ],
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                                Divider(), //
                                              ],
                                            )
                                          : snapshot.data[index].status ==
                                                  'viewed'
                                              ? Column(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: 15,
                                                          bottom: 10,
                                                          left: 20,
                                                          right: 20),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                              flex: 1,
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                        child:
                                                                            Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          snapshot
                                                                              .data[index]
                                                                              .customer_name,
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.normal),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          snapshot.data[index].invoice_name +
                                                                              ' ' +
                                                                              snapshot.data[index].invoice_no,
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyText2
                                                                              .apply(color: Color(0xFFACACAC)),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Container(
                                                                          padding: EdgeInsets.only(
                                                                              left: 15,
                                                                              right: 15,
                                                                              top: 2,
                                                                              bottom: 2),
                                                                          child:
                                                                              Text(
                                                                            snapshot.data[index].status,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                          decoration: new BoxDecoration(
                                                                              borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                                                                              color: snapshot.data[index].status == 'paid'
                                                                                  ? Color(0xff8FAC1B)
                                                                                  : snapshot.data[index].status == 'sent'
                                                                                      ? Color(0xff2CB5E2)
                                                                                      : snapshot.data[index].status == 'viewed'
                                                                                          ? Color(0xffEF9B25)
                                                                                          : snapshot.data[index].status == 'overdue'
                                                                                              ? Color(0xffD74343)
                                                                                              : Color(0xff8FAC1B)),
                                                                        )
                                                                      ],
                                                                    )),
                                                                  ],
                                                                ),
                                                              )),
                                                          Flexible(
                                                              flex: 1,
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Container(
                                                                        child:
                                                                            Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          snapshot.data[index].currency +
                                                                              snapshot.data[index].total,
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.normal),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                5),
                                                                        Text(
                                                                          main(snapshot
                                                                              .data[index]
                                                                              .date),
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: kMerchantBackColor,
                                                                              fontWeight: FontWeight.normal),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                5),
                                                                        InkWell(
                                                                          child:
                                                                              FaIcon(
                                                                            FontAwesomeIcons.pencilAlt,
                                                                            size:
                                                                                14,
                                                                            color:
                                                                                Color(0xFF535353),
                                                                          ),
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context)
                                                                                .push(new MaterialPageRoute(
                                                                                  builder: (context) => EditInvoiceScreen(invoice_id: snapshot.data[index].id),
                                                                                ))
                                                                                .then((val) => val ? invoiceList = loadStaffCommunities() : null);
                                                                          },
                                                                        )
                                                                      ],
                                                                    )),
                                                                  ],
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                    Divider(), //
                                                  ],
                                                )
                                              : snapshot.data[index].status ==
                                                      'overdue'
                                                  ? Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 15,
                                                                  bottom: 10,
                                                                  left: 20,
                                                                  right: 20),
                                                          child: Row(
                                                            children: [
                                                              Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                            child:
                                                                                Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              snapshot.data[index].customer_name,
                                                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Text(
                                                                              snapshot.data[index].invoice_name + ' ' + snapshot.data[index].invoice_no,
                                                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Container(
                                                                              padding: EdgeInsets.only(left: 15, right: 15, top: 2, bottom: 2),
                                                                              child: Text(
                                                                                snapshot.data[index].status,
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              decoration: new BoxDecoration(
                                                                                  borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                                                                                  color: snapshot.data[index].status == 'paid'
                                                                                      ? Color(0xff8FAC1B)
                                                                                      : snapshot.data[index].status == 'sent'
                                                                                          ? Color(0xff2CB5E2)
                                                                                          : snapshot.data[index].status == 'viewed'
                                                                                              ? Color(0xffEF9B25)
                                                                                              : snapshot.data[index].status == 'overdue'
                                                                                                  ? Color(0xffD74343)
                                                                                                  : Color(0xff8FAC1B)),
                                                                            )
                                                                          ],
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  )),
                                                              Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Container(
                                                                            child:
                                                                                Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            Text(
                                                                              snapshot.data[index].currency + snapshot.data[index].total,
                                                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            SizedBox(height: 5),
                                                                            Text(
                                                                              main(snapshot.data[index].date),
                                                                              style: TextStyle(fontSize: 12, color: kMerchantBackColor, fontWeight: FontWeight.normal),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            SizedBox(height: 5),
                                                                            InkWell(
                                                                              child: FaIcon(
                                                                                FontAwesomeIcons.pencilAlt,
                                                                                size: 14,
                                                                                color: Color(0xFF535353),
                                                                              ),
                                                                              onTap: () {
                                                                                Navigator.of(context)
                                                                                    .push(new MaterialPageRoute(
                                                                                      builder: (context) => EditInvoiceScreen(invoice_id: snapshot.data[index].id),
                                                                                    ))
                                                                                    .then((val) => val ? invoiceList = loadStaffCommunities() : null);
                                                                              },
                                                                            )
                                                                          ],
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(), //
                                                      ],
                                                    )
                                                  : Container(),
                                ),
                                onTap: () async {
                                  displayBottomSheet(
                                    context,
                                    _darkModeEnabled,
                                    snapshot.data[index].id,
                                    snapshot.data[index].status,
                                    snapshot.data[index].customer_name,
                                    snapshot.data[index].invoice_name,
                                    snapshot.data[index].invoice_no.toString(),
                                    snapshot.data[index].invoice_date,
                                    snapshot.data[index].currency,
                                    snapshot.data[index].total,
                                    snapshot.data[index].date,
                                    snapshot.data[index].email,
                                    snapshot.data[index].payment_date,
                                    snapshot.data[index].customer_id,
                                    snapshot.data[index].customeraddress1,
                                    snapshot.data[index].customeraddress2,
                                    snapshot.data[index].customercity,
                                    snapshot.data[index].customerzipcode,
                                    snapshot.data[index].customerstate,
                                    snapshot.data[index].customercountry,
                                    snapshot.data[index].customer_phone,
                                    snapshot.data[index].payment_due,
                                    snapshot.data[index].subtotal,
                                  );
                                });
                          },
                        )
                      : Container();
                }),
          ],
        ),
        Container(
          padding: EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [toggle()],
          ),
        ),
        isLoading
            ? Center(child: Loading())
            : getinvoiceData.length == 0
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            child: Stack(
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.black,
                                      size: 200,
                                    ),
                                  ],
                                )),
                          ],
                        )),
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            getTranslated(context, 'invoice_nounpaidinvoice'),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          child: Text(
                            getTranslated(context, 'invoice_appearunpaidinvoice'),
                            style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
      ],
    ));
  }

  Widget toggle() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context)
            .push(new MaterialPageRoute(
              builder: (context) => NewInvoicingScreen(),
            ))
            .then((val) => val ? invoiceList = loadStaffCommunities() : null);
      },
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 40,
      ),
      backgroundColor: Colors.black,
      elevation: 5,
    );
  }

  void displayBottomSheet(
      BuildContext context,
      bool _darkModeEnabled,
      String invoice_id,
      String status,
      String customer_name,
      String invoice_name,
      String invoice_no,
      String invoice_date,
      String currency,
      String total,
      String date,
      String email,
      String payment_date,
      String customer_id,
      String customer_address1,
      String customer_address2,
      String customer_city,
      String customer_zipcode,
      String customer_state,
      String customer_country,
      String customer_phone,
      var payment_due,
      String subtotal) {
    showModalBottomSheet(
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        builder: (ctx) {
          return Container(
              height: 300,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    color: status == 'paid'
                        ? Color(0xff8FAC1B)
                        : status == 'sent'
                            ? Color(0xff2CB5E2)
                            : status == 'viewed'
                                ? Color(0xffEF9B25)
                                : status == 'overdue'
                                    ? Color(0xffD74343)
                                    : Color(0xff8FAC1B),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            status,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                      builder: (context) => EditInvoiceScreen(
                                          invoice_id: invoice_id),
                                    ))
                                    .then((val) => val
                                        ? invoiceList = loadStaffCommunities()
                                        : null);
                              },
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                setTaxData.clear();
                                subTotal = 0;
                                invoiceList = getInvoice(invoice_id, 'preview');
                              },
                              child: Text(
                                'PREVIEW',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 15),
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return _MenuDialog(
                                        selectedText: selectmenu,
                                        onTextChanged: (cities) {
                                          selectmenu = cities;
                                          var str_Name = selectmenu.reduce(
                                              (value, element) =>
                                                  value + element);
                                          setState(() {
                                            if (str_Name == 'Delete') {
                                              Navigator.of(context).pop();
                                              deleteInvoice(invoice_id);
                                            } else if (str_Name ==
                                                'Duplicate') {
                                              Navigator.of(context).pop();
                                              subTotal = 0;
                                              setTaxData.clear();
                                              invoiceList = getInvoice(
                                                  invoice_id, 'duplicate');
                                            } else if (str_Name == 'Resend') {
                                              Navigator.of(context).pop();
                                              Navigator.of(context)
                                                  .push(new MaterialPageRoute(
                                                      builder: (context) =>
                                                          SendInvoiceScreen(
                                                            invoice_id:
                                                                invoice_id,
                                                            customer_email:
                                                                email,
                                                            invoice_no:
                                                                invoice_no,
                                                            total_amout: total,
                                                            send_type: 'edit',
                                                          )))
                                                  .then((val) => val
                                                      ? Navigator.pop(
                                                          context, true)
                                                      : null);
                                            }
                                          });
                                        },
                                      );
                                    });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          customer_name,
                          style: TextStyle(
                              fontSize: 14,
                              color: _darkModeEnabled == true
                                  ? kUserBackColor.withOpacity(0.5)
                                  : kUserBackColor,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          invoice_name + ' ' + invoice_no,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .apply(color: Color(0xFFACACAC)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Divider(
                      color: Color(0xFFACACAC),
                      height: 10,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice date:',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .apply(color: Color(0xFFACACAC)),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          dueDate(invoice_date),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .apply(color: Color(0xFFACACAC)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Divider(
                      color: Color(0xFFACACAC),
                      height: 10,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .apply(color: Color(0xFFACACAC)),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          dueDate(invoice_date),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .apply(color: Color(0xFFACACAC)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Divider(
                      color: Color(0xFFACACAC),
                      height: 10,
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Due: ' + dueDate(date),
                            style: TextStyle(
                                fontSize: 16,
                                color: kMerchantBackColor,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            '(' + currency + ') ' + currency + total,
                            style: TextStyle(
                                fontSize: 16,
                                color: kUserBackColor,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      )),
                  Container(
                    child: Divider(
                      color: Color(0xFFACACAC),
                      height: 10,
                    ),
                  ),
                  Flexible(
                      child: Row(
                    children: [
                      Flexible(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: ButtonTheme(
                              height: 45,
                              minWidth: MediaQuery.of(context).size.width,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              child: RaisedButton(
                                color: _darkModeEnabled == true
                                    ? Color(0xff424242)
                                    : kUserBackColor,
                                onPressed: () {
                                  if (status == 'sent') {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .push(new MaterialPageRoute(
                                            builder: (context) =>
                                                RecordPaymentScreen(
                                                    invoice_id: invoice_id,
                                                    payment_amount: total)))
                                        .then((val) => val
                                            ? invoiceList =
                                                loadStaffCommunities()
                                            : null);
                                  } else if (status == 'paid') {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .push(new MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                                invoice_id: invoice_id,
                                                payment_amount: total,
                                                customer_email: email,
                                                invoice_no: invoice_no)))
                                        .then((val) => val
                                            ? invoiceList =
                                                loadStaffCommunities()
                                            : null);
                                  }
                                },
                                child: Text(
                                  status == 'paid'
                                      ? 'Edit Payment'
                                      : 'Record Payment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          )),
                      Flexible(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: ButtonTheme(
                              height: 45,
                              minWidth: MediaQuery.of(context).size.width,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              child: RaisedButton(
                                color: kPrimaryColor,
                                onPressed: () {
                                  if (status == 'sent') {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .push(new MaterialPageRoute(
                                            builder: (context) =>
                                                SendReminderScreen(
                                                    invoice_id: invoice_id,
                                                    customer_email: email,
                                                    invoice_no: invoice_no,
                                                    total_amount: total,
                                                    payment_date:
                                                        payment_date)))
                                        .then((val) => val
                                            ? invoiceList =
                                                loadStaffCommunities()
                                            : null);
                                  } else if (status == 'paid') {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .push(new MaterialPageRoute(
                                            builder: (context) =>
                                                SendReceiptScreen(
                                                    invoice_id: invoice_id,
                                                    customer_email: email,
                                                    invoice_no: invoice_no,
                                                    total_amout: total)))
                                        .then((val) => val
                                            ? invoiceList =
                                                loadStaffCommunities()
                                            : null);
                                  }
                                },
                                child: Text(
                                  status == 'paid'
                                      ? 'Send Receipt'
                                      : status == 'sent'
                                          ? 'Send Reminder'
                                          : 'Send Invoice',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ))
                ],
              ));
        });
  }

  main(String date) {
    String difference_formate;
    DateTime parseDt = DateTime.parse(date);
    var newFormat = DateFormat("yMMMMd");
    String updatedDt = newFormat.format(parseDt);
    final date2 = DateTime.now();
    final difference = parseDt.difference(date2).inDays;
    final difference_time = parseDt.difference(date2).inHours;
    print(difference);
    difference_formate = difference.toString();
    if (difference_time < 24) {
      final time = date2.difference(parseDt).inHours;
      difference_formate = '$time hours ago';
    } else {
      if (difference == 1) {
        difference_formate = 'in a day';
      } else if (difference < 15) {
        difference_formate = 'in $difference days';
      } else if (difference <= 45 && difference > 1) {
        difference_formate = 'in a month';
      } else if (difference > 45 && difference <= 60) {
        difference_formate = 'in 2 months';
      } else if (difference > 60 && difference <= 90) {
        difference_formate = 'in 3 months';
      }
    }

    return difference_formate; // 20-04-03
  }

  dueDate(String date) {
    String difference_formate;
    DateTime parseDt = DateTime.parse(date);
    var newFormat = DateFormat("yMMMMd");
    String updatedDt = newFormat.format(parseDt);

    return updatedDt; // 20-04-03
  }

  Widget date(String date) {
    DateTime dateTimeCreatedAt = DateTime.parse(date);
    DateTime dateTimeNow = DateTime.now();
    final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inDays;
    print('$differenceInDays');
  }
}

class _MenuDialog extends StatefulWidget {
  _MenuDialog({this.selectedText, this.onTextChanged, this.status});

  String status;
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
                          'Delete',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                        onTap: () {
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Delete');
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
                        onTap: () {
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Duplicate');
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
                        onTap: () {
                          _tempSelectedTxt.clear();
                          _tempSelectedTxt.add('Resend');
                          Navigator.of(context).pop();
                          widget.onTextChanged(_tempSelectedTxt);
                        },
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
