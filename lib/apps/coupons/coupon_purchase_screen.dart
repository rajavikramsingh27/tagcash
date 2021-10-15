import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/coupons/models/coupon.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tagcash/localization/language_constants.dart';

class CouponPurchaseScreen extends StatefulWidget {
  final Coupon coupon;

  const CouponPurchaseScreen({Key key, this.coupon}) : super(key: key);

  @override
  _CouponPurchaseScreenState createState() => _CouponPurchaseScreenState();
}

class _CouponPurchaseScreenState extends State<CouponPurchaseScreen> {
  //Future<List<LendTransaction>> transactionsListData;

  bool _isChecked = false;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  Map<String, dynamic> qrObj = {};

  @override
  void initState() {
    super.initState();
    qrObj['\"action\"'] = '\"COUPON\"';
    qrObj['\"coupon_id\"'] = '\"' + widget.coupon.id + '\"';
    print(qrObj.toString());
    clickHandler(widget.coupon.id);
    //transactionsListData = transactionsListLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "coupons"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
//                  Divider(color: Colors.black),

                  widget.coupon.imageUrl != ""
                      ? SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.network(
                              widget.coupon.imageUrl,
                              height: 300.0,
                              //width: 48.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: Container(
                            height: 300.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[400],
                                shape: BoxShape.rectangle),
                          ),
                        ),
                  SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _PurchaseDialog(
                                  coupon: widget.coupon,
                                  onSuccess: (value) {
//                                    final snackBar = SnackBar(
//                                        content: Text("Coupon purchased successfully."),
//                                        duration: const Duration(seconds: 3));
//                                    globalKey.currentState
//                                        .showSnackBar(snackBar);
                                    Navigator.of(context)
                                        .pop({'status': 'purchaseSuccess'});
                                  },
                                  onFailure: (value) {
                                    final snackBar = SnackBar(
                                        content: Text(value),
                                        duration: const Duration(seconds: 3));
                                    globalKey.currentState
                                        .showSnackBar(snackBar);
                                  });
                            });
                      },
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      color: kPrimaryColor,
                      child: (widget.coupon.couponType == "Free")
                          ? Text(getTranslated(context, "activate_this_coupon"),
                              style: TextStyle(fontSize: 16))
                          : Text(getTranslated(context, "buy_this_coupon"),
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.coupon.title,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.coupon.ownerName,
                    maxLines: 2,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  (widget.coupon.couponType == "Free")
                      ? Text(
                          getTranslated(context, "free_upper"),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700]),
                        )
                      : Text(
                          widget.coupon.couponCurrencyCode +
                              "    " +
                              widget.coupon.couponPrice.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  SizedBox(height: 20),
                  QrImage(
                    data: qrObj.toString(),
                    size: 150,
                  ),
                  SizedBox(height: 30),
                  Text(
                    widget.coupon.description,
                    maxLines: 5,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 20),
                  Text(
                    getTranslated(context, "expires") +
                        " " +
                        widget.coupon.expiryDate,
                    style: TextStyle(fontSize: 14, color: kPrimaryColor),
                  ),
                ],
              ),
              isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: Loading()))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  clickHandler(String couponId) async {
    print("clickHandler");

    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['coupon_id'] = couponId;

    Map<String, dynamic> response =
        await NetworkHelper.request('coupon/ClickCouponId', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
    } else {}
  }
}

class _PurchaseDialog extends StatefulWidget {
  _PurchaseDialog({this.coupon, this.onSuccess, this.onFailure});

  Coupon coupon;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  @override
  _PurchaseDialogState createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<_PurchaseDialog> {
//  bool _anonymousSelected = false;
//  String requestId;
//  Wallet wallet;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final commentsController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
//    _anonymousSelected = widget.setAnonymousSelected;
//    requestId = widget.requestId;
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: (widget.coupon.couponType == "Free")
          ? Text(
              getTranslated(context, "activate_coupon"),
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: kPrimaryColor),
            )
          : Text(
              getTranslated(context, "buy_coupon"),
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
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.coupon.title,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 15),
                  Text(
                    widget.coupon.description,
                    maxLines: 5,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.red[500], size: 16),
                      SizedBox(width: 3),
                      Text(widget.coupon.expiryDate),
                    ],
                  ),
                  SizedBox(height: 15),
                  (widget.coupon.couponType == "Free")
                      ? Text(
                          getTranslated(context, "free_upper"),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700]),
                        )
                      : Text(
                          widget.coupon.couponCurrencyCode +
                              "    " +
                              widget.coupon.couponPrice.toString(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  SizedBox(height: 15),
                  (widget.coupon.requireCustomerDetails == 1)
                      ? Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText:
                                      getTranslated(context, "enter_full_name"),
                                  labelText:
                                      getTranslated(context, "full_name"),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return getTranslated(
                                        context, "please_enter_full_name");
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText:
                                      getTranslated(context, "enter_email"),
                                  labelText: getTranslated(context, "email"),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return getTranslated(
                                        context, "please_enter_email");
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: mobileController,
                                decoration: InputDecoration(
                                  hintText:
                                      getTranslated(context, "enter_mobile"),
                                  labelText: getTranslated(context, "mobile"),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return getTranslated(
                                        context, "please_enter_mobile");
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  hintText:
                                      getTranslated(context, "enter_address"),
                                  labelText: getTranslated(context, "address"),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return getTranslated(
                                        context, "please_enter_address");
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: commentsController,
                                decoration: InputDecoration(
                                  hintText:
                                      getTranslated(context, "enter_comments"),
                                  labelText: getTranslated(context, "comments"),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        if (widget.coupon.requireCustomerDetails == 1) {
                          if (_formKey.currentState.validate()) {
                            purchaseHandler(
                                widget.coupon.id,
                                widget.coupon.requireCustomerDetails,
                                widget.coupon.couponCurrencyCode,
                                nameController.text,
                                emailController.text,
                                mobileController.text,
                                addressController.text,
                                commentsController.text);
                          }
                        } else {
                          purchaseHandler(
                              widget.coupon.id,
                              widget.coupon.requireCustomerDetails,
                              "",
                              "",
                              "",
                              "",
                              "",
                              "");
                        }
                      },
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      color: kPrimaryColor,
                      child: (widget.coupon.couponType == "Free")
                          ? Text(getTranslated(context, "activate"),
                              style: TextStyle(fontSize: 16))
                          : Text(getTranslated(context, "buy"),
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Loading()),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  purchaseHandler(
      String couponId,
      int needCustomerDetails,
      String currencyCode,
      String name,
      String email,
      String mobile,
      String address,
      String comments) async {
    print("purchaseHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['coupon_id'] = couponId;
    apiBodyObj['total_number'] = "1";
    if (needCustomerDetails == 1) {
      apiBodyObj['name'] = name;
      apiBodyObj['email'] = email;
      apiBodyObj['mobile_no'] = mobile;
      apiBodyObj['address'] = address;
      apiBodyObj['additional_comments'] = comments;
    }
    Map<String, dynamic> response =
        await NetworkHelper.request('coupon/purchasecoupon', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess("success");
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      String err;
      if (response['error'] == "coupon_id_is_required") {
        err = getTranslated(context, "coupon_id_required");
      } else if (response['error'] ==
          "insufficient_balance_to_pay_this_amount") {
        err = "You have insufficient " + currencyCode + " in your account..";
      } else if (response['error'] == "switch_to_user_perspective") {
        err = getTranslated(context, "switch_to_user_perspective");
      } else if (response['error'] == "coupon_not_found") {
        err = getTranslated(context, "coupon_not_found");
      } else if (response['error'] == "name_is_required") {
        err = getTranslated(context, "name_is_required");
      } else if (response['error'] == "mobile_no_is_required") {
        err = getTranslated(context, "mobile_no_is_required");
      } else if (response['error'] == "address_is_required") {
        err = getTranslated(context, "address_is_required");
      } else if (response['error'] == "total_number_is_required") {
        err = getTranslated(context, "total_number_required");
      } else if (response['error'] ==
          "total_number_should_be_grether_than_total_available") {
        err = getTranslated(context, "coupon_unavailable");
      } else if (response['error'] == "exceeded_the_limit") {
        err = getTranslated(
            context, "you_have_exceeded_the_maximum_purchase_limit");
      } else if (response['error'] == "user_limit_exceeded") {
        err = getTranslated(
            context, "you_have_exceeded_the_maximum_purchase_limit");
      } else if (response['error'] ==
          "current_date_should_be_less_than_expiry_date") {
        err = getTranslated(
            context, "current_date_should_be_less_than_expiry_date");
      } else if (response['error'] == "failed") {
        err = getTranslated(context, "failed_to_purchase_coupon");
      } else if (response['error'] == "permission_denied") {
        err =
            getTranslated(context, "permission_denied_to_purchase_this_coupon");
      } else if (response['error'] == "role_is_not_exist") {
        err = getTranslated(
            context, "you_dont_have_permission_to_purchase_this_coupon");
      } else {
        err = getTranslated(context, "error_occurred");
      }
      widget.onFailure(err);
    }
  }
}
