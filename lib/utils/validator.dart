import 'dart:convert';

import 'package:intl/intl.dart';

RegExp _ipv4Maybe =
    new RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
RegExp _ipv6 =
    new RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

class Validator {
  static bool isRequired(String value, {bool allowEmptySpaces = true}) {
    if (value == null || value.isEmpty) {
      return false;
    } else {
      if (!allowEmptySpaces) {
        // Check if the string is not only made of empty spaces
        if (RegExp(r"\s").hasMatch(value)) {
          return false;
        }
      }
      return true; // passed
    }
  }

  static bool isEmail(String email) {
    if (!isRequired(email)) return false;

    // final emailRegex = RegExp(
    // r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    // RegExp(r'(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');

    final emailRegex = RegExp(
        r"^((([a-zA-Z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-zA-Z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-zA-Z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-zA-Z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-zA-Z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-zA-Z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-zA-Z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-zA-Z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
    if (emailRegex.hasMatch(email))
      return true;
    else
      return false;
  }

  static bool isMobile(String value) {
    if (!isRequired(value)) return false;
    if (value.length < 10) return false;

    var mobileRegExp = RegExp(r"^[0-9]+$");

    return mobileRegExp.hasMatch(value);
  }

  static isNumber(String value, {bool allowSymbols = true}) {
    if (value == null) return false;

    var numericRegEx = RegExp(r"^[+-]?([0-9]*[.])?[0-9]+$");
    var numericNoSymbolsRegExp = RegExp(r"^[0-9]+$");

    if (allowSymbols) {
      return numericRegEx.hasMatch(value);
    } else
      return numericNoSymbolsRegExp.hasMatch(value);
  }

  static isAmount(String value) {
    if (!isRequired(value)) return false;
    if (!isNumber(value)) return false;

    String amountValue = value.replaceAll(',', '');
    var amount = double.tryParse(amountValue);
    // var amount = double.tryParse(value);

    if (amount > 0) {
      return true;
    } else {
      return false;
    }
  }

  static isAddress(String value) {
    if (!isRequired(value)) return false;
    if (!isAlphaNumeric(value)) return false;

    if (value.length > 20) {
      return true;
    } else {
      return false;
    }
  }

  static bool isUppercase(String value) {
    if (value == null) return false;
    return value.compareTo(value.toUpperCase()) == 0;
  }

  static bool isLowercase(String value) {
    if (value == null) return false;
    return value.compareTo(value.toLowerCase()) == 0;
  }

  static bool isAlphaNumeric(String value) {
    if (value == null) return false;
    var alphaNumRegExp = RegExp(r"^[0-9A-Z]+$", caseSensitive: false);
    return alphaNumRegExp.hasMatch(value);
  }

  static bool isAlpha(String value) {
    if (value == null) return false;
    var alphaRegExp = RegExp(r"^[A-Z]+$", caseSensitive: false);
    return alphaRegExp.hasMatch(value);
  }

  static bool isJSON(String input) {
    try {
      jsonDecode(input);
    } catch (e) {
      return false;
    }
    return true;
  }

  static bool isHexadecimal(String value) {
    if (value == null) return false;

    RegExp hexRegExp = RegExp(r"/^[0-9A-F]+$/i");
    return hexRegExp.hasMatch(value);
  }

  /// check if the string [str] is a URL
  ///
  /// * [protocols] sets the list of allowed protocols
  /// * [requireTld] sets if TLD is required
  /// * [requireProtocol] is a `bool` that sets if protocol is required for validation
  /// * [allowUnderscore] sets if underscores are allowed
  /// * [hostWhitelist] sets the list of allowed hosts
  /// * [hostBlacklist] sets the list of disallowed hosts
  static bool isURL(String str,
      {List<String> protocols = const ['https'],
      bool requireTld = true,
      bool requireProtocol = false,
      bool allowUnderscore = false,
      List<String> hostWhitelist = const [],
      List<String> hostBlacklist = const []}) {
    if (str == null ||
        str.length == 0 ||
        str.length > 2083 ||
        str.startsWith('mailto:')) {
      return false;
    }

    var protocol,
        user,
        auth,
        host,
        hostname,
        port,
        port_str,
        path,
        query,
        hash,
        split;

    // check protocol
    split = str.split('://');
    if (split.length > 1) {
      protocol = shift(split);
      if (protocols.indexOf(protocol) == -1) {
        return false;
      }
    } else if (requireProtocol == true) {
      return false;
    }
    str = split.join('://');

    // check hash
    split = str.split('#');
    str = shift(split);
    hash = split.join('#');
    if (hash != null && hash != "" && new RegExp(r'\s').hasMatch(hash)) {
      return false;
    }

    // check query params
    split = str.split('?');
    str = shift(split);
    query = split.join('?');
    if (query != null && query != "" && new RegExp(r'\s').hasMatch(query)) {
      return false;
    }

    // check path
    split = str.split('/');
    str = shift(split);
    path = split.join('/');
    if (path != null && path != "" && new RegExp(r'\s').hasMatch(path)) {
      return false;
    }

    // check auth type urls
    split = str.split('@');
    if (split.length > 1) {
      auth = shift(split);
      if (auth.indexOf(':') >= 0) {
        auth = auth.split(':');
        user = shift(auth);
        if (!new RegExp(r'^\S+$').hasMatch(user)) {
          return false;
        }
        if (!new RegExp(r'^\S*$').hasMatch(user)) {
          return false;
        }
      }
    }

    // check hostname
    hostname = split.join('@');
    split = hostname.split(':');
    host = shift(split);
    if (split.length > 0) {
      port_str = split.join(':');
      try {
        port = int.parse(port_str, radix: 10);
      } catch (e) {
        return false;
      }
      if (!new RegExp(r'^[0-9]+$').hasMatch(port_str) ||
          port <= 0 ||
          port > 65535) {
        return false;
      }
    }

    if (!isIP(host) &&
        !isFQDN(host,
            requireTld: requireTld, allowUnderscores: allowUnderscore) &&
        host != 'localhost') {
      return false;
    }

    if (hostWhitelist.isNotEmpty && !hostWhitelist.contains(host)) {
      return false;
    }

    if (hostBlacklist.isNotEmpty && hostBlacklist.contains(host)) {
      return false;
    }

    return true;
  }

  static shift(List l) {
    if (l.length >= 1) {
      var first = l.first;
      l.removeAt(0);
      return first;
    }
    return null;
  }

  /// check if the string [str] is IP [version] 4 or 6
  ///
  /// * [version] is a String or an `int`.
  static bool isIP(String str, [/*<String | int>*/ version]) {
    version = version.toString();
    if (version == 'null') {
      return isIP(str, 4) || isIP(str, 6);
    } else if (version == '4') {
      if (!_ipv4Maybe.hasMatch(str)) {
        return false;
      }
      var parts = str.split('.');
      parts.sort((a, b) => int.parse(a) - int.parse(b));
      return int.parse(parts[3]) <= 255;
    }
    return version == '6' && _ipv6.hasMatch(str);
  }

  /// check if the string [str] is a fully qualified domain name (e.g. domain.com).
  ///
  /// * [requireTld] sets if TLD is required
  /// * [allowUnderscore] sets if underscores are allowed
  static bool isFQDN(String str,
      {bool requireTld = true, bool allowUnderscores = false}) {
    var parts = str.split('.');
    if (requireTld) {
      var tld = parts.removeLast();
      if (parts.length == 0 || !new RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
        return false;
      }
    }

    for (var part in parts) {
      if (allowUnderscores) {
        if (part.contains('__')) {
          return false;
        }
      }
      if (!new RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
        return false;
      }
      if (part[0] == '-' ||
          part[part.length - 1] == '-' ||
          part.indexOf('---') >= 0) {
        return false;
      }
    }
    return true;
  }

  static bool isValidAge(String pickedDate) {
    if (pickedDate == null) return false;
    DateTime nowDate = DateTime.now();
    DateFormat inputFormat = DateFormat("dd-MM-yyyy");
    DateTime inputDate = inputFormat.parse(pickedDate);
    DateFormat outputFormat = DateFormat("yyyy-MM-dd");
    DateTime outputDate = outputFormat.parse(inputDate.toString());
    int diffDays = (nowDate.difference(outputDate).inDays);
    int differenceInYears = (diffDays / 365).floor();
    if (differenceInYears < 18) {
      return false;
    } else {
      return true;
    }
  }
}
