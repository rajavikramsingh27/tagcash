import 'package:flutter/material.dart';

import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/coupons/all_coupons_screen.dart';
import 'package:tagcash/apps/coupons/my_coupons_screen.dart';
import 'package:tagcash/localization/language_constants.dart';

class CouponsManageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppTopBar(
            title: getTranslated(context, "coupons"),
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: getTranslated(context, "all_coupons")),
                  Tab(text: getTranslated(context, "my_coupons")),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              AllCouponsScreen(),
              MyCouponsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
