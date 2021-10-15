import 'package:flutter/material.dart';
import 'package:tagcash/apps/helptutorial/models/help_tutorials.dart';
import 'package:tagcash/services/networking.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tagcash/services/app_service.dart';
import 'package:tagcash/apps/helptutorial/tutorial_create_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'dart:async';

class HelpTutorialsScreen extends StatefulWidget {
  @override
  _HelpTutorialsScreen createState() => _HelpTutorialsScreen();
}

class _HelpTutorialsScreen extends State<HelpTutorialsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Tutorial>> tutorialsList;

  bool isLoading = false;
  bool isMerchantPerspective = false;

  final _searchInputController = TextEditingController();
  final scrollController = ScrollController();
  StreamController<List<Tutorial>> _streamcontroller;
  int offsetApi = 0;
  List<Tutorial> _data;
  bool hasMore;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    isMerchantPerspective = AppService.isMerchantPerspective(context);
    isLoading = false;

    // tutorialsList = getTutorialList();
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
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future<void> refreshTutorialsList() {
    reloadTutorialsList();
    return Future.value();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<Tutorial>();
      _streamcontroller.add(_data);

      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    getTutorialList().then((res) {
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

  Future<List<Tutorial>> getTutorialList() async {
    setState(() {
      isLoading = true;
    });
    var searchValue = _searchInputController.text;

    var apiBodyObj = {};
    if (searchValue.isNotEmpty) apiBodyObj["search"] = searchValue;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/HelpTutorialSearchMerchant', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      List responseList = response['result'];
      return responseList.map<Tutorial>((json) {
        return Tutorial.fromJson(json);
      }).toList();
    }
    return [];
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  RefreshIndicator buildTutorialsList(List<Tutorial> tutorialsList) {
    return RefreshIndicator(
        onRefresh: refreshTutorialsList,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: tutorialsList.length,
            itemBuilder: (context, i) {
              return buildRow(tutorialsList[i]);
            }));
  }

  buildRow(Tutorial tutorial) {
    String priceText = getTutorialPrice(tutorial);
    return Card(
        margin: EdgeInsets.only(left: 0, right: 5, bottom: 10),
        child: GestureDetector(
          onTap: () {
            navigaeToTutorialClickHandler(tutorial.id);
          },
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                        imageUrl: tutorial.imageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              shape: BoxShape.rectangle,
                              color: Colors.grey),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    title: Text(
                      tutorial.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      priceText,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .copyWith(color: Colors.red),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              )),
        ));
  }

  reloadTutorialsList() {
    setState(() {
      tutorialsList = getTutorialList();
    });
  }

  void loadTutorialsList() {
    setState(() {
      tutorialsList = getTutorialList();
    });
  }

  void navigaeToTutorialClickHandler(String tutorialid) async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialCreateScreen(
          tutorial_id: tutorialid,
        ),
      ),
    ).whenComplete(() => dataRefresh());
  }

  Future<void> dataRefresh() {
    _searchInputController.text = "";
    _isLoading = false;
    hasMore = true;
    offsetApi = 0;
    loadMoreItems(clearCachedData: true);
    return Future.value();
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
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "tutorial_title"),
        ),
        key: _scaffoldKey,
        body: Column(
          children: [
            Card(
                margin:
                    EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 20),
                  title: TextField(
                    controller: _searchInputController,
                    decoration: InputDecoration(
                        hintText:
                            getTranslated(context, 'tutorial_search_tutorial'),
                        border: InputBorder.none),
                    //onChanged: onSearchTextChanged,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        loadMoreItems(clearCachedData: true);
                      }),
                )),
            Expanded(
              child: Container(
                child: RefreshIndicator(
                  onRefresh: dataRefresh,
                  child: StreamBuilder(
                      stream: _streamcontroller.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Tutorial>> snapshot) {
                        if (snapshot.hasError) print(snapshot.error);
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                          navigaeToTutorialClickHandler(obj.id);
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
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
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
                                                                color: Colors
                                                                    .grey),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    obj.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        .copyWith(
                                                            color:
                                                                Colors.black),
                                                  ),
                                                  subtitle: Text(
                                                    priceText,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        .copyWith(
                                                            color: Colors.red),
                                                  ),
                                                  trailing: Icon(Icons
                                                      .keyboard_arrow_right),
                                                ),
                                              ],
                                            )),
                                      ));
                                } else if (hasMore) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 32.0),
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
        floatingActionButton: AppService.isMerchantPerspective(context)
            ? FloatingActionButton(
                onPressed: () {
                  navigaeToTutorialClickHandler(null);
                },
                child: Icon(Icons.add),
                tooltip: getTranslated(context, "tutorials_create"),
                backgroundColor: Theme.of(context).primaryColor,
              )
            : SizedBox());
  }
}
