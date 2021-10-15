class CountryCallCode {
  String  callingCode;
  String countryName;

  CountryCallCode(
      {this.callingCode,
      this.countryName});

  CountryCallCode.fromJson(Map<String, dynamic> json) {
    callingCode = json['country_callingcode'].toString();
    countryName = json['country_name'];
   
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_callingcode'] = this.callingCode.toString();
    data['country_name'] = this.countryName;
    return data;
  }
}