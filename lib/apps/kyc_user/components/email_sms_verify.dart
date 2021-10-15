import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/handlers/logout_handler.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';

class EmailSmsVerify extends StatefulWidget {
  final bool radiomenuShow;
  final int methodIndex;

  const EmailSmsVerify({Key key, this.radiomenuShow, this.methodIndex})
      : super(key: key);

  @override
  _EmailSmsVerifyState createState() => _EmailSmsVerifyState();
}

class _EmailSmsVerifyState extends State<EmailSmsVerify> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  UserData userData;
  bool initialState = true;

  int emailSmsRadioValue = 0;
  String email;
  String mobile = '';
  String callingCode;
  String countryCode;
  String newCallingCode;
  String newCountryCode;

  TextEditingController newEmailInput = TextEditingController();
  TextEditingController newMobileInput = TextEditingController();
  TextEditingController validationSmsCodeInput = TextEditingController();

  @override
  void initState() {
    emailSmsRadioValue = widget.methodIndex;

    super.initState();
  }

  @override
  void dispose() {
    newEmailInput.dispose();
    newMobileInput.dispose();
    validationSmsCodeInput.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    userData = Provider.of<UserProvider>(context, listen: false).userData;
    email = userData.email;
    newEmailInput.text = email;

    mobile = userData.mobile;
    newMobileInput.text = mobile;
    callingCode = userData.countryCallingCode;
    countryCode = userData.countryCode;

    newCallingCode = userData.countryCallingCode;
    newCountryCode = userData.countryId;
  }

  verifyEmailClicked() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('user/resendactivationmail');

    if (response["status"] == "success") {
      Navigator.pop(context);
      var msg = getTranslated(context, "kyc_verify_email");
      showSnackBar(msg);
    } else {
      setState(() {
        isLoading = false;
      });
      var msgError = getTranslated(context, "error_occurred");
      showSnackBar(msgError);
    }
  }

  modifyEmailClick() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['email'] = newEmailInput.text.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('user/updateprofile/', apiBodyObj);

    if (response["status"] == "success") {
      Navigator.pop(context);
      var msg = getTranslated(context, "kyc_email_chaged");
      showSnackBar(msg);
      // Fluttertoast.showToast(msg: message);

      LogoutHandler logoutHandler = LogoutHandler();
      logoutHandler.logout(context);
    } else {
      setState(() {
        isLoading = false;
      });
      var msgError = getTranslated(context, "kyc_email_already_used");
      showSnackBar(msgError);
    }
  }

  void onCountryChange(Map country) {
    String dialCode = country['dial_code'];
    if (dialCode[0] == '+') {
      dialCode = dialCode.substring(1);
    }
    newCallingCode = dialCode;
    newCountryCode = country['id'];
  }

  void verifySmsClicked() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('User/ResendSMSCode');

    isLoading = false;
    if (response["status"] == "success") {
      validationSmsCodeInput.text = '';
      initialState = false;
      var msg = getTranslated(context, "kyc_sms_send");
      showSnackBar(msg);
    } else {
      var msgError = getTranslated(context, "error_occurred");
      showSnackBar(msgError);
    }
    setState(() {});
  }

  void modifyMobileNoClicked() async {
    if (newCountryCode == "" || newMobileInput.text == "") {
      var msg = getTranslated(context, "kyc_enter_valid_number");
      showSnackBar(msg);
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['user_mobile'] = newMobileInput.text;
    apiBodyObj['country_phonecode'] = newCallingCode;
    apiBodyObj['country_id'] = newCountryCode;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/updateprofile/', apiBodyObj);

    isLoading = false;

    if (response["status"] == "success") {
      userData.mobile = newMobileInput.text;
      userData.countryCallingCode = newCallingCode;
      userData.countryId = newCountryCode;

      Provider.of<UserProvider>(context, listen: false).setUserData(userData);

      mobile = userData.mobile;
      callingCode = userData.countryCallingCode;
      var msg = getTranslated(context, "kyc_mobile_updated_sucess");
      showSnackBar(msg);
    } else {
      if (response['error'] == 'Mobile_number_already_used by_someone_else') {
        var msg = getTranslated(context, "kyc_mobile_already_used");
        showSnackBar(msg);
      } else {
        var msg = getTranslated(context, "error_occurred");
        showSnackBar(msg);
      }
    }
    setState(() {});
  }

  void validateSmsCode() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['code'] = validationSmsCodeInput.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/VerifySMSCode', apiBodyObj);

    if (response["status"] == "success") {
      Navigator.pop(context, true);
      var msg = getTranslated(context, "kyc_mobile_verification_completed");
      showSnackBar(msg);
    } else {
      setState(() {
        isLoading = false;
      });
      if (response['error'] == 'code_missmatch') {
        var msg = getTranslated(context, "kyc_code_missmatch");
        showSnackBar(msg);
      } else if (response['error'] == 'mobile_already_verified') {
        var msg = getTranslated(context, "kyc_mobile_already_verified");
        showSnackBar(msg);
      } else {
        var msg = getTranslated(context, "kyc_failed_verify_code");
        showSnackBar(msg);
      }
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _scaffoldKey,
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  getTranslated(context, "kyc_verify_txt"),
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 10),
                widget.radiomenuShow
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                value: 0,
                                title: Text(getTranslated(context, "email")),
                                groupValue: emailSmsRadioValue,
                                onChanged: (value) {
                                  setState(() {
                                    emailSmsRadioValue = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                value: 1,
                                title: Text(getTranslated(context, "mobile")),
                                groupValue: emailSmsRadioValue,
                                onChanged: (value) {
                                  setState(() {
                                    emailSmsRadioValue = value;
                                    // isSendSmsVerificationCode = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                emailSmsRadioValue == 0 ? emailContainer() : smsContainer(),
              ],
            ),
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }

  Widget emailContainer() {
    return Column(
      children: [
        Text(
          getTranslated(context, "email_address"),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(height: 10),
        Text(
          email,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text(getTranslated(context, "send_email_verify")),
          onPressed: verifyEmailClicked,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            getTranslated(context, "or"),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Text(
          getTranslated(context, "modify_linked_email"),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        TextFormField(
          controller: newEmailInput,
          decoration: InputDecoration(
            labelText: getTranslated(context, "email"),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text(getTranslated(context, "modify")),
          onPressed: modifyEmailClick,
        )
      ],
    );
  }

  Widget smsContainer() {
    return initialState
        ? Column(
            children: [
              if (mobile.isEmpty) ...[
                Text(getTranslated(context, "link_phone_number_account"),
                    style: Theme.of(context).textTheme.subtitle1),
              ],
              if (mobile.isNotEmpty) ...[
                Text(getTranslated(context, "phone_number_linked_account_is"),
                    style: Theme.of(context).textTheme.subtitle1),
                SizedBox(height: 10),
                Text('+ $callingCode $mobile',
                    style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(getTranslated(context, "kyc_verify_txt")),
                  onPressed: verifySmsClicked,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    getTranslated(context, "or"),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Text(
                  getTranslated(context, "modify_linked_phone_number"),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: CountriesFormField(
                      // labelText: 'Select country',
                      initialCountryCode: countryCode,
                      showName: false,
                      onChanged: (country) {
                        if (country != null) {
                          onCountryChange(country);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: newMobileInput,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "mobile_number"),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(mobile.isEmpty
                    ? getTranslated(context, "add")
                    : getTranslated(context, "modify")),
                onPressed: modifyMobileNoClicked,
              ),
            ],
          )
        : Column(
            children: [
              Text(
                getTranslated(context, "kyc_sms_verify_code_des_one") +
                    '+' +
                    '$callingCode' +
                    '$mobile.' +
                    getTranslated(context, "kyc_sms_verify_code_des_two"),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: validationSmsCodeInput,
                decoration: InputDecoration(
                  labelText:
                      getTranslated(context, "kyc_sms_verification_code"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: Text(getTranslated(context, "kyc_code_resend")),
                        onPressed: verifySmsClicked,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        child: Text(getTranslated(context, "kyc_verify_txt")),
                        onPressed: validateSmsCode,
                      ),
                    ),
                  ],
                ),
              ),
              // Text(
              //   "If you do not receive your code via SMS",
              //   style: Theme.of(context).textTheme.subtitle1,
              // ),
            ],
          );
  }
}
