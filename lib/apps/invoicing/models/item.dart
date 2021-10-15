
import 'package:tagcash/apps/invoicing/models/tax.dart';

class Item {
  String id;
  String name;
  String desc;
  String price;
  String income_account;
  String tax_name;
  String tax_rate;
  String tax_id;
  List<Tax> taxx;
  Item(
      this.id,
        this.name,
        this.desc,
        this.price,
        this.income_account, [this.taxx]);

  factory Item.fromJson(Map<String, dynamic> json) {
    if (json['tax'] != null) {
      var tagObjsJson = json['tax'] as List;
      List<Tax> _tags;
      _tags = tagObjsJson.map<Tax>((json) {
        return Tax.fromJson(json);
      }).toList();

      return Item(
          json['id'] as String,
          json['name'] as String,
          json['desc'] as String,
          json['price'] as String,
          json['income_account'] as String,
          _tags
      );
    } else {
      return Item(
        json['id'] as String,
        json['name'] as String,
        json['desc'] as String,
        json['price'] as String,
        json['income_account'] as String,
      );
    }
  }



}
