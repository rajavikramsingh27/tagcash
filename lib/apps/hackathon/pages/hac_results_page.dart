import 'package:flutter/material.dart';
import 'package:tagcash/apps/hackathon/models/results.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';

class HacResultsPage extends StatefulWidget {
  final String hackathonId;
  final bool ownerStatus;

  const HacResultsPage({Key key, this.hackathonId, this.ownerStatus})
      : super(key: key);

  @override
  _HacResultsPageState createState() => _HacResultsPageState();
}

class _HacResultsPageState extends State<HacResultsPage> {
  Future<List<Results>> resultsList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    resultsList = resultsListLoad();
  }

  Future<List<Results>> resultsListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/GetHackathonResult', apiBodyObj);

    List<Results> getData = [];

    List adminPrizeList = response['result']['admin_result'];
    List sponsorPrizeList = response['result']['sponsor_result'];

    List<Results> adminData = adminPrizeList.map<Results>((json) {
      return Results.fromJson(json);
    }).toList();

    List<Results> sponsorData = sponsorPrizeList.map<Results>((json) {
      return Results.fromJson(json);
    }).toList();

    getData.addAll(adminData);
    getData.addAll(sponsorData);

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: resultsList,
      builder: (BuildContext context, AsyncSnapshot<List<Results>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(kDefaultPadding),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Results results = snapshot.data[index];

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: results.prize.prizeType == 'SPONSOR'
                        ? Icon(
                            Icons.redeem,
                            size: 40,
                          )
                        : CircleAvatar(
                            radius: 22,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  results.prize.rank,
                                  textScaleFactor: 1,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'PRIZE',
                                  textScaleFactor: 1,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                    title: Text(results.prize.prize),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (results.prize.prizeType == 'SPONSOR') ...[
                          Text(results.prize.name),
                        ],
                        Text('${results.projectName} (${results.teamName})'),
                      ],
                    ),
                    // subtitle:  ,
                  );
                },
              )
            : Center(child: Loading());
      },
    );
  }
}
