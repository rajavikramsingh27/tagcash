import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/invoicing/setting/setting_screen.dart';
import 'package:tagcash/apps/invoicing/unpaid_tab_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';

import 'all_tab_screen.dart';
import 'create_tab_screen.dart';
import 'customer/customer_screen.dart';
import 'item/item_screen.dart';
import 'merchant_tab_screen.dart';

class InvoicingScreen extends StatefulWidget {
  @override
  _InvoicingScreenState createState() => _InvoicingScreenState();
}

class _InvoicingScreenState extends State<InvoicingScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  bool isSearching = false;
  int _currentPageIndex;
  @override
  void initState() {
    setState(() {
      _currentPageIndex = 0;

      _pages.add(MerchantTabScreen());
      _pages.add(CustomerScreen());
      _pages.add(ItemScreen());
      _pages.add(SettingScreen());
    });

    // TODO: implement initState
    super.initState();
    _controller = new TabController(
      length: 3,
      vsync: this,
    );
  }

  Widget userModule() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Scaffold(
            appBar: AppTopBar(
              appBar: AppBar(),
              title: 'Invoicing',
            ),
            body: Column(
              children: [
                Container(
                  decoration: new BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: TabBar(
                    controller: _controller,
                    unselectedLabelColor: Color(0xFFACACAC),
                    labelColor: kUserBackColor,
                    indicatorWeight: 3,
                    indicatorColor: kPrimaryColor,
                    tabs: const <Tab>[
                      const Tab(text: 'UNPAID'),
                      const Tab(text: 'CREATE'),
                      const Tab(text: 'ALL'),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 0.5,
                  color: Color(0xFFACACAC),
                ),
                Flexible(
                    child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _controller,
                    children: <Widget>[
                      new UnpaidTabScreen(),
                      new CreateTabScreen(),
                      new AllTabScreen(),
                    ],
                  ),
                )),
              ],
            )));
  }

  Widget _getCurrentPage() => _pages[_currentPageIndex];
  List<Widget> _pages = List();

  Widget merchantModule() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: _getCurrentPage(),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.black,
              primaryColor: Colors.red,
            ),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.fileAlt, size: 16),
                  title: Text('Invoices'),
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.userCircle, size: 16),
                  title: Text('Customers'),
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.archive, size: 16),
                  title: Text('Items'),
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.bars, size: 16),
                  title: Text('Settings'),
                ),
              ],
              currentIndex: _currentPageIndex,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: Color(0xFFACACAC),
              type: BottomNavigationBarType.fixed,
              onTap: (int index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(child:
        Consumer<PerspectiveProvider>(builder: (context, perspective, child) {
      return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
              child: Column(children: [
            perspective.getActivePerspective() == 'user'
                ? Flexible(child: userModule())
                : Flexible(child: merchantModule())
          ])));
    }));
  }
}
