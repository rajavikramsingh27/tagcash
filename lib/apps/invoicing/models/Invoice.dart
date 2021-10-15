class Invoice {
  String id;
  String customer_name;
  String invoice_date;
  String invoice_name;
  String invoice_no;
  String date;
  String currency;
  String total;
  String subtotal;
  String status;
  String email;
  String payment_date;
  String customer_id;
  String customeraddress1;
  String customeraddress2;
  String customercity;
  String customerzipcode;
  String customerstate;
  String customercountry;
  String customer_phone;
  var payment_due;

  Invoice(
      {this.id,
        this.customer_name,
        this.invoice_date,
        this.invoice_name,
        this.invoice_no,
        this.date,
        this.currency,
        this.total,
        this.subtotal,
        this.status,
        this.email,
        this.payment_date,
        this.customer_id,
        this.customeraddress1,
        this.customeraddress2,
        this.customercity,
        this.customerzipcode,
        this.customerstate,
        this.customercountry,
        this.customer_phone,
      this.payment_due});

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customer_name = json['customer_name'];
    invoice_date = json['invoice_date'];
    invoice_name = json['invoice_name'];
    invoice_no = json['invoice_no'];
    date = json['payment_due']['date'];
    currency = json['currency'];
    total = json['total'];
    subtotal = json['subtotal'];
    status = json['status'];
    email = json['customer']['email'];
    payment_date = json['payment_due']['date'];
    customer_id = json['customer']['id'];

    if(json['customer']['address'] == '' || json['customer']['address'] == null){
      customeraddress1 = '';
      customeraddress2 = '';
      customercity = '';
      customerzipcode = '';
      customerstate = '';
      customercountry = '';
    } else{
      customeraddress1 = json['customer']['address']['address1'];
      customeraddress2 = json['customer']['address']['address2'];
      customercity = json['customer']['address']['city'];
      customerzipcode = json['customer']['address']['zipCode'];
      customerstate = json['customer']['address']['state']['addressState'];
      customercountry = json['customer']['address']['country']['addressCountry'];
    }
    customer_phone = json['customer']['phone_no'];
  }
}
