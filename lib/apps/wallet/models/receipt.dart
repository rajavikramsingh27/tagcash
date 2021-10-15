class Receipt {
  String type;
  String direction;
  int walletId;
  String amount;
  String currencyCode;
  String narration;
  String date;
  String transactionId;
  String toId;
  String toType;
  String name;
  String scratchcardGameId;
  String winCombinationId;

  Receipt({
    this.type,
    this.direction,
    this.walletId,
    this.amount,
    this.currencyCode,
    this.narration,
    this.date,
    this.transactionId,
    this.toId,
    this.toType,
    this.name,
    this.scratchcardGameId,
    this.winCombinationId,
  });
}
