import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/identifiers/identifiers_list_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/screens/link_devices_screen.dart';
import 'package:tagcash/screens/settings_screen.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class SettingsManageScreen extends StatefulWidget {
  @override
  _SettingsManageScreenState createState() => _SettingsManageScreenState();
}

class _SettingsManageScreenState extends State<SettingsManageScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  bool devicesPossible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
                .getActivePerspective() ==
            'user' &&
        AppConstants.getServer() == 'live') {
      devicesPossible = true;
    }

    _tabController = TabController(
      vsync: this,
      length: devicesPossible ? 3 : 2,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: getTranslated(context, "settings")),
              Tab(text: getTranslated(context, "identifiers")),
              if (devicesPossible) Tab(text: getTranslated(context, "devices")),
            ],
          ),
        ),
        title: getTranslated(context, 'settings'),
      ),
      body: TabBarView(controller: _tabController, children: <Widget>[
        SettingsScreen(),
        IdentifiersListScreen(),
        if (devicesPossible) LinkDevicesScreen(),
      ]),
    );
  }
}
