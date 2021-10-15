import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/models/business_site_data.dart';
import 'package:tagcash/providers/login_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class ValidateWhiteScreen extends StatefulWidget {
  const ValidateWhiteScreen({Key key}) : super(key: key);

  @override
  _ValidateWhiteScreenState createState() => _ValidateWhiteScreenState();
}

class _ValidateWhiteScreenState extends State<ValidateWhiteScreen> {
  bool isLoadingInitial = false;
  bool invalidUser = false;

  @override
  void initState() {
    super.initState();
    if (Validator.isNumber(AppConstants.siteOwner)) {
      loadMerchantProfile();
    } else {
      getOwnerFromDomain();
    }
  }

  void getOwnerFromDomain() async {
    setState(() {
      isLoadingInitial = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['domain_name'] = AppConstants.siteOwner;

    Map<String, dynamic> response =
        await NetworkHelper.request('apps/GetOwnerFromDomain', apiBodyObj);

    isLoadingInitial = false;
    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (responseMap['user_type'] == '2') {
        AppConstants.siteOwner = responseMap['user_id'];
        loadMerchantProfile();
      } else {
        invalidUser = true;
      }
    } else {
      invalidUser = true;
    }
    setState(() {});
  }

  void loadMerchantProfile() async {
    setState(() {
      isLoadingInitial = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = AppConstants.siteOwner;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    isLoadingInitial = false;
    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];

      BusinessSiteData merchantData =
          BusinessSiteData.fromJson(responseList[0]);

      if (merchantData.roleType == 'owner' ||
          merchantData.roleType == 'staff') {
        AppConstants.businessOwner = true;
      } else {
        AppConstants.businessOwner = false;
      }

      goToHomePage();
    } else {
      invalidUser = true;
    }
    setState(() {});
  }

  void goToHomePage() {
    Provider.of<LoginProvider>(context, listen: false).setLoginStatus(true);

    Navigator.pushNamedAndRemoveUntil(
        context, '/business', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoadingInitial
          ? Center(child: Loading())
          : invalidUser
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/cloud.svg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 30),
                      Text(
                        getTranslated(context, 'invalid_business'),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      SizedBox(height: 20),
                      Text(
                        getTranslated(context, 'invalid_business_message'),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                )
              : SizedBox(),
    );
  }
}
