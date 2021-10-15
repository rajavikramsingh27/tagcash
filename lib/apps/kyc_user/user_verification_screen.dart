import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/kyc_user/kyc_verify_IdentityPage.dart';
import 'package:tagcash/apps/kyc_user/kyc_verifyIdentity_pages/kyc_proofofaddress_page.dart';
import 'package:tagcash/apps/kyc_user/kyc_verifyIdentity_pages/kyc_customslimits_page.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/constants.dart';
import 'components/email_sms_verify.dart';
import 'models/country_callingcode.dart';

class UserVerificationScreen extends StatefulWidget {
  _UserVerifyScreenState createState() => _UserVerifyScreenState();
}

class _UserVerifyScreenState extends State<UserVerificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  UserData userData;
  var userEmailDisplay;
  var userMobileDisplay;
  var profileCountryCode;
  var countryCode;

  int emailOrMobileIndex = 0;
  bool level2ButtonEnable = false;
  bool level3ButtonEnable = false;
  bool level4ButtonEnable = false;
  bool level5ButtonEnable = false;

  bool level1EmailorSmsverified = false;
  bool level2EmailorSmsverified = false;

  var loadingCompleteStat = false;

  var level1CashInAmount;
  var level2CashInAmount;
  var level3CashInAmount;
  var level4CashInAmount;
  var level5CashInAmount;

  var level1CashOutAmount;
  var level2CashOutAmount;
  var level3CashOutAmount;
  var level4CashOutAmount;
  var level5CashOutAmount;

  var level4ProoofAddressStatus;
  var level5CustomLimitsStatus;
  var level3ImageIDSelfienogovIDstatus;
  var verifivationlevel;
  var levelOneBySms = false;
  bool isLoading = false;
  bool isPhilippines;

  final newMobileInput = TextEditingController();
  final validationSmsCodeInput = TextEditingController();
  var countryCAllCode = new List<CountryCallCode>();
  CountryCallCode selectedNumber;

  void initState() {
    isPhilippines = false;
    level4ProoofAddressStatus = "new";
    level5CustomLimitsStatus = "new";
    level3ImageIDSelfienogovIDstatus = "new";
    userData = Provider.of<UserProvider>(context, listen: false).userData;
    countryCode = userData.countryCode;
    if (countryCode == "PH") {
      isPhilippines = true;
    } else {
      isPhilippines = false;
    }
    print("country_Code" + countryCode);
    getKycUserVerifiedLevcel();

    super.initState();
  }

  getKycUserVerifiedLevcel() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('verification/GetLevel');

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      var resultObj = response['result'];

      var inRemainingString = "";
      var outRemainingString = "";
      if (resultObj["in_remaining_amount"].toString != 0) {
        inRemainingString =
            " - " + resultObj["in_remaining_amount"].toString() + " remaining";
      }
      if (resultObj["out_remaining_amount"].toString != 0) {
        outRemainingString =
            " - " + resultObj["out_remaining_amount"].toString() + " remaining";
      }

      var levelDetails = resultObj["verification_level_details"];
      level1CashInAmount = levelDetails[0]["cash_in_text"];
      level2CashInAmount = levelDetails[1]["cash_in_text"];
      level3CashInAmount = levelDetails[2]["cash_in_text"];
      level4CashInAmount = levelDetails[3]["cash_in_text"];
      level5CashInAmount = levelDetails[4]["cash_in_text"];

      level1CashOutAmount = levelDetails[0]["cash_out_text"];
      level2CashOutAmount = levelDetails[1]["cash_out_text"];
      level3CashOutAmount = levelDetails[2]["cash_out_text"];
      level4CashOutAmount = levelDetails[3]["cash_out_text"];
      level5CashOutAmount = levelDetails[4]["cash_out_text"];

      verifivationlevel = resultObj["verification_level"];
      switch (verifivationlevel) {
        case 0:
          {
            level1EmailorSmsverified = false;
            level2ButtonEnable = false;
            level3ButtonEnable = false;
            level4ButtonEnable = false;
            level5ButtonEnable = false;
          }
          break;

        case 1:
          {
            if (resultObj["level_1_by_sms"] == true) {
              print("level1 sms verified");
              levelOneBySms = true;
            } else {
              print("level1 email verified");
              levelOneBySms = false;
            }

            level2ButtonEnable = true;
            level1EmailorSmsverified = true;

            level1CashInAmount = level1CashInAmount + inRemainingString;
            level1CashOutAmount = level1CashOutAmount + outRemainingString;
          }
          break;
        case 2:
          {
            level1EmailorSmsverified = true;
            level2EmailorSmsverified = true;
            level2ButtonEnable = true;
            level3ButtonEnable = true;

            level2CashInAmount = level2CashInAmount + inRemainingString;
            level2CashOutAmount = level2CashOutAmount + outRemainingString;
          }
          break;
        case 3:
          {
            level1EmailorSmsverified = true;
            level2EmailorSmsverified = true;
            level4ButtonEnable = true;

            level3CashInAmount = level3CashInAmount + inRemainingString;
            level3CashOutAmount = level3CashOutAmount + outRemainingString;
          }
          break;
        case 4:
          {
            level1EmailorSmsverified = true;
            level2EmailorSmsverified = true;
            level5ButtonEnable = true;

            level4CashInAmount = level4CashInAmount + inRemainingString;
            level4CashOutAmount = level4CashOutAmount + outRemainingString;
          }
          break;
        case 5:
          {
            level1EmailorSmsverified = true;
            level2EmailorSmsverified = true;

            level5CashInAmount = level5CashInAmount + inRemainingString;
            level5CashOutAmount = level5CashOutAmount + outRemainingString;
          }
          break;
      }
    }
    loadingCompleteStat = true;
    setState(() {});

    if (verifivationlevel >= 2) {
      getStatus();
    }
  }

  getStatus() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    Map<String, dynamic> response =
        await NetworkHelper.request('verification/status', apiBodyObj);
    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      setState(() {
        var resultObjarray = response['result'];
        for (var i = 0; i < resultObjarray.length; i++) {
          var resultObject = resultObjarray[i];
          var kycleveltype = resultObject["verification_type"];
          var status = resultObject["status"];
          print("KYC Level Type : " + kycleveltype);
          switch (kycleveltype) {
            case "Level_3_overview":
              {
                if (status == "update_please") {
                  level3ImageIDSelfienogovIDstatus = "new";
                  if (verifivationlevel == 2) {
                    level3ButtonEnable = true;
                    level4ButtonEnable = false;
                    level5ButtonEnable = false;
                  }
                } else if (status == "approved") {
                  level3ImageIDSelfienogovIDstatus = "approved";
                } else if (status == "unapproved") {
                  level3ImageIDSelfienogovIDstatus = "unapproved";
                } else if (status == "pending") {
                  level3ImageIDSelfienogovIDstatus = "pending";
                }
              }
              break;

            case "Level_4_overview":
              {
                if (status == "update_please") {
                  level4ProoofAddressStatus = "new";
                  if (verifivationlevel == 3) {
                    level4ButtonEnable = true;
                    level5ButtonEnable = false;
                  }
                } else if (status == "pending") {
                  level4ProoofAddressStatus = "pending";
                  level5ButtonEnable = false;
                } else if (status == "approved") {
                  level4ProoofAddressStatus = "approved";
                  level5ButtonEnable = true;
                } else if (status == "unapproved") {
                  level4ProoofAddressStatus = "new";
                  level4ButtonEnable = true;
                  level5ButtonEnable = false;
                }
              }
              break;
            case "Level_5_overview":
              {
                if (status == "update_please") {
                  if (verifivationlevel == 4) {
                    //We enable Level5 button only after completed verification level4
                    level5CustomLimitsStatus = "new";
                    level5ButtonEnable = true;
                  }
                } else if (status == "pending") {
                  level5CustomLimitsStatus = "pending";
                } else if (status == "approved") {
                  level5CustomLimitsStatus = "approved";
                } else if (status == "unapproved") {
                  level5CustomLimitsStatus = "new";
                  level5ButtonEnable = true;
                }
              }
              break;
          }
        }
      });
    }
  }

  void level3idImageSelfieHandler() {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => KYCVerifyIdentityPage()),
    );
  }

  void proofofAddressClickHandler() {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => KYCProofofAddressPage()),
    );
  }

  void customLimitApplyClickHandler() {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => KYCCustomsLimitsPage()),
    );
  }

  emailOrSmsVerifyClicked(bool levelOne) {
    int methodIndex = 0;

    if (!levelOne) {
      if (levelOneBySms) {
        methodIndex = 0;
      } else {
        methodIndex = 1;
      }
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: EmailSmsVerify(
                radiomenuShow: levelOne ? true : false,
                methodIndex: methodIndex,
              ),
            ),
          );
        }).then((value) {
      if (value != null) {
        getKycUserVerifiedLevcel();
      }
    });
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        title: getTranslated(context, "kyc_verification_txt"),
        appBar: AppBar(),
      ),
      body: Stack(
        children: [
          if (loadingCompleteStat == true) ...[
            ListView(
              padding: EdgeInsets.all(kDefaultPadding),
              children: [
                level1EmailorSmsverified
                    ? CustomButton(
                        label: getTranslated(context, "kyc_leve1_verified_txt"),
                        color: Colors.green,
                      )
                    : CustomButton(
                        label: getTranslated(context, "kyc_leve1_verify_txt"),
                        color: Colors.grey,
                        onPressed: () => emailOrSmsVerifyClicked(true),
                      ),
                InOutLimitsShow(
                    cashIn: isPhilippines
                        ? level1CashInAmount
                        : getTranslated(context, "kyc_allowed"),
                    cashOut: "0"),
                level2EmailorSmsverified
                    ? CustomButton(
                        label: getTranslated(context, "kyc_leve2_verified_txt"),
                        color: Colors.green,
                      )
                    : CustomButton(
                        label: getTranslated(context, "kyc_leve2_verify_txt"),
                        color: Colors.grey,
                        onPressed: level2ButtonEnable
                            ? () => emailOrSmsVerifyClicked(false)
                            : null,
                      ),
                InOutLimitsShow(
                    cashIn: isPhilippines
                        ? level2CashInAmount
                        : getTranslated(context, "kyc_allowed"),
                    cashOut: "0"),
                if (level3ImageIDSelfienogovIDstatus == "new") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve3_verify"),
                    color: Colors.grey,
                    onPressed: level3ButtonEnable == true
                        ? level3idImageSelfieHandler
                        : null,
                  ),
                ],
                if (level3ImageIDSelfienogovIDstatus == "pending") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve3_verify_pending"),
                    color: Colors.grey,
                    onPressed: level3idImageSelfieHandler,
                  ),
                ],
                if (level3ImageIDSelfienogovIDstatus == "approved") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve3_verify_approved"),
                    color: Colors.green,
                  ),
                ],
                if (level3ImageIDSelfienogovIDstatus == "unapproved") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve_verify_unapproved"),
                    color: Colors.grey,
                    onPressed: level3idImageSelfieHandler,
                  ),
                ],
                InOutLimitsShow(
                    cashIn: isPhilippines
                        ? level3CashInAmount
                        : getTranslated(context, "kyc_allowed"),
                    cashOut: isPhilippines
                        ? level3CashOutAmount
                        : getTranslated(context, "kyc_allowed_limits_apply")),
                if (level4ProoofAddressStatus == "new") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve4_verify"),
                    color: Colors.grey,
                    onPressed: level4ButtonEnable == true
                        ? proofofAddressClickHandler
                        : null,
                  ),
                ],
                if (level4ProoofAddressStatus == "pending") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve4_verify_pending"),
                    color: Colors.grey,
                  ),
                ],
                if (level4ProoofAddressStatus == "approved") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve4_verify_approved"),
                    color: Colors.green,
                  ),
                ],
                if (level4ProoofAddressStatus == "unapproved") ...[
                  CustomButton(
                    label: getTranslated(context, "kyc_leve_verify_unapproved"),
                    color: Colors.grey,
                    onPressed: proofofAddressClickHandler,
                  ),
                ],
                InOutLimitsShow(
                    cashIn: isPhilippines
                        ? level4CashInAmount
                        : getTranslated(context, "kyc_allowed"),
                    cashOut: isPhilippines
                        ? level4CashOutAmount
                        : getTranslated(
                            context, "kyc_allowed_unlimited_amount")),
                SizedBox(height: 20),
                isPhilippines
                    ? Text(
                        getTranslated(context, "kyc_user_des"),
                        style: Theme.of(context).textTheme.subtitle2,
                      )
                    : SizedBox(),
              ],
            ),
          ],
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}

class InOutLimitsShow extends StatelessWidget {
  const InOutLimitsShow({
    Key key,
    this.cashIn,
    this.cashOut,
  }) : super(key: key);

  final String cashIn;
  final String cashOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  getTranslated(context, "kyc_cash_in"),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              Expanded(
                flex: 7,
                child: Text(
                  cashIn,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(children: <Widget>[
            Expanded(
              flex: 3,
              child: Text(
                getTranslated(context, "kyc_cash_out"),
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(
                cashOut,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
