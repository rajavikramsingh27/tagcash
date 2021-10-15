class Search_Merchant {
  int id;
  String community_name;

  Search_Merchant(
      {this.id,
        this.community_name});

  Search_Merchant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    community_name = json['community_name'];
  }
}
