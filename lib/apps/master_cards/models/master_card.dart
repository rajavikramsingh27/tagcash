class MasterCard {
  String cardNo;
  String cvv;
  String expiryDate;
  String validDate;
  String cardStatus;
  String cardType;
  String cardHolderName;

  MasterCard({
    this.cardNo,
    this.cvv,
    this.expiryDate,
    this.validDate,
    this.cardStatus,
    this.cardType,
    this.cardHolderName
  });

  MasterCard.fromJson(Map<String, dynamic> json) {
    cardNo = json['card_no'].toString().replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ");
    //cardNo = json['card_no'];
    cvv = json['cvv'];
    expiryDate = json['expiry_date'];
    validDate = json['valid_date'];
    cardStatus = json['card_status'];
    cardType = json['card_type'];
    cardHolderName = json['card_holder_name'];
  }
}