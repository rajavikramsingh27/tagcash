import 'package:flutter/material.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

enum RoleType { staff, member }
enum PeriodType { monthly, yearly, lifetime }

class RolesEditScreen extends StatefulWidget {
  final Role role;

  const RolesEditScreen({Key key, this.role}) : super(key: key);

  @override
  _RolesEditScreenState createState() => _RolesEditScreenState();
}

class _RolesEditScreenState extends State<RolesEditScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _nameController = TextEditingController();
  RoleType _roleType = RoleType.staff;

  bool defaultRoleEditable = true;

  bool defaultRoleChecked = false;

  bool viewWalletsStatus = true;
  bool transferFundsStatus = true;
  bool chargeUsersStatus = true;
  bool editRolesStatus = true;
  bool assignMemberStatus = true;
  bool assignStaffStatus = true;

  PeriodType periodType = PeriodType.monthly;
  final _feeController = TextEditingController();
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.role != null) {
      _nameController.text = widget.role.roleName;
      isEditMode = true;
      if (widget.role.roleType == "staff") {
        _roleType = RoleType.staff;
        loadRolePermisions();
      } else if (widget.role.roleType == "member") {
        if (widget.role.roleDefault) {
          defaultRoleEditable = false;
          defaultRoleChecked = true;
        }
        _roleType = RoleType.member;
        if (widget.role.fee != '') {
          print(widget.role.fee.toString());
          _feeController.text = widget.role.fee;
          if (widget.role.noOfDays == "30")
            periodType = PeriodType.monthly;
          else if (widget.role.noOfDays == "365")
            periodType = PeriodType.yearly;
          else if (widget.role.noOfDays == "36500")
            periodType = PeriodType.lifetime;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void loadRolePermisions() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.role.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('role/GetPermissions', apiBodyObj);

    isLoading = false;

    if (response['status'] == 'success') {
      List responseList = response['result'];

      viewWalletsStatus = false;
      transferFundsStatus = false;
      chargeUsersStatus = false;
      editRolesStatus = false;
      assignMemberStatus = false;
      assignStaffStatus = false;

      for (var i = 0; i < responseList.length; i++) {
        switch (responseList[i]['id']) {
          case "31":
            viewWalletsStatus = true;
            break;
          case "33":
            transferFundsStatus = true;

            //     if (resultArr[i].wallet_details) {
            //       var wallet_detailsArr = resultArr[i].wallet_details;
            //       for (var j = 0; j < wallet_detailsArr.length; j++) {
            //         var obj = {};
            //         obj.walletId = wallet_detailsArr[j].wallet_id;
            //         obj.currencyCode = wallet_detailsArr[j].currency_code;
            //         obj.limit = Observable(wallet_detailsArr[j].wallet_limit);
            //         limitTransferList.add(obj);
            //       }
            //     }
            break;
          case "31":
            viewWalletsStatus = true;
            break;
          case "34":
            chargeUsersStatus = true;
            break;
          case "4":
            editRolesStatus = true;
            break;
          case "36":
            assignMemberStatus = true;
            break;
          case "37":
            assignStaffStatus = true;
            break;
        }
      }
    }

    setState(() {});
  }

  void staffRoleSubmitHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['role_name'] = _nameController.text;

    List permisionArr = [];

    if (viewWalletsStatus) {
      permisionArr.add(31);
    }

    if (transferFundsStatus) {
      permisionArr.add(33);

      // var walletLimitArr = [];
      // limitTransferList.forEach(function (item, index1) {
      //     var obj = {};
      //     obj.wallet_id = item.walletId;
      //     obj.limit = item.limit.value;
      //     walletLimitArr.push(obj);
      // });

      // if (walletLimitArr.length != 0) {
      //     apiBodyObj.wallet_limit = JSON.stringify(walletLimitArr);
      // }

    }

    if (chargeUsersStatus) {
      permisionArr.add(34);
    }
    if (editRolesStatus) {
      permisionArr.add(4);
    }
    if (assignMemberStatus) {
      permisionArr.add(36);
    }
    if (assignStaffStatus) {
      permisionArr.add(37);
    }

    if (permisionArr.length != 0) {
      apiBodyObj['role_permissions'] = permisionArr.toString();
    }

    String path;
    if (widget.role == null) {
      path = "role/addStaffRolePermissions";
    } else {
      path = "role/editStaffRolePermissions";
      apiBodyObj['id'] = widget.role.id.toString();
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(path, apiBodyObj);

    if (response['status'] == 'success') {
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
      if (response['error'] == 'permission_denied') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error_upper'),
            message:
            getTranslated(context, 'dont_have_suff_permission'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  void memberRoleSubmitHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['role_type'] = 'member';
    apiBodyObj['role_name'] = _nameController.text;
    if (defaultRoleChecked) {
      apiBodyObj['role_default'] = '1';
    } else {
      apiBodyObj['role_default'] = '0';
    }
    if (_feeController.text != '') {
      if (periodType == PeriodType.monthly) {
        apiBodyObj['no_of_days'] = '30';
      } else if (periodType == PeriodType.yearly) {
        apiBodyObj['no_of_days'] = '365';
      } else if (periodType == PeriodType.lifetime) {
        apiBodyObj['no_of_days'] = '36500';
      }
      apiBodyObj['fee'] = _feeController.text;
    }
    String path;
    if (widget.role == null) {
      path = "role/create";
    } else {
      path = "role/edit/" + widget.role.id.toString();
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(path, apiBodyObj);

    if (response['status'] == 'success') {
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
      if (response['error'] == 'permission_denied') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error_upper'),
            message:
            getTranslated(context, 'dont_have_suff_permission'));
      } else if (response['error'] == 'invalid_role_type'){
        showSnackBar(getTranslated(context, 'invalid_role_type'));
      } else if (response['error'] == 'invalid_amount'){
        showSnackBar(getTranslated(context, 'invalid_amount'));
      } else if (response['error'] == 'invalid_no_of_days'){
        showSnackBar(getTranslated(context, 'invalid_no_of_days'));
      } else if (response['error'] == 'invalid_wallet_id'){
        showSnackBar(getTranslated(context, 'invalid_wallet_id'));
      } else if (response['error'] == 'already_charging_exist_for_role_id'){
        showSnackBar(getTranslated(context, 'already_charging_exist_for_role_id'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  void periodTypeChangeHandler(PeriodType value) {
    setState(() {
      periodType = value;
    });
  }

  void cancelHandler() {
    if (widget.role == null) {
      Navigator.pop(context);
    } else {
      deleteRole();
    }
  }

  void deleteRole() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('role/delete/' + widget.role.id.toString());

    if (response['status'] == 'success') {
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
      if (response['error'] == 'default_role_cannot_be_deleted') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error_upper'), message: getTranslated(context, 'default_role_deleted'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
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
        title: widget.role != null ? getTranslated(context, 'edit_role') : getTranslated(context, 'create_role'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: enableAutoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              padding: EdgeInsets.all(kDefaultPadding),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: getTranslated(context, 'role_name'),
                  ),
                  validator: (value) {
                    if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                      return getTranslated(context, 'please_enter_role_name');
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<RoleType>(
                          title: Text(getTranslated(context, 'staff')),
                          value: RoleType.staff,
                          groupValue: _roleType,
                          onChanged: isEditMode ? null : (RoleType value) {
                            setState(() {
                              _roleType = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<RoleType>(
                          title: Text(getTranslated(context, 'contacts_tagcashmember')),
                          value: RoleType.member,
                          groupValue: _roleType,
                          onChanged: isEditMode ? null : (RoleType value) {
                            setState(() {
                              _roleType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                AbsorbPointer(
                  absorbing: defaultRoleEditable ? false : true,
                  child: Opacity(
                    opacity: defaultRoleEditable ? 1 : 0.5,
                    child: _roleType == RoleType.member
                        ? CheckboxListTile(
                            title: Text(getTranslated(context, 'default_role')),
                            value: defaultRoleChecked,
                            onChanged: (newValue) {
                              setState(() {
                                defaultRoleChecked = newValue;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          )
                        : SizedBox(),
                  ),
                ),
                if (_roleType == RoleType.member)
                  Column(children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Radio(
                            value: PeriodType.monthly,
                            groupValue: periodType,
                            onChanged: periodTypeChangeHandler,
                          ),
                          Text(
                            getTranslated(context, 'monthly'),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Radio(
                            value: PeriodType.yearly,
                            groupValue: periodType,
                            onChanged: periodTypeChangeHandler,
                          ),
                          Text(
                            getTranslated(context, 'yearly'),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Radio(
                            value: PeriodType.lifetime,
                            groupValue: periodType,
                            onChanged: periodTypeChangeHandler,
                          ),
                          Text(
                            getTranslated(context, 'lifetime'),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 0),
                      child: TextFormField(
                        controller: _feeController,
                        decoration: InputDecoration(
                          hintText: '0',
                          labelText: getTranslated(context, 'fee_charged_in_credits'),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(context, 'please_enter_fee_charged_in_credits');
                            // return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ]),
                if (_roleType == RoleType.staff)
                  Column(
                    children: [
                      CheckboxListTile(
                        title: Text(getTranslated(context, 'view_wallets')),
                        value: viewWalletsStatus,
                        onChanged: (newValue) {
                          setState(() {
                            viewWalletsStatus = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(getTranslated(context, 'transfer_funds')),
                        value: transferFundsStatus,
                        onChanged: (newValue) {
                          setState(() {
                            transferFundsStatus = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(getTranslated(context, 'charge_users')),
                        value: chargeUsersStatus,
                        onChanged: (newValue) {
                          setState(() {
                            chargeUsersStatus = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(getTranslated(context, 'create_and_edit_roles')),
                        value: editRolesStatus,
                        onChanged: (newValue) {
                          setState(() {
                            editRolesStatus = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(getTranslated(context, 'assign_member_roles')),
                        value: assignMemberStatus,
                        onChanged: (newValue) {
                          setState(() {
                            assignMemberStatus = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(getTranslated(context, 'assign_staff_role')),
                        value: assignStaffStatus,
                        onChanged: (newValue) {
                          setState(() {
                            assignStaffStatus = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      child: Text(widget.role != null ? getTranslated(context, 'delete') : getTranslated(context, 'cancel')),
                      onPressed: () {
                        cancelHandler();
                      },
                    ),
                    ElevatedButton(
                      child: Text(getTranslated(context, 'save')),
                      onPressed: () {
                        setState(() {
                          enableAutoValidate = true;
                        });
                        if (_formKey.currentState.validate()) {
                          if (_roleType == RoleType.staff) {
                            staffRoleSubmitHandler();
                          } else {
                            memberRoleSubmitHandler();
                          }
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
