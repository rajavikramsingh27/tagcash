import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/apps/lending/models/lend.dart';
import 'package:tagcash/apps/lending/models/lend_details.dart';
import 'package:tagcash/apps/lending/models/lend_user.dart';
import 'package:tagcash/services/networking.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tagcash/localization/language_constants.dart';

class LendDetailScreen extends StatefulWidget {
  final Lend lend;

  const LendDetailScreen({Key key, this.lend}) : super(key: key);

  @override
  _LendDetailScreenState createState() => _LendDetailScreenState();
}

class _LendDetailScreenState extends State<LendDetailScreen> {
  bool _isChecked = false;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  var loanedAmount;
  double amountPending;
  double amountReceived;

  Future<LendDetails> lendDetails;

  @override
  void initState() {
    super.initState();
    lendDetails = lendDetailsLoad();
  }

  Future<List<LendUser>> lendersListLoad() async {
    print('lendersListLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lend_request_id'] = widget.lend.id;
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
        },
      );
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
                      if (widget.lend.lendersCount > 0)
                        lendersListLoad();
                      else {
                        final snackBar = SnackBar(
                            content: Text(
                              getTranslated(context, "no_lenders_found"),
                            ),
                            duration: const Duration(seconds: 3));
                        globalKey.currentState.showSnackBar(snackBar);
                      }
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lend.walletName +
                                ' ' +
                                widget.lend.amount.toString(),
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
                                widget.lend.walletName +
                                ' ' +
                                widget.lend.pledgedAmount.toString() +
                                ' ' +
                                getTranslated(context, "from") +
                                ' ' +
                                widget.lend.lendersCount.toString() +
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
                                widget.lend.interestPercent.toString() +
                                getTranslated(context, "percent_per_month"),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(height: 10),
                          Text(
                            getTranslated(context, "duration") +
                                ' - ' +
                                widget.lend.duration,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ]),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.black),
                  SizedBox(height: 10),
                  Text(
                    widget.lend.title,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, color: kPrimaryColor, size: 16),
                      SizedBox(width: 5),
                      Text(
                        widget.lend.ownerName + ' - ',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 5),
                      Text(
                        widget.lend.requestCreated,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  //_getRating(widget.lend.rating),
                  GetRating(
                      rating: widget.lend.rating,
                      id: widget.lend.ownerId,
                      onRateSuccess: (value) {
                        final snackBar = SnackBar(
                            content: Text(getTranslated(
                                context, "rating_update_success")),
                            duration: const Duration(seconds: 3));
                        globalKey.currentState.showSnackBar(snackBar);
                      },
                      onRateFail: (value) {
                        final snackBar = SnackBar(
                            content: Text(getTranslated(
                                context, "failed_to_update_rating")),
                            duration: const Duration(seconds: 3));
                        globalKey.currentState.showSnackBar(snackBar);
                      }),
                  SizedBox(height: 10),
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      //padding: const EdgeInsets.all(8),
                      itemCount: widget.lend.uploadedFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return FileRowItem(widget.lend.uploadedFiles[index]);
                      }),
                  SizedBox(height: 30),
                  if (widget.lend.amount > widget.lend.pledgedAmount)
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _PledgeDialog(
                                    setAnonymousSelected: _isChecked,
                                    walletId: widget.lend.walletId,
                                    walletName: widget.lend.walletName,
                                    requestId: widget.lend.id,
                                    onSelectedAnonymousChanged: (checked) {
                                      _isChecked = checked;
                                      print(_isChecked.toString());
                                    },
                                    onSuccess: (value) {
//                                      final snackBar = SnackBar(
//                                          content: Text(
//                                              'You have successfully pledged an Amount of ' +
//                                                  value),
//                                          duration: const Duration(seconds: 3));
//                                      globalKey.currentState
//                                          .showSnackBar(snackBar);
                                      Navigator.of(context).pop({
                                        'pledgeStatus': 'success',
                                        'value': value
                                      });
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
                        child: Text(getTranslated(context, "pledge_to_lend"),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  if (widget.lend.requestStatus == 1) cancelPledgeButton(),
                  getInstallments(),
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

  Future<LendDetails> lendDetailsLoad() async {
    print('lendDetailsLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lend_request_id'] = widget.lend.id;
    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/GetRequestDetails', apiBodyObj);

    Map responseLoanStatus = response['result'];
    setState(() {
      isLoading = false;
    });
    LendDetails getData = LendDetails.fromJson(responseLoanStatus);
    return getData;
  }

  Widget cancelPledgeButton() {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return _CancelPledgeDialog(
                  onCSuccess: (value) {
                    cancelPledgeHandler();
                  },
                );
              });
        },
        textColor: Colors.white,
        padding: EdgeInsets.all(10.0),
        color: kPrimaryColor,
        child: Text(getTranslated(context, "cancel_pledge_upper"),
            style: TextStyle(fontSize: 16)),
      ),
    );
  }

  cancelPledgeHandler() async {
    print("cancelPledgeHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lend_request_id'] = widget.lend.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'PeerToPeer/DeletePledgeRequests', apiBodyObj);

    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop({'cancelPledgeStatus': 'success'});
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "lend_request_is_already_approved") {
        err = getTranslated(context, "lend_request_is_already_approved");
      } else if (response['error'] == "lend_request_id_is_required") {
        err = getTranslated(context, "lend_request_id_is_required");
      } else if (response['error'] == "invalid_lend_request_id") {
        err = getTranslated(context, "invalid_lend_request_id");
      } else if (response['error'] == "expired_lend_request_id") {
        err = getTranslated(context, "lend_request_already_expired");
      } else if (response['error'] ==
          "pledge_request_is_already_deleted_or_not_requested") {
        err = getTranslated(
            context, "pledge_request_is_already_deleted_or_not_requested");
      } else if (response['error'] == "failed_to_delete_pledge_request") {
        err = getTranslated(context, "failed_to_delete_pledge_request");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else
        err = getTranslated(context, "failed_to_delete_pledge_request");

      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  Widget getInstallments() {
    return FutureBuilder(
        future: lendDetails,
        builder: (BuildContext context, AsyncSnapshot<LendDetails> snapshot) {
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
                          snapshot.data.loanedAmount.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kPrimaryColor),
                        ),
                        SizedBox(height: 5),
                        Text(
                          getTranslated(context, "loaned"),
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
                          snapshot.data.amountReceived.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kPrimaryColor),
                        ),
                        SizedBox(height: 5),
                        Text(
                          getTranslated(context, "received"),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 10),
                      ]),
                    ),
                  ]),
                ),
                Divider(color: Colors.black),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      widget.lend.description,
                      maxLines: 10,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
                SizedBox(height: 10),
//                Divider(color: Colors.black),
//                SizedBox(height: 10),
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
                              if (snapshot
                                      .data.installments[index].transferType ==
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
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: getInstallmentStatus(snapshot
                              .data.installments[index].transactionStatus),
                        ),
                      ]);
                    })
              ],
            );
          else
            return Container();
        });
  }

  Widget _getRating(var rating) {
    if (rating > 0)
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.23),
          borderRadius: BorderRadius.circular(5),
        ),
        //child: Center(
        child: Text(getTranslated(context, "rating") + ' ' + rating.toString(),
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.green[700])),
      );
    else if (rating < 0)
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.23),
          borderRadius: BorderRadius.circular(5),
        ),
        //child: Center(
        child: Text(getTranslated(context, "rating") + ' ' + rating.toString(),
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor)),
      );
    else if (rating == 0)
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.23),
          borderRadius: BorderRadius.circular(5),
        ),
        //child: Center(
        child: Text(getTranslated(context, "rating") + ' ' + rating.toString(),
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      );
  }
}

Widget getInstallmentStatus(transactionStatus) {
  if (transactionStatus == 1)
    return Icon(Icons.check, color: Colors.green[500], size: 16);
  else if (transactionStatus == 0)
    return Icon(Icons.close, color: kPrimaryColor, size: 16);
  else
    return Container();
}

class _PledgeDialog extends StatefulWidget {
  _PledgeDialog(
      {this.setAnonymousSelected,
      this.walletId,
      this.walletName,
      this.requestId,
      this.onSelectedAnonymousChanged,
      this.onSuccess,
      this.onFailure});

  bool setAnonymousSelected = false;
  int walletId;
  String walletName;
  String requestId;
  ValueChanged<bool> onSelectedAnonymousChanged;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  @override
  _PledgeDialogState createState() => _PledgeDialogState();
}

class _PledgeDialogState extends State<_PledgeDialog> {
  bool _anonymousSelected = false;
  int walletId = 0;
  String walletName;
  String requestId;

  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    _anonymousSelected = widget.setAnonymousSelected;
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
        getTranslated(context, "pledge"),
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
                CheckboxListTile(
                  //checkColor: Colors.red[600],
                  activeColor: kPrimaryColor,
                  value: _anonymousSelected,
                  title: Text(getTranslated(context, "anonymous_pledge")),
                  onChanged: (bool value) {
                    setState(() {
                      _anonymousSelected = value;
                      widget.onSelectedAnonymousChanged(_anonymousSelected);
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text(getTranslated(context, "pledge_to_lend")),
                    color: kPrimaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        pledgeHandler(
                            amountController.text, _anonymousSelected);
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

  pledge() {}

  pledgeHandler(String amount, bool isAnonymousSeleted) async {
    print("pledgeHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['pledge_amount'] = amountController.text.toString();
    apiBodyObj['lend_request_id'] = widget.requestId;
    apiBodyObj['wallet_id'] = widget.walletId.toString();
    if (isAnonymousSeleted == true)
      apiBodyObj['anonymous_status'] = "1";
    else
      apiBodyObj['anonymous_status'] = "0";

    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/PledgeRequest', apiBodyObj);

    if (response['status'] == 'success') {
      String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess(
          amountController.text.toString() + " " + widget.walletName);
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      if (response['error'] == "pledge_amount_is_required") {
        widget.onFailure("Pledge amount is required.");
      } else if (response['error'] == "lend_request_id_is_required") {
        widget.onFailure("Lend request ID is required.");
      } else if (response['error'] == "invalid_lend_request_id") {
        widget.onFailure("Invalid Lend Request ID.");
      } else if (response['error'] ==
          "company_not_approved_the_salary_loan_request") {
        widget.onFailure("Company not approved the salary loan request.");
      } else if (response['error'] ==
          "the_company_id_cannot_pledge_the_request") {
        widget.onFailure("The Company cannot pledge the request.");
      } else if (response['error'] == "owner_of_the_request_cannot_pledge") {
        widget.onFailure("Owner of the request cannot Pledge.");
      } else if (response['error'] == "target_achieved_for_the_requester") {
        widget.onFailure("Target achieved for the Requester.");
      } else if (response['error'] == "insuffcient_balance") {
        widget.onFailure("Insufficient balance.");
      } else if (response['error'] == "wallet_id_is_required") {
        widget.onFailure("Please select a Wallet.");
      } else if (response['error'] == "logged_user_is_not_level_3_verified") {
        widget.onFailure("Logged In User is not Level 3 verified.");
      } else if (response['error'] == "merchant_is_not_verified") {
        widget.onFailure("Business is not verified.");
      } else if (response['error'] ==
          "pledged_amount_exceeded_incoming_transfer_level_limit") {
        widget.onFailure(
            "Pledged amount exceeded incoming transfer level limit.");
      } else if (response['error'] ==
          "pledge_amount_should_be_less_than_or_equal_to") {
        widget.onFailure("Pledge amount should be less than or equal to " +
            response['amount'].toString() +
            ".");
      } else if (response['error'] == "maximum_lenders_count_limit_reached") {
        widget.onFailure("Maximum lenders count limit reached.");
      } else
        widget.onFailure(response['error']);
    }
  }
}

class _CancelPledgeDialog extends StatefulWidget {
  _CancelPledgeDialog({this.onCSuccess});

  ValueChanged<String> onCSuccess;

  @override
  _CancelPledgeDialogState createState() => _CancelPledgeDialogState();
}

class _CancelPledgeDialogState extends State<_CancelPledgeDialog> {
  String requestId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    //amountController.dispose();
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
        widget.onCSuccess('success');
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    return AlertDialog(
      title: Text(getTranslated(context, "cancel_pledge")),
      content: Text(getTranslated(
          context, "would_you_like_to_cancel_your_existing_pledge")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}

class GetRating extends StatefulWidget {
  GetRating({this.rating, this.id, this.onRateSuccess, this.onRateFail});

  var rating;
  int id;
  ValueChanged<String> onRateSuccess;
  ValueChanged<String> onRateFail;

  @override
  GetRatingState createState() => GetRatingState();
}

class GetRatingState extends State<GetRating> {
  String textHolder = '';
  int id = 0;
  var rating;

  bool isLoading = false;

  @override
  void initState() {
    rating = widget.rating.toDouble();
    id = widget.id;
    textHolder = rating.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          print("Container clicked");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return _RateUserDialog(
                    rating: rating,
                    id: id,
                    onRateSuccess: (value) {
                      setState(() {
                        textHolder = value;
                      });
                      widget.onRateSuccess(value);
                    },
                    onRateFail: (value) {
                      widget.onRateFail('failed');
                    });
              });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.23),
            borderRadius: BorderRadius.circular(5),
          ),
          //child: Center(
          child: _getRatingColor('$textHolder'),
        ));
  }

  Widget _getRatingColor(var rating) {
    double rat = double.tryParse(rating);
    if (rat > 0)
      return Text(getTranslated(context, "rating") + ' ' + rating.toString(),
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.green[700]));
    else if (rat < 0)
      return Text(getTranslated(context, "rating") + ' ' + rating.toString(),
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: kPrimaryColor));
    else if (rat == 0)
      return Text(getTranslated(context, "rating") + ' ' + rating.toString(),
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]));
  }
}

class _RateUserDialog extends StatefulWidget {
  _RateUserDialog({this.rating, this.id, this.onRateSuccess, this.onRateFail});

  var rating;
  int id;
  ValueChanged<String> onRateSuccess;
  ValueChanged<String> onRateFail;

  @override
  _RateUserDialogState createState() => _RateUserDialogState();
}

class _RateUserDialogState extends State<_RateUserDialog> {
  int id = 0;
  var rating;

  bool isLoading = false;

  @override
  void initState() {
    rating = widget.rating;
    id = widget.id;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Slider(
            value: rating,
            min: -10,
            max: 10,
            divisions: 2000,
            activeColor: Colors.black,
            inactiveColor: Colors.grey[500],
            label: rating.toStringAsFixed(2),
            onChanged: (double value) {
              setState(() {
                rating = value;
              });
            },
          ),
          Row(
            children: [
              Expanded(
                child: RaisedButton(
                  child: Text(getTranslated(context, "cancel")),
                  color: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: RaisedButton(
                  child: Text(getTranslated(context, "rate")),
                  color: kPrimaryColor,
                  textColor: Colors.white,
                  onPressed: () {
                    rateHandler(rating, id);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  rateHandler(var rating, int id) async {
    print("rateHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['rating'] = rating.toString();
    apiBodyObj['to_id'] = id.toString();
    apiBodyObj['to_type'] = "user";
    Map<String, dynamic> response =
        await NetworkHelper.request('ratings/addratings', apiBodyObj);

    if (response['status'] == 'success') {
      var res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onRateSuccess(res.toString());
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onRateFail('failed');
    }
  }
}

class FileRowItem extends StatelessWidget {
  final UploadedFile file;

  FileRowItem(this.file);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: GestureDetector(
      onTap: () async {
        if (await canLaunch(file.fileUrl)) {
          await launch(file.fileUrl, forceSafariVC: false);
        } else {
          throw 'Could not launch ' + file.fileUrl;
        }
      },

      //margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Icon(Icons.file_present),
            Expanded(
              child: Text(
                file.fileName,
                style: TextStyle(fontSize: 15),
              ),
            ),
            Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    ));
  }
}
