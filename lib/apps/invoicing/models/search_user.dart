class Search_User {
  int id;
  String name;
  String user_email;
  int user_mobile;

  Search_User(
      {this.id,
        this.name,
        this.user_email,
        this.user_mobile});

  Search_User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    user_email = json['user_email'];
    user_mobile = json['user_mobile'];
  }
}
