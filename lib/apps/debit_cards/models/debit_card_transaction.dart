class DebitCardTransaction {
  String transactionId;
  String ctbcTransactionId;
  String ctbcSessionId;
  String transactionDate;
  String transactionStatus;
  String accountNo;
  String amount;

  DebitCardTransaction({
    this.transactionId,
    this.ctbcTransactionId,
    this.ctbcSessionId,
    this.transactionDate,
    this.transactionStatus,
    this.accountNo,
    this.amount,
  });

  DebitCardTransaction.fromJson(Map<String, dynamic> json) {
    transactionId = json['transaction_id'];
    ctbcTransactionId = json['ctbc_transaction_id'];
    ctbcSessionId = json['ctbc_session_id'];
    transactionDate = json['transaction_date'];
    transactionStatus = json['transaction_status'];
    accountNo = json['account_no'].toString();
    amount = json['amount'];
  }
}