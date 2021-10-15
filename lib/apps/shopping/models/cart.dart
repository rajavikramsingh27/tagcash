import 'item.dart';

class Cart {
  int shop_id;
  String delivery_handling;
  int delivery_charge;
  String shop_title;
  List<Item> items;

  Cart(
      this.shop_id,
      this.delivery_handling,
      this.delivery_charge,
      this.shop_title, [this.items]);

  factory Cart.fromJson(Map<String, dynamic> json) {
    if (json['item'] != null) {
      var tagObjsJson = json['item'] as List;
      List<Item> _tags;
      _tags = tagObjsJson.map<Item>((json) {
        return Item.fromJson(json);
      }).toList();
      return Cart(
          json['shop_id'],
          json['delivery_handling'],
          json['delivery_charge'],
          json['shop_title'],
          _tags
      );
    } else {
      return Cart(
        json['shop_id'],
        json['delivery_handling'],
        json['delivery_charge'],
        json['shop_title'],
      );
    }
  }

}
