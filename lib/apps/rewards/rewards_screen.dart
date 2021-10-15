import 'package:flutter/material.dart';
import 'package:tagcash/apps/rewards/reward_add_rule.dart';
import 'package:tagcash/apps/rewards/rewards_history_screen.dart';
import 'package:tagcash/apps/rewards/rewards_list_screen.dart';
import 'package:tagcash/apps/rewards/rewards_settings_screen.dart';

import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  int userStatus = 0;

  @override
  void initState() {
    super.initState();

    checkAdminOrOwner();
  }

  checkAdminOrOwner() async {
    print("checkAdminOrOwner");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('RewardRules/CheckAdminOrOwnerOrStaff');

    print(response);
    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      setState(() {
        userStatus = response['user_status'];
      });
    } else {
      String err = 'Failed';
      if (response['error'] == "switch_to_community_perspective") {
        err = getTranslated(context, "switch_to_community_perspective");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "failed") {
        err = getTranslated(context, "reward_failed");
      }
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, body: switchWidget());
  }

  Widget switchWidget() {
    Widget widget;

    switch (userStatus) {
      case 0:
        widget = blankWidget();
        break;
      case 1:
        widget = adminOrOwnerWidget();
        break;
      case 2:
        widget = adminOrOwnerWidget();
        break;
      case 3:
        widget = RewardAddRuleScreen(isOwnerOrAdmin: false);
        break;
      default:
        widget = blankWidget();
    }
    return widget;
  }

  Widget adminOrOwnerWidget() {
    Widget widget;
    widget = DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppTopBar(
          title: getTranslated(context, "reward"),
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "LIST"),
                Tab(text: "SETTINGS"),
                Tab(text: "HISTORY"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            RewardsListScreen(),
            RewardsSettingsScreen(),
            RewardsHistoryScreen(),
          ],
        ),
      ),
    );
    return widget;
  }

  Widget blankWidget() {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "reward"),
      ),
      body: isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(child: Loading()))
          : SizedBox(),
    );
  }
}
