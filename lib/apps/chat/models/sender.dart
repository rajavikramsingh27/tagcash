import '../utils/core/parsing.dart';

class SenderModel {
  String nodeId;
  int tagcashId; //32093
  Map avatar;
  String firstname; // "Puneet"
  String lastname; //: "Sethi"
  String nickname;

  SenderModel.fromJson(Map<String, dynamic> json) {
    this.nodeId = Parsing.stringFrom(json['_id']);
    this.tagcashId = Parsing.intFrom(json['user_id']);
    this.firstname = Parsing.stringFrom(json['user_firstname']);
    this.lastname = Parsing.stringFrom(json['user_lastname']);
    this.nickname = Parsing.stringFrom(json['user_nickname']);
    this.avatar = Parsing.mapFrom(json['avatar']);
  }
  Map<String, dynamic> toMap() => {
        'nodeId': nodeId,
        'tagcashId': tagcashId,
        'avatar': avatar,
        'firstname': firstname,
        'lastname': lastname,
        'nickname': nickname
      };
}
