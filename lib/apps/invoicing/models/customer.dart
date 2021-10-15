class Customer {
  String id;
  String customer_name;
  String email;
  String contact_name;
  String phone_no;
  String mobile_no;
  String currency;
  var address;
  var shipping_details;
  String accounting_number;
  String website;
  String type;
  String merchant_id;



  Customer(
      {this.id,
        this.customer_name,
        this.email,
        this.contact_name,
        this.phone_no,
        this.mobile_no,
        this.currency,
        this.address,
        this.shipping_details,
        this.accounting_number,
        this.website,
        this.type,
        this.merchant_id});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customer_name = json['customer_name'];
    email = json['email'];
    contact_name = json['contact_name'];
    phone_no = json['phone_no'];
    mobile_no = json['mobile_no'];
    currency = json['currency'];
    address = json['address'];
    shipping_details = json['shipping_details'];
    accounting_number = json['accounting_number'];
    website = json['website'];
    type = json['type'];
    merchant_id = json['merchant_id'];
  }
}
