import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/charity/models/donation.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

class DonationsScreen extends StatefulWidget {
  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  //Future<List<LendRequest>> requestsListData;
  StreamController<List<Donation>> _streamcontroller;
  final scrollController = ScrollController();
  TextEditingController _keywordController;
  int offsetApi = 0;
  List<Donation> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _keywordController = TextEditingController();
    //requestsListData = requestsListLoad();
    _data = List<Donation>();
    _streamcontroller = StreamController<List<Donation>>.broadcast();

    _isLoading = false;
    hasMore = true;

    loadMoreItems();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        offsetApi = offsetApi + 10;
        loadMoreItems();
      }
    });
    super.initState();
  }

  Future<void> dataRefresh() {
    // _streamcontroller.add(List<Transaction>());
    _isLoading = false;
    hasMore = true;
    offsetApi = 0;
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<Donation>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    requestsListLoad().then((res) {
      _isLoading = false;
      _data.addAll(res);
      hasMore = (res.length == 10);

      _streamcontroller.add(_data);
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<List<Donation>> requestsListLoad() async {
    Map<String, String> apiBodyObj = {};
//    if (_keywordController.text.length != 0) {
//      apiBodyObj['keyword'] = _keywordController.text;
//    }
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/GetDonatedList', apiBodyObj);

    List responseList = response['result'];

    List<Donation> getData = responseList.map<Donation>((json) {
      return Donation.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: RefreshIndicator(
        onRefresh: dataRefresh,
        child: StreamBuilder(
          stream: _streamcontroller.stream,
          builder:
              (BuildContext context, AsyncSnapshot<List<Donation>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? ListView.builder(
                    controller: scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data.length + 1,
                    //itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < snapshot.data.length) {
                        return Card(
                          child: GestureDetector(
                            onTap: () {
//                              setState(() {
//                                Navigator.push(
//                                  context,
//                                  MaterialPageRoute(
//                                    builder: (context) => RequestDetailScreen(
//                                        lendRequest: snapshot.data[index]),
//                                  ),
//                                );
//                              });
                              // _listItemTapped(snapshot.data[index]);
                            },
                            //margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),

                            child: ListTile(
                              title: Text(
                                snapshot.data[index].title,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.person,
                                          color: Colors.red[500], size: 16),
                                      SizedBox(width: 5),
                                      Text(snapshot.data[index].name),
                                      SizedBox(width: 5),
                                      Icon(Icons.calendar_today,
                                          color: Colors.red[500], size: 12),
                                      SizedBox(width: 5),
                                      Text(snapshot.data[index].createdDate
                                          .toString()),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(getTranslated(context, "you_gave")+' ' +
                                      snapshot.data[index].amount.toString() +
                                      ' ' +
                                      snapshot.data[index].walletCode),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else if (hasMore) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
//                        return Padding(
//                          padding: EdgeInsets.symmetric(vertical: 32.0),
//                          child: Center(child: Text('....................')),
//                        );
                        return Container();
                      }
                    })
                : Center(child: Loading());
          },
        ),
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
////          setState(() {
////            Navigator.push(context,
////                MaterialPageRoute(builder: (context) => LendingCreateScreen()));
////          });
//          //_createButtonTapped();
//        },
//        //tooltip: 'Increment',
//        child: Icon(Icons.add),
//        backgroundColor: Colors.red,
//      ),
    );
    // TODO: implement build
    //throw UnimplementedError();
  }

//  Future _listItemTapped(LendRequest request) async {
//    Map results = await Navigator.of(context).push(MaterialPageRoute(
//      builder: (context) => RequestDetailScreen(lendRequest: request),
//    ));
//
//    if (results != null && results.containsKey('pledgeStatus')) {
//      setState(() {
//        String status = results['pledgeStatus'];
//        if (status == 'success') {
//          String value = results['value'];
//          //requestsListData = requestsListLoad();
//          _isLoading = false;
//          hasMore = true;
//          offsetApi = 0;
//          loadMoreItems(clearCachedData: true);
//          final snackBar = SnackBar(
//              content:
//              Text('You have successfully pledged an Amount of ' + value),
//              duration: const Duration(seconds: 3));
//          globalKey.currentState.showSnackBar(snackBar);
//        }
//      });
//    }
//  }
//
//  Future _createButtonTapped() async {
//    Map results = await Navigator.of(context)
//        .push(MaterialPageRoute(builder: (context) => LendingCreateScreen()));
//
//    if (results != null && results.containsKey('status')) {
//      setState(() {
//        String status = results['status'];
//        if (status == 'success') {
//          final snackBar = SnackBar(
//              content: Text('Successfully created a Lend Request'),
//              duration: const Duration(seconds: 3));
//          globalKey.currentState.showSnackBar(snackBar);
//        }
//      });
//    }
//  }
}
