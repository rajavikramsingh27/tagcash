import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tagcash/apps/user_merchant/components/rating_panel.dart';
import 'package:tagcash/components/public_area.dart';
import 'package:tagcash/providers/layout_provider.dart';

import '../bloc/conversation_bloc.dart';
import '../../../components/app_top_bar.dart';
import '../../../components/dialog.dart';
import '../../../components/loading.dart';
import '../../../components/wallets_dropdown.dart';
import '../../../constants.dart';
import '../../../localization/language_constants.dart';
import '../../../models/app_constants.dart' as AppConstants;
import '../../../models/wallet.dart';
import '../../../providers/user_provider.dart';
import '../../../services/networking.dart';
import '../../../utils/validator.dart';

class Profile extends StatefulWidget {
  final ConversationBloc bloc;
  final String withUser;
  final String title;
  final bool isblock;
  final String source;
  final int me;

  Profile(
      {Key key,
      @required this.withUser,
      this.title,
      this.bloc,
      this.isblock = false,
      this.source,
      this.me});

  @override
  _ProfileState createState() => _ProfileState(
      this.withUser, this.title, this.bloc, this.isblock, this.source, this.me);
}

class _ProfileState extends State<Profile> {
  _ProfileState(
      this.withUser, this.title, this.bloc, this.isblock, this.source, this.me);
  String withUser;
  String title;
  String nlock;
  bool isblock;
  bool buttonPressed = false;
  ConversationBloc bloc;
  String source;
  int me;
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  bool isLoading = false;
  String userRating = '';

  bool addPossible = false;
  bool removePossible = false;

  TextEditingController _amountController;
  TextEditingController _notesController;

  int activeWalletId;
  String activeCurrencyCode = 'PHP';
  Map userData;
  String fromWalletId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    loadUserProfile(widget.withUser.toString());
    defaultWalletLoad();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void loadUserProfile(String useridCheck) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = useridCheck;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      List responseList = response['result'];
      Map userDetail = responseList[0];
      userData = responseList[0];

      var ratingDta = userDetail['rating'].round();
      userRating = ratingDta.toString();

      if (userDetail['contact_status'] == '1') {
        removePossible = true;
      } else {
        addPossible = true;
      }
    }
  }

  void getWallet(Wallet wallet) async {
    setState(() {
      this.fromWalletId = wallet.walletId.toString();
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

  void paymentSuccess() {
    setState(() {
      _notesController.text = '';
      _amountController.text = '';
    });
    var alertStyle = AlertStyle(
      animationType: AnimationType.grow,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(color: Colors.red, fontSize: 16),
    );
    Alert(
      context: context,
      style: alertStyle,
      title: "Payment successful",
      desc: "Transaction completed successfully.",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            setState(() {
              isLoading = false;
              transferClickPossible = true;
            });
            Navigator.pop(context);
          },
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  void paymentFailed() {
    setState(() {
      _notesController.text = '';
      _amountController.text = '';
    });
    var alertStyle = AlertStyle(
      // animationType: AnimationType.grow,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(color: Colors.red, fontSize: 16),
    );
    Alert(
      context: context,
      style: alertStyle,
      title: "Payment Unsuccessful",
      desc: "Transaction was declined.",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            setState(() {
              isLoading = false;
              transferClickPossible = true;
            });
            Navigator.pop(context);
          },
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: WalletsDropdown(
                          currencyCode:
                              ValueNotifier<String>(activeWalletId.toString()),
                          onSelected: (wallet) => getWallet(wallet),
                        ),
                      ),
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
                            // transferClickHandler();
                            Navigator.pop(context);
                            setState(() {
                              isLoading = true;
                              transferClickPossible = false;
                            });
                            this.bloc.paymentWithFromWallet(
                                fromWalletId,
                                _amountController.text,
                                this.withUser,
                                _notesController.text,
                                this.title,
                                this.me,
                                this.paymentFailed,
                                this.paymentSuccess);
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
    apiBodyObj['to_user'] = withUser;

    Map<String, dynamic> response =
        await NetworkHelper.request('Credit/Requestfunds', apiBodyObj);
    print('it si req');
    print(response['id']);

    setState(() {
      isLoading = false;
      transferClickPossible = true;
    });

    if (response['status'] == 'success') {
      //   String notesValues = _notesController.text;
      // notesValues = notesValues.replaceAll(',', '');

      var amount = jsonEncode("amount");
      var walletId = jsonEncode("walletId");
      var notes = jsonEncode("notes");
      var requestFromId = jsonEncode("requestFromId");

      var apiObj = {
        "to_tagcash_id": this.withUser,
        "from_tagcash_id": this.me,
        "toDocId": this.withUser,
        "convId": this.bloc.currentRoom,
        "type": 9,
        "payload": {
          amount: amountValue.toString(),
          walletId: activeWalletId.toString(),
          notes: jsonEncode(_notesController.text),
          requestFromId: response['id'],
        }.toString(),
      };
      this.bloc.sendMessage(apiObj);

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
      // isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['userid'] = widget.withUser.toString();

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
    setState(() {
      isLoading = false;
    });
  }

  void removeClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'contact/delete/' + widget.withUser.toString());

    isLoading = false;
    if (response['status'] == 'success') {
      addPossible = true;
      removePossible = false;

      showSnackBar(getTranslated(context, 'successfully_removed'));
    } else {
      showSnackBar(getTranslated(context, 'error_occurred'));
    }
    setState(() {
      isLoading = false;
    });
  }

  ratingChangeClickHandler() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return RatingPanel(
            id: widget.withUser.toString(),
            type: 'user',
            onRatingChanges: (String rating) {
              setState(() {
                userRating = rating;
              });
            },
          );
        });
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
                    subtitle: Text(userData['id'].toString()),
                  ),
                  if (userData['user_nickname'] != '')
                    ListTile(
                      title: Text(getTranslated(context, 'display_name')),
                      subtitle: Text(userData['user_nickname']),
                    ),
                  if (userData['user_name'] != '')
                    ListTile(
                      title: Text(getTranslated(context, 'username')),
                      subtitle: Text(userData['user_name']),
                    ),
                  if (userData['country'] != null)
                    ListTile(
                      title: Text(getTranslated(context, 'country')),
                      subtitle: Text(userData['country']),
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

  blockCliched() {
    setState(() {
      buttonPressed = true;
    });

    widget.isblock
        ? widget.bloc.unBlockUser(withUser, context, source)
        : widget.bloc.blockUser(withUser, context, source);
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
      appBar: AppTopBar(
        appBar: AppBar(),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 5,
                  ),
                  Text("loading...")
                ],
              ),
            )
          : ListView(
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
                              widget.withUser.toString() +
                              "?kycImage=0",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  this.title.toUpperCase(),
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  widget.withUser,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Provider.of<LayoutProvider>(context).lauoutMode != 3
                        ? IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: FaIcon(FontAwesomeIcons.comment),
                            color: Colors.grey,
                          )
                        : SizedBox(),
                    IconButton(
                      onPressed: transferClickPossible ? payClickHandler : null,
                      icon: FaIcon(FontAwesomeIcons.moneyBillWave),
                      color: Colors.grey,
                    ),
                    // IconButton(
                    //   onPressed:
                    //       transferClickPossible ? requestSendClickHandler : null,
                    //   icon: FaIcon(FontAwesomeIcons.fileInvoice),
                    //   color: Colors.grey,
                    // ),
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
                                userRating != ''
                                    ? ratingValueText(userRating)
                                    : '',
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
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => blockCliched(),
                  child: buttonPressed
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.white))
                      : Text(
                          widget.isblock
                              ? getTranslated(context, 'unblock')
                              : getTranslated(context, 'block'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                ),
                SizedBox(height: 20),
                PublicArea(
                  userName: widget.withUser.toString(),
                  perspective: 'user',
                  centerLayout: true,
                ),
              ],
            ),
    );
  }
}
