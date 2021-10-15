import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:tagcash/apps/helptutorial/models/help_tutorials.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'dart:convert';
import 'package:tagcash/apps/helptutorial/tutorial_lesson_detail_screen.dart';

class TutorialUserListScreen extends StatefulWidget {
  final List<String> inputTutorialIds;

  TutorialUserListScreen({Key key, @required this.inputTutorialIds})
      : super(key: key);

  @override
  _TutorialUserListScreenState createState() => _TutorialUserListScreenState();
}

class _TutorialUserListScreenState extends State<TutorialUserListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchInputController = TextEditingController();
  final scrollController = ScrollController();
  StreamController<List<Tutorial>> _streamcontroller;
  int offsetApi = 0;
  List<Tutorial> _data;
  bool hasMore;
  bool _isLoading;
  bool _isTemplate;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.inputTutorialIds != null) {
      _isTemplate = true;
    } else {
      _isTemplate = false;
    }
    _data = List<Tutorial>();
    _streamcontroller = StreamController<List<Tutorial>>.broadcast();

    _isLoading = false;
    hasMore = true;

    loadMoreItems();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        offsetApi = offsetApi + 10;
        loadMoreItems();
      }
    });
    super.initState();
  }

  Future<List<Tutorial>> allCreatedTutorialListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['page_count'] = '10';
    apiBodyObj['page_offset'] = offsetApi.toString();
    if (_isTemplate == false) {
      if (_searchInputController.text.toString().isNotEmpty)
        apiBodyObj["search_keyword"] = _searchInputController.text.toString();
    } else {
      String jsonTutorialIds = jsonEncode(widget.inputTutorialIds);

      apiBodyObj["tutorial_ids"] = jsonTutorialIds;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('HelpTutorial/ListTutorials', apiBodyObj);

    if (response['status'] == "success") {
      List responseList = response['result'];
      if (responseList != null) {
        List<Tutorial> getData = responseList.map<Tutorial>((json) {
          return Tutorial.fromJson(json);
        }).toList();
        return getData;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> dataRefresh() {
    // _streamcontroller.add(List<Transaction>());
    _isLoading = false;
    hasMore = true;
    offsetApi = 0;
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<Tutorial>();
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    allCreatedTutorialListLoad().then((res) {
      if (res != null) {
        _isLoading = false;
        _data.addAll(res);
        hasMore = (res.length == 10);

        _streamcontroller.add(_data);
      } else {
        showMessage(getTranslated(context, 'tutorial_list_empty'));
        _streamcontroller.add(null);
      }
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void navigateToTutorialDetailScreen(Tutorial obj) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialLessonDetailScreen(
            tutorialId: obj.id,
            tutorialName: obj.name,
            priceFree: obj.priceFree,
            imageUrl: obj.imageUrl,
            tutorialDescription: obj.description,
          ),
        ));
  }

  String getTutorialPrice(Tutorial obj) {
    String priceText = "";
    if (obj.priceFree == 1) {
      priceText = "Free";
    } else {
      priceText = "Paid";
    }
    return priceText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _isTemplate
          ? AppTopBar(
              appBar: AppBar(),
              title: getTranslated(context, "tutorial_title"),
            )
          : null,
      body: Column(
        children: [
          Card(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
              child: !_isTemplate
                  ? ListTile(
                      contentPadding: EdgeInsets.only(left: 20),
                      title: TextField(
                        controller: _searchInputController,
                        decoration: InputDecoration(
                            hintText: getTranslated(
                                context, 'tutorial_search_tutorial'),
                            border: InputBorder.none),
                        //onChanged: onSearchTextChanged,
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            loadMoreItems(clearCachedData: true);
                          }),
                    )
                  : Container()),
          Expanded(
            child: Container(
              child: RefreshIndicator(
                onRefresh: dataRefresh,
                child: StreamBuilder(
                    stream: _streamcontroller.stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Tutorial>> snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData)
                        return ListView.builder(
                            controller: scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: snapshot.data.length,
                            //itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < snapshot.data.length) {
                                Tutorial obj = snapshot.data[index];
                                String priceText = getTutorialPrice(obj);
                                return Card(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        navigateToTutorialDetailScreen(obj);
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 5),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    minWidth: 60,
                                                    minHeight: 60,
                                                    maxWidth: 60,
                                                    maxHeight: 60,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: obj.imageUrl,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      width: 80.0,
                                                      height: 80.0,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      width: 200,
                                                      height: 200,
                                                      decoration:
                                                          BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              color:
                                                                  Colors.grey),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                ),
                                                title: Text(
                                                  obj.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6
                                                      .copyWith(
                                                          color: Colors.black),
                                                ),
                                                subtitle: Text(
                                                  priceText,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2
                                                      .copyWith(
                                                          color: Colors.red),
                                                ),
                                                trailing: Icon(
                                                    Icons.keyboard_arrow_right),
                                              ),
                                            ],
                                          )),
                                    ));
                              } else if (hasMore) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else {
                                return Container();
                              }
                            });
                      else {
                        return Container();
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
