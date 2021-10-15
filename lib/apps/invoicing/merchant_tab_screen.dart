import 'package:flutter/material.dart';
import 'package:tagcash/components/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/constants.dart';

import 'merchant_all_tab_screen.dart';
import 'merchant_draft_tab_screen.dart';
import 'merchant_unpaid_tab_screen.dart';

class MerchantTabScreen extends StatefulWidget {
  @override
  _MerchantTabScreenState createState() => _MerchantTabScreenState();
}

class _MerchantTabScreenState extends State<MerchantTabScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _controller = new TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                appBar: AppTopBar(
                  appBar: AppBar(),
                  title: 'Invoicing',
                ),
                drawer: AppDrawer(),
                body: Column(
                  children: [
                    Container(
                      decoration: new BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                      child: TabBar(
                        controller: _controller,
                        unselectedLabelColor:  Color(0xFFACACAC),
                        labelColor:  kUserBackColor,
                        indicatorWeight:3,
                        indicatorColor:  kPrimaryColor,
                        tabs: const <Tab>[
                          const Tab(text: 'UNPAID'),
                          const Tab(text: 'DRAFT'),
                          const Tab(text: 'ALL'),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      color: Color(0xFFACACAC),
                    ),
                    Flexible(child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: TabBarView(
                        controller: _controller,
                        children: <Widget>[
                          new MerchantUnpaidTabScreen(),
                          new MerchantDraftTabScreen(),
                          new MerchantAllTabScreen(),
                        ],
                      ),
                    )),
                  ],
                ),
            /*    floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/new_invoices');
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 40,
                  ),
                  backgroundColor: Colors.black,
                  elevation: 5,
                ),*/



              ),
            )
    );
  }
}
