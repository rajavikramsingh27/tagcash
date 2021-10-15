import 'package:flutter/material.dart';
import 'package:tagcash/apps/invoicing/models/customer.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'edit_customer_screen.dart';
import 'new_customer_screen.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  Future<List<Customer>> customerList;
  Future<List<Customer>> customersList;
  bool isLoading = false;
  List<Customer> getData = new List<Customer>();
  Icon actionIcon = new Icon(Icons.search);
  Widget appBarTitle = new Text("Customers");
  TextEditingController _textController = TextEditingController();
  List<Customer> searchData = [];


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    customerList = loadStaffCommunities();
  }

  Future<List<Customer>> loadStaffCommunities() async {
    print('loadStaffCommunities');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['customer'] = 'true';

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/searchInvoice', apiBodyObj);

    List responseList = response['result'];

    getData = responseList.map<Customer>((json) {
      return Customer.fromJson(json);
    }).toList();

    setState(() {
      isLoading = false;
    });

    return getData;
  }




  onSearchTextChanged(String text) async {
    searchData.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    getData.forEach((userDetail) {
      if (userDetail.customer_name.contains(text) || userDetail.email.contains(text))
        searchData.add(userDetail);
    });


    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            new IconButton(icon: actionIcon,onPressed:(){
              setState(() {
                if ( this.actionIcon.icon == Icons.search){
                  this.actionIcon = new Icon(Icons.close);
                  this.appBarTitle = new TextField(
                    controller: _textController,
                    style: new TextStyle(
                      color: Colors.white,

                    ),
                    decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search,color: Colors.white),
                        hintText: "Search by customer name and email ",
                        hintStyle: new TextStyle(color: Color(0xFFACACAC))
                    ),
                    onChanged: onSearchTextChanged,
                  );}
                else {
                  _textController.clear();
                  onSearchTextChanged('');
                  this.actionIcon = new Icon(Icons.search);
                  this.appBarTitle = new Text("Customers");
                }

              });
            }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => NewCustomerScreen()),
            ).then((val)=>val?customerList = loadStaffCommunities():null);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
          backgroundColor: Colors.black,
          elevation: 5,
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        child: searchData.length != 0 || _textController.text.isNotEmpty
                            ? FutureBuilder(
                            future: customerList,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Customer>> snapshot) {
                              if (snapshot.hasError) print(snapshot.error);
                              return snapshot.hasData
                                  ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: searchData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                    child: Row(
                                                      children: [
                                                        Ink(
                                                            decoration: const ShapeDecoration(
                                                              color:  Color(0xFF832b17),
                                                              shape: CircleBorder(),
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.all(15),
                                                              child: Text('T',
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 24,
                                                                    fontWeight: FontWeight.normal),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            )
                                                        ),
                                                        SizedBox(width: 15),
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Text(
                                                              searchData[index]
                                                                  .customer_name,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              searchData[index].email,
                                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        Navigator.of(context).push(
                                          new MaterialPageRoute(builder: (context) => EditCustomerScreen(id: searchData[index].id, customer_name: searchData[index].customer_name,
                                              email: searchData[index].email, contact_name: searchData[index].contact_name, phone_no: searchData[index].phone_no, mobile_no: searchData[index].mobile_no,
                                              currency: searchData[index].currency, accounting_number: searchData[index].accounting_number, website: searchData[index].website, type: searchData[index].type,
                                              merchant_id: searchData[index].merchant_id, address: searchData[index].address, shipping_details: searchData[index].shipping_details)),
                                        ).then((val)=>val?customerList = loadStaffCommunities():null);
                                      });
                                },
                              )
                                  : SizedBox();
                            }): FutureBuilder(
                            future: customerList,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Customer>> snapshot) {
                              if (snapshot.hasError) print(snapshot.error);
                              return snapshot.hasData
                                  ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                    child: Row(
                                                      children: [
                                                        Ink(
                                                            decoration: const ShapeDecoration(
                                                              color:  Color(0xFF832b17),
                                                              shape: CircleBorder(),
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.all(15),
                                                              child: Text('T',
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 24,
                                                                    fontWeight: FontWeight.normal),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            )
                                                        ),
                                                        SizedBox(width: 15),
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Text(
                                                              snapshot.data[index]
                                                                  .customer_name,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              snapshot
                                                                  .data[index].email,
                                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        Navigator.of(context).push(
                                          new MaterialPageRoute(builder: (context) => EditCustomerScreen(id: snapshot.data[index].id, customer_name: snapshot.data[index].customer_name,
                                              email: snapshot.data[index].email, contact_name: snapshot.data[index].contact_name, phone_no: snapshot.data[index].phone_no, mobile_no: snapshot.data[index].mobile_no,
                                              currency: snapshot.data[index].currency, accounting_number: snapshot.data[index].accounting_number, website: snapshot.data[index].website, type: snapshot.data[index].type,
                                              merchant_id: snapshot.data[index].merchant_id, address: snapshot.data[index].address, shipping_details: snapshot.data[index].shipping_details)),
                                        ).then((val)=>val?customerList = loadStaffCommunities():null);
                                      });
                                },
                              )
                                  : SizedBox();
                            }),
                      )
                    ],
                  ),
                ),


              ],
            ),
            isLoading
                ? Center(child: Loading())
                : getData.length == 0
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                getTranslated(context, 'invoice_nocustomer'),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
          ],
        ));
  }
}
