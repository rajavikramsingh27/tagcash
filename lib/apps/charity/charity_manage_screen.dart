import 'package:flutter/material.dart';

import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/charity/requests_screen.dart';
import 'package:tagcash/apps/charity/donations_screen.dart';
import 'package:tagcash/localization/language_constants.dart';

class CharityManageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppTopBar(
            title: getTranslated(context, "charity"),
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: getTranslated(context, "requests")),
                  Tab(text: getTranslated(context, "donated_upper")),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              RequestsScreen(),
              DonationsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
