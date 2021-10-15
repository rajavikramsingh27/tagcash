import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/apps/dating/models/dating_cities.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingFilterScreen extends StatefulWidget {
  @override
  _DatingFilterScreen createState() => _DatingFilterScreen();
}

class _DatingFilterScreen extends State<DatingFilterScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String countryId;
  String countryCode;
  bool _isCountryLoaded = false;
  Future<List<Cities>> citiesList;
  String gender = "male";
  String filterDropdownfavourite = "All";
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  List<Cities> citiesListData = null;
  Cities selectedCity;
  bool isLoading = false;
  bool countryChangeFlag = false;
  bool enableAutoValidate = false;
  List<String> filterDropdownList = [];
  @override
  void initState() {
    super.initState();
    citiesList = loadCountryCitiesList(countryId);
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    filterDropdownList.add(getTranslated(context,"dating_filter_all"));
    filterDropdownList.add(getTranslated(context,"dating_filter_myfavourites"));
    filterDropdownList.add(getTranslated(context,"dating_filter_favouritedme"));
    filterDropdownList.add(getTranslated(context, "dating_filter_visits"));
    filterDropdownList.add(getTranslated(context,"dating_filter_visitedme"));
    filterDropdownList.add(getTranslated(context,"dating_filter_matches"));
    filterDropdownfavourite= filterDropdownList[0].toString();
    super.didChangeDependencies();
  }

  void onCountryChange(Map country) {
    countryId = country['id'];
    countryCode = country['code'];
    countryChangeFlag = true;
    citiesList = getCitiesListDataBlank();
    citiesList = loadCountryCitiesList(countryId);

  }

  Future<List<Cities>> getCitiesListDataBlank() async {
    return null;
  }

  Future<List<Cities>> loadCountryCitiesList(String countryid) async {
    if (countryid == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String filterValues = prefs.getString('filterValues');

      if (filterValues != null) {
        Map<String, dynamic> filterValuesMap = jsonDecode(filterValues);
        if (filterValuesMap['gender_id'] == 1) {
          gender = "male";
        } else if (filterValuesMap['gender_id'] == 2) {
          gender = "female";
        } else {
          gender = "transgender";
        }
        countryId = filterValuesMap['country_id'];
        countryCode = filterValuesMap['country_code'];

      } else {
        countryId = prefs.getString("countryId");
      }
    } else {

      countryId = countryid;

    }
    if (countryId == "" || countryId == null) {
      countryId = "174";
    }

    List<Cities> citiesList = new List();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['country_id'] = countryId;
    Map<String, dynamic> response = await NetworkHelper.request(
        'Dating/GetCitiesFromCountryId', apiBodyObj);
    setState(() {
      isLoading = false;

    });

    if (response["status"] == "success") {
      List responseList = response['cities'];
      if (responseList.length > 0) {
        citiesList.add(Cities("0", "All Cities"));
        List<Cities> getData = responseList.map<Cities>((json) {
          return Cities.fromJson(json);
        }).toList();
        citiesList.addAll(getData);
        selectedCity = citiesList[0];
        citiesListData = citiesList;
        if (countryChangeFlag == false) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String filterValues = prefs.getString('filterValues');
          if (filterValues != null) {
            setFilterValues(filterValues);
          } else {

            countryId = prefs.getString("countryId");
            countryCode = prefs.getString("countrycode");
            gender = prefs.getString("gender");
            _isCountryLoaded = true;
            if (countryId == "" || countryId == null) {
              countryId = "174";
              countryCode = "PH";
            }
            if (gender == "" || gender == null) {
              gender = "male";
            } else {
              if (gender == "male") {
                gender = "female";
              } else if (gender == "female") {
                gender = "male";
              } else {
                gender = "female";
              }
            }
            _minAgeController.text = "18";
            _maxAgeController.text = "80";
          }
        }

        //  return null;

        return citiesList;
      } else {
        _isCountryLoaded = true;
        _minAgeController.text = "18";
        _maxAgeController.text = "80";
        selectedCity = null;
        return null;
      }
    }
  }

  String getGenderStatusText(int genderStatus) {
    String value = "";
    switch (genderStatus) {
      case 1:
        {
          value = "male";
        }
        break;
      case 2:
        {
          value = "female";
        }
        break;
      case 3:
        {
          value = "transgender";
        }
        break;
    }
    return value;
  }

  int getFilterListValue(String listValue) {
    int value = 1;
    switch (listValue) {
      case "All":
        {
          value = 0;
        }
        break;
      case "My Favourites":
        {
          value = 1;
        }
        break;
      case "Who Favourited Me":
        {
          value = 2;
        }
        break;
      case "My Visits":
        {
          value = 3;
        }
        break;
      case "Who Visited me":
        {
          value = 4;
        }
        break;
      case "My Matches":
        {
          value = 5;
        }
        break;
    }
    return value;
  }

  String getFilterTextListValue(int listValue) {
    String value = "";
    switch (listValue) {
      case 0:
        {
       //   value = "All";
         value=getTranslated(context, "dating_filter_all") ;
        }
        break;
      case 1:
        {
       //   value = "My Favourites";
          value=getTranslated(context, "dating_filter_myfavourites") ;
        }
        break;
      case 2:
        {
      //    value = "Who Favourited Me";
          value=getTranslated(context, "dating_filter_favouritedme") ;
        }
        break;
      case 3:
        {
        //  value = "My Visits";
          value=getTranslated(context, "dating_filter_visits") ;
        }
        break;
      case 4:
        {
         // value = "Who Visited me";
          value=getTranslated(context, "dating_filter_visitedme") ;
        }
        break;
      case 5:
        {
        //  value = "My Matches";
          value=getTranslated(context, "dating_filter_matches") ;
        }
        break;
    }
    return value;
  }

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

  void setFilterValues(filterValues) {
    Map<String, dynamic> filterValuesMap = jsonDecode(filterValues);
    gender = getGenderStatusText(filterValuesMap['gender_id']);
    _minAgeController.text = filterValuesMap['min_age'];
    _maxAgeController.text = filterValuesMap['max_age'];
    if (filterValuesMap['min_age'] == "") {

      _minAgeController.text = "18";
    }
    if (filterValuesMap['max_age'] == "") {

      _maxAgeController.text = "80";
    }
    countryCode = filterValuesMap['country_code'];
    countryId = filterValuesMap['country_id'];
    _isCountryLoaded = true;
    filterDropdownfavourite = getFilterTextListValue(filterValuesMap['lists']);
    if (filterValuesMap['cities'].toString() == "all") {
      selectedCity = citiesListData[0];
    } else {
      citiesListData.forEach((cityObj) {
        if (cityObj.cityId == filterValuesMap['cities']) {

          selectedCity = cityObj;
        } else {
        }
      });
    }

  }

  bool filterAgeValidation() {
    bool value = true;
    if (!_minAgeController.text.toString().isEmpty) {
      if (int.parse(_minAgeController.text.toString()) < 18) {
        value = false;
        return value;
      }
    }
    return value;
  }

  void saveFilterValues() async {
    Map<String, dynamic> filterDetails = new Map();
    filterDetails['gender_id'] = getGenderStatusValue(gender);
    filterDetails['min_age'] = _minAgeController.text;
    filterDetails['max_age'] = _maxAgeController.text;
    filterDetails['country_id'] = countryId;
    filterDetails['country_code'] = countryCode;
    if (selectedCity != null) {
      if (selectedCity.cityId == "0") {
        filterDetails['cities'] = "all";
      } else {
        filterDetails['cities'] = selectedCity.cityId;
      }
    } else {
      filterDetails['cities'] = "";
    }

  //  filterDetails['lists'] = getFilterListValue(filterDropdownfavourite);
    filterDetails['lists'] = filterDropdownList.indexOf(filterDropdownfavourite);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var encodedFilterValues = json.encode(filterDetails);

    prefs.setString("filterValues", encodedFilterValues);

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context,"dating_filter"),
      ),
      body: Stack(
        children: [
          Container(
              child: Form(
            key: _formKey,
            autovalidateMode: enableAutoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Stack(
                children: [
                  ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DropdownButtonFormField<String>(
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: 'Any', labelText:getTranslated(context,"dating_min_age")),
                                  autofocus: false,
                                  controller: _minAgeController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (filterAgeValidation()) {
                                      return null;
                                      // return 'Enter valid amount';
                                    } else {
                                      return getTranslated(context,"dating_beloweighteen_message");
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: 'Any', labelText: getTranslated(context,"dating_max_age")),
                                  autofocus: false,
                                  controller: _maxAgeController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
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
                          SizedBox(height: 10),
                          FutureBuilder(
                              future: citiesList,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Cities>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return Container();
                                }
                                if (snapshot.hasData) {
                                  return DropdownButtonFormField<Cities>(
                                    icon: Icon(Icons.arrow_downward),
                                    iconSize: 18,
                                    elevation: 12,
                                    items: snapshot.data
                                        .map((city) => DropdownMenuItem<Cities>(
                                              child: Text(city.cityName),
                                              value: city,
                                            ))
                                        .toList(),
                                    onChanged: (Cities value) {
                                      setState(() {
                                        selectedCity = value;
                                      });
                                    },
                                    value: selectedCity,
                                    isExpanded: true,
                                  );
                                } else {
                                  return Text(getTranslated(context, "dating_nocities_found"));
                                  ;
                                }
                              }),
                          DropdownButtonFormField<String>(
                            hint: Text("Lists"),
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 18,
                            elevation: 12,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            value: filterDropdownfavourite,
                            onChanged: (String newValue) {
                              filterDropdownfavourite = newValue;

                            },
                            items: <String>[
                              getTranslated(context,"dating_filter_all"),
                              getTranslated(context, "dating_filter_myfavourites"),
                              getTranslated(context, "dating_filter_favouritedme"),
                              getTranslated(context, "dating_filter_visits"),
                              getTranslated(context, "dating_filter_visitedme"),
                              getTranslated(context,"dating_filter_matches"),
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value.toString(),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: getTranslated(context,"dating_update_filter"),
                                  onPressed: () {
                                    setState(() {
                                      enableAutoValidate = true;
                                    });
                                    if (_formKey.currentState.validate()) {
                                      saveFilterValues();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 0),

                  // isBottomSheetCityLoading ? Center(child: Loading()) : SizedBox(),
                ],
              ),
            ),
          )),
          //  isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
