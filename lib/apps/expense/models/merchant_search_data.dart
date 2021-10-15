class MerchantSearchData {
  int id;
  String name, roleName, roleType;

  MerchantSearchData({this.id, this.name, this.roleName, this.roleType});

  MerchantSearchData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['community_name'];
  //  roleName = json['role']['role_name'];
   // roleType = json['role']['role_type'];
  }
}
