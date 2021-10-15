import 'package:tagcash/apps/crypto_wallet/models/TagbondModel.dart';

class WalletDataModel {
  static const String ASSETS_TYPE_TOKEN = "token";
  static const String ASSETS_TYPE_COIN = "coin";

  List<Wallets> wallets;
  WalletDataModel({this.wallets});

  factory WalletDataModel.fromJson(Map<String, dynamic> json) {
    var walletList = json['walletData'] as List;
    List<Wallets> wallets = walletList.map((e) => Wallets.fromJson(e)).toList();
    return WalletDataModel(wallets: wallets);
  }
}

class Wallets {
  String name;
  String symbol;
  String address;
  String balance;
  String type;
  String familyName;
  String tokenId;
  String image;
  String chain;

  Wallets(
      {this.name,
      this.symbol,
      this.address,
      this.balance,
      this.type,
      this.familyName,
      this.tokenId,
      this.image,
      this.chain});

  factory Wallets.fromJson(Map<String, dynamic> json) {
    return Wallets(
        name: json['name'],
        symbol: json['symbol'],
        address: json['address'],
        balance: json['balance'],
        type: json['type'],
        familyName: json['familyName'],
        tokenId: json['tokenId'],
        image: json['image'],
        chain: json['chain']);
  }

  Future<String> getPrivateKey(TagbondModel tagbondModel) async {
    String privateKey;
    if (type == WalletDataModel.ASSETS_TYPE_COIN) {
      switch (symbol) {
        case "BTC":
          privateKey = tagbondModel.getBTCPrivateKey();
          break;
        case "XLM":
          privateKey = tagbondModel.getXLMPrivateKey();
          break;
        case "ETH":
          privateKey = tagbondModel.getETHPrivateKey();
          break;
      }
    } else {
      privateKey = tagbondModel.getETHPrivateKey();
    }
    return privateKey;
  }
}
