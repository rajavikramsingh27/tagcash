import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:tagcash/apps/user_merchant/user_detail_user_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/services/networking.dart';

import 'contacts_invite_screen.dart';

class ContactsAddressBookScreen extends StatefulWidget {
  final Stream<Map<String, dynamic>> stream;

  const ContactsAddressBookScreen({Key key, this.stream}) : super(key: key);

  @override
  _ContactsAddressBookScreen createState() => _ContactsAddressBookScreen();
}

class _ContactsAddressBookScreen extends State<ContactsAddressBookScreen> {
  StreamSubscription<Map<String, dynamic>> searchStreamSubscription;

  StreamController<List<Contact>> _streamcontroller;
  List<Contact> contacts;
  bool isLoading = false;

  int totalContacts = 0;
  int loadedContacts = 0;

  @override
  void initState() {
    super.initState();
    contacts = List<Contact>();
    _streamcontroller = StreamController<List<Contact>>.broadcast();

    getContactPermission();

    searchStreamSubscription = widget.stream.listen((value) {
      if (value['tab'] == 1) {
        if (totalContacts == loadedContacts) {
          filterContacts(value['search']);
        }
      }
    });
  }

  @override
  void dispose() {
    searchStreamSubscription.cancel();
    super.dispose();
  }

  void getContactPermission() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      print("permission granted");
      getContacts();
    } else {
      print("permission denied");
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  void getContacts() async {
    contacts = <Contact>[];

    Contacts.getTotalContacts().then((value) {
      totalContacts = value;
    });

    Contacts.streamContacts().forEach((contact) {
      // print("${contact.displayName}");
      loadedContacts++;
      Contact newContact = contact;

      bool addContact = true;
      if (newContact.displayName == null) {
        addContact = false;
      }

      if (newContact.phones.isEmpty) {
        addContact = false;
      } else {
        String phoneNo = flattenPhoneNumber(contact.phones[0].value);
        if (phoneNo.length < 10) {
          addContact = false;
        }
      }

      if (addContact) {
        contacts.add(contact);
        _streamcontroller.add(contacts);
      }
    });
  }

  void filterContacts(String searchKey) async {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);

    if (searchKey == '') {
      _streamcontroller.add(contacts);
    } else {
      String searchTerm = searchKey.toLowerCase();
      String searchTermFlatten = flattenPhoneNumber(searchTerm);

      _contacts.retainWhere((contact) {
        if (contact.displayName == null) {
          return false;
        }

        String contactName = contact.displayName.toLowerCase();
        if (contactName.contains(searchTerm)) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    _streamcontroller.add(_contacts);
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  void phoneContactClicked(Contact contact) async {
    if (contact.phones.isEmpty) {
      return;
    }

    String phoneNo = flattenPhoneNumber(contact.phones[0].value);
    if (phoneNo.length < 10) {
      return;
    }

    String email = '';
    if (contact.emails.isNotEmpty) {
      email = contact.emails[0].value;
    }
    String firstName = contact.givenName ?? '';
    String lastName = contact.familyName ?? '';

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['mobile'] = phoneNo.substring(phoneNo.length % 10);

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailUserScreen(
            userData: responseList[0],
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactsInviteScreen(
              email: email, firstName: firstName, lastName: lastName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
            stream: _streamcontroller.stream,
            builder:
                (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        indent: 70,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        Contact contact = snapshot.data[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: contact.avatar != null
                                ? MemoryImage(contact.avatar)
                                : null,
                            child: contact.avatar == null
                                ? Text(contact.initials())
                                : SizedBox(),
                          ),
                          title: Text(contact.displayName ?? ''),
                          onTap: () => phoneContactClicked(contact),
                        );
                      },
                    )
                  : Center(child: Loading());
            },
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
