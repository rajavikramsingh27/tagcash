import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagcash/apps/coupons/models/customer_coupon.dart';
import 'package:tagcash/apps/coupons/models/merchant_coupon.dart';
import 'package:tagcash/apps/coupons/models/purchased_coupon.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tagcash/localization/language_constants.dart';

class CouponMerchantRedeemScreen extends StatefulWidget {
  final CustomerCoupon coupon;

  const CouponMerchantRedeemScreen({Key key, this.coupon}) : super(key: key);

  @override
  _CouponMerchantRedeemScreenState createState() =>
      _CouponMerchantRedeemScreenState();
}

class _CouponMerchantRedeemScreenState
    extends State<CouponMerchantRedeemScreen> {
  //Future<List<LendTransaction>> transactionsListData;

  bool _isMerchant = false;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  int redeemStatus = 0;
  int requireCustomerDetails = 0;
  int selfRedeemable = 0;
  Map<String, dynamic> qrObj = {};

  @override
  void initState() {
    super.initState();
    qrObj['\"action\"'] = '\"COUPON\"';
    qrObj['\"coupon_id\"'] = '\"' + widget.coupon.id + '\"';
    redeemStatus = widget.coupon.redeemStatus;
    requireCustomerDetails = widget.coupon.requireCustomerDetails;
    selfRedeemable = widget.coupon.selfRedeemable;
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      _isMerchant = false;
    } else
      _isMerchant = true;
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

                  if (requireCustomerDetails == 1 &&
                      widget.coupon.redeemStatus == 1)
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {},
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10.0),
                        color: Colors.black,
                        child: Text(getTranslated(context, "finished"),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  if (requireCustomerDetails == 1 &&
                      widget.coupon.redeemStatus == 0)
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          if (_isMerchant) redeemHandler(widget.coupon.id);
                        },
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10.0),
                        color: Colors.green[700],
                        child: (_isMerchant)
                            ? Text(getTranslated(context, "finish"),
                                style: TextStyle(fontSize: 16))
                            : Text(getTranslated(context, "processing"),
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  if (selfRedeemable == 1 && widget.coupon.redeemStatus == 1)
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {},
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10.0),
                        color: Colors.black,
                        child: Text(getTranslated(context, "redeemed"),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  if (selfRedeemable == 1 && widget.coupon.redeemStatus == 0)
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          redeemHandler(widget.coupon.id);
                        },
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10.0),
                        color: Colors.green[700],
                        child: Text(getTranslated(context, "click_to_redeem"),
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
                  (widget.coupon.couponCurrencyCode != '')
                      ? Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              getTranslated(context, "voucher_code") +
                                  ": " +
                                  widget.coupon.voucherCode.toString(),
                              style:
                                  TextStyle(fontSize: 14, color: kPrimaryColor),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.copy_outlined),
                                    color: kPrimaryColor,
                                    onPressed: () => copyClicked(),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share),
                                    color: kPrimaryColor,
                                    onPressed: () => shareClicked(),
                                  ),
                                ]),
                          ],
                        )
                      : Container(),
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

  void copyClicked() {
    Clipboard.setData(
        ClipboardData(text: widget.coupon.voucherCode.toString()));
    final snackBar = SnackBar(
        content: Text(getTranslated(context, "copied_to_clipboard")),
        duration: const Duration(seconds: 3));
    globalKey.currentState.showSnackBar(snackBar);
  }

  void shareClicked() {
    final RenderBox box = context.findRenderObject();
    Share.share(widget.coupon.voucherCode.toString(),
        subject: "Tagcash",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  redeemHandler(String purchaseId) async {
    print("redeemHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['purchase_id'] = purchaseId;

    Map<String, dynamic> response =
        await NetworkHelper.request('coupon/RedeemCoupon', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop({'status': 'redeemSuccess'});
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      String err;
      if (response['error'] == "purchase_id_is_required") {
        err = getTranslated(context, "purchase_id_required");
      } else if (response['error'] == "purchase_details_not_found") {
        err = getTranslated(context, "purchase_details_not_found");
      } else if (response['error'] == "coupon_is_not_self_redeemable") {
        err = getTranslated(context, "coupon_is_not_self_redeemable");
      } else if (response['error'] == "permission_denied") {
        err = getTranslated(context, "permission_denied_to_redeem_this_coupon");
      } else if (response['error'] == "coupon_is_already_redeemed") {
        err = getTranslated(context, "coupon_is_already_redeemed");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "coupon_is_not_self_redeemable") {
        err = getTranslated(context, "coupon_is_not_self_redeemable");
      } else {
        err = getTranslated(context, "failed_to_redeem_coupon");
      }
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}
