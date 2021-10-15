import 'package:flutter/material.dart';
import 'package:tagcash/apps/vouchers/create_voucher_screen.dart';

import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/apps/vouchers/vouchers_list_screen.dart';
import 'package:tagcash/apps/vouchers/vouchers_received_screen.dart';
import 'package:tagcash/apps/vouchers/vouchers_redeem_screen.dart';

class VouchersManageScreen extends StatefulWidget {
  @override
  VouchersManageScreenState createState() => VouchersManageScreenState();
}

class VouchersManageScreenState extends State<VouchersManageScreen> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3, initialIndex: 1);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(
            bottom: new TabBar(
              controller: controller, 
              tabs: <Tab>[
                new Tab(text: getTranslated(context, "vouchers_list")),
                new Tab(text: getTranslated(context, "vouchers_received")),
                new Tab(text: getTranslated(context, "vouchers_redeem"))
              ]
          )
          ),
          title: getTranslated(context, "vouchers"),
        ),
        body: new TabBarView(controller: controller, children: <Widget>[
          new VouchersListScreen(),
          new VouchersReceivedScreen(),
          new VouchersRedeemScreen()
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateVoucherScreen()
              ),
            ).then((val) => {

            });
         },
          child: Icon(Icons.add),
          tooltip: getTranslated(context, "create_reward"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
  }
}


class Third extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Center(
            child:
                new Icon(Icons.local_pizza, size: 150.0, color: Colors.teal)));
  }
}

