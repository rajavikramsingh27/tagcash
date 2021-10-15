import 'package:flutter/material.dart';
import 'package:tagcash/apps/invoicing/models/Invoice.dart';
import 'package:tagcash/apps/invoicing/models/UserInvoice.dart';
import 'package:tagcash/apps/invoicing/models/add_item.dart';
import 'package:tagcash/apps/invoicing/models/tax_total.dart';
import 'package:tagcash/apps/invoicing/user_invoice_preview_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class AllTabScreen extends StatefulWidget {

  @override
  _AllTabScreenState createState() => _AllTabScreenState();

}

class _AllTabScreenState extends State<AllTabScreen> {

  Future<List<UserInvoice>> invoiceList;
  Future<List<UserInvoice>> invoiceeList;

  Future<List<Invoice>> UserinvoiceList;


  bool isLoading = false;
  List<UserInvoice> getData = new List<UserInvoice>();

  //
  List<Invoice> getInvoiceData = new List<Invoice>();
  String default_id = '', default_payment_term = 'On receipt', default_title = '', default_subheading = 'Project name/description', default_footer = '', default_notes = '';
  String invoice_no = '', invoice_status = '', items = '', note = '', footer = '';
  String currentDate;
  String invoiceDate;

  var payment_due;
  var paymentDate;
  var Stuffjson;
  var Taxjson;
  var ItemTax;
  List<String> paymentduelist = [];

  String customerId = '', customerName = '', customerEmail = '', customerAddress1 = '', customerAddress2 = '', customerCity = '',
      customerZipcode = '', customerState = '', customerCountry = '', phone = '', po_so_number = '', summary = '', total = '';
  List<AddItem> getItemData = new List<AddItem>();
  List<AddItem> getIdData = new List<AddItem>();
  List<String> stufflist = [];
  List<String> taxlist = [];
  int subTotal = 0;
  String sub_total;
  List<Tax_total> setTaxData = new List<Tax_total>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    invoiceList = loadStaffCommunities();
  }

  Future<List<UserInvoice>> loadStaffCommunities() async {
    print('loadStaffCommunities');
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request('invoicing/searchInvoice');

    List responseList = response['result'];

    getData = responseList.map<UserInvoice>((json) {
      return UserInvoice.fromJson(json);
    }).toList();

    date('2020-04-11');


    setState(() {
      isLoading = false;
    });

    return getData;
  }


  Future<List<Invoice>> getInvoice(String invoice_id, String press_status) async {
    setTaxData.clear();
    print('loadStaffCommunities');
    setState(() {
      isLoading = true;
    });


    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/searchInvoice');

    var jsonn = response['result'];


    for (var items in jsonn) {
      Map myMap = items;
      if(myMap['id'] == invoice_id){
        default_title = myMap['invoice_name'];
        invoice_no = myMap['invoice_no'].toString();
        invoice_status = myMap['status'];
        invoiceDate = myMap['invoice_date'];
        note = myMap['note'];
        footer = myMap['footer'];
        po_so_number = myMap['po_so_number'];
        summary = myMap['summary'];
        sub_total = myMap['subtotal'];
        total = myMap['total'];
        var formatter = new DateFormat('yMMMMd');
        String d = formatter.format(DateTime.parse(myMap['invoice_date'])); //set formate
        currentDate = d;
        paymentDate = myMap['payment_due']['date'];
//        changePaymentDue( myMap['payment_due']['flag']); //change payment due


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
          customerAddress1 = myMap['customer']['address'][0]['address1'];
          customerAddress2 = myMap['customer']['address'][0]['address2'];
          customerCity = myMap['customer']['address'][0]['city'];
          customerZipcode = myMap['customer']['address'][0]['zipCode'];
          customerState = myMap['customer']['address'][0]['state']['addressState'];
          customerCountry = myMap['customer']['address'][0]['country']['addressCountry'];
        }
        phone = myMap['customer']['phone_no'];

        ItemTax = myMap['tax'];
        List TaxresponseList = myMap['tax'];
        setTaxData = TaxresponseList.map<Tax_total>((json) {
          return Tax_total.fromJson(json);
        }).toList();

        Stuffjson = myMap['stuff'];
        List responseList = myMap['stuff'];
        getItemData = responseList.map<AddItem>((json) {
          return AddItem.fromJson(json);
        }).toList();
        getIdData.addAll(getItemData);
        print(getItemData.length);

        for(int i=0; i<getItemData.length; i++){
          String id = getItemData[i].id;
          String quantity = getItemData[i].qty;
          var stuff = '{"id" : "$id", "quantity" : "$quantity"}';
          stufflist.add("$stuff");

          print("stufflist" + stufflist.toString());

          double d_price = double.parse(getItemData[i].price);
          int price = d_price.toInt();
          subTotal = subTotal + price;

        }

      }else{
      }

    }

    if(press_status == 'preview'){
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (context) => UserInvoicePreviewScreen(invoice_id:invoice_id, invoice: invoice_no, amount_due: total, due_on: paymentDate,
              customerId: customerId, customerName: customerName, customerEmail: customerEmail, customerAddress1: customerAddress1, customerAddress2: customerAddress2,
              customerCity: customerCity, customerZipcode: customerZipcode, customerState: customerState, customerCountry: customerCountry, phone: phone, getData: getItemData,
              subtotal: sub_total, setTaxData: setTaxData, totalamount: total),
          ));

      setState(() {
        isLoading = false;
      });

    } else{

    }


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
      payment_due = '{"flag" : "custom", "date" : ""}';
    }
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              FutureBuilder(
                  future: invoiceList,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<UserInvoice>> snapshot) {
                    if (snapshot.hasError) print(snapshot.error);
                    return snapshot.hasData
                        ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          child: Column(
                            children: [
                              Container(
                                    padding: EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 20),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            snapshot.data[index].customer_name,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.normal),
                                                            textAlign: TextAlign.center,
                                                          ),

                                                          SizedBox(height: 5,),
                                                          Text(
                                                            snapshot.data[index].invoice_name + ' '+snapshot.data[index].invoice_no.toString(),
                                                            style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          SizedBox(height: 5,),
                                                          Container(
                                                            padding: EdgeInsets.only(left: 15, right: 15, top: 2, bottom: 2),
                                                            child: Text(
                                                              snapshot.data[index].status,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.normal,),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                            decoration: new BoxDecoration (
                                                                borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                                                                color: snapshot.data[index].status == 'paid'?
                                                                Color(0xff8FAC1B):snapshot.data[index].status == 'sent'?
                                                                Color(0xff2CB5E2):snapshot.data[index].status == 'viewed'?
                                                                Color(0xffEF9B25):snapshot.data[index].status == 'overdue'?
                                                                Color(0xffD74343):snapshot.data[index].status == 'Draft'?
                                                                Color(0xff757575):Color(0xff8FAC1B)
                                                            ),
                                                          )

                                                        ],
                                                      )

                                                  ),
                                                ],
                                              ),
                                            )),
                                        Flexible(
                                            flex: 1,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            snapshot.data[index].currency + snapshot.data[index].total,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.normal),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text(
                                                            main(snapshot.data[index].date),
                                                            style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                                            textAlign: TextAlign.center,
                                                          ),

                                                        ],
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),

                              Divider(), //
                            ],
                          ),
                            onTap: () async {
                              displayBottomSheet(context, snapshot.data[index].status,  snapshot.data[index].customer_name,  snapshot.data[index].id, snapshot.data[index].invoice_name, snapshot.data[index].invoice_no.toString(), snapshot.data[index].invoice_date, snapshot.data[index].currency, snapshot.data[index].total, snapshot.data[index].date);
                            });

                      },
                    )
                        : SizedBox();
                  }
              )
            ],
          ),
          isLoading ? Center(child: Loading()) : getData.length == 0
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
                    getTranslated(context, 'invoice_nocreatedinvoice'),
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  child: Text(
                    getTranslated(context, 'invoice_appearcreatedinvoice'),
                    style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          )
              : Container(),
        ],
      )
    );

  }


  void displayBottomSheet(BuildContext context, String status, String customer_name, String invoice_id,
      String invoice_name, String invoice_no, String invoice_date, String currency, String total, String date) {
    showModalBottomSheet(
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        builder: (ctx) {
          return Container(
              height: 250,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  color:  Color(0xff757575),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),

                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          UserinvoiceList = getInvoice(invoice_id, 'preview');
                        },
                        child: Text(
                          'REVIEW',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        invoice_name + ' '+ invoice_no,
                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

               Container(
                 padding: EdgeInsets.only(left: 15, right: 15),
                 child:Divider(
                   color: Color(0xFFACACAC),
                   height: 10,
                 ),
               ),

                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoice date:',
                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        main(invoice_date),
                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child:Divider(
                    color: Color(0xFFACACAC),
                    height: 10,
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status,
                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        'Invalid date',
                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child:Divider(
                    color: Color(0xFFACACAC),
                    height: 10,
                  ),
                ),

                Flexible(child:
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Due: '+ main(date),
                            style: TextStyle(
                                fontSize: 16,
                                color: kMerchantBackColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            '('+ currency + ') ' + currency + total,
                            style: TextStyle(
                                fontSize: 16,
                                color: kUserBackColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      )

                ),)

              ],
            )
          );
        });
  }

  Widget date(String date) {
    DateTime dateTimeCreatedAt = DateTime.parse(date);
    DateTime dateTimeNow = DateTime.now();
    final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inDays;
    print('$differenceInDays');

  }

  main(String date) {
    DateTime parseDt = DateTime.parse(date);
    var newFormat = DateFormat("yMMMMd");
    String updatedDt = newFormat.format(parseDt);
    print(updatedDt);
    return updatedDt;// 20-04-03
  }

}