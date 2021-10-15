import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

import '../bloc/conversation_bloc.dart';

const iOSLocalizedLabels = false;

class ContactPicker extends StatefulWidget {
  final ConversationBloc bloc;
  final int withUser;
  final int me;
  final dynamic currentRoom;

  ContactPicker(this.bloc, this.withUser, this.me, this.currentRoom);
  @override
  _ContactPickerState createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker> {
  Contact _contact;
  bool _hasPermission;
  List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();
    setState(() {
      _contacts = contacts;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus;
    while (permissionStatus != PermissionStatus.granted) {
      try {
        permissionStatus = await _getContactPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _hasPermission = false;
          _handleInvalidPermissions(permissionStatus);
        } else {
          _hasPermission = true;

          refreshContacts();
          _pickContact();
        }
      } catch (e) {
        print('error occured');
      }
    }
  }

  // Future<PermissionStatus> _getContactPermission() async {
  //   final status = await Permission.contacts.status;
  //   if (!status.isGranted) {
  //     final result = await Permission.contacts.request();
  //     return result ?? PermissionStatus.undetermined;
  //   } else {
  //     return status;
  //   }
  // }
   Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }


  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Access to location data denied',
          details: null);
    } else if (permissionStatus == PermissionStatus.restricted) {
      throw PlatformException(
          code: 'PERMISSION_DISABLED',
          message: 'Location data is not available on device',
          details: null);
    }
  }

  Future<void> _pickContact() async {
    try {
      final Contact contact = await ContactsService.openDeviceContactPicker(
          iOSLocalizedLabels: iOSLocalizedLabels);
      Navigator.of(context).pop();
      widget.bloc.convStatus = FutureStatus.pending;
      List<Contact> avatarContacts;
      String avatartB64;
      var contactName = jsonEncode("contactName");
      var contactMobile = jsonEncode("contactMobile");
      var imgUrl;
      if (this.mounted) {
        setState(() {
          _contact = contact;
          avatarContacts = _contacts
              .where((element) => element.displayName == _contact.displayName)
              .toList();
        });
      }

      if (avatarContacts[0].avatar.isNotEmpty) {
        print(avatarContacts[0].avatar);
        avatartB64 = base64Encode(avatarContacts[0].avatar);
        imgUrl = await this.widget.bloc.uploadImage(avatartB64);
      } else {
        imgUrl = '';
      }
      this.widget.bloc.sendMessage({
        "to_tagcash_id": this.widget.withUser,
        "from_tagcash_id": this.widget.me,
        "toDocId": this.widget.withUser,
        'doc_id': imgUrl,
        "convId": this.widget.bloc.currentRoom,
        "type": 5,
        "payload": {
          contactName: jsonEncode(_contact.displayName),
          contactMobile:
              jsonEncode(_contact.phones.map((e) => e.value).toList()[0]),
        }.toString(),
      });
      widget.bloc.convStatus = FutureStatus.fulfilled;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.contact_phone,
        color: Colors.white,
      ),
      title: Text(
        'Contact',
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        print(_hasPermission);
        _askPermissions();
        // refreshContacts();
      },
    );
  }
}
