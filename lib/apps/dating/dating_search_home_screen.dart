import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/dating/models/dating_user_details.dart';
import 'package:tagcash/apps/dating/profile_detail_screen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tagcash/apps/dating/dating_filter_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;


class DatingSearchHomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  DatingSearchHomeScreen({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _DatingSearchHomeScreen createState() => _DatingSearchHomeScreen();
}

class _DatingSearchHomeScreen extends State<DatingSearchHomeScreen> {
  bool isLoading = false;
  int offsetApi = 0;
  List<DatingUserDetails> _data;
  bool hasMore;
  bool _isLoading;

  bool refreshFlag = true;
  TextEditingController _nicknameSearchController;
  StreamController<List<DatingUserDetails>> _streamcontroller;
  final scrollController = ScrollController();
  String gender = "male";
  String filterDropdownfavourite = "My Favourites";
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  String countryCode = "PH";
  String countryId;
  BuildContext mContext;
  PersistentBottomSheetController _controller; // <------ Instance variable
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _nicknameSearchController = TextEditingController();
    _data = List<DatingUserDetails>();
    _streamcontroller = StreamController<List<DatingUserDetails>>.broadcast();
    _isLoading = false;
    hasMore = true;
    loadMoreItems();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        offsetApi = offsetApi + 20;
        loadMoreItems();
      }
    });

    // loadDatingProfilesList();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<DatingUserDetails>();
      _streamcontroller.add(_data);
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    loadDatingProfilesList().then((res) {

      if (res != null) {
        _isLoading = false;
        _data.addAll(res);
        hasMore = (res.length == 20);

        _streamcontroller.add(_data);
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nicknameSearchController.dispose();

    super.dispose();
  }

  void showInSnackBar(String value) {
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFe44933),
        content: Text(value),
      ),
    );
   */
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
      content: new Text(value),
      backgroundColor: Colors.red[600],
      duration: new Duration(seconds: 3),
    ));
  }

  Future<List<DatingUserDetails>> loadDatingProfilesList() async {

    List<DatingUserDetails> userDetailsListData = List<DatingUserDetails>();
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    if (_nicknameSearchController.text != "") {
      apiBodyObj['keyword'] = _nicknameSearchController.text;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String filterValues = prefs.getString('filterValues');

    if (filterValues != null) {
      apiBodyObj['filter'] = filterValues;
    }
    apiBodyObj['page_count'] = '20';
    apiBodyObj['page_offset'] = offsetApi.toString();
    //apiBodyObj['hide_status'] = '1'; /*For getting whole profiles with LIked Status and Hidden status we need these hard coded values*/
    // apiBodyObj['like_status'] = '1';
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/GetSearchProfiles', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == "success") {
      List responseList = response['result'];
      if (responseList.length > 0) {
        List<DatingUserDetails> getData =
            responseList.map<DatingUserDetails>((json) {
          return DatingUserDetails.fromJson(json);
        }).toList();
        for (DatingUserDetails datingUserDetails in getData) {
          userDetailsListData.add(datingUserDetails);
        }
        if (userDetailsListData.length > 0) {
          return userDetailsListData;
        } else {
          return null;
        }
      }
    } else {
      if (response['error'] == "pls_add_a_profile") {
        showInSnackBar(getTranslated(context, "dating_create_profilefirst"));
      }
      return null;
    }
  }

  int getGenderStatusValue(String genderStatus) {
    int value = 0;
    switch (genderStatus) {
      case "male":
        {
          value = 1;
        }
        break;
      case "female":
        {
          value = 2;
        }
        break;
      case "transgender":
        {
          value = 3;
        }
        break;
    }
    return value;
  }

  String getGenderStatusText(int genderStatus) {
    String value = "";
    switch (genderStatus) {
      case 1:
        {
          value = "male";
        }
        break;
      case 2:
        {
          value = "female";
        }
        break;
      case 3:
        {
          value = "transgender";
        }
        break;
    }
    return value;
  }

  int getFilterListValue(String listValue) {
    int value = 0;
    switch (listValue) {
      case "My Favourites":
        {
          value = 0;
        }
        break;
      case "Who Favourited Me":
        {
          value = 1;
        }
        break;
      case "My Visits":
        {
          value = 2;
        }
        break;
      case "Who Visited me":
        {
          value = 3;
        }
        break;
      case "My Matches":
        {
          value = 4;
        }
        break;
    }
    return value;
  }

  String getFilterTextListValue(int listValue) {
    String value = "";
    switch (listValue) {
      case 0:
        {
          value = "My Favourites";
        }
        break;
      case 1:
        {
          value = "Who Favourited Me";
        }
        break;
      case 2:
        {
          value = "My Visits";
        }
        break;
      case 3:
        {
          value = "Who Visited me";
        }
        break;
      case 4:
        {
          value = "My Matches";
        }
        break;
    }
    return value;
  }

  void showFilter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DatingFilterScreen()),
    ).then((value) {
      if (value != null) {
        _isLoading = false;
        loadMoreItems(clearCachedData: true);
      }
    });
  }

  void onSearchTextChanged() {
    FocusScope.of(context).unfocus();
    _isLoading = false;
    loadMoreItems(clearCachedData: true);
  }

  @override
  Widget build(BuildContext context) {
    Widget getImageWidget(DatingUserDetails datingUserDetails) {
      return GestureDetector(
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              children: [
                Expanded(
                  child: (datingUserDetails.uploadedImages.length > 0)
                      ? (kIsWeb)
                          ? CachedNetworkImage(
                              cacheKey: datingUserDetails.uploadedImages[0].id
                                  .toString(),
                              imageUrl: datingUserDetails
                                  .uploadedImages[0].imageFileName,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain),
                                  border: Border.all(
                                    color: Colors.grey[600],
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFB6B2B2),
                                  border: Border.all(
                                    color: Color(0XFFFFFF),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                          : CachedNetworkImage(
                              imageUrl: datingUserDetails
                                  .uploadedImages[0].imageFileName,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 200.0,
                                height: 200.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  shape: BoxShape.rectangle,
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
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                      : Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          decoration: BoxDecoration(
                            color: const Color(0XFFB6B2B2),
                            border: Border.all(
                              color: Color(0XFFFFFF),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                ),
                datingUserDetails.onlineStatus == 1
                    ? Divider(
                        color: Colors.green,
                        thickness: 4,
                      )
                    : Divider(
                        color: Colors.red,
                        thickness: 4,
                      ),
                Text(datingUserDetails.nickName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            )),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProfileDetailScreen(datingUserDetails: datingUserDetails),
            ),
          );
        },
      );
    }

    return Stack(
      children: [
        ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: TextField(
                          controller: _nicknameSearchController,
                          decoration: InputDecoration(
                            // labelText: "Search",
                            hintText: getTranslated(
                                context, 'dating_search_nickname'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(4, 20, 0, 0),
                      child: GestureDetector(
                          child: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 34,
                          ),
                          onTap: () {
                            onSearchTextChanged();
                          }),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: GestureDetector(
                        child: IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: Icon(
                            Icons.filter_alt,
                            size: 32,
                          ),
                          color: Colors.grey,
                          onPressed: () {
                            showFilter();
                          },
                        ),
                        onTap: () {
                          showFilter();
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: StreamBuilder(
                        stream: _streamcontroller.stream,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) print(snapshot.error);
                          if (snapshot.hasData) {
                            return GridView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              controller: scrollController,
                              itemCount: snapshot.data.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: (!kIsWeb)
                                          ? MediaQuery.of(context).size.width /
                                              (MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.4)
                                          : 1,
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4.0,
                                      mainAxisSpacing: 10.0),
                              itemBuilder: (BuildContext context, int index) {
                                DatingUserDetails datingUserDetails =
                                    snapshot.data[index];
                                if (index < snapshot.data.length) {
                                  return getImageWidget(datingUserDetails);
                                } else if (hasMore) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 32.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                } else {
                                  return SizedBox(
                                    width: 0,
                                    height: 0,
                                  );
                                }
                              },
                            );
                          } else {
                            return SizedBox(
                              width: 0,
                              height: 0,
                            );
                          }
                        })),
              ],
            ),
          ],
        ),

        isLoading ? Center(child: Loading()) : SizedBox(),
        //  isCityLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}


