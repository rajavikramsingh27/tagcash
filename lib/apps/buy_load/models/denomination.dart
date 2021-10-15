class Denomination {
  String telcoTag;
  String telcoName;
  String denomination;
  String extTag;

  Denomination({this.telcoTag, this.telcoName, this.denomination, this.extTag});

  Denomination.fromJson(Map<String, dynamic> json) {
    telcoTag = json['TelcoTag'];
    telcoName = json['TelcoName'];
    denomination = json['Denomination'].toString();
    extTag = json['ExtTag'];
  }
}
