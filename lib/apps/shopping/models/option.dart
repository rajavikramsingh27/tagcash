class Option {
  String option;
  String price;

  Option(
      {this.option,
        this.price});

  Option.fromJson(Map<String, dynamic> json) {
    option = json['option'].toString();
    price = json['price'].toString();
  }

}
