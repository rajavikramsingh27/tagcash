import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/charity/charity_create_screen.dart';
import 'package:tagcash/apps/charity/request_detail_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/charity/models/charity_request.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  //Future<List<LendRequest>> requestsListData;
  StreamController<List<CharityRequest>> _streamcontroller;
  final scrollController = ScrollController();
  TextEditingController _keywordController;
  int offsetApi = 0;
  List<CharityRequest> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _keywordController = TextEditingController();
    //requestsListData = requestsListLoad();
    _data = List<CharityRequest>();
    _streamcontroller = StreamController<List<CharityRequest>>.broadcast();

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
      _data = List<CharityRequest>();
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

  Future<List<CharityRequest>> requestsListLoad() async {
    Map<String, String> apiBodyObj = {};
    if (_keywordController.text.length != 0) {
      apiBodyObj['keyword'] = _keywordController.text;
    }
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/GetCharityRequests', apiBodyObj);

    List responseList = response['result'];

    List<CharityRequest> getData = responseList.map<CharityRequest>((json) {
      return CharityRequest.fromJson(json);
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
          builder: (BuildContext context,
              AsyncSnapshot<List<CharityRequest>> snapshot) {
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
                                    setState(() {
                                      //requestsListData = requestsListLoad();
                                      _isLoading = false;
                                      hasMore = true;
                                      offsetApi = 0;
                                      loadMoreItems(clearCachedData: true);
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
                                    borderRadius:
                                        BorderRadius.circular(25.0)))),
                      ),
                      Expanded(
                          child: ListView.builder(
                              controller: scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: snapshot.data.length + 1,
                              //itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (index < snapshot.data.length) {
                                  return Card(
                                    child: GestureDetector(
                                      onTap: () {
                                        _listItemTapped(snapshot.data[index]);
                                      },
                                      child: ListTile(
                                        title: Text(
                                          snapshot.data[index].title,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Icon(Icons.person,
                                                    color: Colors.red[500],
                                                    size: 16),
                                                SizedBox(width: 5),
                                                Text(snapshot
                                                    .data[index].ownerName),
                                                SizedBox(width: 5),
                                                Icon(Icons.calendar_today,
                                                    color: Colors.red[500],
                                                    size: 12),
                                                SizedBox(width: 5),
                                                Text(snapshot
                                                    .data[index].createdDate
                                                    .toString()),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                                getTranslated(context, "donated")+": " +
                                                  snapshot
                                                      .data[index].totalDonated
                                                      .toString(),
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (hasMore) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 32.0),
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
        backgroundColor: Colors.red,
      ),
    );
    // TODO: implement build
    //throw UnimplementedError();
  }

  Future _listItemTapped(CharityRequest request) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RequestDetailScreen(charityRequest: request),
    ));

    if (results != null && results.containsKey('donateStatus')) {
      setState(() {
        String status = results['donateStatus'];
        if (status == 'success') {
          String value = results['value'];
          //requestsListData = requestsListLoad();
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "you_donated_amount_of")+' ' + value),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    } else if (results != null && results.containsKey('rateStatus')) {
      setState(() {
        String status = results['rateStatus'];
        if (status == 'success') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "rating_update_success")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    } else if (results != null && results.containsKey('deleteStatus')) {
      setState(() {
        String status = results['deleteStatus'];
        if (status == 'success') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "you_delete_charity_request")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    } else if (results != null && results.containsKey('disableStatus')) {
      setState(() {
        String status = results['disableStatus'];
        if (status == 'success') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "you_disable_charity_request")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  Future _createButtonTapped() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CharityCreateScreen()));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'success') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "success_create_charity_request")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
