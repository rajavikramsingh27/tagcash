class LendTransaction {
  var incomeAmount;
  int inTransactionCount;
  var outAmount;
  int outTransactionCount;
  String fromDateFormatted;
  String toDateFormatted;

  LendTransaction({this.incomeAmount,
    this.inTransactionCount,
    this.outAmount,
    this.outTransactionCount,
    this.fromDateFormatted,
    this.toDateFormatted
  });

  LendTransaction.fromJson(Map<String, dynamic> json) {
    incomeAmount = double.parse((json['income_amount']).toStringAsFixed(2));
    inTransactionCount = json['in_transaction_count'];
    outAmount = double.parse((json['out_amount']).toStringAsFixed(2));
    outTransactionCount = json['out_transaction_count'];
    fromDateFormatted = json['from_date_formatted'];
    toDateFormatted = json['to_date_formatted'];
  }
}