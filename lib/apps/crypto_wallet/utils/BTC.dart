import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:fbroadcast/fbroadcast.dart';
import "package:hex/hex.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tagcash/models/app_constants.dart' as AppConstant;
import 'package:web_socket_channel/io.dart';

class BTC {
  static String BTC_TOKEN = "cda468b0afa146b8becdb40fdbcb22de";
  static String BTC_API_URL = AppConstant.getBTCAPIURL();
  static String BTC_BALANCE_UPDATE = "btc_balance_update";
  static String SYMBOL = "BTC";

  BTCKeys _btcKeys;

  BTC(this._btcKeys);

  void btcINIT() {
    try {
      String address = getPublicKey();
      var channel = IOWebSocketChannel.connect(Uri.parse(
          'wss://socket.blockcypher.com/v1/btc/test3?token=$BTC_TOKEN'));
      // channel.sink.add('{ "event": "ping" }');
      // channel.sink.add('{"event": "unconfirmed-tx"}');
      channel.sink.add('{"event": "tx-confirmation", "address": "${address}"}');
      channel.stream.listen((message) {
        FBroadcast.instance().broadcast(BTC_BALANCE_UPDATE);
      });
    } catch (err) {
      print("here in error => " + err.toString());
    }
  }

  static Future<BTCKeys> createWallet(String mnemonic, {int index = 0}) async {
    try {
      var seed = bip39.mnemonicToSeedHex(mnemonic);
      var hdWallet = new HDWallet.fromSeed(HEX.decode(seed), network: testnet);
      return BTCKeys(hdWallet.privKey, hdWallet.address);
    } catch (err) {
      throw new Exception(err);
    }
  }

  static Future<BTCKeys> getKeysFromPrivateKey(String privateKey) async {
    try {
      final keys = ECPair.fromPrivateKey(HEX.decode(privateKey));
      Wallet wallet = Wallet.fromWIF(keys.toWIF());
      return BTCKeys(privateKey, wallet.pubKey);
    } catch (err) {
      throw new Exception(err);
    }
  }

  String getPublicKey() {
    return _btcKeys.publicKey;
  }

  String getPrivateKey() {
    return _btcKeys.privateKey;
  }

  static int btcToSatoshi(double btc) {
    return (btc * 100000000).toInt();
  }

  static double satoshiToBTC(int satoshi) {
    return double.parse((satoshi / 100000000).toString());
  }

  Future<BTCBalanceDetails> getBTCBalance(String address) async {
    try {
      print("${BTC_API_URL}addrs/${address}/balance");
      final http.Response response = await http.get(Uri.parse(
          "${BTC_API_URL}addrs/${address}/balance?token=${BTC_TOKEN}"));
      BTCBalanceDetails bTCBalanceDetails =
          BTCBalanceDetails.fromJson(jsonDecode(response.body));
      return bTCBalanceDetails;
    } catch (err) {
      throw new Exception(err.toString());
    }
  }

  Future<TXSkeleton> newTransaction(
      String toAddress, String fromAddress, double btc) async {
    try {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['inputs'] = [
        {
          'addresses': [fromAddress]
        }
      ];
      data['outputs'] = [
        {
          'addresses': [toAddress],
          'value': btcToSatoshi(btc)
        }
      ];
      final http.Response response = await http.post(
          Uri.parse(BTC_API_URL + "txs/new?token=" + BTC_TOKEN),
          headers: {"Content-Type": "application/json"},
          body: json.encode(data));
      TXSkeleton txSkeleton = TXSkeleton.fromJson(jsonDecode(response.body));
      return txSkeleton;
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<TX> pushTransaction(
      String toAddress, double btc, String prevHash, int index) async {
    try {
      String privateKey = getPrivateKey();
      final alice =
          ECPair.fromPrivateKey(HEX.decode(privateKey), network: testnet);
      final txb = new TransactionBuilder(network: testnet);

      txb.setVersion(1);
      txb.addInput(prevHash, index);
      print(
          "BTC to Address => ${toAddress}, ${privateKey}, ${prevHash}, ${index}");
      txb.addOutput(toAddress, btcToSatoshi(btc));
      txb.sign(vin: 0, keyPair: alice);
      final tx = txb.build();

      final http.Response response = await http.post(
          Uri.parse(BTC_API_URL + "txs/push?token=" + BTC_TOKEN),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"tx": tx.toHex()}));
      var jsonData = jsonDecode(response.body);
      return TX.fromJson(jsonData["tx"]);
    } catch (e) {
      print(e);
      throw new Exception(e);
    }
  }
}

class BTCKeys {
  String privateKey;
  String publicKey;

  BTCKeys(this.privateKey, this.publicKey);

  Map toJson() => {"privateKey": this.privateKey, "publicKey": this.publicKey};
}

class TXSkeleton {
  TX tx;
  List<String> errors = [];
  TXSkeleton(dynamic tx, List<dynamic> errors) {
    this.tx = TX.fromJson(tx);

    if (errors != null && errors.length > 0) {
      errors.forEach((element) {
        this.errors.add(element["error"]);
      });
    }
  }
  factory TXSkeleton.fromJson(Map<String, dynamic> json) {
    return TXSkeleton(json['tx'], json['errors']);
  }
}

class TX {
  String hash;
  int total;
  double fees;
  List<TXInput> inputs;
  TX(this.hash, this.total, this.fees, List inputs) {
    this.inputs = inputs.map((e) => TXInput.fromJson(e)).toList();
  }

  factory TX.fromJson(Map<String, dynamic> json) {
    return TX(json['hash'], json['total'], BTC.satoshiToBTC(json['fees']),
        json['inputs']);
  }
}

class TXInput {
  String prev_hash;
  int output_index;
  String script;
  int sequence;
  String script_type;
  int age;
  TXInput(this.prev_hash, this.output_index, this.script, this.sequence,
      this.script_type, this.age);

  factory TXInput.fromJson(Map<String, dynamic> json) {
    return TXInput(json['prev_hash'], json['output_index'], json['script'],
        json['sequence'], json['script_type'], json['age']);
  }
}

class BTCBalanceDetails {
  String address;
  int totalReceived;
  int totalSent;
  int balance;
  int unconfirmedBalance;
  int finalBalance;
  int nTx;
  int unconfirmedNTx;
  int finalNTx;

  String getFinalBalance() {
    return BTC.satoshiToBTC(finalBalance).toString();
  }

  BTCBalanceDetails(
      this.address,
      this.totalReceived,
      this.totalSent,
      this.balance,
      this.unconfirmedBalance,
      this.finalBalance,
      this.nTx,
      this.unconfirmedNTx,
      this.finalNTx);
  factory BTCBalanceDetails.fromJson(Map<String, dynamic> json) {
    return BTCBalanceDetails(
        json['address'],
        json['total_received'],
        json['total_sent'],
        json['balance'],
        json['unconfirmed_balance'],
        json['final_balance'],
        json['n_tx'],
        json['unconfirmed_N_tx'],
        json['final_n_tx']);
  }
}
