import 'package:tagcash/apps/shopping/models/option.dart';

class Order {
  String id;
  String inventory_id;
  String shop_id;
  String qty;
  String stock;
  String orderDate;
  String transaction_id;
  String amount;
  String delivery_status;
  String productName;
  String shipping_progress;
  String payment_type;
  String currency_code;
  String shop_name;
  String total_amount;
  String item_price;
  String tax_rate;
  String image_thumb;
  String deliveryCharge;
  var shipping_address;
  String other_option_name;
  List<Option> other;
  String color_option_name;
  List<Option> color;
  String size_option_name;
  List<Option> size;

  Order(this.id, this.inventory_id, this.shop_id, this.qty, this.stock, this.orderDate, this.transaction_id,
        this.amount, this.delivery_status, this.productName, this.shipping_progress, this.payment_type,
        this.currency_code, this.shop_name, this.total_amount, this.item_price, this.tax_rate,
        this.image_thumb, this.deliveryCharge, this.shipping_address,
        this.other_option_name, this.color_option_name, this.size_option_name, [this.other, this.color, this.size]);

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    inventory_id = json['inventory_id'].toString();
    shop_id = json['shop_id'].toString();
    qty = json['qty'].toString();
    stock = json['stock'].toString();
    orderDate = json['orderDate'];
    transaction_id = json['transaction_id'];
    amount = json['amount'].toString();
    delivery_status = json['delivery_status'];
    if(json['shipping_address'] != '' && json['shipping_address'] != null){
      shipping_address = json['shipping_address'];
    }
    productName = json['productName'].toString();
    shipping_progress = json['shipping_progress'].toString();
    payment_type = json['payment_type'].toString();
    currency_code = json['currency_code'].toString();
    shop_name = json['shop_name'].toString();
    total_amount = json['total_amount'].toString();
    item_price = json['item_price'].toString();
    tax_rate = json['tax_rate'].toString();
    image_thumb = json['image_thumb'];
    deliveryCharge = json['deliveryCharge'].toString();
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
