class LikeUser {
  String user_id;
  String name;
  String time;

  LikeUser(
      {this.user_id,
        this.name, this.time});

  LikeUser.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'].toString();
    name = json['name'].toString();
    time = json['time'].toString();
  }

}
