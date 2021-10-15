import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:http/http.dart' as http;
import 'package:tagcash/constants.dart';

import 'lessons_screen.dart';
import 'models/category.dart';
import 'models/course.dart';

class VtcCoursesScreen extends StatefulWidget {
  @override
  _VtcCoursesScreenState createState() => _VtcCoursesScreenState();
}

class _VtcCoursesScreenState extends State<VtcCoursesScreen> {
  StreamController<List<Course>> _streamcontroller;
  List<Course> _courses;

  String nowCatId = '1';
  bool searching = false;

  @override
  void initState() {
    super.initState();

    _courses = List<Course>();
    _streamcontroller = StreamController<List<Course>>.broadcast();

    getCoursesListLoad();
  }

  loadCategoryCourses(int catIdSelected) async {
    nowCatId = catIdSelected.toString();
    getCoursesListLoad();
  }

  searchClicked(String searchValue) {
    if (searchValue.trim() != '') {
      getCoursesListLoad(searchValue.trim());
    } else {
      getCoursesListLoad();
    }
  }

  void getCoursesListLoad([String searchKey]) {
    _courses = <Course>[];
    _streamcontroller.add(null);

    getCoursesList(searchKey).then((res) {
      if (res.length != 0) {
        _courses.addAll(res);
      }

      _streamcontroller.add(_courses);
    });
  }

  Future<List<Course>> getCoursesList(String searchKey) async {
    String urlPath;
    if (searchKey != null) {
      setState(() {
        searching = true;
      });
      urlPath =
          'https://www.vtc.com/services/demoTitle.php?mode=titleSearch&searchStr=$searchKey';
    } else {
      setState(() {
        searching = false;
      });
      urlPath =
          'https://www.vtc.com/services/demoTitle.php?mode=getTitles&catId=$nowCatId&language=english';
    }
    final http.Response response = await http.get(
      Uri.parse(urlPath),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
    );

    List<Course> getData = [];
    List responseList = jsonDecode(response.body);

    if (responseList != null) {
      getData = responseList.map<Course>((json) {
        return Course.fromJson(json);
      }).toList();
    }

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'VTC',
        onSearch: searchClicked,
      ),
      body: Column(
        children: [
          SizedBox(height: 6),
          searching
              ? SizedBox()
              : CategoryMenu(
                  onCategoryChange: (value) {
                    loadCategoryCourses(value);
                  },
                ),
          Expanded(
            child: StreamBuilder(
              stream: _streamcontroller.stream,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? coursesListView(snapshot)
                    : Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView coursesListView(AsyncSnapshot<List<Course>> snapshot) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
          visualDensity: VisualDensity(vertical: -2),
          title: Text(snapshot.data[index].name),
          subtitle: Row(
            children: [
              Text(
                '${snapshot.data[index].movieCount} Lessons ',
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Colors.red),
              ),
              SizedBox(width: 10),
              Text('${snapshot.data[index].totalTime} total hours'),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LessonsScreen(course: snapshot.data[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class CategoryMenu extends StatefulWidget {
  final Function(int) onCategoryChange;

  const CategoryMenu({Key key, this.onCategoryChange}) : super(key: key);
  @override
  _CategoryMenuState createState() => _CategoryMenuState();
}

class _CategoryMenuState extends State<CategoryMenu> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categorys.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(top: 4, right: 20),
            child: GestureDetector(
              onTap: () {
                widget.onCategoryChange(categorys[index].id);
                setState(() {
                  selectedIndex = categorys[index].id;
                });
              },
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: 60.0,
                    // margin: EdgeInsetsDirectional.only(top: 20),
                    child: Icon(
                      categorys[index].icon,
                      color: selectedIndex == categorys[index].id
                          ? Colors.white
                          : categorys[index].color,
                      size: 36,
                    ),
                    decoration: BoxDecoration(
                      color: selectedIndex == categorys[index].id
                          ? Colors.grey
                          : Color(0xFFF8F8FA),
                      border: Border.all(
                        width: 1,
                        color: Color(0xFFE3E7FA),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 0),
                          blurRadius: 8,
                          color: Color(0xFFd8d7d7).withOpacity(1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    categorys[index].title,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
