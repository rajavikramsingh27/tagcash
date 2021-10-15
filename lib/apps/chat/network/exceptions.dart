class TagcashException implements Exception {
  final String message;
  final int status;

  const TagcashException([this.message = "", this.status = 0]) : super();

  @override
  String toString() => message;
}

/// Internet Connectivity
class InternetConnectivityException extends TagcashException {
  final String message;
  final int status;

  const InternetConnectivityException({
    this.message =
        'There is no internet connection. Please connect to an active internet connection.',
    this.status = 0,
  }) : super(message, status);
}

/// Api - TimedOut
class ApiTimedOutException extends TagcashException {
  final String message;
  final int status;

  const ApiTimedOutException({
    this.message = 'Request is timed out. Please try again.',
    this.status = 0,
  }) : super(message, status);
}

/// Api - TimedOut
class ApiResponseException extends TagcashException {
  final String message;
  final int status;

  const ApiResponseException({this.message = '', this.status = 0})
      : super(message, status);
}

/// General
class GeneralException extends TagcashException {
  final String message;
  final int status;

  const GeneralException({this.message = '', this.status = 0})
      : super(message, status);
}
