class Member {
  int id;
  String userFirstname;
  String userLastname;
  int roleId;
  String roleName;
  String roleType;
  String roleStatus;
  String rating;

  Member(
      {this.id,
      this.userFirstname,
      this.userLastname,
      this.roleId,
      this.roleName,
      this.roleType,
      this.roleStatus,
      this.rating});

  Member.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    userFirstname = json['user_firstname'];
    userLastname = json['user_lastname'];
    roleId = int.parse(json['role_id']);
    roleName = json['role_name'];
    roleType = json['role_type'];
    roleStatus = 'approved';
    rating = '0';
  }
}
