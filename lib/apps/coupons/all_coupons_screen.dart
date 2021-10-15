import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/coupons/coupon_purchase_screen.dart';
import 'package:tagcash/apps/coupons/models/coupon.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:location/location.dart';
import 'package:tagcash/localization/language_constants.dart';

class AllCouponsScreen extends StatefulWidget {
  @override
  _AllCouponsScreenState createState() => _AllCouponsScreenState();
}

class _AllCouponsScreenState extends State<AllCouponsScreen> {
  StreamController<List<Coupon>> _streamcontroller;
  final scrollController = ScrollController();
  int offsetApi = 0;
  List<Coupon> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();
  Location location = Location();
  LocationData _locationData;
  bool locationAvailable = false;
  int i = 0;

  @override
  void initState() {
    //_keywordController = TextEditingController();
    checkLocation();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        print('posts.loadMore');
        if (locationAvailable) {
          offsetApi = offsetApi + 10;

          loadMoreItems();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    //_keywordController.dispose();
    super.dispose();
  }

  Future<void> dataRefresh() {
    // _streamcontroller.add(List<Transaction>());
    _isLoading = false;
    hasMore = true;
    i = 0;
    offsetApi = 0;
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<Coupon>();
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

      print(_data.length);

      _streamcontroller.add(_data);
      if (i == 0 && !hasMore) {
        _isLoading = false;
        hasMore = true;
        i++;
        offsetApi = 0;
        loadMoreItems(clearCachedData: false);
      }
    });
  }

  checkLocation() async {
    _isLoading = true;
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData.latitude);
    print(_locationData.longitude);

    setState(() {
      locationAvailable = true;
    });
    _data = List<Coupon>();
    _streamcontroller = StreamController<List<Coupon>>.broadcast();

    _isLoading = false;
    hasMore = true;
    if (locationAvailable) loadMoreItems();
  }

  Future<List<Coupon>> requestsListLoad() async {
    print('requestsListLoad');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['count'] = '10';
    apiBodyObj['offset'] = offsetApi.toString();
    apiBodyObj['latitude'] = _locationData.latitude.toString();
    apiBodyObj['longitude'] = _locationData.longitude.toString();
    if (i > 0) apiBodyObj['viewed_status'] = '1';

    Map<String, dynamic> response =
        await NetworkHelper.request('coupon/GetCoupons', apiBodyObj);

    print(response);
    List responseList = response['result'];

    List<Coupon> getData = responseList.map<Coupon>((json) {
      return Coupon.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: locationAvailable
          ? RefreshIndicator(
              onRefresh: dataRefresh,
              child: StreamBuilder(
                stream: _streamcontroller.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Coupon>> snapshot) {
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
                                    leading:
                                    snapshot.data[index].imageUrl != ""
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.network(
                                        snapshot.data[index].imageUrl,
                                        height: 48.0,
                                        width: 48.0,
                                        fit: BoxFit.fill,
                                      ),
                                    ): Container(
                                        height: 48.0,
                                        width: 48.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: Colors.grey[400],
                                            shape: BoxShape.rectangle),
                                      ),
                                    title: Text(
                                      snapshot.data[index].title,
                                    ),
                                    subtitle: Column(
                                      children: [
                                        SizedBox(height: 5),
                                        Text(snapshot.data[index].ownerName),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(snapshot.data[index].couponType
                                                .toString()),
                                            SizedBox(width: 5),
                                            Icon(Icons.person_outline,
                                                color: Colors.red[500],
                                                size: 18),
                                            Text(snapshot
                                                .data[index].remainingCoupon
                                                .toString()),
                                            SizedBox(width: 5),
                                            Icon(Icons.calendar_today,
                                                color: Colors.red[500],
                                                size: 16),
                                            SizedBox(width: 3),
                                            Text(snapshot
                                                .data[index].expiryDate),
                                          ],
                                        ),
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                  ),
                                ),
                              );
                            } else if (hasMore) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            } else {
                              return Container();
                            }
                          })
                      : Center(child: Loading());
                },
              ),
            )
          : Container(),
    );
  }

  Future _listItemTapped(Coupon coupon) async {
    print("00000" + coupon.codes.toString());
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CouponPurchaseScreen(coupon: coupon),
    ));
//    _isLoading = false;
//    hasMore = true;
//    offsetApi = 0;
//    loadMoreItems(clearCachedData: true);
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'purchaseSuccess') {
          _isLoading = false;
          hasMore = true;
          i = 0;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "coupon_purchase_success")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
