import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/shopping/components/custom_drop_down.dart';
import 'package:tagcash/apps/shopping/models/Inventory.dart';
import 'package:tagcash/apps/shopping/models/product.dart';
import 'package:tagcash/apps/shopping/user/shop_cart_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

import '../shopping_list_screen.dart';

class ShopDetailScreen extends StatefulWidget {
  final String shopId,stripeId, stripeEmail;

  const ShopDetailScreen({Key key, this.shopId, this.stripeId, this.stripeEmail}) : super(key: key);

  @override
  _ShopDetailScreenState createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  String shopName = '', shopImage, shopDesc = '';
  bool isLoading = false, isListType = false;
  List<Product> getProductData = new List<Product>();
  List<CustomDropdownMenuItem<Inventory>> _dropdownMenuItems;
  List<Inventory> getInventoryCategory = new List<Inventory>();
  List<Inventory> categoryData = [];
  Inventory addAll;
  Inventory _selectedCategory;
  String emptyMessage = '';
  List cartList;
  String ImageUrl = 'https://tagbondbeta.s3.amazonaws.com/uploads/shopping/';

  @override
  void initState() {
    super.initState();
    getCategory();
    getCartList();
  }

  void getCategory() async {
    getInventoryCategory.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shopId;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/ListCategory', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['list'];
      if(responseList.isNotEmpty){
        getInventoryCategory = responseList.map<Inventory>((json) {
          return Inventory.fromJson(json);
        }).toList();

        Inventory inventory = new Inventory(0, 0, 'All Categories', "", 0, 0, 0, "", "", 0, 0);
        getInventoryCategory.insert(0, inventory);

        categoryData = getInventoryCategory;
        List<CustomDropdownMenuItem<Inventory>> buildDropdownMenuItems(
            List companies) {
          List<CustomDropdownMenuItem<Inventory>> items = List();
          for (Inventory company in companies) {
            items.add(
              CustomDropdownMenuItem(
                value: company,
                child: Text(
                  company.name,
                ),
              ),
            );
          }
          return items;
        }

        _dropdownMenuItems = buildDropdownMenuItems(categoryData);
        _selectedCategory = _dropdownMenuItems[0].value;

        getProductList();

      } else{
        emptyMessage = 'No Inventory Found';
        setState(() {
          isLoading = false;
        });
      }

    } else {
      setState(() {
        isLoading = false;
      });
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



  void getProductList() async {
    emptyMessage = '';
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shopId;
    if(_selectedCategory.name != 'All Categories'){
      apiBodyObj['category_id'] = _selectedCategory.id.toString();
    }

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/ProductList', apiBodyObj);


    if (response['status'] == 'success') {
      if(response['list'] != null){
        if(response['list']['inventory'] != null){
          shopName = response['list']['shop_detail'][0]['title'];
          shopImage = ImageUrl + response['list']['shop_detail'][0]['logo'];
          shopDesc = response['list']['shop_detail'][0]['description'];
          List responseList = response['list']['inventory'];
          getProductData = responseList.map<Product>((json) {
            return Product.fromJson(json);
          }).toList();

          setState(() {
            isLoading = false;
          });

        } else{
          emptyMessage = 'No Inventory Found';
          setState(() {
            isLoading = false;
          });
        }
      } else{
        emptyMessage = 'No Inventory Found';
        setState(() {
          isLoading = false;
        });
      }

    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']);
    }
  }


  @override
  Widget build(BuildContext context) {

    var _crossAxisSpacing = 8;
    var _screenWidth = MediaQuery.of(context).size.width;
    var _crossAxisCount = 3;
    var _width = ( _screenWidth - ((_crossAxisCount - 2) * _crossAxisSpacing)) / _crossAxisCount;
    var cellHeight = 120;
    var _aspectRatio = _width /cellHeight;

    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 0)),
        );
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor:
            Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                'user'
                ? Colors.black
                : Color(0xFFe44933),
            title: Text('TAG Shopping'),
            actions: [
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pushReplacement(
                    new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 2)),
                  );
                },
                child: Row(
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
                              minWidth: 10,
                              minHeight: 10,
                            ),
                            child: new Text(
                              cartList != null?
                              cartList.length.toString():
                              '',
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ):Container(),
                    Icon(Icons.shopping_cart),
                  ],
                ),
              ),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.solidHeart, size: 20),
                  onPressed: (){
                    Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 3)),
                    );
                  }
              )
            ],
          ),
          body: Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 15, top: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                                onTap: (){
                                },
                                child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                        image: DecorationImage(
                                            image: shopImage != '' && shopImage != null?
                                            NetworkImage(
                                                shopImage)
                                                : NetworkImage(
                                                "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo"),
                                            fit: BoxFit.fill)))
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                                onTap: (){
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          shopName,
                                          style: Theme.of(context).textTheme.subtitle1.apply()
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        shopDesc,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            flex: 6,
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
                                            _selectedCategory = val;
                                            getProductData.clear();
                                            getProductList();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          SizedBox(width: 5),
                          Flexible(
                              flex: 1,
                              child:Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: isListType == false?
                                  IconButton(
                                      icon: FaIcon(FontAwesomeIcons.th, size: 30, color: Colors.grey),
                                      onPressed: (){
                                        setState(() {
                                          isListType = true;
                                        });
                                      }
                                  ) : IconButton(
                                      icon: FaIcon(FontAwesomeIcons.listUl, size: 30, color: Colors.grey),
                                      onPressed: (){
                                        setState(() {
                                          isListType = false;
                                        });
                                      }
                                  )
                              )
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      isListType == false?
                      getProductData.length != 0?
                      Expanded(
                        child: ListView.builder(
                            itemCount: getProductData.length,
                            itemBuilder: (context, i){
                              return InkWell(
                                  onTap: (){
                                    Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) => ShopCartScreen(getProductData: getProductData, index: i,
                                          shopId: widget.shopId, isType: '0', stripeId: widget.stripeId, stripeEmail: widget.stripeEmail)),
                                    ).then((val)=>val?Navigator.pop(context, true):null);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: getProductData[i].image_thumb != ''?
                                                    NetworkImage(
                                                        getProductData[i].image_thumb)
                                                        :NetworkImage(
                                                        "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")
                                                ),
                                              ),
                                              width: 70.0,
                                              height: 60.0,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                                child: Container(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          getProductData[i].name,
                                                          style: Theme.of(context).textTheme.subtitle1.apply()
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        getProductData[i].currency_code + ' ' + getProductData[i].price.toString(),
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                              );
                            }
                        ),
                      ) : Expanded(
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  emptyMessage,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline6.apply(),
                                ),
                              ],
                            )
                        ),
                      )
                          : Expanded(
                          child:  GridView.builder(
                            padding: EdgeInsets.only(),
                            shrinkWrap: false,
                            itemCount: getProductData.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _crossAxisCount,childAspectRatio: _aspectRatio),
                            itemBuilder: (context, index) {
                              final item = getProductData[index];
                              return InkWell(
                                onTap: (){
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>ShopCartScreen(getProductData: getProductData, index: index,
                                        shopId: widget.shopId, isType: '0', stripeId: widget.stripeId, stripeEmail: widget.stripeEmail)),
                                  ).then((val)=>val?Navigator.pop(context, true):null);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Card(
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 70.0,
                                                height: 60.0,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.fill,
                                                      image: getProductData[index].image_thumb != ''?
                                                      NetworkImage(
                                                          getProductData[index].image_thumb)
                                                          :NetworkImage(
                                                          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo")
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                  getProductData[index].name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: Theme.of(context).textTheme.bodyText1.apply()
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                    elevation: 0.5,
                                  ),
                                ),
                              );
                            },
                          )
                      )
                    ],
                  )
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          )
      ),
    );
  }
}
