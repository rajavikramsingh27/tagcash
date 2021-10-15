import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/booking/user_booking/user_appointment_tab_screen.dart';
import 'package:tagcash/apps/booking/user_booking/user_service_tab_screen.dart';
import 'package:tagcash/components/app_drawer.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';

class UserBookingTabScreen extends StatefulWidget {
    @override
    _UserBookingTabScreenState createState() => _UserBookingTabScreenState();
}

class _UserBookingTabScreenState extends State<UserBookingTabScreen>
    with SingleTickerProviderStateMixin {
    TabController _controller;


    @override
    void initState() {
        // TODO: implement initState

        super.initState();
        _controller = new TabController(
            length: 2,
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
                                                                const Tab(text: 'Services'),
                                                                const Tab(text: 'My Appointments'),
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
                                                                new UserServiceTabScreen(),
                                                                new UserAppointmentTabScreen(),
                                                            ],
                                                        ),
                                                    )),
                                                ],
                                            ),
                                        ),
                                    ),

                                ],
                            ),
                    )
        );

    }
}
