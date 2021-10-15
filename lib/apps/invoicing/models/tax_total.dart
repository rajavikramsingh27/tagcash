class Tax_total {
  String id;
  String name;
  String rate;
  String tax_id;
  String recoverable;
  String compound;
  String price;
  String amount;

  Tax_total(
      {this.id,
        this.name,
        this.rate,
        this.tax_id,
        this.recoverable,
        this.compound,
        this.price,
        this.amount});

  Tax_total.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
    tax_id = json['tax_id'];
    recoverable = json['recoverable'];
    compound = json['compound'];
    compound = json['price'];
    amount = json['amount'];
  }
}
