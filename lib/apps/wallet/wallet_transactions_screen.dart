import 'dart:async';
import 'package:intl/intl.dart';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/wallet/transaction_detail_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'models/transaction.dart';

class WalletTransactionsScreen extends StatefulWidget {
  final TransactionFilters filters;

  const WalletTransactionsScreen({Key key, this.filters}) : super(key: key);

  @override
  _WalletTransactionsScreenState createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  TransactionFilters _transactionfilters;
  StreamController<List> _streamcontroller;
  final scrollController = ScrollController();

  int countApi = 20;
  int loadedCount = 0;
  List _data;
  bool hasMore;
  bool _isLoading;

  @override
  void initState() {
    _transactionfilters = widget.filters;
    _data = [];
    loadedCount = 0;
    _streamcontroller = StreamController<List>.broadcast();

    _isLoading = false;
    hasMore = true;

    loadMoreItems();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        loadMoreItems();
      }
    });

    super.initState();
  }

  Future<void> dataRefresh() {
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = [];
      loadedCount = 0;

      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    transactionListLoad().then((res) {
      _isLoading = false;
      // _data.addAll(res);
      hasMore = (res.length == countApi);
      loadedCount = loadedCount + res.length;

      var newMap = groupBy(res, (obj) => obj.date.substring(0, 10));

      newMap.forEach((k, v) {
        Map<String, dynamic> dateGroup = {};
        dateGroup['date'] = k;
        dateGroup['data'] = v;
        _data.add(dateGroup);
      });

      _streamcontroller.add(_data);
    });
  }

  Future<List<Transaction>> transactionListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['from_wallet_id'] = _transactionfilters.fromWalletId.toString();
    if (_transactionfilters.toOrFromId != null)
      apiBodyObj['to_or_from_id'] = _transactionfilters.toOrFromId.toString();

    if (_transactionfilters.toOrFromType != null)
      apiBodyObj['to_or_from_type'] = _transactionfilters.toOrFromType;

    apiBodyObj['count'] = countApi.toString();
    // apiBodyObj['offset'] = _data.length.toString();
    apiBodyObj['offset'] = loadedCount.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/transactions', apiBodyObj);

    List responseList = response['result'];

    List<Transaction> getData = responseList.map<Transaction>((json) {
      return Transaction.fromJson(json);
    }).toList();

    return getData;
  }

  transactionClicked(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          transaction: transaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
          appBar: AppBar(), title: getTranslated(context, "transactions")),
      body: RefreshIndicator(
        onRefresh: dataRefresh,
        child: StreamBuilder(
          stream: _streamcontroller.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            if (!snapshot.hasData) {
              return Center(child: Loading());
            } else {
              return ListView.builder(
                controller: scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(10),
                itemCount: snapshot.data.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < snapshot.data.length) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 4, top: 20, bottom: 10),
                          child: Text(
                            DateFormat('MMMM dd, yyy EEEE').format(
                                DateTime.parse(snapshot.data[index]['date'])),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(fontSize: 14),
                          ),
                        ),
                        Card(
                          // color: Colors.blue,
                          elevation: 4,
                          child:
                              buildDayTransaction(snapshot.data[index]['data']),
                        ),
                      ],
                    );
                  } else if (hasMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  ListView buildDayTransaction(List transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) {
        Transaction transaction = transactions[index];
        return ListTile(
          onTap: () => transactionClicked(transaction),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          title: transaction.firstName != ''
              ? Text(transaction.firstName + ' ' + transaction.lastName)
              : Text(transaction.communityName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DateFormat('h:mm aaa').format(DateTime.parse(transaction.date)),
              ),
              transaction.sentFromFamilyCreator.isNotEmpty
                  ? Text(
                      'From ${transaction.sentFromFamilyCreator}',
                    )
                  : SizedBox(),
              transaction.sentByFamilyUser.isNotEmpty
                  ? Text(
                      'By ${transaction.sentByFamilyUser}',
                    )
                  : SizedBox(),
            ],
          ),
          trailing: transaction.direction == 'in'
              ? Text(
                  '+ ${transaction.fromAmount}',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.green),
                )
              : Text(
                  '- ${transaction.fromAmount}',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.red),
                ),
        );
      },
    );
  }
}
