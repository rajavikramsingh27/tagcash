import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/app_logo.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/login_input.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  bool _obscureStatus = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void registerPressed() async {
    if (_emailController.text == '' ||
        _passwordController.text == '' ||
        _firstNameController.text == '' ||
        _lastNameController.text == '') {
      return;
    }

    if (!Validator.isEmail(_emailController.text)) {
      showSimpleDialog(
        context,
        title: getTranslated(context, 'error'),
        message: getTranslated(context, 'email_not_valid'),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      showSimpleDialog(
        context,
        title: getTranslated(context, 'error'),
        message: getTranslated(context, 'password_too_short'),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    AppConstants.setProductionFlavor();

    prefs.remove('usebetaurl');
    String registerEmailData = _emailController.text;

    Map<String, dynamic> response = await NetworkHelper.userRegistration(
        registerEmailData,
        _firstNameController.text,
        _lastNameController.text,
        _passwordController.text);

    if (response['status'] == 'success') {
      if (response['result']['user_email'] == "d@gmail.net") {
        Navigator.of(context).pop();
      } else {
        prefs.setString('email', _emailController.text);
        logedInDataProcess(response['result']);
      }
    } else {
      setState(() {
        isLoading = false;
      });

      if (response['error'][0] == "email_exists") {
        _emailController.text = '';
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'email_already_taken'));
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'error_occurred'));
      }
    }
  }

  void logedInDataProcess(resultData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    AppConstants.accessToken = resultData['access_token'];
    prefs.setString('access_token', resultData['access_token']);

    AppConstants.refreshToken = resultData['refresh_token'];
    prefs.setString('refresh_token', resultData['refresh_token']);

    int nowTimeSec = DateTime.now().millisecondsSinceEpoch;
    int expiresTime = nowTimeSec + (resultData['expires_in'] * 1000);
    prefs.setInt('expires_time', expiresTime);

    profileUserDetailsLoad();
  }

  void profileUserDetailsLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('user/profile');

    if (response['status'] == 'success') {
      UserData userData = UserData.fromJson(response['result']);
      Provider.of<PerspectiveProvider>(context, listen: false)
          .setActivePerspective('user');

      Provider.of<UserProvider>(context, listen: false).setUserData(userData);

      goToHomePage();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void backClicked() {
    Navigator.of(context).pop();
  }

  void goToHomePage() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(40, 20, 50, 10),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => backClicked(),
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              AppLogo(),
              LoginInput(
                controller: _emailController,
                icon: Icons.alternate_email,
                hintText: getTranslated(context, 'email'),
                obscureText: false,
              ),
              LoginInput(
                controller: _firstNameController,
                icon: Icons.person_outline,
                hintText: getTranslated(context, 'first_name'),
                obscureText: false,
              ),
              LoginInput(
                controller: _lastNameController,
                icon: Icons.person_outline,
                hintText: getTranslated(context, 'last_name'),
                obscureText: false,
              ),
              LoginInput(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hintText: getTranslated(context, 'password'),
                obscureText: _obscureStatus,
                suffix: IconButton(
                    icon: Icon(
                      _obscureStatus ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureStatus = !_obscureStatus;
                      });
                    }),
              ),
              SizedBox(height: 30),
              AnimatedContainer(
                height: 50,
                width: isLoading ? 50 : 320,
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 6),
                      blurRadius: 12,
                      color: Color(0xFF173347).withOpacity(0.23),
                    ),
                  ],
                ),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ))
                    : GestureDetector(
                        onTap: () {
                          registerPressed();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                            child: Text(
                          getTranslated(context, 'register'),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
