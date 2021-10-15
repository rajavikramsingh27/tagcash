import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tagcash/apps/crypto_wallet/models/TransactionModel.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstant;

class CryptoNetworking {
  static String CRYPTO_API_URL = AppConstant.getCryptoWalletServerPath();

  static Future<WalletDataModel> getWalletData(
      String btcAddress, String ethAddress, String xlmAddress) async {
    print(CRYPTO_API_URL);
    final http.Response response = await http.post(
      Uri.parse(CRYPTO_API_URL + "balances"),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: {
        'btcAddress': btcAddress,
        'ethAddress': ethAddress,
        'xlmAddress': xlmAddress
      },
    );
    print(response.body);
    return WalletDataModel.fromJson(jsonDecode(response.body));
  }

  static Future<List<TransactionModel>> transactionList(
      String symbol, String address,
      {String nextPage = ""}) async {
    String listUri = CRYPTO_API_URL + "txn/" + symbol + "/" + address;
    if (nextPage != null && nextPage.isNotEmpty) {
      listUri = listUri + "/" + nextPage;
    }
    final http.Response response = await http.get(Uri.parse(listUri));
    return TransactionModel.transactionList(jsonDecode(response.body));
  }
}
