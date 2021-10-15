import 'package:dio/dio.dart';

import '../models/call_history.dart';
import '../models/chat_history.dart';
import '../models/node_user.dart';
import '../network/base.dart';
import '../../../models/user_data.dart';

class RestApiClientService extends RestApiBaseService {
  static RestApiClientService shared = RestApiClientService._internal();
  var customHeaders = {"Content-Type": "application/json"};
  RestApiClientService._internal() : super();

  Future<dynamic> searchUser(Map<String, dynamic> params) async {
    try {
      final response = await dio.get("user/searchuser",
          queryParameters: params, options: Options(headers: customHeaders));
      return UserData.fromJson(response.data);
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<dynamic> uploadImage(Map<String, dynamic> params) async {
    try {
      final response = await dio.post("api/upload-image",
          queryParameters: params, options: Options(headers: customHeaders));
      return response.data;
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<dynamic> deleteconversation(Map<String, dynamic> params) async {
    try {
      final response = await dio.post("api/deleteconversation", data: params);
      return response.data;
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<dynamic> deleteMessage(Map<String, dynamic> params) async {
    try {
      final response = await dio.post("api/deletemessage", data: params);
      return response.data;
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<dynamic> changeRequestStatus(Map<String, dynamic> params) async {
    try {
      final response = await dio.post("api/update-message", data: params);
      return response.data;
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<dynamic> setCharge(Map<String, dynamic> params) async {
    try {
      final response = await dio.post("/api/set-charge", data: params);
      return NodeUser.fromJson(response.data['data']);
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<History> reloadConversation(Map<String, dynamic> item) async {
    try {
      final response = await dio.post("api/reloadconversation", data: item);
      return (response.data.runtimeType != String)
          ? History.fromJson(response.data['data'])
          : new Map();
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<NodeUser> loginUser(Map<String, dynamic> item) async {
    try {
      final response = await dio.post("api/login", data: item);
      return (response.data.runtimeType != String)
          ? NodeUser.fromJson(response.data['data'])
          : new Map();
    } catch (error) {
      return Future.error(getException(error));
    }
  }

  Future<dynamic> callHistory(Map<String, dynamic> data) async {
    try {
      final response = await dio.post("api/calls", data: data);

      if (response.data.runtimeType != String) {
        if (response.data['data']['docs'].length > 0 ||
            response.data['data']['docs'].length == null) {
          print(response.data['data']['docs']);
          return response.data['data']['docs']
              .map((e) => CallHistoryModel.fromJson(e))
              .toList();
        }
      } else {
        new Map();
      }
    } catch (error) {
      return Future.error(getException(error));
    }
  }
}
