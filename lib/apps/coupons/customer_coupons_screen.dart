import 'package:tagcash/apps/coupons/models/merchant_coupon.dart';
import 'dart:async';
import 'package:tagcash/apps/coupons/coupon_merchant_redeem_screen.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/coupons/models/customer_coupon.dart';
import 'package:tagcash/localization/language_constants.dart';

class CustomerCouponsScreen extends StatefulWidget {
  final MerchantCoupon coupon;

  const CustomerCouponsScreen({Key key, this.coupon}) : super(key: key);

  @override
  _CustomerCouponsScreenState createState() => _CustomerCouponsScreenState();
}

class _CustomerCouponsScreenState extends State<CustomerCouponsScreen> {
  Future<List<CustomerCoupon>> customerCoupons;
  final globalKey = GlobalKey<ScaffoldState>();

  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _nameController.text = '';
    customerCoupons = customerCouponsLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<CustomerCoupon>> customerCouponsLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['coupon_id'] = widget.coupon.id;
    if (_nameController.text.length != 0) {
      apiBodyObj['keyword'] = _nameController.text;
    }
    Map<String, dynamic> response =
        await NetworkHelper.request('coupon/GetCouponPurchase', apiBodyObj);

    List responseList = response['result'];

    List<CustomerCoupon> getData = responseList.map<CustomerCoupon>((json) {
      return CustomerCoupon.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        body: FutureBuilder(
          future: customerCoupons,
          builder: (BuildContext context,
              AsyncSnapshot<List<CustomerCoupon>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? Column(children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                          controller: _nameController,
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
                                    //requestsListData = requestsListLoad();

                                    customerCoupons = customerCouponsLoad();
                                  });
                                },
                              ),
                              hintText: getTranslated(context, "search_customer_by_name"),
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
                            return Card(
                              child: GestureDetector(
                                onTap: () {
                                  _listItemTapped(snapshot.data[index]);
                                },
                                child: ListTile(
                                  title: Text(
                                    snapshot.data[index].customerName,
                                  ),
                                  subtitle: Column(
                                    children: [
                                      SizedBox(height: 5),
                                      Text(snapshot.data[index].title),
                                    ],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                ),
                              ),
                            );
                          }),
                    )
                  ])
                : Center(child: Loading());
          },
        ));
  }

  Future _listItemTapped(CustomerCoupon coupon) async {
    //print("00000" + coupon.codes.toString());
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CouponMerchantRedeemScreen(coupon: coupon),
    ));
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'redeemSuccess') {
          customerCoupons = customerCouponsLoad();
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "coupon_redeemed_successfully")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
