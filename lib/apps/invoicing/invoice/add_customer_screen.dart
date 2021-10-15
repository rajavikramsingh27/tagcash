import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/customer/new_customer_screen.dart';
import 'package:tagcash/apps/invoicing/models/customer.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';


class AddCustomerScreen extends StatefulWidget {

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();

}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  bool isLoading = false;
  Future<List<Customer>> customerList;
  List<Customer> getData = new List<Customer>();
  Widget appBarTitle = new Text("Add Customer");
  Icon actionIcon = new Icon(Icons.search);
  TextEditingController _textController = TextEditingController();
  List<Customer> searchData = [];
  bool implyleading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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


  addStringToSF(String customer_id, String add_customer_name, String add_customer_email, String address1,  String address2,
      String city, String zipcode, String state, String country, String phone ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('add_customer_id', customer_id);
    prefs.setString('add_customer_name', add_customer_name);
    prefs.setString('add_customer_email', add_customer_email);
    prefs.setString('add_customer_address1', address1);
    prefs.setString('add_customer_address2', address2);
    prefs.setString('add_customer_city', city);
    prefs.setString('add_customer_zipcode', zipcode);
    prefs.setString('add_customer_state', state);
    prefs.setString('add_customer_country', country);
    prefs.setString('add_phone', phone);

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          automaticallyImplyLeading: implyleading,
          actions: <Widget>[
            new IconButton(icon: actionIcon,onPressed:(){
              setState(() {
                if ( this.actionIcon.icon == Icons.search){
                  this.actionIcon = new Icon(Icons.close);
                  this.implyleading = false;
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
                  this.appBarTitle = new Text("Add Customer");
                  this.implyleading = true;
                }

              });
            }),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Container(
                    child: customerModule()),
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );

  }

  Widget customerModule(){
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Row(
                  children: [
                    Icon(
                        Icons.add_circle_outline, size: 30, color: Color(0xFF832b17)
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Create a new customer',
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
                Navigator.of(context).push(
                  new MaterialPageRoute(builder: (context) => NewCustomerScreen()),
                ).then((val)=>val?customerList = loadStaffCommunities():null);
              },
            ),

            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                'Customers',
                style: TextStyle(
                    color: kUserBackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ),
           Container(
             width: MediaQuery.of(context).size.width,
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
                                     child: Row(
                                       children: [
                                         Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             Container(
                                                 margin: EdgeInsets.only(bottom: 10),
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
                                     addStringToSF(searchData[index].id, searchData[index].customer_name, searchData[index].email, searchData[index].address['address1'], searchData[index].address['address2'], searchData[index].address['city'], searchData[index].address['zipCode'],
                                         searchData[index].address['state']['addressState'], searchData[index].address['country']['addressCountry'], searchData[index].phone_no);
                                     Navigator.pop(context, true);
                                   });
                             },
                           )
                               : SizedBox();
                         }):FutureBuilder(
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
                                     child: Row(
                                       children: [
                                         Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             Container(
                                                 margin: EdgeInsets.only(bottom: 10),
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
                                     if(snapshot.data[index].address == '' || snapshot.data[index].address == null){
                                       addStringToSF(snapshot.data[index].id, snapshot.data[index].customer_name, snapshot.data[index].email,
                                           '', '', '','', '', '', snapshot.data[index].phone_no);
                                       Navigator.pop(context, true);
                                     } else{
                                       addStringToSF(snapshot.data[index].id, snapshot.data[index].customer_name, snapshot.data[index].email,
                                           snapshot.data[index].address['address1'], snapshot.data[index].address['address2'], snapshot.data[index].address['city'], snapshot.data[index].address['zipCode'],
                                           snapshot.data[index].address['state']['addressState'], snapshot.data[index].address['country']['addressCountry'], snapshot.data[index].phone_no);
                                       Navigator.pop(context, true);
                                     }
                                   });
                             },
                           )
                               : SizedBox();
                         })
                 )
               ],
             ),
           )
          ],
        ),
      )
    );
  }

}


