import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/hackathon/models/hackathon_list.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

import 'create_hackathon_screen.dart';
import 'hackathon_detail_screen.dart';

class HackathonListScreen extends StatefulWidget {
  @override
  _HackathonListScreenState createState() => _HackathonListScreenState();
}

class _HackathonListScreenState extends State<HackathonListScreen> {
  StreamController<List<HackathonList>> _streamcontroller;
  List<HackathonList> _hackathonList;

  @override
  void initState() {
    super.initState();

    _hackathonList = [];
    _streamcontroller = StreamController<List<HackathonList>>.broadcast();

    hackathonListLoad(true);
  }

  void hackathonListLoad(bool clearData) {
    if (clearData) {
      _hackathonList = [];
      _streamcontroller.add(null);
    }

    getHackathonList().then((res) {
      if (res.length != 0) {
        _hackathonList.addAll(res);
      }

      _streamcontroller.add(_hackathonList);
    });
  }

  Future<List<HackathonList>> getHackathonList() async {
    Map<String, String> apiBodyObj = {};
    // apiBodyObj['open_only'] = 'true';//not used now for listing active only
    // apiBodyObj['search'] = 'App';

    String apiPath = '';
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      apiPath = 'HackathonMini/ListHackathon';
    } else {
      apiPath = 'HackathonMini/MyHackathon';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(apiPath, apiBodyObj);

    List<HackathonList> getData = [];
    List responseList = response['result'];

    if (responseList != null) {
      getData = responseList.map<HackathonList>((json) {
        return HackathonList.fromJson(json);
      }).toList();
    }

    return getData;
  }

  createHackathonClicked() {
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      showMerchantCreateAlert();
    } else {
      Navigator.of(context)
          .push(
              MaterialPageRoute(builder: (context) => CreateHackathonScreen()))
          .then((value) {
        if (value != null) {
          hackathonListLoad(true);
        }
      });
    }
  }

  showMerchantCreateAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Business Account'),
          content: Text(
              'Must be business to create hackathon. Create a business account now?'),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Continue"),
              onPressed: () {
                Navigator.pushNamed(context, '/merchants');
              },
            ),
          ],
        );
      },
    );
  }

  onHackathonClickHandler(HackathonList hackathonData) {
    bool ownerStatus = false;
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      ownerStatus = true;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => HackathonDetailScreen(
              hackathonId: hackathonData.id,
              hackathonStatus: hackathonData.hackathonStatus,
              ownerStatus: ownerStatus),
        ))
        .then((value) => value ? hackathonListLoad(true) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Hackathon',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createHackathonClicked(),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _streamcontroller.stream,
        builder: (BuildContext context,
            AsyncSnapshot<List<HackathonList>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10, bottom: 100),
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    HackathonList hackathonData = snapshot.data[index];

                    return Opacity(
                      opacity:
                          hackathonData.hackathonStatus == 'FINISHED' ? 0.5 : 1,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: kDefaultPadding),
                        title: Text(hackathonData.hackathonName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hackathonData.hackathonCountry),
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.solidCalendarAlt,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  hackathonDate(
                                    hackathonData.startTime,
                                    hackathonData.endTime,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => onHackathonClickHandler(hackathonData),
                        trailing: Text(
                          hackathonData.hackathonStatus,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  statusColor(hackathonData.hackathonStatus)),
                        ),
                      ),
                    );
                  },
                )
              : Center(child: Loading());
        },
      ),
    );
  }

  MaterialColor statusColor(String status) {
    MaterialColor statColor = Colors.grey;

    if (status == 'OPEN') {
      statColor = Colors.green;
    } else if (status == 'INVITE ONLY') {
      statColor = Colors.red;
    }

    return statColor;
  }

  String hackathonDate(String startDate, String endDate) {
    DateTime sDate = DateTime.parse(startDate);
    DateTime eDate = DateTime.parse(endDate);
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final String formattedDate = formatter.format(sDate);
    final String formattedDate1 = formatter.format(eDate);

    return formattedDate + ' - ' + formattedDate1;
  }
}
