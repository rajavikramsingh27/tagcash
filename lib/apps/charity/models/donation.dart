class Donation {
  String name;
  String title;
  String createdDate;
  String walletCode;
  var amount;

  Donation({
    this.name,
    this.title,
    this.createdDate,
    this.walletCode,
    this.amount
  });

  Donation.fromJson(Map<String, dynamic> json) {
    name = json['charity_details']['user_name'];
    title = json['charity_details']['title'];
    createdDate = json['charity_details']['created_date'];
    walletCode = json['wallet_code'];
    amount = json['amount'];
  }
}