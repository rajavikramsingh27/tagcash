import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/handlers/logout_handler.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/live_switch_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class LiveSwithScreen extends StatefulWidget {
  @override
  _LiveSwithScreenState createState() => _LiveSwithScreenState();
}

class _LiveSwithScreenState extends State<LiveSwithScreen> {
  @override
  void initState() {
    super.initState();

    switchApiServer();
  }

  switchApiServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    AppConstants.setProductionFlavor();
    prefs.remove('usebetaurl');

    Map<String, dynamic> liveTokenObj = AppConstants.liveTokenData;

    AppConstants.accessToken = liveTokenObj['access'];
    prefs.setString('access_token', liveTokenObj['access']);

    AppConstants.refreshToken = liveTokenObj['refresh'];
    prefs.setString('refresh_token', liveTokenObj['refresh']);

    prefs.setInt('expires_time', liveTokenObj['expires']);

    AppConstants.demoStartTime = null;
    Provider.of<LiveSwitchProvider>(context, listen: false).stopShowLive();

    profileUserDetailsLoad();
  }

  void profileUserDetailsLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('user/profile');

    if (response['status'] == 'success') {
      UserData userData = UserData.fromJson(response['result']);

      Provider.of<UserProvider>(context, listen: false).setUserData(userData);

      Stripe.init(AppConstants.stripePublishableKeyLive,
          returnUrlForSca: AppConstants.getScaReturnUrl());

      goToHomePage();
    } else {
      logoutClicked();
    }
  }

  void logoutClicked() async {
    LogoutHandler logoutHandler = LogoutHandler();
    logoutHandler.logout(context);
  }

  goToHomePage() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 56,
            color: Colors.black,
          ),
          Expanded(child: Container(child: Center(child: Loading()))),
        ],
      ),
    );
  }
}
