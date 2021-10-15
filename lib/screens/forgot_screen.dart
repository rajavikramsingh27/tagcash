import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/app_logo.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/login_input.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/services/networking.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  TextEditingController _emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void resetPressed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_emailController.text == '') {
      return;
    }

    setState(() {
      isLoading = true;
    });

    AppConstants.setProductionFlavor();
    String registerEmailData;
    List emailValueInputList = _emailController.text.split('/');
    if (emailValueInputList.length > 1) {
      if (emailValueInputList[1] == "beta" ||
          emailValueInputList[1] == "demo") {
        AppConstants.setDevelopmentFlavor();
        prefs.setBool('usebetaurl', true);
        registerEmailData = emailValueInputList[0];
      }
    } else {
      prefs.remove('usebetaurl');

      registerEmailData = _emailController.text;
    }

    Map<String, dynamic> response = await NetworkHelper.forgotPassword(
      registerEmailData,
    );

    if (response['status'] == 'success') {
      prefs.setString('email', _emailController.text);
      confirmAlertShow();
    } else {
      setState(() {
        isLoading = false;
      });

      if (response['result'] == "noNetwok") {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'unable_process_try_again'));
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'forgot_not_registered_user'));
      }
    }
  }

  confirmAlertShow() {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, 'reset_password')),
            content: Text(getTranslated(context, 'forgot_link_sent_success')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  backToLogin();
                },
                child: Text(getTranslated(context, 'ok')),
              ),
            ],
          );
        });
  }

  backToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Container(
        margin: EdgeInsets.fromLTRB(40, 20, 50, 10),
        child: Column(
          children: [
            AppLogo(),
            LoginInput(
              controller: _emailController,
              icon: Icons.alternate_email,
              hintText: getTranslated(context, 'email'),
              obscureText: false,
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
                        resetPressed();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                          child: Text(
                        getTranslated(context, 'reset_password'),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),
                    ),
            ),
            SizedBox(height: 20),
            Text(
              getTranslated(context, 'forgot_view_text'),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
