import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/invoicing/invoice/send_invoice_screen.dart';
import 'package:tagcash/apps/invoicing/models/add_item.dart';
import 'package:tagcash/apps/invoicing/models/tax.dart';
import 'package:tagcash/apps/invoicing/models/tax_total.dart';
import 'package:tagcash/apps/invoicing/setting/invoice_customization.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../constants.dart';

class UserInvoicePreviewScreen extends StatefulWidget {
  String invoice_id,
      invoice,
      amount_due,
      due_on,
      phone,
      subtotal,
      totalamount,
      type;
  String customerId,
      customerName,
      customerEmail,
      customerAddress1,
      customerAddress2,
      customerCity,
      customerZipcode,
      customerState,
      customerCountry;
  List<AddItem> getData = new List<AddItem>();
  List<Tax_total> setTaxData = new List<Tax_total>();

  UserInvoicePreviewScreen(
      {Key key,
      this.invoice_id,
      this.invoice,
      this.amount_due,
      this.due_on,
      this.customerId,
      this.customerName,
      this.customerEmail,
      this.customerAddress1,
      this.customerAddress2,
      this.customerCity,
      this.customerZipcode,
      this.customerState,
      this.customerCountry,
      this.phone,
      this.getData,
      this.subtotal,
      this.setTaxData,
      this.totalamount,
      this.type})
      : super(key: key);

  @override
  _UserInvoicePreviewScreenState createState() =>
      _UserInvoicePreviewScreenState(
          invoice_id,
          invoice,
          amount_due,
          due_on,
          customerId,
          customerName,
          customerEmail,
          customerAddress1,
          customerAddress2,
          customerCity,
          customerZipcode,
          customerState,
          customerCountry,
          phone,
          getData,
          subtotal,
          setTaxData,
          totalamount,
          type);
}

class _UserInvoicePreviewScreenState extends State<UserInvoicePreviewScreen> {
  List<AddItem> getData = new List<AddItem>();
  List<Tax_total> setTaxData = new List<Tax_total>();

  bool isLoading = false;
  String invoice_id,
      invoice,
      amount_due,
      due_on,
      phone,
      subtotal,
      totalamount,
      type,
      items = '',
      amount = '';
  String customerId,
      customerName,
      customerEmail,
      customerAddress1,
      customerAddress2,
      customerCity,
      customerZipcode,
      customerState,
      customerCountry;
  bool isBillTo = false;

  List<String> taxlist = [];
  double total_amount = 0.0;
  double ttl_tax = 0.0;
  int subTotal = 0;

  _UserInvoicePreviewScreenState(
      String invoice_id,
      String invoice,
      String amount_due,
      String due_on,
      String customerId,
      String customerName,
      String customerEmail,
      String customerAddress1,
      String customerAddress2,
      String customerCity,
      String customerZipcode,
      String customerState,
      String customerCountry,
      String phone,
      List<AddItem> getData,
      String subtotal,
      List<Tax_total> setTaxData,
      String totalamount,
      String type) {
    this.invoice_id = invoice_id;
    this.invoice = invoice;
    this.amount_due = amount_due;
    this.due_on = due_on;
    this.customerId = customerId;
    this.customerName = customerName;
    this.customerEmail = customerEmail;
    this.customerAddress1 = customerAddress1;
    this.customerAddress2 = customerAddress2;
    this.customerCity = customerCity;
    this.customerZipcode = customerZipcode;
    this.customerState = customerState;
    this.customerCountry = customerCountry;
    this.phone = phone;
    this.getData = getData;
    this.subtotal = subtotal;
    this.setTaxData = setTaxData;
    this.totalamount = totalamount;
    this.type = type;
  }

  String company = '',
      address1 = '',
      address2 = '',
      city = '',
      zipcode = '',
      country = '',
      country_id = '',
      state = '',
      state_id = '';
  String main = '', mobile = '', website = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime dateTime = DateTime.parse(due_on);
    var formatter = new DateFormat('yMMMMd');
    due_on = formatter.format(dateTime);

    print('invoice_id..................' + invoice_id);
    getConfig();
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
        address1 = jsonn[0]['address'][0]['address1'];
        address2 = jsonn[0]['address'][0]['address2'];
        city = jsonn[0]['address'][0]['city'];
        zipcode = jsonn[0]['address'][0]['zipCode'];
        country = jsonn[0]['address'][0]['country']['addressCountry'];
        country_id =
            jsonn[0]['address'][0]['country']['addressCountryId'].toString();
        state = jsonn[0]['address'][0]['state']['addressState'];
        state_id = jsonn[0]['address'][0]['state']['addressStateId'];
        main = jsonn[0]['contact'][0]['main'];
        mobile = jsonn[0]['contact'][0]['mobile'];
        website = jsonn[0]['contact'][0]['website'];
        items = jsonn[0]['columns_titles'][0]['Items'];
        amount = jsonn[0]['columns_titles'][0]['Amount'];
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
          title: 'Invoice Preview',
        ),
        body: Stack(
          children: [
            textModule(),

            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }

  Widget textModule() {
    return Container(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Request for Payment from testapp',
                  style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Row(
                    children: [
                      Flexible(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Text(
                                  'INVOICE',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFFACACAC)),
                                ),
                                Text(
                                  invoice,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFFACACAC)),
                                ),
                              ],
                            ),
                          )),
                      Flexible(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Text(
                                  'AMOUNT DUE',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFFACACAC)),
                                ),
                                Text(
                                  'PHP ' + totalamount,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFFACACAC)),
                                ),
                              ],
                            ),
                          )),
                      Flexible(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Text(
                                  'DUE ON',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFFACACAC)),
                                ),
                                Text(
                                  due_on,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFFACACAC)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        company,
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$address1,\n$address2,\n$city,\n$zipcode,\n$state,\n$country,\nTel: $main,\nMobile: $mobile,\nWebsite: $website",
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    children: [
                      Flexible(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice:',
                            style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Amount Due:',
                            style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Payment Due:',
                            style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Bill To:',
                            style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      )),
                      SizedBox(width: 20),
                      Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice,
                                style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'PHP' + totalamount,
                                style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                due_on,
                                style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      InkWell(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                customerName,
                                                style: TextStyle(
                                                  color: kUserBackColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              isBillTo == false
                                                  ? FaIcon(
                                                      FontAwesomeIcons
                                                          .caretDown,
                                                      size: 16,
                                                      color: kUserBackColor,
                                                    )
                                                  : FaIcon(
                                                      FontAwesomeIcons.caretUp,
                                                      size: 16,
                                                      color: kUserBackColor,
                                                    ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (isBillTo == false) {
                                              isBillTo = true;
                                            } else {
                                              isBillTo = false;
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ))
                            ],
                          )),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Flexible(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                          )
                        ],
                      )),
                      SizedBox(width: 10),
                      Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isBillTo == true
                                  ? Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Text(
                                            "$customerAddress1\n$customerAddress2\n$customerCity\n$customerZipcode\n$customerState\n$customerCountry",
                                            style: TextStyle(
                                              color: kUserBackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Tel: ' + phone,
                                            style: TextStyle(
                                              color: kUserBackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            customerEmail,
                                            style: TextStyle(
                                              color: kUserBackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                            ],
                          )),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'items',
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'amount',
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: getData.length,
                        itemBuilder: (BuildContext context, int index) {
                          int item = index + 1;
                          List<String> multipletax = [];
                          List<String> taxlist = [];
                          List<String> taxidlist = [];

                          var multiple_tax;
                          var tax;
                          var tax_id;

                          List<Tax> taxData = getData[index].taxx;
                          for (int i = 0; i < taxData.length; i++) {
                            multipletax.add(
                                taxData[i].name + ' ' + taxData[i].rate + '%');
                            multiple_tax = multipletax.reduce(
                                (value, element) => value + ',' + element);

                            taxlist.add(taxData[i].name);
                            tax = taxlist.reduce(
                                (value, element) => value + ',' + element);

                            taxidlist.add(taxData[i].tax_id);
                            tax_id = taxidlist.reduce(
                                (value, element) => value + ',' + element);
                          }
                          print(multiple_tax);

                          return InkWell(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Item ' + item.toString(),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: kUserBackColor,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              getData[index].desc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .apply(
                                                      color: Color(0xFFACACAC)),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              getData[index].qty,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .apply(
                                                      color: Color(0xFFACACAC)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  )),
                              onTap: () async {});
                        },
                      ),
                    )),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'PHP' + subtotal,
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: setTaxData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        setTaxData[index].name +
                                            ' ' +
                                            setTaxData[index].rate +
                                            '%:',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: kUserBackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      'PHP' + setTaxData[index].amount,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: kUserBackColor,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {});
                        },
                      ),
                    )),
                SizedBox(height: 5),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total (PHP)',
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'PHP' + totalamount,
                        style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buttonModule() {
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
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
                                builder: (context) =>
                                    InvoiceCustomizationScreen()))
                            .then((val) => val ? getConfig() : null);
                      },
                      child: Text(
                        'Customize',
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
                        if (type == 'new') {
                          Navigator.of(context)
                              .push(new MaterialPageRoute(
                                  builder: (context) => SendInvoiceScreen(
                                      invoice_id: invoice_id,
                                      customer_email: customerEmail,
                                      invoice_no: '',
                                      total_amout:
                                          total_amount.toStringAsFixed(2),
                                      send_type: 'new')))
                              .then((val) =>
                                  val ? Navigator.pop(context, true) : null);
                        } else {
                          Navigator.of(context)
                              .push(new MaterialPageRoute(
                                  builder: (context) => SendInvoiceScreen(
                                        invoice_id: invoice_id,
                                        customer_email: customerEmail,
                                        invoice_no: invoice,
                                        total_amout:
                                            total_amount.toStringAsFixed(2),
                                        send_type: 'edit',
                                      )))
                              .then((val) =>
                                  val ? Navigator.pop(context, true) : null);
                        }
                      },
                      child: Text(
                        'Send Invoice',
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
        ));
  }

  String percentage1Calculate(String id, String name, String ratee, int price) {
    int rate = int.parse(ratee);
    double total = (rate / 100) * price;

    String amount = total.toStringAsFixed(2);
    var tax =
        '{"id" : "$id", "amount" : "$amount.", "name" : "$name", "rate" : "$ratee"}';
    taxlist.add("$tax");
    print('Taxess' + tax);

    ttl_tax = ttl_tax + total;
    print("ttl_tax_ " + ttl_tax.toString());
    double doubleVar = subTotal.toDouble();
    total_amount = ttl_tax + doubleVar;
    print("ttl_anount_ " + total_amount.toString());
    return total.toStringAsFixed(2);
  }
}
