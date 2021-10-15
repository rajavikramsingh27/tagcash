class Shop {
  int id;
  String title, description;
  int walletId, owner, status;
  String logo, logoThumb, headerImage, createdAt, updatedAt, stripe_connect_id, stripe_email;
  int totalProduct, rating;

  Shop({
    this.id,
    this.title,
    this.description,
    this.walletId,
    this.owner,
    this.status,
    this.logo,
    this.logoThumb,
    this.headerImage,
    this.createdAt,
    this.updatedAt,
    this.totalProduct,
    this.rating
  });

  Shop.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'].toString();
    description = json['description'].toString();
    walletId = json['wallet_id'];
    owner = json['owner'];
    status = json['status'];
    logo = json['logo'];
    logoThumb = json['logo_thumb'];
    headerImage = json['header_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    stripe_connect_id = json['stripe_connect_id'].toString();
    stripe_email = json['stripe_email'];
    totalProduct = json['total_product'];
    rating = json['rating'];
  }
}
