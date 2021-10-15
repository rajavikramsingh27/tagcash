

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/merchant_data.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;


class AdminSwithScreen extends StatefulWidget {
  @override
  _AdminSwithScreenState createState() => _AdminSwithScreenState();
}

class _AdminSwithScreenState extends State<AdminSwithScreen> {
  int nowCommunityID = 0;

  @override
  void initState() {
    super.initState();

    switchPerspective();
  }

  switchPerspective() async {
    Map<String, dynamic> response = await NetworkHelper.request(
        'perspective/switch/' + AppConstants.siteOwner);

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      Provider.of<PerspectiveProvider>(context, listen: false)
          .setActivePerspective(responseMap['type']);

      setState(() {
        nowCommunityID = int.parse(responseMap['id']);
      });

      communityDetailsLoad();
    } else {
      if (response['error'] == "kyc_verification_failed") {
        kycErrorAlertShow();
      }
    }
  }

  kycErrorAlertShow() {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('KYC verification '),
            content:
                Text('KYC verification is required for switching to business.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  backToLogin();
                },
                child: Text(
                  'OK',
                ),
              )
            ],
          );
        });
  }

  backToLogin() {
    Navigator.of(context).pop();
  }

  communityDetailsLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request(
        'community/details/' + nowCommunityID.toString());

    if (response['status'] == 'success') {
      MerchantData merchantData = MerchantData.fromJson(response['result']);

      Provider.of<MerchantProvider>(context, listen: false)
          .setMerchantData(merchantData);

      // _model.nowCommunityRoleType = resultObj.role.role_type;
      // _model.nowCommunityRoleName = resultObj.role.role_name;

      // tagEvents.emit("rolePermissionGet");

      goToHomePage();
    }
  }

  void goToHomePage() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 56,
            color: Colors.black,
          ),
          Expanded(child: Container(child: Center(child: Loading()))),
        ],
      ),
    );
  }
}
