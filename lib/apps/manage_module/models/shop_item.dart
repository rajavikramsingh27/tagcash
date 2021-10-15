class ShopItem {
  int id;
  String title;
  String description;
  String logoThumb;
  int totalProduct;
  bool isSelected;

  ShopItem(
      {this.id,
      this.title,
      this.description,
      this.logoThumb,
      this.totalProduct,
      this.isSelected});

  ShopItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    logoThumb = json['logo_thumb'];
    totalProduct = json['total_product'];
    isSelected = json['isSelected'];
  }
}
