class BankSendHistory {
  int id;
  String refno;
  String txnid;
  String date;
  var amount;
  var fee;
  String currency;
  String status;
  String bankName;
  String beneficiaryName;
  String bankCode;

  BankSendHistory(
      {this.id,
      this.refno,
      this.txnid,
      this.date,
      this.amount,
      this.fee,
      this.currency,
      this.status,
      this.bankName,
      this.beneficiaryName,
      this.bankCode});

  BankSendHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    refno = json['refno'].toString();
    txnid = json['txnid'].toString();
    date = json['date'];
    amount = json['amount'];
    fee = json['fee'];
    currency = json['currency'];
    status = json['status'];
    bankName = json['bank_name'];
    beneficiaryName = json['beneficiary_name'];
    bankCode = json['bank_code'];
  }
}
