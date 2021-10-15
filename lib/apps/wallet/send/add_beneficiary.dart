import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class AddBeneficiary extends StatefulWidget {
  final String bankName;
  final String bankCode;

  const AddBeneficiary({
    Key key,
    this.bankName,
    this.bankCode,
  }) : super(key: key);

  @override
  _AddBeneficiaryState createState() => _AddBeneficiaryState();
}

class _AddBeneficiaryState extends State<AddBeneficiary> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressOneController = TextEditingController();
  TextEditingController _addressTwoController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _zipController = TextEditingController();

  String callingCode = 'PH';
  String callingPhonecode = '+63';

  String countryCode = 'PH';
  String countryId = '174';

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _mobileController.dispose();
    _addressOneController.dispose();
    _addressTwoController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void onCallingChange(Map country) {
    callingPhonecode = country['dial_code'];
  }

  void onCountryChange(Map country) {
    countryCode = country['code'];
    countryId = country['id'];
  }

  void addBeneficiaryHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['bank_name'] = widget.bankName;
    apiBodyObj['bank_code'] = widget.bankCode;

    apiBodyObj['beneficiary_name'] = _nameController.text;
    apiBodyObj['bank_account_number'] = _accountNumberController.text;
    apiBodyObj['mobile_country_code'] = callingPhonecode;
    apiBodyObj['mobile_number'] = _mobileController.text;

    apiBodyObj['beneficiary_add_line1'] = _addressOneController.text;
    apiBodyObj['beneficiary_add_line2'] = _addressTwoController.text;
    apiBodyObj['beneficiary_city'] = _cityController.text;
    apiBodyObj['beneficiary_province'] = _provinceController.text;
    apiBodyObj['beneficiary_zipCode'] = _zipController.text;
    apiBodyObj['beneficiary_country'] = countryId;

    Map<String, dynamic> response =
        await NetworkHelper.request('bank/AddBeneficiary', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, true);
      // showSimpleDialog(context,
      //     title: 'Beneficiary',
      //     message:
      //         'Beneficiary added successfully. For next ${responseMap['cooling_period_in_hours']} hours transaction limit for this beneficiary will be ${responseMap['cooling_period_max_amount']}  PHP.');
      showSnackBar(
          'Beneficiary added successfully. For next ${response['cooling_period_in_hours']} hours transaction limit for this beneficiary will be ${response['cooling_period_max_amount']}  PHP.');
    } else {
      if (response['error'] ==
          'cooling_period_max_amount_not_found_please_contact_support') {
        showSnackBar(
            'Unable to process your request at this time. Please try again later.');
      } else if (response['error'] ==
          'cooling_period_in_hours_not_found_please_contact_support') {
        showSnackBar(
            'Unable to process your request at this time. Please try again later.');
      } else {
        showSnackBar(
            'Unable to process your request at this time. Please try again later.');
      }
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          'Add Beneficiary',
        ),
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Beneficiary name',
                  ),
                  validator: (value) {
                    if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                      return 'Please enter beneficiary name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    labelText: 'Account Number',
                  ),
                  validator: (value) {
                    if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                      return 'Please enter Account Number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 130,
                      child: CountriesFormField(
                        labelText: 'Dialing Code',
                        initialCountryCode: callingCode,
                        showName: false,
                        onChanged: (country) {
                          if (country != null) {
                            onCallingChange(country);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value,
                              allowEmptySpaces: false)) {
                            return 'Please enter Mobile Number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _addressOneController,
                  decoration: InputDecoration(
                    labelText: 'Address Line 1',
                  ),
                  minLines: 2,
                  maxLines: null,
                ),
                TextFormField(
                  controller: _addressTwoController,
                  decoration: InputDecoration(
                    labelText: 'Address Line 2',
                  ),
                  minLines: 2,
                  maxLines: null,
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                  ),
                ),
                TextFormField(
                  controller: _provinceController,
                  decoration: InputDecoration(
                    labelText: 'Province/Region',
                  ),
                ),
                TextFormField(
                  controller: _zipController,
                  decoration: InputDecoration(
                    labelText: 'ZIP/Postal Code',
                  ),
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
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('ADD'),
                  onPressed: () {
                    setState(() {
                      enableAutoValidate = true;
                    });
                    if (_formKey.currentState.validate()) {
                      addBeneficiaryHandler();
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
