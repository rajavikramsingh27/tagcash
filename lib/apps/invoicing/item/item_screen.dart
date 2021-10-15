import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tagcash/apps/invoicing/models/item.dart';
import 'package:tagcash/apps/invoicing/models/tax.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'edit_item_screen.dart';
import 'new_item_screen.dart';

class ItemScreen extends StatefulWidget {

  @override
  _ItemScreenState createState() => _ItemScreenState();

}

class _ItemScreenState extends State<ItemScreen> {
  Future<List<Item>> itemList;
  Future<List<Item>> itemsList;
  bool isLoading = false;
  List<Item> getData = new List<Item>();
  List<String> multipletax = [];
  List<Item> searchData = [];


  Widget appBarTitle = new Text("Items");
  Icon actionIcon = new Icon(Icons.search);

  TextEditingController _textController = TextEditingController();


  @override
  void initState() {
    super.initState();

    itemList = loadStaffCommunities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // memberDataList = {} as Future<List<Merchant>>;
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

      appBar: new AppBar(
          title:appBarTitle,
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
                        hintText: "Search by item name and description...",
                        hintStyle: new TextStyle(color: Color(0xFFACACAC))
                    ),
                    onChanged: onSearchTextChanged,
                  );}
                else {
                  _textController.clear();
                  onSearchTextChanged('');
                  this.actionIcon = new Icon(Icons.search);
                  this.appBarTitle = new Text("Items");
                }


              });
            } ,),]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => NewItemScreen()),
          ).then((val)=>val?itemList = loadStaffCommunities():null);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
        backgroundColor: Colors.black,
        elevation: 5,
      ),
      body:
      Stack(
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
                          ?ListView.separated(
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
                                child:Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.all(10),
                                            width: MediaQuery.of(context).size.width,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width,
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
                                                    )
                                                ),

                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width,
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
                                                )
                                              ],
                                            )
                                        ),
                                        Divider(
                                          height: 5,
                                          color: Color(0xFFACACAC),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) => EditItemScreen(user_id: searchData[index].id, name: searchData[index].name, desc: searchData[index].desc, price: searchData[index].price, tax: searchData[index].tax_name, income_account: searchData[index].income_account, txt_id: searchData[index].tax_id, getTaxData: searchData[index].taxx,)),
                                ).then((val)=>val?itemList = loadStaffCommunities():null);
                              }
                          );
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
                                child:Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.all(10),
                                            width: MediaQuery.of(context).size.width,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width,
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
                                                    )
                                                ),

                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width,
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
                                                )
                                              ],
                                            )
                                        ),
                                        Divider(
                                          height: 5,
                                          color: Color(0xFFACACAC),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) => EditItemScreen(user_id: getData[index].id, name: getData[index].name, desc: getData[index].desc, price: getData[index].price, tax: getData[index].tax_name, income_account: getData[index].income_account, txt_id: getData[index].tax_id, getTaxData: getData[index].taxx,)),
                                ).then((val)=>val?itemList = loadStaffCommunities():null);
                              }
                          );
                        },
                      ),
                    )
                  ],
                ),
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
                    getTranslated(context, 'invoice_noitem'),
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
      )
    );

  }

}