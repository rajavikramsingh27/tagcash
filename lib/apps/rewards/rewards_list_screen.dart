import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/rewards/models/reward.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class RewardsListScreen extends StatefulWidget {
  @override
  _RewardsListScreenState createState() => _RewardsListScreenState();
}

class _RewardsListScreenState extends State<RewardsListScreen> {
  StreamController<List<Reward>> _streamcontroller;
  final scrollController = ScrollController();
  TextEditingController _keywordController;
  int offsetApi = 0;
  List<Reward> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _keywordController = TextEditingController();
    _data = List<Reward>();
    _streamcontroller = StreamController<List<Reward>>.broadcast();

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
      _data = List<Reward>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    rewardsListLoad().then((res) {
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

  Future<List<Reward>> rewardsListLoad() async {
    print('rewardsListLoad');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/ListRules', apiBodyObj);

    print(response);
    List responseList = response['result'];

    List<Reward> getData = responseList.map<Reward>((json) {
      return Reward.fromJson(json);
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
              (BuildContext context, AsyncSnapshot<List<Reward>> snapshot) {
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
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, "reward_recive"),
                                            style: new TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                              snapshot.data[index]
                                                      .receiveAmount +
                                                  ' ' +
                                                  snapshot.data[index]
                                                      .receiveCurrencyCode,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 5),
                                          if (snapshot.data[index].roleName !=
                                              "")
                                            Text(snapshot.data[index].roleName),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, "reward_txt"),
                                            style: new TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                              snapshot.data[index]
                                                      .rewardAmount +
                                                  ' ' +
                                                  snapshot.data[index]
                                                      .rewardCurrencyCode,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          //),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        );
                      } else if (hasMore) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return Container();
                      }
                    })
                : Center(child: Loading());
          },
        ),
      ),
    );
  }
}
