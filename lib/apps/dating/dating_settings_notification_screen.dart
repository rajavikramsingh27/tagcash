import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingSettingsNotificationScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  bool valueProfileVisits;
  bool valueReceiveMessage;
  bool valueEmail;
  VoidCallback onnotificationStatusChnaged;

  DatingSettingsNotificationScreen(
      {@required this.valueProfileVisits,
      @required this.valueReceiveMessage,
      @required this.valueEmail,
      this.onnotificationStatusChnaged,
        this.scaffoldKey});

  @override
  _DatingSettingsNotificationScreen createState() =>
      _DatingSettingsNotificationScreen(valueProfileVisits, valueReceiveMessage,
          valueEmail, onnotificationStatusChnaged);
}

class _DatingSettingsNotificationScreen
    extends State<DatingSettingsNotificationScreen> {
  bool valueProfileVisits = false;
  bool valueReceiveMessage = false;
  bool valueEmail = false;
  VoidCallback onnotificationStatusChnaged;
  bool isNotificationStatusLoading = false;

  _DatingSettingsNotificationScreen(valueProfileVisits, valueReceiveMessage,
      valueEmail, onnotificationStatusChnaged) {
    this.valueProfileVisits = valueProfileVisits;
    this.valueReceiveMessage = valueReceiveMessage;
    this.valueEmail = valueEmail;
    this.onnotificationStatusChnaged = onnotificationStatusChnaged;
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
        content: new Text(
            value), backgroundColor: Colors.red[600],
        duration: new Duration(seconds: 3),
      ));
    }

    void changeNotificationStatus(profileVisitStatusValue,
        receiveMessageStatusValue, emailStatusValue) async {
      setState(() {
        isNotificationStatusLoading = true;
      });     ;
      Map<String, String> apiBodyObj = {};
      apiBodyObj['module_id'] = AppConstants.activeModule;
      if (profileVisitStatusValue == true) {
        apiBodyObj['profile_visits'] = "1";
      } else {
        apiBodyObj['profile_visits'] = "0";
      }
      if (receiveMessageStatusValue == true) {
        apiBodyObj['receive_newmessage_status'] = "1";
      } else {
        apiBodyObj['receive_newmessage_status'] = "0";
      }
      if (emailStatusValue == true) {
        apiBodyObj['email_status'] = "1";
      } else {
        apiBodyObj['email_status'] = "0";
      }

      Map<String, dynamic> response = await NetworkHelper.request(
          'Dating/UpdateNotificationSettings', apiBodyObj);

      setState(() {
        isNotificationStatusLoading = false;
      });
      if (response['status'] == 'success') {
        showInSnackBar(getTranslated(context, "dating_changed_successstatus"));
      } else {
        if (response['error'] == "request_not_completed") {

          showInSnackBar(
              getTranslated(context, "dating_profile_requestnotcompleted"));
        } else if (response['error'] == "please_update_the_profile_first") {
          showInSnackBar(
              getTranslated(context, "dating_profiledetails_notfound"));
        }
      }

      onnotificationStatusChnaged();
    }

    void changeProfileStatusNotification(bool profilevisitStatusValue,
        bool receivemessageStatusValue, bool emailStatusValue) {
      setState(() {
        valueProfileVisits = profilevisitStatusValue;
      });
      changeNotificationStatus(
          valueProfileVisits, receivemessageStatusValue, emailStatusValue);
    }

    void changeReceiveMessageStatusNotification(bool profilevisitStatusValue,
        bool receivemessageStatusValue, bool emailStatusValue) {
      setState(() {
        valueReceiveMessage = receivemessageStatusValue;
      });
      changeNotificationStatus(
          profilevisitStatusValue, valueReceiveMessage, emailStatusValue);
    }

    void changeEmailStatusNotification(bool profilevisitStatusValue,
        bool receivemessageStatusValue, bool emailStatusValue) {
      setState(() {
        valueEmail = emailStatusValue;
      });
      changeNotificationStatus(
          profilevisitStatusValue, receivemessageStatusValue, valueEmail);
    }

    return Stack(children: [
      Column(mainAxisSize: MainAxisSize.max, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    checkColor: Color(0xFFFFFFFF),
                    activeColor: Color(0xFF666363),
                    value: valueProfileVisits,
                    onChanged: (bool value) {
                      changeProfileStatusNotification(
                          value, valueReceiveMessage, valueEmail);
                      // ongenderStatusChnaged1;
                    },
                  )),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(2, 0, 0, 0),
                child: Text(getTranslated(context, "dating_profile_visits"),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.normal,
                    )))
          ],
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    checkColor: Color(0xFFFFFFFF),
                    activeColor: Color(0xFF666363),
                    value: valueReceiveMessage,
                    onChanged: (bool value) {
                      changeReceiveMessageStatusNotification(
                          valueProfileVisits, value, valueEmail);
                    },
                  )),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(2, 0, 0, 0),
                child: Text(getTranslated(context, "dating_receive_newmessage"),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.normal,
                    )))
          ],
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      checkColor: Color(0xFFFFFFFF),
                      activeColor: Color(0xFF666363),
                      value: valueEmail,
                      onChanged: (bool value) {
                        changeEmailStatusNotification(
                            valueProfileVisits, valueReceiveMessage, value);
                        // ongenderStatusChnaged1;
                      },
                    ))),
            Container(
                margin: EdgeInsets.fromLTRB(2, 0, 0, 0),
                child: Text(getTranslated(context, "dating_email_newmessage"),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.normal,
                    )))
          ],
        ),
        isNotificationStatusLoading
            ? Container(child: Center(child: Loading()))
            : SizedBox(),
      ])
    ]);
  }
}
