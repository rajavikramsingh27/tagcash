class SearchData {
  String id;
  String name;

  SearchData({
    this.id,
    this.name,
  });

  SearchData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['community_name'] ??
        json['user_firstname'] + ' ' + json['user_lastname'];
  }
}
