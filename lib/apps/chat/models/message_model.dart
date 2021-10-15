import '../services/base_response.dart';
import '../utils/core/parsing.dart';

class MessageModel extends BaseResponse {
  String messageId;
  String createdDate;
  String message;
  String roomId;
  String docId;
  int type;
  int status;

  MessageModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.messageId = Parsing.stringFrom(json['message_id']);
    this.createdDate = Parsing.stringFrom(json['created_date']);
    this.message = Parsing.stringFrom(json['message']);
    this.roomId = Parsing.stringFrom(json['roomId']);
    this.type = Parsing.intFrom(json['type']);
    this.status = Parsing.intFrom(json['status']);
  }

  set messageText(String msg) => this.message = msg;
}
