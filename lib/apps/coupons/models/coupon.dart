import 'package:intl/intl.dart';

class Coupon {
  String id;
  String title;
  String imageUrl;
  int ownerId;
  String ownerName;
  String description;
  String expiryDate;
  int totalAvailable;
  int promisedCoupon;
  int remainingCoupon;
  int userLimit;
  int visibility;
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
  var codes;
  String purchaseId;
  int redeemStatus;
  var voucherCode;

  Coupon({this.id,
    this.title,
    this.imageUrl,
    this.ownerId,
    this.ownerName,
    this.description,
    this.expiryDate,
    this.totalAvailable,
    this.promisedCoupon,
    this.remainingCoupon,
    this.userLimit,
    this.visibility,
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
    this.codes,
    this.purchaseId,
    this.redeemStatus,
    this.voucherCode
  });

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    imageUrl = json['image_url'];
    ownerId = json['owner']['id'];
    ownerName = json['owner']['name'];
    description = json['description'];
    DateFormat formatter = DateFormat('d MMM yyyy');
    var parsedDate = DateTime.parse(json['expiry_date']);
    String formatted = formatter.format(parsedDate);
    expiryDate = formatted;
    totalAvailable = json['total_available'];
    promisedCoupon = json['promised_coupon'];
    remainingCoupon = json['remaining_coupon'];
    userLimit = json['user_limit'];
    visibility = json['visibility'];
    redeemBy = json['redeemby'];
    status = json['status'];
    couponType = json['coupon_type'];
    if (json['coupon_wallet_id'] != null)
      couponWalletId = json['coupon_wallet_id'];
    else
      couponWalletId = 0;
    if (json['coupon_price'] != null)
      couponPrice = json['coupon_price'];
    else
      couponPrice = 0;
    if (json['coupon_currency_code'] != null)
      couponCurrencyCode = json['coupon_currency_code'];
    else
      couponCurrencyCode = '';

    selfRedeemable = json['self_redeemable'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
    userMaxClicks = json['user_max_clicks'];
    requireCustomerDetails = json['require_customer_details'];
    payPerWalletId = json['pay_per_wallet_id'];
    payPerClick = json['pay_per_click'];
    codes = json['codes'];
    if (json['purchase_id'] != null)
      purchaseId = json['purchase_id'];
    else
      purchaseId = '';
    if (json['redeem_status'] != null)
      redeemStatus = json['redeem_status'];
    else      redeemStatus = 0;

    if (json['voucher_code'] != null)
      voucherCode = json['voucher_code'];
    else
      voucherCode = '';
  }
}
