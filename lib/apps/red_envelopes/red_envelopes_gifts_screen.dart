import 'package:flutter/material.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/common_methods.dart';
import 'package:tagcash/constants.dart';

import 'model/red_envelopes.dart';

class RedEnvelopeGiftsScreen extends StatefulWidget {
  @override
  _RedEnvelopeGiftsScreenState createState() => _RedEnvelopeGiftsScreenState();
}

class _RedEnvelopeGiftsScreenState extends State<RedEnvelopeGiftsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<RedEnvelope> _giftsList = [];

  bool isLoading = true;
  bool loadingProgress = false;
  bool loadMore = false;

  final int limit = 10;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadingProgress = false;
    loadMore = false;

    getRedEvpGiftList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future getRedEvpGiftList([bool refresh = false]) async {
    var apiBodyObj = {
      "envelope_status": "1",
      "count": limit.toString(),
      "offset": refresh ? "0" : _giftsList.length.toString()
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('RedEnvelops/userEnvelops', apiBodyObj);

    if (response["status"] == "success") {
      List responseList = response['envelops'];
      var pagedGiftList = responseList.map<RedEnvelope>((json) {
        return RedEnvelope.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
        loadingProgress = false;
        loadMore = pagedGiftList.length == limit;

        if (refresh)
          _giftsList = pagedGiftList;
        else
          _giftsList.addAll(pagedGiftList);
      });
    } else {
      setState(() {
        loadMore = false;
        loadingProgress = false;
        isLoading = false;
      });
    }
  }

  Future<void> refreshHistory() {
    setState(() {
      loadMore = false;
    });

    getRedEvpGiftList(true);
    return Future.value();
  }

  Future redeemVoucherClickHanlder(RedEnvelope gift) async {
    setState(() {
      isLoading = true;
    });

    var apiBodyObj = {"voucher_code": gift.textId};

    Map<String, dynamic> response =
        await NetworkHelper.request('RedEnvelops/redeem', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        isLoading = false;
        _giftsList = [];
      });
      getRedEvpGiftList();
      transactionConfirmedModal(gift);
    } else {
      setState(() {
        isLoading = false;
      });
      switch (response['error']) {
        case 'kyc_verification_failed':
        case 'verification failed':
        case 'verification failed':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(
                  context, 'red_envelope_kyc_verification_failed'));
          break;
        case 'invalid_or_expired_voucher':
        case 'expired_voucher':
        case 'redemption_limit_reached':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message:
                  getTranslated(context, 'red_envelope_invalid_or_expired'));
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(context, 'error_occurred'));
      }
    }
  }

  transactionConfirmedModal(RedEnvelope gift) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 65,
                      height: 65,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 30),
                      child: Icon(Icons.check, size: 30, color: Colors.green),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(75))),
                  Text(
                    "${getTranslated(context, "red_envelope_transaction_confirmed")}",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${CommonMethods.removeTrailingZeros(gift.voucherAmount)} ${gift.currencyCode}",
                    style: TextStyle(
                        fontSize: 22.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
        });
  }

  giftDetailClickHandle(RedEnvelope gift) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          if (gift.randomize == 1) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      gift.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                        "${getTranslated(context, "red_envelope_packet_automatically_message")}"),
                    SizedBox(height: 20),
                    Center(
                        child: IconButton(
                      padding: EdgeInsets.all(0),
                      alignment: Alignment.center,
                      icon: Icon(Icons.email_outlined,
                          color: Theme.of(context).primaryColor, size: 70),
                      onPressed: () {
                        Navigator.pop(context);
                        redeemVoucherClickHanlder(gift);
                      },
                    ))
                  ],
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.mark_email_read_outlined,
                        color: Theme.of(context).primaryColor, size: 70),
                    SizedBox(height: 10),
                    Text(
                      gift.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text("${getTranslated(context, "red_envelope_given")}"),
                    SizedBox(height: 20),
                    Text(
                      "${CommonMethods.removeTrailingZeros(gift.voucherAmount)} ${gift.currencyCode}",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    AnimatedContainer(
                      height: 50,
                      width: isLoading ? 50 : 320,
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 6),
                            blurRadius: 12,
                            color: Color(0xFF173347).withOpacity(0.23),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ))
                          : GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                redeemVoucherClickHanlder(gift);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'red_envelope_redeem'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                var shouldLoadMore = !loadingProgress &&
                    loadMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent;

                if (shouldLoadMore) {
                  setState(() {
                    loadingProgress = true;
                  });

                  getRedEvpGiftList();
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: refreshHistory,
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _giftsList.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _giftsList.length) {
                      return buildGiftRow(_giftsList[index]);
                    } else if (loadMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Loading()),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox()
          ],
        ));
  }

  buildGiftRow(RedEnvelope gift) {
    IconData giftIcon;
    String subTitle;
    if (gift.randomize == 1) {
      giftIcon = Icons.email_outlined;
      subTitle =
          "${getTranslated(context, "amount")} - ${getTranslated(context, "red_envelope_surprise")}";
    } else {
      giftIcon = Icons.mark_email_read_outlined;
      subTitle =
          "${getTranslated(context, "amount")} - ${CommonMethods.removeTrailingZeros(gift.voucherAmount)} ${gift.currencyCode}";
    }
    return Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Card(
            child: ListTile(
          leading: Container(
            height: double.infinity,
            child: Icon(
              giftIcon,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          title: Text(gift.title, style: TextStyle(fontSize: 16)),
          subtitle: Text(subTitle),
          onTap: () => giftDetailClickHandle(gift),
        )));
  }
}
