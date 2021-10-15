/*
import 'package:fbroadcast/fbroadcast.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

final StellarSDK sdk = StellarSDK.TESTNET;

class XLM {
  XLMKeys _xlmKeys;

  XLM(this._xlmKeys);
  static String XLM_BALANCE_UPDATE = "xlm_balance_update";
  static String SYMBOL = "XLM";

  void xlmINIT() {
    String publicKey = getPublicKey();
    print("start listening for account " + publicKey);
    sdk.payments
        .forAccount(publicKey)
        .cursor("now")
        .stream()
        .listen((response) {
      if (response is PaymentOperationResponse) {
        FBroadcast.instance().broadcast(XLM_BALANCE_UPDATE);
      }
    });
  }

  Future<String> getXLMBalance(String accountID) async {
    String xlmBalance = "";
    AccountResponse account = await sdk.accounts.account(accountID);
    for (Balance balance in account.balances) {
      switch (balance.assetType) {
        case Asset.TYPE_NATIVE:
          xlmBalance = balance.balance;

          break;
      }
    }
    return xlmBalance;
  }

  static Future<XLMKeys> createWallet(String mnemonic, {int index = 0}) async {
    final xlmWallet = await Wallet.from(mnemonic);
    KeyPair keyPair = await xlmWallet.getKeyPair(index: 0);
    createFreindBoatAccount(keyPair.accountId);
    return XLMKeys(keyPair.secretSeed, keyPair.accountId);
  }

  static Future<XLMKeys> getKeysFromPrivateKey(String privateKey) async {
    final sourceKeypair = KeyPair.fromSecretSeed(privateKey);
    final publicKey = sourceKeypair.accountId;
    return XLMKeys(privateKey, publicKey);
  }

  String getPublicKey() {
    return _xlmKeys.publicKey;
  }

  String getPrivateKey() {
    return _xlmKeys.privateKey;
  }

  static void createFreindBoatAccount(String accountId) async {
    bool funded = await FriendBot.fundTestAccount(accountId);
    print("funded: ${funded}");
  }

  Future<String> sendXLM(String toAddress, String amount) async {
    try {
      String privateKey = getPrivateKey();
      KeyPair senderKeyPair = KeyPair.fromSecretSeed(privateKey);

// Load sender account data from the stellar network.
      AccountResponse sender =
          await sdk.accounts.account(senderKeyPair.accountId);

// Build the transaction to send 100 XLM native payment from sender to destination
      Transaction transaction = new TransactionBuilder(sender)
          .addOperation(
              PaymentOperationBuilder(toAddress, Asset.NATIVE, amount).build())
          .build();

// Sign the transaction with the sender's key pair.
      transaction.sign(senderKeyPair, Network.TESTNET);

// Submit the transaction to the stellar network.
      SubmitTransactionResponse response =
          await sdk.submitTransaction(transaction);
      if (response.success) {
        FBroadcast.instance().broadcast(XLM_BALANCE_UPDATE);
      }
      return response.hash.toString();
    } catch (err) {
      throw new Exception(err.toString());
    }
  }
}

class XLMKeys {
  String privateKey;
  String publicKey;

  XLMKeys(this.privateKey, this.publicKey);

  Map toJson() => {"privateKey": this.privateKey, "publicKey": this.publicKey};
}
*/