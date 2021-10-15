class AdvertPrice {
  String message;
  List<AdvertWallet> advertWallets;

  AdvertPrice({this.message, this.advertWallets});

  AdvertPrice.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    var list = json['adverts_wallet_ids'] as List;
    advertWallets = list.map((i) => AdvertWallet.fromJson(i)).toList();
  }
}

class AdvertWallet {
  String id;
  String walletId;
  String walletCode;
  String item;
  String value;

  AdvertWallet(
      {this.id, this.walletId, this.walletCode, this.item, this.value});

  AdvertWallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    walletId = json['wallet_id'];
    walletCode = json['wallet_code'];
    item = json['item'];
    value = json['value'];
  }
}
