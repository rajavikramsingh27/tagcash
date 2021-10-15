class Admin_List {
  String id;
  String hackathon_id;
  String role_name;
  String email;
  String admin_name;
  var user_detail;

  Admin_List(
      {this.id,
      this.hackathon_id,
      this.role_name,
      this.email,
      this.admin_name,
      this.user_detail});

  Admin_List.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hackathon_id = json['hackathon_id'];
    role_name = json['role_name'];
    email = json['email'];
    admin_name = json['admin_name'];
    user_detail = json['user_detail'];
  }
}
