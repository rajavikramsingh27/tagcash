import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/apps/shopping/models/cart.dart';
import 'package:tagcash/apps/shopping/user/shop_cart_list_screen.dart';
import 'package:tagcash/apps/shopping/user/shop_favorite_list_screen.dart';
import 'package:tagcash/apps/shopping/user/shop_history_list_screen.dart';
import 'package:tagcash/apps/shopping/user/shop_user_list_tab.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/screens/qr_scan_screen.dart';
import 'package:tagcash/services/networking.dart';
import '../../constants.dart';
import 'merchant/create_new_shop.dart';
import 'models/shop.dart';
import 'models/shop_merchant.dart';
import 'shop_merchant_view.dart';

class ShoppingListScreen extends StatefulWidget {
  final moduleCode;
  int selectedPage;
  ShoppingListScreen({Key key, this.moduleCode, this.selectedPage}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShoppingListScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<ShoppingListScreen>{
  Future<List<dynamic>> shopListData;
  String perspective = 'user';
  int communityId = 0;
  bool isLoading = false;

  TabController _controller;
  List<Cart> getCartData = new List<Cart>();
  List cartList;

  @override
  void initState() {
    super.initState();
    perspective = Provider.of<PerspectiveProvider>(context, listen: false)
        .getActivePerspective();
    if (perspective == 'community') {
      communityId =
          Provider.of<MerchantProvider>(context, listen: false).merchantData.id;

      shopListData = shopListLoad();
    }else{
      getCartList();
    }

    if(widget.selectedPage != null){
      _controller = new TabController(
        initialIndex: widget.selectedPage,
        length: 5,
        vsync: this,
      );
    } else{
      widget.selectedPage = 0;
      _controller = new TabController(
        initialIndex: widget.selectedPage,
        length: 5,
        vsync: this,
      );
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    perspective = Provider.of<PerspectiveProvider>(context, listen: false)
        .getActivePerspective();
    if (perspective == 'community') {
      communityId =
          Provider.of<MerchantProvider>(context, listen: false).merchantData.id;

      shopListData = shopListLoad();
    }else{
      getCartList();
    }
  }

  void getCartList() async {

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/cart');

    if (response['status'] == 'success') {
      if(response['list'] != null){
        cartList = response['list'][0]['item'];
        setState(() {
          print(cartList.length);
        });
      } else{
        cartList = [];
      }

    } else {

    }
  }


  Future<List<dynamic>> shopListLoad() async {
    print('====================shopListLoad====================');
    setState(() {
      isLoading = true;
    });

    Map<String, String> postData = {};
    if(widget.moduleCode.toString()!="" || widget.moduleCode.toString()!=null){
      String moduleCode = widget.moduleCode.toString();
      List<dynamic> mcl = moduleCode.split("_");
      print(mcl[0]); // show module name to be matched, send in api. as same module can be called multiple times.
      postData["moduleCode"]= mcl[0];
    }

    if (perspective == 'community') {
      postData['merchant_id'] = communityId.toString();
      Map<String, dynamic> response = await NetworkHelper.request('shop/my');
      List responseList = response['list'];
      List<dynamic> getDataMerchant = [];
      if(responseList!=null){
        setState(() {
          isLoading = false;
        });
        getDataMerchant = responseList.map<ShopMerchant>((json) {
          return ShopMerchant.fromJson(json);
        }).toList();
      } else{
        setState(() {
          isLoading = false;
        });
      }
      return getDataMerchant;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('shop', postData);

    List responseList = response['list'];
    List<dynamic> getData = [];
    if(responseList!= null){
      getData = responseList.map<Shop>((json) {
        return Shop.fromJson(json);
      }).toList();
    } else{

    }

    return getData;
  }

  searchClicked(String searchKey) {
    print(searchKey);
  }

  changeView(i, shop) async{
    if (perspective == "community") {

      Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => ShopMerchantView(shop: shop, moduleCode: widget.moduleCode)),
      ).then((val)=>val?shopListData = shopListLoad():null);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
            'user'
            ? Colors.black
            : Color(0xFFe44933),
        title: Text(perspective == "community"?'SETUP' : 'TAG Shopping'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home_outlined,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          perspective == "community"?
          Container(
            child: FutureBuilder<List<dynamic>>(
              future: shopListData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> data = snapshot.data;
                  if(data.length==0){
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'No Shop Found',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6.apply(),
                            ),
                          ],
                        )
                    );}
                  return _buildShopList(data);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(
                  child: new SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: const CircularProgressIndicator()),
                );
              },
            ),
          ) : Column(
            children: [
              Container(
                width: double.infinity,
                decoration: new BoxDecoration(color: Colors.black),
                child:Align(
                  alignment: Alignment.center,
                  child: TabBar(
//                    isScrollable: MediaQuery.of(context).orientation == Orientation.portrait?
//                    true : false,
                    controller: _controller,
                    unselectedLabelColor:  Color(0xFFACACAC),
                    labelColor:  Colors.white,
                    labelPadding: EdgeInsets.only(left: 0, right: 0),
                    indicatorWeight:3,
                    indicatorColor:  kPrimaryColor,
//                    labelPadding: EdgeInsets.symmetric(horizontal: 25.0),
                    tabs: <Tab>[
                      Tab(text: 'SHOPS'),
                      Tab(text: 'HISTORY'),
//                    const Tab(icon: Icon(Icons.shopping_cart)),
                      Tab(icon: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          cartList != null && cartList.length != 0?
                          Stack(
                            children: [
                              Positioned(
                                child: new Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white,
                                        width: 1.0
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: new Text(
                                    cartList != null?
                                    cartList.length.toString():
                                    '0',
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ):Container(),
                          Icon(Icons.shopping_cart),
                        ],
                      ),),
                      Tab(icon: FaIcon(FontAwesomeIcons.solidHeart)),
                      Tab(icon: Icon(Icons.qr_code_outlined)),
                    ],
                  ),
                )
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 0.5,
                color: Color(0xFFACACAC),
              ),
              Flexible(child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                  controller: _controller,
                  children: <Widget>[
                    new ShopUserListTabScreen(),
                    new ShopHistoryListScreen(),
                    new ShopCartListScreen(controller: _controller),
                    new ShopFavoriteListScreen(),
                    new QrScanScreen(),
                  ],
                ),
              )),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),

      floatingActionButton: perspective == "community"?FloatingActionButton(
        onPressed: ()async {
          print("create new shop");
          Navigator.of(context).push(
            new MaterialPageRoute(builder: (context) => CreateNewShop()),
          ).then((val)=>val?shopListData = shopListLoad():null);
        },
        child: Icon(Icons.add),
        tooltip: getTranslated(context, "create_reward"),
        backgroundColor: Theme.of(context).primaryColor,
      ) : Container()
    );
  }

  ListView _buildShopList(shopList) {
    return ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: shopList.length,
        itemBuilder: (context, i) {
          return _buildRow(i, shopList[i]);
        });
  }

  _buildRow(i, shop) {
    String shopSubTitle = shop.totalProduct.toString();
    shopSubTitle += (shop.totalProduct == 1) ? " Product" : " Products";
    return Card(
        child: ListTile(
      leading: shop.logoThumb !=null && shop.logoThumb !=''?
      Image.network(
        shop.logoThumb,
        height: 50.0,
        width: 50.0,
        fit: BoxFit.fill,
      ):Image.network(
       'https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo',
        height: 50.0,
        width: 50.0,
        fit: BoxFit.fill,
      ),
      title: Text(shop.title),
      subtitle: Text(shopSubTitle),
      onTap: () {
        changeView(i, shop);
      },
    ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}
