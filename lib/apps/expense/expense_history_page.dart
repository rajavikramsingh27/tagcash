import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/common_methods.dart';

import 'models/expense_data.dart';

class ExpenseHistoryPage extends StatefulWidget {
  const ExpenseHistoryPage({Key key}) : super(key: key);

  @override
  _ExpenseHistoryPageState createState() => _ExpenseHistoryPageState();
}

class _ExpenseHistoryPageState extends State<ExpenseHistoryPage> {
  bool merchantBo = false;

  Future<List<ExpenseData>> historyList;
  List<ExpenseData> history = List<ExpenseData>();
  Future<List<ExpenseData>> rejectList;
  bool isLoading = false;

  void initState() {
    // history.clear();
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      merchantBo = true;
    } else {
      merchantBo = false;
    }

    getFromApproveRequestList();
    super.initState();
  }

  // @override
  // void dispose() {
  //   history.clear();
  //   super.dispose();
  // }

  getFromApproveRequestList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['request_status'] = 'approved';

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/ListRequest', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        history.clear();
        Iterable list = response['list'];
        if (list != null) {
          history = list.map((model) => ExpenseData.fromJson(model)).toList();
        }
        isLoading = false;
      });
      if (merchantBo == true) {
        getToApproveRequestList();
      } else {
        getFromExpenseRejectHisList();
      }
    }
  }

  getFromExpenseRejectHisList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['request_status'] = 'reject';

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/ListRequest', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        Iterable list = response['list'];
        if (list != null) {
          var kk = list.map((model) => ExpenseData.fromJson(model)).toList();
          history.addAll(kk);
        }
        isLoading = false;
      });
      if (merchantBo == true) {
        getToExpenseRejectHisList();
      } else {
        historyList = approveRequestList();
      }
    }
  }

  getToExpenseRejectHisList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['request_status'] = 'reject';

    Map<String, dynamic> response = await NetworkHelper.request(
        'Expense/ListRequestByCommunity', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        Iterable list = response['list'];
        if (list != null) {
          var kk = list.map((model) => ExpenseData.fromJson(model)).toList();
          history.addAll(kk);
        }
        isLoading = false;

        historyList = approveRequestList();
      });
    }
  }

  Future<List<ExpenseData>> approveRequestList() async {
    return history;
  }

  getToApproveRequestList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['request_status'] = 'approved';

    Map<String, dynamic> response = await NetworkHelper.request(
        'Expense/ListRequestByCommunity', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        Iterable list = response['list'];
        if (list != null) {
          var kk = list.map((model) => ExpenseData.fromJson(model)).toList();
          history.addAll(kk);
        }
        isLoading = false;
      });
      getFromExpenseRejectHisList();
    }
  }

  historyDetails(obj) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Text(
                            getTranslated(context, "expenses_small_single") +
                                "-" +
                                obj.amount.toString() +
                                " " +
                                obj.currencyCode.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .apply(color: Colors.red)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        CommonMethods.formatDateTime(
                            DateTime.parse(obj.requestDate), 'dd MMM yyyy'),
                      ),
                      SizedBox(height: 4),
                      Text(
                        obj.amount.toString() +
                            " " +
                            obj.currencyCode.toString(),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        obj.typeDetails,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      if (obj.typeDescription?.isNotEmpty ?? true) ...[
                        Text(
                          obj.typeDescription,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                      ],
                      Text(
                        obj.description,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      if (obj.approveRequest == "approved") ...[
                        Text(
                          getTranslated(context, "expense_approve_by") +
                              obj.communityName,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .apply(color: Colors.green),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          getTranslated(context, "expense_approve_date") +
                              CommonMethods.formatDateTime(
                                  DateTime.parse(obj.approveDate),
                                  'dd MMM yyyy'),
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                      SizedBox(height: 4),
                      if (obj.approveRequest == "reject") ...[
                        Text(
                          getTranslated(context, "expense_rejected_by") +
                              obj.communityName,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .apply(color: Colors.red),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          getTranslated(context, "expense_rejected_date") +
                              CommonMethods.formatDateTime(
                                  DateTime.parse(obj.approveDate),
                                  'dd MMM yyyy'),
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                      Container(
                        alignment: Alignment.center,
                        color: Colors.black12,
                        height: 180.0,
                        child: GestureDetector(
                          onTap: () => showImage(obj.receipt),
                          child: Image.network(
                            obj.receipt,
                          ),
                        ),
                      ),
                      if (obj.message?.isNotEmpty ?? true) ...[
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          obj.message,
                        ),
                      ],
                    ],
                  )
                  // content padding

                  ),
            ),
          );
        });
  }

  void showImage(String imagePath) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(20.0),
              child: Image(
                image: NetworkImage(imagePath),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: historyList,
            builder: (BuildContext context,
                AsyncSnapshot<List<ExpenseData>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            CommonMethods.formatDateTime(
                                DateTime.parse(
                                    snapshot.data[index].requestDate),
                                'dd MMM yyyy'),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data[index].typeDetails,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Text(
                                snapshot.data[index].description,
                              ),
                            ],
                          ),
                          trailing: Column(children: [
                            Text(
                              snapshot.data[index].amount.toString() +
                                  " " +
                                  snapshot.data[index].currencyCode.toString(),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            if (snapshot.data[index].approveRequest ==
                                "pending")
                              Text(snapshot.data[index].approveRequest,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .apply(color: Colors.green)),
                            if (snapshot.data[index].approveRequest ==
                                "approved")
                              Text(
                                getTranslated(context, "expense_approved_txt"),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .apply(color: Colors.green),
                              ),
                            if (snapshot.data[index].approveRequest == "reject")
                              Text(
                                getTranslated(context, "expense_rejectd"),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .apply(color: Colors.red),
                              ),
                          ]),
                          onTap: () => historyDetails(snapshot.data[index]),
                        );
                      },
                    )
                  : SizedBox();
            },
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
