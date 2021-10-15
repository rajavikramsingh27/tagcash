import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/app_theme.dart';
import 'package:tagcash/apps/chat/screens/ChatScreen.dart';
import 'package:tagcash/apps/chat/screens/ConversationScreen.dart';
import 'package:tagcash/localization/app_localizations.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/events.dart';
import 'package:tagcash/providers/login_provider.dart';
import 'package:tagcash/providers/panel_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/utils/eventBus_utils.dart';

class PanelArea extends StatefulWidget {
  const PanelArea({Key key}) : super(key: key);

  @override
  _PanelAreaState createState() => _PanelAreaState();
}

class _PanelAreaState extends State<PanelArea> {
  final GlobalKey<NavigatorState> navigatorKeyPanel =
      GlobalKey<NavigatorState>();

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

    Provider.of<PanelProvider>(context, listen: false).setPanelName('right');

    EventBusUtils.getInstance().on<ChatClickedEvent>().listen((event) {
      print(event.userData['name']);
      Navigator.push(
        navigatorKeyPanel.currentContext,
        MaterialPageRoute(
          builder: (context) =>
              ConversationScreen(source: 'tagcash', data: event.userData),
        ),
      );
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<LoginProvider>(context).isLogedin
        ? SizedBox(
            width: 360,
            child: Stack(
              textDirection: TextDirection.ltr,
              children: [
                MaterialApp(
                  debugShowCheckedModeBanner: false,
                  navigatorKey: navigatorKeyPanel,

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
                  // initialRoute: '/',
                  // routes: {
                  //   '/': (context) => Container(),
                  //   '/chat': (context) => ChatScreen(),
                  // },
                  home: PanelModuleHandle(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 56),
                  child: Container(
                    width: .5,
                    color: Colors.grey.withOpacity(.5),
                  ),
                ),
              ],
            ),
          )
        : SizedBox();
  }
}

class PanelModuleHandle extends StatelessWidget {
  const PanelModuleHandle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatScreen();
    // return Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
    //         'user'
    //     ? ChatScreen()
    //     : MemberSearchScreen();
  }
}
