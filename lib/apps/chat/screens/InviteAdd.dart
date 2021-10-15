import 'package:flutter/material.dart';

import '../../../components/app_top_bar.dart';
import '../../../services/networking.dart';
import '../../../components/loading.dart';
import '../../../utils/validator.dart';
import '../../../components/custom_button.dart';

class InviteAdd extends StatefulWidget {
  @override
  _InviteAddState createState() => _InviteAddState();
}

class _InviteAddState extends State<InviteAdd> {
  TextEditingController _emailController;
  TextEditingController _firstnameController;
  TextEditingController _lastnameController;
  TextEditingController _inviteEmailController;
  bool enableAutoValidate = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isEmailInvite = false;
  int _radioValue = 1;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _inviteEmailController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _inviteEmailController.dispose();
  }

  void inviteClickHandler() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['email'] = _inviteEmailController.text;
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('/User/EmailInvite', apiBodyObj);
    print(response);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      print("Email Invitation sent Successfully");
      Navigator.of(context).pop('Email Invitation sent Successfully');
    } else {
      if (response['error'] == 'email_required') {
        Navigator.of(context).pop('Failed:Email is required');
      } else if (response['error'] == 'request_failed') {
        Navigator.of(context).pop('Failed:Request Failed');
      } else if (response['error'] == 'failed') {
        Navigator.of(context).pop('Failed: Failed');
      } else if (response['error'] == 'user_is_already_registered') {
        Navigator.of(context).pop('Failed:User is already registered');
      } else {
        Navigator.of(context).pop('Email Invite failed');
      }
    }
  }

  void addContactClickHandler() async {
    // Map<String, String> apiBodyObj = {};
    // apiBodyObj['email'] = _emailController.text;
    // apiBodyObj['first_name'] = _firstnameController.text;
    // apiBodyObj['last_name'] = _lastnameController.text;
    // setState(() {
    //   isLoading = true;
    // });
    // Map<String, dynamic> response =
    //     await NetworkHelper.request('', apiBodyObj);
    // print(response);
    // setState(() {
    //   isLoading = false;
    // });
    // if (response["status"] == "success") {
    //   print("Contact Added Successfully");
    //   Navigator.of(context).pop('Contact Added Successfully');
    // } else {
    //   if (response['error'] == 'email_required') {
    //     Navigator.of(context).pop('Failed:Email is required');
    //   } else if (response['error'] == 'request_failed') {
    //     Navigator.of(context).pop('Failed:Request Failed');
    //   } else if (response['error'] == 'failed') {
    //     Navigator.of(context).pop('Failed: Failed');
    //   } else if (response['error'] == 'user_is_already_registered') {
    //     Navigator.of(context).pop('Failed:User is already registered');
    //   } else {
    //     Navigator.of(context).pop('Email Invite failed');
    //   }
    // }
  }

  void methodChangeHandler(int value) {
    print("valueppp-->" + value.toString());
    _radioValue = value;
    if (_radioValue == 0) {
      isEmailInvite = true;
    } else {
      isEmailInvite = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget addContactSection = Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Form(
        key: _formKey,
        autovalidateMode: enableAutoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'email',
                ),
                validator: (value) {
                  if (!Validator.isEmail(value)) {
                    return "Please enter valid Email";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _firstnameController,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'First name',
                  hintText: 'First name',
                ),
                validator: (value) {
                  if (!Validator.isRequired(value)) {
                    return "Please enter valid First name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastnameController,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Last name',
                  hintText: 'Last name',
                ),
                validator: (value) {
                  if (!Validator.isRequired(value)) {
                    return "Please enter valid Last name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                        label: 'CANCEL',
                        color: Colors.grey,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                        label: 'ADD',
                        onPressed: () {
                          setState(() {
                            enableAutoValidate = true;
                          });
                          if (_formKey.currentState.validate()) {
                            addContactClickHandler();
                          }
                        }),
                  ),
                ],
              ),
            ]),
      ),
    );
    Widget emailInviteSection = Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Form(
        key: _formKey,
        autovalidateMode: enableAutoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(children: [
          TextFormField(
            controller: _inviteEmailController,
            autofocus: false,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Email',
            ),
            validator: (value) {
              if (!Validator.isEmail(value)) {
                return "Please enter valid Email";
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                    label: 'CANCEL',
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                    label: 'INVITE',
                    onPressed: () {
                      setState(() {
                        enableAutoValidate = true;
                      });
                      if (_formKey.currentState.validate()) {
                        inviteClickHandler();
                      }
                    }),
              ),
            ],
          ),
        ]),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Create',
      ),
      body: Stack(
        children: [
          Form(
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Container(
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(
                            "EMAIL NOT FOUND IN TAGCASH",
                            textScaleFactor: 1,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio(
                              value: 0,
                              groupValue: _radioValue,
                              onChanged: methodChangeHandler,
                            ),
                            Text(
                              'Send email Invite',
                            ),
                            Radio(
                              value: 1,
                              groupValue: _radioValue,
                              onChanged: methodChangeHandler,
                            ),
                            Text(
                              'Add and send email',
                            )
                          ],
                        ),
                        isEmailInvite ? emailInviteSection : addContactSection,
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
