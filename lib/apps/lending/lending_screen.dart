import 'dart:async';
import 'package:tagcash/constants.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/lending/lend_detail_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/lending/models/lend.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

class LendingScreen extends StatefulWidget {
  @override
  _LendingScreenState createState() => _LendingScreenState();
}

class _LendingScreenState extends State<LendingScreen> {
//  StreamController<List<Lend>> _streamcontroller;
//  final scrollController = ScrollController();
//  int offsetApi = 0;
//  List<Lend> _data;
//  bool hasMore;
//  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  Future<List<Lend>> lendingListData;
  var totalPaidAmount;
  String searchKey = "all";
  final status = {
    'all': 'All',
    'pending': 'Pending',
    'accepted': 'Owing',
    'due': 'Defaulted',
    'completed': 'Completed'
  };

  @override
  void initState() {
    lendingListData = lendingListLoad();
//    _data = List<Lend>();
//    _streamcontroller = StreamController<List<Lend>>.broadcast();
//
//    _isLoading = false;
//    hasMore = true;

//    loadMoreItems();

//    scrollController.addListener(() {
//      if (scrollController.position.maxScrollExtent ==
//          scrollController.offset) {
//        print('posts.loadMore');
//        offsetApi = offsetApi + 10;
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
//      _data = List<Lend>();
//      hasMore = true;
//    }
//    if (_isLoading || !hasMore) {
//      return Future.value();
//    }
//    _isLoading = true;
//
//    lendingListLoad().then((res) {
//      _isLoading = false;
//      _data.addAll(res);
//      hasMore = (res.length == 10);
//
//      print(_data.length);
//
//      _streamcontroller.add(_data);
//    });
//  }

  Future<List<Lend>> lendingListLoad() async {
    print('lendingListLoad');
    print(searchKey);

    Map<String, String> apiBodyObj = {};
    if (searchKey != null && searchKey.length != 0) {
      if (searchKey != "all") apiBodyObj['status'] = searchKey;
    }
//    apiBodyObj['page_count'] = '10';
//    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response = await NetworkHelper.request(
        'PeerToPeer/GetAllPledgedRequests', apiBodyObj);

    print(response);
    List responseList = response['result'];
    totalPaidAmount =
        response['paid_details']['total_amount_paid_with_interest'];
    print(totalPaidAmount.toString());
    List<Lend> getData = responseList.map<Lend>((json) {
      return Lend.fromJson(json);
    }).toList();

    return getData;
  }

  Future _listItemTapped(Lend lend) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LendDetailScreen(lend: lend),
    ));

    if (results != null && results.containsKey('cancelPledgeStatus')) {
      setState(() {
        String status = results['cancelPledgeStatus'];
        if (status == 'success') {

          searchKey = "all";
          lendingListData = lendingListLoad();
//          _isLoading = false;
//          hasMore = true;
//          offsetApi = 0;
//          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "successfully_canceled_the_pledge")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    } else if (results != null && results.containsKey('pledgeStatus')) {
      setState(() {
        String status = results['pledgeStatus'];
        if (status == 'success') {
          String value = results['value'];

          searchKey = "all";
          lendingListData = lendingListLoad();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body:

//      RefreshIndicator(
//        onRefresh: dataRefresh,
//        child: StreamBuilder(
//          stream: _streamcontroller.stream,
      FutureBuilder(
        future: lendingListData,
          builder: (BuildContext context, AsyncSnapshot<List<Lend>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? Column(
                    children: [
                      Row(children: [
                        Container(
                          width: 130,
                          margin: EdgeInsets.all(10),
                          child: DropdownButtonFormField(
                            // value: _ratingController,
                            items: status.entries
                                .map<DropdownMenuItem<String>>(
                                    (MapEntry<String, String> e) =>
                                        DropdownMenuItem<String>(
                                          value: e.key,
                                          child: Text(e.value),
                                        ))
                                .toList(),
                            decoration: InputDecoration(
                              hintText: 'All',
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.yellow),
                            ),
                            onChanged: (value) {
                              setState(() {

                                searchKey = value;
                                lendingListData = lendingListLoad();
//                                _isLoading = false;
//                                hasMore = true;
//                                offsetApi = 0;
//                                loadMoreItems(clearCachedData: true);
                              });
                            },
                          ),
                        ),
                        //SizedBox(width: 5),
                        Expanded(
                          child: Text(
                              getTranslated(context, "total_to_pay_repaid")+' ' +
                                  totalPaidAmount.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      Expanded(
                          child: ListView.builder(
                        //itemCount: snapshot.data.length,
//                        controller: scrollController,
//                        physics: AlwaysScrollableScrollPhysics(),
//                        itemCount: snapshot.data.length + 1,

            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < snapshot.data.length) {
                            return Card(
                              //margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: GestureDetector(
                                onTap: () {
//                              setState(() {
//                                Navigator.push(
//                                  context,
//                                  MaterialPageRoute(
//                                    builder: (context) => LendDetailScreen(
//                                        lend: snapshot.data[index]),
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
                                                Icon(Icons.donut_large_sharp,
                                                    color: kPrimaryColor,
                                                    size: 12),
                                                SizedBox(width: 5),
                                                Text(snapshot.data[index].amount
                                                        .toString() +
                                                    '' +
                                                    snapshot.data[index]
                                                        .walletName +
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
                                        child: _getCurrentStatus(
                                            snapshot.data[index])),
                                  ],
                                ),
                              ),
                            );
                          }

//                          else if (hasMore) {
//                            return Padding(
//                              padding: EdgeInsets.symmetric(vertical: 32.0),
//                              child: Center(child: CircularProgressIndicator()),
//                            );
//                          }

                          else {
//          return Padding(
//          padding:
//          EdgeInsets.symmetric(vertical: 32.0),
//          child: Center(
//          child: Text('....................')),
//          );
                            return Container();
                          }
                        },
                      )),
                    ],
                  )
                : Center(child: Loading());
          },
        ),
      //),
    );
//      floatingActionButton: FloatingActionButton(
//        //onPressed: _incrementCounter,
//        //tooltip: 'Increment',
//        child: Icon(Icons.add),
//        backgroundColor: Colors.red,
//      ),

    // TODO: implement build
    //throw UnimplementedError();
  }

  Widget _getCurrentStatus(Lend lend) {
    if (lend.currentStatus == "PLEDGED")
      return Column(
        children: [
          Text(
            getTranslated(context, "pledged"),
            style: new TextStyle(fontSize: 12),
          ),
          SizedBox(width: 5),
          //Flexible(child:
          Text(lend.pledgedAmount.toString(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          //),
        ],
      );
    else if (lend.currentStatus == "OWING")
      return Column(
        children: [
          Text(
            getTranslated(context, "loaned_upper"),
            style: new TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          SizedBox(width: 5),
          //Flexible(child:
          Text(lend.loanedAmount.toString(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Text(
            getTranslated(context, "owing"),
            style: new TextStyle(fontSize: 12),
          ),
          SizedBox(width: 5),
          Text(lend.amountPending.toString(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          //),
        ],
      );
    else if (lend.currentStatus == "COMPLETED")
      return Column(
        children: [
          Text(
            getTranslated(context, "loaned_upper"),
            style: new TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          SizedBox(width: 5),
          //Flexible(child:
          Text(lend.loanedAmount.toString(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Text(
            getTranslated(context, "completed"),
            style: new TextStyle(fontSize: 12, color: Colors.green[500]),
          ),
          SizedBox(width: 5),
          Text(lend.amountPaidWithInterest.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green[500])),
          //),
        ],
      );
    else if (lend.currentStatus == "DEFAULTED")
      return Column(
        children: [
          Text(
            getTranslated(context, "loaned_upper"),
            style: new TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          SizedBox(width: 5),
          //Flexible(child:
          Text(lend.loanedAmount.toString(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Text(
            getTranslated(context, "defaulted"),
            style: new TextStyle(fontSize: 12, color: kPrimaryColor),
          ),
          SizedBox(width: 5),
          Text(lend.dueAmount.toString(),
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
          //),
        ],
      );
    else
      return Container();
  }
}
