class Cities {
  String  cityId;
  String cityName;
  Cities(this.cityId,
      this.cityName,
      );

  Cities.fromJson(Map<String, dynamic> json) {
    cityId = json['id'];
    cityName= json['city_name'];

  }
}