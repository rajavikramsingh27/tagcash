import '../utils/core/parsing.dart';

class RoomModel {
  String id;
  String createdDate;
  String description;
  List<dynamic> isHiddenFor;
  bool isVisible;
  String status;
  String title;
  List<dynamic> users;

  RoomModel.fromJson(Map<String, dynamic> json) {
    this.id = Parsing.stringFrom(json['_id']);
    this.createdDate = Parsing.stringFrom(json['created_date']);
    this.description = Parsing.stringFrom(json['description']);
    if (json['is_hidden_for'] != null) {
      this.isHiddenFor =
          json['is_hidden_for'].map((e) => Parsing.mapFrom(e)).toList();
    }
    this.isVisible = Parsing.boolFrom(json['is_visible']);
    this.status = Parsing.stringFrom(json['status']);
    this.title = Parsing.stringFrom(json['title']);
    if (json['users'] != null) {
      this.users = json['users'].map((e) => Parsing.stringFrom(e)).toList();
    }
  }
  Map<String, dynamic> toMap() => {
        'id': id,
        'createdDate': createdDate,
        'description': description,
        'isHiddenFor': isHiddenFor,
        'isVisible': isVisible,
        'status': status,
        'title': title
      };
}
