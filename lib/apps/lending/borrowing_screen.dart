import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/lending/borrow_detail_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/lending/models/borrow.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';

class BorrowingScreen extends StatefulWidget {
  @override
  _BorrowingScreenState createState() => _BorrowingScreenState();
}

class _BorrowingScreenState extends State<BorrowingScreen> {
  //Future<List<Borrow>> borrowingListData;
  StreamController<List<Borrow>> _streamcontroller;
  final scrollController = ScrollController();
  int offsetApi = 0;
  List<Borrow> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    //borrowingListData = borrowingListLoad();
    _data = List<Borrow>();
    _streamcontroller = StreamController<List<Borrow>>.broadcast();

    _isLoading = false;
    hasMore = true;

    loadMoreItems();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        print('posts.loadMore');
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
      _data = List<Borrow>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    borrowingListLoad().then((res) {
      _isLoading = false;
      _data.addAll(res);
      hasMore = (res.length == 10);

      print(_data.length);

      _streamcontroller.add(_data);
    });
  }

  Future<List<Borrow>> borrowingListLoad([String searchKey]) async {
    print('borrowingListLoad');
    print(searchKey);

    Map<String, String> apiBodyObj = {};
    if (searchKey != null && searchKey.length != 0) {
      apiBodyObj['search'] = searchKey;
    }
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/GetBorrowersList', apiBodyObj);

    List responseList = response['result'];

    List<Borrow> getData = responseList.map<Borrow>((json) {
      return Borrow.fromJson(json);
    }).toList();

    return getData;
  }

  Future _listItemTapped(Borrow borrow) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BorrowDetailScreen(borrow: borrow),
    ));

    if (results != null && results.containsKey('deleteStatus')) {
      setState(() {
        String status = results['deleteStatus'];
        if (status == 'success') {
          //borrowingListData = borrowingListLoad();
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "successfully_deleted_the_lend_request")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
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
                (BuildContext context, AsyncSnapshot<List<Borrow>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? ListView.builder(
                      controller: scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: snapshot.data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < snapshot.data.length) {
                          return Card(
                            child: GestureDetector(
                              onTap: () {
//                          setState(() {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                builder: (context) => BorrowDetailScreen(
//                                    borrow: snapshot.data[index]),
//                              ),
//                            );
//                          });
                                _listItemTapped(snapshot.data[index]);
                              },
                              //margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 75,
                                    child: ListTile(
                                      title: Text(
                                        snapshot.data[index].title,
                                        maxLines: 2,
                                      ),
                                      subtitle: Column(
                                        children: [
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.person,
                                                  color: kPrimaryColor,
                                                  size: 16),
                                              SizedBox(width: 5),
                                              Text(snapshot
                                                  .data[index].ownerName),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.donut_large_sharp,
                                                  color: kPrimaryColor,
                                                  size: 12),
                                              SizedBox(width: 5),
                                              Text(snapshot.data[index].amount
                                                      .toString() +
                                                  '' +
                                                  snapshot
                                                      .data[index].walletName +
                                                  ' @ ' +
                                                  snapshot.data[index]
                                                      .interestPercent
                                                      .toString() +
                                                  getTranslated(context, "percent_interest")),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  color: kPrimaryColor,
                                                  size: 16),
                                              SizedBox(width: 5),
                                              Text(snapshot.data[index].duration
                                                  .toString()),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 25,
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context, "pledged"),
                                          style: new TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(width: 5),
                                        //Flexible(child:
                                        Text(
                                            snapshot.data[index].pledgedAmount
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        //),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (hasMore) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
//                      return Padding(
//                        padding:
//                        EdgeInsets.symmetric(vertical: 32.0),
//                        child: Center(
//                            child: Text('....................')),
//                      );
                          return Container();
                        }
                      },
                    )
                  : Center(child: Loading());
            },
          ),
//      floatingActionButton: FloatingActionButton(
//        //onPressed: _incrementCounter,
//        //tooltip: 'Increment',
//        child: Icon(Icons.add),
//        backgroundColor: Colors.red,
//      ),
        ));
    // TODO: implement build
    //throw UnimplementedError();
  }
}
