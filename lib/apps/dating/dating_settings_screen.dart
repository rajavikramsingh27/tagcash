import 'package:flutter/material.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/apps/dating/models/dating_cities.dart';
import 'package:tagcash/apps/dating/models/dating_profiledetails.dart';
import 'package:tagcash/apps/dating/dating_settings_photos_screen.dart';
import 'package:tagcash/apps/dating/dating_settings_privacy_screen.dart';
import 'package:tagcash/apps/dating/dating_settings_notification_screen.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/utils/countries.dart';
import 'package:tagcash/apps/dating/dating_home_screen.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingSettingsScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  DatingSettingsScreen({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _DatingSettingsScreen createState() => _DatingSettingsScreen();
}

class _DatingSettingsScreen extends State<DatingSettingsScreen> {
  String countryCode;
  String countryId;
  final _formKey = GlobalKey<FormState>();
  bool isProfile = true;
  bool isPhotos = false;
  bool isPrivacy = false;
  bool isNotifications = false;
  bool isDelete = false;
  TextEditingController _dateController;
  TextEditingController _notesController;
  TextEditingController _nicknameController;
  TextEditingController _occupationController;

  bool isLoading = false;
  bool isCityLoading = false;
  bool enableAutoValidate = false;
  bool saveClickPossible = true;
  String gender = "male";
  String age = "";
  String apiDateofbirthFormat = null;
  Future<List<Cities>> citiesList;
  Cities citySelected;
  bool valueMales = false;
  bool valueFemales = false;
  bool valueTransgenders = false;
  Future<DatingProfileDetails> datingprofileDetailsData;
  bool profileAlreadyCreated = false;
  int selectedCityid = null;
  bool isProfileVisitNotification = false;
  bool isReceiveMessageNotification = false;
  bool isEmailNofification = false;
  List<UploadedImages> uploadedImages;
  bool countryChnageFlag = false;
  bool _isCountryLoaded = false;
  bool _isCityLoaded = false;

  @override
  void initState() {
    super.initState();
    print("Module ID-->"+AppConstants.activeModule);
    _dateController = TextEditingController();
    _notesController = TextEditingController();
    _nicknameController = TextEditingController();
    _occupationController = TextEditingController();
    loadProfileDetails();
  }

  void deleteProfileProcessHandler() async {
    Navigator.pop(context);
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/DeleteProfile', apiBodyObj);


    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DatingHomeScreen()),
      );
      showInSnackBar(getTranslated(context, "dating_delete_message"));
    } else {
      if (response['error'] == "failed_to_delete_profile_details") {
        showInSnackBar(getTranslated(context, "dating_deleteprofile_failed"));
      } else if (response['error'] == "request_not_completed") {
        showInSnackBar(getTranslated(context, "dating_request_notcompleted"));
      } else if (response['error'] == "profile_details_not_found") {
        showInSnackBar(getTranslated(context, "dating_profile_notfound"));
      } else {
        showInSnackBar(getTranslated(context, "dating_profile_delete_failed"));
      }
    }
  }

  Future<List<Cities>> getCitiesListDataBlank() async {
    return null;
  }

  void confirmDeleteAlertShow() {

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        getTranslated(context, "dating_deleteprofile_message"),
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Color(0xFFDF1C1C),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  CustomButton(
                      label:
                          getTranslated(context, "dating_deleteprofile_images"),
                      onPressed: () {
                        deleteProfileProcessHandler();
                      })
                ],
              ),
            ),
          );
        });
  }



  void loadProfileDetails() {
    datingprofileDetailsData = fetchProfileDetails()
        .then((DatingProfileDetails datingprofileDetailsData) {
print(datingprofileDetailsData.profileDetails.description);
      profileAlreadyCreated = true;
      setProfileValues(datingprofileDetailsData);
    }).catchError((error) {
      if (error == "profile not created") {

        profileAlreadyCreated = false;
        countryId = "174";
        countryCode = "PH";
        _isCountryLoaded = true;
        citiesList = loadCountryCitiesList(countryId);
      }
      else{
      }
    });
  }

  void setProfileValues( DatingProfileDetails datingprofileDetailsData) {

    countryId = datingprofileDetailsData.profileDetails.countryId.toString();
    //countryCode="IN";

    Map<String, String> _selectedCountry =
        countries.firstWhere((item) => item['id'] == countryId);
    countryCode = _selectedCountry['code'];

    _isCountryLoaded = true;
    selectedCityid = datingprofileDetailsData.profileDetails.cityId;

    _nicknameController.text = datingprofileDetailsData.profileDetails.nickName;
    _occupationController.text =
        datingprofileDetailsData.profileDetails.occupation;
    DateTime birthDate = DateTime.parse(
        datingprofileDetailsData.profileDetails.dob + " " + "00:00:00");
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(birthDate);

    _dateController.text = formatted;
    final DateFormat apiformatter = DateFormat('yyyy-MM-dd');
    apiDateofbirthFormat = apiformatter.format(birthDate);


    age = datingprofileDetailsData.profileDetails.age.toString();
    _notesController.text = datingprofileDetailsData.profileDetails.description;
    if (datingprofileDetailsData.profileDetails.genderId == 1) {

      gender = "male";
    } else if (datingprofileDetailsData.profileDetails.genderId == 2) {

      gender = "female";
    } else {

      gender = "transgender";
    }
    int privacy_gendermaleStatus =
        datingprofileDetailsData.profileDetails.privacySettings.maleStatus;
    int privacy_genderfemaleStatus =
        datingprofileDetailsData.profileDetails.privacySettings.femaleStatus;
    int privacy_genderTransgenderStatus =
        datingprofileDetailsData.profileDetails.privacySettings.tgStatus;


    if (privacy_gendermaleStatus == 1) {
      valueMales = true;
    } else {
      valueMales = false;
    }
    if (privacy_genderfemaleStatus == 1) {
      valueFemales = true;
    } else {
      valueFemales = false;
    }
    if (privacy_genderTransgenderStatus == 1) {
      valueTransgenders = true;
    } else {
      valueTransgenders = false;
    }

    int notification_profilevisits = datingprofileDetailsData
        .profileDetails.notificationSettings.profileVisits;
    int notification_receivemessage = datingprofileDetailsData
        .profileDetails.notificationSettings.receiveNewmessageStatus;
    int notification_email = datingprofileDetailsData
        .profileDetails.notificationSettings.emailStatus;

    if (notification_profilevisits == 1) {
      isProfileVisitNotification = true;
    } else {
      isProfileVisitNotification = false;
    }
    if (notification_receivemessage == 1) {
      isReceiveMessageNotification = true;
    } else {
      isReceiveMessageNotification = false;
    }
    if (notification_email == 1) {
      isEmailNofification = true;
    } else {
      isEmailNofification = false;
    }
    uploadedImages = [];
    uploadedImages = datingprofileDetailsData.profileDetails.uploadedImages;

    uploadedImages.add(UploadedImages(
        id: null,
        imageFileName: null,
        imageName: null,
        mainStatus: 0,
        uploadedDate: null));


    setState(() {

    });
    if (citiesList == null) {
      citiesList = loadCountryCitiesList(countryId);
      citiesList.then((citiesDummyList) {
        if (citiesDummyList != null && citiesDummyList.length > 0) {
          citiesDummyList.forEach((cityobj) {

            if (cityobj.cityId == selectedCityid) {

              citySelected = cityobj;
            }
          });
        }
      });
    } else {

    }

  }

  void showInSnackBar(String value) {
    /*
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value), backgroundColor: Colors.red[600]));
    */
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
      content: new Text(value),
      backgroundColor: Colors.red[600],
      duration: new Duration(seconds: 3),
    ));
  }

  Future<DatingProfileDetails> fetchProfileDetails() async {
//await loadCountryCitiesList();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/GetMyProfileDetails', apiBodyObj);


    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {

      DatingProfileDetails datingprofileDetails =
          DatingProfileDetails.fromJson(response['profile_details']);

      return datingprofileDetails;
    } else if (response['error'] == 'failed_to_get_data') {
      throw ("profile not created");
    }
  }

  Future<List<Cities>> loadCountryCitiesList(String countryId) async {

    setState(() {
      isCityLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['country_id'] = countryId;
    Map<String, dynamic> response = await NetworkHelper.request(
        'Dating/GetCitiesFromCountryId', apiBodyObj);

    setState(() {
      isCityLoading = false;
    });
    _isCityLoaded = true;
    if (response["status"] == "success") {
      List responseList = response['cities'];
      if (responseList.length > 0) {
        List<Cities> getData = responseList.map<Cities>((json) {
          return Cities.fromJson(json);
        }).toList();

        if (getData.length != 0) {
          citySelected = getData[0];
        } else {
          citySelected = null;
        }
        return getData;
      } else {
        citySelected = null;
        return null;
      }
    } else {
      citySelected = null;
      return null;
    }
  }

  void saveProfileProcess() async {
    Map<String, dynamic> response = null;
    String gender_id;
    if (gender == "male") {
      gender_id = "1";
    } else if (gender == "female") {
      gender_id = "2";
    } else {
      gender_id = "3";
    }
    String nicknameValue = _nicknameController.text;
    String occupationValue = _occupationController.text;
    String descriptionValue = _notesController.text;


    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['nick_name'] = nicknameValue;
    apiBodyObj['occupation'] = occupationValue;
    apiBodyObj['dob'] = apiDateofbirthFormat;
    apiBodyObj['gender_id'] = gender_id.toString();
    apiBodyObj['country_id'] = countryId.toString();
    apiBodyObj['city_id'] = citySelected.cityId.toString();
    apiBodyObj['description'] = descriptionValue;
    if (profileAlreadyCreated == false) {
      response =
          await NetworkHelper.request('Dating/ProfileCreate', apiBodyObj);

    } else {
      response =
          await NetworkHelper.request('Dating/UpdateProfile', apiBodyObj);

    }
    setState(() {
      isLoading = false;
      saveClickPossible = true;
    });

    if (profileAlreadyCreated == false) {
      if (response['status'] == 'success') {

        profileAlreadyCreated = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("countryId", countryId.toString());
        prefs.setString("gender", gender);
        prefs.setString("countrycode", countryCode);
        showInSnackBar(getTranslated(context, 'dating_profilecreate_success'));
        uploadedImages = [];

        uploadedImages.add(UploadedImages(
            id: null,
            imageFileName: null,
            imageName: null,
            mainStatus: 0,
            uploadedDate: null));
      } else {
        if (response['error'] == "profile_already_created") {

          showInSnackBar(
              getTranslated(context, 'dating_profilealready_created'));
        } else if (response['error'] == "request_not_completed") {
          showInSnackBar(
              getTranslated(context, "dating_profile_requestnotcompleted"));
        } else if (response['error'] == "switch_to_user_perspective") {
          showInSnackBar(getTranslated(context, "dating_switchperspective"));
        }
      }
    } else {
      if (response['status'] == 'success') {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("countryId", countryId.toString());
        prefs.setString("countrycode", countryCode);
        prefs.setString("gender", gender);

        String filterValues = prefs.getString('filterValues');

        /*We need to update filter with gender*/
        if (filterValues != null) {
          Map<String, dynamic> filterValuesMap = jsonDecode(filterValues);
          filterValuesMap.update("gender_id", (v) {
            if (gender == "male") {
              return 2;
            } else if (gender == "female") {
              return 1;
            } else {
              return 1;
            }
          });
          var encodedFilterValues = json.encode(filterValuesMap);

          prefs.setString("filterValues", encodedFilterValues);
        }

        showInSnackBar(getTranslated(context, "dating_profileupdate_success"));
      } else {
        if (response['error'] == "failed_to_update_profile_data") {

          showInSnackBar(
              getTranslated(context, "dating_profileupdation_failed"));
        } else if (response['error'] == "request_not_completed") {
          showInSnackBar(
              getTranslated(context, "dating_profile_requestnotcompleted"));
        } else if (response['error'] == "profile_details_not_found") {
          showInSnackBar(
              getTranslated(context, "dating_profiledetails_notfound"));
        }
      }
    }
  }

  void onCountryChange(Map country) {

    countryId = country['id'];
    countryCode = country['code'];

    countryChnageFlag = true;
    citiesList = getCitiesListDataBlank();
    citiesList = loadCountryCitiesList(countryId);
  }

  void saveProfileClickHandler() {
    if (citySelected == null) {
      showInSnackBar("No Cities Found!!");
      return;
    }
    setState(() {
      isLoading = true;
      saveClickPossible = false;
    });

    saveProfileProcess();
  }

/*
  int getGenderStatusValue(String genderStatus) {

    int value = 0;
    switch (genderStatus) {
      case "male":
        {
          value = 1;
        }
        break;
      case "female":
        {
          value = 2;
        }
        break;
      case "transgender":
        {
          value = 3;
        }
        break;
    }
    return value;
  }
*/


  @override
  Widget build(BuildContext context) {
    DateTime nowDate = DateTime.now();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: nowDate,
          firstDate: DateTime(1950, 8),
          lastDate: DateTime(2021, 12));
      if (picked != null && picked != nowDate)
        setState(() {

          int diffDays = (nowDate.difference(picked).inDays);
          String differenceInYears = (diffDays / 365).floor().toString();
          age = differenceInYears;
          if (int.parse(age) < 18) {
            age = "";
            nowDate = picked;
            final DateFormat formatter = DateFormat('dd-MM-yyyy');
            final String formatted = formatter.format(nowDate);
            _dateController.text = formatted;
            showInSnackBar(getTranslated(context, "dating_age_restriction"));
          } else {
            nowDate = picked;
            final DateFormat formatter = DateFormat('dd-MM-yyyy');
            final String formatted = formatter.format(nowDate);
            final DateFormat apiformatter = DateFormat('yyyy-MM-dd');
            apiDateofbirthFormat = apiformatter.format(nowDate);
            _dateController.text = formatted;
          }
        });
    }

    void showCalendar() {
      _selectDate(context);
    }



    Widget profileSection = Stack(
      children: [
        Form(
            key: _formKey,
            autovalidateMode: enableAutoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              children: [
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Nickname',
                    hintText: 'Nickname',
                  ),
                  validator: (value) {
                    if (!Validator.isRequired(value)) {
                      return getTranslated(context, "dating_valid_nickname");
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _occupationController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.assignment_ind),
                    labelText: 'Occupation',
                    hintText: 'Occupation',
                  ),
                  validator: (value) {
                    if (!Validator.isRequired(value)) {
                      return getTranslated(context, "dating_valid_occupation");
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline, // <--
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.developer_board),
                          labelText: 'Date Of Birth',
                          hintText: 'Date of Birth',
                        ),
                        showCursor: false,
                        readOnly: true,
                        controller: _dateController,
                        onTap: showCalendar,
                        validator: (value) {
                          if (Validator.isValidAge(value)) {
                            return null;
                          } else {
                            return "Please enter valid age";
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          age,
                          style: TextStyle(
                              fontSize: 34, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 24.0,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(12, 10, 0, 10),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 18,
                          elevation: 12,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          value: gender,
                          onChanged: (String newValue) {
                            gender = newValue;

                          },
                          items: <String>["male", "female", "transgender"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.toString(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _isCountryLoaded
                    ? CountriesFormField(
                        labelText: getTranslated(context,"dating_select_country"),
                        initialCountryCode: countryCode,
                        onChanged: (country) {
                          if (country != null) {
                            onCountryChange(country);
                          }
                        },
                      )
                    : SizedBox(height: 10),
                _isCityLoaded
                    ? Row(
                        children: [
                          Container(
                            child: Icon(
                              Icons.location_city,
                              color: Colors.grey,
                              size: 24.0,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(12, 10, 0, 10),
                              child: FutureBuilder(
                                  future: citiesList,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<Cities>> snapshot) {
                                    if (snapshot.hasError)
                                      print(snapshot.error);
                                    if (snapshot.data == null) {
                                      return Text(getTranslated(context,"dating_nocities_found"));
                                    }
                                    return snapshot.hasData
                                        ? DropdownButtonFormField<Cities>(
                                            icon: Icon(Icons.arrow_downward),
                                            iconSize: 18,
                                            elevation: 12,
                                            items: snapshot.data
                                                .map((city) =>
                                                    DropdownMenuItem<Cities>(
                                                      child:
                                                          Text(city.cityName),
                                                      value: city,
                                                    ))
                                                .toList(),
                                            onChanged: (Cities value) {
                                              setState(() {
                                                citySelected = value;
                                              });
                                            },
                                            value: citySelected,
                                            isExpanded: true,
                                          )
                                        : SizedBox();
                                  }),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: TextFormField(
                    validator: (value) {
                      if (!Validator.isRequired(value)) {
                        return 'Please enter valid description';
                      }
                      return null;
                    },
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          "Description about yourself and what you are looking for",
                      border: OutlineInputBorder(),
                    ),
                    controller: _notesController,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  // height: double.infinity,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: CustomButton(
                      label: 'SAVE',
                      onPressed: saveClickPossible
                          ? () {
                              setState(() {

                                enableAutoValidate = true;
                              });
                              if (_formKey.currentState.validate()) {

                                saveProfileClickHandler();
                              } else {

                              }
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            )),
      ],
    );

    return Stack(
      children: [
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child:
                 (!kIsWeb)?
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5.5,
                          height: 40,
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.person,
                              color: isProfile ? Colors.white : Colors.grey,
                              size: 30,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            border: Border(
                              top: BorderSide(color: Color(0XFF7E7A78)),
                              bottom: BorderSide(color: Color(0XFF7E7A78)),
                              right: BorderSide(color: Color(0XFF7E7A78)),
                              left: BorderSide(color: Color(0XFF7E7A78)),
                            ),
                            color: isProfile ? Colors.grey : Colors.white,
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            isProfile = true;
                            isPhotos = false;
                            isPrivacy = false;
                            isNotifications = false;
                            isDelete = false;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5.5,
                          height: 40,
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.camera_alt,
                              color: isPhotos ? Colors.white : Colors.grey,
                              size: 30,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Color(0XFF7E7A78)),
                                bottom: BorderSide(color: Color(0XFF7E7A78))),
                            color: isPhotos ? Colors.grey : Colors.white,
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            isProfile = false;
                            isPhotos = true;
                            isPrivacy = false;
                            isDelete = false;
                            isNotifications = false;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5.8,
                          height: 40,
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.lock,
                              color: isPrivacy ? Colors.white : Colors.grey,
                              size: 30,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0XFF7E7A78)),
                              bottom: BorderSide(color: Color(0XFF7E7A78)),
                              right: BorderSide(color: Color(0XFF7E7A78)),
                              left: BorderSide(color: Color(0XFF7E7A78)),
                            ),
                            color: isPrivacy ? Colors.grey : Colors.white,
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            isProfile = false;
                            isPhotos = false;
                            isPrivacy = true;
                            isNotifications = false;
                            isDelete = false;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5.5,
                          height: 40,
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.notifications_active,
                              color:
                                  isNotifications ? Colors.white : Colors.grey,
                              size: 30,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0XFF7E7A78)),
                              bottom: BorderSide(color: Color(0XFF7E7A78)),
                            ),
                            color: isNotifications ? Colors.grey : Colors.white,
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            isProfile = false;
                            isPhotos = false;
                            isPrivacy = false;
                            isNotifications = true;
                            isDelete = false;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 5.5,
                          height: 40,
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Container(
                            padding: const EdgeInsets.all(0.0),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                Icons.delete,
                                color: isDelete ? Colors.white : Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            border: Border(
                              top: BorderSide(color: Color(0XFF7E7A78)),
                              bottom: BorderSide(color: Color(0XFF7E7A78)),
                              right: BorderSide(color: Color(0XFF7E7A78)),
                              left: BorderSide(color: Color(0XFF7E7A78)),
                            ),
                            color: isDelete ? Colors.grey : Colors.white,
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            isProfile = false;
                            isPhotos = false;
                            isPrivacy = false;
                            isDelete = true;
                            isNotifications = false;
                            confirmDeleteAlertShow();
                          });
                        },
                      ),
                    ],
                  ):
                    Row(
                      children: [
                        Expanded(
                          child:
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 5.5,
                              height: 40,
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.person,
                                  color: isProfile ? Colors.white : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                border: Border(
                                  top: BorderSide(color: Color(0XFF7E7A78)),
                                  bottom: BorderSide(color: Color(0XFF7E7A78)),
                                  right: BorderSide(color: Color(0XFF7E7A78)),
                                  left: BorderSide(color: Color(0XFF7E7A78)),
                                ),
                                color: isProfile ? Colors.grey : Colors.white,
                              ),
                            ),
                            onTap: () {

                              setState(() {
                                isProfile = true;
                                isPhotos = false;
                                isPrivacy = false;
                                isNotifications = false;
                                isDelete = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child:
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 5.5,
                              height: 40,
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: isPhotos ? Colors.white : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Color(0XFF7E7A78)),
                                    bottom: BorderSide(color: Color(0XFF7E7A78))),
                                color: isPhotos ? Colors.grey : Colors.white,
                              ),
                            ),
                            onTap: () {

                              setState(() {
                                isProfile = false;
                                isPhotos = true;
                                isPrivacy = false;
                                isDelete = false;
                                isNotifications = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child:
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 5.8,
                              height: 40,
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.lock,
                                  color: isPrivacy ? Colors.white : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0XFF7E7A78)),
                                  bottom: BorderSide(color: Color(0XFF7E7A78)),
                                  right: BorderSide(color: Color(0XFF7E7A78)),
                                  left: BorderSide(color: Color(0XFF7E7A78)),
                                ),
                                color: isPrivacy ? Colors.grey : Colors.white,
                              ),
                            ),
                            onTap: () {

                              setState(() {
                                isProfile = false;
                                isPhotos = false;
                                isPrivacy = true;
                                isNotifications = false;
                                isDelete = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child:
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 5.5,
                              height: 40,
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(
                                  Icons.notifications_active,
                                  color:
                                  isNotifications ? Colors.white : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0XFF7E7A78)),
                                  bottom: BorderSide(color: Color(0XFF7E7A78)),
                                ),
                                color: isNotifications ? Colors.grey : Colors.white,
                              ),
                            ),
                            onTap: () {

                              setState(() {
                                isProfile = false;
                                isPhotos = false;
                                isPrivacy = false;
                                isNotifications = true;
                                isDelete = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child:
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 5.5,
                              height: 40,
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Container(
                                padding: const EdgeInsets.all(0.0),
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
                                    Icons.delete,
                                    color: isDelete ? Colors.white : Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                border: Border(
                                  top: BorderSide(color: Color(0XFF7E7A78)),
                                  bottom: BorderSide(color: Color(0XFF7E7A78)),
                                  right: BorderSide(color: Color(0XFF7E7A78)),
                                  left: BorderSide(color: Color(0XFF7E7A78)),
                                ),
                                color: isDelete ? Colors.grey : Colors.white,
                              ),
                            ),
                            onTap: () {

                              setState(() {
                                isProfile = false;
                                isPhotos = false;
                                isPrivacy = false;
                                isDelete = true;
                                isNotifications = false;
                                confirmDeleteAlertShow();
                              });
                            },
                          ),
                        ),

                      ],
                    ),
                ),
                isProfile
                    ? Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: profileSection,
                      )
                    : SizedBox(),
                isPrivacy
                    ? Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        //   child: privacySection,
                        child: DatingSettingsPrivacyScreen(
                          valueMales: valueMales,
                          valueFemales: valueFemales,
                          valueTransgenders: valueTransgenders,
                          ongenderStatusChnaged: () {

                            loadProfileDetails();
                          },
                          scaffoldKey: widget.scaffoldKey,
                        ),
                      )
                    : SizedBox(),
                isPhotos
                    ? Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        // child: photosSection,
                        child: DatingSettingsPhotoScreen(
                          uploadedImages: uploadedImages,
                          onImageAddedOrDeleted: () {

                            loadProfileDetails();
                          },
                          onLoading: (bool val) {
                            setState(() {
                              isLoading = val;
                            });
                          },
                          datingProfileDetails:
                              (DatingProfileDetails datingProfileDetailsPhoto) {

                            setProfileValues(datingProfileDetailsPhoto);
                          },
                          scaffoldKey: widget.scaffoldKey,
                        ),
                      )
                    : SizedBox(),
                isNotifications
                    ? Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: DatingSettingsNotificationScreen(
                          valueProfileVisits: isProfileVisitNotification,
                          valueReceiveMessage: isReceiveMessageNotification,
                          valueEmail: isEmailNofification,
                          onnotificationStatusChnaged: () {

                            loadProfileDetails();
                          },
                          scaffoldKey: widget.scaffoldKey,
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ],
        ),
        isLoading ? Container(child: Center(child: Loading())) : SizedBox(),
        isCityLoading ? Container(child: Center(child: Loading())) : SizedBox(),
      ],
    );
  }
}
