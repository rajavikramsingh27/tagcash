import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/contacts/contacts_addressbook_screen.dart';
import 'package:tagcash/apps/contacts/contacts_my_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:universal_platform/universal_platform.dart';

class ContactsManageScreen extends StatefulWidget {
  @override
  _ContactsManageScreenState createState() => _ContactsManageScreenState();
}

class _ContactsManageScreenState extends State<ContactsManageScreen>
    with SingleTickerProviderStateMixin {
  StreamController<Map<String, dynamic>> controller =
      StreamController<Map<String, dynamic>>.broadcast();

  List<Tab> contactTabs = [];

  TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    contactTabs = <Tab>[
      Tab(text: getTranslated(context, "contacts_favourites")),
      Tab(text: getTranslated(context, "contacts_addressbook")),
    ];
    _tabController = TabController(vsync: this, length: contactTabs.length);
  }

  searchClicked(String searchKey) {
    controller.add({'tab': _tabController.index, 'search': searchKey});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppTopBar(
          title: getTranslated(context, 'contacts_title'),
          appBar: AppBar(
            bottom: UniversalPlatform.isAndroid
                ? TabBar(
                    controller: _tabController,
                    tabs: contactTabs,
                  )
                : null,
          ),
          onSearch: searchClicked,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ContactsMyScreen(
              stream: controller.stream,
            ),
            ContactsAddressBookScreen(
              stream: controller.stream,
            ),
          ],
        ),
      ),
    );
  }
}
