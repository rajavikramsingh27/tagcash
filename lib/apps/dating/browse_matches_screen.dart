import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/dating/models/dating_user_details.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'dart:async';
import 'package:tagcash/apps/dating/models/matched_profile_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tagcash/apps/dating/profile_detail_screen.dart';
import 'package:tcard/tcard.dart';
import 'dart:convert';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingBrowseMatchesScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  DatingBrowseMatchesScreen({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _DatingBrowseMatchesScreen createState() => _DatingBrowseMatchesScreen();
}

class _DatingBrowseMatchesScreen extends State<DatingBrowseMatchesScreen> {
  bool refreshFlag = true;
  bool hasMore;
  bool _isLoading;
  List<MatchedProfileData> _data;
  StreamController<List<MatchedProfileData>> _streamcontroller;
  final scrollController = ScrollController();
  Color _likedSelectedColor = Colors.green;
  Color _likeNonSelectedColor = Colors.grey;
  DatingUserDetails activeProfile;
  int offsetApi = 0;
  bool _isLikeFlag = false;
  int count;
  int offset;
  int index = 0;
  bool isLoading = false;
  bool isMatchesLoading = false;
  Future<List<DatingUserDetails>> browseProfilesFutureListData;
  List<DatingUserDetails> browseProfileListData;
  bool _isBrowseFlag = true;
  Color _browseSelectedColor = Colors.grey;
  Color _matchesSelectedColor = Colors.white;
  Color _browseSelectedTextColor = Colors.white;
  Color _matchesSelectedTextColor = Colors.black;
  TCardController _controller = TCardController();
  int _index = 0;
  bool _isLikeHideFlag = false;
  bool _isMatchesLoadingFlag = false;
  bool _isBrowseLoadingFlag = true;
  int profileVisitCounter = 0;
  bool _controllerForwardFlag = false;

  @override
  void initState() {
    super.initState();
    _data = List<MatchedProfileData>();
    _streamcontroller = StreamController<List<MatchedProfileData>>.broadcast();
    _isLoading = false;
    hasMore = true;
    browseProfilesFutureListData = loadBrowseProfilesListData();
    browseProfilesFutureListData
        .then((List<DatingUserDetails> browseProfileList) {
      setActiveProfile(0);
      browseProfileListData = browseProfileList;
      showLikeDislikeColor();
    }).catchError((error) => print(error));
  }

  void setActiveProfile(int index) {
    browseProfilesFutureListData
        .then((List<DatingUserDetails> browseProfileList) {
      activeProfile = browseProfileList[index];
    }).catchError((error) => print(error));
  }

  void showLikeDislikeColor() {
    browseProfilesFutureListData
        .then((List<DatingUserDetails> browseProfileList) {
      if (activeProfile.likedStatus == 0) {
        _isLikeFlag = false;
        _likeNonSelectedColor = Colors.grey;
      } else {
        _isLikeFlag = true;
        _likedSelectedColor = Colors.green;
      }
    }).catchError((error) => print(error));
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

  void loadMatches() {
    loadMoreItems(clearCachedData: true);

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        offsetApi = offsetApi + 20;
        loadMoreItems();
      }
    });
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      isMatchesLoading = true;
      _data = List<MatchedProfileData>();
      _streamcontroller.add(_data);
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    loadMatchesProfilesListData().then((res) {
      _isLoading = false;
      _data.addAll(res);
      hasMore = (res.length == 20);

      _streamcontroller.add(_data);
    });
  }

  void deleteMatchProfileProcessHandler(MatchedProfileData obj) async {
    setState(() {
      isMatchesLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj[' profile_id'] = obj.profileId;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/UnLikeAProfile', apiBodyObj);

    setState(() {
      isMatchesLoading = false;
    });
    if (response["status"] == "success") {
      _isLoading = false;
      hasMore = true;
      offsetApi = 0;
      refreshFlag = true;
      loadMoreItems(clearCachedData: true);
    } else {
      showInSnackBar(getTranslated(context, "dating_matchprofile_failed"));
    }
  }

  Future<List<MatchedProfileData>> loadMatchesProfilesListData() async {
    setState(() {
      if (refreshFlag == true) {
        hasMore = false;
        isMatchesLoading = true;
        offsetApi = 0;
      } else {
        hasMore = true;
        isMatchesLoading = false;
      }
    });
    _isMatchesLoadingFlag = true;
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['count'] = '20';
    apiBodyObj['offset'] = offsetApi.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/GetMatchedProfiles', apiBodyObj);

    setState(() {
      isMatchesLoading = false;
    });
    _isMatchesLoadingFlag = false;
    if (response['status'] == "success") {
      List responseList = response['profile_details'];
      List<MatchedProfileData> getData =
          responseList.map<MatchedProfileData>((json) {
        return MatchedProfileData.fromJson(json);
      }).toList();
      return getData;
    } else {
      return null;
    }
  }

  Future<List<DatingUserDetails>> loadBrowseProfilesListData() async {
    List<DatingUserDetails> userDetailsListData = List<DatingUserDetails>();
    setState(() {
      isLoading = true;
    });
    _isBrowseLoadingFlag = true;
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['page_count'] = '20';
    apiBodyObj['page_offset'] = offsetApi.toString();
    //apiBodyObj['hide_status'] = '1';
    // apiBodyObj['like_status'] = '1';
    apiBodyObj['swipe_status'] = '1';
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/GetSearchProfiles', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    _isBrowseLoadingFlag = false;
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
          _isLikeHideFlag = true;
          return userDetailsListData;
        } else {
          _isLikeHideFlag = true;
          showInSnackBar(getTranslated(context, "dating_profilelist_empty"));
          return null;
        }
      } else {
        _isLikeHideFlag = false;
        showInSnackBar(getTranslated(context, "dating_profilelist_empty"));
        return null;
      }
    } else {
      _isLikeHideFlag = false;

      return null;
    }
  }

  Future<List<DatingUserDetails>> loadBrowseProfilesListDataBlank() async {
    return null;
  }

  void likeProfileProcessHandler() async {
    Map<String, dynamic> response;
    if (_isLikeFlag == true) {
      //_isLikeFlag=false;
      _likedSelectedColor = Colors.grey;
    } else {
      //_isLikeFlag=true;
      _likeNonSelectedColor = Colors
          .green; //Here we change the color to indicate that ,user changes from DISLIKE status to LIKE status
    }
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj[' profile_id'] = activeProfile.id;
    if (activeProfile.likedStatus == 1) {
      response =
          await NetworkHelper.request('Dating/UnLikeAProfile', apiBodyObj);
    } else {
      response = await NetworkHelper.request('Dating/LikeAProfile', apiBodyObj);
    }

    if (response["status"] == "success") {
      browseProfilesFutureListData
          .then((List<DatingUserDetails> browseProfileList) {
        if (_index < browseProfileList.length) {
          _controllerForwardFlag = true;
          _controller.forward();
          setActiveProfile(_index);
          showLikeDislikeColor();
        } else {
          _isLikeHideFlag = false;
          offsetApi = offsetApi + 20;
          browseProfileListData.clear();
          browseProfilesFutureListData = loadBrowseProfilesListDataBlank();
          browseProfilesFutureListData = loadBrowseProfilesListData();
          browseProfilesFutureListData
              .then((List<DatingUserDetails> browseProfileList) {
//activeProfile=browseProfileList[0];
            _index = 0;

            setActiveProfile(0);
            showLikeDislikeColor();
            browseProfileListData = browseProfileList;
          }).catchError((error) => showInSnackBar(error));
        }
        setState(() {
          isLoading = false;
        });
      });
    } else {}
  }

  void hideProcessClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj[' profile_id'] = activeProfile.id;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/HideAProfile', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      browseProfilesFutureListData
          .then((List<DatingUserDetails> browseProfileList) {
        if (_index < browseProfileList.length) {
          _controllerForwardFlag = true;
          _controller.forward();
          setActiveProfile(_index);
        } else {
          _isLikeHideFlag = false;
          offsetApi = offsetApi + 20;
          browseProfileListData.clear();
          browseProfilesFutureListData = loadBrowseProfilesListDataBlank();
          browseProfilesFutureListData = loadBrowseProfilesListData();
          browseProfilesFutureListData
              .then((List<DatingUserDetails> browseProfileList) {
            _index = 0;
            ;
            setActiveProfile(0);
            browseProfileListData = browseProfileList;
          }).catchError((error) => showInSnackBar(error));
        }
      });
    } else {
      if (response['error'] == "profile_is_already_hided") {
        showInSnackBar(getTranslated(context, "dating_profilealready_hided"));
      } else if (response['error'] == "failed_to_hide_the_profile") {
        showInSnackBar(getTranslated(context, "dating_profilehide_failed"));
      } else if (response['error'] == "request_not_completed") {
        showInSnackBar(
            getTranslated(context, "dating_profile_requestnotcompleted"));
      } else {
        showInSnackBar(getTranslated(context, "dating_unspecified_error"));
      }
    }
  }

  void navigateToProfileDetailScreen(MatchedProfileData obj) {
    List<UploadedImages> uploadedImages = List<UploadedImages>();
    obj.uploadedImages.forEach((UploadedImagesMatchedProfile uploadedImage) {
      UploadedImages imageObj = new UploadedImages(
          id: uploadedImage.id,
          imageName: uploadedImage.imageName,
          imageFileName: uploadedImage.imageFileName,
          uploadedDate: uploadedImage.uploadedDate,
          mainStatus: uploadedImage.mainStatus);
      uploadedImages.add(imageObj);
    });
    DatingUserDetails userDetails = new DatingUserDetails(
        id: obj.profileId,
        age: obj.age,
        dob: null,
        dobStrtime: null,
        countryId: obj.countryId,
        cityId: obj.cityId,
        cityName: obj.cityName,
        description: obj.description,
        countryName: null,
        genderId: obj.genderId,
        hidedStatus: null,
        likedStatus: null,
        nickName: obj.nickName,
        occupation: obj.occupation,
        onlineStatus: null,
        uploadedImages: uploadedImages,
        viewMyProfileOnly: null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileDetailScreen(datingUserDetails: userDetails),
      ),
    );
  }

  void checkProfileListCompleted(int indexProfile) {
    if (indexProfile == browseProfileListData.length) {
      _isLikeHideFlag = false;
      offsetApi = offsetApi + 20;
      browseProfileListData.clear();
      browseProfilesFutureListData = loadBrowseProfilesListDataBlank();
      browseProfilesFutureListData = loadBrowseProfilesListData();
      browseProfilesFutureListData
          .then((List<DatingUserDetails> browseProfileList) {
        _index = 0;
        setActiveProfile(0);
        showLikeDislikeColor();
        profileVisitCounter = 0;
        browseProfileListData = browseProfileList;
      }).catchError((error) => print(error));
    } else {
      _isLikeHideFlag = true;
    }
  }

  /*This API call is to do LIKE when swipe right, Here we do not check the response status*/
  void swipeLikeProcessClickHandler() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj[' profile_id'] = activeProfile.id;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/LikeAProfile', apiBodyObj);
  }

  void swipeLiftViewedProfileProcessHandler() async {
    List<String> visitedProfileIds = List<String>();
    visitedProfileIds.add(activeProfile.id.toString());
    String visitedProfileidData = jsonEncode(visitedProfileIds);
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['profile_ids'] = visitedProfileidData;
    Map<String, dynamic> response = await NetworkHelper.request(
        'Dating/UpdateViewedProfileIds', apiBodyObj);
  }

  void showImage(String imagePath, String imageid) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20.0),
                child: CachedNetworkImage(
                  cacheKey: imageid,
                  useOldImageOnUrlChange: true,
                  imageUrl: imagePath,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                      height: 20,
                      width: 20,
                      child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getCards() {
      List<String> images = new List<String>();
      browseProfileListData.forEach((element) {
        if (element.uploadedImages.length > 0) {
          images.add(element.uploadedImages[0].imageFileName);
        } else {
          images.add("");
        }
      });

      List<Widget> cards = List.generate(
        images.length,
        (int index) {
          DatingUserDetails userObj = browseProfileListData[index];
          String nickName = browseProfileListData[index].nickName;
          return (images[index].isEmpty)
              ? Stack(
                  children: [
                    SizedBox.expand(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 17),
                              blurRadius: 23.0,
                              spreadRadius: -13.0,
                              color: Colors.black54,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Center(
                            child: Text(
                              getTranslated(context,"dating_profileimage_notavailable"),
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox.expand(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black54],
                                begin: Alignment.center,
                                end: Alignment.bottomCenter)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(nickName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700)),
                              Padding(padding: EdgeInsets.only(bottom: 8.0)),
                              ConditionalSwitch.single<int>(
                                context: context,
                                valueBuilder: (BuildContext context) =>
                                    userObj.genderId,
                                caseBuilders: {
                                  1: (BuildContext context) => Text(
                                      userObj.age.toString() +
                                          "/" +getTranslated(context,"dating_male")+
                                          "/" +
                                          userObj.countryName +
                                          "/" +
                                          userObj.cityName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  2: (BuildContext context) => Text(
                                      userObj.age.toString() +
                                          "/" +getTranslated(context,"dating_female")+
                                          "/" +
                                          userObj.countryName +
                                          "/" +
                                          userObj.cityName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  3: (BuildContext context) => Text(
                                      userObj.age.toString() +"/"+getTranslated(context,"dating_transgender")+
                                          "/" +
                                          userObj.countryName +
                                          "/" +
                                          userObj.cityName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                      )),
                                },
                                fallbackBuilder: (BuildContext context) =>
                                    Text(getTranslated(context,"dating_noneofthecase_matched")),
                              ),
                            ],
                          )),
                    )
                  ],
                )
              : Stack(
                  children: [
                    SizedBox.expand(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 17),
                              blurRadius: 23.0,
                              spreadRadius: -13.0,
                              color: Colors.black54,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox.expand(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black54],
                                begin: Alignment.center,
                                end: Alignment.bottomCenter)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(nickName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700)),
                              Padding(padding: EdgeInsets.only(bottom: 8.0)),
                              ConditionalSwitch.single<int>(
                                context: context,
                                valueBuilder: (BuildContext context) =>
                                    userObj.genderId,
                                caseBuilders: {
                                  1: (BuildContext context) => Text(
                                      userObj.age.toString() +
                                          "/" +getTranslated(context, "dating_male")+
                                          "/" +
                                          userObj.countryName +
                                          "/" +
                                          userObj.cityName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  2: (BuildContext context) => Text(
                                      userObj.age.toString() +
                                          "/" +getTranslated(context, "dating_female")+
                                          "/" +
                                          userObj.countryName +
                                          "/" +
                                          userObj.cityName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  3: (BuildContext context) => Text(
                                      userObj.age.toString() +getTranslated(context, "dating_transgender")+
                                          "/" +
                                          userObj.countryName +
                                          "/" +
                                          userObj.cityName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400,
                                      )),
                                },
                                fallbackBuilder: (BuildContext context) =>
                                    Text(getTranslated(context,getTranslated(context, "dating_transgender"))),
                              ),
                            ],
                          )),
                    )
                  ],
                );
        },
      );
      return cards;
    }

    Widget browseProfileWidgetSection = Container(
        child: FutureBuilder(
            future: browseProfilesFutureListData,
            builder: (BuildContext context,
                AsyncSnapshot<List<DatingUserDetails>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.data == null) {
                return Container();
              }
              if (snapshot.data.length > 0) {
                if (snapshot.hasData) {
                  return Expanded(
                      child: Column(children: [
                    GestureDetector(
                      child: TCard(
                        size: Size(
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height * .58,
                        ),
                        cards: getCards(),
                        controller: _controller,
                        onForward: (index, info) {
                          if (_controllerForwardFlag == false) {
                            if (info.direction == SwipDirection.Right) {
                              swipeLikeProcessClickHandler();
                            } else {
                              profileVisitCounter++;
                              swipeLiftViewedProfileProcessHandler();
                            }
                          }
                          _controllerForwardFlag = false;
                          _index = index;

                          setActiveProfile(_index);
                          showLikeDislikeColor();
                          setState(() {});
                        },
                        onBack: (index, info) {
                          _index = index;
                          setState(() {});
                        },
                        onEnd: () {
                          checkProfileListCompleted(_index);
                        },
                      ),
                      onTap: () {
                        showImage(
                            browseProfileListData[_index]
                                .uploadedImages[0]
                                .imageName,
                            browseProfileListData[_index]
                                .uploadedImages[0]
                                .id
                                .toString());
                      },
                    ),
                    _isLikeHideFlag
                        ? Expanded(
                            child: Center(
                                child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RawMaterialButton(
                                onPressed: () {
                                  hideProcessClickHandler();
                                },
                                elevation: 2.0,
                                fillColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 30.0,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(10.0),
                                shape: CircleBorder(),
                              ),
                              SizedBox(width: 20),
                              RawMaterialButton(
                                onPressed: () {
                                  likeProfileProcessHandler();
                                },
                                elevation: 2.0,
                                fillColor: _isLikeFlag
                                    ? _likedSelectedColor
                                    : _likeNonSelectedColor,
                                child: Icon(
                                  Icons.done,
                                  size: 30.0,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(10.0),
                                shape: CircleBorder(),
                              ),
                            ],
                          )))
                        : Container()
                  ]));
                } else {
                  return SizedBox(
                    height: 0,
                  );
                }
              } else {
                return SizedBox(
                  height: 0,
                );
              }
            }));

    Widget matchesProfileWidgetSection = Stack(children: [
      ListView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          StreamBuilder(
              stream: _streamcontroller.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                if (snapshot.hasData) {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < snapshot.data.length) {
                          MatchedProfileData obj = snapshot.data[index];

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              child: (obj.uploadedImages
                                                          .length >
                                                      0)
                                                  ? CachedNetworkImage(
                                                      imageUrl: obj
                                                          .uploadedImages[0]
                                                          .imageFileName,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 60.0,
                                                        height: 60.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          Container(
                                                              width: 60,
                                                              height: 60),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        width: 60,
                                                        height: 60,
                                                        child: Icon(
                                                            Icons.person,
                                                            color: Colors.grey,
                                                            size: 48),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 60,
                                                      height: 60,
                                                      child: Icon(Icons.person,
                                                          color: Colors.grey,
                                                          size: 48),
                                                    ),
                                            ),
                                            Container(
                                              width: 6,
                                              height: 60,
                                              color: Colors.green,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  4, 0, 0, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(obj.nickName,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  ConditionalSwitch.single<int>(
                                                    context: context,
                                                    valueBuilder: (BuildContext
                                                            context) =>
                                                        obj.genderId,
                                                    caseBuilders: {
                                                      1: (BuildContext
                                                              context) =>
                                                          Text(
                                                              obj.age.toString() +
                                                                  "/" +
                                                                  getTranslated(context,"dating_male")+"/" +
                                                                  obj.cityName,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                      2: (BuildContext
                                                              context) =>
                                                          Text(
                                                              obj.age.toString() +
                                                                  "/" +
                                                                  getTranslated(context,"dating_female")+"/" +
                                                                  obj.cityName,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                      3: (BuildContext
                                                              context) =>
                                                          Text(
                                                              obj.age.toString() +
                                                                  "/"+getTranslated(context,"dating_transgender")+"/" +
                                                                  obj.cityName,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                    },
                                                    fallbackBuilder: (BuildContext
                                                            context) =>
                                                        Text(
                                                            'None of the cases matched!'),
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  if (obj.lastMessage != null)
                                                    Container(
                                                        child: ConditionalSwitch
                                                            .single<String>(
                                                      context: context,
                                                      valueBuilder:
                                                          (BuildContext
                                                                  context) =>
                                                              obj.lastMessage
                                                                  .messageType,
                                                      caseBuilders: {
                                                        "text": (BuildContext
                                                                context) =>
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .5,
                                                              child: Text(
                                                                  "\"" +
                                                                      obj.lastMessage
                                                                          .message +
                                                                      "\"",
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  )),
                                                            ),
                                                        "image": (BuildContext
                                                                context) =>
                                                            Text(
                                                                "\"" +
                                                                    "sent image" +
                                                                    "\"",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                )),
                                                        "send-money": (BuildContext
                                                                context) =>
                                                            Text(
                                                                "\"" +
                                                                    "sent money" +
                                                                    "\"",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                )),
                                                        "tag-profile": (BuildContext
                                                                context) =>
                                                            Text(
                                                                "\"" +
                                                                    "shared TAG Profile" +
                                                                    "\"",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                )),
                                                      },
                                                      fallbackBuilder: (BuildContext
                                                              context) =>
                                                          Text(
                                                              'None of the cases matched!'),
                                                    )),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        onTap: () {
                                          navigateToProfileDetailScreen(obj);
                                        },
                                      ),
                                      InkWell(
                                        // When the user taps the button, show a snackbar.
                                        onTap: () {
                                          deleteMatchProfileProcessHandler(obj);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.delete,
                                              size: 24,
                                              color: Color(0xFF535353)),
                                        ),
                                      )
                                    ])),
                          );
                        } else if (hasMore) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return SizedBox(
                            width: 0,
                            height: 0,
                          );
                        }
                      });
                } else {
                  return SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
              }),
        ],
      ),
    ]);
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(children: [
                Expanded(
                    child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              border: Border(
                                top: BorderSide(color: Color(0XFF7E7A78)),
                                bottom: BorderSide(color: Color(0XFF7E7A78)),
                                right: BorderSide(color: Color(0XFF7E7A78)),
                                left: BorderSide(color: Color(0XFF7E7A78)),
                              ),
                              color: _browseSelectedColor),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(6, 10, 6, 10),
                              child: Text('Browse',
                                  style: TextStyle(
                                    color: _browseSelectedTextColor,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (_isMatchesLoadingFlag == false) {
                              if (_isBrowseFlag == false) {
                                _browseSelectedColor = Colors.grey;
                                _matchesSelectedColor = Colors.white;
                                _browseSelectedTextColor = Colors.white;
                                _matchesSelectedTextColor = Colors.black;
                                _isBrowseFlag = true;
                              }
                            }
                          });
                        })),
                Expanded(
                    child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              border: Border(
                                top: BorderSide(color: Color(0XFF7E7A78)),
                                bottom: BorderSide(color: Color(0XFF7E7A78)),
                                right: BorderSide(color: Color(0XFF7E7A78)),
                                left: BorderSide(color: Color(0XFF7E7A78)),
                              ),
                              color: _matchesSelectedColor),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(6, 10, 6, 10),
                              child: Text('Matches',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _matchesSelectedTextColor,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (_isBrowseLoadingFlag == false) {
                              if (_isBrowseFlag == true) {
                                _browseSelectedColor = Colors.white;
                                _matchesSelectedColor = Colors.grey;
                                _browseSelectedTextColor = Colors.black;
                                _matchesSelectedTextColor = Colors.white;
                                _isBrowseFlag = false;
                                loadMatches();
                              }
                            }
                          });
                        })),
              ]),
            ),
            _isBrowseFlag
                ? browseProfileWidgetSection
                : matchesProfileWidgetSection
          ],
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
        isMatchesLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
