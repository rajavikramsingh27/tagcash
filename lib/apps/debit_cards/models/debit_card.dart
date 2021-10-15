class DebitCard {
  String id;
  String cardNo;
  String cvv;
  String expiryMonth;
  String expiryYear;
  String cardStatus;
  String cardName;
  var cardBalance;

  DebitCard({
    this.id,
    this.cardNo,
    this.cvv,
    this.expiryMonth,
    this.expiryYear,
    this.cardStatus,
    this.cardName,
    this.cardBalance
  });

  DebitCard.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cardNo = json['card_no'].toString().replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ");
    //cardNo = json['card_no'];
    cvv = json['cvv'];
    expiryMonth = json['expiry_month'];
    expiryYear = json['expiry_year'];
    cardStatus = json['card_status'];
    cardName = json['card_name'];
    cardBalance = json['card_balance'];
  }
}