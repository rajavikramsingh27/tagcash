import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/booking/merchant_booking/booking_tab_screen.dart';
import 'package:tagcash/apps/booking/merchant_booking/service_tab_screen.dart';
import 'package:tagcash/apps/booking/merchant_booking/staff_tab_screen.dart';
import 'package:tagcash/components/app_drawer.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';

class MerchantBookingTabScreen extends StatefulWidget {
    @override
    _MerchantBookingTabScreenState createState() => _MerchantBookingTabScreenState();
}

class _MerchantBookingTabScreenState extends State<MerchantBookingTabScreen>
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
                child: Scaffold(
                                appBar: AppTopBar(
                                    appBar: AppBar(),
                                    title: '',
                                ),
                                drawer: AppDrawer(),
                                body: Column(
                                    children: [
                                        Flexible(
                                            child: Container(
                                                child: Column(
                                                    children: [
                                                        Container(
                                                            decoration: new BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                                                            child: TabBar(
                                                                controller: _controller,
                                                                unselectedLabelColor:  Color(0xFFACACAC),
                                                                labelColor:  Theme.of(context).primaryColor,
                                                                indicatorWeight:3,
                                                                indicatorColor:  kPrimaryColor,
                                                                tabs: const <Tab>[
                                                                    const Tab(text: 'BOOKINGS'),
                                                                    const Tab(text: 'SERVICES'),
                                                                    const Tab(text: 'STAFF'),
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
                                                                    new BookingTabScreen(),
                                                                    new ServiceTabScreen(),
                                                                    new StaffTabScreen(),
                                                                ],
                                                            ),
                                                        )),
                                                    ],
                                                ),
                                            ),
                                        )

                                    ],
                                ),
                    ),
        );

    }
}
