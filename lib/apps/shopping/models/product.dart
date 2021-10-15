import 'package:tagcash/apps/shopping/models/option.dart';

class Product {
  int id;
  String name;
  String description;
  int price;
  int shipment_days;
  int stock;
  String currency_code;
  String image_thumb;
  bool favorite;
  int favorite_id;
  List<String> images;
  String other_option_name;
  List<Option> other;
  String color_option_name;
  List<Option> color;
  String size_option_name;
  List<Option> size;

  Product(this.id,
      this.name,
      this.description,
      this.price,
      this.shipment_days,
      this.stock,
      this.currency_code,
      this.image_thumb, this.favorite, this.favorite_id,this.other_option_name,this.color_option_name,this.size_option_name, [this.images, this.other, this.color, this.size]);

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    description = json['description'].toString();
    price = json['price'];
    shipment_days = json['shipment_days'];
    stock = json['stock'];
    currency_code = json['currency_code'].toString();
    favorite = json['favorite'];
    favorite_id = json['favorite_id'];
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
