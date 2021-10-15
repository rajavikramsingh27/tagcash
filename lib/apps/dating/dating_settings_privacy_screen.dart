import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingSettingsPrivacyScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  bool valueMales;
  bool valueFemales;
  bool valueTransgenders;
  VoidCallback ongenderStatusChnaged;

  DatingSettingsPrivacyScreen(
      {@required this.valueMales,
      @required this.valueFemales,
      @required this.valueTransgenders,
      this.ongenderStatusChnaged,
      this.scaffoldKey});

  @override
  _DatingSettingsPrivacyScreen createState() => _DatingSettingsPrivacyScreen(
      valueMales, valueFemales, valueTransgenders, ongenderStatusChnaged);
}

class _DatingSettingsPrivacyScreen extends State<DatingSettingsPrivacyScreen> {
  bool valueMales = false;
  bool valueFemales = false;
  bool valueTransgenders = false;
  VoidCallback ongenderStatusChnaged;
  bool isGenderStatusLoading = false;

  _DatingSettingsPrivacyScreen(
      valueMales, valueFemales, valueTransgenders, ongenderStatusChnaged) {
    this.valueMales = valueMales;
    this.valueFemales = valueFemales;
    this.valueTransgenders = valueTransgenders;
    this.ongenderStatusChnaged = ongenderStatusChnaged;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void showInSnackBar(String value) {
      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFFe44933),
          content: Text(value),
        ),
      );
*/
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(
        content: new Text(value),
        backgroundColor: Colors.red[600],
        duration: new Duration(seconds: 3),
      ));
    }

    void changeGenderPrivacyStatus(
        maleStatusValue, femaleStatusValue, transgenderStatusValue) async {
      setState(() {
        isGenderStatusLoading = true;
      });

      Map<String, String> apiBodyObj = {};
      apiBodyObj['module_id'] = AppConstants.activeModule;
      if (maleStatusValue == true) {
        apiBodyObj['male_status'] = "1";
      } else {
        apiBodyObj['male_status'] = "0";
      }
      if (femaleStatusValue == true) {
        apiBodyObj['female_status'] = "1";
      } else {
        apiBodyObj['female_status'] = "0";
      }
      if (transgenderStatusValue == true) {
        apiBodyObj['tg_status'] = "1";
      } else {
        apiBodyObj['tg_status'] = "0";
      }

      Map<String, dynamic> response = await NetworkHelper.request(
          'Dating/UpdatePrivacySettings', apiBodyObj);

      if (response['status'] == 'success') {
        showInSnackBar(getTranslated(context, "dating_privacystatus_success"));
      } else {
        if (response['error'] == "request_not_completed") {
          showInSnackBar(
              getTranslated(context, "dating_profile_requestnotcompleted"));
        } else if (response['error'] == "please_update_the_profile_first") {
          showInSnackBar(
              getTranslated(context, "dating_profiledetails_notfound"));
        }
      }
      setState(() {
        isGenderStatusLoading = false;
      });
      ongenderStatusChnaged();
    }

    void changeMalePrivacyStatus(
      bool maleStatusValue,
      bool femaleStatusValue,
      bool transgenderStatusValue,
    ) {
      setState(() {
        valueMales = maleStatusValue;
      });
      changeGenderPrivacyStatus(
          valueMales, femaleStatusValue, transgenderStatusValue);
    }

    void changeFemalePrivacyStatus(
      bool maleStatusValue,
      bool femaleStatusValue,
      bool transgenderStatusValue,
    ) {
      setState(() {
        valueFemales = femaleStatusValue;
      });
      changeGenderPrivacyStatus(
          maleStatusValue, valueFemales, transgenderStatusValue);
    }

    void changeTransgenderPrivacyStatus(
      bool maleStatusValue,
      bool femaleStatusValue,
      bool transgenderStatusValue,
    ) {
      setState(() {
        valueTransgenders = transgenderStatusValue;
      });
      changeGenderPrivacyStatus(
          maleStatusValue, femaleStatusValue, valueTransgenders);
    }

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: Text(
                getTranslated(context, "dating_seeprofile_search"),
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: Checkbox(
                        checkColor: Color(0xFFFFFFFF),
                        activeColor: Color(0xFF666363),
                        value: this.valueMales,
                        onChanged: (bool value) {
                          changeMalePrivacyStatus(
                              value, valueFemales, valueTransgenders);
                          // ongenderStatusChnaged1;
                        },
                      )),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(getTranslated(context, "dating_males"),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.normal,
                        )))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    child: SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: Checkbox(
                          checkColor: Color(0xFFFFFFFF),
                          activeColor: Color(0xFF666363),
                          value: this.valueFemales,
                          onChanged: (bool value) {
                            changeFemalePrivacyStatus(
                                valueMales, value, valueTransgenders);
                          },
                        ))),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(getTranslated(context, "dating_females"),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.normal,
                        )))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    child: SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: Checkbox(
                          checkColor: Color(0xFFFFFFFF),
                          activeColor: Color(0xFF666363),
                          value: this.valueTransgenders,
                          onChanged: (bool value) {
                            changeTransgenderPrivacyStatus(
                                valueMales, valueFemales, value);
                          },
                        ))),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(getTranslated(context, "dating_transgenders"),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.normal,
                        )))
              ],
            ),
            isGenderStatusLoading
                ? Container(child: Center(child: Loading()))
                : SizedBox(),
          ],
        ),
      ],
    );
  }
}
