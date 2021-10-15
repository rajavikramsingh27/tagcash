import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/rewards/models/month.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/apps/rewards/models/reward_history_transaction.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';

class RewardsHistoryScreen extends StatefulWidget {
  @override
  _RewardsHistoryScreenState createState() => _RewardsHistoryScreenState();
}

class _RewardsHistoryScreenState extends State<RewardsHistoryScreen> {
  Future<List<Month>> months;
  StreamController<List<RewardHistoryTransaction>> _streamcontroller;
  final scrollController = ScrollController();
  TextEditingController _keywordController;
  int offsetApi = 0;
  List<RewardHistoryTransaction> _data;

  int _selectedItem = -1;

  //List<Month> months;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();
  String monthYear;

  @override
  void initState() {
    _keywordController = TextEditingController();
    months = monthsLoad();
    _data = List<RewardHistoryTransaction>();
    _streamcontroller =
        StreamController<List<RewardHistoryTransaction>>.broadcast();

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
    _keywordController.text = '';
    _isLoading = false;
    hasMore = true;
    offsetApi = 0;
    monthYear = null;
    _selectedItem = -1;
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<RewardHistoryTransaction>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    historyListLoad().then((res) {
      _isLoading = false;
      _data.addAll(res);
      hasMore = (res.length == 10);

      print(_data.length);

      _streamcontroller.add(_data);
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<List<RewardHistoryTransaction>> historyListLoad() async {
    print('historyListLoad ' + _selectedItem.toString());

    Map<String, String> apiBodyObj = {};
    if (_keywordController.text.length != 0) {
      apiBodyObj['search_keyword'] = _keywordController.text;
    }
    if (_selectedItem > -1) {
      apiBodyObj['month_year'] = monthYear;
      print('GGGJGGG');
    } else
      print('YYYYYYYY');
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/History', apiBodyObj);

    print(response);
    List responseList = response['result']['history'];
//    setState(() {
//      months = response['result']['last_3_months'];
//    });
    List<RewardHistoryTransaction> getData =
        responseList.map<RewardHistoryTransaction>((json) {
      return RewardHistoryTransaction.fromJson(json);
    }).toList();

    return getData;
  }

  Future<List<Month>> monthsLoad() async {
    print('agentLocationsLoad');
//    setState(() {
//      isLoading = true;
//    });
    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/GetLastThreeMonthNames');

    print(response);
    List responseList = response['result'];
//    setState(() {
//      isLoading = false;
//    });
    List<Month> getData = responseList.map<Month>((json) {
      return Month.fromJson(json);
    }).toList();

    return getData;
  }

  selectItem(index, month, monthYear) {
    setState(() {
      _selectedItem = index;
      print(
          _selectedItem.toString() + " " + month + " " + monthYear.toString());
      _isLoading = false;
      hasMore = true;
      offsetApi = 0;
      _keywordController.text = '';
      this.monthYear = monthYear.toString();
      loadMoreItems(clearCachedData: true);
    });
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
              AsyncSnapshot<List<RewardHistoryTransaction>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? Column(children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
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
                                _isLoading = false;
                                hasMore = true;
                                offsetApi = 0;
                                _selectedItem = -1;
                                monthYear = null;
                                loadMoreItems(clearCachedData: true);
                              },
                            ),
                            hintText: getTranslated(context, "reward_search"),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueAccent, width: 32.0),
                                borderRadius: BorderRadius.circular(25.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white, width: 32.0),
                                borderRadius: BorderRadius.circular(25.0))),
                        validator: (value) {
                          if (!Validator.isRequired(value,
                              allowEmptySpaces: false)) {
                            var msg =
                                getTranslated(context, "reward_enter_number");
                            return msg;
                          }
                          return null;
                        },
                      ),
                    ),
                    new Container(
                      height: 50.0,
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: FutureBuilder(
                        future: months,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Month>> snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? new Container(
                                  width: 330,
                                  alignment: Alignment.centerRight,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 10, 5, 10),
                                            child: RadioItem(
                                              selectItem,
                                              // callback function, setstate for parent
                                              index: index,
                                              isSelected: _selectedItem == index
                                                  ? true
                                                  : false,
                                              title: snapshot.data[index].month,
                                              monthYear: snapshot
                                                  .data[index].monthYear,
                                            ));
                                      }))
                              : Center(child: Loading());
                        },
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            controller: scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: snapshot.data.length + 1,
                            //itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < snapshot.data.length) {
                                return Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            snapshot.data[index].date,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              snapshot.data[index].amountSum,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: snapshot
                                              .data[index].transactions.length,
                                          itemBuilder: (BuildContext context,
                                              int index1) {
                                            if (index1 <
                                                snapshot.data[index]
                                                    .transactions.length) {
                                              return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 10, 10, 0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 8,
                                                            child: Text(
                                                              snapshot
                                                                  .data[index]
                                                                  .transactions[
                                                                      index1]
                                                                  .toUserName,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                snapshot
                                                                    .data[index]
                                                                    .transactions[
                                                                        index1]
                                                                    .amount,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 5, 10, 10),
                                                      child: Text(
                                                        snapshot
                                                            .data[index]
                                                            .transactions[
                                                                index1]
                                                            .createdDate,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  ]);
                                            }
                                          }),
                                    ),
                                  ),
                                ]);
                              } else if (hasMore) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else {
//                        return Padding(
//                          padding: EdgeInsets.symmetric(vertical: 32.0),
//                          child: Center(child: Text('....................')),
//                        );
                                return Container();
                              }
                            }))
                  ])
                : Center(child: Loading());
          },
        ),
      ),
    );
  }
}

class RadioItem extends StatefulWidget {
  final String title, monthYear;
  final int index;
  final bool isSelected;
  Function(int, String, String) selectItem;

  RadioItem(this.selectItem,
      {Key key, this.title, this.index, this.isSelected, this.monthYear})
      : super(key: key);

  _RadioItemState createState() => _RadioItemState();
}

class _RadioItemState extends State<RadioItem> {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          widget.selectItem(widget.index, widget.title, widget.monthYear);
        },
        child: new Container(
          height: 50.0,
          width: 100.0,
          child: new Center(
            child: new Text(widget.title,
                style: new TextStyle(
                    color: widget.isSelected ? Colors.white : Colors.black,
                    //fontWeight: FontWeight.bold,
                    fontSize: 16.0)),
          ),
          decoration: new BoxDecoration(
            color: widget.isSelected ? kPrimaryColor : Colors.transparent,
            border: widget.isSelected
                ? Border.all(
                    width: 1,
                    color: kPrimaryColor,
                  )
                : Border.all(
                    width: 1,
                    color: Colors.black,
                  ),
            borderRadius: const BorderRadius.all(const Radius.circular(5.0)),
          ),
        ));
  }
}
