import 'dart:convert';

import 'package:tagcash/apps/invoicing/models/tax.dart';



String itemToJson(List<AddItem> data) => json.encode(List<AddItem>.from(data.map((x) => x.toJson())));
List<AddItem> ItemFromJson(String str) =>
    List<AddItem>.from(json.decode(str).map((x) => AddItem.fromJson(x)));

class AddItem {
  String id;
  String name;
  String desc;
  String price;
  String income_account;
  String qty;
  List<Tax> taxx;
  List<String> tax_id;

  AddItem(
      this.id,
        this.name,
        this.desc, this.price, this.income_account, this.qty, [this.taxx]);

  factory AddItem.fromJson(Map<String, dynamic> json) {
    if (json['tax'] != null) {
      var tagObjsJson = json['tax'] as List;
      List<Tax> _tags;
      _tags = tagObjsJson.map<Tax>((json) {
        return Tax.fromJson(json);
      }).toList();
      return AddItem(
          json['id'] as String,
          json['name'] as String,
          json['desc'] as String,
          json['price'] as String,
          json['income_account'] as String,
          json['quantity'].toString() as String,
          _tags
      );
    } else {
      return AddItem(
        json['id'] as String,
        json['name'] as String,
        json['desc'] as String,
        json['price'] as String,
        json['income_account'] as String,
        json['quantity'] as String,
      );
    }


  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'desc': desc,
    'price': price,
    'income_account': income_account,
    'quantity': qty.toString(),
    'tax_id': tax_id,


  };
}
