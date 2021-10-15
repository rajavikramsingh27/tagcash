import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/item/new_item_screen.dart';
import 'package:tagcash/apps/invoicing/models/item.dart';
import 'package:tagcash/apps/invoicing/models/tax.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'add_item_screen.dart';


class SelectItemScreen extends StatefulWidget {

  @override
  _SelectItemScreenState createState() => _SelectItemScreenState();

}

class _SelectItemScreenState extends State<SelectItemScreen> {
  bool isLoading = false;
  Future<List<Item>> itemList;
  List<Item> getData = new List<Item>();
  Widget appBarTitle = new Text("Select item");
  Icon actionIcon = new Icon(Icons.search);
  TextEditingController _textController = TextEditingController();
  List<String> multipletax = [];
  List<Item> searchData = [];
  bool implyleading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemList = loadStaffCommunities();
  }


  Future<List<Item>> loadStaffCommunities() async {
    print('loadStaffCommunities');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['item'] = 'true';

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'invoicing/searchInvoice', apiBodyObj);

    List responseList = response['result'];

    getData = responseList.map<Item>((json) {
      return Item.fromJson(json);
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
      if (userDetail.name.contains(text) || userDetail.desc.contains(text))
        searchData.add(userDetail);
    });


    setState(() {});
  }


  addStringToSF(String add_customer_name, String add_customer_email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('add_customer_name', add_customer_name);
    prefs.setString('add_customer_email', add_customer_email);
  }

  send() async {
    Navigator.pop(context, true);
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
                        hintText: "Search by item name and description...",
                        hintStyle: new TextStyle(color: Color(0xFFACACAC))
                    ),
                    onChanged: onSearchTextChanged,
                  );}
                else {
                  _textController.clear();
                  onSearchTextChanged('');
                  this.actionIcon = new Icon(Icons.search);
                  this.appBarTitle = new Text("Select item");
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
                    child: itemModule()),
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );

  }

  Widget itemModule(){
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
                        'Create new item',
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
                    new MaterialPageRoute(builder: (context) => NewItemScreen()),
                  ).then((val)=>val?itemList = loadStaffCommunities():null);
                },
              ),

              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Items',
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
                          ? ListView.separated(
                        separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: searchData.length,
                        itemBuilder: (BuildContext context, int index) {
                          List<String> multipletax = [];
                          var multiple_tax;
                          List<Tax> taxData = getData[index].taxx;
                          for(int i = 0; i<taxData.length; i++){
                            multipletax.add(taxData[i].name + ' '+ taxData[i].rate + '%');
                            multiple_tax = multipletax.reduce((value, element) => value + ',' + element);
                          }
                          print(multiple_tax);

                          return InkWell(
                              child: Container(
                                padding: EdgeInsets.only(top:10, bottom: 10),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            searchData[index].name,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                              searchData[index].desc,
                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFF535353).withOpacity(0.8))
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            searchData[index].price,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(height: 2),
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
                                    )

                                  ],
                                ),
                              ),
                              onTap: () async {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) => AddItemScreen(user_id: searchData[index].id, name: searchData[index].name, desc: searchData[index].desc, price: searchData[index].price, tax: searchData[index].tax_name, income_account: searchData[index].income_account, txt_id: searchData[index].tax_id,  qty: '1', getTaxData: searchData[index].taxx,edittype:'0')),
                                ).then((val)=>val?send()():null);
                              });
                        },
                      ):ListView.separated(
                        separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: getData.length,
                        itemBuilder: (BuildContext context, int index) {

                          List<String> multipletax = [];
                          var multiple_tax;
                          List<Tax> taxData = getData[index].taxx;
                          for(int i = 0; i<taxData.length; i++){
                            multipletax.add(taxData[i].name + ' '+ taxData[i].rate + '%');
                            multiple_tax = multipletax.reduce((value, element) => value + ',' + element);
                          }
                          print(multiple_tax);
                          return InkWell(
                              child: Container(
                                padding: EdgeInsets.only(top:10, bottom: 10),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getData[index].name,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                              getData[index].desc,
                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFF535353).withOpacity(0.8))
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            getData[index].price,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(height: 2),
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
                                    )

                                  ],
                                ),
                              ),
                              onTap: () async {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) => AddItemScreen(user_id: getData[index].id, name: getData[index].name, desc: getData[index].desc, price: getData[index].price, tax: getData[index].tax_name, income_account: getData[index].income_account, txt_id: getData[index].tax_id, qty: '1', getTaxData: getData[index].taxx,edittype:'0')),
                                ).then((val)=>val?send()():null);
                              });

                        },
                      ),
                    ),
                  ],
                )

              )
            ],
          ),
        )
    );
  }

}


