import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/apps/charity/models/charity_request.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tagcash/localization/language_constants.dart';

class RequestDetailScreen extends StatefulWidget {
  final CharityRequest charityRequest;

  const RequestDetailScreen({Key key, this.charityRequest}) : super(key: key);

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  //Future<List<LendTransaction>> transactionsListData;

  bool _isChecked = false;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    //transactionsListData = transactionsListLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "charity"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
//                  Divider(color: Colors.black),
                  SizedBox(height: 10),
                  Text(
                    widget.charityRequest.title,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 5),
                      Text(
                        getTranslated(context, "posted_on") +
                            ' ' +
                            widget.charityRequest.createdDate,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    getTranslated(context, "donated") +
                        ': ' +
                        widget.charityRequest.totalDonated.toString(),
                    maxLines: 2,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  //_getRating(widget.lendRequest.rating),
                  SizedBox(height: 15),
                  GetRating(
                      rating: widget.charityRequest.rating,
                      id: widget.charityRequest.id,
                      onRateSuccess: (value) {
//                        final snackBar = SnackBar(
//                            content: Text('Rating updated successfully'),
//                            duration: const Duration(seconds: 3));
//                        globalKey.currentState.showSnackBar(snackBar);
                        Navigator.of(context).pop({'rateStatus': 'success'});
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
                      itemCount: widget.charityRequest.uploadedFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return FileRowItem(
                            widget.charityRequest.uploadedFiles[index]);
                      }),
                  SizedBox(height: 30),
                  if (Provider.of<UserProvider>(context).userData.id ==
                      widget.charityRequest.ownerId)
                    //deleteCharityButton()
                    (widget.charityRequest.disableStatus == 0)
                        ? disableCharityButton()
                        : Container()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _DonateDialog(
                                    setAnonymousSelected: _isChecked,
                                    requestId: widget.charityRequest.id,
                                    onSelectedAnonymousChanged: (checked) {
                                      _isChecked = checked;
                                    },
                                    onSuccess: (value) {
                                      Navigator.of(context).pop({
                                        'donateStatus': 'success',
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
                        child: Text(getTranslated(context, "donate"),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  SizedBox(height: 30),
                  Text(
                    widget.charityRequest.description,
                    maxLines: 10,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.black),
                  SizedBox(height: 10),
                  _getHistory(widget.charityRequest.donationHistory),
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

  Widget _getHistory(List<DonationHistory> donationHistory) {
    return ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        separatorBuilder: (context, index) => Divider(
              color: Colors.black,
            ),
        itemCount: donationHistory.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(children: [
            Expanded(
              flex: 75,
              child: Text(donationHistory[index].userName +
                  ' - ' +
                  donationHistory[index].createdDate),
            ),
            Expanded(
              flex: 25,
              child: Text(donationHistory[index].amount),
            ),
          ]);
        });
  }

  Widget disableCharityButton() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: kPrimaryColor,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _DisableCharityDialog(
                    onDSuccess: (value) {
                      disableCharityHandler();
                    },
                  );
                });
          },
          textColor: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: Text(getTranslated(context, "disable"),
              style: TextStyle(fontSize: 16)),
        ),
      ),
      SizedBox(height: 30),
    ]);
  }

  Widget deleteCharityButton() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: RaisedButton(
          color: kPrimaryColor,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _DeleteCharityDialog(
                    onDSuccess: (value) {
                      deleteCharityHandler();
                    },
                  );
                });
          },
          textColor: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: Text(getTranslated(context, "delete"),
              style: TextStyle(fontSize: 16)),
        ),
      ),
      SizedBox(height: 30),
    ]);
  }

  deleteCharityHandler() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['charity_id'] = widget.charityRequest.id;

    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/DeleteCharity', apiBodyObj);

    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop({'deleteStatus': 'success'});
    } else {
      setState(() {
        isLoading = false;
      });
      String err;

      err = getTranslated(context, "failed_delete_charity_request");
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  disableCharityHandler() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['charity_id'] = widget.charityRequest.id;

    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/DisableCharity', apiBodyObj);

    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop({'disableStatus': 'success'});
    } else {
      setState(() {
        isLoading = false;
      });
      String err;

      err = getTranslated(context, "failed_disable_charity_request");
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}

class GetRating extends StatefulWidget {
  GetRating({this.rating, this.id, this.onRateSuccess, this.onRateFail});

  var rating;
  String id;
  ValueChanged<String> onRateSuccess;
  ValueChanged<String> onRateFail;

  @override
  GetRatingState createState() => GetRatingState();
}

class GetRatingState extends State<GetRating> {
  String textHolder = '';
  String id;
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

class _DonateDialog extends StatefulWidget {
  _DonateDialog(
      {this.setAnonymousSelected,
      this.requestId,
      this.onSelectedAnonymousChanged,
      this.onSuccess,
      this.onFailure});

  bool setAnonymousSelected = false;
  String requestId;
  ValueChanged<bool> onSelectedAnonymousChanged;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  @override
  _DonateDialogState createState() => _DonateDialogState();
}

class _DonateDialogState extends State<_DonateDialog> {
  bool _anonymousSelected = false;
  String requestId;
  Wallet wallet;
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    _anonymousSelected = widget.setAnonymousSelected;
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
        getTranslated(context, "donate"),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    WalletListingHeader(
                      onWalletSelected: (wallet) {
                        this.wallet = wallet;
                      },
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
                  contentPadding: EdgeInsets.all(0),
                  //checkColor: Colors.red[600],
                  activeColor: kPrimaryColor,
                  value: _anonymousSelected,
                  title: Text(getTranslated(context, "anonymous_donation")),
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
                    child: Text(getTranslated(context, "donate")),
                    color: kPrimaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        if (wallet == null) {
//                            final snackBar = SnackBar(
//                                content: Text(
//                                    "Failed to donate the amount"),
//                                duration: const Duration(seconds: 3));
//                            globalKey.currentState
//                                .showSnackBar(snackBar);
                          widget.onFailure(
                              getTranslated(context, "please_select_a_wallet"));
                        } else
                          donateHandler(
                              amountController.text,
                              _anonymousSelected,
                              wallet.walletId,
                              wallet.currencyCode);
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

  donateHandler(String amount, bool isAnonymousSeleted, int walletId,
      String walletName) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['amount'] = amountController.text.toString();
    apiBodyObj['charity_id'] = widget.requestId;
    apiBodyObj['wallet_id'] = walletId.toString();
    if (isAnonymousSeleted == true)
      apiBodyObj['anonymous_donation'] = "1";
    else
      apiBodyObj['anonymous_donation'] = "0";

    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/Donate', apiBodyObj);

    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess(amountController.text.toString() + " " + walletName);
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onFailure(getTranslated(context, "failed_donate_amount"));
    }
  }
}

class _RateUserDialog extends StatefulWidget {
  _RateUserDialog({this.rating, this.id, this.onRateSuccess, this.onRateFail});

  var rating;
  String id;
  ValueChanged<String> onRateSuccess;
  ValueChanged<String> onRateFail;

  @override
  _RateUserDialogState createState() => _RateUserDialogState();
}

class _RateUserDialogState extends State<_RateUserDialog> {
  String id;
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
            divisions: 20,
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

  rateHandler(var rating, String id) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['rating_value'] = rating.toString();
    apiBodyObj['charity_id'] = id;
    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/AddRatings', apiBodyObj);

    if (response['status'] == 'success') {
      var res = response['result']['avg_rating'];
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

class WalletListingHeader extends StatefulWidget {
  WalletListingHeader({this.onWalletSelected});

  ValueChanged<Wallet> onWalletSelected;

  @override
  _WalletListingHeaderState createState() => _WalletListingHeaderState();
}

class _WalletListingHeaderState extends State<WalletListingHeader> {
  Future<List<Wallet>> walletsListData;
  int walletCardIndex = 0;
  Wallet selectedWallet;

  @override
  void initState() {
    super.initState();
    walletsListData = allWalletListLoad();
  }

  Future<List<Wallet>> allWalletListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';
    //apiBodyObj['wallet_type'] = '[0,1,3]';

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/list', apiBodyObj);

    List responseList = response['result'];

    List<Wallet> getData = responseList.map<Wallet>((json) {
      return Wallet.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: walletsListData,
          builder:
              (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? DropdownButton<Wallet>(
                    hint: Text(getTranslated(context, "select_wallet")),
                    value: selectedWallet,
                    onChanged: (Wallet Value) {
                      setState(() {
                        selectedWallet = Value;
                        widget.onWalletSelected(selectedWallet);
                      });
                    },
                    items: snapshot.data.map((Wallet wallet) {
                      return DropdownMenuItem<Wallet>(
                        value: wallet,
                        child: Row(
                          children: <Widget>[
                            //user.icon,
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              wallet.currencyCode,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : Container();
          }),
    );
  }
}

class _DeleteCharityDialog extends StatefulWidget {
  _DeleteCharityDialog({this.onDSuccess});

  ValueChanged<String> onDSuccess;

  @override
  _DeleteCharityDialogState createState() => _DeleteCharityDialogState();
}

class _DeleteCharityDialogState extends State<_DeleteCharityDialog> {
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
      title: Text(getTranslated(context, "delete_charity_request")),
      content: Text(getTranslated(context, "would_delete_charity_request")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}

class _DisableCharityDialog extends StatefulWidget {
  _DisableCharityDialog({this.onDSuccess});

  ValueChanged<String> onDSuccess;

  @override
  _DisableCharityDialogState createState() => _DisableCharityDialogState();
}

class _DisableCharityDialogState extends State<_DisableCharityDialog> {
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
      title: Text(getTranslated(context, "disable_charity_request")),
      content: Text(getTranslated(context, "would_disable_charity_request")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
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
        padding: const EdgeInsets.all(10),
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
