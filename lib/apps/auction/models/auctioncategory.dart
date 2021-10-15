class AuctionCategory {
  String id;
  String category_name;
  String app_id;

  AuctionCategory(
      {this.id,
        this.category_name, this.app_id});

  AuctionCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    category_name = json['category_name'];
    app_id = json['app_id'].toString();
  }

}
