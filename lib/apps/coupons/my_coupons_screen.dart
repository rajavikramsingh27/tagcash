import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/coupons/coupon_redeem_screen.dart';
import 'package:tagcash/apps/coupons/models/purchased_coupon.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

class MyCouponsScreen extends StatefulWidget {
  @override
  _MyCouponsScreenState createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  Future<List<PurchasedCoupon>> purchasedCoupons;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    purchasedCoupons = purchasedCouponsLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<PurchasedCoupon>> purchasedCouponsLoad() async {
    print('purchasedCouponsLoad');

    Map<String, dynamic> response =
        await NetworkHelper.request('Coupon/MyPurchase');

    List responseList = response['result'];

    List<PurchasedCoupon> getData = responseList.map<PurchasedCoupon>((json) {
      return PurchasedCoupon.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        body: FutureBuilder(
          future: purchasedCoupons,
          builder: (BuildContext context,
              AsyncSnapshot<List<PurchasedCoupon>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: GestureDetector(
                          onTap: () {
                            _listItemTapped(snapshot.data[index]);
                          },
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: snapshot.data[index].imageUrl != ""
                                  ? Image.network(
                                      snapshot.data[index].imageUrl,
                                      height: 48.0,
                                      width: 48.0,
                                      fit: BoxFit.fill,
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
                                    Icon(Icons.calendar_today,
                                        color: Colors.red[500], size: 16),
                                    SizedBox(width: 3),
                                    Text(snapshot.data[index].expiryDate),
                                  ],
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        ),
                      );
                    })
                : Center(child: Loading());
          },
        ));
  }

  Future _listItemTapped(PurchasedCoupon coupon) async {
    //print("00000" + coupon.codes.toString());
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CouponRedeemScreen(coupon: coupon),
    ));
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'redeemSuccess') {
          purchasedCoupons = purchasedCouponsLoad();
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "coupon_redeemed_successfully")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
