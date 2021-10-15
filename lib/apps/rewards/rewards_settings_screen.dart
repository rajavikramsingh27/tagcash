import 'package:flutter/material.dart';
import 'package:tagcash/apps/coupons/models/role_merchant.dart';
import 'package:tagcash/apps/rewards/models/staff_user.dart';
import 'package:tagcash/apps/rewards/reward_add_rule.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/constants.dart';

class RewardsSettingsScreen extends StatefulWidget {
  @override
  _RewardsSettingsScreenState createState() => _RewardsSettingsScreenState();
}

class _RewardsSettingsScreenState extends State<RewardsSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  List<Wallet> walletData = [];

  bool isLoading = false;
  RoleMerchant selectedRole;
  String roleId;
  Future<List<RoleMerchant>> roleListData;
  Future<List<StaffUser>> staffListData;
  Future<List<StaffUser>> adminsListData;
  StaffUser staffUser;
  String staffId;
  bool _isStaffLoading = true;
  bool _isAdminsLoading = true;

  final phpController = TextEditingController();
  final tagController = TextEditingController();

  @override
  void initState() {
    super.initState();

    roleListData = roleListLoad();
    adminsListData = adminsListLoad();
    staffListData = staffListLoad();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phpController.dispose();
    tagController.dispose();
    super.dispose();
  }

  Future<List<RoleMerchant>> roleListLoad() async {
    print('roleListLoad');
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['community_id'] =
        Provider.of<MerchantProvider>(context, listen: false)
            .merchantData
            .id
            .toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('community/GetAllRoles', apiBodyObj);
    List responseList = response['result'];

    List<RoleMerchant> getData = responseList.map<RoleMerchant>((json) {
      return RoleMerchant.fromJson(json);
    }).toList();
    return getData;
  }

  Widget _getRolesList() {
    return FutureBuilder(
        future: roleListData,
        builder:
            (BuildContext context, AsyncSnapshot<List<RoleMerchant>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<RoleMerchant>(
                  isExpanded: true,
                  hint: Text(
                    getTranslated(context, "scratch_role"),
                  ),
                  value: selectedRole,
                  onChanged: (RoleMerchant value) {
                    setState(() {
                      roleId = value.id.toString();
                      selectedRole = value;
                    });
                  },
                  items: snapshot.data.map((RoleMerchant role) {
                    return DropdownMenuItem<RoleMerchant>(
                      value: role,
                      child: Text(role.roleName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }

  Future<List<StaffUser>> staffListLoad() async {
    print('staffListLoad');
    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/GetStaffMembers');
    List responseList = response['result'];

    List<StaffUser> getData = responseList.map<StaffUser>((json) {
      return StaffUser.fromJson(json);
    }).toList();
    if (mounted) {
      setState(() {
        _isStaffLoading = false;
      });
    }
    return getData;
  }

  Widget _getStaffList() {
    return FutureBuilder(
        future: staffListData,
        builder:
            (BuildContext context, AsyncSnapshot<List<StaffUser>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<StaffUser>(
                  isExpanded: true,
                  hint: Text(getTranslated(context, "select_staff")),
                  value: staffUser,
                  onChanged: (StaffUser value) {
                    setState(() {
                      staffId = value.id;
                      staffUser = value;
                    });
                  },
                  items: snapshot.data.map((StaffUser staffUser) {
                    return DropdownMenuItem<StaffUser>(
                      value: staffUser,
                      child: Text(staffUser.userFirstname +
                          " " +
                          staffUser.userLastname),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }

  Future<List<StaffUser>> adminsListLoad() async {
    print('adminsListLoad');
    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/ListAdmins');
    List responseList = response['result'];

    List<StaffUser> getData = responseList.map<StaffUser>((json) {
      return StaffUser.fromJson(json);
    }).toList();
    staffUser = getData[0];
    staffUser = null;
    if (mounted) {
      setState(() {
        _isAdminsLoading = false;
      });
    }
    return getData;
  }

  Widget _getAdminsList() {
    return FutureBuilder(
        future: adminsListData,
        builder:
            (BuildContext context, AsyncSnapshot<List<StaffUser>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        child: GestureDetector(
//                        onTap: () {
//                          _listItemTapped(snapshot.data[index].id);
//                        },
                            child: AdminRowItem(
                                snapshot.data[index].userFirstname +
                                    " " +
                                    snapshot.data[index].userLastname,
                                onDelete: () => deleteAdminHandler(
                                    snapshot.data[index].id))));
                  })
              : Center(child: Loading());
        });
  }

  deleteAdminHandler(String id) async {
    print("deleteAdminHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['admin_id'] = id;
    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/DeleteAdmin', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      _isStaffLoading = true;
      _isAdminsLoading = true;
      adminsListData = adminsListLoad();
      staffListData = staffListLoad();
    } else {
      setState(() {
        isLoading = false;
      });
      String err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getRolesList(),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getTranslated(
                                              context, "rewar_receipt"),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: RaisedButton(
                                                child: Text(getTranslated(
                                                    context, "reard_php")),
                                                color: Colors.grey[500],
                                                textColor: Colors.white,
                                                onPressed: () {},
                                              ),
                                              flex: 2,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: phpController,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: false),
                                                decoration: InputDecoration(
                                                  hintText: getTranslated(
                                                      context,
                                                      "reward_enter_amount_txt"),
                                                  labelText: getTranslated(
                                                      context, "reward_amount"),
                                                ),
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    var msg = getTranslated(
                                                        context,
                                                        "enter_amount");
                                                    return msg;
                                                  }
                                                  return null;
                                                },
                                              ),
                                              flex: 3,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    flex: 1,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getTranslated(
                                              context, "reward_give_txt"),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: RaisedButton(
                                                child: Text(getTranslated(
                                                    context, "reward_tag")),
                                                color: Colors.grey[500],
                                                textColor: Colors.white,
                                                onPressed: () {},
                                              ),
                                              flex: 2,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: tagController,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: false),
                                                decoration: InputDecoration(
                                                  hintText: getTranslated(
                                                      context,
                                                      "reward_enter_amount_txt"),
                                                  labelText: getTranslated(
                                                      context, "reward_amount"),
                                                ),
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    var msg = getTranslated(
                                                        context,
                                                        "reward_enter_amount_txt");
                                                    return msg;
                                                  }
                                                  return null;
                                                },
                                              ),
                                              flex: 3,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    flex: 1,
                                  ),
                                ]),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                child: Text(getTranslated(context, "save")),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    if (selectedRole == null) {
                                      final snackBar = SnackBar(
                                          content: Text(getTranslated(
                                              context, "reward_role_select")),
                                          duration: const Duration(seconds: 3));
                                      _scaffoldKey.currentState
                                          .showSnackBar(snackBar);
                                    } else
                                      addRuleHandler();
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (!_isStaffLoading && !_isAdminsLoading)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: _getStaffList(),
                                    flex: 9,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: RaisedButton(
                                      child: Text("+"),
                                      color: kPrimaryColor,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        addAdminHandler();
                                      },
                                    ),
                                    flex: 1,
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            if (!_isAdminsLoading && !_isStaffLoading)
                              Text(
                                getTranslated(context, "reward_admins"),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            if (!_isAdminsLoading && !_isStaffLoading)
                              _getAdminsList(),
                          ],
                        )),
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
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addRuleButtonTapped();
        },
        child: Icon(Icons.add),
        tooltip: getTranslated(context, "create_reward"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Future _addRuleButtonTapped() async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RewardAddRuleScreen(isOwnerOrAdmin: false)));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'addRuleSuccess') {
          final snackBar = SnackBar(
              content:
                  Text(getTranslated(context, "reward_given_successfully")),
              duration: const Duration(seconds: 3));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      });
    }
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
    apiBodyObj['member_status'] = '1';
    apiBodyObj['role_id'] = selectedRole.id.toString();
    //apiBodyObj['member_status'] = '1';

    Map<String, dynamic> response;
    response = await NetworkHelper.request('RewardRules/AddRules', apiBodyObj);
    print(response);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
        selectedRole = null;
        roleId = null;
        tagController.text = "";
        phpController.text = "";
        final snackBar = SnackBar(
            content: Text(getTranslated(context, "reward_given_successfully")),
            duration: const Duration(seconds: 3));
        _scaffoldKey.currentState.showSnackBar(snackBar);
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
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  addAdminHandler() async {
    print("addAdminHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['admin_id'] = staffUser.id;

    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/AddAdmin', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      _isStaffLoading = true;
      _isAdminsLoading = true;
      adminsListData = adminsListLoad();
      staffListData = staffListLoad();
      final snackBar = SnackBar(
          content: Text(getTranslated(context, "reward_admin_added")),
          duration: const Duration(seconds: 3));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "switch_to_community_perspective") {
        err = getTranslated(context, "reward_switch_merchant_perspective");
      } else if (response['error'] == "failed_to_add_the_admin") {
        err = getTranslated(context, "reward_failed_add_admin");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else {
        err = getTranslated(context, "reward_failed_add_admin");
      }
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}

class AdminRowItem extends StatelessWidget {
  final String name;
  final VoidCallback onDelete;

  AdminRowItem(this.name, {this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
                icon: Icon(Icons.delete),
                color: kPrimaryColor,
                iconSize: 24,
                tooltip: getTranslated(context, "delete"),
                onPressed: () {
                  //this.onDelete,
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _DeleteAdminDialog(
                          onDSuccess: (value) {
                            //deleteLoanHandler();
                            this.onDelete();
                          },
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}

class _DeleteAdminDialog extends StatefulWidget {
  _DeleteAdminDialog({this.onDSuccess});

  ValueChanged<String> onDSuccess;

  @override
  _DeleteAdminDialogState createState() => _DeleteAdminDialogState();
}

class _DeleteAdminDialogState extends State<_DeleteAdminDialog> {
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
      title: Text(getTranslated(context, "reward_delete_admin")),
      content: Text(getTranslated(context, "reward_delete_admin_rqst")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
