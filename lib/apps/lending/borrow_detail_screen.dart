import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/lending/models/borrow.dart';
import 'package:tagcash/apps/lending/models/borrow_details.dart';
import 'package:tagcash/apps/lending/models/lend_user.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';

class BorrowDetailScreen extends StatefulWidget {
  final Borrow borrow;

  const BorrowDetailScreen({Key key, this.borrow}) : super(key: key);

  @override
  _BorrowDetailScreenState createState() => _BorrowDetailScreenState();
}

class _BorrowDetailScreenState extends State<BorrowDetailScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  Future<BorrowDetails> borrowDetails;

  @override
  void initState() {
    super.initState();
    if (widget.borrow.requestStatus == 2) borrowDetails = borrowDetailsLoad();
  }

  Future<List<LendUser>> lendersListLoad() async {
    print('lendersListLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lend_request_id'] = widget.borrow.id;
    Map<String, dynamic> response = await NetworkHelper.request(
        'PeerToPeer/GetAllPledgedUsers', apiBodyObj);

    List responseList = response['result'];
    setState(() {
      isLoading = false;
    });
    List<LendUser> getData = responseList.map<LendUser>((json) {
      return LendUser.fromJson(json);
    }).toList();
    if (getData.length > 0)
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: new Text(
                  getTranslated(context, "lenders_list"),
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: kPrimaryColor),
                ),
                contentPadding: EdgeInsets.all(5.0),
                content: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: getData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Row(children: [
                          Expanded(
                            flex: 73,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Text(
                                getData[index].fullName,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 27,
                            child: Text(
                              getData[index].pledgeAmount.toString(),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ]),
                      );
                    }));
          });
    return getData;
  }

  Future<BorrowDetails> borrowDetailsLoad() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lend_request_id'] = widget.borrow.id;
    Map<String, dynamic> response = await NetworkHelper.request(
        'PeerToPeer/GetRequestBorrowersList', apiBodyObj);

    Map responseLoanStatus = response['result'];
    setState(() {
      isLoading = false;
    });
    BorrowDetails getData = BorrowDetails.fromJson(responseLoanStatus);
    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "crowd_lending"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new GestureDetector(
                    onTap: () {
                      if (widget.borrow.lendersCount > 0)
                        lendersListLoad();
                      else
                        final snackBar = SnackBar(
                            content: Text(
                              getTranslated(context, "no_lenders_found"),
                            ),
                            duration: const Duration(seconds: 3));
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.borrow.walletName +
                                ' ' +
                                widget.borrow.amount.toString(),
                            maxLines: 1,
                            style:
                                //Theme.of(context).textTheme.headline5,
                                TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            getTranslated(context, "pledged") +
                                ' ' +
                                widget.borrow.walletName +
                                ' ' +
                                widget.borrow.pledgedAmount.toString() +
                                ' ' +
                                getTranslated(context, "from") +
                                ' ' +
                                widget.borrow.lendersCount.toString() +
                                ' ' +
                                getTranslated(context, "lenders"),
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: kPrimaryColor),
                          ),
                          SizedBox(height: 10),
                          Text(
                            getTranslated(context, "interest_offered") +
                                ' - ' +
                                widget.borrow.interestPercent.toString() +
                                getTranslated(context, "percent_per_month"),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(height: 10),
                          Text(
                            getTranslated(context, "duration") +
                                ' - ' +
                                widget.borrow.duration,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ]),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.black),
                  SizedBox(height: 10),
                  Text(
                    widget.borrow.title,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, color: kPrimaryColor, size: 16),
                      SizedBox(width: 5),
                      Text(
                        widget.borrow.ownerName + ' - ',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 5),
                      Text(
                        widget.borrow.requestCreated,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  if ((widget.borrow.amount == widget.borrow.pledgedAmount) &&
                      (widget.borrow.requestStatus == 1))
                    acceptLoanButton(),
                  Text(
                    widget.borrow.description,
                    maxLines: 10,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 10),
                  if (widget.borrow.requestStatus == 2) getInstallments(),
                  if (widget.borrow.requestStatus == 1) deleteLoanButton(),
                ],
              ),
              isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: Loading()))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInstallments() {
    return FutureBuilder(
        future: borrowDetails,
        builder: (BuildContext context, AsyncSnapshot<BorrowDetails> snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          if (snapshot.hasData)
            return Column(
              children: [
                Divider(color: Colors.black),
                IntrinsicHeight(
                  child: Row(children: [
                    Expanded(
                      flex: 49,
                      child: Column(children: [
                        SizedBox(height: 10),
                        Text(
                          snapshot.data.amountPaid.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kPrimaryColor),
                        ),
                        SizedBox(height: 5),
                        Text(
                          getTranslated(context, "paid"),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 10),
                      ]),
                    ),
                    Expanded(
                      child: VerticalDivider(
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      flex: 49,
                      child: Column(children: [
                        SizedBox(height: 10),
                        Text(
                          snapshot.data.amountPendingWithInterest.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kPrimaryColor),
                        ),
                        SizedBox(height: 5),
                        Text(
                          getTranslated(context, "remaining"),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 10),
                      ]),
                    ),
                  ]),
                ),
                Divider(color: Colors.black),
                SizedBox(height: 10),
                Text(
                  getTranslated(context, "lend_info"),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.black),
                SizedBox(height: 10),
                ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                          color: Colors.black,
                        ),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.installments.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(children: [
                        Expanded(
                          flex: 33,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: Text(
                              snapshot.data.installments[index].transferDate,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 57,
                          child: Row(
                            children: [
                              Text(
                                snapshot
                                    .data.installments[index].amountTransfered
                                    .toString(),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              if (snapshot.data.installments[index]
                                          .transactionStatus ==
                                      1 &&
                                  snapshot.data.installments[index]
                                          .transferType ==
                                      'early_pay')
                                Text(
                                  '(' +
                                      getTranslated(context, "manual_payment") +
                                      ')',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                  ),
                                ),
                              if (snapshot.data.installments[index]
                                      .transactionStatus ==
                                  0)
                                Text(
                                  '(' +
                                      getTranslated(
                                          context, "please_top_up_wallet") +
                                      ')',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kPrimaryColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: getInstallmentStatus(snapshot
                              .data.installments[index].transactionStatus),
                        ),
                      ]);
                    }),
                if (((snapshot.data.amountPending != 0) ||
                        (snapshot.data.amountPendingWithInterest != 0)) &&
                    (widget.borrow.requestStatus == 2))
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _EarlyPayDialog(
                                  walletId: widget.borrow.walletId,
                                  walletName: widget.borrow.walletName,
                                  requestId: widget.borrow.id,
                                  onSuccess: (value) {
                                    final snackBar = SnackBar(
                                        content: Text(getTranslated(context,
                                                "you_have_successfully_paid_an_amount_of") +
                                            value),
                                        duration: const Duration(seconds: 3));
                                    globalKey.currentState
                                        .showSnackBar(snackBar);

                                    borrowDetails = borrowDetailsLoad();
                                  },
                                  onFailure: (value) {
                                    final snackBar = SnackBar(
                                        content: Text(value),
                                        duration: const Duration(seconds: 3));
                                    globalKey.currentState
                                        .showSnackBar(snackBar);
                                  });
                            });
                      },
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      color: kPrimaryColor,
                      child: Text(getTranslated(context, "make_manual_payment"),
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            );
          else
            return Container();
        });
  }

  Widget getInstallmentStatus(transactionStatus) {
    print(transactionStatus.toString());
    if (transactionStatus == 1)
      return Icon(Icons.check, color: Colors.green[500], size: 16);
    else if (transactionStatus == 0)
      return Icon(Icons.close, color: kPrimaryColor, size: 16);
    else
      return Container();
  }

  deleteLoanHandler() async {
    print("deleteLoanHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lend_request_id'] = widget.borrow.id;

    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/DeleteLoanRequest', apiBodyObj);

    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });

//      final snackBar = SnackBar(
//          content: Text('Successfully deleted the Lend Request.'),
//          duration: const Duration(seconds: 3));
//      globalKey.currentState.showSnackBar(snackBar);
      Navigator.of(context).pop({'deleteStatus': 'success'});
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "invalid_lend_request_id") {
        err = getTranslated(context, "invalid_lend_request_id");
      } else if (response['error'] == "lend_request_id_is_required") {
        err = getTranslated(context, "lend_request_id_required");
      } else if (response['error'] == "only_the_owner_can_delete_the_request") {
        err = getTranslated(context, "only_the_owner_can_delete_the_request");
      } else if (response['error'] == "the_request_is_already_expired") {
        err = getTranslated(context, "lend_request_already_expired");
      } else if (response['error'] ==
          "the_accepted_loan_request_cannot_delete") {
        err = getTranslated(context, "no_lenders_found");
      } else if (response['error'] == "failed_to_delete_loan_request") {
        err = getTranslated(context, "failed_to_delete_loan_request");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else
        err = getTranslated(context, "failed_to_delete_loan_request");
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  acceptLoanHandler() async {
    print("acceptLoanHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['request_id'] = widget.borrow.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'PeerToPeer/AcceptPledgedRequests', apiBodyObj);

    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });

      final snackBar = SnackBar(
          content:
              Text(getTranslated(context, "successfully_accepted_the_loan")),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
      widget.borrow.requestStatus = 2;
      borrowDetails = borrowDetailsLoad();
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "request_id_is_not_exist") {
        err = getTranslated(context, "request_id_not_exist");
      } else if (response['error'] == "request_id_is_required") {
        err = getTranslated(context, "request_id_required");
      } else if (response['error'] ==
          "only_owner_of_the_request_can_only_accept_pledge_request") {
        err = getTranslated(
            context, "only_the_owner_can_accept_a_pledge_request");
      } else if (response['error'] == "target_is_not_achieved") {
        err = getTranslated(context, "target_is_not_achieved");
      } else if (response['error'] == "pledge_request_is_already_accepted") {
        err = getTranslated(context, "pledge_request_already_accepted");
      } else if (response['error'] == "company_not_accepted_your_loan") {
        err = "Company not accepted your loan.";
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "failed_to_accept_pledge_request") {
        err = getTranslated(context, "failed_to_accept_pledge_request");
      } else
        err = getTranslated(context, "failed_to_accept_pledge_request");
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  Widget acceptLoanButton() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: RaisedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _AcceptLoanDialog(
                    onSuccess: (value) {
                      acceptLoanHandler();
                    },
                  );
                });
          },
          textColor: Colors.white,
          padding: EdgeInsets.all(10.0),
          color: Colors.green[700],
          child: Text(getTranslated(context, "accept_loan_upper"),
              style: TextStyle(fontSize: 16)),
        ),
      ),
      SizedBox(height: 30),
    ]);
  }

  Widget deleteLoanButton() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: kPrimaryColor,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _DeleteLoanDialog(
                    onDSuccess: (value) {
                      deleteLoanHandler();
                    },
                  );
                });
          },
          textColor: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: Text(getTranslated(context, "delete_lend_request_upper"),
              style: TextStyle(fontSize: 16)),
        ),
      ),
      SizedBox(height: 30),
    ]);
  }
}

class _AcceptLoanDialog extends StatefulWidget {
  _AcceptLoanDialog({this.onSuccess});

  ValueChanged<String> onSuccess;

  @override
  _AcceptLoanDialogState createState() => _AcceptLoanDialogState();
}

class _AcceptLoanDialogState extends State<_AcceptLoanDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text(getTranslated(context, "no")),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(getTranslated(context, "yes")),
      onPressed: () {
        //cancelPledgeHandler();
        widget.onSuccess('success');
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    return AlertDialog(
      title: Text(getTranslated(context, "accept_loan")),
      content:
          Text(getTranslated(context, "would_you_like_to_accept_the_loan")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}

class _DeleteLoanDialog extends StatefulWidget {
  _DeleteLoanDialog({this.onDSuccess});

  ValueChanged<String> onDSuccess;

  @override
  _DeleteLoanDialogState createState() => _DeleteLoanDialogState();
}

class _DeleteLoanDialogState extends State<_DeleteLoanDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text(getTranslated(context, "no")),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(getTranslated(context, "yes")),
      onPressed: () {
        //cancelPledgeHandler();
        widget.onDSuccess('success');
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    return AlertDialog(
      title: Text(getTranslated(context, "delete_lend_request")),
      content: Text(
          getTranslated(context, "would_you_like_to_delete_your_lend_request")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}

class _EarlyPayDialog extends StatefulWidget {
  _EarlyPayDialog(
      {this.walletId,
      this.walletName,
      this.requestId,
      this.onSuccess,
      this.onFailure});
  int walletId;
  String walletName;
  String requestId;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  @override
  __EarlyPayDialogState createState() => __EarlyPayDialogState();
}

class __EarlyPayDialogState extends State<_EarlyPayDialog> {
  int walletId = 0;
  String walletName;
  String requestId;

  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    walletId = widget.walletId;
    walletName = widget.walletName;
    requestId = widget.requestId;
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        getTranslated(context, "manual_payment_upper"),
        style: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: kPrimaryColor),
      ),
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            right: -40.0,
            top: -80.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: kPrimaryColor,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      widget.walletName,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: false),
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enter_amount"),
                          labelText: getTranslated(context, "amount"),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(
                                context, "please_enter_amount");
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text(getTranslated(context, "make_manual_payment")),
                    color: kPrimaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        earlyPayHandler(amountController.text);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Loading()),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  earlyPayHandler(String amount) async {
    print("earlyPayHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['pay_amount'] = amountController.text.toString();
    apiBodyObj['lend_request_id'] = widget.requestId;
    apiBodyObj['wallet_id'] = widget.walletId.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/EarlyPayRequest', apiBodyObj);

    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess(
          amountController.text.toString() + " " + widget.walletName + ".");
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      if (response['error'] == "request_id_not_exist") {
        widget.onFailure(getTranslated(context, "request_id_not_exist"));
      } else if (response['error'] == "lend_request_id_is_required") {
        widget.onFailure(getTranslated(context, "lend_request_id_is_required"));
      } else if (response['error'] == "wallet_id_is_required") {
        widget.onFailure(getTranslated(context, "please_select_a_wallet"));
      } else if (response['error'] == "pay_amount_is_required") {
        widget.onFailure(getTranslated(context, "pay_amount_is_required"));
      } else if (response['error'] ==
          "invalid_lend_request_id_or_already_completed") {
        widget.onFailure(getTranslated(
            context, "invalid_lend_request_id_or_already_completed"));
      } else if (response['error'] ==
          "pay_amount_should_be_greather_than_interest_of_total_pending_amount") {
        widget.onFailure(getTranslated(context,
            "pay_amount_should_be_greater_than_interest_of_total_pending_amount"));
      } else if (response['error'] ==
          "insuffcient_balance_to_pay_this_amount") {
        widget.onFailure(
            getTranslated(context, "insufficient_balance_to_pay_this_amount"));
      } else if (response['error'] ==
          "insuffcient_balance_for_early_pay_request") {
        widget.onFailure(
            getTranslated(context, "insufficient_balance_for_manual_payment"));
      } else if (response['error'] == "failed_to_complete_early_pay_request") {
        widget.onFailure(getTranslated(
            context, "failed_to_complete_manual_payment_request"));
      } else if (response['error'] == "request_not_completed") {
        widget.onFailure(getTranslated(context, "request_not_completed"));
      } else if (response['error'] == "user_can_pay_maximum_amount_only") {
        widget.onFailure(
            getTranslated(context, "user_can_pay_maximum_amount_of") +
                " " +
                response['amount'].toString() +
                " " +
                widget.walletName +
                ".");
      } else
        widget.onFailure(response['error']);
    }
  }
}
