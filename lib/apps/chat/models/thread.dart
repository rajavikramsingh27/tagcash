import '../models/room_model.dart';
import '../models/sender.dart';
import '../utils/core/parsing.dart';

class Thread {
  String id;
  String createdDate;
  String createdDateFormatted;
  String docId;
  int isReply;
  String isVisible;
  String message;
  String parentId;
  Map replyFor;
  String roomId;
  RoomModel roomInfo;
  SenderModel senderInfo;
  List isHiddenFor = [];
  String sortedDate;
  int status;
  int type;
  int withId;
  // int toTagcashId;
  // int fromtagcashId;
  // int isSeenReceiver;
  // int vv;
  // String senderId;
  // String receiverId;

  Thread.fromJson(Map<String, dynamic> json) {
    this.id = Parsing.stringFrom(json['_id']);
   this.createdDate = Parsing.stringFrom(json['created_date']);

    if (Parsing.stringFrom(json['created_date']).isNotEmpty) {
      // this.createdDate= DateFormat('h:mm a')
      //     .format(DateTime.parse(json['created_date']));
      // final DateTime now = DateTime.now();
      // final DateTime incomingDate = DateTime.parse(json['message_date']);
      // final DateFormat formatter = DateFormat('dd/MM/yy');
      // final DateFormat formatNew = DateFormat('h:mm a');
      // // logic
      // var yesterDay = DateTime.now().subtract(Duration(days: 1));

      // if (now.day == incomingDate.day) {
      //   this.createdDate = formatNew.format(incomingDate);
      // } else {
      //   if (yesterDay.day == incomingDate.day) {
      //     this.createdDate = 'yesterday';
      //   } else {
      //     this.createdDate = formatter.format(incomingDate);
      //   }
      // }
    }
    this.docId = Parsing.stringFrom(json['doc_id']);
    this.isReply = Parsing.intFrom(json['is_reply']);
    this.withId = Parsing.intFrom(json['with_Id']);
    this.isVisible = Parsing.stringFrom(json['is_visible']);
    if (json['is_hidden_for'] != null) {
      this.isHiddenFor = Parsing.arrayFrom(json['is_hidden_for']);
    }
    this.message = Parsing.stringFrom(json['message']);
    this.parentId = Parsing.stringFrom(json['parent_id']);
    this.replyFor = Parsing.mapFrom(json['_id']); 
    this.roomId = Parsing.stringFrom(json['roomId']);
    this.senderInfo = SenderModel.fromJson(json['senderinfo']);
    this.status = Parsing.intFrom(json['status']);
    // this.toTagcashId = Parsing.intFrom(json['to_tagcash_id']);
    // this.fromtagcashId = Parsing.intFrom(json['from_tagcash_id']);
    // this.isSeenReceiver = Parsing.intFrom(json['isseen_reciever']);
    // this.vv = Parsing.intFrom(json['__v']);
    // this.senderId = Parsing.stringFrom(json['senderId']);
    // this.receiverId = Parsing.stringFrom(json['receiverId']);
    if (json.containsKey('roominfo')) {
      this.roomInfo = RoomModel.fromJson(json['roominfo']);
    }
    if (json.containsKey('sorted_date')) {
      this.sortedDate = Parsing.stringFrom(json['sorted_date']);
    }
    this.type = Parsing.intFrom(json['type']);
  }

  set setStatus(int status) => this.status = status;

  Map<String, dynamic> toMap() => {
        '_id': id,
        'createdDate': createdDate,
        'isReply': isReply,
        'docId': docId,
        'isVisible': isVisible,
        'message': message,
        'parentId': parentId,
        'replyFor': replyFor,
        'roomId': roomId,
        'sorted_Date': sortedDate,
        'status': status,
        'type': type,
        'roomInfo': roomInfo.toMap(),
        'senderInfo': senderInfo.toMap(),
        'with_Id': withId
      };
}
