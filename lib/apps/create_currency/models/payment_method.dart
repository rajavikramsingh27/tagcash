class PaymentMethod {
  int paymentMethodId;
  String method;
  int walletId;
  String currencyCode;
  double amount;
  int multiplyBy;
  String symbol;


  PaymentMethod({
    this.paymentMethodId,
    this.method,
    this.walletId,
    this.currencyCode,
    this.amount,
    this.multiplyBy,
    this.symbol
  });

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    paymentMethodId = json['payment_method_id'];
    method = json['method'];
    walletId = json['wallet_id'];
    currencyCode = json['currency_code'];
    amount = json['amount'].toDouble();
    multiplyBy = json['multiply_by'];
    symbol = json['symbol'];
  }
}
