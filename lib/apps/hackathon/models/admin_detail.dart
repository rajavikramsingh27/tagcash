class AdminDetail {
  String id;
  String hackathonId;
  String roleName;
  String email;
  String adminName;
  UserDetail userDetail;

  AdminDetail(
      {this.id,
      this.hackathonId,
      this.roleName,
      this.email,
      this.adminName,
      this.userDetail});

  AdminDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hackathonId = json['hackathon_id'];
    roleName = json['role_name'];
    email = json['email'];
    adminName = json['admin_name'];
    userDetail = json['user_detail'] != null
        ? new UserDetail.fromJson(json['user_detail'])
        : null;
  }
}

class UserDetail {
  String id;
  String userEmail;
  String userFirstname;
  String userLastname;

  UserDetail({this.id, this.userEmail, this.userFirstname, this.userLastname});

  UserDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userEmail = json['user_email'];
    userFirstname = json['user_firstname'];
    userLastname = json['user_lastname'];
  }
}
