import 'package:intl/intl.dart';
class PurchasedCoupon {
  String id;
  int userId;
  int userType;
  String couponId;
  String couponType;
  String title;
  String imageUrl;
  String description;
  String expiryDate;
  int couponWalletId;
  var couponPrice;
  String couponCurrencyCode;
  int requireCustomerDetails;
  int selfRedeemable;
  var voucherCode;
  String customerName;
  String customerEmail;
  var customerMobileNo;
  String customerAddress;
  String customerComments;
  int ownerId;
  String ownerName;
  int totalNumber;
  String purchasedDate;
  int redeemStatus;
  String redeemedDate;

  PurchasedCoupon(
      {this.id,
      this.userId,
      this.userType,
      this.couponId,
      this.couponType,
      this.title,
      this.imageUrl,
      this.description,
      this.expiryDate,
      this.couponWalletId,
      this.couponPrice,
      this.couponCurrencyCode,
      this.requireCustomerDetails,
      this.selfRedeemable,
      this.voucherCode,
      this.customerName,
      this.customerEmail,
      this.customerMobileNo,
      this.customerAddress,
      this.customerComments,
      this.ownerId,
      this.ownerName,
      this.totalNumber,
      this.purchasedDate,
      this.redeemStatus,
      this.redeemedDate});

  PurchasedCoupon.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['user_id'];
    userType = json['user_type'];
    couponId = json['coupon_id'];
    couponType = json['coupon_details']['coupon_type'];
    title = json['coupon_details']['title'];
    imageUrl = json['coupon_details']['image_url'];
    description = json['coupon_details']['description'];

    DateFormat formatter = DateFormat('d MMM yyyy');
    var parsedDate = DateTime.parse(json['coupon_details']['expiry_date']);
    String formatted = formatter.format(parsedDate);
    expiryDate = formatted;
    if (json['coupon_details']['coupon_wallet_id'] != null)
      couponWalletId = json['coupon_details']['coupon_wallet_id'];
    else
      couponWalletId = 0;
    if (json['coupon_details']['coupon_price'] != null)
      couponPrice = json['coupon_details']['coupon_price'];
    else
      couponPrice = 0;
    if (json['coupon_details']['coupon_currency_code'] != null)
      couponCurrencyCode = json['coupon_details']['coupon_currency_code'];
    else
      couponCurrencyCode = '';
    requireCustomerDetails = json['coupon_details']['require_customer_details'];
    selfRedeemable = json['coupon_details']['self_redeemable'];
    if (json['coupon_details']['voucher_code'] != null)
      voucherCode = json['coupon_details']['voucher_code'];
    else
      voucherCode = '';
    customerName = json['customer_details']['name'];
    customerEmail = json['customer_details']['email'];
    if (json['customer_details']['mobile_no'] != null)
      customerMobileNo = json['customer_details']['mobile_no'];
    else
      customerMobileNo = '';
    if (json['customer_details']['address'] != null)
      customerAddress = json['customer_details']['address'];
    else
      customerAddress = '';
    if (json['customer_details']['additional_comments'] != null)
      customerComments = json['customer_details']['additional_comments'];
    else
      customerComments = '';
    ownerId = json['owner_details']['id'];
    ownerName = json['owner_details']['name'];
    totalNumber = json['total_number'];
    purchasedDate = json['purchased_date'];
    redeemStatus = json['redeem_status'];
    redeemedDate = json['redeemed_date'];
  }
}
