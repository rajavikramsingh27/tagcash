import 'dart:convert';

class Biller {
  String billerTag;
  String description;
  String firstField;
  String firstFieldFormat;
  int firstFieldWidth;
  String secondField;
  String secondFieldFormat;
  int secondFieldWidth;
  int serviceCharge;

  Biller(
      {this.billerTag,
      this.description,
      this.firstField,
      this.firstFieldFormat,
      this.firstFieldWidth,
      this.secondField,
      this.secondFieldFormat,
      this.secondFieldWidth,
      this.serviceCharge});

  Biller.fromJson(Map<String, dynamic> json) {
    billerTag = json['BillerTag'];
    description = json['Description'];
    firstField = json['FirstField'];
    firstFieldFormat = json['FirstFieldFormat'];
    firstFieldWidth = json['FirstFieldWidth'];
    secondField = json['SecondField'];
    secondFieldFormat = json['SecondFieldFormat'];
    secondFieldWidth = json['SecondFieldWidth'];
    serviceCharge = json['ServiceCharge'];
  }

  static Map<String, dynamic> toMap(Biller biller) => {
    'BillerTag': biller.billerTag,
    'Description': biller.description,
    'FirstField': biller.firstField,
    'FirstFieldFormat': biller.firstFieldFormat,
    'FirstFieldWidth': biller.firstFieldWidth,
    'SecondField': biller.secondField,
    'SecondFieldFormat': biller.secondFieldFormat,
    'SecondFieldWidth': biller.secondFieldWidth,
    'ServiceCharge': biller.serviceCharge,
  };

  static String encode(List<Biller> billers) => json.encode(
    billers
        .map<Map<String, dynamic>>(
            (biller) => Biller.toMap(biller))
        .toList(),
  );

  static List<Biller> decode(String billers) => (json
      .decode(billers) as List<dynamic>)
      .map<Biller>((item) => Biller.fromJson(item))
      .toList();
}
