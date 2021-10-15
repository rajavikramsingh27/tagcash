class CommentReply {
  String user_id;
  String name;
  String type;
  String email;
  String verified;
  String time;
  String reply;

  CommentReply(
      {this.user_id,
        this.name, this.type, this.email,this.verified,this.time,this.reply});

  CommentReply.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'].toString();
    name = json['name'].toString();
    type = json['type'].toString();
    email = json['email'].toString();
    verified = json['verified'].toString();
    time = json['time'].toString();
    reply = json['reply'].toString();
  }

}
