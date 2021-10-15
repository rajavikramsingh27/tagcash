import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/wallet/models/bank_send_history.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

class SendBankApproveHistory extends StatefulWidget {
  final String walletId;

  const SendBankApproveHistory({
    Key key,
    this.walletId,
  }) : super(key: key);

  @override
  _SendBankApproveHistoryState createState() => _SendBankApproveHistoryState();
}

class _SendBankApproveHistoryState extends State<SendBankApproveHistory> {
  StreamController<List<BankSendHistory>> _streamcontroller;
  List<BankSendHistory> _transactionData;

  @override
  void initState() {
    super.initState();

    _transactionData = List<BankSendHistory>();
    _streamcontroller = StreamController<List<BankSendHistory>>.broadcast();

    loadTransactionDetails();
  }

  loadTransactionDetails({bool clearCachedData = false}) {
    if (clearCachedData) {
      _transactionData = [];
      // hasMore = true;
    }
    // if (_isLoading || !hasMore) {
    //   return Future.value();
    // }
    // _isLoading = true;

    transactionListLoad().then((res) {
      // _isLoading = false;
      _transactionData.addAll(res);
      // hasMore = (res.length == 20);

      _streamcontroller.add(_transactionData);
    });
  }

  Future<List<BankSendHistory>> transactionListLoad() async {
    Map<String, String> apiBodyObj = {};
    // apiBodyObj.bank_code = directBankCode;

    apiBodyObj['wallet_id'] = widget.walletId;

    Map<String, dynamic> response =
        await NetworkHelper.request('bank/payments', apiBodyObj);

    List responseList = response['data'];

    List<BankSendHistory> getData = responseList.map<BankSendHistory>((json) {
      return BankSendHistory.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _streamcontroller.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        if (!snapshot.hasData) {
          return Center(child: Loading());
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              BankSendHistory transaction = snapshot.data[index];
              return ListTile(
                title: Text('${transaction.amount} ${transaction.currency}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.beneficiaryName),
                    Text(transaction.date),
                  ],
                ),
                trailing: Text(buildStatusName(transaction.status)),
              );
            },
          );
        }
      },
    );
  }

  String buildStatusName(String status) {
    switch (status) {
      case 'S':
        return 'success';
        break;
      case 'D':
        return 'declined';
        break;
      case 'P':
        return 'pending';
        break;
      default:
        return 'Pending';
    }
  }
}
