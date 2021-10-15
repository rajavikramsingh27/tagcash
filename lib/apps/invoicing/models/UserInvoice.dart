class UserInvoice {
  String id;
  String customer_name;
  String invoice_date;
  String invoice_name;
  int invoice_no;
  String date;
  String currency;
  String total;
  String subtotal;
  String status;

  UserInvoice(
      {this.id,
        this.customer_name,
        this.invoice_date,
        this.invoice_name,
        this.invoice_no,
        this.date,
        this.currency,
        this.total,
        this.subtotal,
        this.status});

  UserInvoice.fromJson(Map<String, dynamic> json) {
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
  }
}
