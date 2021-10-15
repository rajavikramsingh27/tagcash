import 'package:flutter/material.dart';
import 'package:tagcash/apps/hackathon/models/prize_list.dart';
import 'package:tagcash/apps/hackathon/models/project_list.dart';
import 'package:tagcash/apps/hackathon/models/score_detail.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class ProjectVotesPage extends StatefulWidget {
  final String hackathonId;
  final ProjectList project;
  final bool ownProject;

  const ProjectVotesPage(
      {Key key, this.project, this.ownProject, this.hackathonId})
      : super(key: key);
  @override
  _ProjectVotesPageState createState() => _ProjectVotesPageState();
}

class _ProjectVotesPageState extends State<ProjectVotesPage> {
  Future<List<ScoreDetail>> judgesVotes;
  Future<List<ScoreDetail>> publicVotes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loadAllScores();
  }

  void loadAllScores() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;
    apiBodyObj['project_id'] = widget.project.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/GetHackathonScoreDetail', apiBodyObj);

    List<PrizeList> getData = [];

    List judges = response['result']['judges'];
    List public = response['result']['public'];

    List<ScoreDetail> judgesDat = judges.map<ScoreDetail>((json) {
      return ScoreDetail.fromJson(json);
    }).toList();

    List<ScoreDetail> publicDat = public.map<ScoreDetail>((json) {
      return ScoreDetail.fromJson(json);
    }).toList();

    judgesVotes = Future.value(judgesDat);
    publicVotes = Future.value(publicDat);

    setState(() {
      isLoading = false;
    });
  }

  String buildScoreString(List<Scoring> scoring) {
    String scoreStr = '';

    for (Scoring item in scoring) {
      var percentage = double.tryParse(item.percentage) ?? 0;
      var scoreCount = int.tryParse(item.scoreCount) ?? 0;

      var score = ((percentage * (scoreCount * 10)) / 100).round();

      scoreStr += '$score% ${item.description}   ';
    }
    return scoreStr;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: !isLoading,
          child: ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              Text(
                'Judges Scores',
                style: Theme.of(context).textTheme.headline6,
              ),
              FutureBuilder(
                future: judgesVotes,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ScoreDetail>> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              contentPadding: EdgeInsets.all(0),

                              leading: CircleAvatar(
                                radius: 20,
                                child: Text(snapshot.data[index].overallScore),
                              ),
                              title: Text(snapshot.data[index].name),
                              subtitle: Text(buildScoreString(
                                  snapshot.data[index].scoring)),
                              // trailing:
                            );
                          },
                        )
                      : SizedBox();
                },
              ),
              Text(
                'Users Vote',
                style: Theme.of(context).textTheme.headline6,
              ),
              FutureBuilder(
                future: publicVotes,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ScoreDetail>> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              contentPadding: EdgeInsets.all(0),

                              leading: CircleAvatar(
                                radius: 20,
                                child: Text(snapshot.data[index].overallScore),
                              ),
                              title: Text(snapshot.data[index].name),
                              subtitle: Text(buildScoreString(
                                  snapshot.data[index].scoring)),
                              // trailing:
                            );
                          },
                        )
                      : SizedBox();
                },
              ),
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
