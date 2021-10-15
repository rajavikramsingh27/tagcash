import 'package:tagcash/apps/shopping/models/image.dart';

import 'image.dart';
import 'image.dart';
import 'option.dart';

class Favorite {
  int id;
  int product_id;
  String name;
  int shop_id;
  String description;
  int price;
  String currency_code;
  String image_thumb;
  int shipment_days;
  int stock;
  String shop_name;
  bool favourite;
  List<String> images;
  String other_option_name;
  List<Option> other;
  String color_option_name;
  List<Option> color;
  String size_option_name;
  List<Option> size;

  Favorite(this.id,
      this.product_id,
      this.name,
      this.shop_id,
      this.description,
      this.price,
      this.currency_code,
      this.image_thumb,
      this.shipment_days, this.stock, this.shop_name, this.favourite, this.other_option_name, this.color_option_name, this.size_option_name, [this.images, this.other, this.color, this.size]);

  Favorite.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product_id = json['product_id'];
    name = json['name'].toString();
    shop_id = json['shop_id'];
    description = json['description'].toString();
    price = json['price'];
    currency_code = json['currency_code'].toString();
    if(json['image'] != ''){
      image_thumb = json['image'][0].toString();
      var image = json['image'];
      images = new List<String>.from(image);
    } else{
      image_thumb = "";
      var image = "";
      images = new List<String>();
      images.add(image);
    }
    shipment_days = json['shipment_days'];
    stock = json['stock'];
    shop_name = json['shop_name'];
    favourite = json['favorite'];
    other_option_name = json['other']['option_name'].toString();
    if(json['other']['option'] != '' && json['other']['option'] != null){
      var tagObjsJson = json['other']['option'] as List;
      other = tagObjsJson.map<Option>((json) {
        return Option.fromJson(json);
      }).toList();
    }
    color_option_name = json['color']['option_name'].toString();
    if(json['color']['option'] != '' && json['color']['option'] != null){
      var tagObjsJson = json['color']['option'] as List;
      color = tagObjsJson.map<Option>((json) {
        return Option.fromJson(json);
      }).toList();
    }
    size_option_name = json['size']['option_name'].toString();
    if(json['size']['option'] != '' && json['size']['option'] != null){
      var tagObjsJson = json['size']['option'] as List;
      size = tagObjsJson.map<Option>((json) {
        return Option.fromJson(json);
      }).toList();
    }

  }
}
