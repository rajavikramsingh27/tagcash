class DeliveryOption {
  int id,shopId;
  String title, description;
  int shippingCharge;
  String createdAt, updatedAt, shippingDays;
  bool isRemoved = false;

  DeliveryOption({
    this.id,
    this.shopId,
    this.title,
    this.description,
    this.shippingCharge,
    this.shippingDays,
    this.createdAt,
    this.updatedAt,
    this.isRemoved
  });

  DeliveryOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shop_id'];
    title = json['title'].toString();
    description = json['description'].toString();
    shippingCharge = json['shipping_charge'];
    shippingDays = json['shipping_days'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  @override
  String toString() {
    return '{ ${this.id}, ${this.title}, ${this.description}, ${this.isRemoved} }';
  }
}
