import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/merchant_data.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class MerchantProfileEditScreen extends StatefulWidget {
  @override
  _MerchantProfileEditScreenState createState() =>
      _MerchantProfileEditScreenState();
}

class _MerchantProfileEditScreenState extends State<MerchantProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  MerchantData merchantData;
  String activeId;

  String callingCode;

  String countryCode;
  String countryName;
  String countryId;

  TextEditingController _nameController;
  TextEditingController _mobileController;
  TextEditingController _cityController;
  TextEditingController _detailsController;

  Map<String, String> inputValueObj = {};

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _cityController = TextEditingController();
    _detailsController = TextEditingController();

    showProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _detailsController.dispose();

    super.dispose();
  }

  void showProfileData() {
    merchantData =
        Provider.of<MerchantProvider>(context, listen: false).merchantData;
    // activeId = userData.id.toString();

    _nameController.text = merchantData.name;
    if (merchantData.countryCode != '') {
      callingCode = '+' + merchantData.countryPhonecode;
      countryCode = merchantData.countryCode;
      countryId = merchantData.countryId;
      countryName = merchantData.countryName;
    } else {
      callingCode = '+63';
      countryCode = 'PH';
      countryId = '174';
      countryName = 'Philippines';

      saveFieldDataChanges('country_phonecode', '63');
      saveFieldDataChanges("country_id", '174');
    }

    _mobileController.text = merchantData.communityMobile;

    _cityController.text = merchantData.communityCity;
    _detailsController.text = merchantData.communityDescription;
  }

  void onEditTextChange(String field, String value) {
    saveFieldDataChanges(field, value);
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

  void saveFieldDataChanges(String editedField, dynamic editedValue) {
    inputValueObj[editedField] = editedValue;
  }

  void merchantProfileUpdate() async {
    bool dataPassError = false;

    if (inputValueObj.containsKey('community_mobile')) {
      String value = inputValueObj['community_mobile'];
      if (!Validator.isMobile(value)) {
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
        await NetworkHelper.request('community/edit', inputValueObj);

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (inputValueObj.containsKey('community_name')) {
        merchantData.name = inputValueObj['community_name'];
      }

      if (inputValueObj.containsKey('community_mobile')) {
        merchantData.communityMobile = inputValueObj['community_mobile'];
      }

      merchantData.communityCity = _cityController.text;
      merchantData.communityDescription = _detailsController.text;

      if (inputValueObj.containsKey('country_phonecode')) {
        merchantData.countryPhonecode = inputValueObj['country_phonecode'];
      }
      if (inputValueObj.containsKey('country_id')) {
        merchantData.countryId = inputValueObj['country_id'];

        merchantData.countryCode = countryCode;
        merchantData.countryName = countryName;
      }

      Provider.of<MerchantProvider>(context, listen: false)
          .setMerchantData(merchantData);

      inputValueObj = {};

      Fluttertoast.showToast(msg: 'Profile Updated Successfully');
      Navigator.pop(context);
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: getTranslated(context, 'error_occurred'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Name',
                    ),
                    onChanged: (value) {
                      onEditTextChange('community_name', value);
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
                            onEditTextChange('community_mobile', value);
                          },
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.location_city),
                      labelText: 'City',
                    ),
                    onChanged: (value) {
                      onEditTextChange('community_city', value);
                    },
                  ),
                  TextFormField(
                    controller: _detailsController,
                    minLines: 3,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Details',
                    ),
                    onChanged: (value) {
                      onEditTextChange('community_description', value);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () => merchantProfileUpdate(),
                      child: Text(getTranslated(context, 'save')))
                ],
              )),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
