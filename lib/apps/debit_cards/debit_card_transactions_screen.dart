import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/debit_cards/models/debit_card_transaction.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

class DebitCardTransactionsScreen extends StatefulWidget {
  @override
  _DebitCardTransactionsScreenState createState() => _DebitCardTransactionsScreenState();
}

class _DebitCardTransactionsScreenState extends State<DebitCardTransactionsScreen> {
  Future<List<DebitCardTransaction>> debitTransactions;
  final globalKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    debitTransactions = debitTransactionsLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<DebitCardTransaction>> debitTransactionsLoad() async {
    print('debitTransactionsLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/ListTransactions');

    print(response);
    if (response["status"] == "success") {
    List responseList = response['result'];
    setState(() {
      isLoading = false;
    });
    List<DebitCardTransaction> getData = responseList.map<DebitCardTransaction>((json) {
      return DebitCardTransaction.fromJson(json);
    }).toList();

    return getData;
    } else {
      var error = response["result"];
      var message = '';
      if (error == "no_data_found") {
        message = "No transactions found.";
      }else {
        message = getTranslated(context, "error_occurred");
      }
      final snackBar = SnackBar(
          content: Text(
              message),
          duration:
          const Duration(seconds: 3));
      globalKey.currentState
          .showSnackBar(snackBar);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Transactions - Debit Card',
      ),
      body: FutureBuilder(
        future: debitTransactions,
        builder: (BuildContext context,
            AsyncSnapshot<List<DebitCardTransaction>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        child: GestureDetector(
                            child: TransactionRowItem(snapshot.data[index].accountNo,
                                snapshot.data[index].transactionDate,snapshot.data[index].amount,
//                                onDelete: () => deleteLocationHandler(
//                                    snapshot.data[index].id)
                            )));
                  })
              : Center(child: Loading());
        },
      ),
    );
  }
}

class TransactionRowItem extends StatelessWidget {
  final String accountNo,transactionDate;
  final String amount;

  TransactionRowItem(this.accountNo, this.transactionDate,this.amount);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEBIT',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Account No: '+accountNo,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2,
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm aaa dd MMM yyy')
                        .format(
                      DateTime.parse(transactionDate),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),

                Text(
              '- ${amount}',
            ),
          ],
        ),
      ),
    );
  }
}
