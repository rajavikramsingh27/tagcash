import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/app_theme.dart';
import 'package:tagcash/components/app_drawer.dart';
import 'package:tagcash/components/app_drawer_business.dart';
import 'package:tagcash/localization/app_localizations.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/login_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class LeftMenu extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final int layoutMode;

  const LeftMenu({
    Key key,
    this.mainNavigatorKey,
    this.layoutMode,
  }) : super(key: key);

  @override
  _LeftMenuState createState() => _LeftMenuState();
}

class _LeftMenuState extends State<LeftMenu> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<LoginProvider>(context).isLogedin
        ? SizedBox(
            width: widget.layoutMode == 1 ? 70 : 304,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: Provider.of<ThemeProvider>(context).isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              locale: _locale,
              supportedLocales: [
                Locale('en', 'US'),
                Locale('es', 'SV'),
                Locale('ar', 'SE'),
                Locale('hi', 'IN'),
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode &&
                      supportedLocale.countryCode == locale.countryCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              home: LeftModuleHandle(
                mainNavigatorKey: widget.mainNavigatorKey,
              ),
            ),
          )
        : SizedBox();
  }
}

class LeftModuleHandle extends StatelessWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const LeftModuleHandle({
    Key key,
    this.mainNavigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AppConstants.appHomeMode == 'whitelabel' &&
        Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
            'user') {
      return AppDrawerBusiness(mainNavigatorKey: mainNavigatorKey);
    } else {
      return AppDrawer(mainNavigatorKey: mainNavigatorKey);
    }
  }
}
