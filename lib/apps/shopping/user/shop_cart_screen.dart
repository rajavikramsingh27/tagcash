import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/shopping/components/custom_drop_down.dart';
import 'package:tagcash/apps/shopping/models/image.dart';
import 'package:tagcash/apps/shopping/models/option.dart';
import 'package:tagcash/apps/shopping/models/product.dart';
import 'package:tagcash/apps/shopping/user/shop_detail_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

import '../shopping_list_screen.dart';

class ShopCartScreen extends StatefulWidget {
  List<Product> getProductData;
  int index;
  String shopId, shopName, shopImage, shopDesc, cc, isType, inventoryId,stripeId, stripeEmail;

  ShopCartScreen({Key key, this.getProductData, this.index, this.shopId, this.shopName, this.shopImage,
    this.shopDesc, this.isType, this.inventoryId, this.stripeId, this.stripeEmail}) : super(key: key);

  @override
  _ShopCartScreenState createState() => _ShopCartScreenState();
}

class _ShopCartScreenState extends State<ShopCartScreen> {
  TextEditingController quantityController = TextEditingController();

  bool isLoading = false, isFavorite = false;

  List<CustomDropdownMenuItem<Option>> _dropdownMenuItems;
  List<Option> colorData = [];

  List<CustomDropdownMenuItem<Option>> _dropdownMenuItems1;
  List<Option> sizeData = [];

  List<CustomDropdownMenuItem<Option>> _dropdownMenuItems2;
  List<Option> otherData = [];

  Option _selectedColor;
  Option _selectedSize;
  Option _selectedOther;

  String Stock = '';

  List<String> sizeList = [];
  List<String> colorList = [];
  List<String> otherList = [];

  var currentPageValue = 0;
  PageController controller;
  PageController controller1;

  List cartList;

  List<String> imagess = new List<String>();
  List<Option> other;
  List<Option> color;
  List<Option> size;
  List<image> getImageData = new List<image>();

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  @override
  void initState() {
    super.initState();
    if(widget.isType == '2'){
      getInventoryDetail(widget.inventoryId, widget.shopId);
    }else{
      getCartList();
      quantityController.text = '1';
      isFavorite = widget.getProductData[widget.index].favorite;
      Stock = widget.getProductData[widget.index].stock.toString();
      controller = PageController(initialPage: 0);
      controller1 = PageController(initialPage: widget.index);
    }

  }

  void getInventoryDetail(String inventoryId, String shopId) async {
    widget.getProductData = new List<Product>();
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = inventoryId;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/InventoryDetails', apiBodyObj);


    if (response['status'] == 'success') {
      if(response['list'] != null){
        Product product = new Product(0, '','', 0, 0, 0, '', '', false, 0, '', '', '');
        product.id =  response['list'][0]['id'];
        product.name = response['list'][0]['name'];
        product.description = response['list'][0]['description'];
        product.price = response['list'][0]['price'];
        product.shipment_days = response['list'][0]['shipment_days'];
        product.stock = response['list'][0]['stock'];
        product.currency_code = response['list'][0]['currency_code'];
        product.image_thumb = response['list'][0]['image'][0].toString();
        product.favorite = response['list'][0]['favorite'];
        product.favorite_id = response['list'][0]['favorite_id'];
        List imageList = response['list'][0]['image'];

        getImageData = imageList.map<image>((json) {
          return image.fromJson(json);
        }).toList();
        for (int i=0; i < getImageData.length; i++){
          String image = getImageData[i].images;
          imagess.add(image);
        }
        product.images = imagess;
        product.other_option_name = response['list'][0]['other']['option_name'].toString();
        if( response['list'][0]['other']['option'] != '' &&  response['list'][0]['other']['option'] != null){
          var tagObjsJson =  response['list'][0]['other']['option'] as List;
          other = tagObjsJson.map<Option>((json) {
            return Option.fromJson(json);
          }).toList();
        }
        product.other = other;
        product.color_option_name = response['list'][0]['color']['option_name'].toString();
        if( response['list'][0]['color']['option'] != '' &&  response['list'][0]['color']['option'] != null){
          var tagObjsJson =  response['list'][0]['color']['option'] as List;
          color = tagObjsJson.map<Option>((json) {
            return Option.fromJson(json);
          }).toList();
        }
        product.color = color;
        product.size_option_name = response['list'][0]['size']['option_name'].toString();
        if( response['list'][0]['size']['option'] != '' &&  response['list'][0]['size']['option'] != null){
          var tagObjsJson =  response['list'][0]['size']['option'] as List;
          size = tagObjsJson.map<Option>((json) {
            return Option.fromJson(json);
          }).toList();
        }
        product.size = size;
        widget.getProductData.add(product);
        widget.index = 0;

        getCartList();
        quantityController.text = '1';
        isFavorite = widget.getProductData[widget.index].favorite;
        Stock = widget.getProductData[widget.index].stock.toString();
        controller = PageController(initialPage: 0);
        controller1 = PageController(initialPage: widget.index);

      }
      setState(() {
        isLoading = false;
      });

    } else {

    }
  }


  int imageIndex = 0;
  bool isFavourite = false;

  bool isCart = true;

  void getCartList() async {
  setState(() {
      isLoading = true;
    });
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
      setState(() {
        isLoading = false;
      });

    } else {

    }
  }

  void addFavorite(String product_id, int index) async {

    Map<String, String> apiBodyObj = {};
    apiBodyObj['product_id'] = product_id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/AddFavorite', apiBodyObj);
    if (response['status'] == 'success') {

      setState(() {
        widget.getProductData[index].favorite = true;
        isFavorite = widget.getProductData[index].favorite;
        widget.getProductData[index].favorite_id = response['id'];
      });

    }
  }

  void removeFavorite(String favorite_id, int index) async {

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = favorite_id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/RemoveFavourite', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        widget.getProductData[index].favorite = false;
        isFavorite = widget.getProductData[index].favorite;
      });
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
                  if(widget.isType == '1'){
                    Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 3)),
                    );
                  }else if(widget.isType == '2'){
                    Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 2)),
                    );
                  }else{
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => ShopDetailScreen(shopId: widget.shopId)),
                    );
                  }
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

  void displayBottomSheet(String clearAll) {
    if(widget.getProductData[widget.index].color.length != 0){
      colorData = widget.getProductData[widget.index].color;
      List<CustomDropdownMenuItem<Option>> buildDropdownMenuItems(
          List companies) {
        List<CustomDropdownMenuItem<Option>> items = List();
        for (Option company in companies) {
          items.add(
            CustomDropdownMenuItem(
              value: company,
              child: Text(
                company.option + ' ' + company.price.toString(),
              ),
            ),
          );
        }
        return items;
      }
      _dropdownMenuItems = buildDropdownMenuItems(colorData);
    }else{
      colorData.clear();
    }

    if(widget.getProductData[widget.index].size.length != 0){
      sizeData = widget.getProductData[widget.index].size;
      List<CustomDropdownMenuItem<Option>> buildDropdownMenuItems(
          List companies) {
        List<CustomDropdownMenuItem<Option>> items = List();
        for (Option company in companies) {
          items.add(
            CustomDropdownMenuItem(
              value: company,
              child: Text(
                company.option + ' ' + company.price.toString(),
              ),
            ),
          );
        }
        return items;
      }
      _dropdownMenuItems1 = buildDropdownMenuItems(sizeData);
    }else{
      sizeData.clear();
    }
    if(widget.getProductData[widget.index].other.length != 0){
      otherData = widget.getProductData[widget.index].other;
      List<CustomDropdownMenuItem<Option>> buildDropdownMenuItems(
          List companies) {
        List<CustomDropdownMenuItem<Option>> items = List();
        for (Option company in companies) {
          items.add(
            CustomDropdownMenuItem(
              value: company,
              child: Text(
                company.option + ' ' + company.price.toString(),
              ),
            ),
          );
        }
        return items;
      }
      _dropdownMenuItems2 = buildDropdownMenuItems(otherData);
    }else{
      otherData.clear();
    }

    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child:DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.2,
                maxChildSize: 1,
                builder: (_, controller) {
                  return StatefulBuilder(
                      builder: (BuildContext context, setState) =>
                          Container(
                              decoration: new BoxDecoration(
                                color: Color(0xFFD4D4D4),
                              ),
                              child: Container(
                                  padding: EdgeInsets.all(20),
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child:Text(
                                            'Quantity',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: new BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                                borderRadius: BorderRadius.circular(5.0)),
                                            width: MediaQuery.of(context).size.width,
                                            child: Container(
                                              padding: EdgeInsets.only(top: 5, bottom:5, left: 10, right: 10),
                                              width: MediaQuery.of(context).size.width,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  TextFormField(
                                                    controller: quantityController,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly],
                                                    decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        isDense: true,
                                                        hintText: 'Enter Quantity',
                                                        hintStyle: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black)
                                                    ),
                                                    style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black),
                                                    onChanged: (text) {

                                                      if(text != ''){
                                                        if(widget.getProductData[widget.index].stock >= int.parse(text)){

                                                        } else{
                                                          quantityController.text = '';
                                                          FocusScope.of(context).unfocus();
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text(''),
                                                                content: Text('Stock is not available more then ' + widget.getProductData[widget.index].stock.toString()),
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
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )),
                                        colorData.length != 0?
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: new BoxDecoration(
                                                color: Colors.white,
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
                                                    dropdownColor: Colors.white,
                                                    iconEnabledColor: Colors.black,
                                                    isExpanded: true,
                                                    value: _selectedColor,
                                                    hint: Container(
                                                        child: Text('Color', style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black))),
                                                    style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black),
                                                    items: _dropdownMenuItems,
                                                    underline: Container(),
                                                    onChanged: (val) {
                                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                                      if (currentFocus.canRequestFocus) {
                                                        FocusScope.of(context)
                                                            .requestFocus(new FocusNode());
                                                      }
                                                      setState(() {
                                                        _selectedColor = val;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )) : Container(),

                                        sizeData.length != 0?
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: new BoxDecoration(
                                                color: Colors.white,
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
                                                    dropdownColor: Colors.white,
                                                    iconEnabledColor: Colors.black,
                                                    isExpanded: true,
                                                    value: _selectedSize,
                                                    hint: Container(
                                                        child: Text('Size', style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black))),
                                                    items: _dropdownMenuItems1,
                                                    style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black),
                                                    underline: Container(),
                                                    onChanged: (val) {
                                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                                      if (currentFocus.canRequestFocus) {
                                                        FocusScope.of(context)
                                                            .requestFocus(new FocusNode());
                                                      }
                                                      setState(() {
                                                        _selectedSize = val;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )) : Container(),

                                        otherData.length != 0?
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            decoration: new BoxDecoration(
                                                color: Colors.white,
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
                                                    dropdownColor: Colors.white,
                                                    iconEnabledColor: Colors.black,
                                                    isExpanded: true,
                                                    value: _selectedOther,
                                                    hint: Container(
                                                        child: Text('Other', style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black))),
                                                    items: _dropdownMenuItems2,
                                                    underline: Container(),
                                                    style: Theme.of(context).textTheme.subtitle1.apply(color: Colors.black),
                                                    onChanged: (val) {
                                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                                      if (currentFocus.canRequestFocus) {
                                                        FocusScope.of(context)
                                                            .requestFocus(new FocusNode());
                                                      }
                                                      setState(() {
                                                        _selectedOther = val;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )):Container(),


                                        Container(
                                          padding: EdgeInsets.all(5),
                                          child:Text(
                                            'In Stock - ' + Stock,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          child: Row(
                                            children: [
                                              Flexible(
                                                  flex: 1,
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: FlatButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context,true);
                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(3.0),
                                                        side: BorderSide(
                                                            color: Color(0xFF8C8C8C)),
                                                      ),
                                                      child: Container(
                                                        padding: EdgeInsets.only(top: 10, bottom: 10),
                                                        child: Text(
                                                          "CANCEL",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                      color: Color(0xFF8C8C8C),
                                                    ),
                                                  )
                                              ),
                                              SizedBox(width: 5),
                                              Flexible(
                                                  flex: 2,
                                                  child:Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: FlatButton(
                                                      onPressed: () async {
                                                        var sizeObject;
                                                        var colorObject;
                                                        var otherObject;
                                                        String color = '', colorPrice = '', size = '', sizePrice = '', other = '', price = '';
                                                        if(colorData.length != 0){
                                                          if(_selectedColor != null){
                                                            sizeData = widget.getProductData[widget.index].size;
                                                            color = _selectedColor.option;
                                                            colorPrice = _selectedColor.price.toString();
                                                            var colorObjects = '{"option" : "$color","price" : "$colorPrice"}';
                                                            colorList.add(colorObjects);

                                                            String colorName = widget.getProductData[widget.index].color_option_name;
                                                            var colorlist = colorList.toString();
                                                            colorObject = '{"option_name" : "$colorName","option" : $colorlist}';
                                                            print(colorObject);
                                                          }else{
                                                            String colorName = widget.getProductData[widget.index].color_option_name;
                                                            var colorlist = colorList.toString();
                                                            colorObject = '{"option_name" : "$colorName","option" : $colorlist}';
                                                            print(colorObject);
                                                          }
                                                        } else{
                                                          String colorName = widget.getProductData[widget.index].color_option_name;
                                                          var colorlist = colorList.toString();
                                                          colorObject = '{"option_name" : "$colorName","option" : $colorlist}';
                                                        }
                                                        if(sizeData.length != 0){
                                                          if(_selectedSize != null){
                                                            size = _selectedSize.option;
                                                            sizePrice = _selectedSize.price.toString();
                                                            var sizeObjects = '{"option" : "$size","price" : "$sizePrice"}';
                                                            sizeList.add(sizeObjects);

                                                            String sizeName = widget.getProductData[widget.index].size_option_name;
                                                            var sizelist = sizeList.toString();
                                                            sizeObject = '{"option_name" : "$sizeName","option" : $sizelist}';
                                                            print(sizeObject);
                                                          }else{
                                                            String sizeName = widget.getProductData[widget.index].size_option_name;
                                                            var sizelist = sizeList.toString();
                                                            sizeObject = '{"option_name" : "$sizeName","option" : $sizelist}';
                                                            print(sizeObject);
                                                          }
                                                        }else{
                                                          String sizeName = widget.getProductData[widget.index].size_option_name;
                                                          var sizelist = sizeList.toString();
                                                          sizeObject = '{"option_name" : "$sizeName","option" : $sizelist}';
                                                          print(sizeObject);
                                                        }
                                                        if(otherData.length != 0){
                                                          if(_selectedOther != null){
                                                            other = _selectedOther.option;
                                                            price = _selectedOther.price.toString();
                                                            var otherObjects = '{"option" : "$other","price" : "$price"}';
                                                            otherList.add(otherObjects);

                                                            String otherName = widget.getProductData[widget.index].other_option_name;
                                                            var otherlist = otherList.toString();
                                                            otherObject = '{"option_name" : "$otherName","option" : $otherlist}';
                                                            print(otherObject);
                                                          }else{
                                                            String otherName = widget.getProductData[widget.index].other_option_name;
                                                            var otherlist = otherList.toString();
                                                            otherObject = '{"option_name" : "$otherName","option" : $otherlist}';
                                                            print(otherObject);
                                                          }
                                                        }else{
                                                          String otherName = widget.getProductData[widget.index].other_option_name;
                                                          var otherlist = otherList.toString();
                                                          otherObject = '{"option_name" : "$otherName","option" : $otherlist}';
                                                          print(otherObject);
                                                        }

                                                        if(quantityController.text == ''){
                                                          showSimpleDialog(context,
                                                              title: 'Attention',
                                                              message: 'Quantity required.');
                                                        } else{
                                                          if(widget.getProductData[widget.index].stock >= int.parse(quantityController.text)){
                                                            Navigator.pop(context,true);
                                                            addCart(widget.getProductData[widget.index].id.toString(), quantityController.text,
                                                                colorObject, sizeObject, otherObject, clearAll );
                                                          }else{
                                                            showSimpleDialog(context,
                                                                title: '',
                                                                message: 'Stock is not available more then ' + widget.getProductData[widget.index].stock.toString());
                                                          }

                                                        }

                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(3.0),
                                                        side: BorderSide(
                                                            color: Theme.of(context).primaryColor),
                                                      ),
                                                      child: Container(
                                                        padding: EdgeInsets.only(top: 10, bottom: 10),
                                                        child: Text(
                                                          "ADD TO CART",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  )
                                              )
                                            ],
                                          ),
                                        )

                                      ],
                                    ),
                                  )
                              )
                          )
                  );
                }
            ),
          );
        });
  }
  void cartBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return BottomSheet(
              backgroundColor: Colors.transparent,
              onClosing: (){},
              builder: (BuildContext context){
                return StatefulBuilder(
                    builder: (BuildContext context, setState) =>
                        Container(
                            decoration: new BoxDecoration(
                              color: Color(0xFFD4D4D4),
                            ),
                            height: 250,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child:Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(50),
                                    child:Text(
                                      'You will lose all the items you have in your cart - Do you want to do this?',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    child: Row(
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: FlatButton(
                                                onPressed: () async {
                                                  Navigator.pop(context,true);
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(3.0),
                                                  side: BorderSide(
                                                      color: Color(0xFF8C8C8C)),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Text(
                                                    "STAY",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                                color: Color(0xFF8C8C8C),
                                              ),
                                            )
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                            flex: 2,
                                            child:Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: FlatButton(
                                                onPressed: () async {
                                                  Navigator.pop(context,true);
                                                  displayBottomSheet('true');
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(3.0),
                                                  side: BorderSide(
                                                      color: Theme.of(context).primaryColor),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  child: Text(
                                                    "CLEAR AND ADD NEW ITEM",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  )

                                ],
                              ),
                            )
                        )
                );
              }
          );

        });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: (){
        if(widget.isType == '1'){
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 3)),
          );
        }else if(widget.isType == '2'){
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => ShoppingListScreen(moduleCode:"TAG Shopping", selectedPage: 2)),
          );
        }else{
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ShopDetailScreen(shopId: widget.shopId)),
          );
        }

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
              widget.getProductData.length != 0 ?
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 250.0,
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 250, // card height
                                child: PageView.builder(
                                  controller: controller,
                                  itemCount: widget.getProductData[widget.index].images.length,
                                  onPageChanged: (int index) => setState(() => imageIndex = index),
                                  itemBuilder: (_, i) {
                                    return GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).push(PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (BuildContext context, _, __) =>
                                                RedeemConfirmationScreen(url: widget.getProductData[widget.index].images[imageIndex])));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                                image: widget.getProductData[widget.index].images[i] != ''?
                                                NetworkImage(
                                                    widget.getProductData[widget.index].images[i])
                                                    : NetworkImage(
                                                    "https://dummyimage.com/100x100/cccccc/000000.jpg&text=Image"),
                                                fit: BoxFit.fill)
                                        ),
                                        width: MediaQuery.of(context).size.width,
                                        height: 250.0,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.only(bottom:10),
                                height: 250.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    new Positioned(
                                      child: new Container(
                                        height: 40,
                                        width: MediaQuery.of(context).size.width,
                                        color: Colors.grey[800].withOpacity(0.2),
                                        padding: const EdgeInsets.all(15.0),
                                        child: new Center(
                                          child: new DotsIndicator(
                                            controller: controller,
                                            itemCount: widget.getProductData[widget.index].images.length,
                                            onPageSelected: (int page) {
                                              controller.animateToPage(
                                                page,
                                                duration: _kDuration,
                                                curve: _kCurve,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )/* Container(
                                height: MediaQuery.of(context).size.height,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    imageIndex > 0?
                                    IconButton(
                                        icon: FaIcon(FontAwesomeIcons.angleLeft, size: 30, color: Colors.grey),
                                        onPressed: (){
                                          setState(() {
                                            imageIndex --;
                                            controller.animateToPage(imageIndex, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
                                          });
                                        }
                                    ) : Container(),

                                    widget.getProductData[widget.index].images.length - 1  > imageIndex?
                                    IconButton(
                                        icon: FaIcon(FontAwesomeIcons.angleRight, size: 30, color: Colors.grey),
                                        onPressed: (){
                                          setState(() {
                                            imageIndex ++;
                                            controller.animateToPage(imageIndex, curve: Curves.decelerate, duration: Duration(milliseconds: 300)); // for animated jump. Requires a curve and a duration
                                          });
                                        }
                                    ) : Container()
                                  ],
                                ),
                              )*/

                            ],
                          ),
                        ),
                      ),
                    ),

                    Flexible(
                      flex: 3,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: controller1,
                                itemCount: widget.getProductData.length,
//                            onPageChanged: (int index) => setState(() => widget.index = index),
                                onPageChanged: (int index){
                                  print(index);
                                  setState(() {
                                    widget.index = index;
                                  });
                                },
                                itemBuilder: (_, i) {
                                  i = widget.index;
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  widget.getProductData[i].name,
                                                  style: Theme.of(context).textTheme.subtitle1.apply()
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                  widget.getProductData[i].description,
                                                  style: Theme.of(context).textTheme.bodyText2.apply()
                                              ),
                                            ],
                                          )
                                      ),

                                      Container(
                                        color:Theme.of(context).primaryColor,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Stack(
                                              children: [


                                                Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: FlatButton(
                                                    onPressed: () async {
                                                      if(isCart){
                                                        displayBottomSheet('false');
                                                      } else{
                                                        cartBottomSheet();
                                                      }
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(3.0),
                                                      side: BorderSide(
                                                          color: Theme.of(context).primaryColor),
                                                    ),
                                                    child: Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10),
                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                      child: Text(
                                                        widget.getProductData[i].currency_code + widget.getProductData[i].price.toString() + " - ADD TO CART",
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      widget.getProductData[i].favorite == false?
                                                      IconButton(
                                                          icon: FaIcon(FontAwesomeIcons.heart, size: 25, color: Colors.grey),
                                                          onPressed: (){
                                                            setState(() {
                                                              addFavorite(widget.getProductData[i].id.toString(), i);
                                                            });
                                                          }
                                                      ) : IconButton(
                                                          icon: FaIcon(FontAwesomeIcons.solidHeart, size: 25, color: Colors.black),
                                                          onPressed: (){
                                                            setState(() {
                                                              removeFavorite(widget.getProductData[i].favorite_id.toString(), i);
                                                            });
                                                          }
                                                      ),
                                                      Container(
                                                          color: Colors.white, height: 40, width: 0.3),
                                                    ],
                                                  )
                                                ),
                                              ],
                                            )

,
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          )
                      ),
                    )
                  ],
                ),
              ) : Container(),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          )
      ),
    );
  }
}

class RedeemConfirmationScreen extends StatelessWidget {
  String url;

  RedeemConfirmationScreen({Key key, this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.80), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/1,
                    height: MediaQuery.of(context).size.height/1,
                    child: PhotoView(
                      backgroundDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      imageProvider:  NetworkImage(
                          url),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 100, right: 10),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                       IconButton(
                         icon: const Icon(Icons.clear, size: 25,color: Colors.white),
                        onPressed:(){
                          Navigator.pop(context, true);
                        },
                       )
                      ],
                    )
                  ),
                ],
              )
            ],
          )
      ),
    );
  }
}
class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 2.0;

  // The distance between the center of each dot
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}