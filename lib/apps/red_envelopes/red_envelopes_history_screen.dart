import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/common_methods.dart';

import 'model/red_envelopes.dart';

class RedEnvelopeHistoryScreen extends StatefulWidget {
  @override
  _RedEnvelopeHistoryScreenState createState() =>
      _RedEnvelopeHistoryScreenState();
}

class _RedEnvelopeHistoryScreenState extends State<RedEnvelopeHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<RedEnvelope> _histroyList = [];

  bool isLoading = true;
  bool loadingProgress = false;
  bool loadMore = false;

  final int limit = 10;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadingProgress = false;
    loadMore = false;

    getRedEvpHistoryList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future getRedEvpHistoryList([bool refresh = false]) async {
    var apiBodyObj = {
      "count": limit.toString(),
      "offset": refresh ? "0" : _histroyList.length.toString()
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('RedEnvelops/history', apiBodyObj);

    if (response["status"] == "success") {
      List responseList = response['envelops'];
      var pagedHistoryList = responseList.map<RedEnvelope>((json) {
        return RedEnvelope.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
        loadingProgress = false;
        loadMore = pagedHistoryList.length == limit;

        if (refresh)
          _histroyList = pagedHistoryList;
        else
          _histroyList.addAll(pagedHistoryList);
      });
    } else {
      setState(() {
        loadMore = false;
        loadingProgress = false;
        isLoading = false;
      });
    }
  }

  Future<void> refreshHistory() {
    setState(() {
      loadMore = false;
    });

    getRedEvpHistoryList(true);
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

                  getRedEvpHistoryList();
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: refreshHistory,
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _histroyList.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _histroyList.length) {
                      return buildHistoryRow(_histroyList[index]);
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
        ));
  }

  buildHistoryRow(RedEnvelope history) {
    IconData historyIcon;
    String subTitle =
        "${CommonMethods.removeTrailingZeros(history.voucherAmount)} ${history.currencyCode}";
    if (history.randomize == 1) {
      historyIcon = Icons.email_outlined;
    } else {
      historyIcon = Icons.mark_email_read_outlined;
    }
    return Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Card(
            child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                leading: Container(
                  height: double.infinity,
                  child: Icon(
                    historyIcon,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ),
                title: Text(history.title, style: TextStyle(fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3),
                    Text(subTitle, textAlign: TextAlign.left),
                    SizedBox(height: 3),
                    Text(
                        "${getTranslated(context, "red_envelope_credited_to_wallet")}")
                  ],
                ))));
  }
}
