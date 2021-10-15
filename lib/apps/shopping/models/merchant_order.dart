import 'order.dart';

class MerchantOrder {
  int shop_id;
  String transaction_id;
  String title;
  String delivery_status;
  String shipping_progress;
  String order_date;
  String grand_total;
  String shop_currency_code;
  List<Order> items;

  MerchantOrder(
      this.shop_id,
      this.transaction_id,
      this.title,
      this.delivery_status, this.shipping_progress, this.order_date, this.grand_total, this.shop_currency_code,[this.items]);

  factory MerchantOrder.fromJson(Map<String, dynamic> json) {
    if (json['item'] != null) {
      var tagObjsJson = json['item'] as List;
      List<Order> _tags;
      _tags = tagObjsJson.map<Order>((json) {
        return Order.fromJson(json);
      }).toList();
      return MerchantOrder(
          json['shop_id'],
          json['transaction_id'].toString(),
          json['title'].toString(),
          json['delivery_status'].toString(),
          json['shipping_progress'].toString(),
          json['order_date'].toString(),
          json['grand_total'].toString(),
          json['shop_currency_code'].toString(),
          _tags
      );
    } else {
      return MerchantOrder(
        json['shop_id'],
        json['transaction_id'].toString(),
        json['title'].toString(),
        json['delivery_status'].toString(),
        json['shipping_progress'].toString(),
        json['order_date'].toString(),
        json['grand_total'].toString(),
        json['shop_currency_code'].toString(),
      );
    }
  }

}
