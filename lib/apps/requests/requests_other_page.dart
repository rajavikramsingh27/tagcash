import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'models/request_other.dart';

class RequestsOtherPage extends StatefulWidget {
  const RequestsOtherPage({Key key}) : super(key: key);

  @override
  _RequestsOtherPageState createState() => _RequestsOtherPageState();
}

class _RequestsOtherPageState extends State<RequestsOtherPage> {
  Future<List<RequestOther>> requestsDataList;

  @override
  void initState() {
    super.initState();

    requestsDataList = requestsListLoad();
  }

  Future<List<RequestOther>> requestsListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['send'] = '0';

    Map<String, dynamic> response =
        await NetworkHelper.request('Credit/ListRequests', apiBodyObj);

    List responseList = response['result'];

    List<RequestOther> getData = responseList.map<RequestOther>((json) {
      return RequestOther.fromJson(json);
    }).toList();

    return getData;
  }

  requestsClicked(RequestOther request) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: RequestOtherDetails(request: request),
            ),
          );
        }).then((value) {
      if (value != null) {
        requestsDataList = requestsListLoad();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: requestsDataList,
        builder:
            (BuildContext context, AsyncSnapshot<List<RequestOther>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Opacity(
                      opacity:
                          snapshot.data[index].status == 'Pending' ? 1 : 0.5,
                      child: ListTile(
                        title: Text(snapshot.data[index].requestFromName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${snapshot.data[index].requestAmount} ${snapshot.data[index].currencyCode}'),
                            Text(DateFormat('dd MMM yyy').format(
                              DateTime.parse(snapshot.data[index].requestDate),
                            )),
                          ],
                        ),
                        trailing:
                            Text(snapshot.data[index].status.toUpperCase()),
                        onTap: () => requestsClicked(snapshot.data[index]),
                      ),
                    );
                  },
                )
              : Center(child: Loading());
        },
      ),
    );
  }
}

class RequestOtherDetails extends StatefulWidget {
  final RequestOther request;
  const RequestOtherDetails({
    Key key,
    this.request,
  }) : super(key: key);

  @override
  _RequestOtherDetailsState createState() => _RequestOtherDetailsState();
}

class _RequestOtherDetailsState extends State<RequestOtherDetails> {
  bool isLoading = false;

  void declineRequestClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'credit/Declinerequest/' + widget.request.id.toString());

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, true);
      Fluttertoast.showToast(msg: getTranslated(context, "request_declined"));
    }
  }

  void approveRequestClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'credit/Approverequest/' + widget.request.id.toString());

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, true);
      Fluttertoast.showToast(
          msg: getTranslated(context, "request_payment_proccessed"));
    } else {
      if (response['error'] == 'insufficient_amount') {
        Fluttertoast.showToast(
            msg: getTranslated(context, "request_insufficient_fund"));
      } else {
        Fluttertoast.showToast(msg: getTranslated(context, "error_occurred"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                getTranslated(context, "request_to_pay_from"),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 10),
              Text(
                widget.request.requestFromName,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${widget.request.requestAmount} ${widget.request.currencyCode}',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
              Text(DateFormat('dd MMM yyy').format(
                DateTime.parse(widget.request.requestDate),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.request.status.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Text(
                widget.request.remarks,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              widget.request.status == 'Pending'
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => declineRequestClickHandler(),
                              child: Text(
                                  getTranslated(context, "request_decline")),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => approveRequestClickHandler(),
                              child: Text(
                                  getTranslated(context, "request_paynow")),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
