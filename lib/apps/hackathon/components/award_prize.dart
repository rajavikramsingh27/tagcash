import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/hackathon/models/prize_list.dart';
import 'package:tagcash/apps/hackathon/models/project_list.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class AwardPrize extends StatefulWidget {
  final ProjectList project;
  final String hackathonId;
  final bool sponserUser;
  final bool adminUser;

  const AwardPrize({
    Key key,
    this.project,
    this.hackathonId,
    this.sponserUser,
    this.adminUser,
  }) : super(key: key);

  @override
  _AwardPrizeState createState() => _AwardPrizeState();
}

class _AwardPrizeState extends State<AwardPrize> {
  Future<List<PrizeList>> prizeList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    prizeList = loadPrizeList();
  }

  Future<List<PrizeList>> loadPrizeList() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.hackathonId;
    apiBodyObj['project_id'] = widget.project.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/GetHackathonPrize', apiBodyObj);

    List<PrizeList> getData = [];

    List adminPrizeList = response['result']['prize'];
    List sponsorPrizeList = response['result']['sponsor_prize'];

    List<PrizeList> adminData = adminPrizeList.map<PrizeList>((json) {
      return PrizeList.fromJsonAdmin(json);
    }).toList();

    List<PrizeList> sponsorData = sponsorPrizeList.map<PrizeList>((json) {
      return PrizeList.fromJsonSponsor(json);
    }).toList();

    getData.addAll(adminData);
    getData.addAll(sponsorData);

    return getData;
  }

  Widget buildAwardFunction(PrizeList prize) {
    if (prize.prizeType == 'ADMIN' &&
        prize.isAwarded == '0' &&
        widget.adminUser) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton(
          onPressed: () => awardProjectPrize(prize),
          child: Text('AWARD'),
        ),
      );
    }

    if (prize.prizeType == 'SPONSOR' &&
        prize.isAwarded == '0' &&
        widget.sponserUser) {
      String activeId = Provider.of<UserProvider>(context, listen: false)
          .userData
          .id
          .toString();
      if (activeId == prize.id) {
        return Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () => awardProjectPrize(prize),
            child: Text('AWARD'),
          ),
        );
      }
    }

    return null;
  }

  awardProjectPrize(PrizeList prize) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;
    apiBodyObj['project_id'] = widget.project.id;

    List prizeList = [];
    prizeList.add(prize.prizeData);
    apiBodyObj['prize'] = jsonEncode(prizeList);

    Map<String, dynamic> response =
        await NetworkHelper.request('HackathonMini/AwardPrize', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: prizeList,
          builder:
              (BuildContext context, AsyncSnapshot<List<PrizeList>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      PrizeList prize = snapshot.data[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        leading: prize.prizeType == 'SPONSOR'
                            ? Icon(
                                Icons.redeem,
                                color: prize.isAwarded == '0'
                                    ? Theme.of(context).primaryColor
                                    : Colors.green,
                                size: 40,
                              )
                            : CircleAvatar(
                                radius: 22,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      prize.rank,
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'PRIZE',
                                      textScaleFactor: 1,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                        title: Text(prize.prize),
                        subtitle: buildAwardFunction(prize),
                      );
                    },
                  )
                : Center(child: Loading());
          },
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
