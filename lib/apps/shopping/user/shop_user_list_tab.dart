import 'package:flutter/material.dart';
import 'package:tagcash/apps/shopping/models/shop.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

import 'shop_detail_screen.dart';

class ShopUserListTabScreen extends StatefulWidget {
  final moduleCode;
  const ShopUserListTabScreen({Key key, this.moduleCode}) : super(key: key);

  @override
  _ShopUserListTabScreenState createState() => _ShopUserListTabScreenState();
}

class _ShopUserListTabScreenState extends State<ShopUserListTabScreen> with SingleTickerProviderStateMixin {
  Future<List<dynamic>> shopListData;
  String perspective = 'user';
  int communityId = 0;
  bool isLoading = false;

  TabController _controller;
  TextEditingController _shopUserController = TextEditingController();
  List<Shop> getData = new List<Shop>();
  List<Shop> searchData = [];

  TextEditingController _shopSearchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    shopListData = shopListLoad();
  }

  Future<List<dynamic>> shopListLoad() async {
    print('====================shopListLoad====================');
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
    await NetworkHelper.request('shop');

    List responseList = response['list'];
    if(responseList!= null){
      getData = responseList.map<Shop>((json) {
        return Shop.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
      });

    }
    return getData;
  }

  onSearchTextChanged(String text) async {
    searchData.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    getData.forEach((userDetail) {
      if (userDetail.title.toLowerCase().contains(text.toLowerCase())) searchData.add(userDetail);
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
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _shopSearchController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 20),
                      hintText: "Search shop",
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

                Expanded(
                  child:searchData.length != 0 ||
                      _shopSearchController.text.isNotEmpty
                  ? ListView.builder(
                      itemCount: searchData.length,
                      itemBuilder: (context, index){
                        return Card(
                            child: InkWell(
                              onTap: (){
                                FocusScope.of(context).unfocus();
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) => ShopDetailScreen(shopId: searchData[index].id.toString(), stripeId: searchData[index].stripe_connect_id, stripeEmail: searchData[index].stripe_email))
                                ).then((val)=>val?shopListData = shopListLoad():null);
                              },
                              child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: searchData[index].logoThumb != ''?
                                                NetworkImage(
                                                    searchData[index].logoThumb)
                                                    : NetworkImage(
                                                    "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo")
                                            ),
                                          ),
                                          width: 70.0,
                                          height: 70.0,
                                        ),

                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    searchData[index].title,
                                                    style: Theme.of(context).textTheme.subtitle1.apply()
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  searchData[index].description,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.normal),
                                                ),

                                              ],
                                            ),
                                          ),
                                        )

                                      ],
                                    ),
                                  )
                              ),
                            ));
                      }
                  ):ListView.builder(
                      itemCount: getData.length,
                      itemBuilder: (context, index){
                        return Card(
                            child: InkWell(
                              onTap: (){
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) => ShopDetailScreen(shopId: getData[index].id.toString(), stripeId: getData[index].stripe_connect_id, stripeEmail: getData[index].stripe_email)),
                                ).then((val)=>val?shopListData = shopListLoad():null);
                              },
                              child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: getData[index].logoThumb != ''?
                                                NetworkImage(
                                                    getData[index].logoThumb)
                                                    : NetworkImage(
                                                    "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo")
                                            ),
                                          ),
                                          width: 70.0,
                                          height: 70.0,
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    getData[index].title,
                                                    style: Theme.of(context).textTheme.subtitle1.apply()
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  getData[index].description,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ),
                            ));
                      }
                  )
                )
              ],
            )
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      )
    );
  }
}
