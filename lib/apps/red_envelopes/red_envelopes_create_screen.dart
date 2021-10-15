import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/own_wallet_select.dart';
import 'package:tagcash/components/snackbar_notification.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/services/app_service.dart';

import 'model/redevelope_item.dart';

class RedEnvelopeCreateScreen extends StatefulWidget {
  @override
  _RedEnvelopeCreateScreenState createState() =>
      _RedEnvelopeCreateScreenState();
}

class _RedEnvelopeCreateScreenState extends State<RedEnvelopeCreateScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool isMerchantPerspective = false;

  final formKey = GlobalKey<FormState>();
  var codeInputControl = TextEditingController();
  var nameInputControl = TextEditingController();
  var totalNumberInputControl = TextEditingController();
  var emailInputControl = TextEditingController();
  final amountInputControl = TextEditingController();
  bool randomize = false;

  int walletId = 0;
  String currencyCode = "";

  bool emailBool = false;
  bool totalNumberBool = false;
  bool communityRoleBool = false;

  List<RedEnevlopItem> redEvelopeItems = List<RedEnevlopItem>();
  List<Role> communityRoleList = List<Role>();

  String selectedReceipientRole;
  int receipientType;

  List<String> redEnevlopeEmails = new List<String>();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    isMerchantPerspective = AppService.isMerchantPerspective(context);

    receipientType = 1;
    emailBool = true;

    emailInputControl = TextEditingController(text: '');

    getDefaultWallet();
    getCommunityRoles();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  getDefaultWallet() async {
    // Get Default Wallet
    var wallet = await AppService.getDefaultWallet();
    if (wallet != null) {
      setState(() {
        isLoading = false;
        currencyCode = wallet.currencyCode;
        walletId = wallet.walletId;
      });
    }
  }

  getCommunityRoles() async {
    if (isMerchantPerspective) {
      // Get Community Roles
      var merchantData = AppService.merchantData(context);
      var communityId = merchantData.id.toString();
      var rolesList = await AppService.getCommunityRoles(communityId);

      if (rolesList.length > 0) {
        setState(() {
          communityRoleList = rolesList;
          selectedReceipientRole = rolesList[0].id.toString();
        });
      }
    }
  }

  redEnvelopeCreate() async {
    if (walletId <= 0) {
      SnackbarNotification.show(
          _scaffoldKey, getTranslated(context, 'select_wallet'));
      return;
    }

    if (!Validator.isAmount(amountInputControl.text)) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, 'red_envelopes_amount_should_not_empty'));
      return;
    }

    if (!Validator.isAmount(totalNumberInputControl.text)) {
      SnackbarNotification.show(
          _scaffoldKey,
          getTranslated(
              context, 'red_envelopes_total_number_should_not_empty'));
      return;
    }

    var amount = int.tryParse(amountInputControl.text);
    var totalNumbers = int.tryParse(totalNumberInputControl.text);

    if (amount < totalNumbers) {
      SnackbarNotification.show(
          _scaffoldKey,
          getTranslated(context,
              'red_envelopes_amount_should_greater_than_total_number'));
      return;
    }

    if (receipientType == 2 && selectedReceipientRole.isEmpty) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, 'red_envelopes_role_must_be_selected'));
      return;
    }

    setState(() {
      isLoading = true;
    });

    var apiBodyObj = {
      "amount": amountInputControl.text,
      "total_users": totalNumberInputControl.text,
      "wallet_id": walletId,
      "randomize": randomize ? "1" : "0",
      "receipient_type": receipientType.toString(),
    };

    if (receipientType == 1) {
      apiBodyObj["email"] = jsonEncode(redEnevlopeEmails);
    } else if (receipientType == 2) {
      apiBodyObj["receipient_role"] = selectedReceipientRole;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('RedEnvelops/CreateEnvelope', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    var status = response["status"].toString();
    var arr = response["result"];

    if (status == "success") {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "red_envelopes_created_successfully"));
      Navigator.of(context).pop(true);
    } else {
      var error = response["error"];

      var message = 'error_occurred';

      if (error == "insuffcient_balance") {
        message = error;
      }
      SnackbarNotification.show(
          _scaffoldKey,
          getTranslated(context, 'error') +
              ': ' +
              getTranslated(context, message));
    }
  }

  getTotalNumber(int receipientType) async {
    setState(() {
      isLoading = true;
    });

    var apiBodyObj = {};
    apiBodyObj["receipient_type"] = receipientType.toString();
    if (receipientType == 2) {
      apiBodyObj["receipient_role"] = selectedReceipientRole;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('RedEnvelops/totalUsers', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    var status = response["status"].toString();

    if (status == "success") {
      var totalUsers = response["totalUsers"].toString();
      if (!Validator.isAmount(totalUsers)) {
        receipientType = 0;
        communityRoleBool = false;
        emailBool = true;
        totalNumberBool = false;
        emailInputControl = TextEditingController(text: '');

        SnackbarNotification.show(
            _scaffoldKey, getTranslated(context, "red_envelopes_no_friends"));
      } else {
        totalNumberInputControl = TextEditingController(text: totalUsers);
      }
    }
  }

  handleAddEmailUser() {
    var emailValue = emailInputControl.text.toLowerCase();

    if (emailValue.isEmpty || !Validator.isEmail(emailValue)) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "red_envelopes_error_enter_valid_email"));
      return;
    }

    var emailExist = redEnevlopeEmails.contains(emailValue);

    if (emailExist) {
      SnackbarNotification.show(_scaffoldKey,
          getTranslated(context, "red_envelopes_error_email_already_added"));
      return;
    }

    setState(() {
      redEnevlopeEmails.add(emailValue);
      totalNumberInputControl =
          TextEditingController(text: redEnevlopeEmails.length.toString());
      emailInputControl = TextEditingController(text: '');
    });
  }

  handleEnvelopeTypeChange(int newValue) {
    emailBool = false;
    totalNumberBool = false;
    communityRoleBool = false;

    if (newValue == 1) {
      emailBool = true;
      emailInputControl = TextEditingController(text: '');
    } else if (newValue == 2) {
      communityRoleBool = true;
      getTotalNumber(newValue);
    } else if (newValue == 3) {
      getTotalNumber(3);
    } else if (newValue == 4) {
      totalNumberBool = true;
    } else if (newValue == 5) {
      getTotalNumber(5);
    }

    setState(() {
      receipientType = newValue;
      totalNumberInputControl = TextEditingController(text: '');
    });
  }

  handleWalletChange(Wallet wallet) {
    setState(() {
      walletId = wallet.walletId;
      currencyCode = wallet.currencyCode;
    });
  }

  //----- UI Methods ------//
  buildForm() {
    if (isMerchantPerspective) {
      redEvelopeItems = [
        new RedEnevlopItem(
            name: getTranslated(context, "red_envelope_manualy_added"),
            value: 1),
        new RedEnevlopItem(
            name: getTranslated(context, "red_envelope_community_role"),
            value: 2),
        new RedEnevlopItem(
            name: getTranslated(context, "red_envelope_all_member_community"),
            value: 3),
        new RedEnevlopItem(
            name: getTranslated(context, "red_envelope_anyone"), value: 4)
      ];
    } else {
      redEvelopeItems = [
        new RedEnevlopItem(
            name: getTranslated(context, "red_envelope_manualy_added"),
            value: 1),
        new RedEnevlopItem(
            name: getTranslated(context, "red_envelope_use_all_friends"),
            value: 5)
      ];
    }

    final totalNumberFormField = TextFormField(
      keyboardType: TextInputType.number,
      enabled: totalNumberBool,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: totalNumberInputControl,
      validator: (value) {
        if (totalNumberBool && value.isEmpty) {
          return getTranslated(
              context, 'red_envelopes_total_number_should_not_empty');
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: getTranslated(context, 'red_envelopes_total_number'),
      ),
    );

    final redEvelopeItemsFormField = DropdownButtonFormField<int>(
        hint: new Text("Selecte Item"),
        isExpanded: true,
        value: receipientType,
        items:
            redEvelopeItems.map<DropdownMenuItem<int>>((RedEnevlopItem item) {
          return DropdownMenuItem<int>(
            value: item.value,
            child: Text(item.name),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return getTranslated(context, 'red_envelopes_select_type');
          }
          return null;
        },
        onChanged: handleEnvelopeTypeChange);

    final randomizeFormField = CheckboxListTile(
      title: Text(getTranslated(context, "red_envelopes_randomize")),
      value: randomize,
      contentPadding: EdgeInsets.all(0),
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool value) {
        setState(() {
          randomize = value;
        });
      },
    );

    final communityRoleListFormField = DropdownButtonFormField<String>(
        hint: new Text("Selecte Item"),
        isExpanded: true,
        value: selectedReceipientRole,
        items: communityRoleList.map<DropdownMenuItem<String>>((Role item) {
          return DropdownMenuItem<String>(
            value: item.id.toString(),
            child: Text(item.roleName),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return getTranslated(context, 'red_envelopes_select_type');
          }
          return null;
        },
        onChanged: (String newValue) {
          setState(() {
            selectedReceipientRole = newValue;
          });
          getTotalNumber(2);
        });

    final amountFormField = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return getTranslated(context, 'enter_a_valid_amount');
        }
        return null;
      },
      keyboardType: TextInputType.number,
      controller: amountInputControl,
      decoration: InputDecoration(
        labelText: getTranslated(context, 'amount'),
      ),
    );

    Widget conditionalWidgets = SizedBox();
    if (emailBool) {
      conditionalWidgets = buildAddEmailMethod();
    } else if (communityRoleBool) {
      conditionalWidgets = SizedBox(child: communityRoleListFormField);
    }

    return Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OwnWalletSelect(
                currencyCode: currencyCode,
                onChange: handleWalletChange,
              ),
              SizedBox(width: 25),
              Expanded(child: amountFormField),
            ],
          ),
          SizedBox(height: 15),
          SizedBox(child: redEvelopeItemsFormField),
          SizedBox(height: 15),
          conditionalWidgets,
          SizedBox(child: totalNumberFormField),
          SizedBox(height: 15),
          SizedBox(child: randomizeFormField),
          SizedBox(height: 20),
          SizedBox(
              width: double.infinity,
              child: CustomButton(
                  label: getTranslated(context, 'red_envelopes_create')
                      .toUpperCase(),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      redEnvelopeCreate();
                    }
                  }))
        ]));
  }

  buildAddEmailMethod() {
    return Column(children: [
      Row(children: [
        Expanded(
          child: TextFormField(
              controller: emailInputControl,
              decoration: InputDecoration(hintText: 'Enter Email')),
        ),
        SizedBox(width: 20),
        Container(
            width: 36,
            height: 36,
            color: Theme.of(context).primaryColor,
            child: IconButton(
                padding: EdgeInsets.all(0),
                color: Colors.white,
                icon: Icon(Icons.add),
                onPressed: handleAddEmailUser))
      ]),
      SizedBox(height: 15),
      redEnevlopeEmails.length > 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: EdgeInsets.only(bottom: 15),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: redEnevlopeEmails
                    .map((email) => Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              email,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            )),
                            SizedBox(width: 20),
                            Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    color: Colors.white,
                                    icon: Icon(Icons.remove, size: 16),
                                    onPressed: () {
                                      var index =
                                          redEnevlopeEmails.indexOf(email);
                                      if (index > -1) {
                                        setState(() {
                                          redEnevlopeEmails.removeAt(index);
                                          totalNumberInputControl.text =
                                              redEnevlopeEmails.length
                                                  .toString();
                                        });
                                      }
                                    }))
                          ],
                        )))
                    .toList(),
              ),
            )
          : SizedBox(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "red_envelopes"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 0.0,
                            offset: Offset(0.0, 0.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: AppService.isDarkMode(context)
                            ? Colors.grey[800]
                            : Colors.white),
                    child: Padding(
                        padding: EdgeInsets.all(15), child: buildForm()))),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
