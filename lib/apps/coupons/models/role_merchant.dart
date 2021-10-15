class RoleMerchant {
  int id;
  String roleName;
  bool roleDefault;
  String roleType;

  RoleMerchant({this.id, this.roleName, this.roleDefault, this.roleType});

  RoleMerchant.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    roleName = json['role_name'].toString();
    roleDefault = (json['role_default'] == '0') ? false : true;
    roleType = json['role_type'];
  }
}
