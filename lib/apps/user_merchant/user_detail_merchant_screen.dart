import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/pin_entry_text_field.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';
import 'components/rating_panel.dart';

class UserDetailMerchantScreen extends StatefulWidget {
  final Map userData;
  final String identifier;

  const UserDetailMerchantScreen({Key key, this.userData, this.identifier})
      : super(key: key);

  @override
  _UserDetailMerchantScreenState createState() =>
      _UserDetailMerchantScreenState();
}

class _UserDetailMerchantScreenState extends State<UserDetailMerchantScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  bool isLoading = false;
  String userRating;

  bool chargingPossible = false;
  bool addPossible = false;
  bool removePossible = false;

  bool roleEditable = false;
  String roleDisplay = "Non Member";
  int roleId = -1;
  List roleListItems;

  TextEditingController _amountController;
  TextEditingController _notesController;

  int activeWalletId = 1;
  String activeCurrencyCode = 'PHP';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    if (Provider.of<MerchantProvider>(context, listen: false)
        .merchantData
        .kycVerified) {
      // if (_model.availablePermission.charge) {

      chargingPossible = true;
    }

    userRating = widget.userData['rating'].toString();

    Map role = widget.userData['role'];
    roleDisplay = role['role_name'];
    roleId = role['role_id'];

    if (role['role_status'] == 'approved') {
      if (role['role_type'] != 'owner') {
        // if (_model.availablePermission.assignMember || _model.availablePermission.assignStaff) {
        roleEditable = true;
        removePossible = true;
        // }
      }
    } else {
      addPossible = true;
    }

    getRoles();
    defaultWalletLoad();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void getRoles() async {
    Map<String, dynamic> response = await NetworkHelper.request('role/list');

    if (response['status'] == 'success') {
      roleListItems = response['result'];
    }
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

  void creditPayClickHandler(String action) {
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
                            if (action == 'credit') {
                              transferProcess();
                            } else {
                              pinCheckHandler();
                            }
                          }
                        },
                        child: Text(action.toUpperCase()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  pinCheckHandler() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(20.0), // content padding
                child: PinEntryTextField(
                  showFieldAsBox: true,
                  onSubmit: (String pin) {
                    Navigator.pop(context);
                    transferProcess(pin);
                  }, // end onSubmit
                ),
              ),
            ),
          );
        });
  }

  transferProcess([String pin]) async {
    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Receipt receiptData = Receipt(
      type: 'send_tagcash',
      direction: pin != null ? 'in' : 'out',
      walletId: activeWalletId,
      amount: amountValue,
      currencyCode: activeCurrencyCode,
      narration: _notesController.text,
      name: widget.userData['name'],
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['from_wallet_id'] = activeWalletId.toString();
    apiBodyObj['to_wallet_id'] = activeWalletId.toString();
    apiBodyObj['narration'] = _notesController.text;

    if (pin == null) {
      if (widget.identifier != null) {
        apiBodyObj['identifier'] = widget.identifier;
      } else {
        apiBodyObj['to_type'] = 'user';
        apiBodyObj['to_id'] = widget.userData['id'].toString();
      }
    } else {
      apiBodyObj['charging'] = 'true';
      apiBodyObj['pin'] = pin;
      apiBodyObj['from_type'] = 'user';
      apiBodyObj['from_id'] = widget.userData['id'].toString();
    }

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
    apiBodyObj['to_user'] = widget.userData['id'].toString();

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

    Map<String, dynamic> response = await NetworkHelper.request(
        'community/adduser/' + widget.userData['id'].toString());

    isLoading = false;
    if (response['status'] == 'success') {
      addPossible = false;
      removePossible = true;

      showSnackBar(getTranslated(context, 'user_add_success'));

      //    if (result.status == "pending") {
      //   tagEvents.emit("toastShow", { message: "Request is pending" });
      // } else if (result.status == "approved") {
      //   addMemberPossibleStat.value = false;
      //   removeMemberPossibleStat.value = true;
      //   roleEditableStatus.value = true;
      //   setRoleNameDisplay(result.role_id);

      //   tagEvents.emit("toastShow", { message: "User added" });
      // }
    } else {
      if (response['error'] == 'request_pending') {
        showSnackBar(getTranslated(context, 'request_pending'));
      } else if (response['error'] == 'blocked_by_user') {
        showSnackBar(getTranslated(context, 'blocked_by_user'));
      } else if (response['error'] == 'cant_add_paid_roles') {
        showSnackBar(getTranslated(context, 'cant_add_paid_roles'));
      } else if (response['error'] == 'daily_member_limit_exceeded') {
        showSnackBar(getTranslated(context, 'daily_member_limit_exceeded'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
    setState(() {});
  }

//   function setRoleNameDisplay(role_id) {
//   for (var i = 0; i < roleListItemsArr.length; i++) {
//     if (roleListItemsArr[i].id == role_id) {
//       roleDisplay.value = roleListItemsArr[i].role_name;
//     }
//   }
// }

  void removeClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'community/removeuser/' + widget.userData['id'].toString());

    isLoading = false;
    if (response['status'] == 'success') {
      addPossible = true;
      removePossible = false;

      roleEditable = false;
      roleDisplay = "Non Member";

      showSnackBar(getTranslated(context, 'successfully_removed'));
    } else {
      showSnackBar(getTranslated(context, 'error_occurred'));
    }
    setState(() {});
  }

  Future changeRoleClickHandler() async {
    Map selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Role'),
          children: roleListItems.map((value) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, value);
              },
              child: Text(value['role_name'].toString()), //item value
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      onRolesSelectionChanges(selected);
    }
  }

  void onRolesSelectionChanges(Map roleSelect) async {
    setState(() {
      isLoading = true;
    });

    //{"id":2915,"role_name":"Owner","role_default":false,"role_type":"owner"}

    Map<String, String> apiBodyObj = {};
    apiBodyObj['role_id'] = roleSelect['id'].toString();

    Map<String, dynamic> response = await NetworkHelper.request(
        'community/adduser/' + widget.userData['id'].toString(), apiBodyObj);

    isLoading = false;
    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (responseMap.containsKey('status') &&
          responseMap['status'] == 'approved') {
        roleDisplay = roleSelect['role_name'];
      }
    } else {
      if (response['error'] == 'request_pending') {
        showSnackBar(getTranslated(context, 'request_pending'));
      } else if (response['error'] == 'blocked_by_user') {
        showSnackBar(getTranslated(context, 'blocked_by_user'));
      } else if (response['error'] == 'cant_add_paid_roles') {
        showSnackBar(getTranslated(context, 'cant_add_paid_roles'));
      } else if (response['error'] == 'daily_member_limit_exceeded') {
        showSnackBar(getTranslated(context, 'daily_member_limit_exceeded'));
      } else {
        showSnackBar(getTranslated(context, 'failed_to_change_role'));
      }
    }
    setState(() {});
  }

  ratingChangeClickHandler() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return RatingPanel(
            id: widget.userData['id'].toString(),
            type: 'user',
            onRatingChanges: (String rating) {
              setState(() {
                userRating = rating;
              });
            },
          );
        });
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.black,
            height: 250,
            width: double.infinity,
            child: Image.network(
              AppConstants.getUserImagePath() +
                  widget.userData['id'].toString() +
                  "?kycImage=0",
            ),
          ),
          Stack(
            children: [
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(10),
                children: [
                  Text(
                    widget.userData['name'],
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.userData['id'].toString(),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 20),
                      Text(
                        roleDisplay,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      userRating != null
                          ? Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star_border,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                  Text(
                                    userRating,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: transferClickPossible
                        ? () => creditPayClickHandler('credit')
                        : null,
                    child: Text(getTranslated(context, 'credit')),
                  ),
                  chargingPossible
                      ? ElevatedButton(
                          onPressed: transferClickPossible
                              ? () => creditPayClickHandler('charge')
                              : null,
                          child: Text(getTranslated(context, 'charge')),
                        )
                      : SizedBox(),
                  // ElevatedButton(
                  //   onPressed:
                  //       transferClickPossible ? requestSendClickHandler : null,
                  //   child: Text('SEND A REQUEST TO PAY'),
                  // ),
                  ElevatedButton(
                    onPressed: ratingChangeClickHandler,
                    child: Text(getTranslated(context, 'rate')),
                  ),
                  addPossible
                      ? ElevatedButton(
                          onPressed: addClickHandler,
                          child: Text(getTranslated(context, 'add_member')),
                        )
                      : SizedBox(),
                  removePossible
                      ? ElevatedButton(
                          onPressed: removeClickHandler,
                          child: Text(getTranslated(context, 'remove_member')),
                        )
                      : SizedBox(),
                  roleEditable
                      ? ElevatedButton(
                          onPressed: changeRoleClickHandler,
                          child: Text(getTranslated(context, 'change_role')),
                        )
                      : SizedBox(),
                ],
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
