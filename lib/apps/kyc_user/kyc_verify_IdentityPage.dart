import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/kyc_user/kyc_verifyIdentity_pages/kyc_dataverify_page.dart';
import 'package:tagcash/apps/kyc_user/kyc_verifyIdentity_pages/kyc_govidverify_page.dart';
import 'package:tagcash/apps/kyc_user/kyc_verifyIdentity_pages/kyc_nogovidapproval_page.dart';
import 'package:tagcash/apps/kyc_user/kyc_verifyIdentity_pages/kyc_profileimage_page.dart';
import 'package:tagcash/apps/kyc_user/kyc_verifyIdentity_pages/kyc_selfieverify_page.dart';
import 'package:tagcash/localization/language_constants.dart';

class KYCVerifyIdentityPage extends StatefulWidget {
  KYCVerifyIdentityPage({
    Key key,
  });
  _KYCVerifyIdentityState createState() => _KYCVerifyIdentityState();
}

class _KYCVerifyIdentityState extends State<KYCVerifyIdentityPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppTopBar(
            title: getTranslated(context, "kyc_leve3_verify_txt"),
            appBar: AppBar(
                bottom: TabBar(
              tabs: [
                Tab(text: getTranslated(context, "kyc_data")),
                Tab(text: getTranslated(context, "kyc_photo")),
                Tab(text: getTranslated(context, "kyc_gov_id")),
                Tab(text: getTranslated(context, "kyc_selfie_id")),
              ],
              isScrollable: true,
            )),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              KYCDataVerifyPage(),
              KYCProfileImagePage(),
              KYCGovIdVerifyPage(),
              KYCSelfieVerifyPage(),
            ],
          ),
        ),
      ),
    );
  }
}
