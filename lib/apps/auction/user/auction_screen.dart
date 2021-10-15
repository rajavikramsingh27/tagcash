import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/auction/user/history_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/providers/perspective_provider.dart';

import '../../../constants.dart';
import 'future_auction_screen.dart';
import 'live_auction_screen.dart';

class AuctionScreen extends StatefulWidget {

  @override
  _AuctionScreenState createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> with SingleTickerProviderStateMixin{
  TabController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(
          ),
          title: 'AUCTIONS',
        ),
        body:Column(
          children: [
            Container(
                width: double.infinity,
                decoration: new BoxDecoration(color: Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                    'user'
                    ? Colors.black
                    : kPrimaryColor),
                child:Align(
                  alignment: Alignment.center,
                  child: TabBar(
                    controller: _controller,
                    labelColor:  Colors.white,
                    labelPadding: EdgeInsets.only(left: 0, right: 0),
                    indicatorWeight:3,
                    indicatorColor: Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                        'user'
                        ? kPrimaryColor
                        : Colors.white,
//                    labelPadding: EdgeInsets.symmetric(horizontal: 25.0),
                    tabs: <Tab>[
                      Tab(text: 'LIVE'),
                      Tab(text: 'FUTURE'),
                      Tab(text: 'HISTORY'),
                    ],
                  ),
                )
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
                  LiveAuctionScreen(),
                  FutureAuctionScreen(),
                  HistoryScreen(),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
