import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class UserProfileEditScreen extends StatefulWidget {
  @override
  _UserProfileEditScreenState createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  List<String> reagionList = [
    'National Capital Region',
    'Cordillera Administrative Region',
    'Ilocos Region',
    'Cagayan Valley',
    'Central Luzon',
    'Calabarzon',
    'Southwestern Tagalog Region',
    'Bicol Region',
    'Western Visayas',
    'Central Visayas',
    'Eastern Visayas',
    'Zamboanga Peninsula',
    'Northern Mindanao',
    'Davao Region',
    'Soccsksargen',
    'Caraga',
    'Bangsamoro'
  ];

  UserData userData;

  String activeId;

  String callingCode;

  String countryCode;
  String countryName;
  String countryId;

  String userRegion;
  String _genderValue;

  TextEditingController _nameController;
  TextEditingController _nicknameController;
  TextEditingController _usernameController;
  TextEditingController _emailController;
  TextEditingController _mobileController;
  TextEditingController _cityController;
  TextEditingController _dateBirthController;
  TextEditingController _detailsController;

  String dateBirthValue = '';
  Map<String, String> inputValueObj = {};

  bool usrnameEditPossible = true;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _cityController = TextEditingController();
    _dateBirthController = TextEditingController();
    _detailsController = TextEditingController();

    showProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _dateBirthController.dispose();
    _detailsController.dispose();

    super.dispose();
  }

  void showProfileData() {
    userData = Provider.of<UserProvider>(context, listen: false).userData;
    activeId = userData.id.toString();

    _nameController.text = userData.firstName + ' ' + userData.lastName;
    _nicknameController.text = userData.nickName;
    _usernameController.text = userData.userName;
    _emailController.text = userData.email;

    if (userData.userName != '') {
      usrnameEditPossible = false;
    }

    countryCode = userData.countryCode;
    countryName = userData.countryName;
    countryId = userData.countryId.toString();
    callingCode = '+' + userData.countryCallingCode;
    _mobileController.text = userData.mobile.toString();

    _cityController.text = userData.userCity;

    DateTime dobDateTime = DateTime.tryParse(userData.userDob);
    if (dobDateTime != null) {
      _dateBirthController.text =
          DateFormat('MMM dd, yyyy').format(dobDateTime);
      dateBirthValue = userData.userDob;
      print(dateBirthValue);
    }

    _detailsController.text = userData.profileBio;

    if (userData.userRegion != '') {
      userRegion = userData.userRegion;
    }

    if (userData.userGender == '') {
      _genderValue = 'not set';
    } else {
      _genderValue = userData.userGender;
    }
  }

  void onEditTextChange(String field, String value) {
    if (field == 'userFullName') {
      List userNameArr = value.split(' ');
      saveFieldDataChanges('user_firstname', userNameArr[0]);
      saveFieldDataChanges('user_lastname', userNameArr[1]);
    } else {
      saveFieldDataChanges(field, value);
    }
  }

  void onCountryChange(Map country) {
    String dialCode = country['dial_code'];
    if (dialCode[0] == '+') {
      dialCode = dialCode.substring(1);
    }
    saveFieldDataChanges('country_phonecode', dialCode);
    saveFieldDataChanges("country_id", country['id']);

    setState(() {
      callingCode = country['dial_code'];
      countryCode = country['code'];
      countryName = country['name'];
    });
  }

  void userRegionChange(String region) {
    saveFieldDataChanges('user_region', region);

    setState(() {
      userRegion = region;
    });
  }

  void onGenderChange(String value) {
    saveFieldDataChanges("user_gender", value);
    setState(() {
      _genderValue = value;
    });
  }

  void saveFieldDataChanges(String editedField, dynamic editedValue) {
    inputValueObj[editedField] = editedValue;
  }

  void usernameCheck() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['user_name'] = _usernameController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/CheckUserNameAvailable', apiBodyObj);

    if (response['status'] == 'success') {
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void userProfileUpdate() async {
    bool dataPassError = false;

    if (inputValueObj.containsKey('user_name')) {
      String value = inputValueObj['user_name'];

      if (Validator.isNumber(value) ||
          !Validator.isAlphaNumeric(value) ||
          value.length < 3 ||
          value.length > 50) {
        dataPassError = true;

        showSimpleDialog(context,
            title: 'Invalid Username',
            message:
                'Username must be between 3 and 50 characters long. A username can only contain alphanumeric characters (letters A-Z, numbers 0-9). Must contain at least one English character.');
      }
    }

    if (inputValueObj.containsKey('user_mobile')) {
      String value = inputValueObj['user_mobile'];
      if (!Validator.isMobile(value)) {
        dataPassError = true;
      }
    }

    if (inputValueObj.containsKey('email')) {
      String value = inputValueObj['email'];
      if (!Validator.isEmail(value)) {
        dataPassError = true;
      }
    }
    if (dataPassError) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('user/updateprofile', inputValueObj);

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (inputValueObj.containsKey('user_firstname')) {
        userData.firstName = inputValueObj['user_firstname'];
        userData.lastName = inputValueObj['user_lastname'];
      }
      if (inputValueObj.containsKey('user_mobile')) {
        userData.mobile = inputValueObj['user_mobile'];
      }
      if (inputValueObj.containsKey('email')) {
        userData.email = inputValueObj['email'];
      }

      if (inputValueObj.containsKey('user_name')) {
        userData.userName = inputValueObj['user_name'];
      }

      userData.nickName = _nicknameController.text;
      userData.userCity = _cityController.text;
      userData.userDob = dateBirthValue;
      userData.profileBio = _detailsController.text;

      if (userRegion != null) {
        userData.userRegion = userRegion;
      }

      if (_genderValue != 'not set') {
        userData.userGender = _genderValue;
      }

      if (inputValueObj.containsKey('country_phonecode')) {
        userData.countryCallingCode = inputValueObj['country_phonecode'];
      }
      if (inputValueObj.containsKey('country_id')) {
        userData.countryId = inputValueObj['country_id'];

        userData.countryCode = countryCode;
        userData.countryName = countryName;
      }

      Provider.of<UserProvider>(context, listen: false).setUserData(userData);

      inputValueObj = {};

      Fluttertoast.showToast(msg: 'Profile Updated Successfully');
      Navigator.pop(context);
    } else {
      setState(() {
        isLoading = false;
      });

      if (response['error'] == 'Mobile_number_already_used by_someone_else') {
        showSimpleDialog(context,
            title: 'Error', message: 'Mobile number is already used.');
      } else if (response['error'] == 'email_exists') {
        showSimpleDialog(context,
            title: 'Error',
            message: 'Email is already in use by another account.');
      } else if (response['error'] == 'user_name_exists') {
        showSimpleDialog(context,
            title: 'Username Error',
            message: 'Username is already in use by another user.');
      } else if (response['error'] == 'user_name_invalid' ||
          response['error'] == 'user_name_special_char_not_allowed' ||
          response['error'] == 'user_name_max_lenth_50' ||
          response['error'] == 'user_name_atleast_1_alphabet_required') {
        showSimpleDialog(context,
            title: 'Invalid Username',
            message:
                'Username must be between 3 and 50 characters long. A username can only contain alphanumeric characters (letters A-Z, numbers 0-9). Must contain at least one English character.');
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  Future<void> _showDatePickerDialog() async {
    DateTime ldDatePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (ldDatePicked != null) {
      _dateBirthController.text =
          DateFormat('MMM dd, yyyy').format(ldDatePicked);

      dateBirthValue = DateFormat('yyyy-MM-dd').format(ldDatePicked);
      onEditTextChange('user_dob', dateBirthValue);
    }
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        // title: 'Module Name',
      ),
      body: Stack(
        children: [
          Form(
              key: _formKey,
              autovalidateMode: enableAutoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: ListView(
                padding: EdgeInsets.all(10),
                children: [
                  usrnameEditPossible
                      ? TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.alternate_email_rounded),
                            labelText: 'Username',
                          ),
                          onChanged: (value) {
                            onEditTextChange('user_name', value.toLowerCase());
                          },
                        )
                      : ListTile(
                          title: Text('Username'),
                          subtitle: Text('@${_usernameController.text}'),
                        ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Name',
                    ),
                    onChanged: (value) {
                      onEditTextChange('userFullName', value);
                    },
                  ),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person_outline),
                      labelText: 'Display Name',
                    ),
                    onChanged: (value) {
                      onEditTextChange('user_nickname', value);
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    onChanged: (value) {
                      onEditTextChange('email', value);
                    },
                  ),
                  SizedBox(height: 20),
                  CountriesFormField(
                    labelText: 'Select country',
                    initialCountryCode: countryCode,
                    onChanged: (country) {
                      if (country != null) {
                        onCountryChange(country);
                      }
                    },
                  ),
                  Row(
                    children: [
                      Text(
                        callingCode,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _mobileController,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                          ),
                          onChanged: (value) {
                            onEditTextChange('user_mobile', value);
                          },
                        ),
                      ),
                    ],
                  ),
                  countryCode == 'PH'
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Select Region',
                              border: const OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                            value: userRegion,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            // style: TextStyle(color: Colors.deepPurple),
                            onChanged: userRegionChange,
                            items: reagionList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        )
                      : SizedBox(),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.location_city),
                      labelText: 'City',
                    ),
                    onChanged: (value) {
                      onEditTextChange('user_city', value);
                    },
                  ),
                  TextField(
                    controller: _dateBirthController,
                    readOnly: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.today),
                      labelText: 'Date of Birth',
                    ),
                    onTap: () => _showDatePickerDialog(),
                  ),

                  SizedBox(height: 20),
                  // Text(toBeginningOfSentenceCase(_genderValue)),
                  Text('Gender'),
                  Row(
                    children: [
                      Radio(
                        value: 'male',
                        groupValue: _genderValue,
                        onChanged: onGenderChange,
                      ),
                      Text(
                        'Male',
                      ),
                      Radio(
                        value: 'female',
                        groupValue: _genderValue,
                        onChanged: onGenderChange,
                      ),
                      Text(
                        'Female',
                      ),
                      Radio(
                        value: 'other',
                        groupValue: _genderValue,
                        onChanged: onGenderChange,
                      ),
                      Text(
                        'Other',
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _detailsController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Details',
                    ),
                    onChanged: (value) {
                      onEditTextChange('profile_bio', value);
                    },
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () => userProfileUpdate(),
                      child: Text(getTranslated(context, 'save')))
                ],
              )),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
