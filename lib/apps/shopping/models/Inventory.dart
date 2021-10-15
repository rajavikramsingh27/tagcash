import 'package:tagcash/apps/shopping/models/image.dart';

class Inventory {
  int id;
  int shop_id;
  String name;
  String description;
  int price;
  int owner;
  int shipment_days;
  String tax_rate;
  String sku_code;
  int stock;
  int status;
  List<image> images;

  Inventory(
      this.id,
        this.shop_id,
        this.name,
        this.description,
        this.price,
        this.owner,
        this.shipment_days,
        this.tax_rate,
        this.sku_code,
        this.stock,
        this.status, [this.images]);

  factory Inventory.fromJson(Map<String, dynamic> json) {
    if (json['image_thumb'] != null) {
      var tagObjsJson = json['image_thumb'] as List;
      List<image> _tags;
      _tags = tagObjsJson.map<image>((json) {
        return image.fromJson(json);
      }).toList();
      return Inventory(
          json['id'],
          json['shop_id'],
          json['name'].toString(),
          json['description'].toString(),
          json['price'],
          json['owner'],
          json['shipment_days'],
          json['tax_rate'].toString(),
          json['sku_code'],
          json['stock'],
          json['status'],
          _tags
      );
    } else {
      return Inventory(
          json['id'],
          json['shop_id'],
          json['name'].toString(),
          json['description'].toString(),
          json['price'],
          json['owner'],
          json['shipment_days'],
          json['tax_rate'].toString(),
          json['sku_code'],
          json['stock'],
          json['status'],
      );
    }


  }

/*
  Inventory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shop_id = json['shop_id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    owner = json['owner'];
    shipment_days = json['shipment_days'];
    sku_code = json['sku_code'];
    stock = json['stock'];
    status = json['status'];
  }
*/

}
