import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/live_switch_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DemoSwithScreen extends StatefulWidget {
  @override
  _DemoSwithScreenState createState() => _DemoSwithScreenState();
}

class _DemoSwithScreenState extends State<DemoSwithScreen> {
  @override
  void initState() {
    super.initState();

    switchApiServer();
  }

  switchApiServer() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('perspective/CreateBetaAccessToken');

    if (response['status'] == 'success') {
      logedInDataProcess(response['result']);
    } else {
      goToHomePage();
    }
  }

  void logedInDataProcess(resultData) async {
    Provider.of<PerspectiveProvider>(context, listen: false)
        .setActivePerspective('user');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> liveTokenObj = {};
    liveTokenObj['access'] = AppConstants.accessToken;
    liveTokenObj['refresh'] = AppConstants.refreshToken;
    liveTokenObj['expires'] = prefs.getInt('expires_time');
    AppConstants.liveTokenData = liveTokenObj;

    AppConstants.setDevelopmentFlavor();
    prefs.setBool('usebetaurl', true);

    AppConstants.accessToken = resultData['access_token'];
    prefs.setString('access_token', resultData['access_token']);

    AppConstants.refreshToken = resultData['refresh_token'];
    prefs.setString('refresh_token', resultData['refresh_token']);

    int nowTimeSec = DateTime.now().millisecondsSinceEpoch;
    int expiresTime = nowTimeSec + (resultData['expires_in'] * 1000);
    prefs.setInt('expires_time', expiresTime);

    AppConstants.demoStartTime = DateTime.now();

    profileUserDetailsLoad();
  }

  void profileUserDetailsLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('user/profile');

    if (response['status'] == 'success') {
      UserData userData = UserData.fromJson(response['result']);

      Provider.of<UserProvider>(context, listen: false).setUserData(userData);
      Provider.of<LiveSwitchProvider>(context, listen: false).startShowLive();
      Stripe.init(AppConstants.stripePublishableKeyTest,
          returnUrlForSca: AppConstants.getScaReturnUrl());
      goToHomePage();
    } else {
      resetToLive();
    }
  }

  resetToLive() async {
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

    goToHomePage();
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
