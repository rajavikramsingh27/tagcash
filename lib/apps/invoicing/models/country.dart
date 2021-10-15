class Country {
  int id;
  String country_code;
  String country_name;

  Country(
      {this.id,
        this.country_code,
        this.country_name});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    country_code = json['country_code'];
    country_name = json['country_name'];
  }
}
