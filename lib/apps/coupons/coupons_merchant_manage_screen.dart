import 'package:tagcash/apps/coupons/coupons_create_screen.dart';
import 'package:tagcash/apps/coupons/customer_coupons_screen.dart';
import 'package:tagcash/apps/coupons/models/merchant_coupon.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

enum PayStatus { paid, free }

class CouponsMerchantManageScreen extends StatefulWidget {
  final MerchantCoupon coupon;

  const CouponsMerchantManageScreen({Key key, this.coupon}) : super(key: key);

  @override
  _CouponsMerchantManageScreen createState() => _CouponsMerchantManageScreen();
}

class _CouponsMerchantManageScreen extends State<CouponsMerchantManageScreen> {
  @override
  Widget build(BuildContext context) {
    return (widget.coupon != null)
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppTopBar(
                title: getTranslated(context, "coupons"),
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      Tab(text: getTranslated(context, "details")),
                      Tab(text: getTranslated(context, "customers")),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  CouponsCreateScreen(coupon: widget.coupon),
                  CustomerCouponsScreen(coupon: widget.coupon),
                ],
              ),
            ),
          )
        : Container(
            child: Scaffold(
              appBar: AppTopBar(
                appBar: AppBar(),
                title: getTranslated(context, "coupons"),
              ),
              body: CouponsCreateScreen(),
            ),
          );
  }
}
