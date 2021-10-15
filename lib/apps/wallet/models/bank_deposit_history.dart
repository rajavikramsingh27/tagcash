class BankDepositHistory {
  int id;
  String refno;
  String txnid;
  String date;
  String amount;
  String currency;
  String status;
  String statusText;
  String method;
  bool removing = false;

  BankDepositHistory(
      {this.id,
      this.refno,
      this.txnid,
      this.date,
      this.amount,
      this.currency,
      this.status,
      this.statusText,
      this.method});

  BankDepositHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    refno = json['refno'].toString();
    txnid = json['txnid'].toString();
    date = json['date'];
    amount = json['amount'].toString();
    currency = json['currency'];
    status = json['status'];
    statusText = statusDisplay(json['status']);
    method = json['method'];
  }

  String statusDisplay(String status) {
    String statusReturn = 'pending';
    if (status == 'S') {
      statusReturn = 'success';
    } else if (status == 'D') {
      statusReturn = 'declined';
    }

    return statusReturn;
  }
}
