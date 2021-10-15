import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/crypto_wallet/utils/BTC.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoAESEncryption.dart';
import 'package:tagcash/apps/crypto_wallet/utils/ETH.dart';
// import 'package:tagcash/apps/crypto_wallet/utils/XLM.dart';
import 'package:device_info/device_info.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:universal_platform/universal_platform.dart';
import 'package:web3dart/web3dart.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class TagbondModel {
  static const String CRYPTO_WALLET_DATA = "CRYPTO_WALLET_DATA";
  BTC _btc;
  //XLM _xlm;
  ETH _eth;

  void startSocketForWallet() {
    _btc.btcINIT();
    //_xlm.xlmINIT();
    _eth.ethINIT();
  }

  static Future<bool> createWallet(String mnemonic, {int index = 0}) async {
    try {
      TagbondModel walletModel = new TagbondModel();
      if (!(await walletModel._validateMnemonic(mnemonic))) {
        return false;
      }
      ETHKeys ethKeys = await ETH.createWallet(mnemonic);
      print("after ETH created");
      BTCKeys btcKeys = await BTC.createWallet(mnemonic);
      print("after BTC created");
      // XLMKeys xlmKeys = await XLM.createWallet(mnemonic);
      Map keys = {
        "eth": ethKeys.toJson(),
        "btc": btcKeys.toJson(),
        // "xlm": xlmKeys.toJson()
      };
      bool isWalletFileSaved = await walletModel._walletSaveFile(keys);
      return isWalletFileSaved;
    } catch (err) {
      print(err);
      throw new Exception(err);
    }
  }

  static Future<TagbondModel> loadWallet() async {
    try {
      TagbondModel walletModel = new TagbondModel();
      await walletModel._setup(await walletModel._decrypt());
      return walletModel;
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<bool> _setup(String jsonData) async {
    Map<String, dynamic> keys = jsonDecode(jsonData);
    keys.forEach((key, value) {
      if (key == "btc") {
        _btc = BTC(BTCKeys(value['privateKey'], value['publicKey']));
      } else if (key == "eth") {
        _eth = ETH(ETHKeys(value['privateKey'], value['publicKey']));
      } else if (key == "xlm") {
        //_xlm = XLM(XLMKeys(value['privateKey'], value['publicKey']));
      } else {
        print("NOT a relevant wallet");
      }
    });
    return true;
  }

  Future<bool> _walletSaveFile(Map keys) async {
    try {
      String jsonData = jsonEncode(keys);
      return await _encrypt(jsonData);
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<bool> _encrypt(jsonData) async {
    try {
      String uuid = await _getUUId();
      String encrypted = encryptAESCryptoJS(jsonData, uuid);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return await sharedPreferences.setString(CRYPTO_WALLET_DATA, encrypted);
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<String> _decrypt() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String cryptoData = sharedPreferences.getString(CRYPTO_WALLET_DATA);
      String uuid = await _getUUId();
      return decryptAESCryptoJS(cryptoData, uuid);
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<String> _getUUId() async {
    try {
      String uuid = "";
      if (UniversalPlatform.isIOS) {
        var deviceInfo = DeviceInfoPlugin();
        var iosDeviceInfo = await deviceInfo.iosInfo;
        uuid = iosDeviceInfo.identifierForVendor; // unique ID on iOS
      } else if (UniversalPlatform.isAndroid) {
        var deviceInfo = DeviceInfoPlugin();
        var androidDeviceInfo = await deviceInfo.androidInfo;
        uuid = androidDeviceInfo.androidId; // unique ID on Android
      } else {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        uuid = sharedPreferences.getString("uuid");
      }
      return uuid;
    } on PlatformException {
      //not handled platform
      print('Not handled platform');
      AppConstants.deviceId = '1234567890';
      AppConstants.deviceName = 'Debug';
    }
  }

  static Future<bool> isWalletLogin() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return sharedPreferences.containsKey(CRYPTO_WALLET_DATA);
    } catch (err) {
      throw new Exception(err);
    }
  }

  static Future<bool> removeWallet() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(CRYPTO_WALLET_DATA);
  }

  Future<bool> _validateMnemonic(String mnemonic) async {
    return bip39.validateMnemonic(mnemonic);
  }

  String getBTCAddress() {
    return _btc.getPublicKey();
  }

  String getETHAddress() {
    return _eth.getPublicKey();
  }

  String getXMLAddress() {
    return "";
    //_xlm.getPublicKey();
  }

  String getBTCPrivateKey() {
    return _btc.getPrivateKey();
  }

  String getXLMPrivateKey() {
    return "";
    //_xlm.getPrivateKey();
  }

  String getETHPrivateKey() {
    return _eth.getPrivateKey();
  }

  Future<BTCBalanceDetails> getBTCBalance(String address) async {
    try {
      return await _btc.getBTCBalance(address);
    } catch (e) {
      throw new Exception(e);
    }
  }

  Future<TXSkeleton> newBTCTransaction(String toAddress, double btc) async {
    try {
      return await _btc.newTransaction(toAddress, getBTCAddress(), btc);
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<TX> confirmBTCTransaction(
      String toAddress, double amount, String prevHash, int index) async {
    try {
      return await _btc.pushTransaction(toAddress, amount, prevHash, index);
    } catch (e) {
      throw new Exception(e);
    }
  }

  Future<String> confirmXLMTransaction(String toAddress, String amount) async {
    try {
      //return await _xlm.sendXLM(toAddress, amount);
    } catch (e) {
      throw new Exception(e);
    }
  }

  Future<String> getXLMBalance() async {
    //return await _xlm.getXLMBalance(getXMLAddress());
  }

  /*
  ETH Content Here
  */

  Future<String> getETHBalance() async {
    EtherAmount etherAmount = await _eth.ethBalance();
    return etherAmount.getInEther.toString();
  }

  Future<String> getEstimateGasPrice(String toAddress, String amount) async {
    try {
      return await _eth.getGasEstimate(getETHAddress(), toAddress, amount);
    } catch (e) {
      throw new Exception(e);
    }
  }

  Future<String> confirmETHTransaction(
      String toAddress, String amount, String maxGas) async {
    try {
      return await _eth.sendETH(toAddress, amount, maxGas);
    } catch (e) {
      throw new Exception(e);
    }
  }
}
