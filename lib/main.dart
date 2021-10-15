import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/app_theme.dart';
import 'package:tagcash/apps/advertising/advert_created_list_screen.dart';
import 'package:tagcash/apps/chat/screens/ChatScreen.dart';
import 'package:tagcash/apps/chat/screens/Profile.dart';
import 'package:tagcash/apps/kyc_merchant/kyc_merchat_verification.dart';
import 'package:tagcash/apps/user_merchant/member_search_screen.dart';
import 'package:tagcash/apps/user_merchant/memberships_screen.dart';
import 'package:tagcash/apps/user_merchant/merchants_list_screen.dart';
import 'package:tagcash/apps/user_merchant/roles_screen.dart';
import 'package:tagcash/apps/user_merchant/sub_merchant_screen.dart';
import 'package:tagcash/apps/user_merchant/community_list_screen.dart';
import 'package:tagcash/apps/wallet/wallet_user_screen.dart';
import 'package:tagcash/localization/app_localizations.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/events.dart';
import 'package:tagcash/providers/live_switch_provider.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/panel_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/screens/forgot_screen.dart';
import 'package:tagcash/screens/home_module_screen.dart';
import 'package:tagcash/screens/home_user_screen.dart';
import 'package:tagcash/screens/home_white_screen.dart';
import 'package:tagcash/screens/landing_screen.dart';
import 'package:tagcash/screens/login_screen.dart';
import 'package:tagcash/screens/qr_scan_screen.dart';
import 'package:tagcash/screens/register_screen.dart';
import 'package:tagcash/screens/settings_manage_screen.dart';
import 'package:tagcash/utils/eventBus_utils.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:tagcash/panel/panel_area.dart';
import 'package:tagcash/panel/left_menu.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/login_provider.dart';

import 'apps/kyc_user/user_verification_screen.dart';
import 'handlers/push_nofitications.dart';
import 'apps/contacts/contacts_manage_screen.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

import 'package:tagcash/apps/crypto_wallet/crypto_wallet_screen.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_backup_screen.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_home_screen.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_import_wallet.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_login_page.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_phrase_recover_screen.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_confirm_phrase_screen.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_single_dasboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  configureApp();

  if (kIsWeb) {
    FacebookAuth.i.webInitialize(
      appId: "191470321646938",
      cookie: true,
      xfbml: true,
      version: "v9.0",
    );
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<PerspectiveProvider>(
        create: (context) => PerspectiveProvider()),
    ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
    ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider()),
    ChangeNotifierProvider<MerchantProvider>(
        create: (context) => MerchantProvider()),
    ChangeNotifierProvider<LoginProvider>(create: (context) => LoginProvider()),
    ChangeNotifierProvider<LayoutProvider>(
        create: (context) => LayoutProvider()),
    ChangeNotifierProvider<LiveSwitchProvider>(
        create: (context) => LiveSwitchProvider()),
    // ChangeNotifierProvider<PanelProvider>(create: (context) => PanelProvider()),
  ], child: MyApp()));
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _sub;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  PushNotificationsManager pushNotificationsManager =
      PushNotificationsManager();

  final ValueNotifier<int> _layoutNumber = ValueNotifier<int>(0);

  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();

    initUniLinks();
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    pushNotificationsManager.listen(navigatorKey);

    getActiveTheme();

    registerEvents();

    super.didChangeDependencies();
  }

  void getActiveTheme() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool isDark = _prefs.getBool('isDarkMode') ?? false;

    Provider.of<ThemeProvider>(context, listen: false).updateTheme(isDark);
  }

  Future<void> initUniLinks() async {
    try {
      Uri initialUri = await getInitialUri();
      print('initial uri: ');
      print(initialUri?.host);
      print(initialUri?.origin);
      print(initialUri?.pathSegments);

      String loadingHost = initialUri?.host;

      if (loadingHost != 'localhost' &&
          loadingHost.indexOf('tagcash.com') == -1) {
        handleCustomMerchentUrl(initialUri?.host);
      } else {
        if (initialUri?.path != null) {
          String pathString = initialUri?.path;
          if (pathString.length > 1) {
            handleUserMerchentSite(pathString);
          }
        }
      }
    } on PlatformException {
      print('Failed to get initial uri.');
    } on FormatException {
      print('Bad parse the initial link as Uri.');
    }

    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri uri) {
        print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
      }, onError: (Object err) {
        print('got err: $err');
      });
    }
  }

  handleUserMerchentSite(String path) {
    if (path[1] == '@') {
      String siteOwnerUser = path.substring(2, path.length);
      AppConstants.siteOwner = siteOwnerUser;
      AppConstants.appHomeMode = 'usersite';
    } else if (path[1].toLowerCase() == 'm') {
      String siteOwnerUser = path.substring(3, path.length);
      AppConstants.siteOwner = siteOwnerUser;
      AppConstants.appHomeMode = 'module';
    } else {
      String siteOwnerMerchant = path.substring(1, path.length);
      if (Validator.isNumber(siteOwnerMerchant)) {
        AppConstants.siteOwner = siteOwnerMerchant;
        AppConstants.appHomeMode = 'whitelabel';
      }
    }
  }

  handleCustomMerchentUrl(String host) {
    AppConstants.siteOwner = host;
    AppConstants.appHomeMode = 'whitelabel';
  }

  bool gotSizeChangedNotification(SizeChangedLayoutNotification notification) {
    setLayoutMode();

    return true;
  }

  setLayoutMode() {
    int layoutMode = 0;

    double screenWidth = MediaQuery.of(navigatorKey.currentContext).size.width;
    if (screenWidth > 1024) {
      layoutMode = 3;
    } else if (screenWidth > 744) {
      layoutMode = 2;
    } else if (screenWidth > 430) {
      layoutMode = 1;
    } else {
      layoutMode = 0;
    }

    if (_layoutNumber.value != layoutMode) {
      Future.delayed(Duration(milliseconds: 100), () {
        _layoutNumber.value = layoutMode;
      });

      Provider.of<LayoutProvider>(context, listen: false)
          .setLauoutMode(layoutMode);
    }
  }

  void registerEvents() {
    EventBusUtils.getInstance().on<ProfileClickedEvent>().listen((event) {
      print(event.profileData['title']);
      Navigator.push(
        navigatorKey.currentContext,
        MaterialPageRoute(
          builder: (context) => Profile(
            withUser: event.profileData['withUser'],
            title: event.profileData['title'],
            bloc: event.profileData['bloc'],
            me: event.profileData['me'],
          ),
        ),
      );
    });
    EventBusUtils.getInstance().on<LayoutRefreshEvent>().listen((event) {
      print('LayoutRefreshEvent ----------------');

      setLayoutMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
        ),
      );
    } else {
      return OverlaySupport(
        child: NotificationListener<SizeChangedLayoutNotification>(
          onNotification: gotSizeChangedNotification,
          child: SizeChangedLayoutNotifier(
            //  key: _filterBarChangeKey,
            child: Container(
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.black
                  : Colors.white,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 1280),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      ValueListenableBuilder(
                        builder:
                            (BuildContext context, int value, Widget child) {
                          return value >= 1
                              ? LeftMenu(
                                  mainNavigatorKey: navigatorKey,
                                  layoutMode: value,
                                )
                              : SizedBox();
                        },
                        valueListenable: _layoutNumber,
                      ),
                      Expanded(
                        child: ChangeNotifierProvider(
                          create: (context) => PanelProvider(),
                          child: MaterialApp(
                            debugShowCheckedModeBanner: false,
                            title: 'TAGCASH',
                            navigatorKey: navigatorKey,
                            theme: AppTheme.lightTheme,
                            darkTheme: AppTheme.darkTheme,
                            themeMode:
                                Provider.of<ThemeProvider>(context).isDarkMode
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
                            localeResolutionCallback:
                                (locale, supportedLocales) {
                              for (var supportedLocale in supportedLocales) {
                                if (supportedLocale.languageCode ==
                                        locale.languageCode &&
                                    supportedLocale.countryCode ==
                                        locale.countryCode) {
                                  return supportedLocale;
                                }
                              }
                              return supportedLocales.first;
                            },
                            initialRoute: '/',
                            routes: {
                              '/': (context) => LoginScreen(),
                              '/home': (context) => LandingScreen(),
                              '/homeuser': (context) => HomeUserScreen(),
                              '/business': (context) => HomeWhiteScreen(),
                              '/homemodule': (context) => HomeModuleScreen(),
                              '/register': (context) => RegisterScreen(),
                              '/forgot': (context) => ForgotScreen(),
                              '/allbusiness': (context) =>
                                  CommunityListScreen(),
                              '/memberships': (context) => MembershipsScreen(),
                              '/merchants': (context) => MerchantsListScreen(),
                              '/settings': (context) => SettingsManageScreen(),
                              '/wallet': (context) => WalletUserScreen(),
                              '/scan': (context) => QrScanScreen(),
                              '/userkyc': (context) => UserVerificationScreen(),
                              '/merchantkyc': (context) =>
                                  MerchantVerifyScreen(),
                              '/members': (context) => MemberSearchScreen(),
                              '/submerchant': (context) => SubMerchantScreen(),
                              '/role': (context) => RolesScreen(),
                              '/contacts': (context) => ContactsManageScreen(),
                              '/advertising': (context) =>
                                  AdvertCreatedListScreen(),
                              '/chat': (context) => ChatScreen(),
                              '/crypto': (context) => CryptoWalletScreen(),
                              '/crypto/backup': (context) =>
                                  CryptoWalletBackupScreen(),
                              '/crypto/recover/phrase': (context) =>
                                  CryptoWalletPhraseRecoverScreen(),
                              '/crypto/confirm/phrase': (context) =>
                                  CryptoWalletConfirmPhraseScreen(),
                              "/crypto/wallet/import": (context) =>
                                  CryptoWalletImportScreen(),
                              "/crypto/wallet/dashboard": (context) =>
                                  CryptoWalletHomeScreen(),
                              "/crypto/wallet/details": (context) =>
                                  CryptoWalletSingleDashboardScreen()
                            },
                          ),
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (context) => PanelProvider(),
                        child: ValueListenableBuilder(
                          builder:
                              (BuildContext context, int value, Widget child) {
                            return value == 3 ? PanelArea() : SizedBox();
                          },
                          valueListenable: _layoutNumber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
