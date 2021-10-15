import 'dart:convert';

class BillerFavorites {
  String biller;
  String billerTag;
  String amount;
  String name;
  String firstField;
  String secondField;
  String paymentOption;
  String serviceCharge;

  BillerFavorites(
      {this.biller,
      this.billerTag,
      this.amount,
      this.name,
      this.firstField,
      this.secondField,
      this.paymentOption,
      this.serviceCharge});

  BillerFavorites.fromJson(Map<String, dynamic> json) {
    biller = json['biller'];
    billerTag = json['billerTag'];
    amount = json['amount'];
    name = json['name'];
    firstField = json['firstField'];
    secondField = json['secondField'];
    paymentOption = json['paymentOption'];
    serviceCharge = json['serviceCharge'];
  }

  static Map<String, dynamic> toMap(BillerFavorites biller) => {
        'biller': biller.biller,
        'billerTag': biller.billerTag,
        'amount': biller.amount,
        'name': biller.name,
        'firstField': biller.firstField,
        'secondField': biller.secondField,
        'paymentOption': biller.paymentOption,
        'serviceCharge': biller.serviceCharge
      };

  static String encode(List<BillerFavorites> billers) => json.encode(
        billers
            .map<Map<String, dynamic>>(
                (biller) => BillerFavorites.toMap(biller))
            .toList(),
      );

  static List<BillerFavorites> decode(String billers) =>
      (json.decode(billers) as List<dynamic>)
          .map<BillerFavorites>((item) => BillerFavorites.fromJson(item))
          .toList();
}
