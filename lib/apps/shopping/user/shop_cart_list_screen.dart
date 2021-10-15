import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:tagcash/apps/shopping/models/history.dart';
import 'package:tagcash/apps/shopping/models/image.dart';
import 'package:tagcash/apps/shopping/models/item.dart';
import 'package:tagcash/apps/shopping/models/option.dart';
import 'package:tagcash/apps/shopping/models/product.dart';
import 'package:tagcash/apps/shopping/payment/create_new_card.dart';
import 'package:tagcash/apps/shopping/payment/payment_status_screen.dart';
import 'package:tagcash/apps/shopping/user/shop_address_screen.dart';
import 'package:tagcash/apps/shopping/user/shop_cart_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import '../shopping_list_screen.dart';

class ShopCartListScreen extends StatefulWidget {
  TabController tabController;

  ShopCartListScreen({controller}) {
    tabController = controller;
  }
  @override
  _ShopCartListScreenState createState() => _ShopCartListScreenState();
}

class _ShopCartListScreenState extends State<ShopCartListScreen> {
  List<Item> getCartData = new List<Item>();
  List<History> getHistoryData = new List<History>();
  bool isLoading = false, isTax = false;
  String shop_id = '',
      delivery_handling = '',
      delivery_charge = '',
      shop_title = '',
      cod_type = '0',
      currency_code = '',
      walletBalance = '';
  int total = 0;

  String isDefault = '0',
      id = '',
      name = '',
      address = '',
      phone = '',
      city = '',
      postal_code = '',
      emptyMessage = '';

  var _value = 1;

  List<Wallet> walletData = [];

  List<String> selectedOption = [];
  var stringList;

  List<Product> getProductData = new List<Product>();
  List<String> imagess = new List<String>();
  List<Option> other;
  List<Option> color;
  List<Option> size;
  List<image> getImageData = new List<image>();

  int totalAmount = 0;
  String StripeConnectId = '', StripeEmail = '';

  @override
  void initState() {
    super.initState();
    // StripePayment.setOptions(
    //     StripeOptions(
    //         publishableKey:"YOUR_PUBLISHABLE_KEY",
    //         merchantId: "YOUR_MERCHANT_ID",
    //         androidPayMode: 'test'
    //     ));
    getWalletData();
    getCartList();
    getAddressList();
  }

  void getInventoryDetail(String inventoryId, String shopId) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = inventoryId;

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/InventoryDetails', apiBodyObj);


    if (response['status'] == 'success') {
      print(response);
      if (response['list'] != null) {
        Product product =
            new Product(0, '', '', 0, 0, 0, '', '', false, 0, '', '', '');
        product.id = response['list'][0]['id'];
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
        for (int i = 0; i < getImageData.length; i++) {
          String image = getImageData[i].images;
          imagess.add(image);
        }
        product.images = imagess;
        product.other_option_name =
            response['list'][0]['other']['option_name'].toString();
        if (response['list'][0]['other']['option'] != '' &&
            response['list'][0]['other']['option'] != null) {
          var tagObjsJson = response['list'][0]['other']['option'] as List;
          other = tagObjsJson.map<Option>((json) {
            return Option.fromJson(json);
          }).toList();
        }
        product.other = other;
        product.color_option_name =
            response['list'][0]['color']['option_name'].toString();
        if (response['list'][0]['color']['option'] != '' &&
            response['list'][0]['color']['option'] != null) {
          var tagObjsJson = response['list'][0]['color']['option'] as List;
          color = tagObjsJson.map<Option>((json) {
            return Option.fromJson(json);
          }).toList();
        }
        product.color = color;
        product.size_option_name =
            response['list'][0]['size']['option_name'].toString();
        if (response['list'][0]['size']['option'] != '' &&
            response['list'][0]['size']['option'] != null) {
          var tagObjsJson = response['list'][0]['size']['option'] as List;
          size = tagObjsJson.map<Option>((json) {
            return Option.fromJson(json);
          }).toList();
        }
        product.size = size;
        getProductData.add(product);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ShopCartScreen(
                  getProductData: getProductData,
                  index: 0,
                  shopId: shopId,
                  isType: '2')),
        ).then((val) => val ? getCartList() : null);
      }
      setState(() {
        isLoading = false;
      });
    } else {}
  }

  Future<List<Wallet>> getWalletData() async {
    setState(() {
      isLoading = true;
    });
    print(
        '============================getting wallets============================');
    if (walletData.length == 0) {
      Map<String, dynamic> response =
          await NetworkHelper.request('wallet/list');

      if (response["status"] == "success") {
        setState(() {
          isLoading = false;
        });
        List responseList = response['result'];
        List<Wallet> getData = responseList.map<Wallet>((json) {
          return Wallet.fromJson(json);
        }).toList();
        walletData = getData;

        return getData;
      }
    }
    return walletData;
  }

  void getCartList() async {
    getCartData.clear();

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request('shop/cart');

    if (response['status'] == 'success') {
      print(response);
      if (response['list'] != null) {
        shop_id = response['list'][0]['shop_id'].toString();
        delivery_handling = response['list'][0]['delivery_handling'];
        cod_type = response['list'][0]['cod'].toString();
        StripeConnectId = response['list'][0]['stripe_connect_id'].toString();
        StripeEmail = response['list'][0]['stripe_email'].toString();
        if (response['list'][0]['delivery_charge'] != null) {
          delivery_charge = response['list'][0]['delivery_charge'].toString();
        }
        shop_title = response['list'][0]['shop_title'].toString();
        currency_code = response['list'][0]['item'][0]['currency_code'];
        print(currency_code);

        List cartList = response['list'][0]['item'];
        if (cartList != null) {
          getCartData = cartList.map<Item>((json) {
            return Item.fromJson(json);
          }).toList();

          setState(() {
            isLoading = false;
          });
        }
      } else {
        emptyMessage = 'Your Cart is Empty';
        setState(() {
          isLoading = false;
        });
      }
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  void getAddressList() async {
    id = '';
    isDefault = '0';
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/GetAddress');

    if (response['status'] == 'success') {
      print(response);
      if (response['list'] != null) {
        List responseList = response['list'];
        if (responseList != null) {
          for (int i = 0; i < responseList.length; i++) {
            if (responseList[i]['is_default'] == '1') {
              isDefault = responseList[i]['is_default'];
              id = responseList[i]['id'];
              name = responseList[i]['name'];
              address = responseList[i]['address'];
              phone = responseList[i]['phone'];
              city = responseList[i]['city'];
              postal_code = responseList[i]['postal_code'];
            } else {}
          }
          setState(() {
            isLoading = false;
          });
        } else {
          name = '';
        }
      } else {}
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  void deleteAddress(String id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id;

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/DeleteAddress', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getAddressList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateCartQuantity(String item_id, String quantity) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['item_id'] = item_id;
    apiBodyObj['quantity'] = quantity;

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/UpdateCartItemQuantity', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
//      getCartList();
      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
            builder: (context) => ShoppingListScreen(
                moduleCode: "TAG Shopping", selectedPage: 2)),
      );
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addOrder(var payment_type) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = shop_id;
    apiBodyObj['address_id'] = id;
    apiBodyObj['transaction_id'] = '';
    apiBodyObj['payment_type'] = payment_type.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/Order', apiBodyObj);

    if (response['status'] == 'success') {
      getOrderList();
    } else {
      setState(() {
        isLoading = false;
      });
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']['error']);
    }
  }

  void getOrderList() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('shop/UserOrder');


    if (response['status'] == 'success') {
      print(response);
      if (response['list'] != null) {
        List responseList = response['list'];

        getHistoryData = responseList.map<History>((json) {
          return History.fromJson(json);
        }).toList();

        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentStatusScreen(
                  isType: '1',
                  shopId: shop_id,
                  shopTitle: shop_title,
                  paymentStatus: true,
                  paymentMessage: 'Order pay successfully.')),
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  void displayBottomSheet(int itemId, int qty) {
    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              maxChildSize: 1,
              builder: (_, controller) {
                return StatefulBuilder(
                    builder: (BuildContext context, setState) => Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 10),
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 50, right: 50),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.indeterminate_check_box_sharp,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (qty > 0) {
                                            qty--;
                                          }
                                        });
                                      },
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(30),
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 12,
                                        minHeight: 12,
                                      ),
                                      child: new Text(
                                        qty.toString(),
                                        style: new TextStyle(
                                          color: Colors.grey,
                                          fontSize: 50,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_box_sharp,
                                        color: Colors.green,
                                        size: 40,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (qty >= 0) {
                                            qty++;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 2,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: FlatButton(
                                            onPressed: () async {
                                              Navigator.pop(context, true);
                                              updateCartQuantity(
                                                  itemId.toString(),
                                                  qty.toString());
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            child: Container(
                                              child: Text(
                                                "OK",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        )));
              });
        });
  }

  void displayOrderBottomSheet() {
    int total = int.parse(mainTotal());
    for (int i = 0; i < walletData.length; i++) {
      if (currency_code == walletData[i].currencyCode) {
        walletBalance = walletData[i].balanceAmount.toString();
        print(walletBalance);
      }
    }

    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.2,
              maxChildSize: 1,
              builder: (_, controller) {
                return StatefulBuilder(
                    builder: (BuildContext context, setState) => Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Colors.grey,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            child: SizedBox(
                                          height: 24.0,
                                          width: 24.0,
                                          child: Radio(
                                            value: 1,
                                            groupValue: _value,
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            onChanged: (value) {
                                              setState(() {
                                                _value = value;
                                              });
                                            },
                                          ),
                                        )),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _value = 1;
                                            });
                                          },
                                          child: Text("Tagcash Wallet",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                    cod_type != '0'
                                        ? Row(
                                            children: [
                                              Container(
                                                  child: SizedBox(
                                                height: 24.0,
                                                width: 24.0,
                                                child: Radio(
                                                  value: 2,
                                                  groupValue: _value,
                                                  activeColor: Theme.of(context)
                                                      .primaryColor,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _value = value;
                                                    });
                                                  },
                                                ),
                                              )),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _value = 2;
                                                  });
                                                },
                                                child: Text("Cash on Delivery",
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    currency_code != 'TAG'
                                        ? Row(
                                            children: [
                                              Container(
                                                  child: SizedBox(
                                                height: 24.0,
                                                width: 24.0,
                                                child: Radio(
                                                  value: 3,
                                                  groupValue: _value,
                                                  activeColor: Theme.of(context)
                                                      .primaryColor,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _value = value;
                                                    });
                                                  },
                                                ),
                                              )),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _value = 3;
                                                  });
                                                },
                                                child: Text("Card",
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                            ],
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              _value == 1
                                  ? Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [
                                          Text(
                                            "Tagcash Wallet Balance : ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                currency_code,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                ' ' + walletBalance,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          )
                                        ],
                                      ))
                                  : Container(),
                              Container(
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 2,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: FlatButton(
                                            onPressed: () async {
                                              Navigator.pop(context, true);
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              side: BorderSide(
                                                  color: Color(0xFF8C8C8C)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Text(
                                                "CANCEL",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            color: Color(0xFF8C8C8C),
                                          ),
                                        )),
                                    SizedBox(width: 5),
                                    Flexible(
                                        flex: 3,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: FlatButton(
                                            onPressed: () async {
                                              if (_value == 1) {
                                                double d =
                                                    double.parse(walletBalance);
                                                int wBalance = d.toInt();
                                                if (total <= wBalance) {
                                                  Navigator.pop(context, true);
                                                  addOrder(_value);
                                                } else {
                                                  showSimpleDialog(context,
                                                      title: 'Attention',
                                                      message:
                                                          'Please check your wallet balance is low.');
                                                }
                                              } else if (_value == 2) {
                                                Navigator.pop(context, true);
                                                addOrder(_value);
                                              } else {
                                                Navigator.pop(context, true);
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                      new MaterialPageRoute(
                                                          builder: (context) =>
                                                              CreateNewCardScreen(
                                                                  amount: totalAmount
                                                                      .toString(),
                                                                  currency:
                                                                      currency_code,
                                                                  shopId:
                                                                      shop_id,
                                                                  shopTitle:
                                                                      shop_title,
                                                                  addressId: id,
                                                                  paymentType:
                                                                      '3')),
                                                    )
                                                    .then((val) => val
                                                        ? Navigator.of(context)
                                                            .pushReplacement(
                                                            new MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ShoppingListScreen(
                                                                        moduleCode:
                                                                            "TAG Shopping",
                                                                        selectedPage:
                                                                            0)),
                                                          )
                                                        : null);
                                              }
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(0),
                                              child: Text(
                                                "ORDER AND PAY NOW",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        )));
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          child: getCartData.length != 0
              ? SingleChildScrollView(
                  child: Container(
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(15),
                          color: kUserBackColor,
                          child: Row(
                            children: [
                              Text(
                                shop_title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          )),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: getCartData.length,
                          itemBuilder: (context, i) {
                            selectedOption.clear();
                            stringList = '';
                            if (getCartData[i].size.length != 0) {
                              selectedOption.add(getCartData[i].size[0].option);
                            }
                            if (getCartData[i].color.length != 0) {
                              selectedOption
                                  .add(getCartData[i].color[0].option);
                            }
                            if (getCartData[i].other.length != 0) {
                              selectedOption
                                  .add(getCartData[i].other[0].option);
                            }

                            if (selectedOption.length != 0) {
                              stringList = selectedOption.reduce(
                                  (value, element) => value + ', ' + element);
                            }
                            return InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShopCartScreen(
                                          inventoryId: getCartData[i]
                                              .inventory_id
                                              .toString(),
                                          shopId:
                                              getCartData[i].shop_id.toString(),
                                          isType: '2')),
                                ).then((val) => val ? getCartList() : null);
//                                getInventoryDetail(getCartData[i].inventory_id.toString(), getCartData[i].shop_id.toString());
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: getCartData.length != 0
                                                  ? getCartData[i]
                                                              .image_thumb !=
                                                          ''
                                                      ? NetworkImage(
                                                          getCartData[i]
                                                              .image_thumb)
                                                      : NetworkImage(
                                                          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")
                                                  : NetworkImage(
                                                      "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")),
                                        ),
                                        width: 70.0,
                                        height: 60.0,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(getCartData[i].name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          .apply()),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  getCartData[i].size.length !=
                                                              0 ||
                                                          getCartData[i]
                                                                  .color
                                                                  .length !=
                                                              0 ||
                                                          getCartData[i]
                                                                  .other
                                                                  .length !=
                                                              0
                                                      ? Text(
                                                          stringList,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          softWrap: false,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      : Container(),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    getCartData[i]
                                                            .currency_code +
                                                        ' ' +
                                                        getCartData[i]
                                                            .price
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          displayBottomSheet(getCartData[i].id,
                                              getCartData[i].qty);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.grey, width: 1.0),
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: 12,
                                            minHeight: 12,
                                          ),
                                          child: new Text(
                                            getCartData[i].qty.toString(),
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
                          }),
                      Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              delivery_charge != ''
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Delivery Charge',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          delivery_charge,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              delivery_charge != ''
                                  ? SizedBox(height: 5)
                                  : Container(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .apply()),
                                  Text(mainTotal(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .apply()),
                                ],
                              ),
                              SizedBox(height: 15),
                              isTax != false
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                    )
                                  : Container(),
                              isTax != false
                                  ? SizedBox(height: 10)
                                  : Container(),
                              isDefault != '0'
                                  ? Card(
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 5,
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Text(
                                                      name +
                                                          '\n' +
                                                          phone +
                                                          '\n' +
                                                          address +
                                                          '\n' +
                                                          city +
                                                          ' - ' +
                                                          postal_code +
                                                          '\n',
                                                      maxLines: 5,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              Widget
                                                                  cancelButton =
                                                                  FlatButton(
                                                                child:
                                                                    Text("No"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              );
                                                              Widget
                                                                  continueButton =
                                                                  FlatButton(
                                                                child:
                                                                    Text("Yes"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  deleteAddress(
                                                                      id);
                                                                },
                                                              );

                                                              AlertDialog
                                                                  alert =
                                                                  AlertDialog(
                                                                title: Text(""),
                                                                content: Text(
                                                                    'Are you sure you want to delete this address?'),
                                                                actions: [
                                                                  continueButton,
                                                                  cancelButton,
                                                                ],
                                                              );

                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return alert;
                                                                },
                                                              );
                                                            },
                                                            child: const Icon(
                                                              Icons.delete,
                                                              size: 25.0,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                )
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ShopAddressScreen()),
                                                ).then((val) => val
                                                    ? getAddressList()
                                                    : null);
                                              },
                                              child: Text(
                                                'CHOOSE ADDRESS ',
                                                maxLines: 5,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Card(
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [],
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ShopAddressScreen()),
                                                  ).then((val) => val
                                                      ? getAddressList()
                                                      : null);
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Text(
                                                    'CHOOSE ADDRESS ',
                                                    maxLines: 5,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ))
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: FlatButton(
                                            onPressed: () async {
                                              widget.tabController.animateTo(0);
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              side: BorderSide(
                                                  color: Color(0xFF8C8C8C)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Text(
                                                "CANCEL",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            color: Color(0xFF8C8C8C),
                                          ),
                                        )),
                                    SizedBox(width: 5),
                                    Flexible(
                                        flex: 1,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: FlatButton(
                                            onPressed: () async {
                                              if (id != '') {
                                                SharedPreferences _prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await _prefs.setString(
                                                    'SAccountId',
                                                    StripeConnectId);
                                                await _prefs.setString(
                                                    'SEmail', StripeEmail);

                                                displayOrderBottomSheet();
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Attention'),
                                                      content: Text(
                                                          'Please select address.'),
                                                      actions: [
                                                        FlatButton(
                                                          child: Text(
                                                              'CHOOSE ADDRESS'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ShopAddressScreen()),
                                                            ).then((val) => val
                                                                ? getAddressList()
                                                                : null);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Text(
                                                "ORDER & PAY",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
                ))
              : Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6.apply(),
                      ),
                    ],
                  )),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    ));
  }

  String subTotal() {
    total = 0;
    int colorPrice = 0;
    int sizePrice = 0;
    int otherPrice = 0;
    for (int i = 0; i < getCartData.length; i++) {
      if (getCartData[i].color.length != 0) {
        if (getCartData[i].color[0].price != '') {
          colorPrice = int.parse(getCartData[i].color[0].price);
        }
      }
      if (getCartData[i].size.length != 0) {
        if (getCartData[i].size[0].price != '') {
          sizePrice = int.parse(getCartData[i].size[0].price);
        }
      }
      if (getCartData[i].other.length != 0) {
        if (getCartData[i].other[0].price != '') {
          otherPrice = int.parse(getCartData[i].other[0].price);
        }
      }
      int ttl = getCartData[i].price + colorPrice + sizePrice + otherPrice;
      int qty = getCartData[i].qty;
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
    for (int i = 0; i < getCartData.length; i++) {
      if (getCartData[i].color.length != 0) {
        if (getCartData[i].color[0].price != '') {
          colorPrice = int.parse(getCartData[i].color[0].price);
        }
      }
      if (getCartData[i].size.length != 0) {
        if (getCartData[i].size[0].price != '') {
          sizePrice = int.parse(getCartData[i].size[0].price);
        }
      }
      if (getCartData[i].other.length != 0) {
        if (getCartData[i].other[0].price != '') {
          otherPrice = int.parse(getCartData[i].other[0].price);
        }
      }
      int ttl = getCartData[i].price + colorPrice + sizePrice + otherPrice;
      int qty = getCartData[i].qty;
      if (getCartData[i].tax_rate != '') {
        isTax = true;
        rate = int.parse(getCartData[i].tax_rate);
      } else {
        rate = 0;
      }

      int ttlprice = ttl * qty;
      total = total + ttlprice;

      double pertotal = (rate / 100) * ttlprice;
      ttlRate = ttlRate + pertotal;
      total = total + pertotal.toInt();
    }
    if (delivery_charge != '') {
      dCharge = int.parse(delivery_charge);
    }
    total = total + dCharge;
    totalAmount = total;
    return total.toString();
  }

  String taxTotal() {
    double ttlRate = 0;
    int rate = 0;
    int colorPrice = 0;
    int sizePrice = 0;
    int otherPrice = 0;
    for (int i = 0; i < getCartData.length; i++) {
      if (getCartData[i].color.length != 0) {
        if (getCartData[i].color[0].price != '') {
          colorPrice = int.parse(getCartData[i].color[0].price);
        }
      }
      if (getCartData[i].size.length != 0) {
        if (getCartData[i].size[0].price != '') {
          sizePrice = int.parse(getCartData[i].size[0].price);
        }
      }
      if (getCartData[i].other.length != 0) {
        if (getCartData[i].other[0].price != '') {
          otherPrice = int.parse(getCartData[i].other[0].price);
        }
      }
      int ttl = getCartData[i].price + colorPrice + sizePrice + otherPrice;
      int qty = getCartData[i].qty;
      int ttlprice = ttl * qty;
      if (getCartData[i].tax_rate != '') {
        rate = int.parse(getCartData[i].tax_rate);
      } else {
        rate = 0;
      }
      double total = (rate / 100) * ttlprice;
      ttlRate = ttlRate + total;
    }
    total = total + ttlRate.toInt();
    return ttlRate.toStringAsFixed(0);
  }
}
