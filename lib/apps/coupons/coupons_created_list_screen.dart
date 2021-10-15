import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/coupons/coupons_create_screen.dart';
import 'package:tagcash/apps/coupons/coupons_merchant_manage_screen.dart';
import 'package:tagcash/apps/coupons/models/merchant_coupon.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

class CouponsCreatedListScreen extends StatefulWidget {
  @override
  _CouponsCreatedListScreenState createState() =>
      _CouponsCreatedListScreenState();
}

class _CouponsCreatedListScreenState extends State<CouponsCreatedListScreen> {
  StreamController<List<MerchantCoupon>> _streamcontroller;
  final scrollController = ScrollController();
  int offsetApi = 0;
  List<MerchantCoupon> _data;
  bool hasMore;
  bool _isLoading;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _data = List<MerchantCoupon>();
    _streamcontroller = StreamController<List<MerchantCoupon>>.broadcast();

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
      _data = List<MerchantCoupon>();
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
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<MerchantCoupon>> requestsListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('Coupon/GetMerchantCoupons', apiBodyObj);

    List responseList = response['result'];

    List<MerchantCoupon> getData = responseList.map<MerchantCoupon>((json) {
      return MerchantCoupon.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "coupons"),
      ),
      body: RefreshIndicator(
        onRefresh: dataRefresh,
        child: StreamBuilder(
          stream: _streamcontroller.stream,
          builder: (BuildContext context,
              AsyncSnapshot<List<MerchantCoupon>> snapshot) {
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
                              leading: snapshot.data[index].imageUrl != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.network(
                                        snapshot.data[index].imageUrl,
                                        height: 48.0,
                                        width: 48.0,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Container(
                                      height: 48.0,
                                      width: 48.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey[400],
                                          shape: BoxShape.rectangle),
                                    ),
                              title: Text(
                                snapshot.data[index].title,
                              ),
                              subtitle: Column(
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.red[500], size: 16),
                                      SizedBox(width: 3),
                                      Text(snapshot.data[index].expiryDate),
                                      SizedBox(width: 5),
                                      Icon(Icons.person_outline,
                                          color: Colors.red[500], size: 18),
                                      Text(snapshot.data[index].remainingCoupon
                                          .toString()),
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
    Map results = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CouponsMerchantManageScreen()));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "coupon_created_successfully")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'updateSuccess') {
          _isLoading = false;
          hasMore = true;
          offsetApi = 0;
          loadMoreItems(clearCachedData: true);
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "coupon_updated_successfully")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  Future _listItemTapped(MerchantCoupon coupon) async {
    print("00000" + coupon.codes.toString());
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CouponsMerchantManageScreen(coupon: coupon),
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
              content: Text(getTranslated(context, "coupon_created_successfully")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'updateSuccess') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "coupon_updated_successfully")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'deleteSuccess') {
          String hasVoucherCode = results['hasVoucherCode'];
          if (hasVoucherCode == 'false') {
            final snackBar = SnackBar(
                content: Text(getTranslated(context, "coupon_deleted_successfully")),
                duration: const Duration(seconds: 3));
            globalKey.currentState.showSnackBar(snackBar);
          }
        }
      });
    }
  }
}
