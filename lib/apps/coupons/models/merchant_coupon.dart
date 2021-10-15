import 'package:intl/intl.dart';

class MerchantCoupon {
  String id;
  String title;
  String imageUrl;
  String description;
  String expiryDate;
  int totalAvailable;
  int promisedCoupon;
  int remainingCoupon;
  int userLimit;
  int visibility;
  int roleId;
  String redeemBy;
  int status;
  String couponType;
  var couponPrice;
  int couponWalletId;
  String couponCurrencyCode;
  int selfRedeemable;
  var latitude;
  var longitude;
  int radius;
  int userMaxClicks;
  int requireCustomerDetails;
  int payPerWalletId;
  int payPerClick;
  List<dynamic> codes;

  MerchantCoupon({this.id,
    this.title,
    this.imageUrl,
    this.description,
    this.expiryDate,
    this.totalAvailable,
    this.promisedCoupon,
    this.remainingCoupon,
    this.userLimit,
    this.visibility,
    this.roleId,
    this.redeemBy,
    this.status,
    this.couponType,
    this.couponPrice,
    this.couponWalletId,
    this.couponCurrencyCode,
    this.selfRedeemable,
    this.latitude,
    this.longitude,
    this.radius,
    this.userMaxClicks,
    this.requireCustomerDetails,
    this.payPerWalletId,
    this.payPerClick,
    this.codes
  });

  MerchantCoupon.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    imageUrl = json['image_url'];
    description = json['description'];
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var parsedDate = DateTime.parse(json['expiry_date']);
    String formatted = formatter.format(parsedDate);
    expiryDate = formatted;
    totalAvailable = json['total_available'];
    promisedCoupon = json['promised_coupon'];
    remainingCoupon = json['remaining_coupon'];
    userLimit = json['user_limit'];
    visibility = json['visibility'];
    roleId = json['role_id'];
    redeemBy = json['redeemby'];
    status = json['status'];
    couponType = json['coupon_type'];
    couponPrice = json['coupon_price'];
    couponWalletId = json['coupon_wallet_id'];
    couponCurrencyCode = json['coupon_currency_code'];
    selfRedeemable = json['self_redeemable'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
    userMaxClicks = json['user_max_clicks'];
    requireCustomerDetails = json['require_customer_details'];
    payPerWalletId = json['pay_per_wallet_id'];
    payPerClick = json['pay_per_click'];
    codes = json['codes'];
  }
}
