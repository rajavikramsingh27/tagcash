import 'package:flutter/material.dart';
import 'package:tagcash/apps/hackathon/models/project_list.dart';
import 'package:tagcash/apps/hackathon/models/score_list.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class AddScore extends StatefulWidget {
  final ProjectList project;
  final String hackathonId;
  final bool judgeUser;

  const AddScore({Key key, this.project, this.hackathonId, this.judgeUser})
      : super(key: key);

  @override
  _AddScoreState createState() => _AddScoreState();
}

class _AddScoreState extends State<AddScore> {
  Future<List<ScoreList>> scoreList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    scoreList = loadScoreList();
  }

  Future<List<ScoreList>> loadScoreList() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;
    apiBodyObj['project_id'] = widget.project.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/GetHackathonScore', apiBodyObj);

    List responseList = response['result'][0]['scoring_criteria'];
    List<ScoreList> getData = responseList.map<ScoreList>((json) {
      return ScoreList.fromJson(json);
    }).toList();

    return getData;
  }

  Map scoreStored = {};
  Map totalScoreStored = {};
  var totalScore = 0;

  scoreUpdateHandle(value) {
    scoreStored[value['scoringId']] = value['score'];

    var percentage = double.tryParse(value['percentage']) ?? 0;
    var scoreCount = int.tryParse(value['score']) ?? 0;

    var score = (percentage * (scoreCount * 10)) / 100;
    totalScoreStored[value['scoringId']] = score.toInt();

    totalScore = 0;
    totalScoreStored.forEach((k, v) {
      totalScore += v;
    });
    setState(() {});
  }

  addProjectScore() {
    setState(() {
      isLoading = true;
    });
    scoreStored.forEach((k, v) async {
      Map<String, String> apiBodyObj = {};
      apiBodyObj['hackathon_id'] = widget.hackathonId;
      apiBodyObj['project_id'] = widget.project.id;
      apiBodyObj['scoring_id'] = k.toString();
      apiBodyObj['score_count'] = v;
      if (widget.judgeUser) {
        apiBodyObj['role'] = 'judge';
      } else {
        apiBodyObj['role'] = 'public';
      }

      Map<String, dynamic> response = await NetworkHelper.request(
          'HackathonMini/AddHackathonScore', apiBodyObj);

      if (response['status'] == 'success') {
        // print(response);
      }
    });
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Overall Score - $totalScore%',
              style: Theme.of(context).textTheme.headline6.copyWith(
                    color: Colors.red,
                  ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: scoreList,
              builder: (BuildContext context,
                  AsyncSnapshot<List<ScoreList>> snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          ScoreList score = snapshot.data[index];
                          return ScoreCard(
                            score: score,
                            onScoreUpdate: (value) => scoreUpdateHandle(value),
                          );
                        },
                      )
                    : Center(child: Loading());
              },
            ),
            ElevatedButton(
              onPressed: () => addProjectScore(),
              child: Text(getTranslated(context, 'save')),
            )
          ],
        ),
        Positioned.fill(
          child: isLoading ? Center(child: Loading()) : SizedBox(),
        ),
      ],
    );
  }
}

class ScoreCard extends StatefulWidget {
  const ScoreCard({
    Key key,
    @required this.score,
    this.onScoreUpdate,
  }) : super(key: key);

  final ScoreList score;
  final Function(Map) onScoreUpdate;

  @override
  _ScoreCardState createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.score.percentage}% - ${widget.score.description}',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text('0'),
              Expanded(
                child: Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                    widget.onScoreUpdate({
                      'scoringId': widget.score.scoringId,
                      'percentage': widget.score.percentage,
                      'score': value.toInt().toString(),
                    });
                  },
                ),
              ),
              Text('10'),
            ],
          ),
        ],
      ),
    );
  }
}
