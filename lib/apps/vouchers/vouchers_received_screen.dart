import 'package:flutter/material.dart';
import 'package:flutter/src/services/clipboard.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/vouchers/models/voucher.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/common_methods.dart';

class VouchersReceivedScreen extends StatefulWidget {
  @override
  _VouchersReceivedScreenState createState() => _VouchersReceivedScreenState();
}

class _VouchersReceivedScreenState extends State<VouchersReceivedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<ReceivedVoucher> _vouchersList = [];

  bool isLoading = true;
  bool loadingProgress = false;
  bool loadMore = false;

  final int limit = 10;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadMore = false;
    loadingProgress = false;

    getVouchersList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future getVouchersList([bool refresh = false]) async {
    print('===============getting vouchers List =====================');

    var apiBodyObj = {
      "count": limit.toString(),
      "offset": refresh ? "0" : _vouchersList.length.toString()
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/Listing', apiBodyObj);

    if (response["status"] == "success") {
      List responseList = response['result'];
      var pagedVoucherList = responseList.map<ReceivedVoucher>((json) {
        return ReceivedVoucher.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
        loadingProgress = false;
        loadMore = pagedVoucherList.length == limit;

        if (refresh)
          _vouchersList = pagedVoucherList;
        else
          _vouchersList.addAll(pagedVoucherList);
      });
    } else {
      setState(() {
        loadMore = false;
        loadingProgress = false;
        isLoading = false;
      });
    }
  }

  Future<void> refreshVouchers() {
    setState(() {
      loadMore = false;
    });

    getVouchersList(true);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              var shouldLoadMore = !loadingProgress &&
                  loadMore &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent;

              if (shouldLoadMore) {
                setState(() {
                  loadingProgress = true;
                });

                getVouchersList();
              }
              return true;
            },
            child: RefreshIndicator(
              onRefresh: refreshVouchers,
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _vouchersList.length + 1,
                itemBuilder: (context, index) {
                  if (index < _vouchersList.length) {
                    return buildVoucherRow(_vouchersList[index]);
                  } else if (loadMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: Loading()),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox()
        ],
      ),
    );
  }

  buildVoucherRow(ReceivedVoucher voucher) {
    return GestureDetector(
        onTap: () {
          Clipboard.setData(new ClipboardData(text: voucher.code));
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text(
                getTranslated(context, "vouchers_code_copied_to_clipboard")),
            duration: new Duration(seconds: 3),
          ));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  children: [
                    Row(children: [
                      Icon(Icons.article,
                          color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Text(
                        voucher.code,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )
                    ]),
                    Row(children: [
                      Icon(Icons.account_balance_wallet,
                          color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Text(
                          "${voucher.walletType} ${CommonMethods.removeTrailingZeros(voucher.amount)}")
                    ])
                  ],
                ))));
  }
}
