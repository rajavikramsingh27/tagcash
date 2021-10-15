
class Address {
  String id;
  String user_id;
  String user_type;
  String name;
  String first_name;
  String address;
  String phone;
  String city;
  String postal_code;
  String is_default;
  String created_date;

  Address(
      {this.id, this.user_id, this.user_type, this.name, this.first_name, this.address, this.phone,
        this.city, this.postal_code, this.is_default, this.created_date});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    user_type = json['user_type'];
    name = json['name'];
    first_name = json['first_name'];
    address = json['address'];
    phone = json['phone'].toString();
    city = json['city'];
    postal_code = json['postal_code'].toString();
    is_default = json['is_default'];
    created_date = json['created_date'];
  }

}
