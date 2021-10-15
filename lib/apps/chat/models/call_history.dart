import 'package:intl/intl.dart';
import '../models/receiver.dart';
import '../models/sender.dart';
import '../services/base_response.dart';
import '../utils/core/parsing.dart';

class CallHistoryModel extends BaseResponse {
  String id;
  String roomId;
  String createdDate;
  int toTagcashId;
  int fromTagcashId;
  SenderModel sender;
  ReceiverModel receiver;

  CallHistoryModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.id = Parsing.stringFrom(json['_id']);
    this.roomId = Parsing.stringFrom(json['roomId']);

    if (Parsing.stringFrom(json['created_date']).isNotEmpty) {
      this.createdDate= DateFormat('d MMMM, h:mm a').format(DateTime.parse(json['created_date']));
    }

    //this.createdDate = Parsing.stringFrom(json['created_date']);
    this.toTagcashId = Parsing.intFrom(json['to_tagcash_id']);
    this.fromTagcashId = Parsing.intFrom(json['from_tagcash_id']);
    this.receiver = ReceiverModel.fromJson(json['receiverinfo']);
    this.sender = SenderModel.fromJson(json['senderinfo']);
  }
}
