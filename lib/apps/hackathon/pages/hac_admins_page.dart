import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/hackathon/models/admin_detail.dart';
import 'package:tagcash/apps/hackathon/models/admin_role.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class HacAdminsPage extends StatefulWidget {
  final String hackathonId;
  final bool ownerStatus;

  const HacAdminsPage({Key key, this.hackathonId, this.ownerStatus})
      : super(key: key);

  @override
  _HacAdminsPageState createState() => _HacAdminsPageState();
}

class _HacAdminsPageState extends State<HacAdminsPage> {
  bool isLoading = false;
  StreamController<List<AdminDetail>> _streamcontroller;
  List<AdminDetail> _admins;

  bool editableUser = false;
  @override
  void initState() {
    super.initState();

    if (widget.ownerStatus) {
      editableUser = true;
    }
    _admins = [];
    _streamcontroller = StreamController<List<AdminDetail>>.broadcast();
    adminsListLoad(true);
  }

  void adminsListLoad(bool clearData) {
    if (clearData) {
      _admins = [];
      _streamcontroller.add(_admins);
    }

    setState(() {
      isLoading = true;
    });

    adminListData().then((res) {
      setState(() {
        isLoading = false;
      });

      if (res.length != 0) {
        _admins.addAll(res);
      }

      _streamcontroller.add(_admins);
    });
  }

  Future<List<AdminDetail>> adminListData() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/ListHackathonAdmins', apiBodyObj);

    List responseList = response['result'];

    List<AdminDetail> getData = responseList.map<AdminDetail>((json) {
      return AdminDetail.fromJson(json);
    }).toList();

    return getData;
  }

  adminEditClicked(AdminDetail data) {}

  removeAdmin(AdminDetail data) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = data.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/RemoveHackathonAdmin', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      _admins.remove(data);
    }
  }

// void editHackathonAdmin(String _id, String role_name, String email) async {
//     setState(() {
//       isLoading = true;
//     });

//     Map<String, String> apiBodyObj = {};
//     apiBodyObj['_id'] = _id;
//     apiBodyObj['hackathon_id'] = hackathonId;
//     apiBodyObj['role_name'] = role_name;
//     apiBodyObj['email'] = email;

//     Map<String, dynamic> response = await NetworkHelper.request(
//         'HackathonMini/EditHackathonAdmin', apiBodyObj);

//   }
  void addAdminClicked() {
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
                child: AdminUserAdd(
                  onUserSelect: (value) => addAdminProcess(value),
                  onInviteSelect: (value) => sendInviteConfirm(value),
                ),
              ),
            ),
          );
        });
  }

  addAdminProcess(Map userData) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;
    apiBodyObj['role_name'] = userData['role'];
    apiBodyObj['email'] = userData['email'];

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/AddHackathonAdmin', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      adminsListLoad(true);
    } else {
      Fluttertoast.showToast(
          msg:
              'Unable to process your request at this time. Please try again later.');
    }
  }

  sendInviteConfirm(String email) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'EMAIL NOT FOUND',
              textAlign: TextAlign.center,
            ),
            content: Text(
                'The email you entered doesn\'t have a Tagcash account. You want to invite this user to join Tagcash?'),
            actions: [
              FlatButton(
                child: Text(
                  'NO',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: 10),
              FlatButton(
                child: Text(
                  'INVITE',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void inviteSendProcess(String email) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['email_required_status'] = '0';
    apiBodyObj['email'] = email;

    Map<String, dynamic> response =
        await NetworkHelper.request('contact/Invite', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Fluttertoast.showToast(msg: 'Invite email send successfully');
    } else {
      Fluttertoast.showToast(msg: 'Invitation sent Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: editableUser
          ? FloatingActionButton(
              onPressed: () => addAdminClicked(),
              child: Icon(Icons.add),
            )
          : null,
      body: StreamBuilder(
        stream: _streamcontroller.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<AdminDetail>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          if (!snapshot.hasData) {
            return Center(child: Loading());
          } else {
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                indent: 70,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Slidable(
                  key: ValueKey(index),
                  actionPane: SlidableDrawerActionPane(),
                  enabled: editableUser ? true : false,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => removeAdmin(snapshot.data[index]),
                    ),
                  ],
                  child: ListTile(
                    visualDensity: VisualDensity(vertical: -2),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        AppConstants.getUserImagePath() +
                            snapshot.data[index].userDetail.id.toString() +
                            "?kycImage=0",
                      ),
                    ),
                    title: RichText(
                      text: TextSpan(
                          text: snapshot.data[index].adminName,
                          style: Theme.of(context).textTheme.subtitle1,
                          children: <TextSpan>[
                            TextSpan(
                              text: snapshot.data[index].roleName == 'ADMIN'
                                  ? ' *'
                                  : '',
                              style: Theme.of(context).textTheme.headline6,
                            )
                          ]),
                    ),
                    subtitle: Text(
                      snapshot.data[index].roleName,
                    ),
                    onTap: () => adminEditClicked(snapshot.data[index]),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class AdminUserAdd extends StatefulWidget {
  final Function(Map) onUserSelect;
  final Function(String) onInviteSelect;

  const AdminUserAdd({
    Key key,
    this.onUserSelect,
    this.onInviteSelect,
  }) : super(key: key);

  @override
  _AdminUserAddState createState() => _AdminUserAddState();
}

class _AdminUserAddState extends State<AdminUserAdd> {
  TextEditingController _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  AdminRole _adminRoleSelected;
  String userName = '';

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<bool> usercheckProcess() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['email'] = _idController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('HackathonMini/GetUserByEmail', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      userName =
          '${response['result']['user_firstname']} ${response['result']['user_lastname']}';
      return true;
    } else {
      return false;
    }
  }

  userAddProcess() {
    usercheckProcess().then((value) {
      Navigator.pop(context);
      if (value) {
        widget.onUserSelect(
            {'role': _adminRoleSelected.value, 'email': _idController.text});
      } else {
        widget.onInviteSelect(_idController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<AdminRole>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select admin role',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: const OutlineInputBorder(),
                ),
                value: _adminRoleSelected,
                icon: Icon(Icons.arrow_downward),
                items: AdminRole.adminRoles
                    .map<DropdownMenuItem<AdminRole>>((AdminRole value) {
                  return DropdownMenuItem<AdminRole>(
                    value: value,
                    child: Text(
                      value.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Admin role required';
                  }
                  return null;
                },
                onChanged: (AdminRole newValue) {
                  setState(() {
                    _adminRoleSelected = newValue;
                  });
                },
              ),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Email',
                    helperText: userName),
                onChanged: (newInput) {
                  if (Validator.isEmail(newInput)) {
                    usercheckProcess();
                  }
                },
                validator: (value) {
                  if (!Validator.isEmail(value)) {
                    return 'Email required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  child: Text('ADD'),
                  onPressed: () {
                    setState(() {
                      enableAutoValidate = true;
                    });
                    if (_formKey.currentState.validate()) {
                      userAddProcess();
                    }
                  })
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
