import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/constants.dart';

import 'lessons_detail_screen.dart';
import 'models/chapter.dart';
import 'models/course.dart';
import 'models/lesson.dart';
import 'package:http/http.dart' as http;
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class LessonsScreen extends StatefulWidget {
  final Course course;

  LessonsScreen({this.course});

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  Future<List<Chapter>> chapters;

  @override
  void initState() {
    super.initState();

    chapters = getCoursesList(widget.course.sku);
  }

  Future<List<Chapter>> getCoursesList(nowSku) async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://www.vtc.com/services/demoTitle.php?mode=getLessons&sku=$nowSku'),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
    );

    List responseList = jsonDecode(response.body);

    List<Chapter> getData = responseList.map<Chapter>((json) {
      return Chapter.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: widget.course.name,
      ),
      body: FutureBuilder(
        future: chapters,
        builder: (BuildContext context, AsyncSnapshot<List<Chapter>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? chapterssListView(snapshot)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  ListView chapterssListView(AsyncSnapshot<List<Chapter>> snapshot) {
    return ListView.builder(
      padding: EdgeInsets.all(kDefaultPadding),
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                snapshot.data[index].chapter,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Card(
              elevation: 4,
              child: lessonsListView(
                  snapshot.data[index].lessons, widget.course.sku),
            ),
          ],
        );
      },
    );
  }

  ListView lessonsListView(List<dynamic> lessons, String sku) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      shrinkWrap: true,
      primary: false,
      itemCount: lessons.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(lessons[index]['lesson']),
          onTap: () {
            if (AppConstants.getServer() == 'beta') {
              showSimpleDialog(context,
                  title: 'Demo Mode',
                  message: 'Lessons won\'t work in demo mode');
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonsDetailScreen(
                    lesson: Lesson(
                      sku: sku,
                      lessonId: lessons[index]['lessonId'],
                      lesson: lessons[index]['lesson'],
                      movieCode: lessons[index]['movieCode'],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
