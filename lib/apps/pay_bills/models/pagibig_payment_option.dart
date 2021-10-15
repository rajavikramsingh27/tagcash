import 'dart:convert';

class PagibigPaymentOption {
  String value;
  String name;

  PagibigPaymentOption({this.value, this.name});

  PagibigPaymentOption.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
  }

  static Map<String, dynamic> toMap(PagibigPaymentOption pag) => {
        'value': pag.value,
        'name': pag.name,
      };

  static String encode(List<PagibigPaymentOption> pags) => json.encode(
        pags
            .map<Map<String, dynamic>>(
                (pag) => PagibigPaymentOption.toMap(pag))
            .toList(),
      );

  static List<PagibigPaymentOption> decode(String pags) => (json
          .decode(pags) as List<dynamic>)
      .map<PagibigPaymentOption>((item) => PagibigPaymentOption.fromJson(item))
      .toList();
}
