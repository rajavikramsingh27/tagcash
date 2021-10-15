import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/common_methods.dart';

import 'create_expense_screen.dart';
import 'models/expense_data.dart';
import 'models/expense_merchant_list.dart';

class ExpenseRequestsPage extends StatefulWidget {
  const ExpenseRequestsPage({Key key}) : super(key: key);

  @override
  _ExpenseRequestsPageState createState() => _ExpenseRequestsPageState();
}

class _ExpenseRequestsPageState extends State<ExpenseRequestsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<List<ExpenseData>> requestCategoryList;
  var merchantList = new List<MerchantList>();
  bool isLoading = false;
  bool isMerchantDataBo = false;
  var merchantObj;
  void initState() {
    requestCategoryList = getExpenseRequestList();
    getMerchantList();
    super.initState();
  }

  getMerchantList() async {
    Map<String, String> apiBodyObj = {};
    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/ListMerchants', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        Iterable list = response['list'];
        if (list.length != 0) {
          isMerchantDataBo = true;
          merchantObj =
              list.map((model) => MerchantList.fromJson(model)).toList();
        } else {
          isMerchantDataBo = false;
        }
      });
    }
  }

  Future<List<ExpenseData>> getExpenseRequestList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['request_status'] = 'pending';

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/ListRequest', apiBodyObj);

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

  deleteExpenseRequest(id) async {
    setState(() {
      isLoading = true;
    });
    var apiBodyObj = {};
    apiBodyObj['request_id'] = id.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/DeleteRequest', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        isLoading = false;
        Navigator.of(context).pop();
        requestCategoryList = getExpenseRequestList();
      });
    }
  }

  detailsClicked(ExpenseData expenseData) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(getTranslated(context, "expense_request"),
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .apply(color: Colors.red)),
                  ),
                  SizedBox(height: 10),
                  Text(CommonMethods.formatDateTime(
                    DateTime.parse(expenseData.requestDate),
                  )),
                  SizedBox(height: 4),
                  Text(
                    expenseData.amount.toString() +
                        " " +
                        expenseData.currencyCode.toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 4),
                  Text(
                    expenseData.typeDetails,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 4),
                  Text(expenseData.typeDescription),
                  Text(expenseData.description),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    color: Colors.black12,
                    height: 180.0,
                    child: GestureDetector(
                      onTap: () => showImage(expenseData.receipt),
                      child: Image.network(
                        expenseData.receipt,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      deleteExpenseRequest(expenseData.requestId);
                    },
                    child: Text(getTranslated(context, "delete")),
                  ),
                ],
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
      floatingActionButton: isMerchantDataBo
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                          builder: (_) => CreateExpenseScreen(
                                data: merchantObj,
                              )),
                    )
                    .then((val) => val
                        ? setState(() {
                            requestCategoryList = getExpenseRequestList();
                          })
                        : null);
              },
              child: Icon(Icons.add),
            )
          : null,
      body: Stack(
        children: [
          FutureBuilder(
            future: requestCategoryList,
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
                          ]),
                          onTap: () => detailsClicked(snapshot.data[index]),
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
