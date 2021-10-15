import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/common_methods.dart';

import '../../constants.dart';
import 'model/red_envelopes_created.dart';

class RedEnvelopeCreatedScreen extends StatefulWidget {
  @override
  _RedEnvelopeCreatedScreenState createState() =>
      _RedEnvelopeCreatedScreenState();
}

class _RedEnvelopeCreatedScreenState extends State<RedEnvelopeCreatedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<RedEnvelopeCreated> _createdList = [];

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

    getRedEvpCreatedList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future getRedEvpCreatedList([bool refresh = false]) async {
    var apiBodyObj = {
      "envelope_status": "1",
      "count": limit.toString(),
      "offset": refresh ? "0" : _createdList.length.toString()
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('RedEnvelops/list', apiBodyObj);

    if (response["status"] == "success") {
      List responseList = response['envelops'];
      var pagedCreatedList = responseList.map<RedEnvelopeCreated>((json) {
        return RedEnvelopeCreated.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
        loadingProgress = false;
        loadMore = pagedCreatedList.length == limit;

        if (refresh)
          _createdList = pagedCreatedList;
        else
          _createdList.addAll(pagedCreatedList);
      });
    } else {
      setState(() {
        loadMore = false;
        loadingProgress = false;
        isLoading = false;
      });
    }
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> refreshHistory() {
    setState(() {
      loadMore = false;
    });
    getRedEvpCreatedList(true);
    return Future.value();
  }

  Future deleteVoucherHandler(RedEnvelopeCreated created) async {
    setState(() {
      isLoading = true;
    });

    var apiBodyObj = {"id": created.id.toString()};

    Map<String, dynamic> response =
        await NetworkHelper.request('RedEnvelops/cancel', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        isLoading = false;
        _createdList = [];
      });
      showSnackBar(getTranslated(context, 'red_envelope_deleted'));
      getRedEvpCreatedList();
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: getTranslated(context, 'network_error_message'));
      setState(() {
        isLoading = false;
      });
    }
  }

  getCreatedRedEnevlopDetailClickHandle(RedEnvelopeCreated created) {
    IconData createdIcon;
    if (created.randomize == 1) {
      createdIcon = Icons.email_outlined;
    } else {
      createdIcon = Icons.mark_email_read_outlined;
    }

    String receipient_type;
    switch ("${created.enveloperReceipientType}") {
      case "1":
        receipient_type = getTranslated(context, 'red_envelope_manualy_added');
        break;
      case "2":
        receipient_type =
            getTranslated(context, 'red_envelope_manualy_community_role');
        break;
      case "3":
        receipient_type =
            getTranslated(context, 'red_envelope_manualy_all_member_community');
        break;
      case "4":
        receipient_type = getTranslated(context, 'red_envelope_anyone');
        break;
      case "5":
        receipient_type =
            getTranslated(context, 'red_envelope_use_all_friends');
        break;
    }

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
                  Icon(createdIcon,
                      color: Theme.of(context).primaryColor, size: 70),
                  SizedBox(height: 20),
                  Text(
                    "${CommonMethods.removeTrailingZeros(created.envelopeTotalAmount)} ${created.currencyCode}",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(receipient_type + " (${created.envelopeTotalUsers})",
                      style: Theme.of(context).textTheme.subtitle1),
                  SizedBox(height: 10),
                  Text(CommonMethods.formatDateTime(created.createdAt),
                      style: Theme.of(context).textTheme.subtitle1),
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
                              deleteVoucherHandler(created);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                                child: Text(
                              getTranslated(context, 'delete'),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            )),
                          ),
                  ),
                ],
              ),
            ),
          );
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

                  getRedEvpCreatedList();
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: refreshHistory,
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _createdList.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _createdList.length) {
                      return buildCreatedRow(_createdList[index]);
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

  buildCreatedRow(RedEnvelopeCreated created) {
    IconData createdIcon;
    String subTitle =
        "${getTranslated(context, "red_envelope_total_amount")} - ${created.envelopeTotalAmount} ${created.currencyCode}";
    if (created.randomize == 1) {
      createdIcon = Icons.email_outlined;
    } else {
      createdIcon = Icons.mark_email_read_outlined;
    }
    return Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Card(
            child: ListTile(
          leading: Container(
            height: double.infinity,
            child: Icon(createdIcon,
                color: Theme.of(context).primaryColor, size: 30),
          ),
          title: Text(created.title, style: TextStyle(fontSize: 16)),
          subtitle: Text(subTitle),
          onTap: () => getCreatedRedEnevlopDetailClickHandle(created),
        )));
  }
}
