import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/manage_module/manage_module_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/merchant_profile_header.dart';
import 'package:tagcash/components/user_profile_header.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/handlers/logout_handler.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/live_switch_provider.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

import 'package:tagcash/screens/user_swith_screen.dart';
import 'package:tagcash/screens/demo_swith_screen.dart';
import 'package:tagcash/screens/live_swith_screen.dart';

class AppDrawer extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const AppDrawer({
    Key key,
    this.mainNavigatorKey,
  }) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String activeServer = '';
  bool showDemoSwitch = false;
  bool showLiveSwitch = false;
  bool showDeviceLink = false;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();

    _initPackageInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (AppConstants.demoStartTime != null) {
      var currentTime = DateTime.now();
      var diff = currentTime.difference(AppConstants.demoStartTime).inMinutes;
      if (diff < 15) {
        showLiveSwitch = true;
      }
    }

    if (AppConstants.getServer() == 'beta') {
      activeServer = getTranslated(context, 'demo');
    }

    setState(() {});
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

  void demoSwitchClicked() {
    Navigator.pushReplacement(
      widget.mainNavigatorKey != null
          ? widget.mainNavigatorKey.currentContext
          : context,
      MaterialPageRoute(
        builder: (context) => DemoSwithScreen(),
      ),
    );
  }

  void liveSwitchClicked() {
    if (AppConstants.demoStartTime != null) {
      var currentTime = DateTime.now();
      var diff = currentTime.difference(AppConstants.demoStartTime).inMinutes;
      if (diff < 15) {
        Navigator.pushReplacement(
          widget.mainNavigatorKey != null
              ? widget.mainNavigatorKey.currentContext
              : context,
          MaterialPageRoute(
            builder: (context) => LiveSwithScreen(),
          ),
        );
      } else {
        AppConstants.demoStartTime = null;
      }
    }
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

  void subMerchantClicked() {
    //subMerchant Possible -  if merchent verified
    if (Provider.of<MerchantProvider>(context, listen: false)
        .merchantData
        .kycVerified) {
      Navigator.pushNamed(
          widget.mainNavigatorKey != null
              ? widget.mainNavigatorKey.currentContext
              : context,
          '/submerchant');
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'kyc'),
          message: getTranslated(context, 'kyc_verification_required'));
    }
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
                            !userPerspective
                                ? menuListTile(
                                    context,
                                    getTranslated(
                                        context, 'switch_to_personal_mode'),
                                    Icons.account_circle, () {
                                    userSwitchClicked();
                                  })
                                : SizedBox(),
                            if (userPerspective) ...[
                              menuListTile(
                                  context,
                                  getTranslated(context, 'switch_to_business'),
                                  Icons.list, () {
                                Navigator.pushNamed(
                                    widget.mainNavigatorKey != null
                                        ? widget.mainNavigatorKey.currentContext
                                        : context,
                                    '/merchants');
                              }),
                              menuListTile(
                                  context,
                                  getTranslated(context, 'people'),
                                  Icons.perm_contact_calendar, () {
                                Navigator.pushNamed(
                                    widget.mainNavigatorKey != null
                                        ? widget.mainNavigatorKey.currentContext
                                        : context,
                                    '/contacts');
                              }),
                              menuListTile(
                                  context,
                                  getTranslated(context, 'businesses'),
                                  FontAwesomeIcons.building, () {
                                Navigator.pushNamed(
                                    widget.mainNavigatorKey != null
                                        ? widget.mainNavigatorKey.currentContext
                                        : context,
                                    '/allbusiness');
                              }),
                              menuListTile(
                                  context,
                                  getTranslated(context, 'my_memberships'),
                                  FontAwesomeIcons.addressCard, () {
                                Navigator.pushNamed(
                                    widget.mainNavigatorKey != null
                                        ? widget.mainNavigatorKey.currentContext
                                        : context,
                                    '/memberships');
                              }),
                            ],
                            if (!userPerspective) ...[
                              menuListTile(
                                  context,
                                  getTranslated(context, 'member_list'),
                                  FontAwesomeIcons.users, () {
                                Navigator.pushNamed(
                                    widget.mainNavigatorKey != null
                                        ? widget.mainNavigatorKey.currentContext
                                        : context,
                                    '/members');
                              }),
                              // menuListTile(context, getTranslated(context, 'sub_business'), Icons.people,
                              //     () {
                              //   subMerchantClicked();
                              // }),
                              menuListTile(
                                  context,
                                  getTranslated(context, 'roles'),
                                  Icons.person_outline, () {
                                Navigator.pushNamed(
                                    widget.mainNavigatorKey != null
                                        ? widget.mainNavigatorKey.currentContext
                                        : context,
                                    '/role');
                              }),
                              menuListTile(
                                  context,
                                  getTranslated(context, 'advertising'),
                                  Icons.perm_media, () {
                                Navigator.pushNamed(
                                    widget.mainNavigatorKey != null
                                        ? widget.mainNavigatorKey.currentContext
                                        : context,
                                    '/advertising');
                              }),
                            ],
                            menuListTile(
                                context,
                                getTranslated(context, 'manage_mini_programs'),
                                Icons.dynamic_feed_outlined, () {
                              Navigator.push(
                                widget.mainNavigatorKey != null
                                    ? widget.mainNavigatorKey.currentContext
                                    : context,
                                MaterialPageRoute(
                                    builder: (context) => ManageModuleScreen()),
                              );
                            }),
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
                            userPerspective &&
                                    AppConstants.getServer() == 'live'
                                ? menuListTile(
                                    context,
                                    getTranslated(
                                        context, 'switch_to_developer_mode'),
                                    Icons.code, () {
                                    demoSwitchClicked();
                                  })
                                : SizedBox(),
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
                    Provider.of<LiveSwitchProvider>(context).showLive
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              child: Text(getTranslated(
                                  context, 'switch_back_to_live')),
                              onPressed: () => liveSwitchClicked(),
                            ),
                          )
                        : SizedBox(),
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
                                    AppConstants.getServer() == 'beta'
                                        ? getTranslated(context, 'demo')
                                        : '',
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
