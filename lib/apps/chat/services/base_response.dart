import '../utils/core/parsing.dart';

abstract class BaseResponse {
  String message;
  int code;
  BaseResponse.fromJson(Map<String, dynamic> json) {
    message = Parsing.stringFrom(json['message']);
    code = Parsing.intFrom(json['code']);
  }
}
