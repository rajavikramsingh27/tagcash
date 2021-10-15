class MemberDetail {
  String id;
  String projectId;
  String memberOption;
  String memberName;
  String memberType;
  String teamAdmin;
  String email;
  UserDetail userDetail;

  MemberDetail(
      {this.id,
      this.projectId,
      this.memberOption,
      this.memberName,
      this.memberType,
      this.teamAdmin,
      this.email,
      this.userDetail});

  MemberDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    projectId = json['project_id'];
    memberOption = json['member_option'];
    memberName = json['member_name'];
    memberType = json['member_type'];
    teamAdmin = json['team_admin'];
    email = json['email'];
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
