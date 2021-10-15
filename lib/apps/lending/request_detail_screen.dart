import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/apps/lending/models/lend_request.dart';
import 'package:tagcash/apps/lending/models/lend_transaction.dart';
import 'package:tagcash/apps/lending/models/lend_user.dart';
import 'package:tagcash/services/networking.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tagcash/localization/language_constants.dart';

class RequestDetailScreen extends StatefulWidget {
  final LendRequest lendRequest;

  const RequestDetailScreen({Key key, this.lendRequest}) : super(key: key);

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  Future<List<LendTransaction>> transactionsListData;

  bool _isChecked = false;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    transactionsListData = transactionsListLoad();
  }

  Future<List<LendTransaction>> transactionsListLoad([String searchKey]) async {
    print('transactionsListLoad');

    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/GetThreeMonthIncomingLimit');

    List responseList = response['three_month_limit'];

    List<LendTransaction> getData = responseList.map<LendTransaction>((json) {
      return LendTransaction.fromJson(json);
    }).toList();

    return getData;
  }

  Widget _getTransactions() {
    return FutureBuilder(
      future: transactionsListData,
      builder: (BuildContext context,
          AsyncSnapshot<List<LendTransaction>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    //margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(children: [
                      Expanded(
                        flex: 45,
                        child: ListTile(
                          subtitle: Column(children: [
                            Text(snapshot.data[index].fromDateFormatted),
                            SizedBox(height: 5),
                            Text('|'),
                            SizedBox(height: 5),
                            Text(snapshot.data[index].toDateFormatted),
                          ]),
                        ),
                      ),
                      Expanded(
                        flex: 55,
                        child: ListTile(
                          subtitle: Column(children: [
                            Row(
                              children: [
                                Icon(Icons.arrow_upward_sharp,
                                    color: Colors.green[500], size: 20),
                                SizedBox(width: 5),
                                Text(
                                  snapshot.data[index].incomeAmount.toString() +
                                      '(' +
                                      snapshot.data[index].inTransactionCount
                                          .toString() +
                                      ')',
                                  style: TextStyle(
                                    color: Colors.green[500],
                                    fontSize: 14,
                                    //fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(children: [
                              Icon(Icons.arrow_downward_sharp,
                                  color: kPrimaryColor, size: 20),
                              SizedBox(height: 5),
                              Text(
                                snapshot.data[index].outAmount.toString() +
                                    '(' +
                                    snapshot.data[index].outTransactionCount
                                        .toString() +
                                    ')',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 14,
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                            ])
                          ]),
                        ),
                      ),
                    ]),
                  );
                })
            : Center(child: Loading());
      },
    );
  }

  Future<List<LendUser>> lendersListLoad() async {
    print('lendersListLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['lend_request_id'] = widget.lendRequest.id;
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
                      if (widget.lendRequest.lendersCount > 0)
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
                            widget.lendRequest.walletName +
                                ' ' +
                                widget.lendRequest.amount.toString(),
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
                                widget.lendRequest.walletName +
                                ' ' +
                                widget.lendRequest.pledgedAmount.toString() +
                                ' ' +
                                getTranslated(context, "from") +
                                ' ' +
                                widget.lendRequest.lendersCount.toString() +
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
                                widget.lendRequest.interestPercent.toString() +
                                getTranslated(context, "percent_per_month"),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(height: 10),
                          Text(
                            getTranslated(context, "duration") +
                                ' - ' +
                                widget.lendRequest.duration,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ]),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.black),
                  SizedBox(height: 10),
                  Text(
                    widget.lendRequest.title,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, color: kPrimaryColor, size: 16),
                      SizedBox(width: 5),
                      Text(
                        widget.lendRequest.ownerName + ' - ',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 5),
                      Text(
                        widget.lendRequest.requestCreated,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  //_getRating(widget.lendRequest.rating),
                  GetRating(
                      rating: widget.lendRequest.rating,
                      id: widget.lendRequest.ownerId,
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
                      itemCount: widget.lendRequest.uploadedFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return FileRowItem(
                            widget.lendRequest.uploadedFiles[index]);
                      }),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _PledgeDialog(
                                  setAnonymousSelected: _isChecked,
                                  walletId: widget.lendRequest.walletId,
                                  walletName: widget.lendRequest.walletName,
                                  requestId: widget.lendRequest.id,
                                  onSelectedAnonymousChanged: (checked) {
                                    _isChecked = checked;
                                    print(_isChecked.toString());
                                  },
                                  onSuccess: (value) {
//                                    final snackBar = SnackBar(
//                                        content: Text(
//                                            'You have successfully pledged an Amount of ' +
//                                                value),
//                                        duration: const Duration(seconds: 3));
//                                    globalKey.currentState
//                                        .showSnackBar(snackBar);
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
                  SizedBox(height: 30),
                  Text(
                    widget.lendRequest.description,
                    maxLines: 10,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.black),
                  SizedBox(height: 10),
                  Text(
                    getTranslated(context, "last_3_months_transaction_summary"),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  SizedBox(height: 10),
                  _getTransactions(),
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
