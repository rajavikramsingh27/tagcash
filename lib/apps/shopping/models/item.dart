import 'package:tagcash/apps/shopping/models/option.dart';

class Item {
  int id;
  int inventory_id;
  int shop_id;
  int qty;
  String name;
  int price;
  String tax_rate;
  String image;
  String order_image;
  String image_thumb;
  String order_image_thumb;
  String currency_code;
  String other_option_name;
  List<Option> other;
  String color_option_name;
  List<Option> color;
  String size_option_name;
  List<Option> size;

  Item(
      this.id, this.inventory_id, this.shop_id, this.qty, this.name, this.price,
        this.tax_rate, this.image, this.order_image, this.image_thumb, this.order_image_thumb,
        this.currency_code, this.other_option_name, this.color_option_name, this.size_option_name, [this.other, this.color, this.size]);

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    inventory_id = json['inventory_id'];
    shop_id = json['shop_id'];
    qty = json['qty'];
    name = json['name'].toString();
    price = json['price'];
    tax_rate = json['tax_rate'].toString();
    image = json['image'].toString();
    order_image = json['order_image'].toString();
    image_thumb = json['image_thumb'].toString();
    order_image_thumb = json['order_image_thumb'].toString();
    currency_code = json['currency_code'].toString();
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
