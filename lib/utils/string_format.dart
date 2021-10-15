import 'package:flutter/cupertino.dart';

class StringFormat {
  static Color stringToColor(name) {
    List<String> colors = [
      'd32f2f',
      'C2185B',
      '7B1FA2',
      '512DA8',
      '303F9F',
      '1976D2',
      '0288D1',
      '0097A7',
      '00796B',
      '388E3C',
      '689F38',
      'AFB42B',
      'FBC02D',
      'FFA000',
      'F57C00',
      'E64A19',
      '5D4037',
      '616161',
      '455A64'
    ];
    int hash = _hashStr(name);
    int index = hash % colors.length;
    String colorStr = "FF" + colors[index];
    return Color(int.parse(colorStr, radix: 16));
  }

//very simple hash
  static int _hashStr(str) {
    int hash = 0;

    for (var i = 0; i < str.length; i++) {
      int charCode = str.codeUnitAt(i);
      hash += charCode;
    }
    return hash;
  }
}
