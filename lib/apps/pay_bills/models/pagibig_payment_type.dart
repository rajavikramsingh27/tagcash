import 'dart:convert';

class PagibigPaymentType {
  int value;
  String name;

  PagibigPaymentType({this.value, this.name});

  PagibigPaymentType.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
  }

  static Map<String, dynamic> toMap(PagibigPaymentType pag) => {
        'value': pag.value,
        'name': pag.name,
      };

  static String encode(List<PagibigPaymentType> pags) => json.encode(
        pags
            .map<Map<String, dynamic>>((pag) => PagibigPaymentType.toMap(pag))
            .toList(),
      );

  static List<PagibigPaymentType> decode(String pags) =>
      (json.decode(pags) as List<dynamic>)
          .map<PagibigPaymentType>((item) => PagibigPaymentType.fromJson(item))
          .toList();
}
