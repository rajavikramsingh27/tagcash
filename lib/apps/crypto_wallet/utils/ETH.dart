import 'dart:async';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:fbroadcast/fbroadcast.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:hex/hex.dart';

import 'package:tagcash/models/app_constants.dart' as AppConstant;

class ETH {
  static String ETH_BALANCE_UPDATE = "eth_balance_update";
  static String SYMBOL = "ETH";
  ETHKeys _ethKeys;

  ETH(this._ethKeys);

  static String ETH_API_URL = AppConstant.getETHAPIURL();

  void ethINIT() async {
    Web3Client web3Client = getETHClient();
    web3Client.pendingTransactions().listen((event) {
      // print("message from server in ws => " + event);
      watchTransaction(event);
    });
  }

  void watchTransaction(String hash) async {
    // print("Start watching transaction with hash ${hash}");
    Web3Client web3Client = getETHClient();
    String ethAddress = getPublicKey().toLowerCase();

    //Get Transaction and chcek for ETH address if related
    TransactionInformation transaction =
        await web3Client.getTransactionByHash(hash);
    if (transaction.to.hex.toLowerCase() == ethAddress ||
        transaction.from.hex.toLowerCase() == ethAddress) {
      Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
        // print("Here in after 10 secnods for receipt");

        try {
          TransactionReceipt transactionReceipt =
              await web3Client.getTransactionReceipt(hash);
          print(transactionReceipt);
          if (transactionReceipt != null && transactionReceipt.status) {
            FBroadcast.instance().broadcast(ETH_BALANCE_UPDATE);
            timer.cancel();
          }
        } catch (err) {
          // print("here in error");
          print(err);
        }
      });
    }
  }

  static Web3Client getETHClient() {
    var httpClient = new Client();
    return new Web3Client(ETH_API_URL, httpClient);
  }

  Future<EtherAmount> ethBalance() async {
    Web3Client web3Client = ETH.getETHClient();
    Credentials credentials =
        await web3Client.credentialsFromPrivateKey(getPrivateKey());
    EtherAmount etherAmount =
        await web3Client.getBalance(await credentials.extractAddress());
    EtherAmount gasAmount = await web3Client.getGasPrice();
    print("GAS PRICE " + gasAmount.getInEther.toString());
    return etherAmount;
  }

  Future<String> getGasEstimate(
      String fromAddress, String toAddress, String amount) async {
    try {
      BigInt estimateGas = await ETH.getETHClient().estimateGas(
          sender: EthereumAddress.fromHex(fromAddress),
          to: EthereumAddress.fromHex(toAddress),
          value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount));
      return EtherAmount.inWei(estimateGas).getInWei.toString();
    } catch (e) {
      throw new Exception(e.toString());
    }
  }

  Future<String> sendETH(String toAddress, String amount, String maxGas) async {
    try {
      String privateKey = getPrivateKey();
      Web3Client web3Client = ETH.getETHClient();
      Credentials credentials =
          await web3Client.credentialsFromPrivateKey(privateKey);

      String hash = await web3Client.sendTransaction(
          credentials,
          Transaction(
              to: EthereumAddress.fromHex(toAddress),
              maxGas: int.parse(maxGas),
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)),
          chainId: 2018);
      return hash;
    } catch (err) {
      print(err);
      throw new Exception(err.toString());
    }
  }

  static Future<ETHKeys> createWallet(String mnemonic, {int index = 0}) async {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    final root = bip32.BIP32.fromSeed(HEX.decode(seed) as Uint8List);
    final child = root.derivePath("m/44'/60'/0'/0/${index}");
    Credentials fromHex = EthPrivateKey.fromHex(HEX.encode(child.privateKey));
    String address = (await fromHex.extractAddress()).toString();
    return ETHKeys(HEX.encode(child.privateKey), address);
  }

  static Future<ETHKeys> getKeysFromPrivateKey(String privateKey) async {
    Credentials credentials = EthPrivateKey.fromHex(privateKey);
    final address = await credentials.extractAddress();
    return ETHKeys(privateKey, address.toString());
  }

  String getPublicKey() {
    return _ethKeys.publicKey;
  }

  String getPrivateKey() {
    return _ethKeys.privateKey;
  }
}

class ETHKeys {
  String privateKey;
  String publicKey;

  ETHKeys(this.privateKey, this.publicKey);

  Map toJson() => {"privateKey": this.privateKey, "publicKey": this.publicKey};
}

class ETHTransfer {
  ETHTransfer(List<dynamic> response)
      : from = (response[0] as EthereumAddress),
        to = (response[1] as EthereumAddress),
        value = (response[2] as BigInt);

  final EthereumAddress from;

  final EthereumAddress to;

  final BigInt value;
}
