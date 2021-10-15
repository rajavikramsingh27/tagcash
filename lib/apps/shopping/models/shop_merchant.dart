/*class ShopType{
  int typeId;
  ShopType(this.typeId);
  factory ShopType.fromJson(dynamic json){
    return ShopType(json['type_id']);
  }

  @override
  String toString() {
    return '{ ${this.typeId} }';
  }
}

class ShopApps{
  int appId;
  ShopApps(this.appId);
  factory ShopApps.fromJson(dynamic json){
    return ShopApps(json['app_Id']);
  }

  @override
  String toString() {
    return '{ ${this.appId} }';
  }
}*/

import 'package:tagcash/apps/shopping/models/option.dart';

class ShopMerchant {
  int id;
  String title, description, search_tag, wallet_reward_currency_code, currency_code, shop_tax_rate;
  int walletId, payment_by_tagcash, cod, enable_reward_payment, reward_wallet_id, reward_amount, max_purchase_reward;
  String logo, delivery_charge, logoThumb, headerImage, currencyCode, delivery_handling, pickup_address, postal_code, contact_number, contact_email;
  int totalProduct;
  List<dynamic> shopType;
  List<dynamic> shopApps;
  String other_option_name;
  List<Option> other;
  String color_option_name;
  List<Option> color;
  String size_option_name;
  List<Option> size;
  String stripe_connect_id, stripe_email;
  ShopMerchant(
    this.id,
    this.title,
    this.description,
    this.search_tag,
    this.walletId,
    this.logo,
    this.logoThumb,
    this.payment_by_tagcash,
    this.cod,
    this.delivery_charge,
    this.enable_reward_payment,
    this.reward_wallet_id,
    this.shop_tax_rate,
    this.reward_amount,
    this.max_purchase_reward,
    this.wallet_reward_currency_code,
    this.currency_code,
    this.headerImage,
    this.currencyCode,
    this.delivery_handling,
    this.pickup_address,
    this.postal_code,
    this.contact_number,
    this.contact_email,
    this.totalProduct,
    this.shopType,
    this.shopApps, this.other_option_name, this.color_option_name, this.size_option_name, this.stripe_connect_id, this.stripe_email, [this.other, this.color, this.size]
  );

  factory ShopMerchant.fromJson(dynamic json){
    var shopTypeJson;
    var shopAppsJson;
    List<Option> other;
    List<Option> size;
    List<Option> color;

    if(json["shop_type"]!=null){
      shopTypeJson = json["shop_type"] as List;
    }
    if(json["shop_apps"]!=null){
      shopAppsJson = json["shop_apps"] as List;
    }
    if(json['other']['option'].toString() != '' && json['other']['option'].toString() != null){
      var tagObjsJson = json['other']['option'] as List;
      other = tagObjsJson.map<Option>((json) {
        return Option.fromJson(json);
      }).toList();
    }
    if(json['size']['option'].toString() != '' && json['size']['option'].toString() != null){
      var tagObjsJson = json['size']['option'] as List;
      size = tagObjsJson.map<Option>((json) {
        return Option.fromJson(json);
      }).toList();
    }

    if(json['color']['option'].toString() != '' && json['color']['option'].toString() != null){
      var tagObjsJson = json['color']['option'] as List;
      color = tagObjsJson.map<Option>((json) {
        return Option.fromJson(json);
      }).toList();
    }

    return ShopMerchant(
      json["id"] as int,
      json["title"].toString(),
      json['description'].toString(),
      json['search_tag'].toString(),
      json['wallet_id'] as int,
      json['logo'].toString(),
      json['logo_thumb'].toString(),
      json['payment_by_tagcash'] as int,
      json['cod'] as int,
      json['delivery_charge'].toString(),
      json['enable_reward_payment'] as int,
      json['reward_wallet_id'] as int,
      json['shop_tax_rate'].toString(),
      json['reward_amount'] as int,
      json['max_purchase_reward'] as int,
      json['wallet_reward_currency_code'] as String,
      json['currency_code'].toString(),
      json['header_image'].toString(),
      json['currency_code'].toString(),
      json['delivery_handling'].toString(),
      json['pickup_address'].toString(),
      json['postal_code'].toString(),
      json['contact_number'].toString(),
      json['contact_email'].toString(),
      json['total_product'] as int,
      shopTypeJson,//_shoptypes
      shopAppsJson,
      json['other']['option_name'].toString(),
      json['color']['option_name'].toString(),
      json['size']['option_name'].toString(),
      json['stripe_connect_id'].toString(),
      json['stripe_email'].toString(),
      other,
      color,
      size,
    );
  }

  @override
  String toString() {
    return '{ ${this.id}, ${this.title}, ${this.description}, ${this.shopType.toString()},${this.shopApps.toString() }';
  }
}
