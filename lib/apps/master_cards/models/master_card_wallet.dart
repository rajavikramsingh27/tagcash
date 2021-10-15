class MasterCardWallet {
  String pcmId;
  String walletId;
  String amount;
  String walletName;

  MasterCardWallet({this.pcmId,this.walletId, this.amount,this.walletName});

  MasterCardWallet.fromJson(Map<String, dynamic> json) {
    pcmId = json['pcm_id'];
    walletId = json['wallet_id'];
    var arr = double.parse(json['amount']).round();
    amount = arr.toString();
    walletName = json['wallet_name'];
  }
}
