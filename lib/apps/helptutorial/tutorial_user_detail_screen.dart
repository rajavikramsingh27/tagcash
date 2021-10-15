import 'package:flutter/material.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/helptutorial/models/tutorial_detail_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tagcash/apps/helptutorial/tutorial_custom_videoplayer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/services/app_service.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class TutorialUserDetailScreen extends StatefulWidget {
  final String tutorial_id;

  // In the constructor, require a Todo.
  TutorialUserDetailScreen({Key key, @required this.tutorial_id})
      : super(key: key);

  @override
  _TutorialUserDetailScreenState createState() =>
      _TutorialUserDetailScreenState();
}

class _TutorialUserDetailScreenState extends State<TutorialUserDetailScreen>
    with TickerProviderStateMixin {
  String lessonId;
  String lessonVideoFilePath;
  bool _isLoading = false;
  Future<TutorialDetailModel> tutorialDetailsData;
  String tutorialTotalTime;
  String tutorialName = "";
  String tutorialDescription = "";
  String tutorialImageURL;
  List<Chapters> chapters = [];
  int tutorialPricefreeStatus = 0;
  bool _isOwnerStatus = false;
  bool _isFavouriteStatus = false;
  String totalVideoLength = "00:00";
  bool _isChaptersLoaded = false;
  Future<TutorialDetailModel> futureTutorialDetailModel;

  @override
  void initState() {
    super.initState();
    futureTutorialDetailModel = tutorialDetailLoad(widget.tutorial_id);
    setState(() {
      futureTutorialDetailModel.then((TutorialDetailModel tutorialDetailModel) {
        if (tutorialDetailModel != null) {
          tutorialName = tutorialDetailModel.name;
          tutorialDescription = tutorialDetailModel.description;
          tutorialPricefreeStatus = tutorialDetailModel.priceFree;
          tutorialImageURL = tutorialDetailModel.imageUrl;
          chapters = tutorialDetailModel.chapters;
          _isFavouriteStatus = tutorialDetailModel.isFavourite;
          totalVideoLength =
              getTutorialTime(tutorialDetailModel.lessonTotalLength);
          if (AppService.isMerchantPerspective(context)) {
            if (tutorialDetailModel.ownerDetails.userId ==
                AppService.merchantData(context).id.toString()) {
              _isOwnerStatus = true;
            } else {
              _isOwnerStatus = false;
            }
          } else {
            _isOwnerStatus = false;
          }
          _isChaptersLoaded = true;
        } else {
          showMessage("Failed to load the details");
        }
      });
    });
  }

  Future<TutorialDetailModel> tutorialDetailLoad(String tutorialId) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['tutorial_id'] = tutorialId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/GetTutorialDetailsFromId', apiBodyObj);
    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      dynamic responseData = response['result'];

      return TutorialDetailModel.fromJson(responseData);
    } else {
      return null;
    }
  }

  void playVideLessonAPI(
      Lessons lessonObj,
      bool
          firstTimeView) async /*Here we check user has the amount to play the video*/
  {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['lesson_id'] = lessonObj.lessonId;
    Map<String, dynamic> response =
        await NetworkHelper.request('HelpTutorial/PlayLesson', apiBodyObj);

    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      navigateToVideoScreen(lessonObj, firstTimeView);
    } else {
      if (response["error"] == "lesson_id_is_required") {
        showMessage("Lesson ID is required");
      } else if (response["error"] == "you_have_insufficient_cred_balance") {
        showMessage("Insufficient CRED Balance");
      } else if (response["error"] == "transfer_to_tagcash_failed") {
        showMessage("Error:Transfer to tagcash failed");
      } else if (response["error"] ==
          "creator_have_insufficient_cred_balance") {
        showMessage("Error:Creator Insufficient Balance");
      } else if (response["error"] == "transfer_to_creator_failed") {
        showMessage("Error:Transfer to creator failed");
      }
    }
  }

  void navigateToVideoScreen(Lessons lessonObj, bool firstTimeView) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
                  videoUrl: lessonObj.fileUrl,
                  lessonId: lessonObj.lessonId,
                ))).whenComplete(() {
      if (firstTimeView == true) {
        updateViewedStatus(lessonObj.lessonId);
      }
    });
  }

  void updateViewedStatus(String lessonId) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['lesson_id'] = lessonId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/UpdateLessonViewedStatus', apiBodyObj);
    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      futureTutorialDetailModel = tutorialDetailLoad(widget.tutorial_id);
      setState(() {
        futureTutorialDetailModel
            .then((TutorialDetailModel tutorialDetailModel) {
          chapters = tutorialDetailModel.chapters;
          _isChaptersLoaded = true;
          _isFavouriteStatus = tutorialDetailModel.isFavourite;
        });
      });
    } else {
      showMessage("Update View Status Failed");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String getTutorialTime(String time) {
    String hour, minute, seconds;
    String formattedTime;
    List<String> timeList = time.split(":");

    hour = timeList[0];
    minute = timeList[1];
    seconds = timeList[2];

    if (hour == "0" || hour == "00") {
      hour = "00";
    } else {
      hour = timeList[0];
    }
    if (minute == "0" || minute == "00") {
      minute = "00";
    } else {
      minute = timeList[1];
    }
    if (seconds == "0" || seconds == "00") {
      seconds = "00";
    } else {
      seconds = timeList[2];
    }
    if (hour == "00") {
      if (minute == "00" || minute == "0") {
        formattedTime = seconds + " Seconds ";
      } else {
        formattedTime = minute + " Minutes " + seconds + " Seconds ";
      }
    } else {
      formattedTime = hour + " Hour " + minute + " Minutes ";
    }
    return formattedTime;
  }

  void appUrlCopyClicked(String moduleUrl) {
    Clipboard.setData(ClipboardData(text: moduleUrl));
    Fluttertoast.showToast(msg: 'Copied to clipboard');
  }

  showAppQr() {
    String moduleUrl = "";
    (_isOwnerStatus)
        ? moduleUrl = "https://web.tagcash.com/m/" +
            AppConstants.activeModule +
            "/" +
            widget.tutorial_id
        : moduleUrl = "https://web.tagcash.com/m/" + AppConstants.activeModule;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  QrImage(
                    data: moduleUrl,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    size: 240,
                    embeddedImage: AssetImage('assets/images/logo.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(60, 60),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    title: Text(moduleUrl),
                    trailing: IconButton(
                      icon: Icon(Icons.copy_outlined),
                      onPressed: () => appUrlCopyClicked(moduleUrl),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void changeViewStatusIcon(Lessons lessonObj, String chapterID) {
    String lessonID = lessonObj.lessonId;
    Chapters objChp =
        chapters.firstWhere((Chapters obj) => chapterID == obj.id);
    int updateChapterIndex =
        chapters.indexWhere((Chapters objch) => objChp.id == objch.id);

    List<Lessons> lessonsList = [];
    lessonsList = objChp.lessons;
    Lessons objle =
        lessonsList.firstWhere((Lessons objk) => objk.lessonId == lessonID);
    int updateLessonIndex =
        lessonsList.indexWhere((Lessons objInd) => objInd.lessonId == lessonID);

    Lessons updateLessonObj = Lessons(
        fileName: objle.fileName,
        fileSizeEqualToPriceInMb: objle.fileSizeEqualToPriceInMb,
        fileSizeInMb: objle.fileSizeInMb,
        fileUrl: objle.fileUrl,
        length: objle.length,
        lessonId: objle.lessonId,
        lessonName: objle.lessonName,
        lessonPurchasedStatus: objle.lessonPurchasedStatus,
        merchantEnteredLessonPrice: objle.merchantEnteredLessonPrice,
        priceFree: objle.priceFree,
        priceInCredits: objle.priceInCredits,
        seconds: objle.seconds,
        viewedStatus: true);
    lessonsList.removeAt(updateLessonIndex);
    lessonsList.insert(updateLessonIndex, updateLessonObj);
    Chapters upobj = Chapters(
        lessons: lessonsList,
        chapterName: objChp.chapterName,
        createdDate: objChp.createdDate,
        id: objChp.id);
    chapters.removeAt(updateChapterIndex);
    chapters.insert(updateChapterIndex, upobj);
    setState(() {});

    playVideLessonAPI(lessonObj, true);
  }

  void changeFavouriteStatus() {
    setState(() {
      _isFavouriteStatus = !_isFavouriteStatus;
    });
    changeFavouriteStatusAPI(_isFavouriteStatus);
  }

  void changeFavouriteStatusAPI(bool favouriteStatus) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['tutorial_id'] = widget.tutorial_id;
    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/AddTutorialToFavouriteNonFavourite', apiBodyObj);
    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      if (favouriteStatus == true) {
        showMessage(getTranslated(context, "tutorial_added_favourites"));
      } else {
        showMessage(getTranslated(context, "tutorial_removed_favourites"));
      }
    } else {
      setState(() {
        _isFavouriteStatus = !_isFavouriteStatus;
      });
      showMessage(getTranslated(context, "tutorial_changingstatus_failed"));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget chapterLessonList(List<Lessons> lessonsListData, String chapterID) {
      return ListView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.only(left: 0),
          itemCount: lessonsListData.length,
          itemBuilder: (BuildContext context, int index) {
            Lessons lessonObj = lessonsListData[index];
            return Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      (!_isOwnerStatus)
                          ? lessonObj.viewedStatus
                              ? GestureDetector(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 30.0,
                                  ),
                                  onTap: () {
                                    playVideLessonAPI(lessonObj, false);
                                  },
                                )
                              : GestureDetector(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.red,
                                    size: 30.0,
                                  ),
                                  onTap: () {
                                    changeViewStatusIcon(lessonObj, chapterID);
                                  },
                                )
                          : GestureDetector(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: Colors.red,
                                size: 30.0,
                              ),
                              onTap: () {
                                /*If the tutorial owner is playing video, creator has to pay to merchnat ID2
                                * So we call this API*/
                                playVideLessonAPI(lessonObj, false);
                              },
                            ),
                      SizedBox(width: 10),
                      GestureDetector(
                        child: Text(
                          lessonObj.lessonName,
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontSize,
                              fontWeight: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontWeight,
                              color: Colors.black54),
                        ),
                        onTap: () {
                          (!_isOwnerStatus)
                              ? lessonObj.viewedStatus
                                  ? playVideLessonAPI(lessonObj, false)
                                  : changeViewStatusIcon(lessonObj, chapterID)
                              : playVideLessonAPI(lessonObj, false);
                        },
                      )
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Text(
                          lessonObj.length +
                              " - " +
                              lessonObj.priceInCredits +
                              "CR",
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontSize,
                              fontWeight: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontWeight,
                              color: Colors.black54)))
                ],
              ),
            );
          });
    }

    Widget tutorialChapterLessonlDataWidget = chapters.length > 0
        ? Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 6),
                  blurRadius: 2,
                  color: Colors.red.withOpacity(0.23),
                ),
              ],
            ),
            child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.only(left: 10),
                itemCount: chapters.length,
                itemBuilder: (BuildContext context, int index) {
                  Chapters chObj = chapters[index];
                  List<Lessons> lessonsListData = chObj.lessons;
                  return ListTile(
                      contentPadding: EdgeInsets.all(0),
                      visualDensity: VisualDensity(vertical: -2),
                      title: Row(
                        children: [
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                            size: 44.0,
                          ),
                          Text(
                            chObj.chapterName,
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .fontSize,
                                fontWeight: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .fontWeight,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      subtitle: chapterLessonList(lessonsListData, chObj.id));
                }))
        : Center(child: Loading());

    Widget tutorialDataWidget =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
        child: Container(
          constraints:
              BoxConstraints(minWidth: double.infinity, maxHeight: 200),
          child: Container(
              child: CachedNetworkImage(
            alignment: Alignment.center,
            imageUrl: tutorialImageURL,
            fit: BoxFit.cover,
          )),
        ),
      ),
      SizedBox(height: 10),
      Text(tutorialName,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text(tutorialDescription,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              getTranslated(context, "tutorials_totaltime") +
                  " " +
                  totalVideoLength,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Row(
            children: [
              (!_isOwnerStatus)
                  ? GestureDetector(
                      child: Icon(Icons.favorite,
                          size: 30.0,
                          color: (_isFavouriteStatus)
                              ? Colors.green
                              : Colors.grey),
                      onTap: () {
                        changeFavouriteStatus();
                      })
                  : Container(),
              SizedBox(width: 20),
              GestureDetector(
                child: Icon(
                  Icons.qr_code,
                  color: Colors.black,
                  size: 30.0,
                ),
                onTap: () {
                  showAppQr();
                },
              )
            ],
          ),
        ],
      ),
      SizedBox(height: 10),
      (tutorialPricefreeStatus == 1)
          ? Text(getTranslated(context, "tutorials_price_free"),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
          : Text(getTranslated(context, "tutorials_price_paid"),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      tutorialChapterLessonlDataWidget
    ]);

    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: _isChaptersLoaded ? tutorialName : "Tutorial",
        ),
        body: Stack(children: [
          ListView(padding: EdgeInsets.all(10), children: [
            Container(
                child: _isChaptersLoaded ? tutorialDataWidget : Container())
          ]),
          _isLoading ? Center(child: Loading()) : SizedBox()
        ]));
  }
}
