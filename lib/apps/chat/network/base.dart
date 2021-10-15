import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../network/exceptions.dart';
import '../utils/core/connectivity.dart';
import '../utils/core/parsing.dart';
import '../../../models/app_constants.dart' as AppConstants;

abstract class RestApiBaseService {
  Dio dio = Dio();

  RestApiBaseService() {
    BaseOptions options = BaseOptions(
      baseUrl: AppConstants.getChatServerUrl(),
      connectTimeout: 30000,
      receiveTimeout: 30000,
    );
    dio.interceptors.add(PrettyDioLogger());
    dio = Dio(options);
  }

  /// Helper Method - [getException]
  /// Return our own [Exception] from the [DioErrorType]
  TagcashException getException(dynamic error) {
    print(error.toString());
    if (error == null || ((error is DioError) == false))
      return GeneralException();
    final dioError = error as DioError;
    switch (dioError.type) {
      case DioErrorType.response:
        dynamic errorData = dioError.response.data['error'];
        String message = Parsing.stringFrom(errorData);
        if (message.isEmpty) {
          // Checking if the error comes in array of strings format
          List<String> messages = Parsing.arrayFrom(errorData)
              .map((element) => Parsing.stringFrom(element))
              .where((element) => element.isNotEmpty)
              .toList();
          if (messages.isNotEmpty) message = messages.first;
        }
        return message.isNotEmpty && errorData is int
            ? ApiResponseException(
                message: message,
                status: Parsing.intFrom(dioError.response.data['error']))
            : GeneralException();
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        return ApiTimedOutException();
      default:
        if (ConnectivityManager.shared.isNotAvailable())
          return InternetConnectivityException();
        return GeneralException();
    }
  }
}
