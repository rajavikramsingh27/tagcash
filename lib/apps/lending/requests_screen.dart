import 'dart:async';
import 'package:tagcash/constants.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/lending/lending_create_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/lending/models/lend_request.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/lending/request_detail_screen.dart';
import 'package:tagcash/localization/language_constants.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  Future<List<LendRequest>> requestsListData;
  StreamController<List<LendRequest>> _streamcontroller;
  final scrollController = ScrollController();
  TextEditingController _keywordController;
  int offsetApi = 0;
  List<LendRequest> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print('initState');
    _keywordController = TextEditingController();
    _keywordController.text = '';
    requestsListData = requestsListLoad();
//    _data = List<LendRequest>();
//    _streamcontroller = StreamController<List<LendRequest>>.broadcast();
//
//    _isLoading = false;
//    hasMore = true;
//    offsetApi = 0;
//    loadMoreItems();

//    scrollController.addListener(() {
//      if (scrollController.position.maxScrollExtent ==
//          scrollController.offset) {
//        print('posts.loadMore');
//        offsetApi = offsetApi + 100;
//        loadMoreItems();
//      }
//    });
    super.initState();
  }

//  Future<void> dataRefresh() {
//    // _streamcontroller.add(List<Transaction>());
//    _isLoading = false;
//    hasMore = true;
//    offsetApi = 0;
//    loadMoreItems(clearCachedData: true);
//    return Future.value();
//  }
//
//  loadMoreItems({bool clearCachedData = false}) {
//    if (clearCachedData) {
//      _data = List<LendRequest>();
//      hasMore = true;
//    }
//    if (_isLoading || !hasMore) {
//      return Future.value();
//    }
//    _isLoading = true;
//
//    requestsListLoad().then((res) {
//      _isLoading = false;
//      _data.addAll(res);
//      hasMore = (res.length == 100);
//
//      print(_data.length);
//
//      _streamcontroller.add(_data);
//    });
//  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<List<LendRequest>> requestsListLoad() async {
    Map<String, String> apiBodyObj = {};
    if (_keywordController.text.length != 0) {
      apiBodyObj['keyword'] = _keywordController.text;
    }
//    apiBodyObj['page_count'] = '100';
//    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/GetRequests', apiBodyObj);

    List responseList = response['request_datas'];

    List<LendRequest> getData = responseList.map<LendRequest>((json) {
      return LendRequest.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: FutureBuilder(
        future: requestsListData,
        builder:
            (BuildContext context, AsyncSnapshot<List<LendRequest>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                          controller: _keywordController,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.blueAccent,
                          ),
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  //print("Hi this is a second print out");
                                  setState(() {
                                    requestsListData = requestsListLoad();
//                                      _isLoading = false;
//                                      hasMore = true;
//                                      offsetApi = 0;
//                                      loadMoreItems(clearCachedData: true);
                                  });
                                },
                              ),
                              hintText: getTranslated(context, "search_name_title"),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueAccent, width: 32.0),
                                  borderRadius: BorderRadius.circular(25.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 32.0),
                                  borderRadius: BorderRadius.circular(25.0)))),
                    ),
                    Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
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
                                                    Icon(
                                                        Icons.donut_large_sharp,
                                                        color: kPrimaryColor,
                                                        size: 12),
                                                    SizedBox(width: 5),
                                                    Text(snapshot
                                                            .data[index].amount
                                                            .toString() +
                                                        '' +
                                                        snapshot.data[index]
                                                            .walletName +
                                                        ' @ ' +
                                                        snapshot.data[index]
                                                            .interestPercent
                                                            .toString() +
                                                        getTranslated(context, "percent_interest"),),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Icon(Icons.calendar_today,
                                                        color: kPrimaryColor,
                                                        size: 16),
                                                    SizedBox(width: 5),
                                                    Text(snapshot
                                                        .data[index].duration
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
                                                style:
                                                    new TextStyle(fontSize: 12),
                                              ),
                                              SizedBox(width: 5),
                                              //Flexible(child:
                                              Text(
                                                  snapshot
                                                      .data[index].pledgedAmount
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
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
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else {
//                                  return Padding(
//                                    padding:
//                                        EdgeInsets.symmetric(vertical: 32.0),
//                                    child: Center(
//                                        child: Text('....................')),
//                                  );
                                return Container();
                              }
                            })),
                  ],
                )
              : Center(child: Loading());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
//          setState(() {
//            Navigator.push(context,
//                MaterialPageRoute(builder: (context) => LendingCreateScreen()));
//          });
          _createButtonTapped();
        },
        //tooltip: 'Increment',
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
      ),
    );
    // TODO: implement build
    //throw UnimplementedError();
  }

  Future _listItemTapped(LendRequest request) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RequestDetailScreen(lendRequest: request),
    ));

    if (results != null && results.containsKey('pledgeStatus')) {
      setState(() {
        String status = results['pledgeStatus'];
        if (status == 'success') {
          String value = results['value'];
          requestsListData = requestsListLoad();
//          _isLoading = false;
//          hasMore = true;
//          offsetApi = 0;
//          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content:
                  Text(getTranslated(context, "you_have_successfully_pledged_an_amount_of") + value),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  Future _createButtonTapped() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LendingCreateScreen()));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'success') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "successfully_created_a_lend_request")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
