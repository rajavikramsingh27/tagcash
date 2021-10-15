import 'dart:convert';

String textToJson(List<Tax> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
List<Tax> TaxFromJson(String str) =>
    List<Tax>.from(json.decode(str).map((x) => Tax.fromJson(x)));

class Tax {
  String id;
  String name;
  String rate;
  String tax_id;
  String recoverable;
  String compound;

  Tax(
      {this.id,
        this.name,
        this.rate,
        this.tax_id,
        this.recoverable,
        this.compound});

  Tax.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
    tax_id = json['tax_id'];
    recoverable = json['recoverable'];
    compound = json['compound'];
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "rate": rate,
    "tax_id": tax_id,
    "recoverable": recoverable,
    "compound": compound,
  };
}
