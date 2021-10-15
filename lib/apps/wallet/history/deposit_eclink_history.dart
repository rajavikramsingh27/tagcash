import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/wallet/models/eclink_deposit.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class DepositEclinkHistory extends StatefulWidget {
  final Function(EclinkDeposit) onTransactionClick;

  const DepositEclinkHistory({
    Key key,
    this.onTransactionClick,
  }) : super(key: key);

  @override
  _DepositEclinkHistoryState createState() => _DepositEclinkHistoryState();
}

class _DepositEclinkHistoryState extends State<DepositEclinkHistory> {
  StreamController<List<EclinkDeposit>> _streamcontroller;
  List<EclinkDeposit> _transactionData;

  @override
  void initState() {
    super.initState();

    _transactionData = List<EclinkDeposit>();
    _streamcontroller = StreamController<List<EclinkDeposit>>.broadcast();

    loadTransactionDetails();
  }

  loadTransactionDetails({bool clearCachedData = false}) {
    if (clearCachedData) {
      _transactionData = List<EclinkDeposit>();
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

  Future<List<EclinkDeposit>> transactionListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('deposit/requests?show_eclink=1');

    List responseList = response['data']['requests'];

    List<EclinkDeposit> getData = responseList.map<EclinkDeposit>((json) {
      return EclinkDeposit.fromJson(json);
    }).toList();

    return getData;
  }

  void transactionCancel(EclinkDeposit value) async {
    setState(() {
      value.removing = true;
      // isLoading = true;
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
              EclinkDeposit transaction = snapshot.data[index];
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
                          title: Text(transaction.referenceId.toString()),
                          subtitle: Text(
                              'Amount : ${transaction.amount}  ${transaction.status}'),
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
