import 'dart:convert';

import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:flutter/material.dart';
import 'package:tagcash/apps/user_merchant/models/member.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/screens/qr_scan_screen.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/dialog_animated.dart';

class RewardAddRuleScreen extends StatefulWidget {
  final bool isOwnerOrAdmin;

  const RewardAddRuleScreen({Key key, this.isOwnerOrAdmin}) : super(key: key);

  @override
  _RewardAddRuleScreenState createState() => _RewardAddRuleScreenState();
}

class _RewardAddRuleScreenState extends State<RewardAddRuleScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  final _formKey1 = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final searchController = TextEditingController();
  String userId;
  String userName;
  String userRole;
  final phpController = TextEditingController();
  final tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    searchController.dispose();
    super.dispose();
  }

  getUserScanData() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanScreen(
          returnScan: true,
        ),
      ),
    );

    if (Validator.isJSON(result)) {
      Map resultJson = jsonDecode(result);

      if (resultJson.containsKey('action')) {
        String actionInput = resultJson['action'].toUpperCase();
        print(actionInput);

        if (actionInput == "PAY") {
          searchController.text = resultJson['address'];
          searchUser();
        }
      }
    } else {
      String resultData = result;
      if (resultData.indexOf("https://tagcash.com/") != -1) {
        String scanDataCheck =
            resultData.replaceFirst("https://tagcash.com/", '');

        searchController.text = scanDataClean(scanDataCheck);
        searchUser();
      } else if (Validator.isAddress(resultData)) {
        searchController.text = resultData;
        searchUser();
      }
    }

    setState(() {});
  }

  String scanDataClean(String value) {
    String returnId = value.substring(1);
    if (returnId.startsWith('/')) {
      returnId = returnId.substring(1);
    }
    return returnId;
  }

  searchUser() {
    String value = searchController.text;
    Map<String, String> apiBodyObj = {};
    if (Validator.isMobile(value)) {
      apiBodyObj['mobile'] = value;
      search(apiBodyObj);
    } else if (Validator.isEmail(value)) {
      apiBodyObj['email'] = value;
      search(apiBodyObj);
    } else if (Validator.isNumber(value)) {
      apiBodyObj['id'] = value;
      search(apiBodyObj);
    } else {
      showAnimatedDialog(context,
          title: getTranslated(context, 'error'),
          message: getTranslated(context, "reward_id_invalid"));
    }
  }

  search(Map<String, String> apiBodyObj) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];

      List<Member> getData = responseList.map<Member>((json) {
        return userDataToMember(json);
      }).toList();

      if (getData.length == 1) {
        setState(() {
          userId = getData[0].id.toString();
          userName = getData[0].userFirstname + " " + getData[0].userLastname;
          userRole = getData[0].roleName;
        });
      } else {}
    } else {
      showAnimatedDialog(context,
          title: getTranslated(context, 'error'),
          message: getTranslated(context, "reward_id_invalid"));
    }
  }

  userDataToMember(Map<String, dynamic> json) {
    if (json['role']['role_status'] == 'non_member') {
      return Member(
          id: int.parse(json['id']),
          userFirstname: json['user_firstname'].toString(),
          userLastname: json['user_lastname'].toString(),
          roleId: 0,
          roleName: 'Non Member',
          roleType: 'notowner',
          roleStatus: 'notapproved',
          rating: json['rating'].toString());
    } else {}
    return Member(
        id: int.parse(json['id']),
        userFirstname: json['user_firstname'].toString(),
        userLastname: json['user_lastname'].toString(),
        roleId: json['role'] != null ? int.parse(json['role']['role_id']) : 0,
        roleName:
            json['role'] != null ? json['role']['role_name'] : 'Non Member',
        roleType: json['role'] != null ? json['role']['role_type'] : 'notowner',
        roleStatus:
            json['role'] != null ? json['role']['role_status'] : 'notapproved',
        rating: json['rating'].toString());
  }

  addRuleHandler() async {
    print("addRuleHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['receive_wallet_id'] = '1';
    apiBodyObj['receive_amount'] = phpController.text.toString();
    apiBodyObj['reward_wallet_id'] = '7';
    apiBodyObj['reward_amount'] = tagController.text.toString();
    apiBodyObj['member_status'] = '2';
    apiBodyObj['reward_user_id'] = searchController.text.toString();

    Map<String, dynamic> response;
    response = await NetworkHelper.request('RewardRules/AddRules', apiBodyObj);
    print(response);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
        if (widget.isOwnerOrAdmin) {
          Navigator.of(context).pop({'status': 'addRuleSuccess'});
        } else {
          userId = null;
          userName = null;
          userRole = null;
          searchController.text = "";
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "reward_given_success")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });

      String err;
      if (response['error'] == "switch_to_community_perspective") {
        err = getTranslated(context, "reward_switch_merchant_perspective");
      } else if (response['error'] == "receive_wallet_id_is_required") {
        err = getTranslated(context, "recive_wallet_recived");
      } else if (response['error'] == "receive_amount_is_required") {
        err = getTranslated(context, "receive_amount_is_required");
      } else if (response['error'] == "reward_wallet_id_is_required") {
        err = getTranslated(context, "reward_wallet_id_is_required");
      } else if (response['error'] == "reward_amount_is_required") {
        err = getTranslated(context, "reward_amount_is_required");
      } else if (response['error'] == "member_status_is_required") {
        err = getTranslated(context, "member_status_is_required");
      } else if (response['error'] == "role_id_is_required") {
        err = getTranslated(context, "role_id_is_required");
      } else if (response['error'] == "reward_user_id_is_required") {
        err = getTranslated(context, "reward_user_id_is_required");
      } else if (response['error'] == "member_status_should_be_1_or_2") {
        err = getTranslated(context, "member_status_should_be_1_or_2");
      } else if (response['error'] == "role_id_is_not_under_the_merchant_id") {
        err = getTranslated(context, "role_id_is_not_under_the_merchant_id");
      } else if (response['error'] == "failed_to_add_the_reward_rule") {
        err = getTranslated(context, "failed_to_add_the_reward_rule");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else
        err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "reward"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            children: [
              Form(
                key: _formKey1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                                icon: Icon(Icons.person),
                                contentPadding:
                                    EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () {
                                    searchUser();
                                  },
                                ),
                                hintText:
                                    getTranslated(context, "reward_id_email"),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blueAccent, width: 32.0),
                                    borderRadius: BorderRadius.circular(25.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 32.0),
                                    borderRadius: BorderRadius.circular(25.0))),
                            validator: (value) {
                              if (!Validator.isRequired(value,
                                  allowEmptySpaces: false)) {
                                var msg = getTranslated(
                                    context, "reward_request_id_email");
                                return msg;
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.qr_code_outlined),
                          onPressed: () => getUserScanData(),
                        )
                      ],
                    ),
                    (userId != null)
                        ? Container(
                            height: 220,
                            width: double.infinity,
                            child: Image.network(
                              AppConstants.getUserImagePath() +
                                  userId +
                                  "?kycImage=0",
                            ),
                          )
                        : Container(
                            height: 220,
                            width: double.infinity,
                          ),
                    if (userName != null)
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                    if (userRole != null)
                      Text(
                        userRole,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    if (userId != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RaisedButton(
                              child: Text(getTranslated(context, "reard_php")),
                              color: Colors.grey[500],
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                            flex: 1,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: phpController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText: getTranslated(
                                    context, "reward_enter_amount"),
                                labelText: getTranslated(
                                    context, "reward_enter_amount"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  var msg = getTranslated(
                                      context, "reward_enter_amount_rqst");
                                  return msg;
                                }
                                return null;
                              },
                            ),
                            flex: 3,
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    if (userId != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RaisedButton(
                              child: Text(getTranslated(context, "reward_tag")),
                              color: Colors.grey[500],
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                            flex: 1,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: tagController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText:
                                    getTranslated(context, "reward_amont"),
                                labelText:
                                    getTranslated(context, "reward_amont"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  var msg = getTranslated(
                                      context, "reward_amount_rqst");
                                  return msg;
                                }
                                return null;
                              },
                            ),
                            flex: 3,
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    if (userId != null)
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text(
                            getTranslated(context, "reward_give"),
                          ),
                          color: kPrimaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            if (_formKey1.currentState.validate()) {
                              addRuleHandler();
                            }
                          },
                        ),
                      ),
                  ],
                ),
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
