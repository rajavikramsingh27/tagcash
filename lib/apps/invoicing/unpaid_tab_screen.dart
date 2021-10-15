import 'package:flutter/material.dart';
import 'package:tagcash/apps/invoicing/models/UserInvoice.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class UnpaidTabScreen extends StatefulWidget {
  @override
  _UnpaidTabScreenState createState() => _UnpaidTabScreenState();
}

class _UnpaidTabScreenState extends State<UnpaidTabScreen> {
  Future<List<UserInvoice>> invoiceList;
  Future<List<UserInvoice>> invoiceeList;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<UserInvoice> getData = new List<UserInvoice>();
  List<UserInvoice> getinvoiceData = new List<UserInvoice>();

  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // memberDataList = {} as Future<List<Merchant>>;
    invoiceList = loadStaffCommunities();
  }

  Future<List<UserInvoice>> loadStaffCommunities() async {
    print('loadStaffCommunities');
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/searchInvoice');

    List responseList = response['result'];

    getData = responseList.map<UserInvoice>((json) {
      return UserInvoice.fromJson(json);
    }).toList();

    var jsonn = response['result'];

    for (var items in jsonn) {
      Map myMap = items;
      UserInvoice model = new UserInvoice();
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
        getinvoiceData.add(model);
      }
    }

    date('2020-04-11');

    setState(() {
      isLoading = false;
    });

    return getinvoiceData;
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
                  if (snapshot.hasError) {
                    return Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  print(snapshot.error);
                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
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
                                                      width:
                                                          MediaQuery.of(context)
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
                                                                    .data[index]
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
                                                                        .invoice_no
                                                                        .toString(),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText2
                                                                    .apply(
                                                                        color: Color(
                                                                            0xFFACACAC)),
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
                                                                        top: 2,
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
                                                      width:
                                                          MediaQuery.of(context)
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
                                                                snapshot
                                                                    .data[index]
                                                                    .invoice_date,
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
                                                              Icon(
                                                                Icons.edit,
                                                                size: 20,
                                                                color: Color(
                                                                    0xFF535353),
                                                              ),
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
                                                                            FontWeight.normal),
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
                                                                            .data[index]
                                                                            .invoice_no
                                                                            .toString(),
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
                                                                    padding: EdgeInsets.only(
                                                                        left:
                                                                            15,
                                                                        right:
                                                                            15,
                                                                        top: 2,
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
                                                                            FontWeight.normal,
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
                                                                    snapshot
                                                                        .data[
                                                                            index]
                                                                        .invoice_date,
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
                                                                  Icon(
                                                                    Icons.edit,
                                                                    size: 20,
                                                                    color: Color(
                                                                        0xFF535353),
                                                                  ),
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
                                                                            .data[index]
                                                                            .customer_name,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.normal),
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
                                                                            snapshot.data[index].invoice_no.toString(),
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
                                                                            snapshot.data[index].total,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.normal),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              5),
                                                                      Text(
                                                                        snapshot
                                                                            .data[index]
                                                                            .invoice_date,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                kMerchantBackColor,
                                                                            fontWeight:
                                                                                FontWeight.normal),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              5),
                                                                      Icon(
                                                                        Icons
                                                                            .edit,
                                                                        size:
                                                                            20,
                                                                        color: Color(
                                                                            0xFF535353),
                                                                      ),
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            snapshot.data[index].customer_name,
                                                                            style:
                                                                                TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
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
                                                                                snapshot.data[index].invoice_no.toString(),
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
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
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          Text(
                                                                            snapshot.data[index].currency +
                                                                                snapshot.data[index].total,
                                                                            style:
                                                                                TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 5),
                                                                          Text(
                                                                            snapshot.data[index].invoice_date,
                                                                            style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: kMerchantBackColor,
                                                                                fontWeight: FontWeight.normal),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 5),
                                                                          Icon(
                                                                            Icons.edit,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Color(0xFF535353),
                                                                          ),
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
                                                : Container(
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
                                          style: TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () async {});
                          },
                        )
                      : Container();
                })
          ],
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

  Widget date(String date) {
    DateTime dateTimeCreatedAt = DateTime.parse(date);
    DateTime dateTimeNow = DateTime.now();
    final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inDays;
    print('$differenceInDays');
  }
}
