import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/merchant_profile_header.dart';
import 'package:tagcash/components/user_profile_header.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/handlers/logout_handler.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/screens/admin_swith_screen.dart';

import 'package:tagcash/screens/user_swith_screen.dart';

class AppDrawerBusiness extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const AppDrawerBusiness({
    Key key,
    this.mainNavigatorKey,
  }) : super(key: key);

  @override
  _AppDrawerBusinessState createState() => _AppDrawerBusinessState();
}

class _AppDrawerBusinessState extends State<AppDrawerBusiness> {
  String activeServer = '';
  bool adminUser = false;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();

    if (AppConstants.businessOwner) {
      adminUser = true;
    }

    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void userSwitchClicked() {
    Navigator.pushReplacement(
      widget.mainNavigatorKey != null
          ? widget.mainNavigatorKey.currentContext
          : context,
      MaterialPageRoute(
        builder: (context) => UserSwithScreen(),
      ),
    );
  }

  void adminSwitchClicked() {
    Navigator.pushReplacement(
      widget.mainNavigatorKey != null
          ? widget.mainNavigatorKey.currentContext
          : context,
      MaterialPageRoute(
        builder: (context) => AdminSwithScreen(),
      ),
    );
  }

  void logoutClicked(BuildContext context) {
    LogoutHandler logoutHandler = LogoutHandler();
    logoutHandler.logout(context);
  }

  void themeChange(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Provider.of<ThemeProvider>(context, listen: false).updateTheme(isDark);
    prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child:
          Consumer<PerspectiveProvider>(builder: (context, perspective, child) {
        bool userPerspective =
            perspective.getActivePerspective() == 'user' ? true : false;

        return Container(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    userPerspective
                        ? UserProfileHeader(
                            mainNavigatorKey: widget.mainNavigatorKey)
                        : MerchantProfileHeader(
                            mainNavigatorKey: widget.mainNavigatorKey),
                    Expanded(
                      child: Container(
                        child: ListView(
                          children: [
                            menuListTile(
                                context,
                                getTranslated(context, 'wallet'),
                                Icons.wallet_travel, () {
                              Navigator.pushNamed(
                                  widget.mainNavigatorKey != null
                                      ? widget.mainNavigatorKey.currentContext
                                      : context,
                                  '/wallet');
                            }),
                            adminUser
                                ? menuListTile(
                                    context,
                                    getTranslated(context, 'switch_to_admin'),
                                    Icons.list, () {
                                    adminSwitchClicked();
                                  })
                                : SizedBox(),
                            // menuListTile(context, "My Memberships",
                            //     FontAwesomeIcons.addressCard, () {
                            //   Navigator.pushNamed(
                            //       widget.mainNavigatorKey != null
                            //           ? widget.mainNavigatorKey.currentContext
                            //           : context,
                            //       '/memberships');
                            // }),
                            menuListTile(
                                context,
                                getTranslated(context, 'settings'),
                                Icons.settings, () {
                              Navigator.pushNamed(
                                  widget.mainNavigatorKey != null
                                      ? widget.mainNavigatorKey.currentContext
                                      : context,
                                  '/settings');
                            }),
                            menuListTile(
                                context,
                                getTranslated(context, 'logout'),
                                Icons.logout, () {
                              logoutClicked(widget.mainNavigatorKey != null
                                  ? widget.mainNavigatorKey.currentContext
                                  : context);
                            }),
                          ],
                        ),
                      ),
                    ),
                    Provider.of<LayoutProvider>(context).lauoutMode == 1
                        ? Switch(
                            value:
                                Provider.of<ThemeProvider>(context).isDarkMode,
                            onChanged: (boolVal) => themeChange(boolVal),
                          )
                        : Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.sun,
                                  size: 18,
                                  color: Color(0xFF535353),
                                ),
                                Switch(
                                  value: Provider.of<ThemeProvider>(context)
                                      .isDarkMode,
                                  onChanged: (boolVal) => themeChange(boolVal),
                                ),
                                FaIcon(
                                  FontAwesomeIcons.moon,
                                  size: 18,
                                  color: Color(0xFF535353),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    activeServer,
                                    textAlign: TextAlign.end,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(_packageInfo.version +
                                    ' ' +
                                    _packageInfo.buildNumber),
                              ],
                            ),
                          )
                  ],
                ),
                Positioned(
                  top: 56,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: .5,
                    color: Colors.grey.withOpacity(.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget menuListTile(BuildContext context, String title, IconData icon,
      VoidCallback onMenuClick) {
    return Provider.of<LayoutProvider>(context).lauoutMode == 1
        ? IconButton(
            onPressed: () {
              onMenuClick();
            },
            icon: Icon(
              icon,
            ),
            tooltip: title,
          )
        : ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
            leading: Icon(
              icon,
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            onTap: () {
              if (Navigator.canPop(
                widget.mainNavigatorKey != null
                    ? widget.mainNavigatorKey.currentContext
                    : context,
              )) {
                Navigator.of(
                  widget.mainNavigatorKey != null
                      ? widget.mainNavigatorKey.currentContext
                      : context,
                ).pop();
              }
              onMenuClick();
            },
          );
  }
}
