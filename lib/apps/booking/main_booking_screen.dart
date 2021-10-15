import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/booking/merchant_booking/merchant_booking_tab_screen.dart';
import 'package:tagcash/apps/booking/user_booking/user_booking_tab_screen.dart';
import 'package:tagcash/providers/perspective_provider.dart';

class MainBookingScreen extends StatefulWidget {
  @override
  _MainBookingScreenState createState() => _MainBookingScreenState();
}

class _MainBookingScreenState extends State<MainBookingScreen>
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
    return Container(child:
    Consumer<PerspectiveProvider>(builder: (context, perspective, child) {
      return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
              child: Column(children: [
                perspective.getActivePerspective() == 'user'
                    ? Flexible(child: UserBookingTabScreen())
                    : Flexible(child: MerchantBookingTabScreen())
              ])));
    }));
  }
}
