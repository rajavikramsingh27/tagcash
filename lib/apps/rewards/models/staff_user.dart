class StaffUser {
  String id;
  String userFirstname;
  String userLastname;
//  bool avatar;
//  String roleId;
//  String roleName;
//  String roleType;

  StaffUser(
      {this.id,
        this.userFirstname,
        this.userLastname});

  StaffUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userFirstname = json['user_firstname'];
    userLastname = json['user_lastname'];
  }
}

