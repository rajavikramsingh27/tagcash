import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/providers/live_switch_provider.dart';
import 'package:tagcash/providers/login_provider.dart';
import 'package:tagcash/services/networking.dart';

class LogoutHandler {
  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('access_token');
    prefs.remove('refresh_token');
    prefs.remove('expires_time');

    Provider.of<LoginProvider>(context, listen: false).setLoginStatus(false);

    AppConstants.demoStartTime = null;
    Provider.of<LiveSwitchProvider>(context, listen: false).showLive = false;
    logoutFromServer();

    GoogleSignIn _googleSignIn = GoogleSignIn();
    _googleSignIn.disconnect();

    Navigator.pushNamedAndRemoveUntil(
        context, '/', (Route<dynamic> route) => false);
  }

  void logoutFromServer() async {
    Map<String, dynamic> response = await NetworkHelper.request(
      'oauth/logout',
    );
  }
}
