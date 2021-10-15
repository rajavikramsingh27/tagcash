import 'package:intl/intl.dart';
import 'package:tagcash/models/wallet.dart';

class CurrencyFormat {
  static String format(Wallet wallet) {
    if (wallet.walletTypeNumeric == 0) {
      return NumberFormat.currency(name: '').format(wallet.balanceAmount);
    } else if (wallet.walletTypeNumeric == 1) {
      var cryptoBalanceAmount = double.parse(wallet.balanceAmount.toString());

      return NumberFormat("###,###.00000000", "en-US")
          .format(cryptoBalanceAmount);
    } else {
      return wallet.balanceAmount.toString();
    }
  }
}
