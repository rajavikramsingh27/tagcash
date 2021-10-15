class DebitWallet {
  String pcmId;
  String walletId;
  String amount;
  String walletName;

  DebitWallet({this.pcmId,this.walletId, this.amount,this.walletName});

  DebitWallet.fromJson(Map<String, dynamic> json) {
    pcmId = json['pcm_id'];
    walletId = json['wallet_id'];
    var arr = double.parse(json['amount']).round();
    amount = arr.toString();
    walletName = json['wallet_name'];
  }
}
