import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/apps/contacts/model/contact_details.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/apps/contacts/contacts_invite_screen.dart';
import 'package:tagcash/apps/user_merchant/user_detail_user_screen.dart';

class ContactsMyScreen extends StatefulWidget {
  final Stream<Map<String, dynamic>> stream;

  const ContactsMyScreen({Key key, this.stream}) : super(key: key);
  @override
  _ContactsMyScreen createState() => _ContactsMyScreen();
}

class _ContactsMyScreen extends State<ContactsMyScreen> {
  StreamSubscription<Map<String, dynamic>> searchStreamSubscription;

  StreamController<List<ContactDetail>> _streamcontroller;
  final scrollController = ScrollController();

  List<ContactDetail> _data;
  int countApi = 20;
  bool hasMore;
  bool _isLoading;

  String searchKey = '';

  @override
  void initState() {
    super.initState();

    _data = <ContactDetail>[];
    _streamcontroller = StreamController<List<ContactDetail>>.broadcast();
    _isLoading = false;
    hasMore = true;

    loadMoreItems();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        loadMoreItems();
      }
    });

    searchStreamSubscription = widget.stream.listen((value) {
      if (value['tab'] == 0) {
        handleSearch(value['search']);
      }
    });
  }

  @override
  void dispose() {
    searchStreamSubscription.cancel();
    super.dispose();
  }

  void handleSearch(String value) {
    searchKey = value;
    loadMoreItems(clearCachedData: true);
  }

  Future<void> dataRefresh() {
    searchKey = '';
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = <ContactDetail>[];
      _streamcontroller.add(_data);
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    loadContactsList().then((res) {
      _isLoading = false;
      _data.addAll(res);
      hasMore = (res.length == countApi);

      _streamcontroller.add(_data);
    });
  }

  Future<List<ContactDetail>> loadContactsList() async {
    Map<String, String> apiBodyObj = {};

    if (searchKey != '') {
      apiBodyObj['keyword'] = searchKey;
    }
    apiBodyObj['count'] = countApi.toString();
    apiBodyObj['offset'] = _data.length.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('contact/getcontacts', apiBodyObj);

    // if (response['status'] == "success") {
    List responseList = response['result'];
    List<ContactDetail> getData = responseList.map<ContactDetail>((json) {
      return ContactDetail.fromJson(json);
    }).toList();
    return getData;
  }

  void navigateToUserDetailScreen(ContactDetail contactDeta) {
    if (contactDeta.contactId != 0) {
      Map<String, dynamic> userData = {};
      userData['id'] = contactDeta.contactId;
      userData['user_email'] = contactDeta.contactEmail;
      userData['name'] =
          contactDeta.contactFirstname + ' ' + contactDeta.contactLastname;
      userData['user_firstname'] = contactDeta.contactFirstname;
      userData['user_lastname'] = contactDeta.contactLastname;
      userData['contact_status'] = contactDeta.contactStatus.toString();
      userData['rating'] = contactDeta.rating;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailUserScreen(userData: userData),
        ),
      ).then((value) => loadMoreItems(clearCachedData: true));
    }
  }

  void addContactsClickHandler() async {
    final result = await showModalBottomSheet(
        context: context,
        shape: kBottomSheetShape,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AddContact(
              onSendInvite: (email) {
                emailInviteHandle(email);
              },
            ),
          );
        });

    if (result != null) {
      dataRefresh();
    }
  }

  emailInviteHandle(String email) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsInviteScreen(email: email),
      ),
    );

    if (result != null) {
      dataRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addContactsClickHandler();
        },
        child: Icon(Icons.add),
        // backgroundColor: Colors.red,
      ),
      body: RefreshIndicator(
        onRefresh: dataRefresh,
        child: StreamBuilder(
          stream: _streamcontroller.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                      visualDensity: VisualDensity(vertical: -2),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          AppConstants.getUserImagePath() +
                              snapshot.data[index].contactId.toString() +
                              "?kycImage=0",
                        ),
                      ),
                      title: Text(
                        snapshot.data[index].contactFirstname +
                            " " +
                            snapshot.data[index].contactLastname,
                      ),
                      subtitle: Text(
                        snapshot.data[index].memberStatus == 1
                            ? 'ID : ${snapshot.data[index].contactId.toString()}'
                            : '',
                        // : getTranslated(
                        //     context, "contacts_nontagcashmember"),
                      ),
                      onTap: () =>
                          navigateToUserDetailScreen(snapshot.data[index]),
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
      ),
    );
  }
}

class AddContact extends StatefulWidget {
  final Function(String) onSendInvite;
  const AddContact({
    Key key,
    this.onSendInvite,
  }) : super(key: key);

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  TextEditingController _idController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _idController.dispose();

    super.dispose();
  }

  void addContactProcess() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['auto_add_status'] = '1';
    apiBodyObj['email_required_status'] = '1';
    apiBodyObj['email'] = _idController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('contact/Invite', apiBodyObj);

    if (response['status'] == 'success') {
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });

      if (response['error'] == 'contact_already_exists') {
        showSnackBar(getTranslated(context, 'contacts_contactalreadyadded'));
      } else if (response['error'] == 'user_blocked') {
        showSnackBar(getTranslated(context, 'contacts_userblocked'));
      } else if (response['error'] == 'you_cannot_add_own_account') {
        showSnackBar(getTranslated(context, 'contacts_cannot_own_user'));
      } else if (response['error'] == 'invalid_email') {
        showSnackBar(getTranslated(context, 'contacts_invalid_email'));
      } else if (response['error'] == 'user_is_not_a_member_in_tagcash') {
        showSnackBar(getTranslated(context, 'contacts_invalid_user'));
      } else if (response['error'] == 'email_not_found_in_tagcash') {
        Navigator.pop(context);
        widget.onSendInvite(_idController.text);
      }
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: getTranslated(context, 'contacts_idemailmobile'),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(
                    getTranslated(context, 'contacts_addcontact'),
                  ),
                  onPressed: () => addContactProcess(),
                ),
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      ),
    );
  }
}
