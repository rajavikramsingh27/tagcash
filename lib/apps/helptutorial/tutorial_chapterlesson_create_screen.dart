import 'package:flutter/material.dart';
import 'package:tagcash/services/networking.dart';
import 'dart:math' as math;
import 'package:tagcash/components/custom_button.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:tagcash/components/loading.dart';
import 'package:storage_path/storage_path.dart';
import 'dart:convert';
import 'package:tagcash/apps/helptutorial/models//file_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/helptutorial/models/tutorial_detail_model.dart';
import 'package:tagcash/apps/helptutorial/tutorial_custom_videoplayer.dart';
import 'package:tagcash/apps/helptutorial/models/chapterlessonmodel.dart';
import 'package:tagcash/apps/helptutorial/tutorial_lesson_videoupload.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

class TutorialChapterLessonCreateScreen extends StatefulWidget {
  final String tutorial_id;

  // In the constructor, require a Todo.
  TutorialChapterLessonCreateScreen({Key key, @required this.tutorial_id})
      : super(key: key);

  @override
  _TutorialChapterLessonCreateScreenState createState() =>
      _TutorialChapterLessonCreateScreenState();
}

class _TutorialChapterLessonCreateScreenState
    extends State<TutorialChapterLessonCreateScreen>
    with TickerProviderStateMixin {
  bool freeTutorialStatus = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController _controller;
  static const List<IconData> icons = const [Icons.folder, Icons.theaters];

  final _chapterNameController = TextEditingController();
  final _lessonNameController = TextEditingController();
  final _lessonPriceController = TextEditingController();
  final _videoDurationController = TextEditingController();
  bool chapterEditMode = false;
  bool lessonEditMode = false;
  final _formKeyChapter = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  bool enableAutoValidateLesson = false;
  final _formKey = GlobalKey<FormState>();
  File _presentationFile;
  PlatformFile _webpresentationFile;
  String lessonVideoLengthinseconds;
  String uploadedLessonVideoFilename;
  String videoFilePath;
  bool _isLoading = false;
  bool _isChapterLessonLoading = false;
  String tutorial_id;
  String chapterId;
  String lessonId;
  final List<ChapterLessonModel> chapterLessonListData = [];
  final List<ChapterLessonModel> chapterLessonListDataOriginal =
      []; //This list is to keep the original data
  String videoFileSizeAPI = "0";
  String totalMBallowedwithMerchantPrice = "0";

  @override
  void initState() {
    super.initState();
    tutorial_id = widget.tutorial_id;
    loadChaptersAndLessonsList();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    //  loadChaptersAndLessonsList();
  }

  @override
  void dispose() {
    _lessonNameController.dispose();
    _videoDurationController.dispose();
    _lessonPriceController.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void navigateToVideoPlayer(String videoFilePath) async {
    if (videoFilePath == null) {
      Fluttertoast.showToast(
          msg: getTranslated(context, 'tutorial_invalid_videofile'));
    } else {
      // Add Your Code here.
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                    videoUrl: videoFilePath,
                    lessonId: lessonId,
                  )));
    }
  }

  void getVideoDuration(File videoFile) async {
    double duration = 0;
    String selectedFileName = path.basename(videoFile.path);
    String videospath = await StoragePath.videoPath;
    var response = jsonDecode(videospath);
    var imageList = response as List;
    for (int i = 0; i < imageList.length; i++) {
      List responseList = response[i]["files"];
      List<Files> list =
          responseList.map<Files>((json) => Files.fromJson(json)).toList();
      Files fileObj = list.firstWhere(
          (element) => element.displayName == selectedFileName, orElse: () {
        return null;
      });
      if (fileObj != null) {
        lessonVideoLengthinseconds = fileObj.duration;
        duration = double.parse(fileObj.duration);

        videoFilePath = fileObj.path;

        String fileSize = (fileObj.size).toString();
        double fileSizeD = double.parse(fileSize);
        String s = (fileSizeD / 1048576).toStringAsFixed(2);

        break;
      } else {
        duration = 0;
      }
    }
    if (duration != 0) {
      setState(() {
        _videoDurationController.text =
            getTimeInSenondsMinHour(double.parse(duration.toString()));
      });
    } else {
      _videoDurationController.text = "00:00";
    }
  }

  Future<int> getVideoFileSize(File videoFile) async {
    return videoFile.length();
  }

  String getTimeInSenondsMinHour(double time) {
    String formattedTime;

    if ((time > 999) & (time < 60000)) {
      double t = time / 1000;
      int timeseconds = t.toInt();

      formattedTime = "00:" + "00:" + timeseconds.toString();
      return formattedTime;
    } else if ((time > 59999) & (time < 3600000)) {
      String timeinMinString, timeinSecondsString;
      double timemin = time / 1000;
      int timemini = timemin.toInt();
      double timeMinDouble = timemini / 60;
      int timeMinInt = timeMinDouble.toInt();
      int timeInSecondsMod = timemini % 60;
      if (timeInSecondsMod < 10) {
        timeinSecondsString = "0" + timeInSecondsMod.toString();
      } else {
        timeinSecondsString = timeInSecondsMod.toString();
      }
      if (timeMinInt < 10) {
        timeinMinString = "0" + timeMinInt.toString();
      } else {
        timeinMinString = timeMinInt.toString();
      }

      formattedTime = "00:" + timeinMinString + ":" + timeinSecondsString;
      return formattedTime;
    } else if (time > 3600000) {
      double timeSeconds = time / 1000;

      int timeSecondsInt = timeSeconds.toInt();

      double timeMinDouble = timeSecondsInt / 60;
      int timeMinInt = timeMinDouble.toInt();
      int timeSecondsmod = timeSecondsInt % 60; //seconds value
      double timeHourDouble = timeMinInt / 60;
      int timeHourInt = timeHourDouble.toInt(); //Hour value
      int timeMinMod = timeMinInt % 60; //min value

      String timeHourIntS, timeMinModS, timeSecondsmodS;
      if (timeHourInt < 10) {
        timeHourIntS = "0" + timeHourInt.toString();
      } else {
        timeHourIntS = timeHourInt.toString();
      }
      if (timeMinMod < 10) {
        timeMinModS = "0" + timeMinMod.toString();
      } else {
        timeMinModS = timeMinMod.toString();
      }
      if (timeSecondsmod < 10) {
        timeSecondsmodS = "0" + timeSecondsmod.toString();
      } else {
        timeSecondsmodS = timeSecondsmod.toString();
      }

      formattedTime = timeHourIntS + ":" + timeMinModS + ":" + timeSecondsmodS;
      return formattedTime;
    } else {
      formattedTime = "00:00";
      return formattedTime;
    }
  }

  void saveChapterCreateHandler() async {
    Map<String, dynamic> response;
    Navigator.of(context).pop(false);

    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['chapter_name'] = _chapterNameController.text;
    apiBodyObj['tutorial_id'] = tutorial_id;
    if (chapterEditMode == false) {
      response =
          await NetworkHelper.request('HelpTutorial/AddChapter', apiBodyObj);
    } else {
      apiBodyObj['chapter_id'] = chapterId;
      response =
          await NetworkHelper.request('HelpTutorial/EditChapter', apiBodyObj);
    }

    setState(() {
      _isLoading = false;
    });
    if (response['status'] == 'success') {
      showMessage(getTranslated(context, "tutorial_chaptersave_success"));
      chapterId = response['chapter_id'];
      /*Refresh the tutorial detail here*/
      clearChapterLessonListAndReload();
    } else {
      if (response['error'] == 'switch_to_community_perspective') {
        showMessage(
            getTranslated(context, "tutorial_switch_merchantperspective"));
      } else if (response['error'] == 'failed_to_add_the_chapter') {
        showMessage(getTranslated(context, "tutorial_chapteradd_failed"));
      } else if (response['error'] == 'chapter_under_this_name_already_added') {
        showMessage(getTranslated(context, "tutorial_chaptercopyadded_error"));
      } else {
        showMessage(
            getTranslated(context, "tutorial_chapter_unspecifiederror"));
      }
    }
  }

  void saveLessonCreateHandler() async {
    Navigator.pop(context);
    Map<String, dynamic> response;
    if (chapterId == null) {
      showMessage("Chapter not found!!");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (lessonEditMode == false) {
      Map<String, dynamic> fileData;
      if (_presentationFile != null) {
        var file = _presentationFile;
        String basename = path.basename(file.path);
        fileData = {};
        fileData['key'] = 'file_data';
        fileData['fileName'] = basename;
        fileData['path'] = file.path;
      }
      Map<String, String> apiBodyObj = {};
      response = await NetworkHelper.request(
          'HelpTutorial/UploadLessonVideo', apiBodyObj, fileData);

      setState(() {
        _isLoading = false;
      });
      if (response['status'] == 'success') {
        saveLessonData(response['file_name']);
      }
    } else {
      if (_presentationFile == null) {
        saveLessonData(uploadedLessonVideoFilename);
      } else {
        Map<String, dynamic> fileData;
        if (_presentationFile != null) {
          var file = _presentationFile;
          String basename = path.basename(file.path);
          fileData = {};
          fileData['key'] = 'file_data';
          fileData['fileName'] = basename;
          fileData['path'] = file.path;
        }
        Map<String, String> apiBodyObj = {};
        Map<String, dynamic> response = await NetworkHelper.request(
            'HelpTutorial/UploadLessonVideo', apiBodyObj, fileData);

        setState(() {
          _isLoading = false;
        });
        if (response['status'] == 'success') {
          saveLessonData(response['file_name']);
        }
      }
    }
  }

  void saveLessonCreateHandlerWeb() async {
    if (freeTutorialStatus == false) {
      if (double.parse(videoFileSizeAPI) >
          double.parse(totalMBallowedwithMerchantPrice)) {
        Fluttertoast.showToast(
          msg: 'Video file size exceeds the maximum allowed size',
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }
    }
    Map<String, dynamic> response;
    Navigator.pop(context);
    if (chapterId == null) {
      showMessage(getTranslated(context, "tutorial_chapter_notfound"));
      return;
    }

    setState(() {
      _isLoading = true;
    });
    if (lessonEditMode == false) {
      response = await HelpTutorialNetworkHelper.uploadHelpTutorialSelectedFile(
          _webpresentationFile);
    } else {
      if (_webpresentationFile == null) {
        saveLessonData(uploadedLessonVideoFilename);
      } else {
        response =
            await HelpTutorialNetworkHelper.uploadHelpTutorialSelectedFile(
                _webpresentationFile);
      }
    }
    setState(() {
      _isLoading = false;
    });
    _webpresentationFile = null;
    if (response['status'] == 'success') {
      saveLessonData(response['file_name']);
    } else {
      showMessage(getTranslated(context, "tutorial_videoupload_failed"));
    }
  }

  void saveLessonData(String videofilename) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> response = {};
    Map<String, String> apiBodyObj = {};
    apiBodyObj['lesson_name'] = _lessonNameController.text;
    apiBodyObj['chapter_id'] = chapterId;
    if (freeTutorialStatus == false) {
      apiBodyObj['price_in_credits'] = _lessonPriceController.text.toString();
      apiBodyObj['  price_free'] = "0";
      apiBodyObj['file_size_equal_to_price_in_mb'] =
          totalMBallowedwithMerchantPrice;
      apiBodyObj['merchant_entered_lesson_price'] =
          _lessonPriceController.text.toString();
    } else {
      apiBodyObj['price_in_credits'] = "0";
      apiBodyObj['price_free'] = "1";
      apiBodyObj['file_size_equal_to_price_in_mb'] = "20";
      apiBodyObj['merchant_entered_lesson_price'] = "0";
    }
    apiBodyObj['file_size_in_mb'] = videoFileSizeAPI;
    if (!kIsWeb) {
      apiBodyObj['length'] = _videoDurationController.text.toString();
      apiBodyObj['total_in_seconds'] = lessonVideoLengthinseconds;
    } else {
      apiBodyObj['length'] =
          "00:01:00"; //Video Length Not available in web now. So we send a default value
      apiBodyObj['total_in_seconds'] = "60";
    }

    apiBodyObj['file_name'] = videofilename;
    if (lessonEditMode == true) {
      apiBodyObj['lesson_id'] = lessonId;
      response =
          await NetworkHelper.request('HelpTutorial/LessonEdit', apiBodyObj);
    } else {
      apiBodyObj['previous_lesson_id'] =
          lessonId; //This field is used to add a lesson to the below of  last clicked lesson
      //Last Clicked Lesson is shown as red in color
      response =
          await NetworkHelper.request('HelpTutorial/LessonCreate', apiBodyObj);
    }

    setState(() {
      _isLoading = false;
    });
    if (response['status'] == 'success') {
      showMessage(getTranslated(context, "tutorial_lessonadded_success"));
      clearChapterLessonListAndReload();
    } else {
      if (response['error'] == 'invalid_video') {
        showMessage(
            getTranslated(context, "tutorial_lessonfailed_invalidvideo"));
      } else if (response['error'] == 'invalid_chapter_id') {
        showMessage(
            getTranslated(context, "tutorial_lessonfailed_invalidchapterid"));
      } else if (response['error'] == 'lesson_already_added') {
        showMessage(
            getTranslated(context, "tutorial_lessonfailed_alreadyadded"));
      } else if (response['error'] == 'chapter_not_exist') {
        showMessage(
            getTranslated(context, "tutorial_lessonfailed_chapternotexist"));
      } else if (response['error'] == 'failed_to_add_the_lesson') {
        showMessage(getTranslated(context, "tutorial_lessonadd_failed"));
      } else if (response['error'] == 'chapter_id_is_required') {
        showMessage(
            getTranslated(context, "tutorial_lesson_chapteridrequired"));
      } else {
        showMessage(getTranslated(context, "tutorial_lesson_unspecifiederror"));
      }
    }
  }

  void reorderData(int oldindex, int newindex) {
    /*This is the case if we are handling the lessons*/
    if (chapterLessonListData[oldindex].type == "lesson") {
      if (newindex < chapterLessonListData.length) {
      } else {}
      setState(() {
        if (newindex > oldindex) {
          newindex -= 1;
        }
        final items = chapterLessonListData.removeAt(oldindex);
        chapterLessonListData.insert(newindex, items);
      });
      bool _isSameChapter = checkSameChapter(oldindex, newindex);
      if (_isSameChapter == true) {
        String name = chapterLessonListDataOriginal[oldindex].chapterLessonName;

        String positionType = "";
        String previousLessonID = "";
        String lessonSourceChapterID =
            chapterLessonListDataOriginal[oldindex].chapterid;
        String lessonID =
            chapterLessonListDataOriginal[oldindex].chapterLessonId;

        if (newindex + 1 >= chapterLessonListData.length) {
          positionType = "last";
        } else {
          if (chapterLessonListData[newindex + 1].type == "chapter") {
            positionType = "last";
          } else if (chapterLessonListData[newindex - 1].type == "chapter") {
            positionType = "first";
          } else {
            positionType = "middle";
            previousLessonID =
                chapterLessonListData[newindex - 1].chapterLessonId;
          }
        }
        dragLessonSameChapter("lesson", lessonSourceChapterID, lessonID,
            positionType, previousLessonID);
      } else {
        String dragType = "chapter_to_chapter_lesson";
        String fromChapterID =
            chapterLessonListDataOriginal[oldindex].chapterid;
        String toChapterID = getdestinationChapterID(newindex);
        String positionType = "";
        String previousLessonID = "";
        if (chapterLessonListData[newindex + 1].type == "chapter") {
          positionType = "last";
        } else if (chapterLessonListData[newindex - 1].type == "chapter") {
          positionType = "first";
        } else {
          positionType = "middle";
          previousLessonID =
              chapterLessonListData[newindex - 1].chapterLessonId;
        }

        chapterLessonListData.forEach((ChapterLessonModel modelObj) {});

        String fromLessonID =
            chapterLessonListDataOriginal[oldindex].chapterLessonId;
        String fromLessonName =
            chapterLessonListDataOriginal[oldindex].chapterLessonName;
        int chapterLessonCount = getLessonsCountInChapter(oldindex);

        if (chapterLessonCount > 2) {
          /*Count greater than 2 means the source Chapter has
more than one item in the list,If the chapter has only one item we have to delete the chapter and need to call an another PAI call,
 So here we put this condition
*/

          dragLessonToDifferentChapter(dragType, fromChapterID, toChapterID,
              positionType, fromLessonID, previousLessonID, fromLessonName);
        } else {
          dragSingleLessontoChapter("chapter_to_chapter", fromChapterID,
              toChapterID, positionType, previousLessonID, fromLessonName);
        }
      }
    } else {
      if (newindex < chapterLessonListData.length) {
        if (newindex >
            1) //new index less than one means item is dragging to first position
        {
/*Here it means we drag the chapter to before end list . so we add this less than check here*/
          /*first check we are not drag the chpater to its own lessons*/
          ChapterLessonModel chaptermodelDraggingItem =
              chapterLessonListData[oldindex];
          ChapterLessonModel lessonmodelPreviousItem =
              chapterLessonListData[newindex - 1];

          ChapterLessonModel lessonmodelNextItem =
              chapterLessonListData[newindex];
          if (lessonmodelPreviousItem.type == "lesson" &&
              lessonmodelNextItem.type == "lesson") {
            if (lessonmodelPreviousItem.chapterid !=
                chaptermodelDraggingItem.chapterid) {
              List<ChapterLessonModel> chapterLessonList =
                  getChapterLessonsFromID(chaptermodelDraggingItem.chapterid);
              setState(() {
                chapterLessonListData.insertAll(newindex, chapterLessonList);

                chapterLessonList.forEach((ChapterLessonModel item) =>
                    chapterLessonListData.remove(item));
                chapterLessonListData.removeWhere((ChapterLessonModel item) =>
                    /*Here we drag  chapter to another chapter.
              In the dragged destination chapter we dont need the old chapter heading so we remove the chapter heading*/
                    item.chapterLessonId ==
                    chaptermodelDraggingItem.chapterLessonId);
              });
              String dragType = "chapter_to_chapter";
              String fromChapterID = chaptermodelDraggingItem.chapterid;
              String toChapterID = lessonmodelPreviousItem.chapterid;
              String toPosition = "middle";
              String previousLessonID = lessonmodelPreviousItem.chapterLessonId;
              dragChapterToAnotherChapter(dragType, fromChapterID, toChapterID,
                  toPosition, previousLessonID);
            } else {}
          } else if (lessonmodelPreviousItem.type == "lesson" &&
              lessonmodelNextItem.type == "chapter") {
            if (lessonmodelPreviousItem.chapterid !=
                chaptermodelDraggingItem.chapterid) {
              List<ChapterLessonModel> chapterLessonList =
                  getChapterLessonsFromID(chaptermodelDraggingItem.chapterid);
              /*
              chapterLessonList.forEach(
                  (ChapterLessonModel item) => print(
                      item.chapterLessonName)
              );
              */
              setState(() {
                chapterLessonListData.insertAll(newindex, chapterLessonList);

                chapterLessonList.forEach((ChapterLessonModel item) =>
                    chapterLessonListData.remove(item));

/*
              chapterLessonListData.removeWhere((ChapterLessonModel item) =>/*Here we drag  chapter to another chapter.
              In the dragged destination chapter we dont need the old chapter heading so we remove the chapter hading*/
              item.chapterLessonId == chaptermodelDraggingItem.chapterLessonId);
*/
                String dragType = "chapter";
                String fromChapterID = chaptermodelDraggingItem.chapterid;
                String toPosition = "middle";
                String previousChapterID = lessonmodelPreviousItem.chapterid;
                //  dragChapterToAnotherChapter(dragType, fromChapterID, toChapterID, toPosition, previousLessonID);

                dragChapter(tutorial_id, dragType, fromChapterID, toPosition,
                    previousChapterID);
              });
            }
          } else if (lessonmodelPreviousItem.type == "chapter" &&
              lessonmodelNextItem.type == "chapter") {
            if (lessonmodelPreviousItem.chapterid !=
                chaptermodelDraggingItem.chapterid) {
              List<ChapterLessonModel> chapterLessonList =
                  getChapterLessonsFromID(chaptermodelDraggingItem.chapterid);
              setState(() {
                if (chapterLessonList.length > 1) {
                  chapterLessonListData.insertAll(newindex, chapterLessonList);

                  chapterLessonList.forEach((ChapterLessonModel item) =>
                      chapterLessonListData.remove(item));
                  /*
                chapterLessonListData.removeWhere(
                        (ChapterLessonModel item) =>
                item.chapterLessonId ==
                    chaptermodelDraggingItem.chapterLessonId);
                */
                  String dragType = "chapter";
                  String fromChapterID = chaptermodelDraggingItem.chapterid;
                  String toPosition = "middle";
                  String previousChapterID = lessonmodelPreviousItem.chapterid;
                  //  dragChapterToAnotherChapter(dragType, fromChapterID, toChapterID, toPosition, previousLessonID);

                  dragChapter(tutorial_id, dragType, fromChapterID, toPosition,
                      previousChapterID);
                } else {
                  if (newindex > oldindex) {
                    newindex -= 1;
                  }
                  final items = chapterLessonListData.removeAt(oldindex);
                  chapterLessonListData.insert(newindex, items);
                }
              });
            }
          }
        } else {
          ChapterLessonModel chaptermodelDraggingItem =
              chapterLessonListData[oldindex];

          ChapterLessonModel lessonmodelNextItem =
              chapterLessonListData[newindex];

          Future.delayed(Duration(milliseconds: 200), () {
            setState(() {
              List<ChapterLessonModel> chapterLessonList =
                  getChapterLessonsFromID(chaptermodelDraggingItem.chapterid);

              chapterLessonList.forEach((ChapterLessonModel item) =>
                  chapterLessonListData.remove(item));
              chapterLessonListData.insertAll(0, chapterLessonList);
            });
          });
          String dragType = "chapter";
          String fromChapterID = chaptermodelDraggingItem.chapterid;
          String toPosition = "first";
          String previousChapterID =
              ""; //Drag to first position. So Previos chapter ID will not be present
          dragChapter(tutorial_id, dragType, fromChapterID, toPosition,
              previousChapterID);
        }
      }
    }
  }

  List<ChapterLessonModel> getChapterLessonsFromID(String chapterid) {
    List<ChapterLessonModel> chapterLessonList1;
    chapterLessonList1 = chapterLessonListData
        .where((ChapterLessonModel item) => item.chapterid == chapterid)
        .toList();

    return chapterLessonList1;
  }

  bool checkSameChapter(int _oldIndex,
      int _newIndex) //This method we use to drag the source and destinaton of lesson within the same chapter
  {
    bool _isSameChapterFlag = false;
    String lessonSourceChapterID =
        chapterLessonListDataOriginal[_oldIndex].chapterid;
    String lessonDestinationChapterID;
    for (int i = _newIndex;
        i >= 0;
        i--) //This is to find destination chapter ID
    {
      ChapterLessonModel model = chapterLessonListData[i];
      if (model.type == "chapter") {
        lessonDestinationChapterID = model.chapterid;
        break;
      }
    }
    if (lessonSourceChapterID == lessonDestinationChapterID) {
      _isSameChapterFlag = true;
    } else {
      _isSameChapterFlag = false;
    }
    return _isSameChapterFlag;
  }

  String getdestinationChapterID(int _newIndex) {
    /*This method is using for getting the destination ChapterID*/
    String destinationChpaterID;
    for (int i = _newIndex;
        i >= 0;
        i--) //This is to find destination chapter ID
    {
      ChapterLessonModel model = chapterLessonListData[i];
      if (model.type == "chapter") {
        destinationChpaterID = model.chapterid;
        return destinationChpaterID;
      }
    }
  }

  int getLessonsCountInChapter(int oldIndex) {
    int chapterLessonCount = 0;
    String draggingItemChapterID =
        chapterLessonListDataOriginal[oldIndex].chapterid;
    chapterLessonListData.forEach((ChapterLessonModel modelObj) {
      if (draggingItemChapterID == modelObj.chapterid) {
        chapterLessonCount++;
      }
    });

    /**If count is less than 3 iit means the source chapter list is empty now*/
    return chapterLessonCount;
  }

  void setLessonValues(ChapterLessonModel obj) {
    setState(() {
      chapterId = obj.chapterid;
      lessonId = obj.chapterLessonId;

      _lessonNameController.text = obj.chapterLessonName;
      _videoDurationController.text = obj.lessonvideolength;
      uploadedLessonVideoFilename = obj.lessonVideofileName;
      videoFileSizeAPI = obj.lessonVideoFileSize;
      totalMBallowedwithMerchantPrice = obj.totalMBallowedwithMerchantPrice;

      if (freeTutorialStatus == false) {
        _lessonPriceController.text = obj.lessonpriceInCredits;
      }
      videoFilePath = obj.lessonVideofileUrl;
    });
  }

  void dragLessonSameChapter(String dragType, String chapterID, String lessonID,
      String toPosition, String previousLessonID) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['drag_type'] = dragType;
    apiBodyObj['chapter_id'] = chapterID;
    apiBodyObj['lesson_id'] = lessonID;
    apiBodyObj['to_position'] = toPosition;
    if (toPosition == "middle") {
      apiBodyObj['previous_lesson_id'] = previousLessonID;
    }

    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/DragLessonOrChapeter', apiBodyObj);

    setState(() {
      _isLoading = false;
    });
    if (response['status'] == 'success') {
      clearChapterLessonListAndReload();
    } else {
      if (response['error'] == 'switch_to_merchant_perspective') {
        showMessage(getTranslated(context, "switch_to_community_perspective"));
      } else if (response['error'] == 'failed') {
        showMessage(getTranslated(context, "tutorials_drag_failed"));
      } else if (response['error'] == 'chapter_id_details_not_found') {
        showMessage(getTranslated(context, "tutorial_chapterdetails_notfound"));
      } else if (response['error'] == 'lesson_id_not_found') {
        showMessage(getTranslated(context, "tutorial_lessonid_notfound"));
      } else {
        showMessage(getTranslated(context, "tutorial_unspecified_error"));
      }
    }
  }

  void dragLessonToDifferentChapter(
      String dragType,
      String fromChapterID,
      String toChapterID,
      String toPosition,
      String fromLessonID,
      String previousLessonID,
      String fromLessonname) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['drag_type'] = dragType;
    apiBodyObj['from_chapter_id'] = fromChapterID;
    apiBodyObj['to_chapter_id'] = toChapterID;
    apiBodyObj['to_position'] = toPosition;
    apiBodyObj['from_lesson_id'] = fromLessonID;

    if (toPosition == "middle") {
      apiBodyObj['previous_lesson_id'] = previousLessonID;
    }

    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/DragLessonOrChapeter', apiBodyObj);

    if (response['status'] == 'success') {
      clearChapterLessonListAndReload();
    } else {
      if (response['error'] == 'switch_to_merchant_perspective') {
        showMessage(getTranslated(context, "switch_to_community_perspective"));
      } else if (response['error'] == 'failed') {
        showMessage(getTranslated(context, "tutorials_drag_failed"));
      } else if (response['error'] == 'chapter_id_details_not_found') {
        showMessage(getTranslated(context, "tutorial_chapterdetails_notfound"));
      } else if (response['error'] == 'lesson_id_not_found') {
        showMessage(getTranslated(context, "tutorial_lessonid_notfound"));
      } else {
        showMessage(getTranslated(context, "tutorial_unspecified_error"));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  /*Drag a single lesson  from one chapter to another chapter is a special case, Sadique suggested this. So we add
  *
  * this method*/
  void dragSingleLessontoChapter(
      String dragType,
      String fromChapterID,
      String toChapterID,
      String toPosition,
      String previousLessonID,
      String fromLessonname) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['drag_type'] = dragType;
    apiBodyObj['from_chapter_id'] = fromChapterID;
    apiBodyObj['to_chapter_id'] = toChapterID;
    apiBodyObj['to_position'] = toPosition;

    if (toPosition == "middle") {
      apiBodyObj['previous_lesson_id'] = previousLessonID;
    }

    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/DragLessonOrChapeter', apiBodyObj);

    if (response['status'] == 'success') {
      clearChapterLessonListAndReload();
    } else {
      if (response['error'] == 'switch_to_merchant_perspective') {
        showMessage(getTranslated(context, "tutorial_switch_group"));
      } else if (response['error'] == 'failed') {
        showMessage(getTranslated(context, "tutorials_drag_failed"));
      } else if (response['error'] == 'chapter_id_details_not_found') {
        showMessage(getTranslated(context, "tutorial_chapterdetails_notfound"));
      } else if (response['error'] == 'lesson_id_not_found') {
        showMessage(getTranslated(context, "tutorial_lessonid_notfound"));
      } else {
        showMessage(
            getTranslated(context, "tutorial_chapter_unspecifiederror"));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void dragChapterToAnotherChapter(String dragType, String fromChapterID,
      String toChapterID, String toPosition, String previousLessonID) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['drag_type'] = dragType;
    apiBodyObj['from_chapter_id'] = fromChapterID;
    apiBodyObj['to_chapter_id'] = toChapterID;
    apiBodyObj['to_position'] = toPosition;
    if (toPosition == "middle") {
      apiBodyObj['previous_lesson_id'] = previousLessonID;
    }
    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/DragLessonOrChapeter', apiBodyObj);

    if (response['status'] == 'success') {
      clearChapterLessonListAndReload();
    } else {
      if (response['error'] == 'switch_to_merchant_perspective') {
        showMessage(getTranslated(context, "switch_to_community_perspective"));
      } else if (response['error'] == 'failed') {
        showMessage(getTranslated(context, "tutorials_drag_failed"));
      } else if (response['error'] == 'chapter_id_details_not_found') {
        showMessage(getTranslated(context, "tutorial_chapterdetails_notfound"));
      } else if (response['error'] == 'lesson_id_not_found') {
        showMessage(getTranslated(context, "tutorial_lessonid_notfound"));
      } else {
        showMessage(getTranslated(context, "tutorial_unspecified_error"));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void dragChapter(
    String tutorialID,
    String dragType,
    String fromChapterID,
    String toPosition,
    String previousChapterID,
  ) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['tutorial_id'] = tutorialID;
    apiBodyObj['drag_type'] = dragType;
    apiBodyObj['from_chapter_id'] = fromChapterID;
    apiBodyObj['to_position'] = toPosition;
    if (toPosition == "middle") {
      apiBodyObj['previous_chapter_id'] = previousChapterID;
    }
    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/DragLessonOrChapeter', apiBodyObj);
    if (response['status'] == 'success') {
      clearChapterLessonListAndReload();
    } else {
      if (response['error'] == 'switch_to_merchant_perspective') {
        showMessage("Switch to Group perspective and try again");
      } else if (response['error'] == 'failed') {
        showMessage("Failed");
      } else if (response['error'] == 'chapter_id_details_not_found') {
        showMessage(getTranslated(context, "tutorial_chapterdetails_notfound"));
      } else if (response['error'] == 'lesson_id_not_found') {
        showMessage(getTranslated(context, "tutorial_lessonid_notfound"));
      } else {
        showMessage(
            getTranslated(context, "tutorial_chapter_unspecifiederror"));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void clearChapterLessonListAndReload() {
    loadChaptersAndLessonsList();
  }

  void deleteChapterHandler(String chapterId) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['chapter_id'] = chapterId;
    Map<String, dynamic> response =
        await NetworkHelper.request('HelpTutorial/DeleteChapter', apiBodyObj);
    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      showMessage(getTranslated(context, "tutorial_chapterdelete_success"));
      clearChapterLessonListAndReload();
    } else {
      if (response["error"] == "switch_to_community_perspective") {
        showMessage(
            getTranslated(context, "tutorial_switch_merchantperspective"));
      } else if (response["error"] == "chapter_id_is_required") {
        showMessage(getTranslated(context, "tutorial_chapterid_notfound"));
      } else if (response["error"] == "failed_to_delete_the_chapter") {
        showMessage(getTranslated(context, "tutorial_chapterdelete_failed"));
      } else if (response["error"] == "chapter_already_deleted") {
        showMessage(getTranslated(context, "tutorial_chapteralready_deleted"));
      } else if (response["error"] ==
          "permission_denied_to_edit_this_chapter") {
        showMessage(
            getTranslated(context, "tutorial_chapterdelete_permissiondenied"));
      } else {
        showMessage(
            getTranslated(context, "tutorial_chapterdelete_unspecifiederror"));
      }
    }
  }

  void deleteLessonHandler(String lessonId) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['lesson_id'] = lessonId;
    Map<String, dynamic> response =
        await NetworkHelper.request('HelpTutorial/LessonDelete', apiBodyObj);
    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      showMessage(getTranslated(context, "tutorial_lessondelete_success"));
      clearChapterLessonListAndReload();
    } else {
      if (response["error"] == "switch_to_community_perspective") {
        showMessage(
            getTranslated(context, "tutorial_switch_merchantperspective"));
      } else if (response["error"] == "no_lesson_found") {
        showMessage(getTranslated(context, "tutorial_lesson_notfound"));
      } else if (response["error"] == "permission_denied_to_edit_this_lesson") {
        showMessage(getTranslated(context, "tutorial_lesson_permissiondenied"));
      } else if (response["error"] == "lesson_already_deleted") {
        showMessage(getTranslated(context, "tutorial_lesson_alreadydeleted"));
      } else {
        showMessage(getTranslated(context, "tutorial_lesson_unspecifiederror"));
      }
    }
  }

  void loadChaptersAndLessonsList() async {
    setState(() {
      _isChapterLessonLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['tutorial_id'] = tutorial_id;
    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/GetTutorialDetailsFromId', apiBodyObj);
    if (response["status"] == "success") {
      dynamic responseData = response['result'];
      TutorialDetailModel tutorialDetailModel =
          TutorialDetailModel.fromJson(responseData);
      if (tutorialDetailModel.priceFree == 1) {
        freeTutorialStatus = true;
      } else {
        freeTutorialStatus = false;
      }
      chapterLessonListData.clear();
      chapterLessonListDataOriginal.clear();
      List<Chapters> chapters = tutorialDetailModel.chapters;
      if (chapters.length > 0) {
        for (int i = 0; i < chapters.length; i++) {
          Chapters chObj = chapters[i];
          ChapterLessonModel chapterModel = ChapterLessonModel(
              chapterLessonId: chObj.id,
              chapterLessonName: chObj.chapterName,
              type: "chapter",
              chapterid: chObj.id,
              chapterLessonIndex: (i + 1).toString());
          chapterLessonListData.add(chapterModel);
          List<Lessons> lessons = chObj.lessons;
          for (int j = 0; j < lessons.length; j++) {
            Lessons lessonObj = lessons[j];
            ChapterLessonModel lessonModel = ChapterLessonModel(
                chapterLessonId: lessonObj.lessonId,
                chapterLessonName: lessonObj.lessonName,
                type: "lesson",
                chapterid: chObj.id,
                chapterLessonIndex: (j + 1).toString(),
                lessonpriceInCredits: lessonObj.priceInCredits,
                lessonVideofileName: lessonObj.fileName,
                lessonVideofileUrl: lessonObj.fileUrl,
                lessonvideolength: lessonObj.length,
                lessonVideoFileSize: lessonObj.fileSizeInMb,
                totalMBallowedwithMerchantPrice:
                    lessonObj.fileSizeEqualToPriceInMb);
            chapterLessonListData.add(lessonModel);
          }
        }
        chapterLessonListDataOriginal.addAll(chapterLessonListData);
        chapterId = chapterLessonListData.last.chapterid;
      } else {}
    } else {}
    setState(() {
      _isChapterLessonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool editModeWidget = false;
    Widget createOrEdirChapterSection(
        BuildContext context, bool editModechapterSection) {
      return Container(
        child: Form(
          key: _formKeyChapter,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                        child: Text(
                      editModechapterSection
                          ? getTranslated(context, "tutorials_edit_chapter")
                          : getTranslated(context, "tutorials_create_chapter"),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            Theme.of(context).textTheme.subtitle1.fontWeight,
                        color: Theme.of(context).primaryColor,
                      ),
                    )),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _chapterNameController,
                      decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "tutorials_chapter_name")),
                      validator: (chapterName) {
                        if (chapterName.isEmpty) {
                          return getTranslated(
                              context, "tutorials_chaptername_required");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                            label: getTranslated(context, "save"),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                enableAutoValidate = true;
                              });
                              if (_formKeyChapter.currentState.validate()) {
                                saveChapterCreateHandler();
                              }
                            }))
                  ])),
        ),
      );
    }

    Widget dialogContent(BuildContext context, bool editMode) {
      editModeWidget = editMode;
      return Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Stack(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                  top: 18.0,
                ),
                margin: EdgeInsets.only(top: 13.0, right: 8.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 0.0,
                        offset: Offset(0.0, 0.0),
                      ),
                    ]),
                child: createOrEdirChapterSection(context, editModeWidget)),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 15.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget showChapterCreateDialog(BuildContext context, bool editMode) {
      return Dialog(
        insetPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context, editMode),
      );
    }

    Widget getChapterSection(ChapterLessonModel obj) {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      shape: BoxShape.circle),
                  child: Center(
                      child: Text(
                    obj.chapterLessonIndex,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )),
                ),
                SizedBox(width: 4),
                Text(
                  obj.chapterLessonName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ]),
              Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text(
                      "C",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                  ),
                  SizedBox(width: 4),

                  GestureDetector(
                    child: CircleAvatar(
                      radius: 18.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    onTap: () {
                      deleteChapterHandler(obj.chapterid);
                    },
                  ), //I ,it is web it will show 2 horizontal black lines
                  (!kIsWeb) ? Container() : SizedBox(width: 20),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _chapterNameController.text = obj.chapterLessonName;
            chapterId = obj.chapterLessonId;
            chapterEditMode = true;
          });

          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  showChapterCreateDialog(context, true));
        },
      );
    }

    Widget getLessonSection(ChapterLessonModel obj) {
      {
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text(
                      obj.chapterLessonIndex,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
                  ),
                  SizedBox(width: 4),
                  Text(
                    obj.chapterLessonName,
                    style: TextStyle(
                        color:
                            lessonId != null && lessonId == obj.chapterLessonId
                                ? Colors.red[600]
                                : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ]),
                Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(
                        "L",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      child: CircleAvatar(
                        radius: 18.0,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      onTap: () {
                        deleteLessonHandler(obj.chapterLessonId);
                      },
                    ),
                    (!kIsWeb) ? Container() : SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            lessonEditMode = true;
            setLessonValues(obj);

            showDialogLessonSection(context, true);
          },
        );
      }
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'tutorial_lessons'),
        ),
        body: Stack(
          children: [
            ReorderableListView(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                for (final items in chapterLessonListData)
                  ListTile(
                      key: ValueKey(items),
                      contentPadding: EdgeInsets.all(0),
                      visualDensity: VisualDensity(vertical: -2),
                      title: (items.type == "chapter")
                          ? getChapterSection(items)
                          : getLessonSection(items))
              ],
              onReorder: reorderData,
            ),
            _isLoading ? Center(child: Loading()) : SizedBox(),
            _isChapterLessonLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
        floatingActionButton: new Column(
          mainAxisSize: MainAxisSize.min,
          children: new List.generate(icons.length, (int index) {
            Widget child = new Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: new ScaleTransition(
                  scale: new CurvedAnimation(
                    parent: _controller,
                    curve: new Interval(0.0, 1.0 - index / icons.length / 2.0,
                        curve: Curves.easeOut),
                  ),
                  child: SizedBox(
                    width: 200.0,
                    height: 200.0,
                    child: FloatingActionButton(
                      heroTag: "btn" + index.toString(),
                      backgroundColor: Colors.red,
                      child: new Icon(
                        icons[index],
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (index == 0) {
                          setState(() {
                            _chapterNameController.text = "";
                            chapterEditMode = false;
                          });

                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  showChapterCreateDialog(context, false));
                        } else {
                          setState(() {
                            lessonEditMode = false;
                            _lessonNameController.text = "";
                            _videoDurationController.text = "";
                            _lessonPriceController.text = "";
                            totalMBallowedwithMerchantPrice = "0";
                            videoFileSizeAPI = "0";
                          });

                          showDialogLessonSection(context, false);
                        }
                      },
                    ),
                  )),
            );
            return child;
          }).toList()
            ..add(
              new FloatingActionButton(
                backgroundColor: Colors.red,
                heroTag: "btn",
                child: new AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget child) {
                    return new Transform(
                      transform: new Matrix4.rotationZ(
                          _controller.value * 0.5 * math.pi),
                      alignment: FractionalOffset.center,
                      child: new Icon(
                        _controller.isDismissed ? Icons.add : Icons.close,
                        color: Colors.white,
                        size: 36,
                      ),
                    );
                  },
                ),
                onPressed: () {
                  if (_controller.isDismissed) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                },
              ),
            ),
        ));
  }

  Widget showDialogLessonSection(
      BuildContext context, bool editModeLessonSection) {
    String filesize1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                insetPadding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.only(left: 0.0, right: 0.0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(
                            top: 18.0,
                          ),
                          margin: EdgeInsets.only(top: 13.0, right: 8.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 0.0,
                                  offset: Offset(0.0, 0.0),
                                ),
                              ]),
                          child: SingleChildScrollView(
                              child: Container(
                            child: Form(
                              key: _formKey,
                              autovalidateMode: enableAutoValidateLesson
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Center(
                                            child: Text(
                                          editModeLessonSection
                                              ? getTranslated(context,
                                                  "tutorials_edit_lesson")
                                              : getTranslated(context,
                                                  "tutorials_create_lesson"),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .fontWeight,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )),
                                        SizedBox(height: 10),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _lessonNameController,
                                          decoration: InputDecoration(
                                              labelText: getTranslated(context,
                                                  'tutorial_lesson_name')),
                                          validator: (lessonName) {
                                            if (lessonName.isEmpty) {
                                              return getTranslated(context,
                                                  'tutorial_lessonname_required');
                                            }
                                            return null;
                                          },
                                        ),
                                        editModeLessonSection
                                            ? (kIsWeb)
                                                ? WebFilePickFormField(
                                                    icon: Icon(
                                                        Icons.cloud_upload),
                                                    onChanged: (newFile, size) {
                                                      if (newFile != null) {
                                                        _webpresentationFile =
                                                            newFile;
                                                        setState(() {
                                                          videoFileSizeAPI =
                                                              size.toString();
                                                        });
                                                      } else {}
                                                    },
                                                    hintText: getTranslated(
                                                        context,
                                                        "tutorials_edit_video"),
                                                    labelText:
                                                        uploadedLessonVideoFilename,
                                                  )
                                                : Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 10, 0, 0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        FilePickFormFieldM(
                                                          icon: Icon(Icons
                                                              .cloud_upload),
                                                          onChanged:
                                                              (newFile, size) {
                                                            if (newFile !=
                                                                null) {
                                                              _presentationFile =
                                                                  newFile;
                                                              getVideoDuration(
                                                                  _presentationFile);

                                                              setState(() {
                                                                videoFileSizeAPI =
                                                                    size;
                                                              });
                                                            }
                                                          },
                                                          hintText: getTranslated(
                                                              context,
                                                              "tutorials_edit_video"),
                                                          labelText:
                                                              uploadedLessonVideoFilename,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                            : (kIsWeb)
                                                ? WebFilePickFormField(
                                                    icon: Icon(
                                                        Icons.cloud_upload),
                                                    onChanged: (newFile, size) {
                                                      if (newFile != null) {
                                                        _webpresentationFile =
                                                            newFile;
                                                        setState(() {
                                                          videoFileSizeAPI =
                                                              size.toString();
                                                        });
                                                      } else {}
                                                    },
                                                    validator: (img) {
                                                      if (img == null) {
                                                        return getTranslated(
                                                            context,
                                                            'tutorial_select_video');
                                                      }
                                                      return null;
                                                    },
                                                    hintText: getTranslated(
                                                        context,
                                                        "tutorials_select_video"),
                                                    labelText: getTranslated(
                                                        context,
                                                        "tutorials_video_tutorial"),
                                                  )
                                                : FilePickFormFieldM(
                                                    icon: Icon(
                                                        Icons.cloud_upload),
                                                    onChanged: (newFile, size) {
                                                      if (newFile != null) {
                                                        _presentationFile =
                                                            newFile;
                                                        getVideoDuration(
                                                            _presentationFile);

                                                        setState(() {
                                                          videoFileSizeAPI =
                                                              size.toString();
                                                        });
                                                      } else {}
                                                    },
                                                    validator: (img) {
                                                      if (img == null) {
                                                        return getTranslated(
                                                            context,
                                                            'tutorial_select_video');
                                                      }
                                                      return null;
                                                    },
                                                    hintText: getTranslated(
                                                        context,
                                                        "tutorials_select_video"),
                                                    labelText: getTranslated(
                                                        context,
                                                        "tutorials_video_tutorial"),
                                                  ),
                                        Text(
                                          getTranslated(context,
                                                  "tutorials_selected_filesize") +
                                              videoFileSizeAPI +
                                              " MB",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        SizedBox(height: 10),
                                        (freeTutorialStatus == false)
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller:
                                                          _lessonPriceController,
                                                      decoration: InputDecoration(
                                                          labelText: getTranslated(
                                                              context,
                                                              'tutorial_price_credits')),
                                                      validator: (lessonPrice) {
                                                        if (_lessonPriceController
                                                            .text.isEmpty) {
                                                          return getTranslated(
                                                              context,
                                                              'tutorial_valid_price');
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                              decimal: true),
                                                      onChanged: (price) {
                                                        setState(() {
                                                          if (price
                                                              .isNotEmpty) {
                                                            try {
                                                              double pri =
                                                                  double.parse(
                                                                      price);
                                                              double
                                                                  totalMBAlloweddb =
                                                                  pri * 500;

                                                              if (pri >= 0.01) {
                                                                totalMBallowedwithMerchantPrice =
                                                                    totalMBAlloweddb
                                                                        .toStringAsFixed(
                                                                            2);
                                                              } else {
                                                                totalMBallowedwithMerchantPrice =
                                                                    "0";
                                                              }
                                                            } catch (error) {}
                                                          } else {
                                                            totalMBallowedwithMerchantPrice =
                                                                "0";
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  (!kIsWeb)
                                                      ? Expanded(
                                                          child: TextFormField(
                                                            controller:
                                                                _videoDurationController,
                                                            decoration:
                                                                InputDecoration(
                                                                    labelText:
                                                                        'Length'),
                                                            validator:
                                                                (videoDuration) {
                                                              if (videoDuration
                                                                  .isEmpty) {
                                                                return getTranslated(
                                                                    context,
                                                                    'tutorial_valid_videofile');
                                                              }
                                                              return null;
                                                            },
                                                            readOnly: true,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              )
                                            : (!kIsWeb)
                                                ? TextFormField(
                                                    controller:
                                                        _videoDurationController,
                                                    decoration: InputDecoration(
                                                        labelText: 'Length'),
                                                    validator: (videoDuration) {
                                                      if (videoDuration
                                                          .isEmpty) {
                                                        return getTranslated(
                                                            context,
                                                            'tutorial_valid_videofile');
                                                      }
                                                      return null;
                                                    },
                                                  )
                                                : Container(),
                                        SizedBox(height: 10),
                                        (freeTutorialStatus)
                                            ? Container()
                                            : Text(
                                                getTranslated(context,
                                                        "tutorial_lesson_uploadfilemax") +
                                                    totalMBallowedwithMerchantPrice +
                                                    " MB",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1,
                                              ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomButton(
                                                  label: getTranslated(context,
                                                      'tutorial_play_video'),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  onPressed: () {
                                                    navigateToVideoPlayer(
                                                        videoFilePath);
                                                  }),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: CustomButton(
                                                  label: getTranslated(
                                                      context, 'tutorial_save'),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  onPressed: () {
                                                    setState(() {
                                                      enableAutoValidateLesson =
                                                          true;
                                                    });
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      (kIsWeb)
                                                          ? saveLessonCreateHandlerWeb()
                                                          : saveLessonCreateHandler();
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ])),
                            ),
                          ))),
                      Positioned(
                        right: 0.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: CircleAvatar(
                              radius: 15.0,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }
}

class WebFilePickFormField extends StatefulWidget {
  WebFilePickFormField({
    Key key,
    this.icon,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.onSaved,
  }) : super(key: key);

  final Icon icon;
  final String labelText;
  final String hintText;
  final void Function(PlatformFile) onSaved;
  final void Function(PlatformFile, double) onChanged;
  final String Function(PlatformFile) validator;

  @override
  _WebFilePickFormFieldState createState() => _WebFilePickFormFieldState();
}

class _WebFilePickFormFieldState extends State<WebFilePickFormField> {
  PlatformFile _pickedFile;

  String fileName;
  String fileDetails;

  @override
  void initState() {
    super.initState();

    fileName = widget.labelText;
    fileDetails = widget.hintText;
  }

  void selectFileClicked() async {
    /*Image Picker causes freeze the view while sending ivideo as bytes, So now we use file picker and send video as stream*/
    FilePickerResult result = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'wmv', 'flv', 'avi'],
    );
    if (result != null) {
      PlatformFile pfile = result.files.first;

      fileName = pfile.name;
      fileDetails = '';
      setPickedFIle(pfile);
      // setPickedFIle(file);
    } else {}
  }

  void setPickedFIle(PlatformFile imageFile) {
    int filesize = imageFile.size;
    double fileSizeMB = double.parse((filesize / 1000000).toStringAsFixed(2));

    setState(() {
      _pickedFile = imageFile;
    });
    if (widget.onChanged != null) {
      widget.onChanged(imageFile, fileSizeMB);
    }
  }

  void clearPicked() {
    setState(() {
      _pickedFile = null;
      fileName = widget.labelText;
      fileDetails = widget.hintText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField(onSaved: (_) {
      if (widget.onSaved != null) return widget.onSaved(_pickedFile);
      return null;
    }, validator: (_) {
      if (widget.validator != null) return widget.validator(_pickedFile);
      return null;
    }, builder: (state) {
      return Column(
        children: [
          Card(
            child: ListTile(
              leading: widget.icon,
              title: Text(fileName),
              subtitle: Text(fileDetails),
              onTap: () => selectFileClicked(),
              trailing: _pickedFile != null
                  ? IconButton(
                      icon: Icon(Icons.close_outlined),
                      onPressed: () => clearPicked(),
                    )
                  : SizedBox(),
            ),
          ),
          state.hasError
              ? Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    state.errorText,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.red),
                  ))
              : SizedBox()
        ],
      );
    });
  }
}

class FilePickFormFieldM extends StatefulWidget {
  FilePickFormFieldM({
    Key key,
    this.icon,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.onSaved,
  }) : super(key: key);

  final Icon icon;
  final String labelText;
  final String hintText;
  final void Function(File) onSaved;
  final void Function(File, String) onChanged;
  final String Function(File) validator;

  @override
  _FilePickFormFieldMState createState() => _FilePickFormFieldMState();
}

class _FilePickFormFieldMState extends State<FilePickFormFieldM> {
  File _pickedFile;

  String fileName;
  String fileDetails;

  @override
  void initState() {
    super.initState();

    fileName = widget.labelText;
    fileDetails = widget.hintText;
  }

  void selectFileClicked() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);
      fileName = result.files.single.name;
      fileDetails = '';
      setPickedFIle(file);
    }
  }

  void setPickedFIle(File imageFile) {
    int filesize = imageFile.lengthSync();
    double fileSizeMB = double.parse((filesize / 1048576).toStringAsFixed(2));
 
    setState(() {
      _pickedFile = imageFile;
    });
    if (widget.onChanged != null) {
      widget.onChanged(imageFile, fileSizeMB.toString());
    }
  }

  void clearPicked() {
    setState(() {
      _pickedFile = null;
      fileName = widget.labelText;
      fileDetails = widget.hintText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField(onSaved: (_) {
      if (widget.onSaved != null) return widget.onSaved(_pickedFile);
      return null;
    }, validator: (_) {
      if (widget.validator != null) return widget.validator(_pickedFile);
      return null;
    }, builder: (state) {
      return Column(
        children: [
          Card(
            child: ListTile(
              leading: widget.icon,
              title: Text(fileName),
              subtitle: Text(fileDetails),
              onTap: () => selectFileClicked(),
              trailing: _pickedFile != null
                  ? IconButton(
                      icon: Icon(Icons.close_outlined),
                      onPressed: () => clearPicked(),
                    )
                  : SizedBox(),
            ),
          ),
          state.hasError
              ? Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    state.errorText,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.red),
                  ))
              : SizedBox()
        ],
      );
    });
  }
}
