import '../models/chat_history.dart';
import '../models/room_model.dart';
import '../services/base_response.dart';
import '../utils/core/parsing.dart';

class Conversation extends BaseResponse {
  RoomModel room;
  History history;
  bool newRoom;

  Conversation.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.history = History.fromJson(Parsing.mapFrom(json['history']));
    this.newRoom = Parsing.boolFrom(json['newRoom']);
    this.room = RoomModel.fromJson(json['room']);
  }
}
