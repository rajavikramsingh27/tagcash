import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'dart:convert';

import 'package:tagcash/models/app_constants.dart' as AppConstants;

const _defaultConnectTimeout = Duration.millisecondsPerMinute;
const _defaultReceiveTimeout = Duration.millisecondsPerMinute;

class NetworkHelper {
  static Future authenticate(String email, String password) async {
    final http.Response response = await http.post(
      Uri.parse(AppConstants.getServerPath() + "oauth/accesstoken"),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: {
        'use_otp': '1',
        'client_id': AppConstants.client_id,
        'client_secret': AppConstants.client_secret,
        'client_unique_id': AppConstants.deviceId,
        'mobile_name': AppConstants.deviceName,
        'app_name': AppConstants.appName,
        'grant_type': 'password',
        'username': email,
        'password': password,
      },
    );

    return jsonDecode(response.body);
  }

  static Future authenticateFacebook(String fbAccessToken) async {
    final http.Response response = await http.post(
      Uri.parse(AppConstants.getServerPath() + "registration/facebook"),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: {
        'use_otp': '1',
        'client_id': AppConstants.client_id,
        'client_secret': AppConstants.client_secret,
        'client_unique_id': AppConstants.deviceId,
        'mobile_name': AppConstants.deviceName,
        'app_name': AppConstants.appName,
        'access_token': fbAccessToken,
      },
    );

    return jsonDecode(response.body);
  }

  static Future authenticateGoogle(
      String email, String firstName, String lastName) async {
    final http.Response response = await http.post(
      Uri.parse(AppConstants.getServerPath() + "registration/google"),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: {
        'use_otp': '1',
        'client_id': AppConstants.client_id,
        'client_secret': AppConstants.client_secret,
        'client_unique_id': AppConstants.deviceId,
        'mobile_name': AppConstants.deviceName,
        'app_name': AppConstants.appName,
        'user_email': email,
        'user_firstname': firstName,
        'user_lastname': lastName,
      },
    );

    return jsonDecode(response.body);
  }

  static Future userRegistration(
      String email, String firstName, String lastName, String password) async {
    final http.Response response = await http.post(
      Uri.parse(AppConstants.getServerPath() + "registration"),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: {
        'client_id': AppConstants.client_id,
        'client_secret': AppConstants.client_secret,
        'client_unique_id': AppConstants.deviceId,
        'mobile_name': AppConstants.deviceName,
        'app_name': AppConstants.appName,
        'user_email': email,
        'user_firstname': firstName,
        'user_lastname': lastName,
        'user_password': password,
      },
    );

    return jsonDecode(response.body);
  }

  static Future forgotPassword(String email) async {
    final http.Response response = await http.post(
      Uri.parse(AppConstants.getServerPath() + "registration/resetpassword"),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: {
        'client_id': AppConstants.client_id,
        'client_secret': AppConstants.client_secret,
        'user_email': email,
      },
    );

    return jsonDecode(response.body);
  }

  static Future request(String url, [options, file]) async {
    Map<String, dynamic> authorization = {};
    authorization['access_token'] = AppConstants.accessToken;
    authorization['client_unique_id'] = AppConstants.deviceId;

    Map<String, dynamic> data = {...?authorization, ...?options};

    Dio dio;
    Response response;

    // dio = dio ?? Dio();
    dio = Dio();
    dio
      ..options.baseUrl = AppConstants.getServerPath()
      ..options.connectTimeout = _defaultConnectTimeout
      ..options.receiveTimeout = _defaultReceiveTimeout
      ..httpClientAdapter
      ..options.headers = {
        // 'Authorization': 'Bearer ${AppConstants.accessToken}',
        'Content-Type': 'application/x-www-form-urlencoded'
      };

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: false,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }

    FormData formData = FormData.fromMap(data);

    if (file != null) {
      if (!kIsWeb) {
        formData.files.addAll([
          MapEntry(
            file['key'],
            MultipartFile.fromFileSync(file['path'],
                filename: file['fileName']),
          ),
        ]);
      } else if (file['bytes'] != null) {
        formData.files.addAll([
          MapEntry(
            file['key'],
            MultipartFile.fromBytes(file['bytes'], filename: file['fileName']),
          ),
        ]);
      }
    }

    try {
      response = await dio.post(
        url,
        data: formData,
      );

      if (kDebugMode) {
        print(jsonEncode(response.data));
      }
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        // print(jsonEncode(e.response.data));
        return e.response.data;
      } else {
        // print(e.request);
        // print(e.message);
      }
    }
  }

  static Future requestPdf(String url, [options, file]) async {
    // print(AppConstants.getServerPath() + url);

    Map<String, String> data = {};
    data['access_token'] = AppConstants.accessToken;
    data['client_unique_id'] = AppConstants.deviceId;

    var request = http.MultipartRequest(
        'POST', Uri.parse(AppConstants.getServerPath() + url));

    request.headers.addAll(
        {'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'});
    request.fields.addAll({...?data, ...?options});

    if (file != null) {
      request.files
          .add(await http.MultipartFile.fromPath(file['key'], file['path']));
    }

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    // var responseString = String.fromCharCodes(responseData);

    // print(responseString);

    return responseData;
  }

  // static Future request(String url, [options, file]) async {
  //   print(AppConstants.getServerPath() + url);

  //   Map<String, String> data = {};
  //   data['access_token'] = AppConstants.accessToken;
  //   data['client_unique_id'] = AppConstants.deviceId;

  //   print({...?data, ...?options});

  //   var request = http.MultipartRequest(
  //       'POST', Uri.parse(AppConstants.getServerPath() + url));

  //   request.headers.addAll(
  //       {'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'});
  //   request.fields.addAll({...?data, ...?options});

  //   if (file != null) {
  //     request.files
  //         .add(await http.MultipartFile.fromPath(file['key'], file['path']));
  //   }

  //   var response = await request.send();
  //   var responseData = await response.stream.toBytes();
  //   var responseString = String.fromCharCodes(responseData);

  //   print(responseString);

  //   return jsonDecode(responseString);
  // }
}
