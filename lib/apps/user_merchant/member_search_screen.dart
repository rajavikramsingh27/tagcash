import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/models/member.dart';
import 'package:tagcash/apps/user_merchant/user_detail_merchant_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

import 'package:tagcash/models/app_constants.dart' as AppConstants;

class MemberSearchScreen extends StatefulWidget {
  @override
  _MemberSearchScreenState createState() => _MemberSearchScreenState();
}

class _MemberSearchScreenState extends State<MemberSearchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  StreamController<List<Member>> _streamcontroller;
  List<Member> _memberList;
  final scrollController = ScrollController();
  bool hasMore;
  bool _isLoading;
  bool _inviteProcessing = false;
  bool searchLoaded = false;

  bool enableAutoValidate = false;
  TextEditingController _emailController;
  TextEditingController _firstnameController;
  TextEditingController _lastnameController;

  int _inviteOptionValue = 0;

  @override
  void initState() {
    super.initState();
    _memberList = <Member>[];
    _streamcontroller = StreamController<List<Member>>.broadcast();

    _emailController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();

    _isLoading = false;
    hasMore = true;

    loadMembersList();

    scrollController.addListener(() {
      if (!searchLoaded) {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          loadMembersList();
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
  }

  searchClicked(String searchKey) {
    if (searchKey == '') {
      loadMembersList(clearCachedData: true);
    } else {
      _memberList = <Member>[];
      _streamcontroller.add(_memberList);
      hasMore = true;

      searchListLoad(searchKey);
    }
  }

  loadMembersList({bool clearCachedData = false}) {
    searchLoaded = false;

    if (clearCachedData) {
      _memberList = <Member>[];
      _streamcontroller.add(_memberList);

      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    memberListLoad().then((res) {
      _isLoading = false;
      _memberList.addAll(res);
      hasMore = (res.length == 20);

      _streamcontroller.add(_memberList);
    });
  }

  Future<List<Member>> memberListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['count'] = '20';
    apiBodyObj['offset'] = _memberList.length.toString();

    String roleType = Provider.of<MerchantProvider>(context, listen: false)
        .merchantData
        .roleType;
    String url;
    if (roleType == 'owner') {
      url = 'community/AllMembers';
    } else {
      url = 'community/members';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(url, apiBodyObj);

    List responseList = response['result'];

    List<Member> getData = responseList.map<Member>((json) {
      return Member.fromJson(json);
    }).toList();

    return getData;
  }

  void searchListLoad(String searchKey) async {
    bool searchMail = false;
    Map<String, String> apiBodyObj = {};
    if (Validator.isMobile(searchKey)) {
      apiBodyObj['mobile'] = searchKey;
    } else if (Validator.isEmail(searchKey)) {
      searchMail = true;
      apiBodyObj['email'] = searchKey;
    } else if (Validator.isNumber(searchKey)) {
      apiBodyObj['id'] = searchKey;
    } else {
      apiBodyObj['name'] = searchKey;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      hasMore = false;
    });

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];

      List<Member> getData = responseList.map<Member>((json) {
        return userDataToMember(json);
      }).toList();

      if (getData.length == 1) {
        onUsersClickHandle(getData[0]);
      } else {
        searchLoaded = true;

        _memberList.addAll(getData);
        _streamcontroller.add(_memberList);
      }
    } else {
      if (searchMail) {
        showNewUserAdd(searchKey);
      } else {
        showSnackBar(getTranslated(context, 'expense_no_data_fount'));
      }
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

  void onUsersClickHandle(Member member) {
    Map<String, dynamic> userData = {};
    userData['id'] = member.id;
    userData['name'] = member.userFirstname + ' ' + member.userLastname;
    userData['user_firstname'] = member.userFirstname;
    userData['user_lastname'] = member.userLastname;
    userData['rating'] = member.rating;
    userData['role'] = {};
    userData['role']['role_id'] = member.roleId;
    userData['role']['role_name'] = member.roleName;
    userData['role']['role_type'] = member.roleType;
    userData['role']['role_status'] = member.roleStatus;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailMerchantScreen(
          userData: userData,
        ),
      ),
    ).whenComplete(() => loadMembersList(clearCachedData: true));
  }

  void showNewUserAdd(String email) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Form(
                        key: _formKey,
                        autovalidateMode: enableAutoValidate
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              getTranslated(context, 'email_not_found'),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                            RadioListTile(
                              title: Text(
                                getTranslated(context, 'send_email_invite'),
                              ),
                              value: 0,
                              groupValue: _inviteOptionValue,
                              onChanged: (value) {
                                setModalState(() {
                                  _inviteOptionValue = value;
                                });
                              },
                            ),
                            RadioListTile(
                              title: Text(
                                getTranslated(context, 'add_and_send_email'),
                              ),
                              value: 1,
                              groupValue: _inviteOptionValue,
                              onChanged: (value) {
                                setModalState(() {
                                  _inviteOptionValue = value;
                                });
                              },
                            ),
                            Text(getTranslated(context, 'email')),
                            Text(email,
                                style: Theme.of(context).textTheme.subtitle1),
                            TextFormField(
                              controller: _firstnameController,
                              autofocus: false,
                              decoration: InputDecoration(
                                labelText: getTranslated(context, 'first_name'),
                              ),
                              validator: (value) {
                                if (!Validator.isRequired(value)) {
                                  return getTranslated(
                                      context, 'valid_first_name');
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _lastnameController,
                              autofocus: false,
                              decoration: InputDecoration(
                                labelText: getTranslated(context, 'last_name'),
                              ),
                              validator: (value) {
                                if (!Validator.isRequired(value)) {
                                  return getTranslated(
                                      context, 'valid_last_name');
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  enableAutoValidate = true;
                                });
                                if (_formKey.currentState.validate()) {
                                  addNewUserConfirmClickHandler(email);
                                }
                              },
                              child: Text(
                                _inviteOptionValue == 0
                                    ? getTranslated(context, 'invite')
                                    : getTranslated(context, 'add'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _inviteProcessing ? Center(child: Loading()) : SizedBox(),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void addNewUserConfirmClickHandler(String email) async {
    setState(() {
      _inviteProcessing = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['user_firstname'] = _firstnameController.text;
    apiBodyObj['user_lastname'] = _lastnameController.text;

    String apiUrl;
    if (_inviteOptionValue == 1) {
      apiBodyObj['user_email'] = email;
      apiUrl = 'user/createUser';
    } else {
      apiBodyObj['email'] = email;
      apiBodyObj['email_required_status'] = "0";
      apiUrl = 'contact/invite';
    }
    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);

    setState(() {
      _inviteProcessing = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context);

      if (_inviteOptionValue == 1) {
        showSnackBar(getTranslated(context, 'user_added'));
      } else {
        showSnackBar(getTranslated(context, 'invitation_sent'));
      }
      _firstnameController.text = '';
      _lastnameController.text = '';
      _inviteOptionValue = 0;
      Navigator.pop(context);
      loadMembersList(clearCachedData: true);
    } else {
      if (_inviteOptionValue == 1) {
        showSnackBar(getTranslated(context, 'adding_user_failed'));
      } else {
        showSnackBar(getTranslated(context, 'sending_invitation_failed'));
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
        onSearch: searchClicked,
        title: getTranslated(context, 'members'),
      ),
      body: StreamBuilder(
        stream: _streamcontroller.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          if (!snapshot.hasData) {
            return Center(child: Loading());
          } else {
            return ListView.separated(
              controller: scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                indent: 70,
              ),
              itemCount: snapshot.data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < snapshot.data.length) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    leading: Image.network(
                      AppConstants.getUserImagePath() +
                          snapshot.data[index].id.toString() +
                          "?kycImage=0",
                    ),
                    title: Text(snapshot.data[index].userFirstname +
                        ' ' +
                        snapshot.data[index].userLastname),
                    subtitle: Text(snapshot.data[index].roleName),
                    onTap: () => onUsersClickHandle(snapshot.data[index]),
                  );
                } else if (hasMore) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return SizedBox();
                }
              },
            );
          }
        },
      ),
    );
  }
}
