import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:tagcash/components/app_logo.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/login_input.dart';
import 'package:tagcash/components/pin_login.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/events.dart';
import 'package:tagcash/models/merchant_data.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/login_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/handlers/push_nofitications.dart';
import 'package:tagcash/screens/validate_white_screen.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tagcash/utils/eventBus_utils.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';
import 'package:web_browser_detect/web_browser_detect.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureStatus = true;
  bool isLoading = false;
  bool isLoadingGoogle = false;
  bool isLoadingFb = false;
  String userEmail = '';

  int activeViewIndex = 0;
  PushNotificationsManager pushNotificationsManager =
      PushNotificationsManager();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  String qrDataString = '';
  String qrUserId = '';

  @override
  void initState() {
    super.initState();

    initPackageInfo();
    initPlatformState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (UniversalPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        AppConstants.deviceId = androidInfo.androidId;
        AppConstants.deviceName =
            '${androidInfo.brand.toUpperCase()} ${androidInfo.model}';
      } else if (UniversalPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        AppConstants.deviceId = iosInfo.identifierForVendor;
        AppConstants.deviceName = iosInfo.name;
      } else if (UniversalPlatform.isWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String uuidString = prefs.getString('uuid');

        if (uuidString == null) {
          var uuid = Uuid();
          uuidString = uuid.v4();
          prefs.setString('uuid', uuidString);
        }

        final browser = Browser.detectOrNull();
        print('${browser?.browser ?? 'Browser'} ${browser?.version ?? ''}');

        AppConstants.deviceId = uuidString;
        AppConstants.deviceName =
            '${browser?.browser ?? 'Browser'} ${browser?.version ?? ''}';
      }
    } on PlatformException {
      //not handled platform
      print('Not handled platform');
      AppConstants.deviceId = '1234567890';
      AppConstants.deviceName = 'Debug';
    }
    checkLoginStatus();
  }

  Future<void> initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    AppConstants.appName =
        "${info.appName} ${info.version} (${info.buildNumber})";
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int lastUserID = prefs.getInt('last_user');

    if (lastUserID != null) {
      String displayData = 'https://tagcash.com/u/$lastUserID';
      setState(() {
        qrDataString = displayData;
        qrUserId = lastUserID.toString();
      });
    }

    String accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      AppConstants.accessToken = accessToken;
      String refreshToken = prefs.getString('refresh_token');
      AppConstants.refreshToken = refreshToken;

      int expiresTime = prefs.getInt('expires_time');
      int nowTimeSec = DateTime.now().millisecondsSinceEpoch;

      if (nowTimeSec < expiresTime) {
        String emailStored = prefs.getString('email');
        if (emailStored != null) {
          _emailController.text = emailStored;
        }

        bool useBetaUrl = prefs.getBool('usebetaurl') ?? false;

        if (useBetaUrl) {
          AppConstants.setDevelopmentFlavor();
        }

        String appLockStat = prefs.getString('app_lock') ?? 'nolock';

        if (appLockStat == 'nolock') {
          profileUserDetailsLoad();
        } else if (appLockStat == 'pin') {
          setState(() {
            if (emailStored != null) {
              userEmail = emailStored;
            }
            activeViewIndex = 1;
          });
        } else if (appLockStat == 'finger') {
          biometricsAuthenticate();
        }
      }
    }
  }

  void biometricsAuthenticate() async {
    var localAuth = LocalAuthentication();
    bool isAuthenticated = await localAuth.authenticate(
      biometricOnly: true,
      localizedReason: 'Login to your account',
      stickyAuth: true,
    );

    print(isAuthenticated);
    if (isAuthenticated) {
      profileUserDetailsLoad();
    }
  }

  void loginPressed() async {
    if (_emailController.text == '' || _passwordController.text == '') {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    AppConstants.setProductionFlavor();
    String loginEmailData;

    prefs.remove('usebetaurl');
    loginEmailData = _emailController.text;

    Map<String, dynamic> response = await NetworkHelper.authenticate(
        loginEmailData, _passwordController.text);

    if (response['status'] == 'success') {
      prefs.setString('email', _emailController.text);
      logedInDataProcess(response['result']);
    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(context, 'error_occurred'));
          break;
        case 'invalid_request':
          // if (response.containsKey('remaining_attempts')) {
          //   invalidRequestErrorHandle(response['remaining_attempts']);
          // } else {
          invalidRequestErrorHandle(0);
          // }
          break;
        case 'please_try_after_24_hours':
          invalidRequestErrorHandle(0);
          break;
        case 'app_only_access_enabled':
          deviceAccessErrorHandle();
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(context, 'invalid_username_password'));
      }
    }
  }

  Future<void> fbLoginClicked() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken;
      if (accessToken != null) {
        print(accessToken.toJson());
        facebookLoginRegister(accessToken.token);
      }
    }
  }

  void facebookLoginRegister(String fbToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoadingFb = true;
    });

    AppConstants.setProductionFlavor();

    prefs.remove('usebetaurl');

    Map<String, dynamic> response =
        await NetworkHelper.authenticateFacebook(fbToken);

    if (response['status'] == 'success') {
      logedInDataProcess(response['result']);
    } else {
      setState(() {
        isLoadingFb = false;
      });

      switch (response['error']) {
        case 'invalid_email':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(context, 'email_address_not_available'));
          break;
        case 'invalid_request':
          invalidRequestErrorHandle(0);
          break;
        case 'please_try_after_24_hours':
          invalidRequestErrorHandle(0);
          break;
        case 'app_only_access_enabled':
          deviceAccessErrorHandle();
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(context, 'unable_to_login_try_again'));
      }
    }
  }

  Future<void> googleLoginClicked() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      print(googleUser);
      googleLoginRegister(googleUser);
    } catch (error) {
      print(error);
    }
  }

  void googleLoginRegister(GoogleSignInAccount account) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoadingGoogle = true;
    });

    AppConstants.setProductionFlavor();
    prefs.remove('usebetaurl');

    List userGoogleNameArr = account.displayName.split(' ');

    String userGoogleFirstName = '';
    String userGoogleLastName = '';
    if (userGoogleNameArr.length == 1) {
      userGoogleFirstName = userGoogleNameArr[0];
    } else if (userGoogleNameArr.length == 2) {
      userGoogleFirstName = userGoogleNameArr[0];
      userGoogleLastName = userGoogleNameArr[1];
    }

    Map<String, dynamic> response = await NetworkHelper.authenticateGoogle(
        account.email, userGoogleFirstName, userGoogleLastName);

    if (response['status'] == 'success') {
      logedInDataProcess(response['result']);
    } else {
      setState(() {
        isLoadingGoogle = false;
      });

      switch (response['error']) {
        case 'invalid_email':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(context, 'email_address_not_available'));
          break;
        case 'invalid_request':
          invalidRequestErrorHandle(0);
          break;
        case 'please_try_after_24_hours':
          invalidRequestErrorHandle(0);
          break;
        case 'app_only_access_enabled':
          deviceAccessErrorHandle();
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: getTranslated(context, 'unable_to_login_try_again'));
      }
    }
  }

  void invalidRequestErrorHandle(remainingAttempts) {
    if (remainingAttempts == 0) {
      showSimpleDialog(context,
          title: getTranslated(context, 'login_failed'),
          message: getTranslated(context, 'invalid_username_password'));
      // showSimpleDialog(context,
      //     title: getTranslated(context, 'error'),
      //     message:
      //         'This account has been blocked due to too many recent failed login attempts. Please reset your account password to login.');
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message:
              'For security reasons, after $remainingAttempts more failed login attempts you will have to wait 24 hours before trying again.');
    }
  }

  void deviceAccessErrorHandle() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DevideVerifyInput(
            tagLogin: true,
            onDeviceVerified: () => loginPressed(),
          );
        });
  }

  void validatePin(String pinValue) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['pin'] = pinValue;

    Map<String, dynamic> response =
        await NetworkHelper.request('perspective/pinLogin', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      profileUserDetailsLoad();
    } else {
      if (response['error'] == 'pin_not_set_yet') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'pin_not_set'));
        setState(() {
          activeViewIndex = 1;
        });
      } else if (response['error'] == 'invalid_pin') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'invalid_pin'));
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'unable_to_login'));
        setState(() {
          activeViewIndex = 1;
        });
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

    prefs.setInt('last_user', resultData['id']);

    // pushNotificationsManager.init();

    profileUserDetailsLoad();
  }

  void profileUserDetailsLoad() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request('user/profile');

    if (response['status'] == 'success') {
      UserData userData = UserData.fromJson(response['result']);

      Provider.of<UserProvider>(context, listen: false).setUserData(userData);

      checkActivePerspective();
    } else {
      // if (response['error'] == "tokenverification") {
      // callRefreshToken();
      // } else {
      setState(() {
        isLoading = false;
      });
      // }
    }
  }

  void checkActivePerspective() async {
    Map<String, dynamic> response = await NetworkHelper.request('perspective');

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      Provider.of<PerspectiveProvider>(context, listen: false)
          .setActivePerspective(responseMap['type']);

      if (responseMap['type'] == 'community') {
        communityDetailsLoad(responseMap['id']);
      } else {
        goToHomePage();
      }
    }
  }

  communityDetailsLoad(String nowCommunityID) async {
    Map<String, dynamic> response =
        await NetworkHelper.request('community/details/' + nowCommunityID);

    if (response['status'] == 'success') {
      MerchantData merchantData = MerchantData.fromJson(response['result']);

      Provider.of<MerchantProvider>(context, listen: false)
          .setMerchantData(merchantData);

      // tagEvents.emit("rolePermissionGet");

      goToHomePage();
    }
  }

  void goToHomePage() {
    EventBusUtils.getInstance().fire(LayoutRefreshEvent(true));

    if (AppConstants.getServer() == 'beta') {
      Stripe.init(AppConstants.stripePublishableKeyTest,
          returnUrlForSca: AppConstants.getScaReturnUrl());
    } else {
      Stripe.init(AppConstants.stripePublishableKeyLive,
          returnUrlForSca: AppConstants.getScaReturnUrl());
    }

    if (AppConstants.appHomeMode == 'usersite') {
      Provider.of<LoginProvider>(context, listen: false).setLoginStatus(true);
      Navigator.pushNamedAndRemoveUntil(
          context, '/homeuser', (Route<dynamic> route) => false);
    } else if (AppConstants.appHomeMode == 'whitelabel') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ValidateWhiteScreen(),
          ),
          (route) => false);
    } else if (AppConstants.appHomeMode == 'module') {
      Provider.of<LoginProvider>(context, listen: false).setLoginStatus(true);
      Navigator.pushNamedAndRemoveUntil(
          context, '/homemodule', (Route<dynamic> route) => false);
    } else {
      Provider.of<LoginProvider>(context, listen: false).setLoginStatus(true);
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: activeViewIndex,
        children: [
          Container(
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(40, 60, 40, 10),
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        AppLogo(),
                        LoginInput(
                          controller: _emailController,
                          icon: Icons.alternate_email,
                          hintText: getTranslated(context, 'email'),
                          obscureText: false,
                          autofillHints: const <String>[AutofillHints.username],
                        ),
                        LoginInput(
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hintText: getTranslated(context, 'password'),
                          obscureText: _obscureStatus,
                          suffix: IconButton(
                              icon: Icon(
                                _obscureStatus
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureStatus = !_obscureStatus;
                                });
                              }),
                          autofillHints: const <String>[AutofillHints.password],
                          onSubmitted: () => loginPressed(),
                        ),
                        SizedBox(height: 30),
                        AnimatedContainer(
                          height: 50,
                          width: isLoading ? 50 : 360,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ))
                              : GestureDetector(
                                  onTap: () {
                                    loginPressed();
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                      child: Text(
                                    getTranslated(context, 'tag_login'),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )),
                                ),
                        ),
                        SizedBox(height: 20),
                        FlatButton(
                          child: Text(
                            getTranslated(context, 'forgot_password'),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot');
                          },
                        )
                      ],
                    ),
                  ),
                ),
                qrDataString.isNotEmpty
                    ? Column(
                        children: [
                          Center(
                            child: QrImage(
                              data: qrDataString,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                              size: 130,
                              padding: const EdgeInsets.all(0.0),
                              embeddedImage:
                                  AssetImage('assets/images/logo.png'),
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: Size(30, 30),
                              ),
                            ),
                          ),
                          Text(
                            qrUserId,
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(height: 10),
                        ],
                      )
                    : SizedBox(),
                !UniversalPlatform.isIOS
                    ? Center(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                          constraints: BoxConstraints(maxWidth: 360),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                  child: Text(
                                getTranslated(context, 'or_connect_with'),
                              )),
                              GestureDetector(
                                onTap: () => googleLoginClicked(),
                                child: Opacity(
                                  opacity: isLoadingGoogle ? 0.5 : 1,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 6),
                                          blurRadius: 12,
                                          color: Color(0xFF173347)
                                              .withOpacity(0.23),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/images/google.png'),
                                        SizedBox(width: 20),
                                        Text(
                                          getTranslated(
                                              context, 'sign_in_with_google'),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF3B3A3B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => fbLoginClicked(),
                                child: Opacity(
                                  opacity: isLoadingFb ? 0.5 : 1,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4267B2),
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 6),
                                          blurRadius: 12,
                                          color: Color(0xFF173347)
                                              .withOpacity(0.23),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            'assets/images/facebook.png'),
                                        SizedBox(width: 20),
                                        Text(
                                          getTranslated(
                                              context, 'sign_in_with_facebook'),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 20),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          getTranslated(
                                              context, 'dont_have_account'),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          getTranslated(context, 'sign_up'),
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                child: AbsorbPointer(
                  absorbing: isLoading ? true : false,
                  child: Opacity(
                    opacity: isLoading ? .2 : 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: PinLogin(
                            userEmail: userEmail,
                            onPinEntered: (String pinValue) {
                              validatePin(pinValue);
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              activeViewIndex = 0;
                            });
                          },
                          child: Text(
                              getTranslated(context, 'login_with_id_email')),
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}

class DevideVerifyInput extends StatefulWidget {
  final bool tagLogin;
  final VoidCallback onDeviceVerified;

  const DevideVerifyInput({
    Key key,
    this.tagLogin,
    this.onDeviceVerified,
  }) : super(key: key);

  @override
  _DevideVerifyInputState createState() => _DevideVerifyInputState();
}

class _DevideVerifyInputState extends State<DevideVerifyInput> {
  bool isLoading = false;
  TextEditingController _codeController = TextEditingController();

  void verifyDeviceHandle() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['client_unique_id'] = AppConstants.deviceId;
    apiBodyObj['otp'] = _codeController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/verifyDevice', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context);

      if (widget.tagLogin) {
        Fluttertoast.showToast(
            msg: getTranslated(context, 'successfully_linked_device'));
        widget.onDeviceVerified();
      } else {
        showSimpleDialog(context,
            title: getTranslated(context, 'success'),
            message:
                getTranslated(context, 'successfully_linked_device_login'));
      }
    } else {
      Fluttertoast.showToast(
          msg: getTranslated(context, 'verification_code_entered_correctly'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: SizedBox(
          width: 360,
          height: 300,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, 'verify_new_device'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 10),
                    Text(
                      getTranslated(context, 'verification_code_send'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      child: PinCodeTextField(
                        autoDismissKeyboard: true,
                        appContext: context,
                        length: 6,
                        keyboardType: TextInputType.number,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          inactiveFillColor: Colors.grey,
                          inactiveColor: Colors.grey,
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.red,
                          selectedColor: Colors.red,
                        ),
                        animationDuration: Duration(milliseconds: 300),
                        enableActiveFill: true,
                        controller: _codeController,
                        onChanged: (value) {
                          if (value.length == 6) {
                            verifyDeviceHandle();
                          }
                        },
                      ),
                    ),
                    Text(
                      getTranslated(context, 'please_enter_code'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
