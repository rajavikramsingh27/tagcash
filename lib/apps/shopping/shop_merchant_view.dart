import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/shopping/components/custom_drop_down.dart';
import 'package:tagcash/apps/shopping/merchant/stripe_webview_screen.dart';
import 'package:tagcash/apps/shopping/models/delivery.dart';
import 'package:tagcash/apps/shopping/models/delivery_option.dart';
import 'package:tagcash/apps/shopping/payment/payment_service.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';

import "dart:io";
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'merchant/inventory_list.dart';
import 'merchant/order_screen.dart';
import 'models/shop_merchant.dart';

class ShopMerchantView extends StatefulWidget {
  final ShopMerchant shop;
  final moduleCode;

  const ShopMerchantView({Key key, this.shop, this.moduleCode}) : super(key: key);

  _ShopMerchantViewState createState() => _ShopMerchantViewState();
}

class _ShopMerchantViewState extends State<ShopMerchantView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  File imageFile;

  bool loader = false;
  TextEditingController shopTitle;
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


  TextEditingController deliveryTitle;
  TextEditingController deliveryDescription;
  TextEditingController deliveryDays;
  var _value;

  PickedFile _logoImage;
  PickedFile _headerImage;
  int walletIdOne = 0;
  String currencyOne = "Select";
  int walletIdTwo = 0;
  String currencyTwo = "";
  String shopType = "Categories";
  bool public = false, cod = false, enable = true;
  String paymenttagcash_type = '0';
  String cod_type = '0';
  String enable_payment = '1';
  bool isLoading = false;
  int updateshop = 0;

  List<ShopMerchant> getDataMerchant = new List<ShopMerchant>();

  List<CustomDropdownMenuItem<Wallet>> _dropdownMenuItems;
  Wallet _selectedCurrency;

  List<CustomDropdownMenuItem<Wallet>> _dropdownMenuItems1;
  Wallet _selectedCurrency1;

  List<Wallet> walletData = [];
  List<Wallet> walletData1 = [];

  List<Delivery> _delivery = Delivery.getDelivery();
  List<CustomDropdownMenuItem<Delivery>> _dropdownMenuItems2;
  Delivery _selectedDelivery;

  List orderList;

  String url = '';

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

  Future<void> _getLogoFromGallary([type]) async {
    var selectedLogo;
    if(type=="camera"){
      selectedLogo = await ImagePicker().getImage(
        source: ImageSource.camera,
          maxHeight: 250
      );
    }else{
      selectedLogo = await ImagePicker().getImage(
        source: ImageSource.gallery,
          maxHeight: 250
      );
    }
    if (selectedLogo != null) {
      setState(() {
        _cropImage(selectedLogo.path, selectedLogo);
      });
    }

  }

  /*GetStripeAccountApi...*/

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

    String account_Id = response['id'];
    String email = response['email'];
    bool detailSubmitted = response['details_submitted'];

    if(detailSubmitted){
      updateStripeConnect(account_Id, email);
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
/*CreateStripeAccountApi...*/
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


  /*CreateStripeAccountLinkApi...*/

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

  /*UpdateStripeAccountApi...*/

  void updateStripeConnect(accountId, email) async {

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
                  setState(() {
                    widget.shop.stripe_connect_id = accountId;
                    widget.shop.stripe_email = email;
                  });
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

  /*RemoveStripeAccountApi...*/

  void removeAccount() async {
    setState(() {
      isLoading = true;
    });
    final postData = {
      "shop_id" : widget.shop.id.toString(),
    };

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/RemoveStripeConnect', postData);

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


  Future<List<DeliveryOption>>deliveryOptionsListLoad() async {
    print('====================shopDeliveryOptionsLoad====================');
    Map<String, String> postData = {};
    if(widget.shop==null){
      return [];
    }
    postData["shop_id"] = widget.shop.id.toString();
    Map<String, dynamic> response =
    await NetworkHelper.request('shop/getshippingoption', postData);

    List responseList = response['list'];
    print(responseList);
    List<DeliveryOption> getData = responseList.map<DeliveryOption>((json) {
      return DeliveryOption.fromJson(json);
    }).toList();
    return getData;
  }

  void getOrderList() async {
    final postData = {
      "shop_id" : widget.shop.id.toString(),
    };

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/OwnerOrder', postData);

    if (response['status'] == 'success') {
      if(response['list'] != null){
        orderList = response['list'];
        setState(() {
          print(orderList.length);
        });
      } else{
      }

    } else {

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
        for(int i = 0; i < walletData.length; i++){
          if(widget.shop.currency_code == walletData[i].currencyCode){
            _selectedCurrency = _dropdownMenuItems[i].value;
          }

        }
        getCurrency(_selectedCurrency.currencyCode);

        return getData;
      }
    }
    return walletData;
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
    int currency;

    if(updateshop == 0){
      _dropdownMenuItems1 = buildDropdownMenuItems(walletData1);
      for(int i = 0; i < walletData1.length; i++){
        if(widget.shop.wallet_reward_currency_code == walletData1[i].currencyCode){
          currency = i;
        } else{
          currency = i;
        }
      }
      setState(() {
        _selectedCurrency1 = _dropdownMenuItems1[currency].value;
      });
    }else{
      _dropdownMenuItems1 = buildDropdownMenuItems(walletData1);
      setState(() {
        _selectedCurrency1 = _dropdownMenuItems1[0].value;
      });
    }

  }

  popupWalletContent([str]){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Center(
          child: Text(
            getTranslated(context, 'choose_wallet'),
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
          child:  SizedBox(
            width: 40,
            height: 2.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor
              ),
            ),
          ),
        ),
        Container(
          height: 300.0, // Change as per your requirement
          // width: 300.0, // Change as per your requirement
          child: FutureBuilder<List<Wallet>>(
            future: getWalletData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Wallet> data = snapshot.data;
                return _buildWalletList(str,data);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: new SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: const CircularProgressIndicator()
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  ListView _buildWalletList(str,data) {
    return ListView.separated(
        padding: EdgeInsets.all(16.0),
        itemCount: data.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (context, i) {
          return _buildWalletRow(str, data[i]);
        }
    );
  }

  _buildWalletRow(str, row) {
    return ListTile(
      title: Text(
        row.walletName,
      ),
      subtitle: Text(row.currencyCode),
      onTap: (){
        if(str=="one"){
          setState(() {
            walletIdOne = row.walletId;
            currencyOne = row.currencyCode;
          });
        }else{
          setState(() {
            walletIdTwo = row.walletId;
            currencyTwo = row.currencyCode;
          });
        }
        Navigator.of(context).pop(true);
      },
    );
  }

  loading(val){
    setState((){
      loader = val;
    });
  }

  @override
  void initState() {
    super.initState();
    _sizeTitleControllers.text = 'SIZE';
    _colorTitleControllers.text = 'COLOR';
    _otherTitleControllers.text = 'OTHER';

    getOrderList();
    List<CustomDropdownMenuItem<Delivery>> buildDropdownMenuItems(
        List companies) {
      List<CustomDropdownMenuItem<Delivery>> items = List();
      for (Delivery company in companies) {
        items.add(
          CustomDropdownMenuItem(
            value: company,
            child: Text(
              company.name,
              style: TextStyle(),
            ),
          ),
        );
      }
      return items;
    }

    _dropdownMenuItems2 = buildDropdownMenuItems(_delivery);
     if(widget.shop != null){
       if(widget.shop.delivery_handling == 'Manually'){
         _selectedDelivery = _dropdownMenuItems2[0].value;
       } else if(widget.shop.delivery_handling == 'Grab delivery'){
         _selectedDelivery = _dropdownMenuItems2[1].value;
       } else if(widget.shop.delivery_handling == 'Gofer'){
         _selectedDelivery = _dropdownMenuItems2[2].value;
       } else if(widget.shop.delivery_handling == 'DHL'){
         _selectedDelivery = _dropdownMenuItems2[3].value;
       }
     } else{
       _selectedDelivery = _dropdownMenuItems2[0].value;
     }

    getWalletData();
    loading(true);
    shopTitle = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.title : "");
    shopTag = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.search_tag : "");
    shopDescription = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.description : "");
    shopTaxRate = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.shop_tax_rate : "");
    enablePayment = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.reward_amount.toString() : "");
    maxReward = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.max_purchase_reward.toString() : "");
    deliveryCharge = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.delivery_charge.toString() : "");
    pickupAddress = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.pickup_address.toString() : "");
    zipCode = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.postal_code.toString() : "");
    contactNumber = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.contact_number.toString() : "");
    contactEmail = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.contact_email.toString() : "");

    paymenttagcash_type = widget.shop.payment_by_tagcash.toString();
    cod_type = widget.shop.cod.toString();
    enable_payment = widget.shop.enable_reward_payment.toString();

    if(paymenttagcash_type == '1'){
      public = true;
    } else{
      public = false;
    }

    if(cod_type == '1'){
      cod = true;
    } else{
      cod = false;
    }

    if(enable_payment == '1'){
      enable = true;
    } else{
      enable = false;
    }

    shopDescription = new TextEditingController(
        text: (widget.shop != null) ? widget.shop.description : "");
    deliveryTitle = new TextEditingController();
    deliveryDescription = new TextEditingController();
    deliveryDays = new TextEditingController();
    _value = 1;
    if(widget.shop != null){
      setState(() {
        walletIdOne = widget.shop.walletId;
        currencyOne = widget.shop.currencyCode;
      });
      print(widget.shop.currencyCode.toString());
    }
    loading(false);

   setupOptions();

  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getOrderList();
  }

  void updateShop(shop_id, title, search_tag, description, payment_by_tagcash, cod, wallet_id,
      delivery_charge, enable_reward_payment, reward_wallet_id, reward_amount, max_purchase_reward, delivery_handling,
      pickup_address, postal_code, contact_number, contact_email, shop_tax_rate, sizeObject, colorObject, otherObject) async {
    getDataMerchant.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = shop_id.toString();
    apiBodyObj['title'] = title;
    apiBodyObj['search_tag'] = search_tag;
    apiBodyObj['description'] = description;
    apiBodyObj['payment_by_tagcash'] = payment_by_tagcash;
    apiBodyObj['cod'] = cod;
    apiBodyObj['wallet_id'] = wallet_id.toString();
    if(url != null && url != ''){
      apiBodyObj['logo'] = img2base64(imageFile);
    }
    apiBodyObj['delivery_charge'] = delivery_charge;
    apiBodyObj['enable_reward_payment'] = enable_reward_payment;
    apiBodyObj['reward_wallet_id'] = reward_wallet_id.toString();
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

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/update', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      List responseList = response['list'];
      if(responseList!= null){
        getDataMerchant = responseList.map<ShopMerchant>((json) {
          return ShopMerchant.fromJson(json);
        }).toList();

        widget.shop.shop_tax_rate = getDataMerchant[0].shop_tax_rate;
        widget.shop.size_option_name = getDataMerchant[0].size_option_name;
        widget.shop.size.clear();
        widget.shop.size = getDataMerchant[0].size;
        widget.shop.color_option_name = getDataMerchant[0].color_option_name;
        widget.shop.color.clear();
        widget.shop.color = getDataMerchant[0].color;
        widget.shop.other_option_name = getDataMerchant[0].other_option_name;
        widget.shop.other.clear();
        widget.shop.other = getDataMerchant[0].other;

      } else{

      }

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text('Shop is updated successfully.'),
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

  void deleteShop(shop_id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = shop_id.toString();

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/Delete', apiBodyObj);

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

  setupOptions(){
    _otherTitleControllers.text = widget.shop.other_option_name;
    if(widget.shop.other.isNotEmpty){
      _otherOptionList.clear();
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

    _colorTitleControllers.text = widget.shop.color_option_name;
    if(widget.shop.color.isNotEmpty){
      _colorOptionList.clear();
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

    _sizeTitleControllers.text = widget.shop.size_option_name;
    if(widget.shop.size.isNotEmpty){
      _sizeOptionList.clear();
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
                                 /* _colorOptionList.clear();
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
    return DefaultTabController(
      length: (widget.shop!=null)?2:1,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor:
          Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
              'user'
              ? Colors.black
              : Color(0xFFe44933),
          title: Text((widget.shop != null) ? widget.shop.title : "Setup New Shop"),
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
        body: Column(
          children: <Widget>[
            (widget.shop!=null)?
            Container(
              decoration: new BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.6)),
              margin: EdgeInsets.only(top: 10),
              constraints: BoxConstraints(maxHeight: 150.0),
                child: TabBar(
                  unselectedLabelColor:  Colors.white,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(text: getTranslated(context, "shop_details")),
                    Tab(icon: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(getTranslated(context, "orders")),
                        SizedBox(width: 10),
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
                                  orderList != null?
                                  orderList.length.toString():
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
                        )
                      ],
                    ),),
                  ],
                  indicatorColor: Colors.black,
                ),
            )
            :Container(),
            (widget.shop!=null)?
            Expanded(
              child: TabBarView(
                children: [
                  shopDetails(),
                  OrderListScreen(shop: widget.shop),
                ],
              ),
            ):
            Expanded(
              child: shopDetails(),
            ),
          ],
        ),
      ),
    );
  }

  getLogo(){
    if(url!=null && url!=''){
      return url != null
          ? FileImage(File(url))
          :NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    }else{
      return (widget.shop != null)
          ? widget.shop.logoThumb != ''?
           NetworkImage(widget.shop.logoThumb)
           : NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo")
          : NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    }
  }

  getHeader(){
    if(_headerImage!=null){
      return AssetImage(_headerImage.path);
    }else{
      return (widget.shop != null && widget.shop.headerImage!= null)
          ? NetworkImage(widget.shop.headerImage)
          : NetworkImage(
          "https://dummyimage.com/500x300/cccccc/000000.jpg&text=Header Image");
    }
  }

  img2base64(image){
    File imageFile = new File(image.path);
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  shopDetails(){
    return Scaffold(
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
                      SizedBox(
                        height: 20,
                      ),
                      widget.shop.stripe_connect_id != 'null'&& widget.shop.stripe_connect_id != ''?
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 15,
                                child:Container(
                                   width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Connected Stripe Account : ',
                                        style: Theme.of(context).textTheme.subtitle2.apply(),
                                        textAlign: TextAlign.start,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            widget.shop.stripe_email,
                                            style: Theme.of(context).textTheme.subtitle2.apply(),
                                            textAlign: TextAlign.start,
                                          ),
                                          SizedBox(width: 10),
                                          InkWell(
                                            onTap: (){
                                              Widget cancelButton = FlatButton(
                                                child: Text("No"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                              Widget continueButton = FlatButton(
                                                child: Text("Yes"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  removeAccount();
                                                },
                                              );

                                              AlertDialog alert = AlertDialog(
                                                title: Text(""),
                                                content: Text('Are you sure you want to delete this account?'),
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
                                            child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Icon(Icons.cancel, size: 20, color: Theme.of(context).primaryColor)
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                )
                            ),
/*                            Flexible(
                              flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: InkWell(
                                    onTap: (){
                                      Widget cancelButton = FlatButton(
                                        child: Text("No"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      );
                                      Widget continueButton = FlatButton(
                                        child: Text("Yes"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          removeAccount();
                                        },
                                      );

                                      AlertDialog alert = AlertDialog(
                                        title: Text(""),
                                        content: Text('Are you sure you want to delete this account?'),
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
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Icon(Icons.cancel, size: 20, color: Theme.of(context).primaryColor)
                                      ),
                                  )
                                )
                            )*/


                          ],
                        ),
                      ) : Container(),

                      widget.shop.stripe_connect_id != 'null' && widget.shop.stripe_connect_id != ''?
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
                        child: Row(
                          children: [
                            Flexible(
                                flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () async {
                                      Widget cancelButton = FlatButton(
                                        child: Text("No"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      );
                                      Widget continueButton = FlatButton(
                                        child: Text("Yes"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          deleteShop(widget.shop.id);

                                        },
                                      );

                                      AlertDialog alert = AlertDialog(
                                        title: Text(""),
                                        content: Text('Are you sure you want to delete this shop?'),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                      side: BorderSide(
                                          color: Theme.of(context).primaryColor),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 15, bottom: 15),
                                      child: Text(
                                        "DELETE",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                            ),

                            SizedBox(
                              width: 10,
                            ),

                            Flexible(
                              flex: 1,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    sizeList.clear();
                                    colorList.clear();
                                    otherList.clear();

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
                                        updateShop(widget.shop.id, shopTitle.text, shopTag.text, shopDescription.text, paymenttagcash_type, cod_type,
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
                                        updateShop(widget.shop.id, shopTitle.text, shopTag.text, shopDescription.text, paymenttagcash_type, cod_type,
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
                                      updateShop(widget.shop.id, shopTitle.text, shopTag.text, shopDescription.text, paymenttagcash_type, cod_type,
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
                                      "SAVE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ),

                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InventoryList(shop: widget.shop)),
                                        ).then((val)=>val?Navigator.pop(context, true):null);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                      side: BorderSide(
                                          color: Theme.of(context).primaryColor),
                                    ),
                                    child: Container(
                                        padding: EdgeInsets.only(top: 15, bottom: 15),
                                        child: Text(
                                          "INVENTORY",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                            ),
                          ],
                        )
                      ),
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
}
