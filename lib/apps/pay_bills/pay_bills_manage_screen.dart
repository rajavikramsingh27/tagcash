import 'package:flutter/material.dart';
import 'package:tagcash/apps/pay_bills/pay_bill_screen.dart';
import 'package:tagcash/apps/pay_bills/pay_bills_tagcash_screen.dart';

import 'package:tagcash/components/app_top_bar.dart';

class PayBillsManageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppTopBar(
            title: 'PAY BILLS',
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: "ECPAY"),
                  Tab(text: "TAGCASH"),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              PayBillScreen(),
              PayBillsTagcashScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
