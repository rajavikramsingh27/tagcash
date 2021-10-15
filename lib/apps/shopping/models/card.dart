class CardDetail {
  int id;
  int user_id;
  String brand;
  String country;
  int exp_month;
  int exp_year;
  String last_four;
  String name;

  CardDetail(this.id,
      this.user_id,
      this.brand,
      this.country,
      this.exp_month,
      this.exp_year,
      this.last_four,
      this.name);

  CardDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    brand = json['brand'];
    country = json['country'];
    exp_month = json['exp_month'];
    exp_year = json['exp_year'];
    exp_month = json['exp_month'];
    last_four = json['last_four'];
    name = json['name'].toString();
  }
}
