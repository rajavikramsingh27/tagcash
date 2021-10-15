import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/wallet/models/seven_deposit.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class DepositSevenHistory extends StatefulWidget {
  final Function(SevenDeposit) onTransactionClick;

  const DepositSevenHistory({
    Key key,
    this.onTransactionClick,
  }) : super(key: key);

  @override
  _DepositSevenHistoryState createState() => _DepositSevenHistoryState();
}

class _DepositSevenHistoryState extends State<DepositSevenHistory> {
  StreamController<List<SevenDeposit>> _streamcontroller;
  List<SevenDeposit> _transactionData;

  @override
  void initState() {
    super.initState();

    _transactionData = [];
    _streamcontroller = StreamController<List<SevenDeposit>>.broadcast();

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

  Future<List<SevenDeposit>> transactionListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('deposit/requests');

    List responseList = response['data']['requests'];

    List<SevenDeposit> getData = responseList.map<SevenDeposit>((json) {
      return SevenDeposit.fromJson(json);
    }).toList();

    return getData;
  }

  void transactionCancel(SevenDeposit value) async {
    setState(() {
      value.removing = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = value.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('deposit/DeleteRequest', apiBodyObj);

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
              SevenDeposit transaction = snapshot.data[index];
              return ClipRect(
                child: Slidable(
                  key: ValueKey(index),
                  actionPane: SlidableDrawerActionPane(),
                  enabled: transaction.status == "UNPAID" ? true : false,
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
                          title: Text(transaction.payId),
                          subtitle: Text(transaction.amount.toString() +
                              ' ' +
                              transaction.status),
                          onTap: () => widget.onTransactionClick(transaction),
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
