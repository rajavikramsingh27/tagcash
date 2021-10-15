import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/date_time_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';

class KYCDataVerifyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KYCDataVerifyPageState();
  }
}

class _KYCDataVerifyPageState extends State<KYCDataVerifyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  List<KYCIDTYPES> _kycIdTypes = KYCIDTYPES.getKycIdTypes();
  List<DropdownMenuItem<KYCIDTYPES>> _dropdownMenuItems;
  KYCIDTYPES _selectedKycIdTypes;
  var kycIdTypeValue;
  var country_code;
//var kycGenderIndex;
  var verificationLevel;
  int kycGenderIndex;
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _dateTimeController;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final middleName = TextEditingController();
  final presentAddress = TextEditingController();
  final permanentAddress = TextEditingController();
  final tinSssNumber = TextEditingController();
  final birthPlace = TextEditingController();
  final sourceOfFund = TextEditingController();
  final workType = TextEditingController();

  void initState() {
    getKYCMerchantVerifiedData();
    _dropdownMenuItems = buildDropdownMenuItems(_kycIdTypes);
    _selectedKycIdTypes = _dropdownMenuItems[0].value;
    kycIdTypeValue = _selectedKycIdTypes.name;
    country_code = 174;
    kycGenderIndex = 0;
    _dateTimeController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    firstName.dispose();
    lastName.dispose();
    middleName.dispose();
    presentAddress.dispose();
    permanentAddress.dispose();
    tinSssNumber.dispose();
    birthPlace.dispose();
    sourceOfFund.dispose();
    workType.dispose();
    super.dispose();
  }

  getKYCMerchantVerifiedData() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('user/GetAddressInfo/');

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      var verifyStatus = response['result'];
      if (verifyStatus["status"] == "pending") {
        verificationLevel = verifyStatus["status"];
      } else if (verifyStatus["status"] == "unapproved") {
        verificationLevel = verifyStatus["status"];
      } else if (verifyStatus["status"] == "approved") {
        verificationLevel = verifyStatus["status"];
      } else {
        verificationLevel = "new";
      }
    } else if (response["error"] == "info_missing") {
      verificationLevel = "new";
    }
    setState(() {});
  }

  List<DropdownMenuItem<KYCIDTYPES>> buildDropdownMenuItems(List kycTypes) {
    List<DropdownMenuItem<KYCIDTYPES>> items = List();
    for (KYCIDTYPES kyc in kycTypes) {
      items.add(
        DropdownMenuItem(
          value: kyc,
          child: Text(kyc.name),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(KYCIDTYPES selectedCompany) {
    setState(() {
      _selectedKycIdTypes = selectedCompany;
      kycIdTypeValue = _selectedKycIdTypes.name;
    });
  }

  void onCountryChange(Map country) {
    setState(() {
      country_code = country['id'];
    });
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      kycGenderIndex = value;
    });
  }

  void saveKYCDataHandler() async {
    setState(() {
      isLoading = true;
    });

    int nowUserID =
        Provider.of<UserProvider>(context, listen: false).userData.id;

    String kycGenderType;

    if (kycGenderIndex == 0) {
      kycGenderType = "male";
    } else {
      kycGenderType = "female";
    }

    var apiBodyObj = {};
    apiBodyObj['firstname'] = firstName.text;
    apiBodyObj['middlename'] = middleName.text;
    apiBodyObj['lastname'] = lastName.text;
    apiBodyObj['gender'] = kycGenderType;
    apiBodyObj['nationality'] = country_code.toString();
    apiBodyObj['government_id_type'] = kycIdTypeValue.toString();
    apiBodyObj['government_id_number'] = tinSssNumber.text.toString();
    apiBodyObj['nature_of_work'] = workType.text;
    apiBodyObj['source_of_funds'] = sourceOfFund.text;
    apiBodyObj['dob'] = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(_dateTimeController.text));
    apiBodyObj['pob'] = birthPlace.text;
    apiBodyObj['currentAddress'] = presentAddress.text;
    apiBodyObj['permanentAddress'] = permanentAddress.text;
    apiBodyObj['user_id'] = nowUserID.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('user/UpdateAddressInfo/', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      var msg = getTranslated(context, "kyc_information_submitted");
      showMessage(msg);
      getKYCMerchantVerifiedData();
    } else {
      if (response['error'] == 'email_verification_pending') {
        var msg = getTranslated(context, "kyc_email_verification_pending");
        showMessage(msg);
      } else if (response['error'] == 'sms_verification_pending') {
        var msg = getTranslated(context, "kyc_sms_verification_pending");
        showMessage(msg);
      } else if (response['error'] == 'already_data_approved') {
        var msg = getTranslated(context, "kyc_already_approved");
        showMessage(msg);
      } else if (response['error'] == 'data_waiting_for_approval') {
        var msg = getTranslated(context, "kyc_data_waiting_for_approval");
        showMessage(msg);
      } else {
        showMessage(response['error']);
      }
    }
  }

  void onVerificationClick() {
    setState(() {
      verificationLevel = "new";
    });
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Stack(
          children: [
            if (verificationLevel == "new") ...[
              Form(
                key: _formKey,
                autovalidateMode: enableAutoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: firstName,
                      decoration: InputDecoration(
                          labelText: getTranslated(context, "first_name")),
                      validator: (firstName) {
                        if (firstName.isEmpty) {
                          var msg =
                              getTranslated(context, "first_name_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: middleName,
                      decoration: InputDecoration(
                          labelText: getTranslated(context, "kyc_middle_name")),
                    ),
                    TextFormField(
                      controller: lastName,
                      decoration: InputDecoration(
                          labelText: getTranslated(context, "last_name")),
                      validator: (lastName) {
                        if (lastName.isEmpty) {
                          var msg =
                              getTranslated(context, "kyc_Last_name_required");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      minLines: 2,
                      maxLines: null,
                      controller: presentAddress,
                      decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "kyc_present_address")),
                      validator: (presentAddress) {
                        if (presentAddress.isEmpty) {
                          var msg = getTranslated(
                              context, "kyc_present_address_required");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      minLines: 2,
                      maxLines: null,
                      controller: permanentAddress,
                      decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "kyc_permanent_address")),
                      validator: (permanentAddress) {
                        if (permanentAddress.isEmpty) {
                          var msg = getTranslated(
                              context, "Permanent_address_required");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CountriesFormField(
                      labelText: getTranslated(context, "kyc_select_country"),
                      initialCountryCode: 'PH',
                      onChanged: (country) {
                        if (country != null) {
                          onCountryChange(country);
                        }
                      },
                      validator: (country) {
                        if (country == null) {
                          var msg =
                              getTranslated(context, "kyc_country_select");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Radio(
                          groupValue: kycGenderIndex,
                          value: 0,
                          onChanged: _handleRadioValueChange,
                        ),
                        Text(getTranslated(context, "kyc_male")),
                        Radio(
                            groupValue: kycGenderIndex,
                            value: 1,
                            onChanged: _handleRadioValueChange),
                        Text(getTranslated(context, "kyc_female")),
                      ],
                    ),
                    TextFormField(
                      controller: workType,
                      decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "kyc_work_employer")),
                      validator: (workType) {
                        if (workType.isEmpty) {
                          var msg = getTranslated(
                              context, "kyc_work_employer_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: _selectedKycIdTypes,
                      items: _dropdownMenuItems,
                      onChanged: onChangeDropdownItem,
                    ),
                    TextFormField(
                      controller: tinSssNumber,
                      decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "kyc_tin_sss_number")),
                      validator: (tinSssNumber) {
                        if (tinSssNumber.isEmpty) {
                          var msg = getTranslated(
                              context, "kyc_tin_sss_number_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: birthPlace,
                      decoration: InputDecoration(
                          labelText: getTranslated(context, "kyc_birth_place")),
                      validator: (birthPlace) {
                        if (birthPlace.isEmpty) {
                          var msg =
                              getTranslated(context, "kyc_birth_place_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    DateTimeFormField(
                      type: DateTimePickerType.date,
                      controller: _dateTimeController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.date_range),
                        labelText: getTranslated(context, "kyc_date_of_birth"),
                      ),
                      validator: (value) {
                        if (value == null) {
                          var msg =
                              getTranslated(context, "kyc_select_valid_date");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: sourceOfFund,
                      decoration: new InputDecoration(
                          labelText: getTranslated(context, "kyc_source_fund")),
                      validator: (sourceOfFund) {
                        if (sourceOfFund.isEmpty) {
                          var msg =
                              getTranslated(context, "kyc_source_fund_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(getTranslated(context, "save")),
                      onPressed: () {
                        setState(() {
                          enableAutoValidate = true;
                        });
                        if (_formKey.currentState.validate()) {
                          saveKYCDataHandler();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (verificationLevel == "pending") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      label: getTranslated(context, "kyc_pending_verification"),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            if (verificationLevel == "unapproved") ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                        color: Colors.red,
                        label: getTranslated(context, "kyc_verification_faild"),
                        onPressed: onVerificationClick),
                  ),
                ],
              ),
            ],
            if (verificationLevel == "approved") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      label: getTranslated(context, "kyc_verified"),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      )),
    );
  }
}

class KYCIDTYPES {
  int value;
  String name;

  KYCIDTYPES(this.value, this.name);

  static List<KYCIDTYPES> getKycIdTypes() {
    return <KYCIDTYPES>[
      KYCIDTYPES(1, 'TIN'),
      KYCIDTYPES(2, 'SSS'),
      KYCIDTYPES(3, 'GSIS'),
      KYCIDTYPES(4, 'OTHER'),
    ];
  }
}
