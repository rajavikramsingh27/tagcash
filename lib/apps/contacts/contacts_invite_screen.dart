import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class ContactsInviteScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;

  const ContactsInviteScreen(
      {Key key, this.email = '', this.firstName = '', this.lastName = ''})
      : super(key: key);

  @override
  _ContactsInviteScreenState createState() => _ContactsInviteScreenState();
}

class _ContactsInviteScreenState extends State<ContactsInviteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();

  int _radioValue = 1;
  @override
  void initState() {
    super.initState();

    _emailController.text = widget.email;
    _firstnameController.text = widget.firstName;
    _lastnameController.text = widget.lastName;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  void inviteClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['email'] = _emailController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('User/EmailInvite', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context);

      Fluttertoast.showToast(
          msg: 'Invite email send successfully',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    } else {
      if (response['error'] == 'user_is_already_registered') {
        showSnackBar(getTranslated(context, 'email_already_registered'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  void addContactClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['email'] = _emailController.text;
    apiBodyObj['first_name'] = _firstnameController.text;
    apiBodyObj['last_name'] = _lastnameController.text;
    Map<String, dynamic> response =
        await NetworkHelper.request('contact/AddAndSendEmail', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.of(context).pop(true);
    } else {
      if (response['error'] == 'email_already_registered') {
        showSnackBar(getTranslated(context, 'email_already_registered'));
      } else if (response['error'] == 'already_added') {
        showSnackBar(getTranslated(context, 'Contact_already_added'));
      } else {
        showSnackBar(getTranslated(context, 'failed_to_add_user_contact'));
      }
    }
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'contacts_title'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: enableAutoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              padding: EdgeInsets.all(kDefaultPadding),
              children: [
                Text(
                  getTranslated(context, 'email_not_found'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                RadioListTile(
                  title: Text(
                    getTranslated(context, 'send_email_invite'),
                  ),
                  value: 0,
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      _radioValue = value;
                    });
                  },
                ),
                RadioListTile(
                  title: Text(
                    getTranslated(context, 'add_and_send_email'),
                  ),
                  value: 1,
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      _radioValue = value;
                    });
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: getTranslated(context, 'email'),
                  ),
                  validator: (value) {
                    if (!Validator.isEmail(value)) {
                      return getTranslated(context, 'email_not_valid');
                    }
                    return null;
                  },
                ),
                _radioValue == 1
                    ? TextFormField(
                        controller: _firstnameController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: getTranslated(context, 'first_name'),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value)) {
                            return getTranslated(context, 'valid_first_name');
                          }
                          return null;
                        },
                      )
                    : SizedBox(),
                _radioValue == 1
                    ? TextFormField(
                        controller: _lastnameController,
                        autofocus: false,
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: getTranslated(context, 'last_name'),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value)) {
                            return getTranslated(context, 'valid_last_name');
                          }
                          return null;
                        },
                      )
                    : SizedBox(),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(
                    _radioValue == 0
                        ? getTranslated(context, 'invite')
                        : getTranslated(context, 'add'),
                  ),
                  onPressed: () {
                    setState(() {
                      enableAutoValidate = true;
                    });
                    if (_formKey.currentState.validate()) {
                      _radioValue == 0
                          ? inviteClickHandler()
                          : addContactClickHandler();
                    }
                  },
                )
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
