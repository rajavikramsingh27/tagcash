import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/advertising/advert_create_screen.dart';
import 'package:tagcash/apps/advertising/models/advert.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

class AdvertCreatedListScreen extends StatefulWidget {
  @override
  _AdvertCreatedListScreenState createState() =>
      _AdvertCreatedListScreenState();
}

class _AdvertCreatedListScreenState extends State<AdvertCreatedListScreen> {
  StreamController<List<Advert>> _streamcontroller;
  final scrollController = ScrollController();
  int offsetApi = 0;
  List<Advert> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _data = List<Advert>();
    _streamcontroller = StreamController<List<Advert>>.broadcast();

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
      _data = List<Advert>();
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
    super.dispose();
  }

  Future<List<Advert>> requestsListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response = await NetworkHelper.request(
        'Advertisement/GetAllAddedCampaigns', apiBodyObj);

    List responseList = response['result'];

    List<Advert> getData = responseList.map<Advert>((json) {
      return Advert.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "advertising"),
      ),
      body: RefreshIndicator(
        onRefresh: dataRefresh,
        child: StreamBuilder(
          stream: _streamcontroller.stream,
          builder:
              (BuildContext context, AsyncSnapshot<List<Advert>> snapshot) {
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
                              _listItemTapped(snapshot.data[index]);
                            },
                            child: ListTile(
                              title: Text(
                                snapshot.data[index].campaignTitle,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(snapshot.data[index].maxSpend +
                                      getTranslated(context, "max_ad_views")+" - " +
                                      snapshot.data[index].consumed.toString() +
                                      " "+getTranslated(context, "consumed")),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.red[500], size: 16),
                                      SizedBox(width: 3),
                                      Text(getTranslated(context, "created")+" "+
                                          snapshot.data[index].createdDate),
                                    ],
                                  ),
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
                        return Container();
                      }
                    })
                : Center(child: Loading());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createButtonTapped();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future _createButtonTapped() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AdvertCreateScreen()));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "advert_create_success")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'updateSuccess') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "advert_update_success")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  Future _listItemTapped(Advert advert) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AdvertCreateScreen(advert: advert),
    ));
    _isLoading = false;
    hasMore = true;
    offsetApi = 0;
    loadMoreItems(clearCachedData: true);
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "advert_create_success")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'updateSuccess') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "advert_update_success")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
