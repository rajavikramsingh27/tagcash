import '../services/base_response.dart';
import '../utils/core/parsing.dart';

class ReceiverModel extends BaseResponse {
  int tagcashId; //32093
  Map avatar;
  String firstname; // "Puneet"
  String lastname; //: "Sethi"
  String nickname;
  String nodeId;

  ReceiverModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.tagcashId = Parsing.intFrom(json['user_id']);
    this.nodeId = Parsing.stringFrom(json['_id']);
    this.firstname = Parsing.stringFrom(json['user_firstname']);
    this.lastname = Parsing.stringFrom(json['user_lastname']);
    this.nickname = Parsing.stringFrom(json['user_nickname']);
    this.avatar = Parsing.mapFrom(json['avatar']);
  }
}
