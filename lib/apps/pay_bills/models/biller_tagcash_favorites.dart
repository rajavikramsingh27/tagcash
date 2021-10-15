import 'dart:convert';

import 'package:tagcash/apps/biller_setup/models/merchant_biller.dart';
import 'package:tagcash/apps/pay_bills/models/biller_merchant.dart';

class BillerTagcashFavorites {
  String biller;
  String amount;
  String name;
  String merchantId;
  String merchantName;
  String merchantCurrency;
  BillerMerchant selectedBillerMerchant;
  MerchantBiller selectedMerchantBiller;
  String otherData;
  String billerValue;

  BillerTagcashFavorites(
      {this.biller,
      this.amount,
      this.name,
      this.merchantId,
      this.merchantName,
      this.merchantCurrency,
      this.selectedBillerMerchant,
      this.selectedMerchantBiller,
      this.billerValue,
      this.otherData});

  BillerTagcashFavorites.fromJson(Map<String, dynamic> json) {
    biller = json['biller'];
    amount = json['amount'];
    name = json['name'];
    merchantId = json['merchantId'];
    merchantName = json['merchantName'];
    merchantCurrency = json['merchantCurrency'];
    selectedBillerMerchant =
        BillerMerchant.fromJson(json['selectedBillerMerchant']);
    selectedMerchantBiller =
        MerchantBiller.fromJson(json['selectedMerchantBiller']);

    billerValue = json['billerValue'];
    otherData = json['otherData'];
  }

  static Map<String, dynamic> toMap(BillerTagcashFavorites biller) => {
        'biller': biller.biller,
        'amount': biller.amount,
        'name': biller.name,
        'merchantId': biller.merchantId,
        'merchantName': biller.merchantName,
        'merchantCurrency': biller.merchantCurrency,
        'selectedBillerMerchant':
            BillerMerchant.toMap(biller.selectedBillerMerchant),
        'selectedMerchantBiller':
            MerchantBiller.toMap(biller.selectedMerchantBiller),
        'billerValue': biller.billerValue,
        'otherData': biller.otherData,
      };

  static String encode(List<BillerTagcashFavorites> billers) => json.encode(
        billers
            .map<Map<String, dynamic>>(
                (biller) => BillerTagcashFavorites.toMap(biller))
            .toList(),
      );

  static List<BillerTagcashFavorites> decode(String billers) =>
      (json.decode(billers) as List<dynamic>)
          .map<BillerTagcashFavorites>(
              (item) => BillerTagcashFavorites.fromJson(item))
          .toList();
}
