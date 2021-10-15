import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/wallet/models/transaction.dart';
import 'package:tagcash/apps/wallet/wallet_transactions_screen.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/apps/create_currency/models/token.dart';
import 'package:tagcash/apps/create_currency/models/wallet_statstics.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/app_service.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/common_methods.dart';

class CurrencyReport extends StatefulWidget {
  const CurrencyReport({this.token});

  final Token token;

  @override
  _CurrencyReportState createState() => _CurrencyReportState();
}

class _CurrencyReportState extends State<CurrencyReport> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Token _token;
  Future<WalletStatstics> futureWalletStats;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    futureWalletStats = getWalletStats();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future<WalletStatstics> getWalletStats() async {
    print(
        '============================getting Report ============================');

    var apiBodyObj = {
      "wallet_id": _token.walletId.toString(),
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/statics', apiBodyObj);

    if (response["status"] == "success") {
      var statsResponse = response['result'];
      WalletStatstics data = WalletStatstics.fromJson(statsResponse);
      return data;
    } else {
      var error = response["error"];

      var message = '';
      if (error == "please_switch_to_merchant") {
        message = getTranslated(context, "please_switch_to_merchant_account");
      } else if (error == 'request_failed') {
        message = getTranslated(context, "request_failed");
      } else if (error == "no_active_plan_found") {
        message = getTranslated(context, "no_active_plan_found");
      } else {
        message = getTranslated(context, "error_occurred");
      }

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: new Text(getTranslated(context, 'error') + ': ' + message),
        duration: new Duration(seconds: 3),
      ));
    }
    return null;
  }

  Widget buildAggregateStatsBlock(
      IconData iconData, WalletAggregateStats stats) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 0.0,
              offset: Offset(0.0, 0.0),
            )
          ],
          borderRadius: BorderRadius.circular(10),
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.grey[800]
              : Colors.white),
      child: Column(children: [
        Icon(iconData, size: 28, color: Theme.of(context).primaryColor),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.bar_chart, size: 16),
            Text(stats.holders.toString(),
                style: TextStyle(fontWeight: FontWeight.w500))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.money, size: 16),
            Text(stats.sum.toString(),
                style: TextStyle(fontWeight: FontWeight.w500))
          ],
        )
      ]),
    ));
  }

  Widget buildCurrencyReport(WalletStatstics statstics) {
    var balancesList = statstics.balances;
    var userStats = statstics.user;
    var communityStats = statstics.merchant;
    var systemStats = statstics.system;

    return Column(children: [
      Row(children: [
        buildAggregateStatsBlock(Icons.person, userStats),
        SizedBox(width: 10),
        buildAggregateStatsBlock(Icons.people, communityStats),
        SizedBox(width: 10),
        buildAggregateStatsBlock(Icons.settings, systemStats),
      ]),
      SizedBox(height: 15),
      Expanded(
          child: ListView.builder(
              itemCount: balancesList.length,
              itemBuilder: (context, i) {
                return buildUserBalanceRow(balancesList[i]);
              }))
    ]);
  }

  buildUserBalanceRow(WalletUserBalance balance) {
    String name;
    IconData icon;

    switch (balance.balanceType) {
      case 1:
        name = balance.name;
        icon = Icons.person;
        break;
      case 2:
        name = balance.communityName;
        icon = Icons.people;
        break;
      case 3:
        name = balance.systemName;
        icon = Icons.settings;
        break;
    }

    return Card(
        margin: EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Container(
            height: double.infinity,
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          title: Text(name),
          subtitle: Row(children: [
            Text(
              getTranslated(context, "id") + ": ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(balance.balanceId.toString())
          ]),
          trailing: Text(
            CommonMethods.removeTrailingZeros(balance.balanceAmount),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletTransactionsScreen(
                  filters: TransactionFilters(
                      fromWalletId: _token.walletId,
                      toOrFromId: balance.balanceId,
                      toOrFromType:
                          AppService.getUserTypeByType(balance.balanceType)),
                ),
              ),
            ).then((val) => {});
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        margin: EdgeInsets.all(10),
        child: FutureBuilder<WalletStatstics>(
          future: futureWalletStats,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return buildCurrencyReport(snapshot.data);
            } else if (snapshot.hasError) {
              //return Text("${snapshot.error}");
              print("${snapshot.error}");
            }
            return Center(
              child: new SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: const CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
