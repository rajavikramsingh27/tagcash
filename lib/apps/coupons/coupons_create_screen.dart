import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/coupons/coupon_merchant_redeem_screen.dart';
import 'package:tagcash/apps/coupons/customer_coupons_screen.dart';
import 'package:tagcash/apps/coupons/models/merchant_coupon.dart';
import 'package:tagcash/apps/coupons/models/role_merchant.dart';
import 'package:tagcash/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/image_select_form_field.dart';
import 'package:location/location.dart';
import 'package:tagcash/apps/coupons/models/customer_coupon.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/components/dialog.dart';

enum PayStatus { paid, free }

class CouponsCreateScreen extends StatefulWidget {
  final MerchantCoupon coupon;

  const CouponsCreateScreen({Key key, this.coupon}) : super(key: key);

  @override
  _CouponsCreateScreenState createState() => _CouponsCreateScreenState();
}

class _CouponsCreateScreenState extends State<CouponsCreateScreen> {
  bool _isLoading = false;
  List<int> _receiptFile;

  final globalKey = GlobalKey<ScaffoldState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  Location location = Location();
  LocationData _locationData;
  bool locationAvailable = false;
  File _csvFile;

  String filePath = '';
  final visibilityItems = {
    '1': 'Visible to All',
    '2': 'Role',
    '3': 'Not Visible'
  };

  String visibility = '1';
  RoleMerchant selectedRole;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final expiryDateController = TextEditingController();
  final totalAvailableController = TextEditingController();
  final userLimitController = TextEditingController();
  final amountController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final radiusController = TextEditingController();
  final userMaxClicksController = TextEditingController();
  final bidController = TextEditingController();
  String roleId;
  Wallet wallet;
  bool _requireCustomersDetails = false;
  bool _selfRedeemable = true;
  bool _setUpVoucherCode = false;
  var expiryDateSelected = '';
  PayStatus payStatus = PayStatus.paid;
  int walletId = 0;
  Future<List<RoleMerchant>> roleListData;
  String imgUrl = null;
  List<dynamic> codes = [];
  String qrCode;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    checkLocation();
    roleListData = roleListLoad();
    if (widget.coupon != null) {
      titleController.text = widget.coupon.title;
      descriptionController.text = widget.coupon.description;
      print(widget.coupon.expiryDate);
      final DateFormat formatterTxt = DateFormat('dd-MM-yyyy');
      DateTime dateTime = DateTime.parse(widget.coupon.expiryDate);
      final String formattedTxt = formatterTxt.format(dateTime);
      expiryDateController.text = formattedTxt;
      expiryDateSelected = widget.coupon.expiryDate;
      totalAvailableController.text = widget.coupon.remainingCoupon.toString();
      if (widget.coupon.totalAvailable == widget.coupon.remainingCoupon)
        _enabled = true;
      else
        _enabled = false;
      userLimitController.text = widget.coupon.userLimit.toString();
      visibility = widget.coupon.visibility.toString();
      if (visibility == "2") {
        roleId = widget.coupon.roleId.toString();
      }
      if (widget.coupon.requireCustomerDetails == 0)
        _requireCustomersDetails = false;
      else
        _requireCustomersDetails = true;
      if (widget.coupon.selfRedeemable == 0)
        _selfRedeemable = false;
      else
        _selfRedeemable = true;
      if (widget.coupon.couponType == "Free")
        payStatus = PayStatus.free;
      else {
        payStatus = PayStatus.paid;
        walletId = widget.coupon.couponWalletId;
        amountController.text = widget.coupon.couponPrice.toString();
      }
      latitudeController.text = widget.coupon.latitude.toString();
      longitudeController.text = widget.coupon.longitude.toString();
      radiusController.text = widget.coupon.radius.toString();
      bidController.text = widget.coupon.payPerClick.toString();
      userMaxClicksController.text = widget.coupon.userMaxClicks.toString();
      if (widget.coupon.imageUrl == "") {
        imgUrl = null;
      } else {
        imgUrl = widget.coupon.imageUrl;
      }
      //codes = json.decode( widget.coupon.codes);
      codes = widget.coupon.codes;
      print("11111" + codes.toString());
      if (codes.length > 0) _setUpVoucherCode = true;

      Map<String, dynamic> qrObj = {};
      qrObj['\"action\"'] = '\"COUPON\"';
      qrObj['\"coupon_id\"'] = '\"' + widget.coupon.id + '\"';
      qrCode = qrObj.toString();
      print("qrobj" + qrCode);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkLocation() async {
    // _isLoading = true;
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData.latitude);
    print(_locationData.longitude);

    setState(() {
      locationAvailable = true;
    });
    latitudeController.text = _locationData.latitude.toString();
    longitudeController.text = _locationData.longitude.toString();
  }

  void statusChangeHandler(PayStatus value) {
    setState(() {
      payStatus = value;
    });
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: Container(
        margin: EdgeInsets.all(10),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(children: [
                Form(
                  key: _formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ImageSelectFormField(
                              icon: Icon(Icons.note),
                              labelText: getTranslated(context, "coupon"),
                              hintText: getTranslated(
                                  context, "please_add_coupon_image"),
                              source: ImageFrom.both,
                              imageURL: imgUrl,
                              crop: true,
                              onChanged: (img) {
                                if (img != null) {
                                  _receiptFile = img;
                                  //_formKey.currentState.validate();
                                }
                              },
                            ),
                            flex: 1,
                          ),
                          if (widget.coupon != null)
                            Expanded(
                              child: QrImage(
                                data: qrCode,
                              ),
                              flex: 1,
                            )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: titleController,
                        enabled: _enabled,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enter_title"),
                          labelText: getTranslated(context, "title"),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(context, "please_enter_title");
                          }
                          if (isNumeric(value)) {
                            return getTranslated(
                                context, "please_dont_enter_a_number_as_title");
                          }
                          return null;
                        },
                      ),
                      SizedBox(width: 10),
                      TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        enabled: _enabled,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enter_description"),
                          labelText: getTranslated(context, "description"),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(
                                context, "please_enter_description");
                          }
                          if (isNumeric(value)) {
                            return getTranslated(context,
                                "please_dont_enter_number_as_description");
                          }
                          return null;
                        },
                      ),
                      SizedBox(width: 10),
                      TextFormField(
                          controller: expiryDateController,
                          decoration: InputDecoration(
                            hintText: getTranslated(context, "expiry_date"),
                            labelText: getTranslated(context, "expiry_date"),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return getTranslated(
                                  context, "please_enter_expiry_date");
                            }
                            return null;
                          },
                          onTap: () async {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              initialDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              print(date);
                              final DateFormat formatterTxt =
                                  DateFormat('dd-MM-yyyy');
                              final String formattedTxt =
                                  formatterTxt.format(date);
                              expiryDateController.text = formattedTxt;
                              final DateFormat formatterVal =
                                  DateFormat('yyyy-MM-dd');
                              final String formattedVal =
                                  formatterVal.format(date);
                              expiryDateSelected = formattedVal;
                            }
                          }),
                      SizedBox(width: 10),
//                      Row(
//                        children: [
//                          Expanded(
//                            child:
                      TextFormField(
                        controller: totalAvailableController,
                        //enabled: _enabled,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: false),
                        decoration: InputDecoration(
                          hintText:
                              getTranslated(context, "enter_total_available"),
                          labelText: getTranslated(context, "total_available"),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(
                                context, "please_enter_total_available");
                          } else if (int.parse(value) <
                              int.parse(userLimitController.text)) {
                            return getTranslated(context,
                                "total_available_should_not_be_less_than_user_limit");
                          }
                          return null;
                        },
                      ),
                      //                     ),
                      SizedBox(height: 10),
//                          Expanded(
//                            child:
                      TextFormField(
                        controller: userLimitController,
                        enabled: _enabled,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: false),
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enter_user_limit"),
                          labelText: getTranslated(context, "user_limit"),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(
                                context, "please_enter_user_limit");
                          } else if (int.parse(totalAvailableController.text) <
                              int.parse(value)) {
                            return getTranslated(context,
                                "total_available_should_not_be_less_than_user_limit");
                          }
                          return null;
                        },
                      ),
                      //),
                      //],
                      //),
                      SizedBox(height: 10),
                      DropdownButtonFormField(
                        value: visibility,
                        items: visibilityItems.entries
                            .map<DropdownMenuItem<String>>(
                                (MapEntry<String, String> e) =>
                                    DropdownMenuItem<String>(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                            .toList(),
                        decoration: InputDecoration(
                          hintText: 'Visible to All',
                          filled: true,
                          errorStyle: TextStyle(color: Colors.yellow),
                        ),
                        onChanged: (value) {
                          setState(() {
                            visibility = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      if (visibility == "2") _getRolesList(),
                      ListTile(
                        trailing: GestureDetector(
                          onTap: () {
                            showSimpleDialog(context,
                                title: getTranslated(
                                    context, "customer_details_needed"),
                                message: getTranslated(
                                    context, "ship_customer_info"));
                          },
                          child: Container(
                            child: Icon(
                              Icons.help_rounded,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        title: CheckboxListTile(
                          //checkColor: Colors.red[600],
                          activeColor: kPrimaryColor,
                          value: _requireCustomersDetails,
                          title: Text(getTranslated(
                              context, "require_customer_details")),

                          onChanged: _enabled
                              ? (bool value) {
                                  setState(() {
                                    _requireCustomersDetails = value;
                                    _selfRedeemable = !value;
//                            widget.onSelectedAnonymousChanged(_anonymousSelected);
                                  });
                                }
                              : null,
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                      ),

                      SizedBox(height: 10),
                      ListTile(
                        trailing: GestureDetector(
                          onTap: () {
                            showSimpleDialog(context,
                                title:
                                    getTranslated(context, "self_redeemable"),
                                message: getTranslated(
                                    context, "user_coupon_redeem"));
                          },
                          child: Container(
                            child: Icon(
                              Icons.help_rounded,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        title: CheckboxListTile(
                          //checkColor: Colors.red[600],
                          activeColor: kPrimaryColor,
                          value: _selfRedeemable,
                          title:
                              Text(getTranslated(context, "self_redeemable")),
                          onChanged: _enabled
                              ? (bool value) {
                                  setState(() {
                                    _selfRedeemable = value;
                                    _requireCustomersDetails = !value;
//                            widget.onSelectedAnonymousChanged(_anonymousSelected);
                                  });
                                }
                              : null,
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        getTranslated(context, "coupon_price"),
                        style: TextStyle(
                          //color: kPrimaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Radio(
                            value: PayStatus.paid,
                            groupValue: payStatus,
                            onChanged: _enabled ? statusChangeHandler : null,
                          ),
                          Text(
                            getTranslated(context, "paid"),
                          ),
                          Radio(
                            value: PayStatus.free,
                            groupValue: payStatus,
                            onChanged: _enabled ? statusChangeHandler : null,
                          ),
                          Text(
                            getTranslated(context, "free"),
                          )
                        ],
                      ),
                      payStatus == PayStatus.paid
                          ? AbsorbPointer(
                              absorbing: !_enabled,
                              child: Row(
                                children: [
                                  WalletListingHeader(
                                      onWalletSelected: (wallet) {
                                        this.wallet = wallet;
                                        print(wallet.walletName);
                                      },
                                      walletId: walletId),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: amountController,
                                      enabled: _enabled,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: false),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(
                                            context, "enter_price"),
                                        labelText:
                                            getTranslated(context, "price"),
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return getTranslated(
                                              context, "please_enter_price");
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      SizedBox(height: 10),
                      ListTile(
                        trailing: GestureDetector(
                          onTap: () {
                            showSimpleDialog(context,
                                title: getTranslated(context, "voucher_codes"),
                                message: getTranslated(context,
                                    "codes_can_be_created_or_imported_and_given_away_or_sold_to_customer"));
                          },
                          child: Container(
                            child: Icon(
                              Icons.help_rounded,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        title: CheckboxListTile(
                          //checkColor: Colors.red[600],
                          activeColor: kPrimaryColor,
                          value: _setUpVoucherCode,
                          title: Text(
                              getTranslated(context, "setup_voucher_code")),
                          onChanged: _enabled
                              ? (bool value) {
                                  setState(() {
                                    _setUpVoucherCode = value;
                                  });
                                }
                              : null,
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                      ),
                      SizedBox(height: 10),
                      _setUpVoucherCode
                          ? SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                child: Text(getTranslated(context, "add_code")),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _SetupVoucherCodeDialog(
                                          codes: codes,
                                          onSuccess: (value) {
                                            codes = value;
                                            if (codes.length !=
                                                widget.coupon.totalAvailable) {
                                              final snackBar = SnackBar(
                                                  content: Text(getTranslated(
                                                      context,
                                                      "the_number_of_voucher_codes_should_be_the_same_as_total_available")),
                                                  duration: const Duration(
                                                      seconds: 3));
                                              globalKey.currentState
                                                  .showSnackBar(snackBar);
                                            }
                                          },
                                          onFailure: (value) {},
                                          onFileSuccess: (value) {
                                            filePath = value;
                                          },
                                        );
                                      });
                                },
                              ),
                            )
                          : SizedBox(),
                      //SizedBox(height: 10),
                    ],
                  ),
                ),
                Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        trailing: GestureDetector(
                          onTap: () {
                            showSimpleDialog(context,
                                title: getTranslated(
                                    context, "bidding_for_viewing_placement"),
                                message: getTranslated(
                                    context, "coupons_module_info"));
                          },
                          child: Container(
                            child: Icon(
                              Icons.help_rounded,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        title: Text(
                          getTranslated(context, "pay_per_click_coupon"),
                          style: TextStyle(
                            //color: kPrimaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: latitudeController,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "latitude"),
                                labelText: getTranslated(context, "latitude"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "enter_location");
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: longitudeController,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "longitude"),
                                labelText: getTranslated(context, "longitude"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "enter_location");
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: radiusController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "radius"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "please_enter_radius");
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text(
                              getTranslated(context, "calculate_current_bid")),
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.grey[300]
                              : Colors.black,
                          textColor:
                              Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                          onPressed: () {
                            if (_formKey2.currentState.validate())
                              getHighestBidHandler();
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Form(
                  key: _formKey3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: bidController,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "bid_amount"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "please_enter_bid");
                                } else if (int.parse(value) <= 0) {
                                  return getTranslated(
                                      context, "bid_amount_greater_than_0");
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'TAG',
                              style: TextStyle(
                                //color: kPrimaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: userMaxClicksController,
                              enabled: _enabled,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText:
                                    getTranslated(context, "user_max_clicks"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "please_enter_user_max_clicks");
                                } else if (int.parse(value) <= 0) {
                                  return getTranslated(context,
                                      "user_maximum_clicks_should_be_greater_than_0");
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
//                      GestureDetector(
//                        onTap: () => selectFileClicked(),
//                        child: Container(
//                          child: Icon(
//                            Icons.add_circle_sharp,
//                            size: 18,
//                            color: kPrimaryColor,
//                          ),
//                        ),
//                      ),
                      (widget.coupon != null)
                          ? Row(
                              children: [
                                Expanded(
                                  child: RaisedButton(
                                    child:
                                        Text(getTranslated(context, "delete")),
                                    color: Provider.of<ThemeProvider>(context)
                                            .isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.black,
                                    textColor:
                                        Provider.of<ThemeProvider>(context)
                                                .isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                    onPressed: () {
                                      deleteCouponHandler(null);
                                    },
                                  ),
                                  flex: 1,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: RaisedButton(
                                    child:
                                        Text(getTranslated(context, "update")),
                                    color: kPrimaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      if (_formKey1.currentState.validate() &&
                                          _formKey2.currentState.validate() &&
                                          _formKey3.currentState.validate())
                                        saveCouponHandler();
                                    },
                                  ),
                                  flex: 1,
                                ),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                child: Text(getTranslated(context, "save")),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  if (_formKey1.currentState.validate() &&
                                      _formKey2.currentState.validate() &&
                                      _formKey3.currentState.validate())
                                    saveCouponHandler();
                                },
                              ),
                            ),
                    ],
                  ),
                )
              ]),
            ),
            _isLoading
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: Loading()))
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  saveCouponHandler() async {
    print("getHighestBidHandler");
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['title'] = titleController.text.toString();
    apiBodyObj['description'] = descriptionController.text.toString();
    apiBodyObj['expiry_date'] = expiryDateSelected;
    apiBodyObj['total_available'] = totalAvailableController.text.toString();
    apiBodyObj['user_limit'] = userLimitController.text.toString();
    apiBodyObj['visibility'] = visibility.toString();
    if (visibility == "2") apiBodyObj['role_id'] = roleId;
    apiBodyObj['redeemby'] = "merchant";
    if (_requireCustomersDetails)
      apiBodyObj['require_customer_details'] = "1";
    else
      apiBodyObj['require_customer_details'] = "0";
    if (_selfRedeemable)
      apiBodyObj['self_redeemable'] = "1";
    else
      apiBodyObj['self_redeemable'] = "0";
    if (payStatus == PayStatus.paid) {
      apiBodyObj['coupon_type'] = "Paid";
      Map<String, dynamic> map = {
        'walletid': wallet.walletId.toString(),
        'price': amountController.text.toString(),
        'currency_code': wallet.currencyCode,
      };
      List currencyItems = [];
      currencyItems.add(map);
      String rawJson = jsonEncode(currencyItems);
      apiBodyObj['price'] = rawJson;
      apiBodyObj['coupon_wallet_id'] = wallet.walletId.toString();
      apiBodyObj['coupon_price'] = amountController.text.toString();
    } else
      apiBodyObj['coupon_type'] = "Free";
    apiBodyObj['user_max_clicks'] = userMaxClicksController.text.toString();
    apiBodyObj['pay_per_click'] = bidController.text.toString();
    apiBodyObj['pay_per_wallet_id'] = "7";
    if (_setUpVoucherCode) {
      List<String> c = [];
      for (int i = 0; i < codes.length; i++) {
        c.add('"' + codes[i].toString() + '"');
      }
      apiBodyObj['codes'] = c.toString();
    }
    apiBodyObj['latitude'] = latitudeController.text.toString();
    apiBodyObj['longitude'] = longitudeController.text.toString();
    apiBodyObj['radius'] = radiusController.text.toString();
    Map<String, dynamic> response;
    if (widget.coupon == null)
      response = await NetworkHelper.request('coupon/create', apiBodyObj);
    else {
      apiBodyObj['update_id'] = widget.coupon.id;
      response = await NetworkHelper.request('coupon/update', apiBodyObj);
    }
    print(response);
    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });
      String id;
      if (widget.coupon == null)
        id = response['result']['coupon']['_id']['\$id'];
      else
        id = widget.coupon.id;
      print("Coupon ID" + id);
      if (widget.coupon == null) {
        if (_receiptFile != null) {
          uploadImage(id);
        } else {
          if (filePath != '') {
            uploadDoc(filePath, id);
          } else {
            Navigator.of(context).pop({'status': 'createSuccess'});
          }
        }
      } else {
        if (_receiptFile != null) {
          uploadImage(id);
        } else {
          if (filePath != '') {
            uploadDoc(filePath, id);
          } else {
            Navigator.of(context).pop({'status': 'updateSuccess'});
          }
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      String err;
      if (response['error'] == "Insufficient balance") {
        err = getTranslated(
            context, "you_have_insufficient_balance_in_the_wallet");
      } else if (response['error'] ==
          "merchant_account_does_not_have_sufficient_balance_to_pay_php_or_tag") {
        err = getTranslated(
            context, "you_have_insufficient_balance_in_the_wallet");
      } else if (response['error'] ==
          "expiry_date_should_be_grether_than_current_date_time") {
        err = getTranslated(
            context, "expiry_date_should_be_greater_than_current_date");
      } else if (response['error'] == "update_id_is_required") {
        err = getTranslated(context, "update_id_is_required");
      } else if (response['error'] == "failed_to_update_the_coupon") {
        err = getTranslated(context, "failed_to_update_the_coupon");
      } else if (response['error'] == "title_is_required") {
        err = getTranslated(context, "title_is_required");
      } else if (response['error'] == "description_is_required") {
        err = getTranslated(context, "description_is_required");
      } else if (response['error'] == "coupon_type_is_required") {
        err = getTranslated(context, "coupon_type_is_required");
      } else if (response['error'] == "coupon_price_is_required") {
        err = getTranslated(context, "coupon_price_is_required");
      } else if (response['error'] == "coupon_wallet_id_is_required") {
        err = getTranslated(context, "coupon_wallet_id_is_required");
      } else if (response['error'] == "price_is_required") {
        err = getTranslated(context, "price_is_required");
      } else if (response['error'] == "expiry_date_is_required") {
        err = getTranslated(context, "expiry_date_is_required");
      } else if (response['error'] == "total_available_is_required") {
        err = getTranslated(context, "total_available_is_required");
      } else if (response['error'] == "user_limit_is_required") {
        err = getTranslated(context, "user_limit_is_required");
      } else if (response['error'] == "visibility_is_required") {
        err = getTranslated(context, "visibility_is_required");
      } else if (response['error'] == "redeemby_is_required") {
        err = getTranslated(context, "redeem_by_is_required");
      } else if (response['error'] == "latitude_is_required") {
        err = getTranslated(context, "latitude_is_required");
      } else if (response['error'] == "longitude_is_required") {
        err = getTranslated(context, "longitude_is_required");
      } else if (response['error'] == "radius_is_required") {
        err = getTranslated(context, "radius_is_required");
      } else if (response['error'] == "self_redeemable_is_required") {
        err = getTranslated(context, "self_redeemable_is_required");
      } else if (response['error'] == "self_redeemable_should_be_0_or_1") {
        err = getTranslated(context, "self_redeemable_is_invalid");
      } else if (response['error'] == "require_customer_details_is_required") {
        err = getTranslated(context, "require_customer_details_is_required");
      } else if (response['error'] ==
          "require_customer_details_should_be_0_or_1") {
        err = getTranslated(context, "require_customer_details_is_invalid");
      } else if (response['error'] == "pay_per_wallet_id_is_required") {
        err = getTranslated(context, "bid_wallet_id_is_required");
      } else if (response['error'] == "pay_per_click_is_required") {
        err = getTranslated(context, "bid_amount_is_required");
      } else if (response['error'] == "user_max_clicks_should_be_numeric") {
        err = getTranslated(context, "user_maximum_clicks_should_be_numeric");
      } else if (response['error'] ==
          "user_max_clicks_should_be_grether_than_1") {
        err = getTranslated(
            context, "user_maximum_clicks_should_be_greater_than_0");
      } else if (response['error'] == "coupon_id_does_not_exist") {
        err = getTranslated(context, "coupon_id_does_not_exist");
      } else if (response['error'] == "only_the_owner_can_update_the_data") {
        err = getTranslated(context, "only_the_owner_can_update_the_data");
      } else if (response['error'] ==
          "total_available_is_grether_than_array_count") {
        err = getTranslated(context,
            "the_number_of_voucher_codes_should_be_the_same_as_total_available");
      } else if (response['error'] ==
          "total_available_should_be_equal_to_voucher_array_count") {
        err = getTranslated(context, "codes_should_be_unique");
      } else if (response['error'] == "codes_array_is_not_unique") {
        err = getTranslated(context, "coupon_id_is_required");
      } else
        err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  deleteCouponHandler(String id) async {
    print("deleteCouponHandler");
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    if (id != null)
      apiBodyObj['coupon_id'] = id;
    else
      apiBodyObj['coupon_id'] = widget.coupon.id;
    Map<String, dynamic> response =
        await NetworkHelper.request('Coupon/DeleteCoupon', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });
      if (id != null)
        Navigator.of(context)
            .pop({'status': 'deleteSuccess', 'hasVoucherCode': 'true'});
      else
        Navigator.of(context)
            .pop({'status': 'deleteSuccess', 'hasVoucherCode': 'false'});
    } else {
      setState(() {
        _isLoading = false;
      });
      String err;
      if (response['error'] == "coupon_id_is_required") {
        err = getTranslated(context, "coupon_id_is_required");
      } else if (response['error'] == "coupon_already_sold_cannot_delete") {
        err = getTranslated(
            context, "coupon_already_started_purchasing_cannot_delete");
      } else if (response['error'] == "failed_to_delete_the_coupon") {
        err = getTranslated(context, "failed_to_delete_the_coupon");
      } else if (response['error'] == "coupon_details_not_found") {
        err = getTranslated(context, "coupon_details_not_found");
      } else if (response['error'] == "permission_denied") {
        err = getTranslated(context, "permission_denied_to_delete_the_coupon");
      } else if (response['error'] == "coupon_already_deleted") {
        err = getTranslated(context, "coupon_already_deleted");
      } else if (response['error'] ==
          "failed_to_delete_ticket_from_coupon_location_details") {
        err = getTranslated(context, "coupon_already_sold_cannot_delete");
      } else if (response['error'] == "coupon_already_sold_cannot_delete") {
        err = getTranslated(context, "coupon_already_sold_cannot_delete");
      } else
        err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  uploadImage(String id) async {
    setState(() {
      _isLoading = true;
    });

    var apiBodyObj = {};
    apiBodyObj['coupon_id'] = id;
    apiBodyObj['file_data'] = base64Encode(_receiptFile);

    Map<String, dynamic> response =
        await NetworkHelper.request('Coupon/UploadCouponImage', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });
      if (widget.coupon == null) {
        if (filePath != '') {
          uploadDoc(filePath, id);
        } else {
          Navigator.of(context).pop({'status': 'createSuccess'});
        }
      } else
        Navigator.of(context).pop({'status': 'updateSuccess'});
    } else {
      setState(() {
        _isLoading = false;
      });
      String err;
      if (response['error'] == "coupon_id_is_required") {
        err = getTranslated(context, "coupon_id_is_required");
      } else if (response['error'] == "file_data_is_required") {
        err = getTranslated(context, "file_data_is_required");
      } else if (response['error'] == "failed_to_upload_the_file") {
        err = getTranslated(context, "failed_to_upload_the_file");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] ==
          "only_the_owner_can_upload_file_under_this_coupon_id") {
        err = getTranslated(context, "only_the_owner_can_upload_image");
      }
    }
  }

  uploadDoc(String filePath, String id) async {
    setState(() {
      _isLoading = true;
    });
    String basename = path.basename(filePath);
    Map<String, dynamic> fileData;
    fileData = {};
    fileData['key'] = 'csv_file';
    fileData['fileName'] = basename;
    fileData['path'] = filePath;
    Map<String, String> apiBodyObj = {};
    apiBodyObj['coupon_id'] = id;

    Map<String, dynamic> response =
        await NetworkHelper.request('Coupon/CSVUpload', apiBodyObj, fileData);

    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });
      if (widget.coupon == null)
        Navigator.of(context).pop({'status': 'createSuccess'});
      else
        Navigator.of(context).pop({'status': 'updateSuccess'});
    } else {
      setState(() {
        _isLoading = false;
      });
      String err;
      if (response['error'] == "coupon_id_is_required") {
        err = getTranslated(context, "coupon_id_is_required");
      } else if (response['error'] == "codes_array_is_not_unique") {
        err = getTranslated(context, "codes_should_be_unique");
      } else if (response['error'] == "failed_to_update_the_coupon") {
        err = getTranslated(context, "failed_to_update_the_coupon");
      } else if (response['error'] == "coupon_id_does_not_exist") {
        err = getTranslated(context, "coupon_id_does_not_exist");
      } else if (response['error'] ==
          "total_available_should_be_equal_to_voucher_array_count") {
        err = getTranslated(context,
            "the_number_of_voucher_codes_should_be_the_same_as_total_available");
      } else if (response['error'] == "you_should_upload_csv_file_or_codes") {
        err = getTranslated(context, "you_should_upload_csv_files_or_codes");
      } else if (response['error'] == "only_the_owner_can_update_the_data") {
        err = getTranslated(context, "only_the_owner_can_update_the_data");
      } else if (response['error'] == "purchased_coupon_cannot_update") {
        err = getTranslated(context, "purchased_coupon_cannot_update");
      } else
        err = response['error'];

      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);

      if (widget.coupon == null) deleteCouponHandler(id);
    }
  }

  getHighestBidHandler() async {
    print("getHighestBidHandler");
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lat'] = latitudeController.text.toString();
    apiBodyObj['lng'] = longitudeController.text.toString();
    apiBodyObj['radius'] = radiusController.text.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('coupon/GetHighestBidAmount', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });
      bidController.text = response['next_bid_value'].toString();
    } else {
      setState(() {
        _isLoading = false;
      });
      String err;
      if (response['error'] == "lat_is_required") {
        err = getTranslated(context, "latitude_is_required");
      } else if (response['error'] == "lng_is_required") {
        err = getTranslated(context, "longitude_is_required");
      } else if (response['error'] == "radius_is_required") {
        err = getTranslated(context, "radius_is_required");
      } else if (response['error'] == "failed") {
        err = getTranslated(context, "failed_to_get_bid_amount");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else
        err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<List<RoleMerchant>> roleListLoad() async {
    print('roleListLoad');
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['community_id'] =
        Provider.of<MerchantProvider>(context, listen: false)
            .merchantData
            .id
            .toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('community/GetAllRoles', apiBodyObj);
    List responseList = response['result'];

    List<RoleMerchant> getData = responseList.map<RoleMerchant>((json) {
      return RoleMerchant.fromJson(json);
    }).toList();
    if (visibility == "2") {
      for (RoleMerchant r in getData) {
        if (r.id.toString() == roleId) selectedRole = r;
      }
    }
    return getData;
  }

  Widget _getRolesList() {
    return FutureBuilder(
        future: roleListData,
        builder:
            (BuildContext context, AsyncSnapshot<List<RoleMerchant>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<RoleMerchant>(
                  isExpanded: true,
                  hint: Text(getTranslated(context, "select_role")),
                  value: selectedRole,
                  onChanged: (RoleMerchant value) {
                    setState(() {
                      roleId = value.id.toString();
//            selectedWallet = Value;
//            widget.onWalletSelected(selectedWallet);
                    });
                  },
                  items: snapshot.data.map((RoleMerchant role) {
                    return DropdownMenuItem<RoleMerchant>(
                      value: role,
                      child: Text(role.roleName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }
}

class WalletListingHeader extends StatefulWidget {
  WalletListingHeader({this.onWalletSelected, this.walletId});

  ValueChanged<Wallet> onWalletSelected;
  int walletId;

  @override
  _WalletListingHeaderState createState() => _WalletListingHeaderState();
}

class _WalletListingHeaderState extends State<WalletListingHeader> {
  Future<List<Wallet>> walletsListData;
  int walletCardIndex = 0;
  Wallet selectedWallet;

  @override
  void initState() {
    super.initState();
    walletsListData = allWalletListLoad();
  }

  Future<List<Wallet>> allWalletListLoad() async {
    print('allWalletListLoad');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';
    //apiBodyObj['wallet_type'] = '[0,1,3]';

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/list', apiBodyObj);

    print('got walletsListData');
    List responseList = response['result'];

    List<Wallet> getData = responseList.map<Wallet>((json) {
      return Wallet.fromJson(json);
    }).toList();
    if (widget.walletId > 0) {
      for (Wallet w in getData) {
        if (w.walletId == widget.walletId) {
          selectedWallet = w;
          print("Loool");
          widget.onWalletSelected(selectedWallet);
        }
      }
    }
    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: walletsListData,
          builder:
              (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            // print(snapshot.data);

            return snapshot.hasData
                ? DropdownButton<Wallet>(
                    hint: Text(getTranslated(context, "select_wallet")),
                    value: selectedWallet,
                    onChanged: (Wallet Value) {
                      setState(() {
                        selectedWallet = Value;
                        widget.onWalletSelected(selectedWallet);
                      });
                    },
                    items: snapshot.data.map((Wallet wallet) {
                      return DropdownMenuItem<Wallet>(
                        value: wallet,
                        child: Text(wallet.currencyCode),
                      );
                    }).toList(),
                  )
                : Container();
          }),
    );
  }
}

class _SetupVoucherCodeDialog extends StatefulWidget {
  _SetupVoucherCodeDialog(
      {this.codes, this.onSuccess, this.onFailure, this.onFileSuccess});

  //String couponId;
  ValueChanged<List<dynamic>> onSuccess;
  ValueChanged<String> onFailure;
  ValueChanged<String> onFileSuccess;
  List<dynamic> codes;

  @override
  _SetupVoucherCodeDialogState createState() => _SetupVoucherCodeDialogState();
}

class _SetupVoucherCodeDialogState extends State<_SetupVoucherCodeDialog> {
  //String couponId;
  final _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();

  //List<dynamic> codes = [];
  bool isLoading = false;

  @override
  void initState() {
    //couponId = widget.couponId;
    super.initState();
    //codes = widget.codes;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        getTranslated(context, "setup_voucher_code"),
        style: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: kPrimaryColor),
      ),
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            right: -40.0,
            top: -80.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: kPrimaryColor,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: codeController,
                          decoration: InputDecoration(
                            hintText:
                                getTranslated(context, "enter_code_manually"),
                            labelText: getTranslated(context, "enter_code"),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return getTranslated(
                                  context, "enter_currency_code");
                            }
                            return null;
                          },
                        ),
                        flex: 8,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: RaisedButton(
                          child: Text("+"),
                          color: kPrimaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              if (codeController.text.length > 0) {
                                widget.codes.add(codeController.text);
                                codeController.text = "";
                              }
                            });
                          },
                        ),
                        flex: 2,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectFileClicked(),
                          child: Positioned.fill(
                            child: Container(
                              color: kPrimaryColor,
                              child: Center(
                                child: Icon(
                                  Icons.upload_file,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        flex: 2,
                      ),
                    ],
                  ),
                  Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          //padding: const EdgeInsets.all(8),
                          itemCount: widget.codes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CodeItem(widget.codes[index].toString(),
                                onDelete: () => removeItem(index));
                          })),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      child: Text(getTranslated(context, "done")),
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onSuccess(widget.codes);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectFileClicked() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    print(result.files.single.path);
    Navigator.of(context).pop();
    widget.onFileSuccess(result.files.single.path);
  }

  void removeItem(int index) {
    setState(() {
      //print("hiiii"+index.toString());
      widget.codes.removeAt(index);
    });
  }
}

class CodeItem extends StatelessWidget {
  final String title;
  final VoidCallback onDelete;

  CodeItem(this.title, {this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: kPrimaryColor,
              iconSize: 24,
              tooltip: getTranslated(context, "delete"),
              onPressed: this.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
