import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/wallet/models/bank_deposit_history.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class DepositBankHistory extends StatefulWidget {
  final String walletId;

  const DepositBankHistory({
    Key key,
    this.walletId,
  }) : super(key: key);

  @override
  _DepositBankHistoryState createState() => _DepositBankHistoryState();
}

class _DepositBankHistoryState extends State<DepositBankHistory> {
  StreamController<List<BankDepositHistory>> _streamcontroller;
  List<BankDepositHistory> _transactionData;

  @override
  void initState() {
    super.initState();

    _transactionData = List<BankDepositHistory>();
    _streamcontroller = StreamController<List<BankDepositHistory>>.broadcast();

    loadTransactionDetails();
  }

  loadTransactionDetails({bool clearCachedData = false}) {
    if (clearCachedData) {
      _transactionData = List<BankDepositHistory>();
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

  Future<List<BankDepositHistory>> transactionListLoad() async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['wallet_id'] = widget.walletId;

    Map<String, dynamic> response =
        await NetworkHelper.request('bank/Deposits', apiBodyObj);

    List responseList = response['data'];

    List<BankDepositHistory> getData =
        responseList.map<BankDepositHistory>((json) {
      return BankDepositHistory.fromJson(json);
    }).toList();

    return getData;
  }

  void transactionCancel(BankDepositHistory value) async {
    setState(() {
      value.removing = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = value.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('bank/DeleteRequest', apiBodyObj);

    if (response['status'] == 'success') {
      _transactionData.remove(value);
      showSnackBar('Deleted successfully');
    } else {
      value.removing = false;
      showSnackBar(getTranslated(context, 'error_occurred'));
    }
    setState(() {});
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
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
              BankDepositHistory transaction = snapshot.data[index];
              return ClipRect(
                child: Slidable(
                  key: ValueKey(index),
                  actionPane: SlidableDrawerActionPane(),
                  enabled: transaction.status == 'P' ? true : false,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => transactionCancel(transaction),
                    ),
                  ],
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: transaction.removing ? 0.3 : 1,
                        child: ListTile(
                          title: Text(transaction.method),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transaction.statusText.toUpperCase()),
                              Text(
                                  '${transaction.amount} ${transaction.currency}'),
                              Text(transaction.date),
                            ],
                          ),
                        ),
                      ),
                      transaction.removing
                          ? Center(child: Loading())
                          : SizedBox(),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
