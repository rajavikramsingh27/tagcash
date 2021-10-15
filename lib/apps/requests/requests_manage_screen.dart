import 'package:flutter/material.dart';
import 'package:tagcash/apps/requests/requests_my_page.dart';
import 'package:tagcash/apps/requests/requests_other_page.dart';
import 'package:tagcash/components/app_top_bar.dart';

class RequestsManageScreen extends StatelessWidget {
  const RequestsManageScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppTopBar(
          title: '',
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'MY REQUESTS'),
                Tab(text: 'OTHER REQUESTS'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            RequestsMyPage(),
            RequestsOtherPage(),
          ],
        ),
      ),
    );
  }
}
