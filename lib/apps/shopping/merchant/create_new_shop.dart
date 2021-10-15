import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/shopping/components/custom_drop_down.dart';
import 'package:tagcash/apps/shopping/merchant/stripe_webview_screen.dart';
import 'package:tagcash/apps/shopping/models/delivery.dart';
import 'package:tagcash/apps/shopping/payment/payment_service.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';

import "dart:io";
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CreateNewShop extends StatefulWidget {

  _CreateNewShopState createState() => _CreateNewShopState();
}


class _CreateNewShopState extends State<CreateNewShop> {
  File imageFile;
  TextEditingController shopTitle = TextEditingController();
  TextEditingController shopTag = TextEditingController();
  TextEditingController shopDescription = TextEditingController();
  TextEditingController shopTaxRate = TextEditingController();
  TextEditingController enablePayment = TextEditingController();
  TextEditingController maxReward = TextEditingController();
  TextEditingController deliveryCharge = TextEditingController();
  TextEditingController pickupAddress = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController contactEmail = TextEditingController();
  bool loader = false, public = false, cod = false, enable = true, isLoading = false;
  String url = '', paymenttagcash_type = '0', cod_type = '0', enable_payment = '1';

  List<CustomDropdownMenuItem<Wallet>> _dropdownMenuItems;
  Wallet _selectedCurrency;

  List<CustomDropdownMenuItem<Wallet>> _dropdownMenuItems1;
  Wallet _selectedCurrency1;

  List<Delivery> _delivery = Delivery.getDelivery();
  List<CustomDropdownMenuItem<Delivery>> _dropdownMenuItems2;
  Delivery _selectedDelivery;

  List<Wallet> walletData = [];
  List<Wallet> walletData1 = [];

  bool size = false, color = false, other = false;
  String isSize = '0', isColor = '0', isOther = '0';

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

  List<String> sizeList = [];
  List<String> colorList = [];
  List<String> otherList = [];

  String StripeAccountId = '', StripeAccountEmail = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('initChangeback');
    _sizeTitleControllers.text = 'SIZE';
    _colorTitleControllers.text = 'COLOR';
    _otherTitleControllers.text = 'OTHER';

    List<CustomDropdownMenuItem<Delivery>> buildDropdownMenuItems(
        List companies) {
      List<CustomDropdownMenuItem<Delivery>> items = List();
      for (Delivery company in companies) {
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

    _dropdownMenuItems2 = buildDropdownMenuItems(_delivery);
    _selectedDelivery = _dropdownMenuItems2[0].value;

    getWalletData();

  }


  void getAccount() async {
    print('didChangeback');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String accountId = _prefs.getString('AccountId');
    print(accountId);
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await StripeService.requestGetAccount(
        'https://api.stripe.com/v1/accounts/$accountId',
        );

    bool detailSubmitted = response['details_submitted'];

    if(detailSubmitted){
      setState(() {
        isLoading = false;
      });
      String account_Id = response['id'];
      String email = response['email'];
      await _prefs.setString('StripeAccountId', account_Id);
      await _prefs.setString('StripeAccountEmail', email);
//      updateStripeConnect(account_Id);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text('Your stripe account connected successfully'),
            actions: [
              FlatButton(
                child: Text('Ok'),
                onPressed: () async {
//                  Navigator.of(context).pop();
                  SharedPreferences _prefs = await SharedPreferences.getInstance();
                  setState(() {
                    StripeAccountId = _prefs.getString('StripeAccountId');
                    StripeAccountEmail = _prefs.getString('StripeAccountEmail');
                  });
                },
              ),
            ],
          );
        },
      );
    } else{
      setState(() {
        isLoading = false;
      });
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text('Stripe account connected Failed'),
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

  void createAccount() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await StripeService.requestAccount(
        'https://api.stripe.com/v1/accounts',
        'standard');

    String acId = response['id'];
    print(acId);
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('AccountId', acId);

    createAccountLink(acId);

  }

  void createAccountLink(String accountId) async {

    Map<String, dynamic> response = await StripeService.requestAccountLink(
        'https://api.stripe.com/v1/account_links',
        accountId, 'https://www.google.com', 'https://www.yahoo.com', 'account_onboarding');

    setState(() {
      isLoading = false;
    });
    String url = response['url'];
    print(url);

    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => StripeWebviewScreen(url: url)),
    ).then((val)=>val? getAccount():null);

  }

  void updateStripeConnect(accountId) async {

    final postData = {
      "stripe_connect_id" : accountId,
    };

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/UpdateStripeConnect', postData);

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
            content: Text('Your stripe account connected successfully'),
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
                  style: TextStyle(),
                ),
              ),
            );
          }
          return items;
        }

        _dropdownMenuItems = buildDropdownMenuItems(walletData);
        _selectedCurrency = _dropdownMenuItems[0].value;

        getCurrency(_selectedCurrency.currencyCode);

        return getData;
      }
    }
    return walletData;
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
    return Column(
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

  Future<Null> _cropImage(String path, var selectedImage) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
//        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
//          CropAspectRatioPreset.ratio3x2,
//          CropAspectRatioPreset.original,
//          CropAspectRatioPreset.ratio4x3,
//          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
//          CropAspectRatioPreset.ratio3x2,
//          CropAspectRatioPreset.ratio4x3,
//          CropAspectRatioPreset.ratio5x3,
//          CropAspectRatioPreset.ratio5x4,
//          CropAspectRatioPreset.ratio7x5,
//          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: kPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
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
        url = imageFile.path;
      });
      print(File(imageFile.path).readAsBytes());
    }
  }


  getLogo(){
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

  img2base64(image){
    File imageFile = new File(image.path);
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }
  getCurrency(String countrycode){
    walletData1.clear();

    for(int i = 0; i < walletData.length; i++){
      if(walletData[i].currencyCode != countrycode){
        Wallet wallet = new Wallet();
        wallet.balanceAmount = walletData[i].balanceAmount;
        wallet.promisedAmount = walletData[i].promisedAmount;
        wallet.walletId = walletData[i].walletId;
        wallet.walletType = walletData[i].walletType;
        wallet.walletTypeNumeric = walletData[i].walletTypeNumeric;
        wallet.walletName = walletData[i].walletName;
        wallet.currencyCode = walletData[i].currencyCode;
        wallet.walletDescription = walletData[i].walletDescription;
        wallet.bankDepositWithdraw = walletData[i].bankDepositWithdraw;
        wallet.subSetTokenTypeId = walletData[i].subSetTokenTypeId;

        walletData1.add(wallet);
      }
    }

    List<CustomDropdownMenuItem<Wallet>> buildDropdownMenuItems(
        List companies) {
      List<CustomDropdownMenuItem<Wallet>> items = List();
      for (Wallet company in companies) {
        items.add(
          CustomDropdownMenuItem(
            value: company,
            child: Text(
              company.currencyCode,
              style: TextStyle(),
            ),
          ),
        );
      }
      return items;
    }

    _dropdownMenuItems1 = buildDropdownMenuItems(walletData1);
    setState(() {
      _selectedCurrency1 = _dropdownMenuItems1[0].value;
    });
  }

  void createShop(title, search_tag, description, payment_by_tagcash, cod, wallet_id,
      delivery_charge, enable_reward_payment, reward_wallet_id, reward_amount, max_purchase_reward, delivery_handling,
      pickup_address, postal_code, contact_number, contact_email, shop_tax_rate, sizeObject, colorObject, otherObject) async {

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    StripeAccountId = _prefs.getString('StripeAccountId');
    StripeAccountEmail = _prefs.getString('StripeAccountEmail');

    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['title'] = title;
    apiBodyObj['search_tag'] = search_tag;
    apiBodyObj['description'] = description;
    apiBodyObj['payment_by_tagcash'] = payment_by_tagcash;
    apiBodyObj['cod'] = cod;
    apiBodyObj['wallet_id'] = wallet_id.toString();
    if(url != null && url != ""){
      apiBodyObj['logo'] = img2base64(imageFile);
    }
    apiBodyObj['delivery_charge'] = delivery_charge;
    apiBodyObj['enable_reward_payment'] = enable_reward_payment;
    apiBodyObj['reward_wallet_id'] = reward_wallet_id;
    apiBodyObj['reward_amount'] = reward_amount;
    apiBodyObj['max_purchase_reward'] = max_purchase_reward;
    apiBodyObj['delivery_handling'] = delivery_handling;
    apiBodyObj['pickup_address'] = pickup_address;
    apiBodyObj['postal_code'] = postal_code;
    apiBodyObj['contact_number'] = contact_number;
    apiBodyObj['contact_email'] = contact_email;
    apiBodyObj['shop_tax_rate'] = shop_tax_rate;
    apiBodyObj['size'] = sizeObject;
    apiBodyObj['color'] = colorObject;
    apiBodyObj['other'] = otherObject;
    apiBodyObj['stripe_connect_id'] = StripeAccountId;
    apiBodyObj['stripe_email'] = StripeAccountEmail;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/create', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
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
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
            'user'
            ? Colors.black
            : Color(0xFFe44933),
        title: Text('Setup New Shop'),
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
          children:[
            ListView(shrinkWrap: true, padding: EdgeInsets.all(5.0), children: <
                Widget>[
              walletData.length != 0?
              Center(
                  child: Column(
                    children: [
                      Card(
                        elevation: 1,
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  showdiag(context, selectedImageContent(_getLogoFromGallary), '0'));
                                        },
                                        child: Container(
                                          height: 60.0,
                                          width: 60.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            border: Border.all(
                                                color: Colors.black, width: .50),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: getLogo(),
                                            ),
                                          ),
                                          child: Text(""),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                          child: TextFormField(
                                            controller: shopTitle,
                                            textCapitalization: TextCapitalization.sentences,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return "Shop title is required."; //getTranslated(context, 'enter_a_valid_amount');
                                              }
                                              return null;
                                            },
                                            keyboardType: TextInputType.text,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .singleLineFormatter
                                            ],
                                            decoration: InputDecoration(
                                              labelText:
                                              "Shop Name", //getTranslated(context, 'amount'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      //Text(shop.title)
                                    ],
                                  ),
                                  TextFormField(
                                    controller: shopTag,
                                    textCapitalization: TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .singleLineFormatter
                                    ],
                                    decoration: InputDecoration(
                                      labelText:
                                      "Search Tags, separate using commas", //getTranslated(context, 'amount'),
                                    ),
                                  ),

                                  TextFormField(
                                    controller: shopDescription,
                                    textCapitalization: TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      new LengthLimitingTextInputFormatter(100),
                                    ],
                                    decoration: InputDecoration(
                                      labelText:
                                      "Shop description", //getTranslated(context, 'amount'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Card(
                        elevation: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5.0),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment Method',
                                    style: Theme.of(context).textTheme.subtitle2.apply(),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Checkbox(
                                            activeColor: kPrimaryColor,
                                            value: public,
                                            onChanged: (val) {
                                              setState(() {
                                                public = val;
                                                if (public == true) {
                                                  paymenttagcash_type = '1';
                                                } else {
                                                  paymenttagcash_type = '0';
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Payment by Tagcash',
                                          style: new TextStyle(fontSize: 14.0),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Checkbox(
                                            activeColor: kPrimaryColor,
                                            value: cod,
                                            onChanged: (val) {
                                              setState(() {
                                                cod = val;
                                                if (cod == true) {
                                                  cod_type = '1';
                                                } else {
                                                  cod_type = '0';
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'COD',
                                          style: new TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                          decoration: new BoxDecoration(
                                              border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                              borderRadius: BorderRadius.circular(5.0)),
                                          width: MediaQuery.of(context).size.width / 3,
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
                                                  items: _dropdownMenuItems,
                                                  underline: Container(),
                                                  onChanged: (val) {
                                                    FocusScopeNode currentFocus = FocusScope.of(context);
                                                    if (currentFocus.canRequestFocus) {
                                                      FocusScope.of(context)
                                                          .requestFocus(new FocusNode());
                                                    }
                                                    setState(() {
                                                      _selectedCurrency = val;
                                                      getCurrency(_selectedCurrency.currencyCode);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          )),

                                      Container(
                                        width: MediaQuery.of(context).size.width / 2,
                                        child: TextFormField(
                                          controller: shopTaxRate,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(2),
                                            FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                            isDense: true,
                                            labelText:
                                            "Default tax rate", //getTranslated(context, 'amount'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Checkbox(
                                            activeColor: kPrimaryColor,
                                            value: enable,
                                            onChanged: (val) {
                                              setState(() {
                                                enable = val;
                                                if (enable == true) {
                                                  enable_payment = '1';
                                                } else {
                                                  enable_payment = '0';
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Enable payment or part payment using rewards',
                                          style: new TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ),

                                  enable_payment == '1'?
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Text(
                                              '1',
                                              style: Theme.of(context).textTheme.subtitle2.apply(),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                                decoration: new BoxDecoration(
                                                    border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                                    borderRadius: BorderRadius.circular(5.0)),
                                                width: MediaQuery.of(context).size.width / 4,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 10, right: 10),
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      CustomDropdownButton(
                                                        isExpanded: true,
                                                        value: _selectedCurrency1,
                                                        items: _dropdownMenuItems1,
                                                        hint: Container(
                                                            child: Text('PHP')),
                                                        underline: Container(),
                                                        onChanged: (val) {
                                                          FocusScopeNode currentFocus = FocusScope.of(context);
                                                          if (currentFocus.canRequestFocus) {
                                                            FocusScope.of(context)
                                                                .requestFocus(new FocusNode());
                                                          }
                                                          setState(() {
                                                            _selectedCurrency1 = val;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '=',
                                              style: Theme.of(context).textTheme.subtitle2.apply(),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(bottom: 10),
                                              width: MediaQuery.of(context).size.width/8,
                                              child: TextFormField(
                                                controller: enablePayment,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly],
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                                  isDense: true,
                                                  labelText:
                                                  "", //getTranslated(context, 'amount'),
                                                ),
                                              ),
                                            ),

                                            Text(_selectedCurrency == null?
                                                'PHP': _selectedCurrency.currencyCode,
                                              style: Theme.of(context).textTheme.subtitle2.apply(),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Max',
                                              style: Theme.of(context).textTheme.bodyText2.apply(),
                                            ),

                                            Container(
                                              margin: EdgeInsets.only(bottom: 10),
                                              width: MediaQuery.of(context).size.width/8,
                                              child: TextFormField(
                                                controller: maxReward,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly],
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
                                                  isDense: true,
                                                  labelText:
                                                  "", //getTranslated(context, 'amount'),
                                                ),
                                                textAlign: TextAlign.center,

                                              ),
                                            ),

                                            Text(_selectedCurrency1 == null?
                                            'PHP':_selectedCurrency1.currencyCode,
                                              style: Theme.of(context).textTheme.subtitle2.apply(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ) : Container() ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Card(
                        elevation: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5.0),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivery Handling',
                                    style: Theme.of(context).textTheme.subtitle2.apply(),
                                    textAlign: TextAlign.start,
                                  ),
                                  _selectedDelivery.name != 'Manually'?
                                  SizedBox(height: 10):Container(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
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
                                                    value: _selectedDelivery,
                                                    items: _dropdownMenuItems2,
                                                    underline: Container(),
                                                    onChanged: (val) {
                                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                                      if (currentFocus.canRequestFocus) {
                                                        FocusScope.of(context)
                                                            .requestFocus(new FocusNode());
                                                      }
                                                      setState(() {
                                                        _selectedDelivery = val;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child:  _selectedDelivery.name == 'Manually'?Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: TextFormField(
                                            controller: deliveryCharge,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(8),
                                              FilteringTextInputFormatter.digitsOnly],
                                            decoration: InputDecoration(
                                              labelText:
                                              "Delivery charge", //getTranslated(context, 'amount'),
                                            ),
                                          ),
                                        ): Container()
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  _selectedDelivery.name != 'Manually'?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: TextFormField(
                                            controller: pickupAddress,
                                            keyboardType: TextInputType.streetAddress,
                                            decoration: InputDecoration(
                                              labelText:
                                              "Pickup address", //getTranslated(context, 'amount'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(
                                        flex: 2,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: TextFormField(
                                            controller: zipCode,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly],
                                            decoration: InputDecoration(
                                              labelText:
                                              "Zip/postcode", //getTranslated(context, 'amount'),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ) : Container(),
                                  SizedBox(height: 5),
                                  _selectedDelivery.name != 'Manually'?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: TextFormField(
                                            controller: contactNumber,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly],
                                            decoration: InputDecoration(
                                              labelText:
                                              "Contact number", //getTranslated(context, 'amount'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: TextFormField(
                                            controller: contactEmail,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              labelText:
                                              "Contact email", //getTranslated(context, 'amount'),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ) : Container()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 5),
                      Card(
                        elevation: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5.0),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set Default Option',
                                    style: Theme.of(context).textTheme.subtitle2.apply(),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      StripeAccountId != 'null'&& StripeAccountId != ''?
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connected Stripe Account : ' +  StripeAccountEmail,
                              style: Theme.of(context).textTheme.subtitle2.apply(),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ) : Container(),
                      StripeAccountId != 'null' && StripeAccountId != ''?
                      Container(margin: EdgeInsets.only(top:10)):Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        child:  FlatButton(
                          onPressed: () async {
                            createAccount();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                            side: BorderSide(
                                color: Color(0xFF2b2b2b)),
                          ),
                          child: Container(
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            child: Text(
                              "CONNECT WITH STRIPE",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          color: Color(0xFF2b2b2b),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        child:  FlatButton(
                          onPressed: () async {
                            var sizeObject;
                            var colorObject;
                            var otherObject;

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

                            if(shopTitle.text == ''){
                              showSimpleDialog(context,
                                  title: 'Attention',
                                  message: 'Shop name required.');
                            } else if(shopTag.text == ''){
                              showSimpleDialog(context,
                                  title: 'Attention',
                                  message: 'Shop tag required.');
                            } else if(shopDescription.text == ''){
                              showSimpleDialog(context,
                                  title: 'Attention',
                                  message: 'Shop description required.');
                            } else if(enablePayment.text == ''){
                              showSimpleDialog(context,
                                  title: 'Attention',
                                  message: 'Payment required.');
                            } else if(maxReward.text == ''){
                              showSimpleDialog(context,
                                  title: 'Attention',
                                  message: 'Max reward required.');
                            } else if(_selectedDelivery.name == 'Manually'){
                              if(deliveryCharge.text == ''){
                                showSimpleDialog(context,
                                    title: 'Attention',
                                    message: 'Delivery charge required.');
                              } else{
                                String reward_wallet_id;
                                if(_selectedCurrency1 != null){
                                  reward_wallet_id = _selectedCurrency1.walletId.toString();
                                }else{
                                  reward_wallet_id = '';
                                }
                                createShop(shopTitle.text, shopTag.text, shopDescription.text, paymenttagcash_type, cod_type,
                                    _selectedCurrency.walletId, deliveryCharge.text, enable_payment,
                                    reward_wallet_id, enablePayment.text, maxReward.text, _selectedDelivery.name, pickupAddress.text,
                                    zipCode.text, contactNumber.text, contactEmail.text, shopTaxRate.text, sizeObject, colorObject, otherObject);
                              }
                            } else if(_selectedDelivery.name != 'Manually'){
                              if(pickupAddress.text == ''){
                                showSimpleDialog(context,
                                    title: 'Attention',
                                    message: 'Pickup address required.');
                              }else if(zipCode.text == ''){
                                showSimpleDialog(context,
                                    title: 'Attention',
                                    message: 'Zip/postcode required.');
                              }else if(contactNumber.text == ''){
                                showSimpleDialog(context,
                                    title: 'Attention',
                                    message: 'Contact number required.');
                              }else if(contactEmail.text == ''){
                                showSimpleDialog(context,
                                    title: 'Attention',
                                    message: 'Contact email required.');
                              } else{
                                String reward_wallet_id;
                                if(_selectedCurrency1 != null){
                                  reward_wallet_id = _selectedCurrency1.walletId.toString();
                                }else{
                                  reward_wallet_id = '';
                                }
                                createShop(shopTitle.text, shopTag.text, shopDescription.text, paymenttagcash_type, cod_type,
                                    _selectedCurrency.walletId, deliveryCharge.text, enable_payment,
                                    reward_wallet_id, enablePayment.text, maxReward.text, _selectedDelivery.name, pickupAddress.text,
                                    zipCode.text, contactNumber.text, contactEmail.text, shopTaxRate.text, sizeObject, colorObject, otherObject);
                              }
                            } else{
                              String reward_wallet_id;
                              if(_selectedCurrency1 != null){
                                reward_wallet_id = _selectedCurrency1.walletId.toString();
                              }else{
                                reward_wallet_id = '';
                              }
                              createShop(shopTitle.text, shopTag.text, shopDescription.text, paymenttagcash_type, cod_type,
                                  _selectedCurrency.walletId, deliveryCharge.text, enable_payment,
                                  reward_wallet_id, enablePayment.text, maxReward.text, _selectedDelivery.name, pickupAddress.text,
                                  zipCode.text, contactNumber.text, contactEmail.text, shopTaxRate.text, sizeObject, colorObject, otherObject);
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
                              "SAVE SHOP INFORMATION",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  )
              ) : Container()
            ]),
            (loader==true)?
            Center(
              child: new SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: CircularProgressIndicator()
              ),
            )
                :Container(),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ]
      ),
    );
  }
}



