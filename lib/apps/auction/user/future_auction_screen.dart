import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/auction/models/auctioncategory.dart';
import 'package:tagcash/apps/auction/models/category.dart';
import 'package:tagcash/apps/auction/models/liveauction.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

import '../components/custom_drop_down.dart';
import 'future_auction_detail_screen.dart';

class FutureAuctionScreen extends StatefulWidget {

  @override
  _FutureAuctionScreenState createState() => _FutureAuctionScreenState();
}

class _FutureAuctionScreenState extends State<FutureAuctionScreen> {
  List<Category> _category = Category.getDelivery();
  List<CustomDropdownMenuItem<Category>> _dropdownMenuItems;
  Category _selectedCategory;
  bool isLoading = false;

  List<LiveAuction> getFutureAuctionList = new List<LiveAuction>();

  List<AuctionCategory> getAuctionCategoryList = new List<AuctionCategory>();
  List<CustomDropdownMenuItem<AuctionCategory>> _dropdownMenuItems1;
  List<AuctionCategory> categoryData = [];
  AuctionCategory _selectedAuctionCategory;

  String itemCategory = '', searchTerm = '';
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

    getFutureAuctionData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  getLogo(){
    return NetworkImage(
        "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image");
  }

  void getFutureAuctionData() async {
    getFutureAuctionList.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['item_category'] = itemCategory;
    apiBodyObj['search_term'] = searchTerm;

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/FutureAuction', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getFutureAuctionList = responseList.map<LiveAuction>((json) {
        return LiveAuction.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
      });

      _timer = new Timer.periodic(Duration(seconds: 5),
              (Timer timer) => getCroneFutureAuctionData());

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getCroneFutureAuctionData() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['item_category'] = itemCategory;
    apiBodyObj['search_term'] = searchTerm;

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/FutureAuction', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getFutureAuctionList = responseList.map<LiveAuction>((json) {
        return LiveAuction.fromJson(json);
      }).toList();

      setState(() {});
    } else {

    }
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
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
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
                                        getFutureAuctionData();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ),
                      SizedBox(width: 20),
                      Flexible(
                        flex: 1,
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
                                        getFutureAuctionData();
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
                  child:ListView.builder(
                      itemCount: getFutureAuctionList.length,
                      itemBuilder: (context, i){
                        return InkWell(
                          onTap: (){
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => FutureAuctionDetailScreen(auctionId: getFutureAuctionList[i].id, auctionName: getFutureAuctionList[i].product_name,
                                auctionImage: getFutureAuctionList[i].image, auctionSeller: getFutureAuctionList[i].owner_details['name'],
                                auctionStartDate: getFutureAuctionList[i].start_date_time, isWatch: getFutureAuctionList[i].is_watch)),
                            );
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
                                                            image: getFutureAuctionList[i].image != ''?
                                                            NetworkImage(
                                                                getFutureAuctionList[i].image)
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
                                                              getFutureAuctionList[i].product_name,
                                                              style: Theme.of(context).textTheme.subtitle1.apply(),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              getFutureAuctionList[i].product_description,
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
                                                              getFutureAuctionList[i].time_left,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w500),
                                                            ),
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
                  ),
                )

              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}