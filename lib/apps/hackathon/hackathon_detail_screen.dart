import 'package:flutter/material.dart';
import 'package:tagcash/apps/hackathon/pages/hac_admins_page.dart';
import 'package:tagcash/apps/hackathon/pages/hac_detail_page.dart';
import 'package:tagcash/apps/hackathon/pages/hac_projects_page.dart';
import 'package:tagcash/apps/hackathon/pages/hac_results_page.dart';
import 'package:tagcash/components/app_top_bar.dart';

class HackathonDetailScreen extends StatefulWidget {
  final String hackathonId;
  final String hackathonStatus;
  final bool ownerStatus;

  const HackathonDetailScreen(
      {Key key, this.hackathonId, this.ownerStatus, this.hackathonStatus})
      : super(key: key);

  @override
  _HackathonDetailScreenState createState() => _HackathonDetailScreenState();
}

class _HackathonDetailScreenState extends State<HackathonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'Details'),
                Tab(text: 'Projects'),
                Tab(text: 'Admins'),
                Tab(text: 'Results'),
              ],
              isScrollable: true,
            ),
          ),
          title: 'Hackathon',
        ),
        body: TabBarView(children: [
          HacDetailPage(
            ownerStatus: widget.ownerStatus,
            hackathonId: widget.hackathonId,
            hackathonStatus: widget.hackathonStatus,
          ),
          HacProjectsPage(
            ownerStatus: widget.ownerStatus,
            hackathonId: widget.hackathonId,
          ),
          HacAdminsPage(
            ownerStatus: widget.ownerStatus,
            hackathonId: widget.hackathonId,
          ),
          HacResultsPage(
            ownerStatus: widget.ownerStatus,
            hackathonId: widget.hackathonId,
          )
        ]),
      ),
    );
  }
}
