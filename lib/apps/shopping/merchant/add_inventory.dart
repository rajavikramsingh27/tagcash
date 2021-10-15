import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/shopping/components/custom_drop_down.dart';
import 'package:tagcash/apps/shopping/models/Inventory.dart';
import 'package:tagcash/apps/shopping/models/shop_merchant.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import '../../../constants.dart';

class AddInventory extends StatefulWidget {
  final ShopMerchant shop;

  const AddInventory({Key key, this.shop}) : super(key: key);

  _AddInventoryState createState() => _AddInventoryState();
}

class _AddInventoryState extends State<AddInventory> {
  File imageFile;
  TextEditingController productName = TextEditingController();
  TextEditingController productDescription = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController productStock = TextEditingController();
  TextEditingController productTime = TextEditingController();
  TextEditingController productTax = TextEditingController();

  List<CustomDropdownMenuItem<Inventory>> _dropdownMenuItems;
  Inventory _selectedCategory;
  List<Inventory> categoryData = [];

  bool defOption = false, size = false, color = false, other = false;
  String isSize = '0', isColor = '0', isOther = '0';

  List<String> _categoryList = [''];
  List<TextEditingController> _categoryControllers = new List();

  List<String> _sizeOptionList = [''];
  TextEditingController _sizeTitleControllers = TextEditingController();
  List<TextEditingController> _sizeOptionControllers = new List();
  List<TextEditingController> _sizePriceControllers = new List();

  List<String> _colorOptionList = [''];
  TextEditingController _colorTitleControllers = TextEditingController();
  List<TextEditingController> _colorOptionControllers = new List();
  List<TextEditingController> _colorPriceControllers = new List();

  List<String> _otherOptionList = [''];
  TextEditingController _otherTitleControllers = TextEditingController();
  List<TextEditingController> _otherOptionControllers = new List();
  List<TextEditingController> _otherPriceControllers = new List();

  List<String> _logoList = [''];
  List<String> _logoUrlList = [''];

  List<String> sizeList = [];
  List<String> colorList = [];
  List<String> otherList = [];

  List<Inventory> getInventoryCategory = new List<Inventory>();
  List<Inventory> getReversedInventoryCategory = new List<Inventory>();

  bool isLoading = false, isImage = false;

  int logoindex;

  String image_File = '';

  @override
  void initState() {
    super.initState();
    _sizeTitleControllers.text = 'SIZE';
    _colorTitleControllers.text = 'COLOR';
    _otherTitleControllers.text = 'OTHER';
    productTax.text = widget.shop.shop_tax_rate;
    getCategory('');
  }

  getLogo(String url){
    if(url!=null && url!=''){
      return url != null
          ? FileImage(File(url))
          :NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    }else{
      return NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    }
  }

  defaultOption(){
     setState(() {
        if(widget.shop.other_option_name != ''){
          _otherTitleControllers.text = widget.shop.other_option_name;
        }else{
          _otherTitleControllers.text ='SIZE';
        }
       if(widget.shop.other.isNotEmpty){
         _otherOptionList.clear();
         _otherOptionControllers.clear();
         _otherPriceControllers.clear();
         other = true;
         isOther = '1';
         for(int i = 0; i < widget.shop.other.length; i++){
           setState(() {
             _otherOptionList.add('');
             TextEditingController _otherOptionController = TextEditingController();
             TextEditingController _priceOptionController = TextEditingController();
             _otherOptionController.text = widget.shop.other[i].option.toString();
             _priceOptionController.text = widget.shop.other[i].price.toString();
             _otherOptionControllers.add(_otherOptionController);
             _otherPriceControllers.add(_priceOptionController);
           });
         }
       }

        if(widget.shop.color_option_name != ''){
          _colorTitleControllers.text = widget.shop.color_option_name;
        }else{
          _colorTitleControllers.text = 'COLOR';
        }

       if(widget.shop.color.isNotEmpty){
         _colorOptionList.clear();
         _colorOptionControllers.clear();
         _colorPriceControllers.clear();
         color = true;
         isColor = '1';
         for(int i = 0; i < widget.shop.color.length; i++){
           setState(() {
             _colorOptionList.add('');
             TextEditingController _colorOptionController = TextEditingController();
             TextEditingController _priceOptionController = TextEditingController();
             _colorOptionController.text = widget.shop.color[i].option.toString();
             _priceOptionController.text = widget.shop.color[i].price.toString();
             _colorOptionControllers.add(_colorOptionController);
             _colorPriceControllers.add(_priceOptionController);
           });
         }
       }

        if(widget.shop.size_option_name != ''){
          _sizeTitleControllers.text = widget.shop.size_option_name;
        }else{
          _sizeTitleControllers.text = 'SIZE';
        }
       _sizeTitleControllers.text = widget.shop.size_option_name;
       if(widget.shop.size.isNotEmpty){
         _sizeOptionList.clear();
         _sizeOptionControllers.clear();
         _sizePriceControllers.clear();
         size = true;
         isSize = '1';
         for(int i = 0; i < widget.shop.size.length; i++){
           setState(() {
             _sizeOptionList.add('');
             TextEditingController _sizeOptionController = TextEditingController();
             TextEditingController _priceOptionController = TextEditingController();
             _sizeOptionController.text = widget.shop.size[i].option.toString();
             _priceOptionController.text = widget.shop.size[i].price.toString();
             _sizeOptionControllers.add(_sizeOptionController);
             _sizePriceControllers.add(_priceOptionController);
           });
         }
       }
     });
  }

  void getCategory(String type) async {
    categoryData.clear();
    getInventoryCategory.clear();

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shop.id.toString();

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/ListCategory', apiBodyObj);
    if (response['status'] == 'success') {
      _categoryControllers.clear();
      List responseList = response['list'];

      if(responseList.isNotEmpty){
        getReversedInventoryCategory = responseList.map<Inventory>((json) {
          return Inventory.fromJson(json);
        }).toList();
        print(getInventoryCategory.length);
        getInventoryCategory = getReversedInventoryCategory.reversed.toList();

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

        _categoryList.clear();
        _categoryControllers.clear();

        for(int i = 0; i < getInventoryCategory.length; i++){
          TextEditingController _inventoryCategoryController = TextEditingController();
          _inventoryCategoryController.text = getInventoryCategory[i].name;
          _categoryList.add(getInventoryCategory[i].name);
          _categoryControllers.add(_inventoryCategoryController);
        }
        setState(() {
          isLoading = false;
        });
      } else{
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

  void addCategory(name) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = name;
    apiBodyObj['shop_id'] = widget.shop.id.toString();

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/AddCategory', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getCategory('');
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCategory(name, id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = name;
    apiBodyObj['id'] = id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/EditCategory', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getCategory('');
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteCategory(id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/DeleteCategory', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getCategory('');
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void createInventory(name, description, price, item_category, stock, shipment_days, tax_rate,
      sizeObject, colorObject, otherObject) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shop.id.toString();
    apiBodyObj['name'] = name;
    apiBodyObj['description'] = description;
    apiBodyObj['price'] = price;
    apiBodyObj['item_category'] = item_category;
    apiBodyObj['shipment_days'] = shipment_days;
    apiBodyObj['stock'] = stock;
    apiBodyObj['tax_rate'] = tax_rate ;
    apiBodyObj['size'] = sizeObject;
    apiBodyObj['color'] = colorObject;
    apiBodyObj['other'] = otherObject;

    Map<String, dynamic> response = await NetworkHelper.request('shop/CreateInventory', apiBodyObj);

    if (response['status'] == 'success') {
      int id = response['id'];

      if(_logoList.length != 0){
        for(int i = 0; i < _logoList.length; i++){
          uploadImage(id.toString(),_logoList[i]);
        }
      }
      setState(() {
        Timer(Duration(seconds: 5), () {
          isLoading = false;
          Navigator.pop(context, true);
        });
      });

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadImage(id, image) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id;
    apiBodyObj['image'] = image;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/UploadInventoryImage', apiBodyObj);

    if (response['status'] == 'success') {
      print('upload_image' + response['status']);

    } else {

    }
  }

  void displayBottomSheet() {
    bool isBottomLoading = false;
    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return StatefulBuilder(
                builder: (BuildContext context, setState) =>
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        decoration: new BoxDecoration(
                          color: Colors.white,
                        ),
                        height: 500,
                        child: Stack(
                          children: [
                            Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: MediaQuery.of(context).viewInsets,
                                      child:Column(
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: Container(
                                                  color: kUserBackColor,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(left: 15),
                                                        child: Text(
                                                          'INVENTORY CATEGORIES',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.start,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.clear, color: Colors.white),
                                                        onPressed:(){
                                                          Navigator.pop(context,true);
                                                        },
                                                      )
                                                    ],
                                                  )
                                              )
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: _categoryList.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                final textFieldFocusNode = FocusNode();
                                                _categoryControllers.add(new TextEditingController());
                                                return Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 30, right: 30, top: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 7,
                                                          child: Container(
                                                            margin: EdgeInsets.only(bottom: 10),
                                                            width: MediaQuery.of(context).size.width,
                                                            child: TextFormField(
                                                              focusNode: textFieldFocusNode,
                                                              controller: _categoryControllers[index],
                                                              keyboardType: TextInputType.text,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .singleLineFormatter
                                                              ],
                                                              decoration: InputDecoration(
                                                                enabledBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                                ),
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                                ),
                                                                fillColor: Colors.black12,
                                                                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                                                isDense: true,
                                                                labelText: "", //getTranslated(context, 'amount'),
                                                              ),
                                                              style: TextStyle(
                                                                  color: Colors.black
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Flexible(
                                                            flex: 2,
                                                            child: Container(
                                                                width: MediaQuery.of(context).size.width,
                                                                child: Row(
                                                                  /* spacing: 5,
                                                              direction: Axis.horizontal,*/
                                                                  children: [
                                                                    Container(
                                                                        padding: const EdgeInsets.all(0.0),
                                                                        width: 20.0, // you can adjust the width as you need
                                                                        child:IconButton(
                                                                          icon: Icon(Icons.done, size: 25,color: Colors.grey),
                                                                          onPressed:()async{
                                                                            int i = index + 1;
                                                                            if(getInventoryCategory.length < i){
                                                                              textFieldFocusNode.unfocus();
                                                                              textFieldFocusNode.canRequestFocus = false;
                                                                              setState(() {
                                                                                isBottomLoading = true;
                                                                              });

                                                                              Map<String, String> apiBodyObj = {};
                                                                              apiBodyObj['name'] = _categoryControllers[index].text;
                                                                              apiBodyObj['shop_id'] = widget.shop.id.toString();

                                                                              Map<String, dynamic> response =
                                                                              await NetworkHelper.request('shop/AddCategory', apiBodyObj);

                                                                              if (response['status'] == 'success') {
                                                                                setState(() {
                                                                                  isBottomLoading = false;
                                                                                });
                                                                                getCategory('');
                                                                              } else {
                                                                                setState(() {
                                                                                  isBottomLoading = false;
                                                                                });
                                                                              }

                                                                            } else{
                                                                              textFieldFocusNode.unfocus();
                                                                              textFieldFocusNode.canRequestFocus = false;
//                                                                              Navigator.pop(context,true);
//                                                                              editCategory(_categoryControllers[index].text, getInventoryCategory[index].id.toString());
                                                                              setState(() {
                                                                                isBottomLoading = true;
                                                                              });

                                                                              Map<String, String> apiBodyObj = {};
                                                                              apiBodyObj['name'] = _categoryControllers[index].text;
                                                                              apiBodyObj['id'] = getInventoryCategory[index].id.toString();

                                                                              Map<String, dynamic> response =
                                                                              await NetworkHelper.request('shop/EditCategory', apiBodyObj);

                                                                              if (response['status'] == 'success') {
                                                                                setState(() {
                                                                                  isBottomLoading = false;
                                                                                });
                                                                                getCategory('');
                                                                              } else {
                                                                                setState(() {
                                                                                  isBottomLoading = false;
                                                                                });
                                                                              }
                                                                            }

                                                                          },
                                                                        )
                                                                    ),
                                                                    SizedBox(width: 10),
                                                                    Container(
                                                                      padding: const EdgeInsets.all(0.0),
                                                                      width: 20.0, // you can adjust the width as you need
                                                                      child:  IconButton(
                                                                        icon: Icon(Icons.delete, size: 25,color: Colors.grey),
                                                                        onPressed:(){

                                                                          Widget cancelButton = FlatButton(
                                                                            child: Text("No"),
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          );
                                                                          Widget continueButton = FlatButton(
                                                                            child: Text("Yes"),
                                                                            onPressed: ()async {
                                                                              textFieldFocusNode.unfocus();
                                                                              textFieldFocusNode.canRequestFocus = false;
                                                                              Navigator.of(context).pop();
//                                                                              Navigator.pop(context,true);
//                                                                              deleteCategory(getInventoryCategory[index].id.toString());
                                                                              setState(() {
                                                                                isBottomLoading = true;
                                                                              });

                                                                              Map<String, String> apiBodyObj = {};
                                                                              apiBodyObj['id'] = getInventoryCategory[index].id.toString();

                                                                              Map<String, dynamic> response =
                                                                              await NetworkHelper.request('shop/DeleteCategory', apiBodyObj);

                                                                              if (response['status'] == 'success') {
                                                                                setState(() {
                                                                                  isBottomLoading = false;
                                                                                });
                                                                                _categoryList.removeAt(index);
                                                                                _categoryControllers.removeAt(index);
                                                                                getCategory('');
                                                                              } else {
                                                                                setState(() {
                                                                                  isBottomLoading = false;
                                                                                });
                                                                              }
                                                                            },
                                                                          );

                                                                          AlertDialog alert = AlertDialog(
                                                                            title: Text(""),
                                                                            content: Text('Are you sure you want to delete this category?'),
                                                                            actions: [
                                                                              continueButton,
                                                                              cancelButton,

                                                                            ],
                                                                          );

                                                                          showDialog(
                                                                            context: context,
                                                                            builder: (BuildContext context) {
                                                                              return alert;
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                            )
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),

                                          _categoryList.length < 5?
                                          Container(
                                            margin: EdgeInsets.only(right: 20),
                                            child:Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.add, size: 30,color: Colors.grey),
                                                  onPressed:(){

                                                    if (_categoryList.length < 5) {
                                                      setState(() {
                                                        _categoryList.add('');
                                                      });
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ): Container()
                                        ],
                                      ),
                                    )
                                  )
                                ),
                            isBottomLoading ? Center(child: Loading()) : SizedBox(),
                          ],
                        )
                    )
            );
        });
  }

  Widget showdiag(BuildContext context, data, String dialogType) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: dialogType == '0'?
        dialogContent(context, data)
            : data,
      ),
    );
  }

  Widget dialogContent(BuildContext context, data) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: data,
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  selectedImageContent(call) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text(
              "Select Image",//getTranslated(context, 'select_image'),
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Center(
            child: SizedBox(
              width: 40,
              height: 2.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: (){
                call("camera");
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Take a pic",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:10.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: (){
                call();
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Select Picture",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height:20.0),
        ],
      ),
    );
  }
  Future<void> _getLogoFromGallary([type]) async {
    var selectedLogo;
    if(type=="camera"){
      selectedLogo = await ImagePicker().getImage(
          source: ImageSource.camera,
      );
    }else{
      selectedLogo = await ImagePicker().getImage(
          source: ImageSource.gallery,
      );
    }

    if (selectedLogo != null) {
      setState(() {
        _cropImage(selectedLogo.path, selectedLogo);
      });
    }

  }

  img2base64(image){
    File imageFile = new File(image.path);
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  Future<Null> _cropImage(String path, var selectedImage) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
     /*   aspectRatioPresets: Platform.isAndroid
            ? [
         *//* CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,*//*
          CropAspectRatioPreset.ratio16x9
        ]
            : [
        *//*  CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9*//*
          CropAspectRatioPreset.ratio16x9
        ],*/
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: kPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

      print(decodedImage.width);
      print(decodedImage.height);

      List<int> imageBytes = imageFile.readAsBytesSync();

      String imageB64 = base64Encode(imageBytes);

      setState(() {
        isImage = true;
        _logoList.removeAt(logoindex);
        _logoList.insert(logoindex, img2base64(imageFile));
        _logoUrlList.removeAt(logoindex);
        _logoUrlList.insert(logoindex, imageFile.path);
      });
      print(File(imageFile.path).readAsBytes());
    }
  }

  sizeOptions(){
    return StatefulBuilder(builder: (context,setState){
      return Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 0.0,
                      offset: Offset(0.0, 0.0),
                    ),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _sizeTitleControllers,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.singleLineFormatter],
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor),
                            ),
                            contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                            isDense: true,
                            hintText: 'Size (change title)',
                            labelStyle: TextStyle(color: kPrimaryColor),
                          ),
                          style: TextStyle(
                              color: Colors.black
                          ),
                        ),
                      ],
                    )
                  ),

                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _sizeOptionList.length,
                      itemBuilder: (BuildContext context, int index) {
                        int count = index + 1;
                        final textFieldFocusNode = FocusNode();
                        final textFieldFocusNode1 = FocusNode();
                        _sizeOptionControllers.add(new TextEditingController());
                        _sizePriceControllers.add(new TextEditingController());
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      focusNode: textFieldFocusNode,
                                      controller: _sizeOptionControllers[index],
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .singleLineFormatter
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                        isDense: true,
                                        labelText: "Option " + count.toString(),
                                        labelStyle: TextStyle(color: kPrimaryColor),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      focusNode: textFieldFocusNode1,
                                      controller: _sizePriceControllers[index],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly],
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                        isDense: true,
                                        labelText: "+price " + count.toString(),
                                        labelStyle: TextStyle(color: kPrimaryColor),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Wrap(
                                          spacing: 5,
                                          direction: Axis.horizontal,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(0.0),
                                              width: 30.0, // you can adjust the width as you need
                                              child:  IconButton(
                                                icon: Icon(Icons.delete, size: 25,color: Colors.grey),
                                                onPressed:(){
                                                  textFieldFocusNode.unfocus();
                                                  textFieldFocusNode.canRequestFocus = false;
                                                  setState(() {
                                                    _sizeOptionList.removeAt(index);
                                                    _sizeOptionControllers.removeAt(index);
                                                    _sizePriceControllers.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                    )
                                )
                              ],
                            ),
                          ),
                        );
                      }),

                  _sizeOptionList.length < 5?
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, size: 30,color: Colors.grey),
                          onPressed:(){
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (currentFocus.canRequestFocus) {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            }
                            if (_sizeOptionList.length < 5) {
                              setState(() {
                                _sizeOptionList.add('');
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ): Container(),

                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                /*  _sizeOptionList.clear();
                                  _sizeOptionList = [''];
                                  _sizeTitleControllers.text = 'SIZE';*/
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
                                padding: EdgeInsets.all(0),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    "SAVE",
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
            ),
          ],
        ),
      );
    });
  }
  colorOptions(){
    return StatefulBuilder(builder: (context,setState){
      return Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 0.0,
                      offset: Offset(0.0, 0.0),
                    ),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[

                  Container(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _colorTitleControllers,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter],
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                              contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                              isDense: true,
                              hintText: 'Color (change title)',
                              labelStyle: TextStyle(color: kPrimaryColor),
                            ),
                            style: TextStyle(
                                color: Colors.black
                            ),
                          ),
                        ],
                      )
                  ),

                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _colorOptionList.length,
                      itemBuilder: (BuildContext context, int index) {
                        int count = index + 1;
                        final textFieldFocusNode = FocusNode();
                        final textFieldFocusNode1 = FocusNode();
                        _colorOptionControllers.add(new TextEditingController());
                        _colorPriceControllers.add(new TextEditingController());
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      focusNode: textFieldFocusNode,
                                      controller: _colorOptionControllers[index],
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .singleLineFormatter
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                        isDense: true,
                                        labelText: "Option " + count.toString(),
                                        labelStyle: TextStyle(color: kPrimaryColor),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      focusNode: textFieldFocusNode1,
                                      controller: _colorPriceControllers[index],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly],
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                        isDense: true,
                                        labelText: "+price " + count.toString(),
                                        labelStyle: TextStyle(color: kPrimaryColor),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Wrap(
                                          spacing: 5,
                                          direction: Axis.horizontal,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(0.0),
                                              width: 30.0, // you can adjust the width as you need
                                              child:  IconButton(
                                                icon: Icon(Icons.delete, size: 25,color: Colors.grey),
                                                onPressed:(){
                                                  textFieldFocusNode.unfocus();
                                                  textFieldFocusNode.canRequestFocus = false;
                                                  setState(() {
                                                    _colorOptionList.removeAt(index);
                                                    _colorOptionControllers.removeAt(index);
                                                    _colorPriceControllers.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                    )
                                )
                              ],
                            ),
                          ),
                        );
                      }),

                  _colorOptionList.length < 5?
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, size: 30,color: Colors.grey),
                          onPressed:(){
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (currentFocus.canRequestFocus) {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            }
                            if (_colorOptionList.length < 5) {
                              setState(() {
                                _colorOptionList.add('');
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ): Container(),
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                /*  _colorOptionList.clear();
                                  _colorOptionList = [''];
                                  _colorTitleControllers.text = 'COLOR';*/
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
                                padding: EdgeInsets.all(0),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    "SAVE",
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
            ),
          ],
        ),
      );
    });
  }
  otherOptions(){
    return StatefulBuilder(builder: (context,setState){
      return Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 0.0,
                      offset: Offset(0.0, 0.0),
                    ),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _otherTitleControllers,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter],
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: kPrimaryColor),
                              ),
                              contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                              isDense: true,
                              hintText: 'Other (change title)',
                              labelStyle: TextStyle(color: kPrimaryColor),
                            ),
                            style: TextStyle(
                                color: Colors.black
                            ),
                          ),
                        ],
                      )
                  ),

                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _otherOptionList.length,
                      itemBuilder: (BuildContext context, int index) {
                        int count = index + 1;
                        final textFieldFocusNode = FocusNode();
                        final textFieldFocusNode1 = FocusNode();
                        _otherOptionControllers.add(new TextEditingController());
                        _otherPriceControllers.add(new TextEditingController());
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      focusNode: textFieldFocusNode,
                                      controller: _otherOptionControllers[index],
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .singleLineFormatter
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                        isDense: true,
                                        labelText: "Option " + count.toString(),
                                        labelStyle: TextStyle(color: kPrimaryColor),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      focusNode: textFieldFocusNode1,
                                      controller: _otherPriceControllers[index],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly],
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: kPrimaryColor),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                        isDense: true,
                                        labelText: "+price " + count.toString(),
                                        labelStyle: TextStyle(color: kPrimaryColor),
                                      ),
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Wrap(
                                          spacing: 5,
                                          direction: Axis.horizontal,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(0.0),
                                              width: 30.0, // you can adjust the width as you need
                                              child:  IconButton(
                                                icon: Icon(Icons.delete, size: 25,color: Colors.grey),
                                                onPressed:(){
                                                  textFieldFocusNode.unfocus();
                                                  textFieldFocusNode.canRequestFocus = false;
                                                  setState(() {
                                                    _otherOptionList.removeAt(index);
                                                    _otherOptionControllers.removeAt(index);
                                                    _otherPriceControllers.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                    )
                                )
                              ],
                            ),
                          ),
                        );
                      }),

                  _colorOptionList.length < 5?
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, size: 30,color: Colors.grey),
                          onPressed:(){
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (currentFocus.canRequestFocus) {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            }
                            if (_otherOptionList.length < 5) {
                              setState(() {
                                _otherOptionList.add('');
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ): Container(),
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                 /* _otherOptionList.clear();
                                  _otherOptionList = [''];
                                  _otherTitleControllers.text = 'OTHER';*/
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
                                padding: EdgeInsets.all(0),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    "SAVE",
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
            ),
          ],
        ),
      );
    });
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
          title: Text('Setup New Inventory'),
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
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:  Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _logoList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return  InkWell(
                                    onTap: (){
                                      logoindex = index;
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              showdiag(context, selectedImageContent(_getLogoFromGallary), '0'));
                                    },
                                      child: _logoUrlList[index]!=null && _logoUrlList[index]!=''?
                                      _logoUrlList[index] != null
                                          ? Container(
                                        margin: EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: getLogo(_logoUrlList[index]),
                                          ),
                                        ),
                                        width: 100.0,
                                        height: 100.0,
                                      )
                                          :Icon(Icons.add_photo_alternate_outlined, size: 100,color: Colors.grey)
                                          :Icon(Icons.add_photo_alternate_outlined, size: 100,color: Colors.grey),

                                  );
                                }),
                            _logoList.length < 3?
                            IconButton(
                              icon: Icon(Icons.add_to_photos, size: 30,color: Colors.grey),
                              onPressed:(){
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (currentFocus.canRequestFocus) {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                }
                                if (_logoList.length < 3) {
                                  setState(() {
                                    _logoList.add('');
                                    _logoUrlList.add('');
                                  });
                                }
                              },
                            ) : Container(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Flexible(
                          flex: 8,
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
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        Flexible(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: IconButton(icon: Icon(Icons.edit, size: 30, color: Colors.grey),
                                        onPressed: (){
                                          FocusScope.of(context).unfocus();
                                          displayBottomSheet();
                                        })

                                ),
                              ],
                            )
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: productName,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .singleLineFormatter
                      ],
                      decoration: InputDecoration(
                        labelText:
                        "Product name", //getTranslated(context, 'amount'),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: productDescription,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .singleLineFormatter
                      ],
                      decoration: InputDecoration(
                        labelText:
                        "Product description", //getTranslated(context, 'amount'),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              controller: productPrice,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText:
                                "Price", //getTranslated(context, 'amount'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              controller: productStock,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText:
                                "Stock", //getTranslated(context, 'amount'),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              controller: productTime,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText:
                                "Time to ship in days", //getTranslated(context, 'amount'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              controller: productTax,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                                FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText:
                                "Tax rate", //getTranslated(context, 'amount'),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: 50),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: defOption,
                            onChanged: (val) {
                              setState(() {
                                defOption = val;
                                if (defOption == true) {
                                  isSize = '1';
                                  defaultOption();
                                } else {
                                  setState(() {
                                    _sizeTitleControllers.text = 'SIZE';
                                    _colorTitleControllers.text = 'COLOR';
                                    _otherTitleControllers.text = 'OTHER';

                                    size = false;
                                    _sizeOptionList.clear();
                                    _sizeOptionList = [''];
                                    _sizeOptionControllers.clear();
                                    _sizePriceControllers.clear();

                                    color = false;
                                    _colorOptionList.clear();
                                    _colorOptionList = [''];
                                    _colorOptionControllers.clear();
                                    _colorPriceControllers.clear();

                                    other = false;
                                    _otherOptionList.clear();
                                    _otherOptionList = [''];
                                    _otherOptionControllers.clear();
                                    _otherPriceControllers.clear();

                                  });
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'USE DEFAULT OPTIONS',
                          style: new TextStyle(fontSize: 14.0),
                        ),

                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: size,
                            onChanged: (val) {
                              setState(() {
                                size = val;
                                if (size == true) {
                                  isSize = '1';
                                } else {
                                  isSize = '0';
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                            onTap: ()async{
                              FocusScope.of(context).unfocus();
                              await showDialog(context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => showdiag(context, sizeOptions(), '1'));
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add_box_rounded, color: Colors.grey),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  _sizeTitleControllers.text != ''?
                                  _sizeTitleControllers.text : 'SIZE',
                                  style: new TextStyle(fontSize: 14.0),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: color,
                            onChanged: (val) {
                              setState(() {
                                color = val;
                                if (color == true) {
                                  isColor = '1';
                                } else {
                                  isColor = '0';
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                            onTap: ()async{
                              FocusScope.of(context).unfocus();
                              await showDialog(context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => showdiag(context, colorOptions(), '1'));
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add_box_rounded, color: Colors.grey),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  _colorTitleControllers.text != ''?
                                  _colorTitleControllers.text : 'COLOR',
                                  style: new TextStyle(fontSize: 14.0),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: other,
                            onChanged: (val) {
                              setState(() {
                                other = val;
                                if (other == true) {
                                  isOther = '1';
                                } else {
                                  isOther = '0';
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                            onTap: ()async{
                              FocusScope.of(context).unfocus();
                              await showDialog(context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => showdiag(context, otherOptions(), '1'));
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add_box_rounded, color: Colors.grey),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  _otherTitleControllers.text != ''?
                                  _otherTitleControllers.text : 'OTHER',
                                  style: new TextStyle(fontSize: 14.0),
                                ),
                              ],
                            )
                        ),

                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          var sizeObject;
                          var colorObject;
                          var otherObject;
                          if(isImage == false){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Please add image');
                          } else if(categoryData.isEmpty){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Please add category');
                          } else if(productName.text == ''){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Product name required.');
                          } else if(productDescription.text == ''){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Product descripton required.');
                          }else if(productPrice.text == ''){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Price required.');
                          } else if(productStock.text == ''){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Stock required.');
                          } else if(0 >= int.parse(productStock.text)){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Stock is required more then 0.');
                          } else if(productTime.text == ''){
                            showSimpleDialog(context,
                                title: 'Attention',
                                message: 'Time required.');
                          } else{
                            if(isSize == '1'){
                              if (_sizeOptionControllers.length > 0) {
                                for (int i = 0; i < _sizeOptionList.length; i++) {
                                  String sizeOption = _sizeOptionControllers[i].text;
                                  String sizePrice = _sizePriceControllers[i].text;
                                  if (sizeOption != '' || sizePrice != '') {
                                    var sizeObject = '{"option" : "$sizeOption","price" : "$sizePrice"}';
                                    sizeList.add(sizeObject);
                                  }
                                }
                                String sizeTitle =_sizeTitleControllers.text;
                                var size = sizeList.toString();
                                sizeObject = '{"option_name" : "$sizeTitle","option" : $size}';
                                print(sizeObject);
                              } else{
                                String sizeTitle =_sizeTitleControllers.text;
                                var size = sizeList.toString();
                                sizeObject = '{"option_name" : "$sizeTitle","option" : $size}';
                              }
                            } else{
                              String sizeTitle =_sizeTitleControllers.text;
                              var size = sizeList.toString();
                              sizeObject = '{"option_name" : "$sizeTitle","option" : $size}';
                            }
                            if(isColor == '1'){
                              if (_colorOptionControllers.length > 0) {
                                for (int i = 0; i < _colorOptionList.length; i++) {
                                  String colorOption = _colorOptionControllers[i].text;
                                  String colorPrice = _colorPriceControllers[i].text;
                                  if (colorOption != '' || colorPrice != '') {
                                    var colorObject = '{"option" : "$colorOption","price" : "$colorPrice"}';
                                    colorList.add(colorObject);
                                  }
                                }
                                String colorTitle =_colorTitleControllers.text;
                                var color = colorList.toString();
                                colorObject = '{"option_name" : "$colorTitle","option" : $color}';
                                print(colorObject);
                              } else{
                                String colorTitle =_colorTitleControllers.text;
                                var color = colorList.toString();
                                colorObject = '{"option_name" : "$colorTitle","option" : $color}';
                              }
                            }else{
                              String colorTitle =_colorTitleControllers.text;
                              var color = colorList.toString();
                              colorObject = '{"option_name" : "$colorTitle","option" : $color}';
                            }
                            if(isOther == '1'){
                              if (_otherPriceControllers.length > 0) {
                                for (int i = 0; i < _otherOptionList.length; i++) {
                                  String otherOption = _otherOptionControllers[i].text;
                                  String priceOption = _otherPriceControllers[i].text;
                                  if (otherOption != '' || priceOption != '') {
                                    var otherObject = '{"option" : "$otherOption","price" : "$priceOption"}';
                                    otherList.add(otherObject);
                                  }
                                }
                                String otherTitle =_otherTitleControllers.text;
                                var other = otherList.toString();
                                otherObject = '{"option_name" : "$otherTitle","option" : $other}';
                              }else{
                                String otherTitle =_otherTitleControllers.text;
                                var other = otherList.toString();
                                otherObject = '{"option_name" : "$otherTitle","option" : $other}';
                              }
                            }else{
                              String otherTitle =_otherTitleControllers.text;
                              var other = otherList.toString();
                              otherObject = '{"option_name" : "$otherTitle","option" : $other}';
                            }
                            createInventory(productName.text, productDescription.text, productPrice.text,
                                _selectedCategory.id.toString(), productStock.text, productTime.text, productTax.text,
                                sizeObject, colorObject, otherObject);

                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                          side: BorderSide(
                              color: Theme.of(context).primaryColor),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            "SAVE",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }
}
