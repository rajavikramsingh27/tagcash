import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/wallets_dropdown.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/main.dart';
import 'package:tagcash/models/language.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/handlers/logout_handler.dart';
import 'package:universal_platform/universal_platform.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoading = false;

  bool pinStatus = false;
  bool fingerprintStatus = false;
  String defaultCurrencyCode;
  bool passwordChangePossible = false;

  List<Language> languageList = [];

  Language languageDropdownValue;

  @override
  void initState() {
    super.initState();

    if (AppConstants.getServer() == 'live') {
      passwordChangePossible = true;
    }
    languageList = Language.languageList();
    checkSettings();
  }

  void checkSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String appLockStat = prefs.getString('app_lock') ?? 'nolock';

    if (appLockStat == 'pin') {
      setState(() {
        pinStatus = true;
      });
    } else if (appLockStat == 'finger') {
      setState(() {
        fingerprintStatus = true;
      });
    }

    defaultWalletCheck();
  }

  defaultWalletCheck() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['community_id'] = '0';

    Map<String, dynamic> response =
        await NetworkHelper.request('settings', apiBodyObj);

    Map responseMap = response['result']['defaults'];
    setState(() {
      defaultCurrencyCode = responseMap['wallet_id'].toString();
    });
  }

  void _changeLanguage(BuildContext context, Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  void pinEnable(bool status) async {
    setState(() {
      pinStatus = status;
      fingerprintStatus = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (status) {
      prefs.setString('app_lock', 'pin');
    } else {
      prefs.remove('app_lock');
    }
  }

  void setDefaultWallet(Wallet wallet) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['wallet_id'] = wallet.walletId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('settings/setdefaults', apiBodyObj);

    setState(() {
      isLoading = false;
    });
  }

  void pinChangeClicked() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ChangePin(),
              ),
            ),
          );
        });
  }

  void fingerprintEnable(bool status) async {
    setState(() {
      pinStatus = false;
      fingerprintStatus = status;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (status) {
      prefs.setString('app_lock', 'finger');
    } else {
      prefs.remove('app_lock');
    }
  }

  void passwordChangeClicked() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ChangePassword(),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // ListTile(
          //   title: Text(getTranslated(context, 'language')),
          //   trailing: SizedBox(
          //       width: 150,
          //       child: DropdownButtonFormField<Language>(
          //         decoration: const InputDecoration(
          //           labelText: getTranslated(context, 'language'),
          //           contentPadding:
          //               EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          //           border: const OutlineInputBorder(),
          //         ),
          //         value: languageDropdownValue,
          //         icon: Icon(Icons.arrow_downward),
          //         items: languageList
          //             .map<DropdownMenuItem<Language>>((Language value) {
          //           return DropdownMenuItem<Language>(
          //             value: value,
          //             child: Text(
          //               value.name,
          //               overflow: TextOverflow.ellipsis,
          //             ),
          //           );
          //         }).toList(),
          //         onChanged: (Language language) {
          //           _changeLanguage(context, language);
          //           setState(() {
          //             languageDropdownValue = language;
          //           });
          //         },
          //       )),
          // ),
          SizedBox(height: 20),
          ListTile(
            title: Text(getTranslated(context, 'default_currency')),
            trailing: SizedBox(
              width: 150,
              child: WalletsDropdown(
                currencyCode: ValueNotifier<String>(defaultCurrencyCode),
                onSelected: (wallet) => setDefaultWallet(wallet),
              ),
            ),
          ),
          if (Provider.of<PerspectiveProvider>(context, listen: false)
                  .getActivePerspective() ==
              'user') ...[
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(10),
              color: Colors.grey[300],
              child: Text(getTranslated(context, 'security_settings')),
            ),
            ListTile(
              title: Text(getTranslated(context, 'change_pin_code')),
              trailing: ElevatedButton(
                child: Text(getTranslated(context, 'change')),
                onPressed: () => pinChangeClicked(),
              ),
            ),
            ListTile(
              title: Text(getTranslated(context, 'enable_pin')),
              trailing: Switch(
                value: pinStatus,
                onChanged: (boolVal) => pinEnable(boolVal),
              ),
            ),
            UniversalPlatform.isAndroid
                ? ListTile(
                    title: Text(getTranslated(context, 'fingerprint_login')),
                    trailing: Switch(
                      value: fingerprintStatus,
                      onChanged: (boolVal) => fingerprintEnable(boolVal),
                    ),
                  )
                : SizedBox(),
            passwordChangePossible
                ? ListTile(
                    title: Text(getTranslated(context, 'change_password')),
                    trailing: ElevatedButton(
                      child: Text(getTranslated(context, 'change')),
                      onPressed: () => passwordChangeClicked(),
                    ),
                  )
                : SizedBox(),
          ],
        ],
      ),
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({
    Key key,
  }) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _oldController;
  TextEditingController _newController;
  TextEditingController _confirmController;

  bool _obscureStatusOld = true;
  bool _obscureStatusNew = true;
  bool _obscureStatusCon = true;

  @override
  void initState() {
    super.initState();

    _oldController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void passwordChangeClicked() async {
    if (_newController.text != _confirmController.text) {
      showSnackBar(getTranslated(context, 'password_confirm_not_match'));
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['current_password'] = _oldController.text;
    apiBodyObj['user_password'] = _newController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/changepassword', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      logoutClicked();
      showSimpleNotification(
        Text(getTranslated(context, 'password_changed')),
        subtitle: Text(getTranslated(context, 'password_changed_successfully')),
      );
    } else {
      if (response['error'] == 'invalid_current_password') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'password_entered_not_valid'));
      } else if (response['error'] == 'min_password_length_6') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'password_too_short'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  void logoutClicked() async {
    LogoutHandler logoutHandler = LogoutHandler();
    logoutHandler.logout(context);
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                getTranslated(context, 'change_password'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              TextFormField(
                controller: _oldController,
                obscureText: _obscureStatusOld,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'old_password'),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _obscureStatusOld
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureStatusOld = !_obscureStatusOld;
                        });
                      }),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return getTranslated(context, 'please_enter_old_password');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newController,
                obscureText: _obscureStatusNew,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'new_password'),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _obscureStatusOld
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureStatusNew = !_obscureStatusNew;
                        });
                      }),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return getTranslated(context, 'please_enter_new_password');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureStatusCon,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'confirm_password'),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _obscureStatusOld
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureStatusCon = !_obscureStatusCon;
                        });
                      }),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return getTranslated(
                        context, 'please_enter_confirm_password');
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(getTranslated(context, 'change')),
                onPressed: () {
                  setState(() {
                    enableAutoValidate = true;
                  });
                  if (_formKey.currentState.validate()) {
                    passwordChangeClicked();
                  }
                },
              ),
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}

class ChangePin extends StatefulWidget {
  const ChangePin({
    Key key,
  }) : super(key: key);

  @override
  _ChangePinState createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _oldController;
  TextEditingController _newController;
  TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();

    _oldController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void pinchangeClicked() async {
    if (_newController.text != _confirmController.text) {
      showSnackBar(getTranslated(context, 'pin_confirm_does_not_match'));
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['current_pin'] = _oldController.text;
    apiBodyObj['pin'] = _newController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/setrestrictions', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context);
      showSnackBar(getTranslated(context, 'pin_changed'));
    } else {
      if (response['error'] == 'wrong_pin') {
        showSnackBar(getTranslated(context, 'incorrect_pin'));
      } else if (response['error'] == 'exceeded_pin_try') {
        showSnackBar(getTranslated(context, 'incorrect_pin_several_times'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  void resetPinClicked() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('settings/ResetPincode');

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      showSnackBar(getTranslated(context, 'pin_reset_email_sent_successfully'));
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              Text(
                getTranslated(context, 'pin_change'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              TextFormField(
                controller: _oldController,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'old_pin'),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return getTranslated(context, 'please_enter_old_pin');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newController,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'new_pin'),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return getTranslated(context, 'please_enter_new_pin');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmController,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'confirm_pin'),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return getTranslated(context, 'please_enter_confirm_pin');
                  }

                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text(getTranslated(context, 'reset_pin')),
                    onPressed: () => resetPinClicked(),
                  ),
                  ElevatedButton(
                    child: Text(getTranslated(context, 'change')),
                    onPressed: () {
                      setState(() {
                        enableAutoValidate = true;
                      });
                      if (_formKey.currentState.validate()) {
                        pinchangeClicked();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
