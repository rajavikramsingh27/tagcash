import 'dart:convert';

class MerchantBiller {
  String id;
  var ownerName;
  var ownerId;
  int ownerType;
  var title;
  int categoryId;
  String currency;
  int status;
  List<BillerData> billerData;

  MerchantBiller(
      {this.id,
      this.ownerId,
      this.ownerName,
      this.ownerType,
      this.title,
      this.categoryId,
      this.currency,
      this.status,
      this.billerData});

  MerchantBiller.fromJson(Map<String, dynamic> json) {
    if (json['billtype_ID'] != null) {
      id = json['billtype_ID'];
    } else {
      id = json['id'];
    }

    if (json['owner'] != null) {
      ownerId = json['owner']['id'];
      ownerName = json['owner']['name'];
      ownerType = json['owner']['type'];
    } else {
      ownerId = json['ownerId'];
      ownerName = json['ownerName'];
      ownerType = json['ownerType'];
    }
    title = json['title'];
    categoryId = json['category_id'];
    currency = json['currency'];
    status = json['status'];
    if (json['biller_data'] != null) {
      var list = json['biller_data'] as List;
      billerData = list.map((i) => BillerData.fromJson(i)).toList();
    } else if (json['billerData'] != null) {
      billerData =
          BillerData.decode(json['billerData']); //json['billerData'] as List;
      //billerData = list.map((i) => BillerData.fromJson(i)).toList();

    } else {
      billerData = [];
    }
  }

  static Map<String, dynamic> toMap(MerchantBiller biller) => {
        'id': biller.id,
        'ownerId': biller.ownerId,
        'ownerName': biller.ownerName,
        'ownerType': biller.ownerType,
        'title': biller.title,
        'categoryId': biller.categoryId,
        'currency': biller.currency,
        'status': biller.status,
        'billerData': BillerData.encode(biller.billerData)
      };
}

class BillerData {
  var displayName;
  var slug;
  var value;

  BillerData({this.displayName, this.slug, this.value});

  BillerData.fromJson(Map<String, dynamic> json) {
    displayName = json['display_name'];
    slug = json['slug'];
    if (json['value'] != null) {
      value = json['value'];
    } else {
      value = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['display_name'] = this.displayName;
    data['slug'] = this.slug;
    data['value'] = this.value;
    return data;
  }

  static Map<String, dynamic> toMap(BillerData billerData) => {
        'display_name': billerData.displayName,
        'slug': billerData.slug,
        'value': billerData.value
      };

  static String encode(List<BillerData> billers) => json.encode(
        billers
            .map<Map<String, dynamic>>((biller) => BillerData.toMap(biller))
            .toList(),
      );

  static List<BillerData> decode(String billerData) =>
      (json.decode(billerData) as List<dynamic>)
          .map<BillerData>((item) => BillerData.fromJson(item))
          .toList();
}
