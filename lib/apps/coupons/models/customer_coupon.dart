import 'package:intl/intl.dart';

class CustomerCoupon {
  String id;
  String title;
  String imageUrl;
  String description;
  String expiryDate;
  int ownerId;
  String ownerName;
  String couponType;
  var couponPrice;
  int couponWalletId;
  String couponCurrencyCode;
  int requireCustomerDetails;
  int selfRedeemable;
  int redeemStatus;
  String customerName;
  var voucherCode;

  CustomerCoupon(
      {this.id,
      this.title,
      this.imageUrl,
      this.description,
      this.expiryDate,
      this.ownerId,
      this.ownerName,
      this.couponType,
      this.couponPrice,
      this.couponWalletId,
      this.couponCurrencyCode,
      this.requireCustomerDetails,
      this.selfRedeemable,
      this.redeemStatus,
      this.customerName,
      this.voucherCode});

  CustomerCoupon.fromJson(Map<String, dynamic> json) {
    id = json['coupon_id'];
    title = json['coupon_details']['title'];
    imageUrl = json['coupon_details']['image_url'];
    description = json['coupon_details']['description'];
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var parsedDate = DateTime.parse(json['coupon_details']['expiry_date']);
    String formatted = formatter.format(parsedDate);
    expiryDate = formatted;
    ownerId = json['owner_details']['id'];
    ownerName = json['owner_details']['name'];
    couponType = json['coupon_details']['coupon_type'];
    couponPrice = json['coupon_details']['coupon_price'];
    couponWalletId = json['coupon_details']['coupon_wallet_id'];
    couponCurrencyCode = json['coupon_details']['coupon_currency_code'];
    requireCustomerDetails = json['coupon_details']['require_customer_details'];
    selfRedeemable = json['coupon_details']['self_redeemable'];
    redeemStatus = json['redeem_status'];
    customerName = json['customer_details']['name'];
    if (json['voucher_code'] != null)
      voucherCode = json['voucher_code'];
    else
      voucherCode = '';
  }
}
