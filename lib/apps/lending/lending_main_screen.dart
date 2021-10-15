import 'package:flutter/material.dart';

import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/lending/borrowing_screen.dart';
import 'package:tagcash/apps/lending/lending_screen.dart';
import 'package:tagcash/apps/lending/requests_screen.dart';
import 'package:tagcash/localization/language_constants.dart';

//void main() => runApp(MyApp());

class LendingMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppTopBar(
            title: getTranslated(context, "crowd_lending"),
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: getTranslated(context, "requests")),
                  Tab(text: getTranslated(context, "lending")),
                  Tab(text: getTranslated(context, "borrowing")),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              RequestsScreen(),
              LendingScreen(),
              BorrowingScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
