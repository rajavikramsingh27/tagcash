import 'package:intl/intl.dart';

import '../models/message_model.dart';
import '../models/receiver.dart';
import '../models/sender.dart';
import '../services/base_response.dart';
import '../utils/core/parsing.dart';


class ChatModel extends BaseResponse {
  String roomId;
  int unreadCount;
  Map avatarUrl;
  String contactName;
  String name;
  String datetime;
  String dayDatetime;
  MessageModel messageDetail;
  SenderModel sender;
  ReceiverModel receiver;

  ChatModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.roomId = Parsing.stringFrom(json['_id']);
    this.unreadCount = Parsing.intFrom(json['unread_count']);
    this.avatarUrl = Parsing.mapFrom(json['contact_avatar']);
    this.contactName = Parsing.stringFrom(json['contact_name']);
    if (Parsing.stringFrom(json['message_date']).isNotEmpty) {
      final DateTime now = DateTime.now();
      var incomingDate = DateTime.parse(json['message_date']).toUtc();
      final DateFormat formatter = DateFormat('dd/MM/yy');
      final DateFormat formatNew = DateFormat('h:mm a');
      // logic
      var yesterDay = DateTime.now().subtract(Duration(days: 1));

      if (now.day == incomingDate.day) {
        this.datetime = formatNew.format(incomingDate.toLocal()).toString();
      } else {
        if (yesterDay.day == incomingDate.day) {
          this.datetime = 'yesterday';
        } else {
          this.datetime = formatter.format(incomingDate);
        }
      }
    }
    this.messageDetail = MessageModel.fromJson(json['chatDetails']);
    this.receiver = ReceiverModel.fromJson(json['receiverinfo']);
    this.sender = SenderModel.fromJson(json['senderinfo']);
  }

  // ignore: non_constant_identifier_names
  set msg_detail(MessageModel msgDetail) {
    this.messageDetail = msgDetail;
  }

  // ignore: non_constant_identifier_names
  set date_time(String dt) {
    this.datetime = dt;
  }
}
