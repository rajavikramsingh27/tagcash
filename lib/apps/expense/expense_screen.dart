import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/components/app_top_bar.dart';

import 'expense_approve_page.dart';
import 'expense_history_page.dart';
import 'expense_requests_page.dart';
import 'expense_settings_page.dart';

class ExpenseScreen extends StatefulWidget {
  _TabBarDemoState createState() => _TabBarDemoState();
}

// with SingleTickerProviderStateMixin
// File _image;
class _TabBarDemoState extends State<ExpenseScreen> {
  bool merchantBo = false;
  List<Tab> tabs = [];

  @override
  void initState() {
    tabs.clear();
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      merchantBo = true;
    } else {
      merchantBo = false;
    }

    if (merchantBo == false) {
      this._addTab();
    } else {
      this._merchantTab();
    }

    super.initState();
  }

  void _merchantTab() {
    setState(() {
      tabs.add(Tab(
        text: "TO APPROVE",
      ));
      tabs.add(Tab(
        text: "EXPENSES",
      ));
      tabs.add(Tab(
        text: "HISTORY",
      ));
      tabs.add(Tab(
        icon: Icon(Icons.settings),
      ));
    });
  }

  void _addTab() {
    setState(() {
      tabs.add(Tab(
        text: "EXPENSES",
      ));
      tabs.add(Tab(
        text: "HISTORY",
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(
            bottom: TabBar(
              tabs: tabs,
              isScrollable: merchantBo,
            ),
          ),
          title: getTranslated(context, "expenses_small"),
        ),
        body: TabBarView(
          children: merchantBo
              ? [
                  ExpenseApprovePage(),
                  ExpenseRequestsPage(),
                  ExpenseHistoryPage(),
                  ExpenseSettingsPage(),
                ]
              : [
                  ExpenseRequestsPage(),
                  ExpenseHistoryPage(),
                ],
        ),
      ),
    );
  }
}
