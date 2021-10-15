import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tagcash/apps/wallet/models/transaction.dart';
import 'package:tagcash/apps/wallet/wallet_transactions_screen.dart';
import 'package:tagcash/handlers/models/received_status.dart';

class WalletNofiticationHandler {
  void messageProcess(BuildContext context, ReceivedStatus receivedStatus,
      String activePage, RemoteMessage message) {
    if (receivedStatus == ReceivedStatus.message) {
      showSimpleNotification(
        Text(message.notification.title),
        subtitle: Text(message.notification.body),
      );
      //if active page is home or list refresh
      // if (activePage == '/home') {}
    } else if (receivedStatus == ReceivedStatus.resume) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_context) => WalletTransactionsScreen(
            filters: TransactionFilters(
                fromWalletId: int.parse(message.data['from_wallet_id'])),
          ),
        ),
      );
    } else if (receivedStatus == ReceivedStatus.launch) {
      // goToWallet = true;
    }
  }
}
