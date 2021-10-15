import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/shopping/models/order.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import '../shopping_list_screen.dart';

class ShopHistoryDetailScreen extends StatefulWidget {
  String shopId = '', shopTitle = '', deliveryStatus = '', isType = '';
  List<Order> getHistoryData = new List<Order>();

  ShopHistoryDetailScreen({Key key, this.shopId, this.shopTitle, this.deliveryStatus, this.getHistoryData, this.isType}) : super(key: key);

  @override
  _ShopHistoryDetailScreenState createState() => _ShopHistoryDetailScreenState();
}

class _ShopHistoryDetailScreenState extends State<ShopHistoryDetailScreen> {
  bool isLoading = false, isTax = false, isCart = true;
  int total = 0;

  List<String> sizeList = [];
  List<String> colorList = [];
  List<String> otherList = [];

  List cartList;

  @override
  void initState() {
    super.initState();
    getCartList();
  }

  void getCartList() async {
    widget.isType == '1'?
    setState(() {
      isLoading = true;
    }) : Container();
    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shopId;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/cart', apiBodyObj);


    if (response['status'] == 'success') {
      if(response['list'] != null){
        String shop_id = response['list'][0]['shop_id'].toString();
        cartList = response['list'][0]['item'];
        if(shop_id == widget.shopId){
          isCart = true;
        }else{
          isCart = false;
        }

      }
      widget.isType == '1'?
      setState(() {
        isLoading = false;
      }) : Container();

    } else {

    }
  }

  void addCart(String inventory_id, String qty, colorObject, sizeObject, otherObject, String clear_all) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shopId;
    apiBodyObj['inventory_id'] = inventory_id;
    apiBodyObj['qty'] = qty;
    apiBodyObj['color'] = colorObject;
    apiBodyObj['size'] = sizeObject;
    apiBodyObj['other'] = otherObject;
    apiBodyObj['clear_all'] = clear_all;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/AddToCart', apiBodyObj);
    if (response['status'] == 'success') {

      setState(() {
        isLoading = false;
      });

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text('Product is added successfully in cart.'),
            actions: [
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 1)),
        );
      },
      child:Scaffold(
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
                child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                              padding: EdgeInsets.all(15),
                              color: kUserBackColor,
                              child: Row(
                                children: [
                                  Text(
                                    widget.shopTitle,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              )
                          ),
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.getHistoryData.length,
                              itemBuilder: (context, i){

                                return InkWell(
                                  onTap: (){
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: widget.getHistoryData.length != 0?
                                                  widget.getHistoryData[i].image_thumb != ''?
                                                  NetworkImage(
                                                      widget.getHistoryData[i].image_thumb)
                                                      : NetworkImage(
                                                      "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")
                                                      : NetworkImage(
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
                                            child: GestureDetector(
                                                onTap: (){
                                                },
                                                child: Container(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          widget.getHistoryData[i].productName,
                                                          style: Theme.of(context).textTheme.subtitle1.apply()
                                                      ),

                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        widget.getHistoryData[i].currency_code + ' '+  widget.getHistoryData[i].item_price,
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (){
//                                            displayBottomSheet(getCartData[i].id, getCartData[i].qty);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1.0
                                                ),
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: 12,
                                                minHeight: 12,
                                              ),
                                              child: new Text(
                                                widget.getHistoryData[i].qty.toString(),
                                                style: new TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )

                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                          Container(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subtotal',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        subTotal(),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  widget.getHistoryData[0].deliveryCharge != ''?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Delivery Charge',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        widget.getHistoryData[0].deliveryCharge,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ) : Container(),
                                  widget.getHistoryData[0].deliveryCharge != ''?
                                  SizedBox(height: 5) : Container(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'Total',
                                          style: Theme.of(context).textTheme.subtitle1.apply()
                                      ),
                                      Text(
                                          mainTotal(),
                                          style: Theme.of(context).textTheme.subtitle1.apply()
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  isTax != false?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TAX included',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        taxTotal(),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ):Container(),
                                  isTax != false?
                                  SizedBox(height: 10):Container(),
                                  Card(
                                    margin: EdgeInsets.zero,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                flex:5,
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child:Text(
                                                    widget.getHistoryData[0].shipping_address['first_name'].toString()+ '\n'
                                                        + widget.getHistoryData[0].shipping_address['phone'].toString() + '\n'
                                                        + widget.getHistoryData[0].shipping_address['address'].toString() + '\n'
                                                        + widget.getHistoryData[0].shipping_address['city'].toString() + '\n',
                                                    maxLines: 5,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    child: Row(
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: FlatButton(
                                                onPressed: () async {
//                                                Navigator.pop(context,true);
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(3.0),
                                                  side: BorderSide(
                                                      color: kUserBackColor),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 15, bottom: 15),
                                                  child: Text(
                                                    widget.deliveryStatus == 'yes'?
                                                    "DELIVERED" : widget.deliveryStatus == 'no'? "IN TRANSIT" : "CANCELLED",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                color: kUserBackColor,
                                              ),
                                            )
                                        ),

                                        widget.deliveryStatus == 'yes'?
                                            SizedBox(width: 10) : Container(),
                                        widget.deliveryStatus == 'yes'?
                                        Flexible(
                                            flex: 1,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: FlatButton(
                                                onPressed: () async {

                                                  String sizeOption = '', sizePrice = '', colorOption = '', colorPrice = '',
                                                      otherOption = '', otherPrice = '';
                                                  var sizeObject;
                                                  var colorObject;
                                                  var otherObject;

                                                  if(widget.getHistoryData[0].size.length != 0){
                                                    sizeOption =widget.getHistoryData[0].size[0].option;
                                                    sizePrice =widget.getHistoryData[0].size[0].price;
                                                    var sizeObjects = '{"option" : "$sizeOption","price" : "$sizePrice"}';
                                                    sizeList.add(sizeObjects);

                                                    String sizeName = widget.getHistoryData[0].size_option_name;
                                                    var sizelist = sizeList.toString();
                                                    sizeObject = '{"option_name" : "$sizeName","option" : $sizelist}';
                                                  } else{
                                                    String sizeName = widget.getHistoryData[0].size_option_name;
                                                    var sizelist = sizeList.toString();
                                                    sizeObject = '{"option_name" : "$sizeName","option" : $sizelist}';
                                                  }

                                                  if(widget.getHistoryData[0].color.length != 0){
                                                    colorOption =widget.getHistoryData[0].color[0].option;
                                                    colorPrice =widget.getHistoryData[0].color[0].price;
                                                    var colorObjects = '{"option" : "$colorOption","price" : "$colorPrice"}';
                                                    colorList.add(colorObjects);

                                                    String colorName = widget.getHistoryData[0].color_option_name;
                                                    var colorlist = colorList.toString();
                                                    colorObject = '{"option_name" : "$colorName","option" : $colorlist}';
                                                  } else{
                                                    String colorName = widget.getHistoryData[0].color_option_name;
                                                    var colorlist = colorList.toString();
                                                    colorObject = '{"option_name" : "$colorName","option" : $colorlist}';
                                                  }

                                                  if(widget.getHistoryData[0].other.length != 0){
                                                    otherOption =widget.getHistoryData[0].other[0].option;
                                                    otherPrice =widget.getHistoryData[0].other[0].price;
                                                    var otherObjects = '{"option" : "$otherOption","price" : "$otherPrice"}';
                                                    otherList.add(otherObjects);

                                                    String otherName = widget.getHistoryData[0].other_option_name;
                                                    var otherlist = otherList.toString();
                                                    otherObject = '{"option_name" : "$otherName","option" : $otherlist}';
                                                  } else{
                                                    String otherName = widget.getHistoryData[0].other_option_name;
                                                    var otherlist = otherList.toString();
                                                    otherObject = '{"option_name" : "$otherName","option" : $otherlist}';
                                                  }

                                                  if(int.parse(widget.getHistoryData[0].stock) >= int.parse(widget.getHistoryData[0].qty)){
                                                    if(isCart){
                                                      addCart(widget.getHistoryData[0].inventory_id, widget.getHistoryData[0].qty,
                                                          colorObject, sizeObject, otherObject, 'false' );
                                                    }else{
                                                      addCart(widget.getHistoryData[0].inventory_id, widget.getHistoryData[0].qty,
                                                          colorObject, sizeObject, otherObject, 'true');
                                                    }
                                                  }else{
                                                    showSimpleDialog(context,
                                                        title: '',
                                                        message: 'Stock is not available more then ' + widget.getHistoryData[0].stock);
                                                  }

                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(3.0),
                                                  side: BorderSide(
                                                      color: kUserBackColor),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 15, bottom: 15),
                                                  child: Text(
                                                    "REPEAT",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                color: kUserBackColor,
                                              ),
                                            )
                                        ):Container()
                                      ],
                                    ),
                                  )
                                ],
                              )
                          )
                        ],
                      ),
                    )
                ),
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          )
      ),
    );
  }


  String subTotal() {
    total = 0;
    int colorPrice = 0;
    int sizePrice = 0;
    int otherPrice = 0;
    for(int i=0; i<widget.getHistoryData.length; i++){
      if(widget.getHistoryData[i].color.length != 0){
        if(widget.getHistoryData[i].color[0].price != ''){
          colorPrice = int.parse(widget.getHistoryData[i].color[0].price);
        }
      }
      if(widget.getHistoryData[i].size.length != 0){
        if(widget.getHistoryData[i].size[0].price != ''){
          sizePrice = int.parse(widget.getHistoryData[i].size[0].price);
        }
      }
      if(widget.getHistoryData[i].other.length != 0){
        if(widget.getHistoryData[i].other[0].price != ''){
          otherPrice = int.parse(widget.getHistoryData[i].other[0].price);
        }
      }
      int ttl = int.parse(widget.getHistoryData[i].item_price) + colorPrice + sizePrice + otherPrice;
      int qty = int.parse(widget.getHistoryData[i].qty);
      int ttlprice = ttl * qty;
      total = total + ttlprice;
    }
    return total.toString();
  }

  String mainTotal() {
    int total = 0;
    int dCharge = 0;
    double ttlRate = 0;
    int rate = 0;
    int colorPrice = 0;
    int sizePrice = 0;
    int otherPrice = 0;
    for(int i=0; i<widget.getHistoryData.length; i++){
      if(widget.getHistoryData[i].color.length != 0){
        if(widget.getHistoryData[i].color[0].price != ''){
          colorPrice = int.parse(widget.getHistoryData[i].color[0].price);
        }
      }
      if(widget.getHistoryData[i].size.length != 0){
        if(widget.getHistoryData[i].size[0].price != ''){
          sizePrice = int.parse(widget.getHistoryData[i].size[0].price);
        }
      }
      if(widget.getHistoryData[i].other.length != 0){
        if(widget.getHistoryData[i].other[0].price != ''){
          otherPrice = int.parse(widget.getHistoryData[i].other[0].price);
        }
      }
      int ttl = int.parse(widget.getHistoryData[i].item_price) + colorPrice + sizePrice + otherPrice;
      int qty = int.parse(widget.getHistoryData[i].qty);
      if(widget.getHistoryData[i].tax_rate != ''){
        isTax = true;
        rate = int.parse(widget.getHistoryData[i].tax_rate);
      }else{
        rate = 0;
      }

      int ttlprice = ttl * qty;
      total = total + ttlprice;

      double pertotal = (rate / 100) * ttlprice;
      ttlRate = ttlRate + pertotal;
      total = total + pertotal.toInt();
    }
    if(widget.getHistoryData[0].deliveryCharge != ''){
      dCharge = int.parse(widget.getHistoryData[0].deliveryCharge);
    }
    total = total + dCharge;
    return total.toString();
  }

  String taxTotal() {
    double ttlRate = 0;
    int rate = 0;
    int colorPrice = 0;
    int sizePrice = 0;
    int otherPrice = 0;
    for(int i=0; i<widget.getHistoryData.length; i++){
      if(widget.getHistoryData[i].color.length != 0){
        if(widget.getHistoryData[i].color[0].price != ''){
          colorPrice = int.parse(widget.getHistoryData[i].color[0].price);
        }
      }
      if(widget.getHistoryData[i].size.length != 0){
        if(widget.getHistoryData[i].size[0].price != ''){
          sizePrice = int.parse(widget.getHistoryData[i].size[0].price);
        }
      }
      if(widget.getHistoryData[i].other.length != 0){
        if(widget.getHistoryData[i].other[0].price != ''){
          otherPrice = int.parse(widget.getHistoryData[i].other[0].price);
        }
      }

      int ttl = int.parse(widget.getHistoryData[i].item_price) + colorPrice + sizePrice + otherPrice;
      int qty = int.parse(widget.getHistoryData[i].qty);
      int ttlprice = ttl * qty;
      if(widget.getHistoryData[i].tax_rate != ''){
        rate = int.parse(widget.getHistoryData[i].tax_rate);
      }else{
        rate = 0;
      }
      double total = (rate / 100) * ttlprice;
      ttlRate = ttlRate + total;
    }
    total = total + ttlRate.toInt();
    return ttlRate.toStringAsFixed(0);
  }
}
