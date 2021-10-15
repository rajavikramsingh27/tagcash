import 'package:tagcash/apps/crypto_wallet/models/TagbondModel.dart';

class CryptoWalletUtils {
  Future<bool> createWallet(String mnemonic) async {
    try {
      bool isWalletCreted = await TagbondModel.createWallet(mnemonic);
      return isWalletCreted;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> isWalletLogin() async {
    try {
      return await TagbondModel.isWalletLogin();
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<TagbondModel> loadWallet() async {
    try {
      return await TagbondModel.loadWallet();
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<bool> removeWallet() {
    return TagbondModel.removeWallet();
  }
}
