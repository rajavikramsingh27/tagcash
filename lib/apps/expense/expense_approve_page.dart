import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/common_methods.dart';

import 'models/expense_data.dart';

class ExpenseApprovePage extends StatefulWidget {
  const ExpenseApprovePage({Key key}) : super(key: key);

  @override
  _ExpenseApprovePageState createState() => _ExpenseApprovePageState();
}

class _ExpenseApprovePageState extends State<ExpenseApprovePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<List<ExpenseData>> pendingRequestList;
  final messageTxt = TextEditingController();
  bool isLoading = false;

  void initState() {
    pendingRequestList = merchantExpenseRequestList();
    super.initState();
  }

  @override
  void dispose() {
    messageTxt.dispose();
    super.dispose();
  }

  Future<List<ExpenseData>> merchantExpenseRequestList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['request_status'] = 'pending';

    Map<String, dynamic> response = await NetworkHelper.request(
        'Expense/ListRequestByCommunity', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    List<ExpenseData> getData = List<ExpenseData>();
    List responseList = response['list'];

    if (responseList != null) {
      getData = responseList.map<ExpenseData>((json) {
        return ExpenseData.fromJson(json);
      }).toList();
    }
    return getData;
  }

  approveExpenseRequest(requestId) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['request_id'] = requestId.toString();

    if (messageTxt.text != null) {
      apiBodyObj['message'] = messageTxt.text;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/ApproveRequest', apiBodyObj);

    if (response["status"] == "success") {
      Navigator.of(context).pop();
      pendingRequestList = merchantExpenseRequestList();
    } else {
      if (response['error'] == 'insuffcient_balance') {
        var msg =
            getTranslated(context, "expense_insuffcient_balance_to_approve");
        showMessage(msg);
      }
    }
  }

  rejectExpenseRequest(requestId) async {
    var apiBodyObj = {};
    apiBodyObj['request_id'] = requestId.toString();
    if (messageTxt.text != null) {
      apiBodyObj['message'] = messageTxt.text.toString();
    }
    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/RejectRequest', apiBodyObj);

    if (response["status"] == "success") {
      Navigator.of(context).pop();
      pendingRequestList = merchantExpenseRequestList();
    }
  }

  _approveDetailsScreen(obj) {
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
                            getTranslated(context, "expense_request_approve"),
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .apply(color: Colors.red)),
                      ),
                      SizedBox(height: 10),
                      Text(CommonMethods.formatDateTime(
                        DateTime.parse(obj.requestDate),
                      )),
                      SizedBox(height: 4),
                      Text(
                        obj.amount.toString() +
                            " " +
                            obj.currencyCode.toString(),
                        style: Theme.of(context).textTheme.headline6,
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
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                      ],
                      Text(
                        obj.description,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      SizedBox(height: 10),
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
                      TextFormField(
                        minLines: 2,
                        maxLines: 3,
                        controller: messageTxt,
                        decoration: InputDecoration(
                            labelText:
                                getTranslated(context, "expense_message")),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              approveExpenseRequest(obj.requestId);
                            },
                            child: Text(
                                getTranslated(context, "expense_approve_txt")),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              rejectExpenseRequest(obj.requestId);
                            },
                            child:
                                Text(getTranslated(context, "expense_reject")),
                          )),
                        ],
                      ),
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

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          FutureBuilder(
            future: pendingRequestList,
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
                            snapshot.data[index].typeDetails,
                          ),
                          subtitle: Text(
                            snapshot.data[index].description,
                          ),
                          trailing: Text(
                            snapshot.data[index].amount.toString() +
                                " " +
                                snapshot.data[index].currencyCode.toString(),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          onTap: () =>
                              _approveDetailsScreen(snapshot.data[index]),
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
