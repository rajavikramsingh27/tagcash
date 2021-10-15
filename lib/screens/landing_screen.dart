import 'package:flutter/material.dart';
import 'package:tagcash/screens/app_list_screen.dart';
import 'package:tagcash/screens/home_screen.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  PageController _pageController;

  String listingMode = 'miniprogram';
  //miniprogram,publicprogram

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          HomeScreen(
            listingMode: listingMode,
            showAppList: () {
              _pageController.jumpToPage(1);
            },
            setMoreMode: (value) {
              setState(() {
                listingMode = value;
              });
            },
          ),
          AppListScreen(
            onBackPressed: () {
              _pageController.jumpToPage(0);
            },
          )
        ],
      ),
    );
  }
}
