import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/apps/agents/models/quiz_question.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

class AgentQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;

  AgentQuizScreen({this.questions});

  @override
  _AgentQuizScreenState createState() => _AgentQuizScreenState();
}

class _AgentQuizScreenState extends State<AgentQuizScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  int index = 0;
  List<String> answersArr = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "agents"),
      ),
      body: Stack(children: [
        Container(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (index + 1).toString() +
                    ") " +
                    widget.questions[index].question,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    String qStr = '{' +
                        '"question_id":"' +
                        widget.questions[index].id +
                        '","answer_index":"1"}';
                    answersArr.add(qStr);
                    if ((index + 1) < widget.questions.length) {
                      setState(() {
                        index++;
                      });
                    } else {
                      postHandler(answersArr.toString());
                    }
                  },
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  color: kPrimaryColor,
                  child: Text(widget.questions[index].option1,
                      style: TextStyle(fontSize: 14)),
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    String qStr = '{' +
                        '"question_id":"' +
                        widget.questions[index].id +
                        '","answer_index":"2"}';
                    answersArr.add(qStr);
                    if ((index + 1) < widget.questions.length) {
                      setState(() {
                        index++;
                      });
                    } else {
                      postHandler(answersArr.toString());
                    }
                  },
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  color: kPrimaryColor,
                  child: Text(widget.questions[index].option2,
                      style: TextStyle(fontSize: 14)),
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    String qStr = '{' +
                        '"question_id":"' +
                        widget.questions[index].id +
                        '","answer_index":"3"}';
                    answersArr.add(qStr);
                    if ((index + 1) < widget.questions.length) {
                      setState(() {
                        index++;
                      });
                    } else {
                      postHandler(answersArr.toString());
                    }
                  },
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  color: kPrimaryColor,
                  child: Text(widget.questions[index].option3,
                      style: TextStyle(fontSize: 14)),
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    String qStr = '{' +
                        '"question_id":"' +
                        widget.questions[index].id +
                        '","answer_index":"4"}';
                    answersArr.add(qStr);
                    if ((index + 1) < widget.questions.length) {
                      setState(() {
                        index++;
                      });
                    } else {
                      postHandler(answersArr.toString());
                    }
                  },
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  color: kPrimaryColor,
                  child: Text(widget.questions[index].option4,
                      style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(child: Loading()))
            : SizedBox(),
      ]),
    );
  }

  postHandler(String answers) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['answer'] = answers;
    Map<String, dynamic> response =
        await NetworkHelper.request('AgentQuiz/PostAnswer', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getResult();
    } else {
      setState(() {
        isLoading = false;
      });
//      String err = response['error'];
//      final snackBar =
//      SnackBar(content: Text(err), duration: const Duration(seconds: 3));
//      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  getResult() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('AgentQuiz/GetAllAgentQuiz');

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      List responseList = response['result'];
      List<QuizQuestion> questions = responseList.map<QuizQuestion>((json) {
        return QuizQuestion.fromJson(json);
      }).toList();
      if (questions.length == 0) {
        Navigator.of(context).pop({'status': 'success'});
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ResultDialog(
                questionSize: questions.length,
                questionWSize: widget.questions.length,
                onSuccess: (value) {
                  if (value == 'failed') {
                    Navigator.of(context).pop({'status': 'failed'});
                  }
                },
              );
            });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class ResultDialog extends StatefulWidget {
  ResultDialog({this.questionSize, this.questionWSize, this.onSuccess});

  int questionSize;
  int questionWSize;
  ValueChanged<String> onSuccess;

  @override
  _ResultDialogState createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        getTranslated(context, "agent_quiz"),
        style: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: kPrimaryColor),
      ),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          "You have " +
              widget.questionSize.toString() +
              "  incorrect answers out of " +
              widget.questionWSize.toString() +
              " questions. Please watch the Agent tutorial video and try again.",
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSuccess('failed');
            },
            textColor: Colors.white,
            padding: EdgeInsets.all(10.0),
            color: kPrimaryColor,
            child: Text(getTranslated(context, "ok"), style: TextStyle(fontSize: 16)),
          ),
        ),
      ]),
    );
  }
}
