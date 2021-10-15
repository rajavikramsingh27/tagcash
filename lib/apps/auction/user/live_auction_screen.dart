import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/auction/components/custom_drop_down.dart';
import 'package:tagcash/apps/auction/models/auctioncategory.dart';
import 'package:tagcash/apps/auction/models/category.dart';
import 'package:tagcash/apps/auction/models/liveauction.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'create_auction_screen.dart';
import 'live_auction_detail_screen.dart';


class LiveAuctionScreen extends StatefulWidget {

  @override
  _LiveAuctionScreenState createState() => _LiveAuctionScreenState();
}

class _LiveAuctionScreenState extends State<LiveAuctionScreen> {
  TextEditingController _auctionSearchController = TextEditingController();
  List<Category> _category = Category.getDelivery();
  List<CustomDropdownMenuItem<Category>> _dropdownMenuItems;
  Category _selectedCategory;
  bool isLoading = false;

  List<AuctionCategory> getAuctionCategoryList = new List<AuctionCategory>();
  List<CustomDropdownMenuItem<AuctionCategory>> _dropdownMenuItems1;
  List<AuctionCategory> categoryData = [];
  AuctionCategory _selectedAuctionCategory;

  List<Wallet> walletData = [];
  List<Wallet> walletData1 = [];
  List<CustomDropdownMenuItem<Wallet>> _dropdownMenuItems2;
  Wallet _selectedCurrency;

  List<LiveAuction> getLiveAuctionList = new List<LiveAuction>();
  List<LiveAuction> searchData = [];

  String itemCategory = '', currencyCode = '', searchTerm = '';

  Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAuctionCategory();
    List<CustomDropdownMenuItem<Category>> buildDropdownMenuItems(
        List companies) {
      List<CustomDropdownMenuItem<Category>> items = List();
      for (Category company in companies) {
        items.add(
          CustomDropdownMenuItem(
            value: company,
            child: Text(
              company.name,
              style: TextStyle(fontSize: 14),
            ),
          ),
        );
      }
      return items;
    }

    _dropdownMenuItems = buildDropdownMenuItems(_category);
    _selectedCategory = _dropdownMenuItems[0].value;
    getWalletData();
    getLiveAuctionData();
  }

  getLogo(){
    return NetworkImage(
        "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image");
  }

  void getAuctionCategory() async {
    getAuctionCategoryList.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['app_id'] = '6';

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/GetAuctionCategories', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
        getAuctionCategoryList = responseList.map<AuctionCategory>((json) {
          return AuctionCategory.fromJson(json);
        }).toList();

        categoryData = getAuctionCategoryList;
        List<CustomDropdownMenuItem<AuctionCategory>> buildDropdownMenuItems(
            List companies) {
          List<CustomDropdownMenuItem<AuctionCategory>> items = List();
          for (AuctionCategory company in companies) {
            items.add(
              CustomDropdownMenuItem(
                value: company,
                child: Text(
                  company.category_name,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            );
          }
          return items;
        }

      _dropdownMenuItems1 = buildDropdownMenuItems(categoryData);
      setState(() {
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Wallet>> getWalletData () async{
    setState(() {
      isLoading = true;
    });
    print('============================getting wallets============================');
    if(walletData.length==0) {
      Map<String, dynamic> response = await NetworkHelper.request(
          'wallet/list');

      if (response["status"] == "success") {
        setState(() {
          isLoading = false;
        });
        List responseList = response['result'];
        List<Wallet> getData = responseList.map<Wallet>((json) {
          return Wallet.fromJson(json);
        }).toList();
        walletData = getData;

        List<CustomDropdownMenuItem<Wallet>> buildDropdownMenuItems(
            List companies) {
          List<CustomDropdownMenuItem<Wallet>> items = List();
          for (Wallet company in companies) {
            items.add(
              CustomDropdownMenuItem(
                value: company,
                child: Text(
                  company.currencyCode,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            );
          }
          return items;
        }

        _dropdownMenuItems2 = buildDropdownMenuItems(walletData);
        return getData;
      }
    }
    return walletData;
  }

  void getLiveAuctionData() async {
    getLiveAuctionList.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['item_category'] = itemCategory;
    apiBodyObj['currency_code'] = currencyCode;
    apiBodyObj['search_term'] = searchTerm;

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/LiveAuction', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getLiveAuctionList = responseList.map<LiveAuction>((json) {
        return LiveAuction.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
      });

      _timer = new Timer.periodic(Duration(seconds: 5),
              (Timer timer) => getCroneLiveAuctionData());

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getCroneLiveAuctionData() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['item_category'] = itemCategory;
    apiBodyObj['currency_code'] = currencyCode;
    apiBodyObj['search_term'] = searchTerm;

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/LiveAuction', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getLiveAuctionList = responseList.map<LiveAuction>((json) {
        return LiveAuction.fromJson(json);
      }).toList();

      setState(() {
      });
    } else {

    }
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  onSearchTextChanged(String text) async {
    searchData.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    getLiveAuctionList.forEach((userDetail) {
      if (userDetail.product_name.toLowerCase().contains(text.toLowerCase())) searchData.add(userDetail);
    });

    print(searchData.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                    child: TextField(
                      controller: _auctionSearchController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 20),
                        hintText: "Search",
                        hintStyle: TextStyle(fontSize: 18.0, color: Color(0xFFACACAC)),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(0xFFACACAC),
                        ),
                      ),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                      onChanged: onSearchTextChanged,
                    )
                ),
                SizedBox(height: 20),
                Container(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 4,
                        child: Container(
                            decoration: new BoxDecoration(
                                border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                borderRadius: BorderRadius.circular(5.0)),
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  CustomDropdownButton(
                                    isExpanded: true,
                                    value: _selectedAuctionCategory,
                                    items: _dropdownMenuItems1,
                                    hint: Container(
                                        child: Text('Category')),
                                    underline: Container(),
                                    onChanged: (val) {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (currentFocus.canRequestFocus) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                      setState(() {
                                        _selectedAuctionCategory = val;
                                        itemCategory = _selectedAuctionCategory.id;
                                        getLiveAuctionData();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        flex: 2,
                        child: Container(
                            decoration: new BoxDecoration(
                                border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                borderRadius: BorderRadius.circular(5.0)),
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  CustomDropdownButton(
                                    isExpanded: true,
                                    value: _selectedCurrency,
                                    items: _dropdownMenuItems2,
                                    hint: Container(
                                        child: Text('All')),
                                    underline: Container(),
                                    onChanged: (val) {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (currentFocus.canRequestFocus) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                      setState(() {
                                        _selectedCurrency = val;
                                        currencyCode = _selectedCurrency.currencyCode;
                                        getLiveAuctionData();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        flex: 3,
                        child: Container(
                            decoration: new BoxDecoration(
                                border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                borderRadius: BorderRadius.circular(5.0)),
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  CustomDropdownButton(
                                    isExpanded: true,
                                    value: _selectedCategory,
                                    items: _dropdownMenuItems,
                                    underline: Container(),
                                    onChanged: (val) {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (currentFocus.canRequestFocus) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                      setState(() {
                                        _selectedCategory = val;
                                        searchTerm = _selectedCategory.id.toString();
                                        getLiveAuctionData();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
               Expanded(
                 child:searchData.length != 0 ||
                     _auctionSearchController.text.isNotEmpty?
                 ListView.builder(
                     itemCount: searchData.length,
                     itemBuilder: (context, i){
                       return InkWell(
                         onTap: (){
                           Navigator.push(context,
                             MaterialPageRoute(builder: (context) => LiveAuctionDetailScreen(auctionId: searchData[i].id, auctionName: searchData[i].product_name, auctionCurrency:searchData[i].currency,
                                 auctionReservePrice: searchData[i].reserve_price, auctionImage: searchData[i].image, auctionSeller: searchData[i].owner_details['name'], auctionSellerId: searchData[i].owner_details['id'].toString(), auctionEnd: searchData[i].time_left,
                                 bidAmount: searchData[i].bid_amount_per_unit, isWatch: searchData[i].is_watch, latestBid: searchData[i].latest_bid, highestBidder: searchData[i].is_highest_bidder, getBidList: searchData[i].biddetails))).then((val)=>val? getLiveAuctionData():null);
                         },
                         child: Card(
                           child: Padding(
                             padding: const EdgeInsets.all(10.0),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.start,
                               children: <Widget>[
                                 Expanded(
                                     child: Container(
                                         child: Row(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             Container(
                                               child: Row(
                                                 children: [
                                                   Container(
                                                     decoration: BoxDecoration(
                                                       image: DecorationImage(
                                                           fit: BoxFit.fill,
                                                           image: getLiveAuctionList[i].image != ''?
                                                           NetworkImage(
                                                               getLiveAuctionList[i].image)
                                                               : NetworkImage(
                                                               "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")
                                                       ),
                                                     ),
                                                     width: 60.0,
                                                     height: 60.0,
                                                   ),
                                                 ],
                                               ),
                                             ),

                                             SizedBox(width: 10),
                                             Flexible(
                                               child: Container(
                                                 width: MediaQuery.of(context).size.width,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                     Column(
                                                       mainAxisAlignment: MainAxisAlignment.start,
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                       children: [
                                                         Text(
                                                           searchData[i].product_name,
                                                           style: Theme.of(context).textTheme.subtitle1.apply(),
                                                         ),
                                                         SizedBox(
                                                           height: 5,
                                                         ),
                                                         Text(
                                                           searchData[i].product_description,
                                                           maxLines: 1,
                                                           overflow: TextOverflow.ellipsis,
                                                           style: TextStyle(
                                                               color: Colors.grey,
                                                               fontSize: 14,
                                                               fontWeight: FontWeight.normal),
                                                         ),
                                                       ],
                                                     ),

                                                     Column(
                                                       mainAxisAlignment: MainAxisAlignment.start,
                                                       crossAxisAlignment: CrossAxisAlignment.end,
                                                       children: [
                                                         Text(
                                                           searchData[i].currency + searchData[i].reserve_price,
                                                           style: TextStyle(
                                                               fontSize: 12,
                                                               fontWeight: FontWeight.w500),
                                                         ),
                                                         Text(
                                                           searchData[i].time_left,
                                                           overflow: TextOverflow.ellipsis,
                                                           style: TextStyle(
                                                               fontSize: 12,
                                                               fontWeight: FontWeight.w500),
                                                         ),
                                                         searchData[i].is_highest_bidder == '1'?
                                                         Icon(
                                                           Icons.check_circle,
                                                           color: kPrimaryColor,
                                                           size: 24,
                                                         ):Container()
                                                       ],
                                                     ),
                                                   ],
                                                 )
                                               ),
                                             )
                                           ],
                                         )
                                     )
                                 ),

                               ],
                             ),
                           ),
                         ),
                       );
                     }
                 ): ListView.builder(
                     itemCount: getLiveAuctionList.length,
                     itemBuilder: (context, i){
                       return InkWell(
                         onTap: (){
                           Navigator.push(context,
                             MaterialPageRoute(builder: (context) => LiveAuctionDetailScreen(auctionId: getLiveAuctionList[i].id, auctionName: getLiveAuctionList[i].product_name, auctionCurrency:getLiveAuctionList[i].currency,
                                 auctionReservePrice: getLiveAuctionList[i].reserve_price, auctionImage: getLiveAuctionList[i].image, auctionSeller: getLiveAuctionList[i].owner_details['name'], auctionSellerId: getLiveAuctionList[i].owner_details['id'].toString(), auctionEnd: getLiveAuctionList[i].time_left,
                                 bidAmount: getLiveAuctionList[i].bid_amount_per_unit, isWatch: getLiveAuctionList[i].is_watch, latestBid: getLiveAuctionList[i].latest_bid, highestBidder: getLiveAuctionList[i].is_highest_bidder, getBidList: getLiveAuctionList[i].biddetails))).then((val)=>val? getLiveAuctionData():null);
                         },
                         child: Card(
                           child: Padding(
                             padding: const EdgeInsets.all(10.0),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.start,
                               children: <Widget>[
                                 Expanded(
                                     child: Container(
                                         child: Row(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             Container(
                                               child: Row(
                                                 children: [
                                                   Container(
                                                     decoration: BoxDecoration(
                                                       image: DecorationImage(
                                                           fit: BoxFit.fill,
                                                           image: getLiveAuctionList[i].image != ''?
                                                           NetworkImage(
                                                               getLiveAuctionList[i].image)
                                                               : NetworkImage(
                                                               "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")
                                                       ),
                                                     ),
                                                     width: 60.0,
                                                     height: 60.0,
                                                   ),
                                                 ],
                                               ),
                                             ),

                                             SizedBox(width: 10),
                                             Flexible(
                                               child: Container(
                                                   width: MediaQuery.of(context).size.width,
                                                   child: Row(
                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: [
                                                       Column(
                                                         mainAxisAlignment: MainAxisAlignment.start,
                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                           Text(
                                                             getLiveAuctionList[i].product_name,
                                                             style: Theme.of(context).textTheme.subtitle1.apply(),
                                                           ),
                                                           SizedBox(
                                                             height: 5,
                                                           ),
                                                           Text(
                                                             getLiveAuctionList[i].product_description,
                                                             maxLines: 1,
                                                             overflow: TextOverflow.ellipsis,
                                                             style: TextStyle(
                                                                 color: Colors.grey,
                                                                 fontSize: 14,
                                                                 fontWeight: FontWeight.normal),
                                                           ),
                                                         ],
                                                       ),

                                                       Column(
                                                         mainAxisAlignment: MainAxisAlignment.start,
                                                         crossAxisAlignment: CrossAxisAlignment.end,
                                                         children: [
                                                           Text(
                                                             getLiveAuctionList[i].currency + getLiveAuctionList[i].reserve_price,
                                                             style: TextStyle(
                                                                 fontSize: 12,
                                                                 fontWeight: FontWeight.w500),
                                                           ),
                                                           Text(
                                                             getLiveAuctionList[i].time_left,
                                                             overflow: TextOverflow.ellipsis,
                                                             style: TextStyle(
                                                                 fontSize: 12,
                                                                 fontWeight: FontWeight.w500),
                                                           ),
                                                           getLiveAuctionList[i].is_highest_bidder == '1'?
                                                           Icon(
                                                             Icons.check_circle,
                                                             color: kPrimaryColor,
                                                             size: 24,
                                                           ):Container()
                                                         ],
                                                       ),
                                                     ],
                                                   )
                                               ),
                                             )
                                           ],
                                         )
                                     )
                                 ),

                               ],
                             ),
                           ),
                         ),
                       );
                     }
                 )
               )

              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateAuctionScreen())
          ).then((val)=>val? getLiveAuctionData():null);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
