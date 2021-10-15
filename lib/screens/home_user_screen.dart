import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/apps/chat/screens/ConversationScreen.dart';
import 'package:tagcash/apps/user_merchant/components/rating_panel.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/public_area.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/models/user_site_data.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({Key key}) : super(key: key);

  @override
  _HomeUserScreenState createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  bool isLoading = false;
  bool isLoadingInitial = false;
  String userRating;

  bool addPossible = false;
  bool removePossible = false;

  TextEditingController _amountController;
  TextEditingController _notesController;

  int activeWalletId = 1;
  String activeCurrencyCode = 'PHP';

  UserSiteData userData;
  Map userDetail;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    loadUserProfile();

    // defaultWalletLoad();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void loadUserProfile() async {
    setState(() {
      isLoadingInitial = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['user_name'] = AppConstants.siteOwner;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoadingInitial = false;
      });
      List responseList = response['result'];

      userData = UserSiteData.fromJson(responseList[0]);

      userDetail = responseList[0];
      var ratingDta = userDetail['rating'].round();
      userRating = ratingDta.toString();

      if (userDetail['contact_status'].toString() == '1') {
        removePossible = true;
      } else {
        addPossible = true;
      }
    } else {
      showInvalidUserError();
    }
  }

  void showInvalidUserError() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, 'invalid_username')),
            content: Text(getTranslated(context, 'invalid_username_message')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppConstants.siteOwner = '';
                  AppConstants.appHomeMode = 'normal';

                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (Route<dynamic> route) => false);
                },
                child: Text(getTranslated(context, 'ok')),
              )
            ],
          );
        });
  }

  void defaultWalletLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';

    Map<String, dynamic> response =
        await NetworkHelper.request('user/DefaultWallet', apiBodyObj);

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (responseMap.containsKey('wallet_id')) {
        activeWalletId = int.parse(responseMap['wallet_id']);
        activeCurrencyCode = responseMap['currency_code'];
      }
    }
  }

  void payClickHandler() {
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
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: enableAutoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_balance_wallet),
                          labelText: getTranslated(context, 'amount'),
                          hintText: getTranslated(context, 'enter_amount'),
                        ),
                        validator: (value) {
                          if (!Validator.isAmount(value)) {
                            return getTranslated(context, 'enter_valid_amount');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        minLines: 3,
                        maxLines: 5,
                        controller: _notesController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.note),
                          labelText: getTranslated(context, 'notes'),
                          hintText: getTranslated(context, 'invalid_username'),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            enableAutoValidate = true;
                          });
                          if (_formKey.currentState.validate()) {
                            transferClickHandler();
                          }
                        },
                        child: Text(getTranslated(context, 'pay')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  transferClickHandler() async {
    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Receipt receiptData = Receipt(
      type: 'send_tagcash',
      direction: 'out',
      walletId: activeWalletId,
      amount: amountValue,
      currencyCode: activeCurrencyCode,
      narration: _notesController.text,
      name: userData.name,
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['from_wallet_id'] = activeWalletId.toString();
    apiBodyObj['to_wallet_id'] = activeWalletId.toString();
    apiBodyObj['narration'] = _notesController.text;

    apiBodyObj['to_type'] = 'user';
    apiBodyObj['to_id'] = userData.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/transfer', apiBodyObj);

    setState(() {
      isLoading = false;
      transferClickPossible = true;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      // if (Provider.of<PerspectiveProvider>(context, listen: false)
      //       .getActivePerspective() ==
      //   'user') {
      receiptData.transactionId = responseMap['transaction_id'];
      receiptData.date = responseMap['transfer_date'];
      receiptData.scratchcardGameId =
          responseMap['scratchcard_game_id'].toString();
      receiptData.winCombinationId =
          responseMap['win_combination_id'].toString();

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            receipt: receiptData,
          ),
        ),
      );

      // } else {
      //   showSimpleDialog(context, title: 'PAY', message: '${_amountController.text} $activeCurrencyCode Credited to user');
      // }

      _amountController.text = '';
      _notesController.text = '';
    } else {
      TransferError.errorHandle(context, response['error']);
    }
  }

  void requestSendClickHandler() {
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
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: enableAutoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_balance_wallet),
                          labelText: getTranslated(context, 'amount'),
                          hintText: getTranslated(context, 'enter_amount'),
                        ),
                        validator: (value) {
                          if (!Validator.isAmount(value)) {
                            return getTranslated(context, 'enter_valid_amount');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        minLines: 3,
                        maxLines: 5,
                        controller: _notesController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.note),
                          labelText: getTranslated(context, 'notes'),
                          hintText: getTranslated(context, "transaction_notes"),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            enableAutoValidate = true;
                          });
                          if (_formKey.currentState.validate()) {
                            requestsCreateHandler();
                          }
                        },
                        child: Text(getTranslated(context, 'request_send')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  requestsCreateHandler() async {
    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['wallet'] = activeWalletId.toString();
    apiBodyObj['remarks'] = _notesController.text;

    apiBodyObj['to_type'] = 'user';
    apiBodyObj['to_user'] = userData.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Credit/Requestfunds', apiBodyObj);

    setState(() {
      isLoading = false;
      transferClickPossible = true;
    });

    if (response['status'] == 'success') {
      Navigator.pop(context);
      showSnackBar(getTranslated(context, 'request_success_msg'));

      _amountController.text = '';
      _notesController.text = '';
    } else {
      if (response['error'] == 'invalid_user_can_not_lend_from_yourself') {
        showSimpleDialog(context,
            title: getTranslated(context, 'request_failed'),
            message: getTranslated(context, 'request_faild_msg'));
      } else if (response['error'] == 'invalid_user') {
        showSnackBar(getTranslated(context, 'not_valid_user'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  void addClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['userid'] = userData.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('contact/add', apiBodyObj);

    isLoading = false;
    if (response['status'] == 'success') {
      addPossible = false;
      removePossible = true;

      showSnackBar(getTranslated(context, 'friend_request_sent'));
    } else {
      if (response['error'] == 'contact_already_exists') {
        showSnackBar(getTranslated(context, 'already_friends_list'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
    setState(() {});
  }

  void removeClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('contact/delete/' + userData.id.toString());

    isLoading = false;
    if (response['status'] == 'success') {
      addPossible = true;
      removePossible = false;

      showSnackBar(getTranslated(context, 'successfully_removed'));
    } else {
      showSnackBar(getTranslated(context, 'error_occurred'));
    }
    setState(() {});
  }

  ratingChangeClickHandler() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return RatingPanel(
            id: userData.id.toString(),
            type: 'user',
            onRatingChanges: (String rating) {
              setState(() {
                userRating = rating;
              });
            },
          );
        });
  }

  chatClickHandler() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConversationScreen(source: 'tagcash', data: userDetail),
      ),
    );
  }

  userInfoClickHandler() {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(getTranslated(context, 'user_id')),
                    subtitle: Text(userDetail['id'].toString()),
                  ),
                  ListTile(
                    title: Text(getTranslated(context, 'username')),
                    subtitle: Text(userDetail['user_name']),
                  ),
                  ListTile(
                    title: Text(getTranslated(context, 'display_name')),
                    subtitle: Text(userDetail['user_nickname']),
                  ),
                  ListTile(
                    title: Text(getTranslated(context, 'country')),
                    subtitle: Text(userDetail['country']),
                  ),
                ],
              ),
            ),
          );
        });
  }

  String ratingValueText(String rating) {
    return double.parse(rating).round().toString();
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
      ),
      body: isLoadingInitial
          ? Center(child: Loading())
          : Stack(
              children: [
                ListView(
                  padding: EdgeInsets.all(kDefaultPadding),
                  children: [
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            width: 2.0,
                            color: Colors.white,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5.0,
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(
                              AppConstants.getUserImagePath() +
                                  userData.id.toString() +
                                  "?kycImage=0",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        userData.name.toUpperCase(),
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: chatClickHandler,
                          icon: FaIcon(FontAwesomeIcons.comment),
                          color: Colors.grey,
                        ),
                        IconButton(
                          onPressed:
                              transferClickPossible ? payClickHandler : null,
                          icon: FaIcon(FontAwesomeIcons.moneyBillWave),
                          color: Colors.grey,
                        ),
                        IconButton(
                          onPressed: userInfoClickHandler,
                          icon: FaIcon(FontAwesomeIcons.infoCircle),
                          color: Colors.grey,
                        ),
                        IconButton(
                          onPressed: ratingChangeClickHandler,
                          icon: Stack(
                            children: [
                              FaIcon(FontAwesomeIcons.circle),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    ratingValueText(userRating),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          color: Colors.grey,
                        ),
                        if (addPossible)
                          IconButton(
                            onPressed: addClickHandler,
                            icon: FaIcon(FontAwesomeIcons.userPlus),
                            color: Colors.grey,
                          ),
                        if (removePossible)
                          IconButton(
                            onPressed: removeClickHandler,
                            icon: FaIcon(FontAwesomeIcons.userMinus),
                            color: Colors.grey,
                          ),
                      ],
                    ),

                    // ElevatedButton(
                    //   onPressed: transferClickPossible ? requestSendClickHandler : null,
                    //   child: Text('SEND A REQUEST TO PAY'),
                    // ),
                    SizedBox(height: 20),
                    PublicArea(
                      userName: AppConstants.siteOwner,
                      perspective: 'user',
                      centerLayout: true,
                    ),
                  ],
                ),
                isLoading ? Center(child: Loading()) : SizedBox(),
              ],
            ),
    );
  }
}
