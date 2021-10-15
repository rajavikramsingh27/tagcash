import 'package:http/http.dart';
import 'package:tagcash/apps/crypto_wallet/utils/ETH.dart';
import 'package:web3dart/web3dart.dart';

class Web3Context {
  String chainName;
  String chianURL;
  String SYMBOL;
  String abiCode;
  Web3Client web3Client;
  ETH eth;
  Web3Context(
      this.chianURL, this.eth, this.abiCode, this.SYMBOL, this.chainName) {
    setup();
  }

  void setup() {
    var httpClient = new Client();
    this.web3Client = new Web3Client(chianURL, httpClient);
  }
}
