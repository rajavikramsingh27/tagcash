import 'dart:convert' as convert;

class Parsing {
  Parsing._();

  /// Get Integer from Dynamic Data
  static int intFrom(dynamic data, {int defaultValue = 0}) {
    if (null == data) return defaultValue;
    if (data is int) return data;
    if (data is double) return data.toInt();
    if (data is String) return _intFromString(data, defaultValue: defaultValue);
    return defaultValue;
  }

  /// Get Double from Dynamic Data
  static double doubleFrom(dynamic data, {double defaultValue = 0}) {
    if (null == data) return defaultValue;
    if (data is double) return data;
    if (data is int) return data.toDouble();
    if (data is String)
      return _doubleFromString(data, defaultValue: defaultValue);
    return defaultValue;
  }

  /// Get String from Dynamic Data
  static String stringFrom(dynamic data, {String defaultValue = ""}) {
    if (null == data) return defaultValue;
    if (data is String) return data;
    if (data is int) return "$data";
    if (data is double) return "$data";
    return defaultValue;
  }

  /// Get Bool from Dynamic Data
  static bool boolFrom(dynamic data, {bool defaultValue = false}) {
    if (null == data) return defaultValue;
    if (data is bool) return data;
    if (data is int || data is double) return data == 1;
    if (data is String)
      return (data == "1" ||
              data.toLowerCase() == "true" ||
              data.toLowerCase() == "yes")
          ? true
          : defaultValue;
    return defaultValue;
  }

  /// Get Array from Dynamic Data
  static List arrayFrom(dynamic data, {bool makeNull = false}) {
    if (null == data) return makeNull ? null : [];
    if (data is List) return data;
    if (data is String) {
      try {
        final newData = convert.jsonDecode(data);
        if (newData is List) return newData;
      } catch (e) {}
    }
    return makeNull ? null : [];
  }

  /// Get Map from Dynamic Data
  static Map<String, dynamic> mapFrom(dynamic data, {bool makeNull = false}) {
    if (null == data) return makeNull ? null : {};
    if (data is Map)
      return data.map((key, value) => MapEntry(key.toString(), value));
    if (data is String) {
      try {
        final newData = convert.jsonDecode(data);
        if (newData is Map)
          return newData.map((key, value) => MapEntry(key.toString(), value));
      } catch (e) {}
    }
    return makeNull ? null : {};
  }

  /// Get Map from Dynamic Data
  static Map<String, dynamic> cloneMap(Map<String, dynamic> data,
      {bool makeNull = false}) {
    if (null == data) return makeNull ? null : {};
    try {
      final stringData = convert.jsonEncode(data);
      final newData = convert.jsonDecode(stringData);
      if (newData is Map)
        return newData.map((key, value) => MapEntry(key.toString(), value));
    } catch (e) {}
    return makeNull ? null : {};
  }

  static int _intFromString(String data, {int defaultValue = 0}) {
    return int.tryParse(data) ??
        double.tryParse(data)?.toInt() ??
        defaultValue?.toDouble()?.toInt();
  }

  static double _doubleFromString(String data, {double defaultValue = 0}) {
    return double.tryParse(data) ??
        int.tryParse(data)?.toDouble() ??
        defaultValue?.toInt()?.toDouble();
  }

  /// Helper Method - [containValues]
  /// Return true if given [data] contains values
  /// or return false
  static bool containValues(dynamic data) {
    if (data == null) return false;
    if (data is String) return data.isNotEmpty;
    if (data is List) return data.isNotEmpty;
    if (data is Map) return data.isNotEmpty;
    if (data is int) return true;
    if (data is double) return true;
    return false;
  }
}
